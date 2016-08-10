/*
 * MyJailbreak - Hide in the Dark Event Day Plugin.
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
bool IsHide;
bool StartHide;


//Console Variables
ConVar gc_bPlugin;
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_bVote;
ConVar gc_bOverlays;
ConVar gc_bFreezeHider;
ConVar gc_iRoundTime;
ConVar gc_fBeaconTime;
ConVar gc_iCooldownDay;
ConVar gc_iCooldownStart;
ConVar gc_iFreezeTime;
ConVar gc_sOverlayStartPath;
ConVar gc_bSounds;
ConVar gc_sSoundStartPath;
ConVar gc_iRounds;
ConVar gc_iTAgrenades;
ConVar g_iGetRoundTime;
ConVar gc_sCustomCommand;
ConVar g_sOldSkyName;
ConVar gc_sAdminFlag;


//Integers
int g_iOldRoundTime;
int g_iFreezeTime;
int g_iCoolDown;
int g_iVoteCount;
int g_iRound;
int g_iMaxRound;
int g_iMaxTA;
int g_iTA[MAXPLAYERS + 1];


//Handles
Handle FreezeTimer;
Handle HideMenu;
Handle BeaconTimer;


//Strings
char g_sHasVoted[1500];
char g_sSoundStartPath[256];
char g_sCustomCommand[64];
char g_sEventsLogFile[PLATFORM_MAX_PATH];
char g_sSkyName[256];
char g_sAdminFlag[32];
char g_sOverlayStartPath[256];


//Info
public Plugin myinfo = {
	name = "MyJailbreak - HideInTheDark",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = PLUGIN_VERSION,
	url = URL_LINK
};


//Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.Hide.phrases");
	
	
	//Client Commands
	RegConsoleCmd("sm_sethide", SetHide, "Allows the Admin or Warden to set hide as next round");
	RegConsoleCmd("sm_hide", VoteHide, "Allows players to vote for a hide");
	
	
	//AutoExecConfig
	AutoExecConfig_SetFile("Hide", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_hide_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_hide_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_sCustomCommand = AutoExecConfig_CreateConVar("sm_hide_cmd", "seek", "Set your custom chat command for Event voting. no need for sm_ or !");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_hide_warden", "1", "0 - disabled, 1 - allow warden to set hide round", _, true,  0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_hide_admin", "1", "0 - disabled, 1 - allow admin/vip to set hide round", _, true,  0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_hide_flag", "g", "Set flag for admin/vip to set this Event Day.");
	gc_bVote = AutoExecConfig_CreateConVar("sm_hide_vote", "1", "0 - disabled, 1 - allow player to vote for hide round", _, true,  0.0, true, 1.0);
	gc_bFreezeHider = AutoExecConfig_CreateConVar("sm_hide_freezehider", "1", "0 - disabled, 1 - enable freeze hider when hidetime gone", _, true,  0.0, true, 1.0);
	gc_iTAgrenades = AutoExecConfig_CreateConVar("sm_hide_tagrenades", "3", "how many tagrenades a guard have?", _, true, 1.0);
	gc_iRounds = AutoExecConfig_CreateConVar("sm_hide_rounds", "1", "Rounds to play in a row", _, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_hide_roundtime", "5", "Round time in minutes for a single war round", _, true, 1.0);
	gc_fBeaconTime = AutoExecConfig_CreateConVar("sm_hide_beacon_time", "240", "Time in seconds until the beacon turned on (set to 0 to disable)", _, true, 0.0);
	gc_iFreezeTime = AutoExecConfig_CreateConVar("sm_hide_hidetime", "30", "Time in seconds to hide / CT freezed", _, true,  0.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_hide_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true,  0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_hide_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true,  0.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_hide_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true,  0.0, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_hide_sounds_start", "music/MyJailbreak/start.mp3", "Path to the soundfile which should be played for start");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_hide_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true,  0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_hide_overlays_start", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	
	//Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("tagrenade_detonate", Event_TA_Detonate);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sCustomCommand, OnSettingChanged);
	HookConVarChange(gc_sAdminFlag, OnSettingChanged);
	
	
	//FindConVar
	g_iGetRoundTime = FindConVar("mp_roundtime");
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	gc_sOverlayStartPath.GetString(g_sOverlayStartPath , sizeof(g_sOverlayStartPath));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
	gc_sCustomCommand.GetString(g_sCustomCommand , sizeof(g_sCustomCommand));
	gc_sAdminFlag.GetString(g_sAdminFlag , sizeof(g_sAdminFlag));
	
	SetLogFile(g_sEventsLogFile, "Events");
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
	else if(convar == gc_sAdminFlag)
	{
		strcopy(g_sAdminFlag, sizeof(g_sAdminFlag), newValue);
	}
	else if(convar == gc_sCustomCommand)
	{
		strcopy(g_sCustomCommand, sizeof(g_sCustomCommand), newValue);
		char sBufferCMD[64];
		Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
		if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
			RegConsoleCmd(sBufferCMD, VoteHide, "Allows players to vote for hide");
	}
}


//Initialize Plugin
public void OnConfigsExecuted()
{
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iMaxRound = gc_iRounds.IntValue;
	g_iMaxTA = gc_iTAgrenades.IntValue - 1;
	
	char sBufferCMD[64];
	Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
	if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMD, VoteHide, "Allows players to vote for hide");
}


/******************************************************************************
                   COMMANDS
******************************************************************************/


//Admin & Warden set Event
public Action SetHide(int client,int args)
{
	if (gc_bPlugin.BoolValue)	
	{
		if(client == 0)
		{
			StartNextRound();
			if(ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event Hide was started by groupvoting");
		}
		else if (warden_iswarden(client))
		{
			if (gc_bSetW.BoolValue)	
			{
				if ((GetTeamClientCount(CS_TEAM_CT) > 0) && (GetTeamClientCount(CS_TEAM_T) > 0 ))
				{
					char EventDay[64];
					GetEventDayName(EventDay);
					
					if(StrEqual(EventDay, "none", false))
					{
						if (g_iCoolDown == 0)
						{
							StartNextRound();
							if(ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event Hide was started by warden %L", client);
						}
						else CPrintToChat(client, "%t %t", "hide_tag" , "hide_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "hide_tag" , "hide_progress" , EventDay);
				}
				else CPrintToChat(client, "%t %t", "hide_tag" , "hide_minplayer");
			}
			else CPrintToChat(client, "%t %t", "hide_tag" , "hide_setbywarden");
		}
		else if (CheckVipFlag(client,g_sAdminFlag))
		{
			if (gc_bSetA.BoolValue)
			{
				if ((GetTeamClientCount(CS_TEAM_CT) > 0) && (GetTeamClientCount(CS_TEAM_T) > 0 ))
				{
					char EventDay[64];
					GetEventDayName(EventDay);
					
					if(StrEqual(EventDay, "none", false))
					{
						if (g_iCoolDown == 0)
						{
							StartNextRound();
							if(ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event Hide was started by admin %L", client);
						}
						else CPrintToChat(client, "%t %t", "hide_tag" , "hide_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "hide_tag" , "hide_progress" , EventDay);
				}
				else CPrintToChat(client, "%t %t", "hide_tag" , "hide_minplayer");
			}
			else CPrintToChat(client, "%t %t", "hide_tag" , "hide_setbyadmin");
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "hide_tag" , "hide_disabled");
}


//Voting for Event
public Action VoteHide(int client,int args)
{
	char steamid[64];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bVote.BoolValue)
		{
			if ((GetTeamClientCount(CS_TEAM_CT) > 0) && (GetTeamClientCount(CS_TEAM_T) > 0 ))
			{
				char EventDay[64];
				GetEventDayName(EventDay);
				
				if(StrEqual(EventDay, "none", false))
				{
					if (g_iCoolDown == 0)
					{
						if (StrContains(g_sHasVoted, steamid, true) == -1)
						{
							int playercount = (GetClientCount(true) / 2);
							g_iVoteCount++;
							int Missing = playercount - g_iVoteCount + 1;
							Format(g_sHasVoted, sizeof(g_sHasVoted), "%s,%s", g_sHasVoted, steamid);
							
							if (g_iVoteCount > playercount)
							{
								StartNextRound();
								if(ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event Hide was started by voting");
							}
							else CPrintToChatAll("%t %t", "hide_tag" , "hide_need", Missing, client);
						}
						else CPrintToChat(client, "%t %t", "hide_tag" , "hide_voted");
					}
					else CPrintToChat(client, "%t %t", "hide_tag" , "hide_wait", g_iCoolDown);
				}
				else CPrintToChat(client, "%t %t", "hide_tag" , "hide_progress" , EventDay);
			}
			else CPrintToChat(client, "%t %t", "hide_tag" , "hide_minplayer");
		}
		else CPrintToChat(client, "%t %t", "hide_tag" , "hide_voting");
	}
	else CPrintToChat(client, "%t %t", "hide_tag" , "hide_disabled");
}


/******************************************************************************
                   EVENTS
******************************************************************************/


//Round start
public void Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	if (StartHide || IsHide)
	{
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvarString("sv_skyname", "cs_baggage_skybox_");
		SetCvar("sm_weapons_t", 0);
		SetCvar("sm_weapons_ct", 0);
		SetCvar("sm_menu_enable", 0);
		SetEventDayPlanned(false);
		SetEventDayRunning(true);
		IsHide = true;
		g_iRound++;
		StartHide = false;
		SJD_OpenDoors();
		FogOn();
		
		if (gc_fBeaconTime.FloatValue > 0.0) BeaconTimer = CreateTimer(gc_fBeaconTime.FloatValue, Timer_BeaconOn, TIMER_FLAG_NO_MAPCHANGE);
		
		if (g_iRound > 0)
		{
			LoopClients(client)
			{
				CreateInfoPanel(client);
				
				if (GetClientTeam(client) == CS_TEAM_CT)
				{
					StripAllPlayerWeapons(client);
					SetEntityMoveType(client, MOVETYPE_NONE);
					GivePlayerItem(client, "weapon_tagrenade");
					SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
					GivePlayerItem(client, "weapon_knife");
				}
				if (GetClientTeam(client) == CS_TEAM_T)
				{
					StripAllPlayerWeapons(client);
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					GivePlayerItem(client, "weapon_knife");
				}
			}
			g_iFreezeTime--;
			FreezeTimer = CreateTimer(1.0, Timer_StartEvent, _, TIMER_REPEAT);
		}
	}
	else
	{
		char EventDay[64];
		GetEventDayName(EventDay);
		
		if(!StrEqual(EventDay, "none", false))
		{
			g_iCoolDown = gc_iCooldownDay.IntValue + 1;
		}
		else if (g_iCoolDown > 0) g_iCoolDown--;
	}
}


//Round End
public void Event_RoundEnd(Event event, char[] name, bool dontBroadcast)
{
	int winner = event.GetInt("winner");
	
	if (IsHide)
	{
		LoopClients(client)
		{
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
			g_iTA[client] = 0;
		}
		
		delete BeaconTimer;
		delete FreezeTimer;
		
		if (winner == 2) PrintCenterTextAll("%t", "hide_twin_nc");
		if (winner == 3) PrintCenterTextAll("%t", "hide_ctwin_nc");
		if (g_iRound == g_iMaxRound)
		{
			IsHide = false;
			StartHide = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_weapons_t", 0);
			SetCvar("sm_weapons_ct", 1);
			SetCvarString("sv_skyname", g_sSkyName);
			SetCvar("sm_warden_enable", 1);
			SetCvar("sm_menu_enable", 1);
			g_iGetRoundTime.IntValue = g_iOldRoundTime;
			SetEventDayName("none");
			SetEventDayRunning(false);
			SetEventDayRunning(false);
			CPrintToChatAll("%t %t", "hide_tag" , "hide_end");
			
			FogOff();
		}
	}
	if (StartHide)
	{
		LoopClients(i) CreateInfoPanel(i);
		
		CPrintToChatAll("%t %t", "hide_tag" , "hide_next");
		PrintCenterTextAll("%t", "hide_next_nc");
	}
}


//Give new TA
public void Event_TA_Detonate(Event event, const char[] name, bool dontBroadcast)
{
	if (IsHide == true)
	{
		int target = GetClientOfUserId(event.GetInt("userid"));
		if (GetClientTeam(target) == 1 && !IsPlayerAlive(target))
		{
			return;
		}
		if (g_iTA[target] != g_iMaxTA)
		{
			GivePlayerItem(target, "weapon_tagrenade");
			int g_iTAgot = (g_iMaxTA - g_iTA[target]);
			g_iTA[target]++;
			
			CPrintToChat(target,"%t %t", "hide_tag" , "hide_stillta", g_iTAgot);
		}
		else CPrintToChat(target,"%t %t", "hide_tag" , "hide_nota");
	}
	return;
}


/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/


//Initialize Event
public void OnMapStart()
{
	g_iVoteCount = 0;
	g_iRound = 0;
	IsHide = false;
	StartHide = false;
	
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_sOldSkyName = FindConVar("sv_skyname");
	g_sOldSkyName.GetString(g_sSkyName, sizeof(g_sSkyName));
	
	if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayStartPath);
	if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStartPath);
	
	for(int client=1; client <= MaxClients; client++) g_iTA[client] = 0;
}


//Terror win Round if time runs out
public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason)
{
	if (IsHide)   //TODO: does this trigger??
	{
		if (reason == CSRoundEnd_Draw)
		{
			reason = CSRoundEnd_TerroristWin;
			return Plugin_Changed;
		}
		return Plugin_Continue;
	}
	return Plugin_Continue;
}


public void OnMapEnd()
{
	IsHide = false;
	StartHide = false;
	delete FreezeTimer;
	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
}


//Set Client Hook
public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}


//Knife only for Terrorists
public Action OnWeaponCanUse(int client, int weapon)
{
	if(IsHide == true)
	{
		char sWeapon[32];
		GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));
		if((GetClientTeam(client) == CS_TEAM_T && StrEqual(sWeapon, "weapon_knife")) || (GetClientTeam(client) == CS_TEAM_CT))
		{
		
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				return Plugin_Continue;
			}
		}
		return Plugin_Handled;
	}
	return Plugin_Continue;
}


/******************************************************************************
                   FUNCTIONS
******************************************************************************/


//Prepare Event
void StartNextRound()
{
	StartHide = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	
	char buffer[32];
	Format(buffer, sizeof(buffer), "%T", "hide_name", LANG_SERVER);
	SetEventDayName(buffer);
	SetEventDayPlanned(true);
	
	g_iOldRoundTime = g_iGetRoundTime.IntValue; //save original round time
	g_iGetRoundTime.IntValue = gc_iRoundTime.IntValue;//set event round time
	
	g_iVoteCount = 0;
	CPrintToChatAll("%t %t", "hide_tag" , "hide_next");
	PrintCenterTextAll("%t", "hide_next_nc");
}


/******************************************************************************
                   MENUS
******************************************************************************/


stock void CreateInfoPanel(int client)
{
	//Create info Panel
	char info[255];

	HideMenu = CreatePanel();
	Format(info, sizeof(info), "%T", "hide_info_title", client);
	SetPanelTitle(HideMenu, info);
	DrawPanelText(HideMenu, "                                   ");
	Format(info, sizeof(info), "%T", "hide_info_line1", client);
	DrawPanelText(HideMenu, info);
	DrawPanelText(HideMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "hide_info_line2", client);
	DrawPanelText(HideMenu, info);
	Format(info, sizeof(info), "%T", "hide_info_line3", client);
	DrawPanelText(HideMenu, info);
	Format(info, sizeof(info), "%T", "hide_info_line4", client);
	DrawPanelText(HideMenu, info);
	Format(info, sizeof(info), "%T", "hide_info_line5", client);
	DrawPanelText(HideMenu, info);
	Format(info, sizeof(info), "%T", "hide_info_line6", client);
	DrawPanelText(HideMenu, info);
	Format(info, sizeof(info), "%T", "hide_info_line7", client);
	DrawPanelText(HideMenu, info);
	DrawPanelText(HideMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "warden_close", client);
	DrawPanelItem(HideMenu, info); 
	SendPanelToClient(HideMenu, client, Handler_NullCancel, 20);
}


/******************************************************************************
                   TIMER
******************************************************************************/


//Start Timer
public Action Timer_StartEvent(Handle timer)
{
	if (g_iFreezeTime > 1)
	{
		g_iFreezeTime--;
		LoopClients(client)if (IsPlayerAlive(client))
		{
			if (GetClientTeam(client) == CS_TEAM_CT)
			{
				PrintCenterText(client,"%t", "hide_timetounfreeze_nc", g_iFreezeTime);
			}
			else if (GetClientTeam(client) == CS_TEAM_T)
			{
				PrintCenterText(client,"%t", "hide_timetohide_nc", g_iFreezeTime);
			}
		}
		return Plugin_Continue;
	}
	
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	
	if (g_iRound > 0)
	{
		LoopClients(client) if(IsPlayerAlive(client))
		{
			if (GetClientTeam(client) == CS_TEAM_CT)
			{
				SetEntityMoveType(client, MOVETYPE_WALK);
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.4);
			}
			if (GetClientTeam(client) == CS_TEAM_T)
			{
				if (gc_bFreezeHider)
				{
					SetEntityMoveType(client, MOVETYPE_NONE);
				}
				else
				{
					SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.9);
				}
			}
			if(gc_bOverlays.BoolValue) ShowOverlay(client, g_sOverlayStartPath, 2.0);
			if(gc_bSounds.BoolValue)
			{
				EmitSoundToAllAny(g_sSoundStartPath);
			}
			PrintCenterText(client,"%t", "hide_start_nc");
		}
		CPrintToChatAll("%t %t", "hide_tag" , "hide_start");
	}
	FreezeTimer = null;
	return Plugin_Stop;
}


//Beacon Timer
public Action Timer_BeaconOn(Handle timer)
{
	LoopValidClients(i,true,false) BeaconOn(i, 2.0);
	BeaconTimer = null;
}