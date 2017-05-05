/*
 * MyJailbreak - Freeday Event Day Plugin.
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
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Booleans
bool g_bIsFreeday = false;
bool g_bStartFreeday = false;
bool g_bAutoFreeday = false;
bool g_bAllowRespawn = false;
bool g_bRepeatFirstFreeday = false;

// Plugin bools
bool gp_bWarden;
bool gp_bHosties;
bool gp_bSmartJailDoors;
bool gp_bMyJailbreak;

// Console Variables
ConVar gc_bPlugin;
ConVar gc_bSetW;
ConVar gc_bFirst;
ConVar gc_bAuto;
ConVar gc_iRespawn;
ConVar gc_iRespawnTime;
ConVar gc_bdamage;
ConVar gc_bSetA;
ConVar gc_bSetABypassCooldown;
ConVar gc_bVote;
ConVar gc_iCooldownDay;
ConVar gc_iRoundTime;
ConVar gc_sCustomCommandVote;
ConVar gc_sCustomCommandSet;
ConVar gc_sAdminFlag;

// Extern Convars
ConVar g_iMPRoundTime;

// Integers
int g_iOldRoundTime;
int g_iCoolDown;
int g_iVoteCount;
int g_iFreedayRound = 0;
int g_iCollision_Offset;

// Strings
char g_sHasVoted[1500];
char g_sEventsLogFile[PLATFORM_MAX_PATH];
char g_sAdminFlag[4];

// Floats
float g_fPos[3];

// Info
public Plugin myinfo =
{
	name = "MyJailbreak - Freeday",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
};

// Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.FreeDay.phrases");

	// Client Commands
	RegConsoleCmd("sm_setfreeday", Command_SetFreeday, "Allows the Admin or Warden to set freeday as next round");
	RegConsoleCmd("sm_freeday", Command_VoteFreeday, "Allows players to vote for a freeday");

	// AutoExecConfig
	AutoExecConfig_SetFile("Freeday", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);

	AutoExecConfig_CreateConVar("sm_freeday_version", MYJB_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_freeday_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true, 0.0, true, 1.0);
	gc_sCustomCommandVote = AutoExecConfig_CreateConVar("sm_freeday_cmds_vote", "fd, free", "Set your custom chat command for Event voting(!freeday (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandSet = AutoExecConfig_CreateConVar("sm_freeday_cmds_set", "sfreeday, sfd", "Set your custom chat command for set Event(!setfreeday (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_freeday_warden", "1", "0 - disabled, 1 - allow warden to set freeday round", _, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_freeday_admin", "1", "0 - disabled, 1 - allow admin/vip to set freeday round", _, true, 0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_freeday_flag", "g", "Set flag for admin/vip to set this Event Day.");
	gc_bVote = AutoExecConfig_CreateConVar("sm_freeday_vote", "1", "0 - disabled, 1 - allow player to vote for freeday", _, true, 0.0, true, 1.0);
	gc_bAuto = AutoExecConfig_CreateConVar("sm_freeday_noct", "1", "0 - disabled, 1 - auto freeday when there is no CT", _, true, 0.0, true, 1.0);
	gc_iRespawn = AutoExecConfig_CreateConVar("sm_freeday_respawn", "1", "1 - respawn on NoCT Freeday / 2 - respawn on firstround/vote/set Freeday / 3 - Both", _, true, 1.0, true, 3.0);
	gc_iRespawnTime = AutoExecConfig_CreateConVar("sm_freeday_respawn_time", "120", "Time in seconds player will respawn after round begin", _, true, 1.0);
	gc_bFirst = AutoExecConfig_CreateConVar("sm_freeday_firstround", "1", "0 - disabled, 1 - auto freeday first round after mapstart", _, true, 0.0, true, 1.0);
	gc_bdamage = AutoExecConfig_CreateConVar("sm_freeday_damage", "1", "0 - disabled, 1 - enable damage on freedays", _, true, 0.0, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_freeday_roundtime", "5", "Round time in minutes for a single freeday round", _, true, 1.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_freeday_cooldown_day", "0", "Rounds until freeday can be started again.", _, true, 0.0);
	gc_bSetABypassCooldown = AutoExecConfig_CreateConVar("sm_freeday_cooldown_admin", "1", "0 - disabled, 1 - ignore the cooldown when admin/vip set freeday round", _, true, 0.0, true, 1.0);

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_death", Event_PlayerDeath);
	HookConVarChange(gc_sAdminFlag, OnSettingChanged);

	// FindConVar
	g_iMPRoundTime = FindConVar("mp_roundtime");
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	gc_sAdminFlag.GetString(g_sAdminFlag, sizeof(g_sAdminFlag));

	// Offsets
	g_iCollision_Offset = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");

	// Logs
	SetLogFile(g_sEventsLogFile, "Events", "MyJailbreak");
}

// ConVarChange for Strings
public void OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sAdminFlag)
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
}

// Initialize Event
public void OnConfigsExecuted()
{
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
			RegConsoleCmd(sCommand, Command_VoteFreeday, "Allows players to vote for a freeday");
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
			RegConsoleCmd(sCommand, Command_SetFreeday, "Allows the Admin or Warden to set freeday as next round");
		}
	}
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

// Admin & Warden set Event
public Action Command_SetFreeday(int client, int args)
{
	if (!gc_bPlugin.BoolValue)
	{
		CReplyToCommand(client, "%t %t", "freeday_tag", "freeday_disabled");
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
			LogToFileEx(g_sEventsLogFile, "Event Deal Damage was started by groupvoting");
		}
	}
	else if (CheckVipFlag(client, g_sAdminFlag)) // Called by admin/VIP
	{
		if (!gc_bSetA.BoolValue)
		{
			CReplyToCommand(client, "%t %t", "freeday_tag", "freeday_setbyadmin");
			return Plugin_Handled;
		}

		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				CReplyToCommand(client, "%t %t", "freeday_tag", "freeday_progress", EventDay);
				return Plugin_Handled;
			}
		}

		if (g_iCoolDown > 0 && !gc_bSetABypassCooldown.BoolValue)
		{
			CReplyToCommand(client, "%t %t", "freeday_tag", "freeday_wait", g_iCoolDown);
			return Plugin_Handled;
		}

		StartNextRound();

		if (!gp_bMyJailbreak)
		{
			return Plugin_Handled;
		}

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event FreeDay was started by admin %L", client);
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
			CReplyToCommand(client, "%t %t", "warden_tag", "freeday_setbywarden");
			return Plugin_Handled;
		}

		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				CReplyToCommand(client, "%t %t", "freeday_tag", "freeday_progress", EventDay);
				return Plugin_Handled;
			}
		}

		if (g_iCoolDown > 0)
		{
			CReplyToCommand(client, "%t %t", "freeday_tag", "freeday_wait", g_iCoolDown);
			return Plugin_Handled;
		}

		StartNextRound();

		if (!gp_bMyJailbreak)
		{
			return Plugin_Handled;
		}

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event FreeDay was started by warden %L", client);
		}
	}
	else
	{
		CReplyToCommand(client, "%t %t", "warden_tag", "warden_notwarden");
	}

	return Plugin_Handled;
}

// Voting for Event
public Action Command_VoteFreeday(int client, int args)
{
	if (!gc_bPlugin.BoolValue)
	{
		CReplyToCommand(client, "%t %t", "freeday_tag", "freeday_disabled");
		return Plugin_Handled;
	}

	if (!gc_bVote.BoolValue)
	{
		CReplyToCommand(client, "%t %t", "freeday_tag", "freeday_voting");
		return Plugin_Handled;
	}

	if (gp_bMyJailbreak)
	{
		char EventDay[64];
		MyJailbreak_GetEventDayName(EventDay);

		if (!StrEqual(EventDay, "none", false))
		{
			CReplyToCommand(client, "%t %t", "freeday_tag", "freeday_progress", EventDay);
			return Plugin_Handled;
		}
	}

	if (g_iCoolDown > 0)
	{
		CReplyToCommand(client, "%t %t", "freeday_tag", "freeday_wait", g_iCoolDown);
		return Plugin_Handled;
	}

	char steamid[24];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));

	if (StrContains(g_sHasVoted, steamid, true) != -1)
	{
		CReplyToCommand(client, "%t %t", "freeday_tag", "freeday_voted");
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
			LogToFileEx(g_sEventsLogFile, "Event FreeDay was started by voting");
		}
	}
	else
	{
		CPrintToChatAll("%t %t", "freeday_tag", "freeday_need", Missing, client);
	}

	return Plugin_Handled;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

// Round start
public void Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	if ((GetTeamClientCount(CS_TEAM_CT) < 1) && gc_bAuto.BoolValue)
	{
		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!MyJailbreak_IsEventDayPlanned())
			{
				g_bStartFreeday = true;
				g_iCoolDown = gc_iCooldownDay.IntValue + 1;
				g_iVoteCount = 0;
				char buffer[32];
				Format(buffer, sizeof(buffer), "%T", "freeday_name", LANG_SERVER);
				MyJailbreak_SetEventDayName(buffer);
				MyJailbreak_SetEventDayRunning(true, 0);
				g_bAutoFreeday = true;
			}
		}
	}

	if (!g_bStartFreeday && !g_bRepeatFirstFreeday)
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

	SetCvar("sm_weapons_enable", 0);
	SetCvar("sm_weapons_t", 0);

	if (gp_bMyJailbreak)
	{
		MyJailbreak_SetEventDayPlanned(false);
		MyJailbreak_SetEventDayRunning(true, 0);
	}

	g_bIsFreeday = true;
	g_iFreedayRound++;
	g_bStartFreeday = false;
	g_bAllowRespawn = true;

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

	CreateTimer (gc_iRespawnTime.FloatValue, Timer_StopRespawn);

	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
	{
		CreateInfoPanel(i);

		SetEntData(i, g_iCollision_Offset, 2, 4, true);

		if (!gc_bdamage.BoolValue && IsValidClient(i))
		{
			SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);
		}
	}

	if (g_bRepeatFirstFreeday)
	{
		SetTeamScore(CS_TEAM_CT, 0);
		SetTeamScore(CS_TEAM_T, 0);
		g_bRepeatFirstFreeday = false;
	}

	if (gc_bFirst.BoolValue)
	{
		if ((GetTeamClientCount(CS_TEAM_CT) == 0) || (GetTeamClientCount(CS_TEAM_T) == 0) && (GetTeamScore(CS_TEAM_CT) + GetTeamScore(CS_TEAM_T) == 0))
		{
			g_bRepeatFirstFreeday = true;
		}
	}

	PrintCenterTextAll("%t", "freeday_start_nc");
	CPrintToChatAll("%t %t", "freeday_tag", "freeday_start");
}

// Round End
public void Event_RoundEnd(Event event, char[] name, bool dontBroadcast)
{
	if (g_bIsFreeday)
	{
		for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, false, true))
		{
			SetEntData(i, g_iCollision_Offset, 0, 4, true);
		}

		g_bIsFreeday = false;
		g_bStartFreeday = false;
		g_bAllowRespawn = false;
		g_bAutoFreeday = false;
		g_iFreedayRound = 0;
		Format(g_sHasVoted, sizeof(g_sHasVoted), "");

		if (gp_bHosties)
		{
			SetCvar("sm_hosties_lr", 1);
		}

		if (gp_bWarden)
		{
			SetCvar("sm_warden_enable", 1);
		}

		SetCvar("sm_weapons_enable", 1);
		SetCvar("mp_teammates_are_enemies", 0);

		g_iMPRoundTime.IntValue = g_iOldRoundTime;

		if (gp_bMyJailbreak)
		{
			MyJailbreak_SetEventDayName("none"); // tell myjailbreak event is ended
			MyJailbreak_SetEventDayRunning(false, 0);
		}

		CPrintToChatAll("%t %t", "freeday_tag", "freeday_end");
	}

	if (g_bStartFreeday || g_bRepeatFirstFreeday)
	{
		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
		{
			CreateInfoPanel(i);
		}

		CPrintToChatAll("%t %t", "freeday_tag", "freeday_next");
		PrintCenterTextAll("%t", "freeday_next_nc");
	}
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	if ((g_bAutoFreeday && gc_iRespawn.IntValue == 1) || (g_bIsFreeday && gc_iRespawn.IntValue == 2) || ((g_bIsFreeday || g_bAutoFreeday) && gc_iRespawn.IntValue == 3))
	{
		int client = GetClientOfUserId(event.GetInt("userid")); // Get the dead clients id

		if (((GetAlivePlayersCount(CS_TEAM_CT) >= 1) && (GetClientTeam(client) == CS_TEAM_CT) && g_bAllowRespawn) || ((GetAlivePlayersCount(CS_TEAM_T) >= 1) && (GetClientTeam(client) == CS_TEAM_T) && g_bAllowRespawn))
		{
			CreateTimer (2.0, Timer_Respawn, GetClientUserId(client));
		}
	}
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

// Initialize Event
public void OnMapStart()
{
	g_iVoteCount = 0;
	g_iFreedayRound = 0;

	g_bIsFreeday = false;
	g_bAutoFreeday = false;
	g_bRepeatFirstFreeday = false;

	if (gc_bFirst.BoolValue)
	{
		g_bStartFreeday = true;

		if (gp_bMyJailbreak)
		{
			char buffer[32];
			Format(buffer, sizeof(buffer), "%T", "freeday_name", LANG_SERVER);
			MyJailbreak_SetEventDayName(buffer);
			MyJailbreak_SetEventDayRunning(true, 0);
		}

		g_iOldRoundTime = g_iMPRoundTime.IntValue;
		g_iMPRoundTime.IntValue = gc_iRoundTime.IntValue;
	}
	else
	{
		g_bStartFreeday = false;
	}
}

// Map End
public void OnMapEnd()
{
	if (gc_bFirst.BoolValue)
	{
		g_bStartFreeday = true;
	}
	else
	{
		g_bStartFreeday = false;
	}

	g_bIsFreeday = false;
	g_bAutoFreeday = false;
	g_bAllowRespawn = false;

	g_iVoteCount = 0;
	g_iFreedayRound = 0;
	g_sHasVoted[0] = '\0';
}

/******************************************************************************
                   FUNCTIONS
******************************************************************************/

// Prepare Event
void StartNextRound()
{
	g_bStartFreeday = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;

	if (gp_bMyJailbreak)
	{
		char buffer[32];
		Format(buffer, sizeof(buffer), "%T", "freeday_name", LANG_SERVER);
		MyJailbreak_SetEventDayName(buffer);
		MyJailbreak_SetEventDayPlanned(true);
	}

	g_iOldRoundTime = g_iMPRoundTime.IntValue;
	g_iMPRoundTime.IntValue = gc_iRoundTime.IntValue;

	CPrintToChatAll("%t %t", "freeday_tag", "freeday_next");
	PrintCenterTextAll("%t", "freeday_next_nc");
}

/******************************************************************************
                   MENUS
******************************************************************************/

void CreateInfoPanel(int client)
{
	// Create info Panel
	char info[255];

	Panel InfoPanel = new Panel();

	Format(info, sizeof(info), "%T", "freeday_info_title", client);
	InfoPanel.SetTitle(info);

	InfoPanel.DrawText("                                   ");
	Format(info, sizeof(info), "%T", "freeday_info_line1", client);
	InfoPanel.DrawText(info);
	InfoPanel.DrawText("-----------------------------------");
	Format(info, sizeof(info), "%T", "freeday_info_line2", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "freeday_info_line3", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "freeday_info_line4", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "freeday_info_line5", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "freeday_info_line6", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "freeday_info_line7", client);
	InfoPanel.DrawText(info);
	InfoPanel.DrawText("-----------------------------------");

	Format(info, sizeof(info), "%T", "warden_close", client);
	InfoPanel.DrawItem(info);

	InfoPanel.Send(client, Handler_NullCancel, 20);
}

/******************************************************************************
                   TIMER
******************************************************************************/

public Action Timer_StopRespawn(Handle timer)
{
	g_bAllowRespawn = false;
}

public Action Timer_Respawn(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	CS_RespawnPlayer(client);
}
