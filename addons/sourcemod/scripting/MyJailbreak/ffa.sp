/*
 * MyJailbreak - Free For All Event Day Plugin.
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
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <emitsoundany>
#include <colors>
#include <autoexecconfig>
#include <hosties>
#include <lastrequest>
#include <warden>
#include <smartjaildoors>
#include <mystocks>
#include <myjailbreak>


//Compiler Options
#pragma semicolon 1
#pragma newdecls required


//Booleans
bool IsFFA = false;
bool StartFFA = false;


//Console Variables
ConVar gc_bPlugin;
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_bSetABypassCooldown;
ConVar gc_bVote;
ConVar gc_iCooldownStart;
ConVar gc_bSpawnCell;
ConVar gc_iRoundTime;
ConVar gc_bOverlays;
ConVar gc_fBeaconTime;
ConVar gc_sOverlayStartPath;
ConVar gc_bSounds;
ConVar gc_sSoundStartPath;
ConVar gc_iCooldownDay;
ConVar gc_iTruceTime;
ConVar gc_iRounds;
ConVar g_iMPRoundTime;
ConVar gc_sCustomCommandVote;
ConVar gc_sCustomCommandSet;
ConVar gc_sAdminFlag;
ConVar gc_bAllowLR;
ConVar g_iTerrorForLR;


//Integers
int g_iOldRoundTime;
int g_iCoolDown;
int g_iTruceTime;
int g_iVoteCount;
int g_iRound;
int g_iMaxRound;
int g_iTsLR;


//Floats
float g_fPos[3];


//Handles
Handle TruceTimer;
Handle FFAMenu;
Handle BeaconTimer;


//Strings
char g_sHasVoted[1500];
char g_sSoundStartPath[256];
char g_sEventsLogFile[PLATFORM_MAX_PATH];
char g_sAdminFlag[32];
char g_sOverlayStartPath[256];


//Info
public Plugin myinfo = 
{
	name = "MyJailbreak - War FFA", 
	author = "shanapu", 
	description = "Event Day for Jailbreak Server", 
	version = MYJB_VERSION, 
	url = MYJB_URL_LINK
};


//Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.Ffa.phrases");
	
	
	//Client Commands
	RegConsoleCmd("sm_setffa", Command_Setffa, "Allows the Admin or Warden to set FFA");
	RegConsoleCmd("sm_ffa", Command_VoteFFA, "Allows players to vote for a FFA");
	
	
	//AutoExecConfig
	AutoExecConfig_SetFile("FreeForAll", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_ffa_version", MYJB_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_ffa_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_sCustomCommandVote = AutoExecConfig_CreateConVar("sm_ffa_cmds_vote", "freeforall, dm, deathmatch", "Set your custom chat command for Event voting(!ffa (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandSet = AutoExecConfig_CreateConVar("sm_ffa_cmds_set", "sffa, sfreeforall, sdm", "Set your custom chat command for set Event(!ffa (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_ffa_warden", "1", "0 - disabled, 1 - allow warden to set ffa round", _, true,  0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_ffa_admin", "1", "0 - disabled, 1 - allow admin/vip to set ffa round", _, true,  0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_ffa_flag", "g", "Set flag for admin/vip to set this Event Day.");
	gc_bVote = AutoExecConfig_CreateConVar("sm_ffa_vote", "1", "0 - disabled, 1 - allow player to vote for ffa", _, true,  0.0, true, 1.0);
	gc_bSpawnCell = AutoExecConfig_CreateConVar("sm_ffa_spawn", "0", "0 - T teleport to CT spawn, 1 - cell doors auto open", _, true,  0.0, true, 1.0);
	gc_iRounds = AutoExecConfig_CreateConVar("sm_ffa_rounds", "1", "Rounds to play in a row", _, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_ffa_roundtime", "5", "Round time in minutes for a single ffa round", _, true, 1.0);
	gc_fBeaconTime = AutoExecConfig_CreateConVar("sm_ffa_beacon_time", "240", "Time in seconds until the beacon turned on (set to 0 to disable)", _, true, 0.0);
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_ffa_trucetime", "30", "Time in seconds players can't deal damage", _, true,  0.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_ffa_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true,  0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_ffa_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true,  0.0);
	gc_bSetABypassCooldown = AutoExecConfig_CreateConVar("sm_ffa_cooldown_admin", "1", "0 - disabled, 1 - ignore the cooldown when admin/vip set ffa round", _, true, 0.0, true, 1.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_ffa_sounds_enable", "1", "0 - disabled, 1 - enable sounds", _, true,  0.0, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_ffa_sounds_start", "music/MyJailbreak/start.mp3", "Path to the soundfile which should be played for a start.");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_ffa_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true,  0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_ffa_overlays_start", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_bAllowLR = AutoExecConfig_CreateConVar("sm_ffa_allow_lr", "0" , "0 - disabled, 1 - enable LR for last round and end eventday", _, true, 0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	
	//Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sAdminFlag, OnSettingChanged);
	
	
	//FindConVar
	g_iMPRoundTime = FindConVar("mp_roundtime");
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
	gc_sOverlayStartPath.GetString(g_sOverlayStartPath , sizeof(g_sOverlayStartPath));
	gc_sAdminFlag.GetString(g_sAdminFlag , sizeof(g_sAdminFlag));
	
	SetLogFile(g_sEventsLogFile, "Events", "MyJailbreak");
}


//ConVarChange for Strings
public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sOverlayStartPath)
	{
		strcopy(g_sOverlayStartPath, sizeof(g_sOverlayStartPath), newValue);
		if (gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayStartPath);
	}
	else if (convar == gc_sAdminFlag)
	{
		strcopy(g_sAdminFlag, sizeof(g_sAdminFlag), newValue);
	}
	else if (convar == gc_sSoundStartPath)
	{
		strcopy(g_sSoundStartPath, sizeof(g_sSoundStartPath), newValue);
		if (gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStartPath);
	}
}


//Initialize Plugin
public void OnConfigsExecuted()
{
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iMaxRound = gc_iRounds.IntValue;
	
	
	//FindConVar
	g_iTerrorForLR = FindConVar("sm_hosties_lr_ts_max");
	
	
	//Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];
	
	//Vote
	gc_sCustomCommandVote.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));
	
	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  //if command not already exist
			RegConsoleCmd(sCommand, Command_VoteFFA, "Allows players to vote for a FFA");
	}
	
	//Set
	gc_sCustomCommandSet.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));
	
	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  //if command not already exist
			RegConsoleCmd(sCommand, Command_Setffa, "Allows the Admin or Warden to set a ffa");
	}
}


/******************************************************************************
                   COMMANDS
******************************************************************************/


//Admin & Warden set Event
public Action Command_Setffa(int client, int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (client == 0)
		{
			StartNextRound();
			if (MyJailbreak_ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event FFA was started by groupvoting");
		}
		else if (warden_iswarden(client))
		{
			if (gc_bSetW.BoolValue)
			{
				if ((GetTeamClientCount(CS_TEAM_CT) > 0) && (GetTeamClientCount(CS_TEAM_T) > 0 ))
				{
					char EventDay[64];
					MyJailbreak_GetEventDayName(EventDay);
					
					if (StrEqual(EventDay, "none", false))
					{
						if (g_iCoolDown == 0)
						{
							StartNextRound();
							if (MyJailbreak_ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event FFA was started by warden %L", client);
						}
						else CReplyToCommand(client, "%t %t", "ffa_tag" , "ffa_wait", g_iCoolDown);
					}
					else CReplyToCommand(client, "%t %t", "ffa_tag" , "ffa_progress" , EventDay);
				}
				else CReplyToCommand(client, "%t %t", "ffa_tag" , "ffa_minplayer");
			}
			else CReplyToCommand(client, "%t %t", "warden_tag" , "war_setbywarden");
		}
		else if (CheckVipFlag(client, g_sAdminFlag))
			{
				if (gc_bSetA.BoolValue)
				{
					if ((GetTeamClientCount(CS_TEAM_CT) > 0) && (GetTeamClientCount(CS_TEAM_T) > 0 ))
					{
						char EventDay[64];
						MyJailbreak_GetEventDayName(EventDay);
						
						if (StrEqual(EventDay, "none", false))
						{
							if ((g_iCoolDown == 0) || gc_bSetABypassCooldown.BoolValue)
							{
								StartNextRound();
								if (MyJailbreak_ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event FFA was started by admin %L", client);
							}
							else CReplyToCommand(client, "%t %t", "ffa_tag" , "ffa_wait", g_iCoolDown);
						}
						else CReplyToCommand(client, "%t %t", "ffa_tag" , "ffa_progress" , EventDay);
					}
					else CReplyToCommand(client, "%t %t", "ffa_tag" , "ffa_minplayer");
				}
				else CReplyToCommand(client, "%t %t", "ffa_tag" , "war_setbyadmin");
			}
			else CReplyToCommand(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CReplyToCommand(client, "%t %t", "ffa_tag" , "ffa_disabled");
	return Plugin_Handled;
}


//Voting for Event
public Action Command_VoteFFA(int client, int args)
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
				MyJailbreak_GetEventDayName(EventDay);
				
				if (StrEqual(EventDay, "none", false))
				{
					if (g_iCoolDown == 0)
					{
						if (StrContains(g_sHasVoted, steamid, true) == -1)
						{
							int playercount = (GetClientCount(true) / 2);
							g_iVoteCount++;
							int Missing = playercount - g_iVoteCount + 1;
							Format(g_sHasVoted, sizeof(g_sHasVoted), "%s, %s", g_sHasVoted, steamid);
							
							if (g_iVoteCount > playercount)
							{
								StartNextRound();
								if (MyJailbreak_ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event FFA was started by voting");
							}
							else CPrintToChatAll("%t %t", "ffa_tag" , "ffa_need", Missing, client);
						}
						else CReplyToCommand(client, "%t %t", "ffa_tag" , "ffa_voted");
					}
					else CReplyToCommand(client, "%t %t", "ffa_tag" , "ffa_wait", g_iCoolDown);
				}
				else CReplyToCommand(client, "%t %t", "ffa_tag" , "ffa_progress" , EventDay);
			}
			else CReplyToCommand(client, "%t %t", "ffa_tag" , "ffa_minplayer");
		}
		else CReplyToCommand(client, "%t %t", "ffa_tag" , "ffa_voting");
	}
	else CReplyToCommand(client, "%t %t", "ffa_tag" , "ffa_disabled");
	return Plugin_Handled;
}


/******************************************************************************
                   EVENTS
******************************************************************************/


//Round start
public void Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	if (StartFFA || IsFFA)
	{
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_weapons_t", 1);
		SetCvar("sm_weapons_ct", 1);
		SetCvar("mp_teammates_are_enemies", 1);
		SetCvar("mp_friendlyfire", 1);
		SetCvar("sm_menu_enable", 0);
		MyJailbreak_SetEventDayPlanned(false);
		MyJailbreak_SetEventDayRunning(true);
		MyJailbreak_FogOn();
		g_iRound++;
		IsFFA = true;
		StartFFA = false;
		SJD_OpenDoors();
		
		if (gc_fBeaconTime.FloatValue > 0.0) BeaconTimer = CreateTimer(gc_fBeaconTime.FloatValue, Timer_BeaconOn, TIMER_FLAG_NO_MAPCHANGE);
		
		int RandomCT = 0;
		
		LoopClients(client)
		{
			if (GetClientTeam(client) == CS_TEAM_CT)
			{
				RandomCT = client;
				break;
			}
		}
		if (RandomCT)
		{
			GetClientAbsOrigin(RandomCT, g_fPos);
			
			g_fPos[2] = g_fPos[2] + 5;
			
			if (g_iRound > 0)
			{
				LoopClients(client)
				{
					if (!gc_bSpawnCell.BoolValue || (gc_bSpawnCell.BoolValue && (SJD_IsCurrentMapConfigured() != true))) //spawn Terrors to CT Spawn 
					{
						if (IsClientInGame(client))
						{
							TeleportEntity(client, g_fPos, NULL_VECTOR, NULL_VECTOR);
						}
					}
				}
				
				//enable lr on last round
				g_iTsLR = GetAliveTeamCount(CS_TEAM_T);
				
				if (gc_bAllowLR.BoolValue)
				{
					if ((g_iRound == g_iMaxRound) && (g_iTsLR > g_iTerrorForLR.IntValue))
					{
						SetCvar("sm_hosties_lr", 1);
					}
				}
				
				CPrintToChatAll("%t %t", "ffa_tag" , "ffa_rounds", g_iRound, g_iMaxRound);
			}
			LoopClients(client)
			{
				CreateInfoPanel(client);
				SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
				SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
			}
			TruceTimer = CreateTimer(1.0, Timer_StartEvent, _, TIMER_REPEAT);
		}
	}
	else
	{
		char EventDay[64];
		MyJailbreak_GetEventDayName(EventDay);
	
		if (!StrEqual(EventDay, "none", false))
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
	
	if (IsFFA)
	{
		LoopValidClients(client, false, true) SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
		delete TruceTimer;
		delete BeaconTimer;
		if (winner == 2) PrintCenterTextAll("%t", "ffa_twin_nc"); 
		if (winner == 3) PrintCenterTextAll("%t", "ffa_ctwin_nc");
		if (g_iRound == g_iMaxRound)
		{
			IsFFA = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_warden_enable", 1);
			SetCvar("sm_weapons_t", 0);
			SetCvar("sm_weapons_ct", 1);
			SetCvar("mp_teammates_are_enemies", 0);
			SetCvar("mp_friendlyfire", 0);
			SetCvar("sm_menu_enable", 1);
			g_iMPRoundTime.IntValue = g_iOldRoundTime;
			MyJailbreak_SetEventDayName("none");
			MyJailbreak_SetEventDayRunning(false);
			CPrintToChatAll("%t %t", "ffa_tag" , "ffa_end");
		}
	}
	if (StartFFA)
	{
		LoopClients(i) CreateInfoPanel(i);
		
		CPrintToChatAll("%t %t", "ffa_tag" , "ffa_next");
		PrintCenterTextAll("%t", "ffa_next_nc");
	}
}


/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/


//Initialize Event
public void OnMapStart()
{
	g_iVoteCount = 0;
	g_iRound = 0;
	IsFFA = false;
	StartFFA = false;
	
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	if (gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayStartPath);
	if (gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStartPath);
	
}


//Map End
public void OnMapEnd()
{
	IsFFA = false;
	StartFFA = false;
	delete TruceTimer;
	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
}


//Listen for Last Lequest
public void OnAvailableLR(int Announced)
{
	if (IsFFA && gc_bAllowLR.BoolValue && (g_iTsLR > g_iTerrorForLR.IntValue))
	{
		LoopValidClients(client, false, true)
		{
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
			
			StripAllPlayerWeapons(client);
			if (GetClientTeam(client) == CS_TEAM_CT)
			{
				FakeClientCommand(client, "sm_weapons");
			}
			GivePlayerItem(client, "weapon_knife");
		}
		
		delete BeaconTimer;
		delete TruceTimer;
		
		if (g_iRound == g_iMaxRound)
		{
			IsFFA = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_warden_enable", 1);
			SetCvar("sm_weapons_t", 0);
			SetCvar("sm_weapons_ct", 1);
			SetCvar("mp_teammates_are_enemies", 0);
			SetCvar("mp_friendlyfire", 0);
			SetCvar("sm_menu_enable", 1);
			g_iMPRoundTime.IntValue = g_iOldRoundTime;
			MyJailbreak_SetEventDayName("none");
			MyJailbreak_SetEventDayRunning(false);
			CPrintToChatAll("%t %t", "ffa_tag" , "ffa_end");
		}
	}
}


/******************************************************************************
                   FUNCTIONS
******************************************************************************/


//Prepare Event for next round
void StartNextRound()
{
	StartFFA = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;
	
	char buffer[32];
	Format(buffer, sizeof(buffer), "%T", "ffa_name", LANG_SERVER);
	MyJailbreak_SetEventDayName(buffer);
	MyJailbreak_SetEventDayPlanned(true);
	
	g_iOldRoundTime = g_iMPRoundTime.IntValue; //save original round time
	g_iMPRoundTime.IntValue = gc_iRoundTime.IntValue;//set event round time
	
	CPrintToChatAll("%t %t", "ffa_tag" , "ffa_next");
	PrintCenterTextAll("%t", "ffa_next_nc");
}


/******************************************************************************
                   MENUS
******************************************************************************/


stock void CreateInfoPanel(int client)
{
	//Create info Panel
	char info[255];

	FFAMenu = CreatePanel();
	Format(info, sizeof(info), "%T", "ffa_info_title", client);
	SetPanelTitle(FFAMenu, info);
	DrawPanelText(FFAMenu, "                                   ");
	Format(info, sizeof(info), "%T", "ffa_info_line1", client);
	DrawPanelText(FFAMenu, info);
	DrawPanelText(FFAMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "ffa_info_line2", client);
	DrawPanelText(FFAMenu, info);
	Format(info, sizeof(info), "%T", "ffa_info_line3", client);
	DrawPanelText(FFAMenu, info);
	Format(info, sizeof(info), "%T", "ffa_info_line4", client);
	DrawPanelText(FFAMenu, info);
	Format(info, sizeof(info), "%T", "ffa_info_line5", client);
	DrawPanelText(FFAMenu, info);
	Format(info, sizeof(info), "%T", "ffa_info_line6", client);
	DrawPanelText(FFAMenu, info);
	Format(info, sizeof(info), "%T", "ffa_info_line7", client);
	DrawPanelText(FFAMenu, info);
	DrawPanelText(FFAMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "warden_close", client);
	DrawPanelItem(FFAMenu, info); 
	SendPanelToClient(FFAMenu, client, Handler_NullCancel, 20);
}


/******************************************************************************
                   TIMER
******************************************************************************/


//Start Timer
public Action Timer_StartEvent(Handle timer)
{
	if (g_iTruceTime > 1)
	{
		g_iTruceTime--;
		
		PrintCenterTextAll("%t", "ffa_damage_nc", g_iTruceTime);
		
		return Plugin_Continue;
	}
	
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	for (int client=1; client <= MaxClients; client++) 
	{
		if (IsClientInGame(client) && IsPlayerAlive(client)) 
		{
			SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
			if (gc_bOverlays.BoolValue) ShowOverlay(client, g_sOverlayStartPath, 2.0);
			if (gc_bSounds.BoolValue)	
			{
				EmitSoundToAllAny(g_sSoundStartPath);
			}
			
			PrintCenterText(client, "%t", "ffa_start_nc");
		}
	}
	CPrintToChatAll("%t %t", "ffa_tag" , "ffa_start");
	TruceTimer = null;
	MyJailbreak_FogOff();
	
	return Plugin_Stop;
}


//Beacon Timer
public Action Timer_BeaconOn(Handle timer)
{
	LoopValidClients(i, true, false) MyJailbreak_BeaconOn(i, 2.0);
	BeaconTimer = null;
}