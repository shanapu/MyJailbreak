/*
 * MyJailbreak - Hide in the Dark Event Day Plugin.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
 * 
 * Copyright (C) 2016-2017 Thomas Schmidt (shanapu)
 *
 * This file is part of the MyJailbreak SourceMod Plugin.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 */

/******************************************************************************
                   STARTUP
******************************************************************************/

// Includes
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <emitsoundany>
#include <colors>
#include <autoexecconfig>
#include <mystocks>

// Optional Plugins
#undef REQUIRE_PLUGIN
#include <hosties>
#include <lastrequest>
#include <warden>
#include <myjailbreak>
#include <smartjaildoors>
#include <myicons>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Booleans
bool g_bIsLateLoad = false;
bool g_bIsHide = false;
bool g_bStartHide = false;

// Plugin bools
bool gp_bWarden;
bool gp_bHosties;
bool gp_bSmartJailDoors;
bool gp_bMyJailbreak;
bool gp_bMyIcons;

// Console Variables
ConVar gc_bPlugin;
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_bSetABypassCooldown;
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
ConVar gc_sCustomCommandVote;
ConVar gc_sCustomCommandSet;
ConVar gc_sAdminFlag;
ConVar gc_bAllowLR;

// Extern Convars
ConVar g_iMPRoundTime;
ConVar g_sOldSkyName;
ConVar g_iTerrorForLR;

// Integers
int g_iOldRoundTime;
int g_iFreezeTime;
int g_iCoolDown;
int g_iVoteCount;
int g_iRound;
int g_iMaxRound;
int g_iMaxTA;
int g_iTA[MAXPLAYERS + 1];
int g_iTsLR;
int g_iCollision_Offset;

// Handles
Handle g_hTimerFreeze;
Handle g_hTimerBeacon;

// Strings
char g_sHasVoted[1500];
char g_sSoundStartPath[256];
char g_sEventsLogFile[PLATFORM_MAX_PATH];
char g_sSkyName[256];
char g_sAdminFlag[4];
char g_sOverlayStartPath[256];

// Floats
float g_fPos[3];

// Info
public Plugin myinfo = {
	name = "MyJailbreak - HideInTheDark",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_bIsLateLoad = late;

	return APLRes_Success;
}

// Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.Hide.phrases");

	// Client Commands
	RegConsoleCmd("sm_sethide", Command_SetHide, "Allows the Admin or Warden to set hide as next round");
	RegConsoleCmd("sm_hide", Command_VoteHide, "Allows players to vote for a hide");

	// AutoExecConfig
	AutoExecConfig_SetFile("Hide", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);

	AutoExecConfig_CreateConVar("sm_hide_version", MYJB_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_hide_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true, 0.0, true, 1.0);
	gc_sCustomCommandVote = AutoExecConfig_CreateConVar("sm_hide_cmds_vote", "hidenseek", "Set your custom chat command for Event voting(!hide (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandSet = AutoExecConfig_CreateConVar("sm_hide_cmds_set", "shide", "Set your custom chat command for set Event(!hide (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_hide_warden", "1", "0 - disabled, 1 - allow warden to set hide round", _, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_hide_admin", "1", "0 - disabled, 1 - allow admin/vip to set hide round", _, true, 0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_hide_flag", "g", "Set flag for admin/vip to set this Event Day.");
	gc_bVote = AutoExecConfig_CreateConVar("sm_hide_vote", "1", "0 - disabled, 1 - allow player to vote for hide round", _, true, 0.0, true, 1.0);
	gc_bFreezeHider = AutoExecConfig_CreateConVar("sm_hide_freezehider", "1", "0 - disabled, 1 - enable freeze hider when hidetime gone", _, true, 0.0, true, 1.0);
	gc_iTAgrenades = AutoExecConfig_CreateConVar("sm_hide_tagrenades", "3", "how many tagrenades a guard have?", _, true, 1.0);
	gc_iRounds = AutoExecConfig_CreateConVar("sm_hide_rounds", "1", "Rounds to play in a row", _, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_hide_roundtime", "5", "Round time in minutes for a single war round", _, true, 1.0);
	gc_fBeaconTime = AutoExecConfig_CreateConVar("sm_hide_beacon_time", "240", "Time in seconds until the beacon turned on (set to 0 to disable)", _, true, 0.0);
	gc_iFreezeTime = AutoExecConfig_CreateConVar("sm_hide_hidetime", "30", "Time in seconds to hide / CT freezed", _, true, 0.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_hide_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true, 0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_hide_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true, 0.0);
	gc_bSetABypassCooldown = AutoExecConfig_CreateConVar("sm_hide_cooldown_admin", "1", "0 - disabled, 1 - ignore the cooldown when admin/vip set hide round", _, true, 0.0, true, 1.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_hide_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true, 0.0, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_hide_sounds_start", "music/MyJailbreak/start.mp3", "Path to the soundfile which should be played for start");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_hide_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true, 0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_hide_overlays_start", "overlays/MyJailbreak/start", "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_bAllowLR = AutoExecConfig_CreateConVar("sm_hide_allow_lr", "0", "0 - disabled, 1 - enable LR for last round and end eventday", _, true, 0.0, true, 1.0);

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("tagrenade_detonate", Event_TA_Detonate);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sAdminFlag, OnSettingChanged);

	// FindConVar
	g_iMPRoundTime = FindConVar("mp_roundtime");
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	gc_sOverlayStartPath.GetString(g_sOverlayStartPath, sizeof(g_sOverlayStartPath));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
	gc_sAdminFlag.GetString(g_sAdminFlag, sizeof(g_sAdminFlag));

	// Offsets
	g_iCollision_Offset = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");

	// Logs
	SetLogFile(g_sEventsLogFile, "Events", "MyJailbreak");

	// Late loading
	if (g_bIsLateLoad)
	{
		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
		{
			OnClientPutInServer(i);
		}

		g_bIsLateLoad = false;
	}
}

// ConVarChange for Strings
public void OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sOverlayStartPath)
	{
		strcopy(g_sOverlayStartPath, sizeof(g_sOverlayStartPath), newValue);
		if (gc_bOverlays.BoolValue)
		{
			PrecacheDecalAnyDownload(g_sOverlayStartPath);
		}
	}
	else if (convar == gc_sSoundStartPath)
	{
		strcopy(g_sSoundStartPath, sizeof(g_sSoundStartPath), newValue);
		if (gc_bSounds.BoolValue)
		{
			PrecacheSoundAnyDownload(g_sSoundStartPath);
		}
	}
	else if (convar == gc_sAdminFlag)
	{
		strcopy(g_sAdminFlag, sizeof(g_sAdminFlag), newValue);
	}
}

public void OnAllPluginsLoaded()
{
	gp_bWarden = LibraryExists("warden");
	gp_bHosties = LibraryExists("lastrequest");
	gp_bSmartJailDoors = LibraryExists("smartjaildoors");
	gp_bMyJailbreak = LibraryExists("myjailbreak");
	gp_bMyIcons = LibraryExists("myicons");
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "warden"))
		gp_bWarden = false;

	if (StrEqual(name, "lastrequest"))
		gp_bHosties = false;

	if (StrEqual(name, "smartjaildoors"))
		gp_bSmartJailDoors = false;

	if (StrEqual(name, "myjailbreak"))
		gp_bMyJailbreak = false;

	if (StrEqual(name, "myicons"))
		gp_bMyIcons = false;
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "warden"))
		gp_bWarden = true;

	if (StrEqual(name, "lastrequest"))
		gp_bHosties = true;

	if (StrEqual(name, "smartjaildoors"))
		gp_bSmartJailDoors = true;

	if (StrEqual(name, "myjailbreak"))
		gp_bMyJailbreak = true;

	if (StrEqual(name, "myicons"))
		gp_bMyIcons = true;
}


// Initialize Plugin
public void OnConfigsExecuted()
{
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iMaxRound = gc_iRounds.IntValue;
	g_iMaxTA = gc_iTAgrenades.IntValue - 1;

	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// Vote
	gc_sCustomCommandVote.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));
	
	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  // if command not already exist
		{
			RegConsoleCmd(sCommand, Command_VoteHide, "Allows players to vote for a hide");
		}
	}

	// Set
	gc_sCustomCommandSet.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  // if command not already exist
		{
			RegConsoleCmd(sCommand, Command_SetHide, "Allows the Admin or Warden to set hide as next round");
		}
	}
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

// Admin & Warden set Event
public Action Command_SetHide(int client, int args)
{
	if (!gc_bPlugin.BoolValue)
	{
		CReplyToCommand(client, "%t %t", "hide_tag", "hide_disabled");
		return Plugin_Handled;
	}

	if (client == 0) // Called by a server/voting
	{
		StartNextRound();

		if (!gp_bMyJailbreak)
		{
			return Plugin_Handled;
		}

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Hide was started by groupvoting");
		}
	}
	else if (CheckVipFlag(client, g_sAdminFlag)) // Called by admin/VIP
	{
		if (!gc_bSetA.BoolValue)
		{
			CReplyToCommand(client, "%t %t", "hide_tag", "hide_setbyadmin");
			return Plugin_Handled;
		}

		if (GetTeamClientCount(CS_TEAM_CT) == 0 || GetTeamClientCount(CS_TEAM_T) == 0)
		{
			CReplyToCommand(client, "%t %t", "hide_tag", "hide_minplayer");
			return Plugin_Handled;
		}

		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				CReplyToCommand(client, "%t %t", "hide_tag", "hide_progress", EventDay);
				return Plugin_Handled;
			}
		}

		if (g_iCoolDown > 0 && !gc_bSetABypassCooldown.BoolValue)
		{
			CReplyToCommand(client, "%t %t", "hide_tag", "hide_wait", g_iCoolDown);
			return Plugin_Handled;
		}

		StartNextRound();

		if (!gp_bMyJailbreak)
		{
			return Plugin_Handled;
		}

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Hide was started by admin %L", client);
		}
	}
	else if (gp_bWarden) // Called by warden
	{
		if (!warden_iswarden(client))
		{
			CReplyToCommand(client, "%t %t", "warden_tag", "warden_notwarden");
			return Plugin_Handled;
		}
		
		if (!gc_bSetW.BoolValue)
		{
			CReplyToCommand(client, "%t %t", "warden_tag", "hide_setbywarden");
			return Plugin_Handled;
		}

		if (GetTeamClientCount(CS_TEAM_CT) == 0 || GetTeamClientCount(CS_TEAM_T) == 0)
		{
			CReplyToCommand(client, "%t %t", "hide_tag", "hide_minplayer");
			return Plugin_Handled;
		}

		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				CReplyToCommand(client, "%t %t", "hide_tag", "hide_progress", EventDay);
				return Plugin_Handled;
			}
		}

		if (g_iCoolDown > 0)
		{
			CReplyToCommand(client, "%t %t", "hide_tag", "hide_wait", g_iCoolDown);
			return Plugin_Handled;
		}

		StartNextRound();

		if (!gp_bMyJailbreak)
		{
			return Plugin_Handled;
		}

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Hide was started by warden %L", client);
		}
	}
	else
	{
		CReplyToCommand(client, "%t %t", "warden_tag", "warden_notwarden");
	}

	return Plugin_Handled;
}

// Voting for Event
public Action Command_VoteHide(int client, int args)
{
	if (!gc_bPlugin.BoolValue)
	{
		CReplyToCommand(client, "%t %t", "hide_tag", "hide_disabled");
		return Plugin_Handled;
	}

	if (!gc_bVote.BoolValue)
	{
		CReplyToCommand(client, "%t %t", "hide_tag", "hide_voting");
		return Plugin_Handled;
	}

	if (GetTeamClientCount(CS_TEAM_CT) == 0 || GetTeamClientCount(CS_TEAM_T) == 0)
	{
		CReplyToCommand(client, "%t %t", "hide_tag", "hide_minplayer");
		return Plugin_Handled;
	}

	if (gp_bMyJailbreak)
	{
		char EventDay[64];
		MyJailbreak_GetEventDayName(EventDay);

		if (!StrEqual(EventDay, "none", false))
		{
			CReplyToCommand(client, "%t %t", "hide_tag", "hide_progress", EventDay);
			return Plugin_Handled;
		}
	}

	if (g_iCoolDown > 0)
	{
		CReplyToCommand(client, "%t %t", "hide_tag", "hide_wait", g_iCoolDown);
		return Plugin_Handled;
	}

	char steamid[24];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));

	if (StrContains(g_sHasVoted, steamid, true) != -1)
	{
		CReplyToCommand(client, "%t %t", "hide_tag", "hide_voted");
		return Plugin_Handled;
	}

	int playercount = (GetClientCount(true) / 2);
	g_iVoteCount += 1;

	int Missing = playercount - g_iVoteCount + 1;
	Format(g_sHasVoted, sizeof(g_sHasVoted), "%s, %s", g_sHasVoted, steamid);

	if (g_iVoteCount > playercount)
	{
		StartNextRound();

		if (!gp_bMyJailbreak)
		{
			return Plugin_Handled;
		}

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Hide was started by voting");
		}
	}
	else
	{
		CPrintToChatAll("%t %t", "hide_tag", "hide_need", Missing, client);
	}

	return Plugin_Handled;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

public Action Hook_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)  // todo clean up a bit
{
	if (attacker > 0 && attacker <= MaxClients && victim > 0 && victim <= MaxClients)
	{
		if (g_bIsHide && GetClientTeam(victim) == CS_TEAM_CT)
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

// Round start
public void Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	if (!g_bStartHide && !g_bIsHide)
	{
		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				g_iCoolDown = gc_iCooldownDay.IntValue + 1;
			}
			else if (g_iCoolDown > 0)
			{
				g_iCoolDown -= 1;
			}
		}
		else if (g_iCoolDown > 0)
		{
			g_iCoolDown -= 1;
		}

		return;
	}

	if (gp_bWarden)
	{
		SetCvar("sm_warden_enable", 0);
	}

	if (gp_bHosties)
	{
		SetCvar("sm_hosties_lr", 0);
	}

	SetCvarString("sv_skyname", "cs_baggage_skybox_");
	SetCvar("sm_weapons_t", 0);
	SetCvar("sm_weapons_ct", 0);
	SetCvar("sm_menu_enable", 0);

	if (gp_bMyJailbreak)
	{
		MyJailbreak_SetEventDayPlanned(false);
		MyJailbreak_SetEventDayRunning(true, 0);

		MyJailbreak_FogOn();

		if (gc_fBeaconTime.FloatValue > 0.0)
		{
			g_hTimerBeacon = CreateTimer(gc_fBeaconTime.FloatValue, Timer_BeaconOn, TIMER_FLAG_NO_MAPCHANGE);
		}
	}

	g_bIsHide = true;
	g_iRound++;
	g_bStartHide = false;

	if (gp_bSmartJailDoors)
	{
		SJD_OpenDoors();
	}

	if (!gp_bSmartJailDoors || (gp_bSmartJailDoors && (SJD_IsCurrentMapConfigured() != true))) // spawn Terrors to CT Spawn 
	{
		int RandomCT = 0;
		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
		{
			if (GetClientTeam(i) == CS_TEAM_CT)
			{
				RandomCT = i;
				break;
			}
		}

		if (RandomCT)
		{
			for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
			{
				GetClientAbsOrigin(RandomCT, g_fPos);
				
				g_fPos[2] = g_fPos[2] + 5;
				
				TeleportEntity(i, g_fPos, NULL_VECTOR, NULL_VECTOR);
			}
		}
	}

	if (g_iRound > 0)
	{
		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
		{
			CreateInfoPanel(i);

			if (GetClientTeam(i) == CS_TEAM_CT)
			{
				if (gp_bSmartJailDoors)
				{
					SetEntityMoveType(i, MOVETYPE_NONE);
					SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 0.0);
				}

		//		SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);

				StripAllPlayerWeapons(i);
				GivePlayerItem(i, "weapon_tagrenade");
				GivePlayerItem(i, "weapon_knife");
			}

			if (GetClientTeam(i) == CS_TEAM_T)
			{
				StripAllPlayerWeapons(i);
				GivePlayerItem(i, "weapon_knife");

				if (gp_bMyIcons)
				{
					MyIcons_BlockClientIcon(i, true);
				}

			}

			SetEntData(i, g_iCollision_Offset, 2, 4, true);
		}

		if (gp_bHosties)
		{
			// enable lr on last round
			g_iTsLR = GetAlivePlayersCount(CS_TEAM_T);

			if (gc_bAllowLR.BoolValue)
			{
				if (g_iRound == g_iMaxRound && g_iTsLR > g_iTerrorForLR.IntValue)
				{
					SetCvar("sm_hosties_lr", 1);
				}
			}
		}

		g_iFreezeTime--;
		g_hTimerFreeze = CreateTimer(1.0, Timer_StartEvent, _, TIMER_REPEAT);
	}
}

// Round End
public void Event_RoundEnd(Event event, char[] name, bool dontBroadcast)
{
	if (g_bIsHide)
	{
		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
		{
			SetEntData(i, g_iCollision_Offset, 0, 4, true);
			SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
			g_iTA[i] = 0;

			if (gp_bMyIcons)
			{
				MyIcons_BlockClientIcon(i, false);
			}
		}

		delete g_hTimerBeacon;
		delete g_hTimerFreeze;

		int winner = event.GetInt("winner");
		if (winner == 2)
		{
			PrintCenterTextAll("%t", "hide_twin_nc");
		}
		if (winner == 3)
		{
			PrintCenterTextAll("%t", "hide_ctwin_nc");
		}

		if (g_iRound == g_iMaxRound)
		{
			g_bIsHide = false;
			g_bStartHide = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");

			if (gp_bHosties)
			{
				SetCvar("sm_hosties_lr", 1);
			}

			if (gp_bWarden)
			{
				SetCvar("sm_warden_enable", 1);
			}

			SetCvar("sm_weapons_t", 0);
			SetCvar("sm_weapons_ct", 1);
			SetCvarString("sv_skyname", g_sSkyName);
			SetCvar("sm_menu_enable", 1);

			g_iMPRoundTime.IntValue = g_iOldRoundTime;

			if (gp_bMyJailbreak)
			{
				MyJailbreak_SetEventDayRunning(false, winner);
				MyJailbreak_SetEventDayName("none");
				MyJailbreak_FogOff();
			}

			CPrintToChatAll("%t %t", "hide_tag", "hide_end");
		}
	}

	if (g_bStartHide)
	{
		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
		{
			CreateInfoPanel(i);
		}

		CPrintToChatAll("%t %t", "hide_tag", "hide_next");
		PrintCenterTextAll("%t", "hide_next_nc");
	}
}

// Give new TA
public void Event_TA_Detonate(Event event, const char[] name, bool dontBroadcast)
{
	if (g_bIsHide)
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

			CPrintToChat(target, "%t %t", "hide_tag", "hide_stillta", g_iTAgot);
		}
		else CPrintToChat(target, "%t %t", "hide_tag", "hide_nota");
	}
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

// Initialize Event
public void OnMapStart()
{
	g_iVoteCount = 0;
	g_iRound = 0;
	g_bIsHide = false;
	g_bStartHide = false;

	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_sOldSkyName = FindConVar("sv_skyname");
	g_sOldSkyName.GetString(g_sSkyName, sizeof(g_sSkyName));

	// Precache Sound & Overlay
	if (gc_bSounds.BoolValue)
	{
		PrecacheSoundAnyDownload(g_sSoundStartPath);
	}

	if (gc_bOverlays.BoolValue)
	{
		PrecacheDecalAnyDownload(g_sOverlayStartPath);
	}

	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) g_iTA[i] = 0;
}

// Terror win Round if time runs out
public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason)
{
	if (g_bIsHide)   // TODO: does this trigger??
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
	g_bIsHide = false;
	g_bStartHide = false;

	delete g_hTimerFreeze;

	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
}

// Set Client Hook
public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	SDKHook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
}

// Knife only for Terrorists
public Action OnWeaponCanUse(int client, int weapon)
{
	if (!g_bIsHide)
	{
		return Plugin_Continue;
	}

	char sWeapon[32];
	GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));

	if ((GetClientTeam(client) == CS_TEAM_T && StrEqual(sWeapon, "weapon_knife")) || (GetClientTeam(client) == CS_TEAM_CT))
	{
		if (IsClientInGame(client) && IsPlayerAlive(client))
		{
			return Plugin_Continue;
		}
	}

	return Plugin_Handled;
}

// Listen for Last Lequest
public void OnAvailableLR(int Announced)
{
	if (g_bIsHide && gc_bAllowLR.BoolValue && (g_iTsLR > g_iTerrorForLR.IntValue))
	{
		for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, false, true))
		{
			SetEntData(i, g_iCollision_Offset, 0, 4, true);
			SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
			g_iTA[i] = 0;

			if (gp_bMyIcons)
			{
				MyIcons_BlockClientIcon(i, false);
			}
		}

		delete g_hTimerFreeze;
		delete g_hTimerBeacon;

		if (g_iRound == g_iMaxRound)
		{
			g_bIsHide = false;
			g_bStartHide = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");

			if (gp_bWarden)
			{
				SetCvar("sm_warden_enable", 1);
			}

			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_weapons_t", 0);
			SetCvar("sm_weapons_ct", 1);
			SetCvarString("sv_skyname", g_sSkyName);
			SetCvar("sm_menu_enable", 1);

			g_iMPRoundTime.IntValue = g_iOldRoundTime;

			if (gp_bMyJailbreak)
			{
				MyJailbreak_SetEventDayName("none");
				MyJailbreak_SetEventDayRunning(false, 0);

				MyJailbreak_FogOff();
			}

			CPrintToChatAll("%t %t", "hide_tag", "hide_end");
		}
	}
}

/******************************************************************************
                   FUNCTIONS
******************************************************************************/

// Prepare Event
void StartNextRound()
{
	g_bStartHide = true;
	g_iVoteCount = 0;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;

	if (gp_bMyJailbreak)
	{
		char buffer[32];
		Format(buffer, sizeof(buffer), "%T", "hide_name", LANG_SERVER);
		MyJailbreak_SetEventDayName(buffer);
		MyJailbreak_SetEventDayPlanned(true);
	}

	g_iOldRoundTime = g_iMPRoundTime.IntValue; // save original round time
	g_iMPRoundTime.IntValue = gc_iRoundTime.IntValue; // set event round time

	CPrintToChatAll("%t %t", "hide_tag", "hide_next");
	PrintCenterTextAll("%t", "hide_next_nc");
}

/******************************************************************************
                   MENUS
******************************************************************************/

void CreateInfoPanel(int client)
{
	// Create info Panel
	char info[255];

	Panel InfoPanel = new Panel();

	Format(info, sizeof(info), "%T", "hide_info_title", client);
	InfoPanel.SetTitle(info);

	InfoPanel.DrawText("                                   ");
	Format(info, sizeof(info), "%T", "hide_info_line1", client);
	InfoPanel.DrawText(info);
	InfoPanel.DrawText("-----------------------------------");
	Format(info, sizeof(info), "%T", "hide_info_line2", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "hide_info_line3", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "hide_info_line4", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "hide_info_line5", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "hide_info_line6", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "hide_info_line7", client);
	InfoPanel.DrawText(info);
	InfoPanel.DrawText("-----------------------------------");

	Format(info, sizeof(info), "%T", "warden_close", client);
	InfoPanel.DrawItem(info);

	InfoPanel.Send(client, Handler_NullCancel, 20);
}

/******************************************************************************
                   TIMER
******************************************************************************/

// Start Timer
public Action Timer_StartEvent(Handle timer)
{
	if (g_iFreezeTime > 1)
	{
		g_iFreezeTime--;
		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))if (IsPlayerAlive(i))
		{
			if (GetClientTeam(i) == CS_TEAM_CT)
			{
				PrintCenterText(i, "%t", "hide_timetounfreeze_nc", g_iFreezeTime);
			}
			else if (GetClientTeam(i) == CS_TEAM_T)
			{
				PrintCenterText(i, "%t", "hide_timetohide_nc", g_iFreezeTime);
			}
		}

		return Plugin_Continue;
	}

	g_iFreezeTime = gc_iFreezeTime.IntValue;

	if (g_iRound > 0)
	{
		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) if (IsPlayerAlive(i))
		{
			if (GetClientTeam(i) == CS_TEAM_CT)
			{
				SetEntityMoveType(i, MOVETYPE_WALK);
				SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.4);
			}
			if (GetClientTeam(i) == CS_TEAM_T)
			{
				if (gc_bFreezeHider)
				{
					SetEntityMoveType(i, MOVETYPE_NONE);
					SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 0.0);
				}
				else
				{
					SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 0.9);
				}
			}

			if (gc_bOverlays.BoolValue)
			{
				ShowOverlay(i, g_sOverlayStartPath, 2.0);
			}
		}

		if (gc_bSounds.BoolValue)
		{
			EmitSoundToAllAny(g_sSoundStartPath);
		}

		PrintCenterTextAll("%t", "hide_start_nc");
		CPrintToChatAll("%t %t", "hide_tag", "hide_start");
	}

	g_hTimerFreeze = null;

	return Plugin_Stop;
}

// Beacon Timer
public Action Timer_BeaconOn(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, false))
	{
		MyJailbreak_BeaconOn(i, 2.0);
	}

	g_hTimerBeacon = null;
}