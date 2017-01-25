/*
 * MyJailbreak - Freeday Event Day Plugin.
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
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http:// www.gnu.org/licenses/>.
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
#include <hosties>
#include <lastrequest>
#include <warden>
#include <smartjaildoors>
#include <mystocks>
#include <myjailbreak>

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Booleans
bool g_bIsFreeday = false;
bool g_bStartFreeday = false;
bool g_bAutoFreeday = false;
bool g_bAllowRespawn = false;
bool g_bRepeatFirstFreeday = false;

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

// Handles

// Strings
char g_sHasVoted[1500];
char g_sEventsLogFile[PLATFORM_MAX_PATH];
char g_sAdminFlag[32];

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
			RegConsoleCmd(sCommand, Command_VoteFreeday, "Allows players to vote for a freeday");
	}

	// Set
	gc_sCustomCommandSet.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  // if command not already exist
			RegConsoleCmd(sCommand, Command_SetFreeday, "Allows the Admin or Warden to set freeday as next round");
	}
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

// Admin & Warden set Event
public Action Command_SetFreeday(int client, int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (client == 0)
		{
			StartNextRound();
			if (MyJailbreak_ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event FreeDay was started by groupvoting");
		}
		else if (warden_iswarden(client))
		{
			if (gc_bSetW.BoolValue)
			{
				char EventDay[64];
				MyJailbreak_GetEventDayName(EventDay);
				
				if (!MyJailbreak_IsEventDayPlanned())
				{
					if (g_iCoolDown == 0)
					{
						StartNextRound();
						if (MyJailbreak_ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event Freeday was started by warden %L", client);
					}
					else CReplyToCommand(client, "%t %t", "freeday_tag", "freeday_wait", g_iCoolDown);
				}
				else CReplyToCommand(client, "%t %t", "freeday_tag", "freeday_progress", EventDay);
			}
			else CReplyToCommand(client, "%t %t", "warden_tag", "freeday_setbywarden");
		}
		else if (CheckVipFlag(client, g_sAdminFlag))
		{
			if (gc_bSetA.BoolValue)
			{
				char EventDay[64];
				MyJailbreak_GetEventDayName(EventDay);
				
				if (!MyJailbreak_IsEventDayPlanned())
				{
					if ((g_iCoolDown == 0) || gc_bSetABypassCooldown.BoolValue)
					{
						StartNextRound();
						if (MyJailbreak_ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event Freeday was started by admin %L", client);
					}
					else CReplyToCommand(client, "%t %t", "freeday_tag", "freeday_wait", g_iCoolDown);
				}
				else CReplyToCommand(client, "%t %t", "freeday_tag", "freeday_progress", EventDay);
			}
			else CReplyToCommand(client, "%t %t", "freeday_tag", "freeday_setbyadmin");
		}
		else CReplyToCommand(client, "%t %t", "warden_tag", "warden_notwarden");
	}
	else CReplyToCommand(client, "%t %t", "freeday_tag", "freeday_disabled");

	return Plugin_Handled;
}

// Voting for Event
public Action Command_VoteFreeday(int client, int args)
{
	char steamid[24];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));

	if (gc_bPlugin.BoolValue)
	{
		if (gc_bVote.BoolValue)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);
			
			if (!MyJailbreak_IsEventDayPlanned())
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
							if (MyJailbreak_ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event freeday was started by voting");
						}
						else CPrintToChatAll("%t %t", "freeday_tag", "freeday_need", Missing, client);
					}
					else CReplyToCommand(client, "%t %t", "freeday_tag", "freeday_voted");
				}
				else CReplyToCommand(client, "%t %t", "freeday_tag", "freeday_wait", g_iCoolDown);
			}
			else CReplyToCommand(client, "%t %t", "freeday_tag", "freeday_progress", EventDay);
		}
		else CReplyToCommand(client, "%t %t", "freeday_tag", "freeday_voting");
	}
	else CReplyToCommand(client, "%t %t", "freeday_tag", "freeday_disabled");

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
			MyJailbreak_SetEventDayRunning(true);
			g_bAutoFreeday = true;
		}
	}

	if (g_bStartFreeday || g_bRepeatFirstFreeday)
	{
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_weapons_enable", 0);
		SetCvar("sm_weapons_t", 0);
		SetCvar("sm_warden_enable", 0);
		MyJailbreak_SetEventDayPlanned(false);
		MyJailbreak_SetEventDayRunning(true);
		g_bIsFreeday = true;
		g_iFreedayRound++;
		g_bStartFreeday = false;
		SJD_OpenDoors();
		
		CreateTimer (gc_iRespawnTime.FloatValue, Timer_StopRespawn);
		g_bAllowRespawn = true;
		
		LoopClients(i)
		{
			CreateInfoPanel(i);

			if (!gc_bdamage.BoolValue && IsValidClient(i))
			{
				SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);
			}

			if (IsPlayerAlive(i)) 
			{
				PrintCenterText(i, "%t", "freeday_start_nc");
			}
		}
		CPrintToChatAll("%t %t", "freeday_tag", "freeday_start");

		if (g_bRepeatFirstFreeday)
		{
			SetTeamScore(CS_TEAM_CT, 0);
			SetTeamScore(CS_TEAM_T, 0);
			g_bRepeatFirstFreeday = false;
		}

		if (gc_bFirst.BoolValue) if ((GetTeamClientCount(CS_TEAM_CT) == 0) || (GetTeamClientCount(CS_TEAM_T) == 0) && (GetTeamScore(CS_TEAM_CT) + GetTeamScore(CS_TEAM_T) == 0)) g_bRepeatFirstFreeday = true;
	}
	else
	{
		if (g_iCoolDown > 0) g_iCoolDown--;
	}
}

// Round End
public void Event_RoundEnd(Event event, char[] name, bool dontBroadcast)
{
	if (g_bIsFreeday)
	{
		g_bIsFreeday = false;
		g_bStartFreeday = false;
		g_bAllowRespawn = false;
		g_iFreedayRound = 0;
		Format(g_sHasVoted, sizeof(g_sHasVoted), "");

		SetCvar("sm_hosties_lr", 1);
		SetCvar("sm_weapons_enable", 1);
		SetCvar("mp_teammates_are_enemies", 0);
		SetCvar("sm_warden_enable", 1);
		g_iMPRoundTime.IntValue = g_iOldRoundTime;

		g_bAutoFreeday = false;
		MyJailbreak_SetEventDayName("none");
		MyJailbreak_SetEventDayRunning(false);
		CPrintToChatAll("%t %t", "freeday_tag", "freeday_end");
	}

	if (g_bStartFreeday || g_bRepeatFirstFreeday)
	{
		LoopClients(i) CreateInfoPanel(i);
		
		CPrintToChatAll("%t %t", "freeday_tag", "freeday_next");
		PrintCenterTextAll("%t", "freeday_next_nc");
	}
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	if ((g_bAutoFreeday && gc_iRespawn.IntValue == 1) || (g_bIsFreeday && gc_iRespawn.IntValue == 2) || ((g_bIsFreeday || g_bAutoFreeday) && gc_iRespawn.IntValue == 3))
	{
		int client = GetClientOfUserId(event.GetInt("userid")); // Get the dead clients id

		if (((GetAliveTeamCount(CS_TEAM_CT) >= 1) && (GetClientTeam(client) == CS_TEAM_CT) && g_bAllowRespawn) || ((GetAliveTeamCount(CS_TEAM_T) >= 1) && (GetClientTeam(client) == CS_TEAM_T) && g_bAllowRespawn))
		{
			CreateTimer (2.0, Timer_Respawn, client);
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

	if (gc_bFirst.BoolValue)
	{
		g_bStartFreeday = true;

		char buffer[32];
		Format(buffer, sizeof(buffer), "%T", "freeday_name", LANG_SERVER);
		MyJailbreak_SetEventDayName(buffer);

		MyJailbreak_SetEventDayRunning(true);

		g_iOldRoundTime = g_iMPRoundTime.IntValue;
		g_iMPRoundTime.IntValue = gc_iRoundTime.IntValue;
	}
	else
	{
		g_bStartFreeday = false;
	}

	g_bIsFreeday = false;
	g_bAutoFreeday = false;
	g_bRepeatFirstFreeday = false;
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

	MyJailbreak_SetEventDayName("none");
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

	char buffer[32];
	Format(buffer, sizeof(buffer), "%T", "freeday_name", LANG_SERVER);
	MyJailbreak_SetEventDayName(buffer);
	MyJailbreak_SetEventDayPlanned(true);

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

public Action Timer_Respawn(Handle timer, any client)
{
	CS_RespawnPlayer(client);
}