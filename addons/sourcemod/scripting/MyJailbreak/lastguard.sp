/*
 * MyJailbreak - Last Guard Rule Plugin.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
 *
 * This file is part of the MyJailbreak SourceMod Plugin.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */


/******************************************************************************
                   STARTUP
******************************************************************************/


//Includes
#include <myjailbreak> //... all other includes in myjailbreak.inc


//Compiler Options
#pragma semicolon 1
#pragma newdecls required


//Booleans
bool IsLastGuard;
bool AllowLastGuard;
bool IsLR;
bool MinCT = false;


//Console Variables
ConVar gc_bPlugin;
ConVar gc_bSetCT;
ConVar gc_bVote;
ConVar gc_bAutomatic;
ConVar gc_iMinCT;
ConVar gc_fBeaconTime;
ConVar gc_iTruceTime;
ConVar gc_iTime;
ConVar gc_iTimePerT;
ConVar gc_bFreeze;
ConVar gc_iHPmultipler;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar gc_bSounds;
ConVar gc_sSoundStartPath;
ConVar gc_sSoundLastCTPath;
ConVar gc_sCustomCommand;


//Integers
int g_iTruceTime;
int g_iVoteCount;


//Handles
Handle TruceTimer;
Handle LastGuardMenu;
Handle BeaconTimer;


//Strings
char g_sHasVoted[1500];
char g_sSoundStartPath[256];
char g_sSoundLastCTPath[256];
char g_sCustomCommand[64];
char g_sMyJBLogFile[PLATFORM_MAX_PATH];
char g_sOverlayStartPath[256];


//Info
public Plugin myinfo = {
	name = "MyJailbreak - Last Guard Rule",
	author = "shanapu",
	description = "Last Guard Rule for Jailbreak Server",
	version = PLUGIN_VERSION,
	url = URL_LINK
};


//Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.LastGuard.phrases");
	
	
	//Client Commands
	RegConsoleCmd("sm_lastguard", VoteLastGuard, "Allows terrors to vote and last CT to set Last Guard Rule");	
	
	
	//AutoExecConfig
	AutoExecConfig_SetFile("LastGuard", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_lastguard_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_lastguard_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_sCustomCommand = AutoExecConfig_CreateConVar("sm_lastguard_cmd", "lg", "Set your custom chat command for Last Guard Rule. no need for sm_ or !");
	gc_bSetCT = AutoExecConfig_CreateConVar("sm_lastguard_ct", "1", "0 - disabled, 1 - allow last CT to set Last Guard Rule", _, true,  0.0, true, 1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_lastguard_vote", "1", "0 - disabled, 1 - allow alive player to vote for Last Guard Rule", _, true,  0.0, true, 1.0);
	gc_bAutomatic = AutoExecConfig_CreateConVar("sm_lastguard_auto", "0", "0 - disabled, 1 - Last Guard Rule will start automatic if there is only 1 CT. Disables sm_lastguard_vote & sm_lastguard_ct.", _, true,  0.0, true, 1.0);
	gc_iMinCT = AutoExecConfig_CreateConVar("sm_lastguard_minct", "2", "How many Counter-Terrorist must be on Roundstart to enable LGR? ", _, true,  2.0);
	gc_iHPmultipler = AutoExecConfig_CreateConVar("sm_lastguard_hp", "50", "How many percent of the combined Terror Health the CT get? (3 terror alive with 100HP = 300HP / 50% = CT get 150HP)", _, true,  0.0);
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_lastguard_trucetime", "10", "Time in seconds players can't deal damage. Half of this time you are freezed", _, true,  8.0);
	gc_iTime = AutoExecConfig_CreateConVar("sm_lastguard_time", "5", "Time in minutes to end the last guard rule - 0 = keep original time", _, true,  0.0);
	gc_fBeaconTime = AutoExecConfig_CreateConVar("sm_lastguard_beacon_time", "300", "Time in seconds until the beacon turned on (set to 0 to disable)", _, true, 0.0);
	gc_iTimePerT = AutoExecConfig_CreateConVar("sm_lastguard_time_per_T", "60", "Time in seconds to add to sm_lastguard_time per living terror - 0 = no extra time per t", _, true,  0.0);
	gc_bFreeze = AutoExecConfig_CreateConVar("sm_lastguard_freeze", "0", "0 - disabled, 1 - Freeze all players the half of trucetime.", _, true,  0.0, true, 1.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_lastguard_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true, 0.1, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_lastguard_sounds_start", "music/MyJailbreak/start.mp3", "Path to the soundfile which should be played for LGR beginn.");
	gc_sSoundLastCTPath = AutoExecConfig_CreateConVar("sm_lastguard_sounds_beginn", "music/MyJailbreak/lastct.mp3", "Path to the soundfile which should be played for LGR anouncment.");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_lastguard_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true,  0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_lastguard_overlays_start", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	
	//Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_team", Event_PlayerTeamDeath);
	HookEvent("player_death", Event_PlayerTeamDeath);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundLastCTPath, OnSettingChanged);
	HookConVarChange(gc_sCustomCommand, OnSettingChanged);
	
	
	//Find
	g_iTruceTime = gc_iTruceTime.IntValue;
	gc_sOverlayStartPath.GetString(g_sOverlayStartPath , sizeof(g_sOverlayStartPath));
	gc_sSoundLastCTPath.GetString(g_sSoundLastCTPath, sizeof(g_sSoundLastCTPath));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
	gc_sCustomCommand.GetString(g_sCustomCommand , sizeof(g_sCustomCommand));
	
	
	//Set directory for LogFile - must be created before
	SetLogFile(g_sMyJBLogFile, "MyJB");
}


//ConVarChange for Strings
public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sOverlayStartPath)
	{
		strcopy(g_sOverlayStartPath, sizeof(g_sOverlayStartPath), newValue);
		if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayStartPath);
	}
	else if(convar == gc_sSoundStartPath)
	{
		strcopy(g_sSoundStartPath, sizeof(g_sSoundStartPath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStartPath);
	}
	else if(convar == gc_sSoundLastCTPath)
	{
		strcopy(g_sSoundLastCTPath, sizeof(g_sSoundLastCTPath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundLastCTPath);
	}
	else if(convar == gc_sCustomCommand)
	{
		strcopy(g_sCustomCommand, sizeof(g_sCustomCommand), newValue);
		char sBufferCMD[64];
		Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
		if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
			RegConsoleCmd(sBufferCMD, VoteLastGuard, "Allows players to vote for Last Guard Rule");
	}
}


/******************************************************************************
                   COMMANDS
******************************************************************************/


//Voting for Last Guard Rule
public Action VoteLastGuard(int client,int args)
{
	char steamid[64];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	
	if (gc_bPlugin.BoolValue && !gc_bAutomatic.BoolValue)
	{
		if (gc_bVote.BoolValue && (GetClientTeam(client) == CS_TEAM_T) && IsPlayerAlive(client))
		{
			if ((GetAliveTeamCount(CS_TEAM_CT) == 1) && (GetAliveTeamCount(CS_TEAM_T) > 1 ))
			{
				char EventDay[64];
				GetEventDayName(EventDay);
				
				if(!IsEventDayRunning())
				{
					if (!IsLastGuard)
					{
						if (!IsLR)
						{
							if (StrContains(g_sHasVoted, steamid, true) == -1)
							{
								int playercount = (GetAliveTeamCount(CS_TEAM_T) / 2);
								g_iVoteCount++;
								int Missing = playercount - g_iVoteCount + 1;
								Format(g_sHasVoted, sizeof(g_sHasVoted), "%s,%s", g_sHasVoted, steamid);
								
								if (g_iVoteCount > playercount)
								{
									StartLastGuard();
									if(ActiveLogging()) LogToFileEx(g_sMyJBLogFile, "Last Guard Rule was started by voting");
								}
								else CPrintToChatAll("%t %t", "lastguard_tag" , "lastguard_need", Missing, client);
							}
							else CPrintToChat(client, "%t %t", "lastguard_tag" , "lastguard_voted");
						}
						else CPrintToChat(client, "%t %t", "lastguard_tag" , "lastguard_lr");
					}
					else CPrintToChat(client, "%t %t", "lastguard_tag" , "lastguard_running");
				}
				else CPrintToChat(client, "%t %t", "lastguard_tag" , "lastguard_progress" , EventDay);
			}
			else CPrintToChat(client, "%t %t", "lastguard_tag" , "lastguard_minplayer");
		}
		else if (gc_bSetCT.BoolValue && (GetClientTeam(client) == CS_TEAM_CT) && IsPlayerAlive(client))
		{
			if ((GetAliveTeamCount(CS_TEAM_CT) == 1) && (GetAliveTeamCount(CS_TEAM_T) > 1 ))
			{
				char EventDay[64];
				GetEventDayName(EventDay);
				
				if(!IsEventDayRunning())
				{
					if (!IsLastGuard)
					{
						if(!IsLR)
						{
							StartLastGuard();
							if(ActiveLogging()) LogToFileEx(g_sMyJBLogFile, "Last Guard Rule was started by last CT %L", client);
						}
						else CPrintToChat(client, "%t %t", "lastguard_tag" , "lastguard_lr");
					}
					else CPrintToChat(client, "%t %t", "lastguard_tag" , "lastguard_running");
				}
				else CPrintToChat(client, "%t %t", "lastguard_tag" , "lastguard_progress" , EventDay);
			}
			else CPrintToChat(client, "%t %t", "lastguard_tag" , "lastguard_minplayer");
		}
		else CPrintToChat(client, "%t %t", "lastguard_tag" , "lastguard_notalive");
	}
	else CPrintToChat(client, "%t %t", "lastguard_tag" , "lastguard_disabled");
}


/******************************************************************************
                   EVENTS
******************************************************************************/


//Initialize Event
public void Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	IsLR = false;
	IsLastGuard = false;
	MinCT = false;
	g_iVoteCount = 0;
	AllowLastGuard = false;
	CreateTimer(2.5, Timer_LastGuardBeginn); 
	if (GetAliveTeamCount(CS_TEAM_CT) >= gc_iMinCT.IntValue) MinCT = true;
}


//Round End
public void Event_RoundEnd(Event event, char[] name, bool dontBroadcast)
{
	int winner = event.GetInt("winner");
	
	Format(g_sHasVoted, sizeof(g_sHasVoted), "");
	if (IsLastGuard)
	{
		LoopClients(client)
		{
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
		}
		delete TruceTimer;
		delete BeaconTimer;
		if (winner == 2) PrintCenterTextAll("%t", "lastguard_twin_nc");
		if (winner == 3) PrintCenterTextAll("%t", "lastguard_ctwin_nc");
		
		SetLastGuardRule(false);
		IsLastGuard = false;
		SetCvar("sm_hosties_lr", 1);
		SetCvar("sm_weapons_t", 0);
		SetCvar("sm_warden_enable", 1);
		CPrintToChatAll("%t %t", "lastguard_tag" , "lastguard_end");
	}
	
	AllowLastGuard = false;
	IsLR = false;
}


//Check player count when player dies or change team
public void Event_PlayerTeamDeath(Event event, const char[] name, bool dontBroadcast)
{
	if(AllowLastGuard)CheckStatus();
}


/******************************************************************************
                   FUNCTIONS
******************************************************************************/


//Prepare Event
public Action StartLastGuard()
{
	if(AllowLastGuard)
	{
		IsLastGuard = true;
		g_iVoteCount = 0;
		
		SJD_OpenDoors();
		
		SetLastGuardRule(true);
		
		if (gc_fBeaconTime.FloatValue > 0.0) BeaconTimer = CreateTimer(gc_fBeaconTime.FloatValue, Timer_BeaconOn, TIMER_FLAG_NO_MAPCHANGE);
		
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_weapons_t", 1);
		SetCvar("sm_warden_enable", 0);
		int Tcount = (GetAliveTeamCount(CS_TEAM_T)*gc_iTimePerT.IntValue);
		
		if(gc_iTime.IntValue != 0) GameRules_SetProp("m_iRoundTime", (60+Tcount+(gc_iTime.IntValue*60)), 4, 0, true);
		
		if(gc_bSounds.BoolValue)
		{
			CreateTimer(0.5, Timer_LastGuardSound); 
		}
		
		int HPterrors = 0;
		int HPterBuffer = 0;
		LoopClients(i) if(IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T)
		{
			HPterBuffer = (GetClientHealth(i) + HPterrors);
			HPterrors = HPterBuffer;
			HPterBuffer = 0;
			
			SetEntityMoveType(i, MOVETYPE_WALK);
			SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
			SetEntityRenderColor(i, 255, 255, 255, 255);
			CreateTimer( 0.0, DeleteOverlay, i);
			ChangeRebelStatus(i,true);
		}
		int HPCT = RoundToCeil(HPterrors * (gc_iHPmultipler.FloatValue / 100.0));
		LoopClients(iClient)
		{
			char info[64];
			LastGuardMenu = CreatePanel();
			Format(info, sizeof(info), "%T", "lastguard_info_title", iClient);
			SetPanelTitle(LastGuardMenu, info);
			DrawPanelText(LastGuardMenu, "                                   ");
			Format(info, sizeof(info), "%T", "lastguard_info_line1", iClient);
			DrawPanelText(LastGuardMenu, info);
			DrawPanelText(LastGuardMenu, "-----------------------------------");
			Format(info, sizeof(info), "%T", "lastguard_info_line2", iClient);
			DrawPanelText(LastGuardMenu, info);
			Format(info, sizeof(info), "%T", "lastguard_info_line3", iClient);
			DrawPanelText(LastGuardMenu, info);
			Format(info, sizeof(info), "%T", "lastguard_info_line4", iClient);
			DrawPanelText(LastGuardMenu, info);
			Format(info, sizeof(info), "%T", "lastguard_info_line5", iClient);
			DrawPanelText(LastGuardMenu, info);
			Format(info, sizeof(info), "%T", "lastguard_info_line6", iClient);
			DrawPanelText(LastGuardMenu, info);
			Format(info, sizeof(info), "%T", "lastguard_info_line7", iClient);
			DrawPanelText(LastGuardMenu, info);
			DrawPanelText(LastGuardMenu, "-----------------------------------");
			Format(info, sizeof(info), "%T", "warden_close", iClient);
			DrawPanelItem(LastGuardMenu, info); 
			SendPanelToClient(LastGuardMenu, iClient, Handler_NullCancel, 20);
			
			SetEntData(iClient, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
			SetEntProp(iClient, Prop_Data, "m_takedamage", 0, 1);
			
			if (gc_bFreeze.BoolValue) SetEntityMoveType(iClient, MOVETYPE_NONE);
			
		//	FakeClientCommand(iClient, "sm_guns");
			
			if(IsPlayerAlive(iClient) && GetClientTeam(iClient) == CS_TEAM_CT)
			{
				SetEntityHealth(iClient, HPCT);
				CPrintToChatAll("%t %t", "lastguard_tag", "lastguard_hp", GetAliveTeamCount(CS_TEAM_T), HPterrors, iClient, HPCT);
			}
		}
		
		g_iTruceTime--;
		TruceTimer = CreateTimer(1.0, Timer_TruceUntilStart, _, TIMER_REPEAT);
		
		CPrintToChatAll("%t %t", "lastguard_tag" , "lastguard_startnow");
		PrintCenterTextAll("%t", "lastguard_startnow_nc");
	}
}


//check count for automatic 
public Action CheckStatus()
{
	if (gc_bPlugin.BoolValue && !IsLR && !IsLastGuard && gc_bAutomatic.BoolValue)
	{
		if ((GetAliveTeamCount(CS_TEAM_CT) == 1) && (GetAliveTeamCount(CS_TEAM_T) > 1 ) && !IsEventDayRunning() && !IsLastGuard && !IsLR && MinCT)
		{
			StartLastGuard();
			if(ActiveLogging()) LogToFileEx(g_sMyJBLogFile, "Last Guard Rule was started automatic");
			MinCT = false;
		}
	}
}


/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/


//Prepare Plugin & modules
public void OnMapStart()
{
	g_iVoteCount = 0;
	IsLastGuard = false;
	IsLR = false;
	
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStartPath);    //Add sound to download and precache table
	if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundLastCTPath);    //Add sound to download and precache table
	if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayStartPath);    //Add overlay to download and precache table
}


//Prepare client for Plugin
public void OnConfigsExecuted()
{
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	char sBufferCMD[64];    //Register the custom command 
	Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
	if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMD, VoteLastGuard, "Allows players to vote for Last Guard Rule");
}


//Map End
public void OnMapEnd()
{
	IsLastGuard = false;
	AllowLastGuard = false;
	delete TruceTimer;
	g_iVoteCount = 0;
	g_sHasVoted[0] = '\0';
	
	SetLastGuardRule(false);
}


//Client Disconnect
public void OnClientDisconnect_Post(int client)
{
	if(AllowLastGuard)CheckStatus();
}


//When a last request is available
public int OnAvailableLR(int Announced)
{
	IsLR = true;
	delete BeaconTimer;
}


/******************************************************************************
                   TIMER
******************************************************************************/


//Start Timer
public Action Timer_TruceUntilStart(Handle timer)
{
	if (g_iTruceTime > 1)
	{
		g_iTruceTime--;
		LoopClients(client) if (IsPlayerAlive(client))
		{
			PrintCenterText(client,"%t", "lastguard_timeuntilstart_nc", g_iTruceTime);
			if (gc_bFreeze.BoolValue && (g_iTruceTime <= (gc_iTruceTime.IntValue / 2)) && (GetEntityMoveType(client) == MOVETYPE_NONE))
			{
				SetEntityMoveType(client, MOVETYPE_WALK);
				PrintCenterText(client,"%t", "lastguard_movenow_nc", g_iTruceTime);
				CPrintToChat(client, "%t %t", "lastguard_tag" , "lastguard_movenow");
				
			}
		}
		
		return Plugin_Continue;
	}
	
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	LoopClients(client) if (IsPlayerAlive(client))
	{
		SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
		PrintCenterText(client,"%t", "lastguard_start_nc");
		if(gc_bOverlays.BoolValue) ShowOverlay(client, g_sOverlayStartPath, 2.0);
		if(gc_bSounds.BoolValue)
		{
			EmitSoundToAllAny(g_sSoundStartPath);
		}
		FakeClientCommand(client, "sm_guns");
	}
	CPrintToChatAll("%t %t", "lastguard_tag" , "lastguard_start");
	
	TruceTimer = null;
	return Plugin_Stop;
}


public Action Timer_LastGuardSound(Handle timer)
{
	EmitSoundToAllAny(g_sSoundLastCTPath);
}


public Action Timer_LastGuardBeginn(Handle timer)
{
	AllowLastGuard = true;
}


public Action Timer_BeaconOn(Handle timer)
{
	LoopValidClients(i,true,false) BeaconOn(i, 2.0);
	BeaconTimer = null;
}