/*
 * MyJailbreak - Ratio Plugin.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
 * based on Addicteds https://github.com/oaaron99/JailRatio
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
#include <colors>
#include <autoexecconfig>
#include <mystocks>

// Optional Plugins
#undef REQUIRE_PLUGIN
#include <myjailbreak>
#include <warden>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Console Variables
ConVar gc_fPrisonerPerGuard;
ConVar gc_sCustomCommandGuard;
ConVar gc_sCustomCommandQueue;
ConVar gc_sCustomCommandLeave;
ConVar gc_sCustomCommandRatio;
ConVar gc_sCustomCommandRemove;
ConVar gc_sCustomCommandClear;
ConVar gc_sCustomCommandPrisoner;
ConVar gc_sCustomCommandSpec;
ConVar gc_sAdminFlag;
ConVar gc_bToggle;
ConVar gc_bToggleAnnounce;
ConVar gc_bAdsVIP;
ConVar gc_bVIPQueue;
ConVar gc_bAdminBypass;
ConVar gc_bForceTConnect;
ConVar gc_iJoinMode;
ConVar gc_iQuestionTimes;
ConVar gc_bBalanceTerror;
ConVar gc_bBalanceGuards;
ConVar gc_bBalanceWarden;
ConVar gc_bRespawn;

// Booleans
bool g_bRatioEnable = true;
bool g_bQueueCooldown[MAXPLAYERS+1] = {false, ...};
bool gp_bWarden = false;

// Handles
Handle g_aGuardQueue;
Handle g_aGuardList;
Handle g_hDataPackTeam;
Handle gF_OnClientJoinGuards;

// Integer
int g_iRandomAnswer[MAXPLAYERS+1];
int g_iQuestionTimes[MAXPLAYERS+1];

// Strings
char g_sRestrictedSound[32] = "buttons/button11.wav";
char g_sRightAnswerSound[32] = "buttons/button14.wav";
char g_sAdminFlag[64];

// Info
public Plugin myinfo = {
	name = "MyJailbreak - Ratio",
	author = "shanapu, Addicted",
	description = "Jailbreak team balance / ratio plugin",
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
};

// Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Ratio.phrases");

	// Client commands
	RegConsoleCmd("sm_guard", Command_JoinGuardQueue, "Allows the prisoners to queue to CT");
	RegConsoleCmd("sm_prisoner", Command_JoinTerror, "Allows a player to join prisoner");
	RegConsoleCmd("sm_spectator", Command_JoinSpec, "Allows a player to join Spectator");
	RegConsoleCmd("sm_viewqueue", Command_ViewGuardQueue, "Allows a player to show queue to CT");
	RegConsoleCmd("sm_leavequeue", Command_LeaveQueue, "Allows a player to leave queue to CT");
	RegConsoleCmd("sm_ratio", Command_ToggleRatio, "Allows the admin toggle the ratio check and player to see if ratio is enabled");

	// Admin commands
	RegAdminCmd("sm_removequeue", AdminCommand_RemoveFromQueue, ADMFLAG_GENERIC, "Allows the admin to remove player from queue to CT");
	RegAdminCmd("sm_clearqueue", AdminCommand_ClearQueue, ADMFLAG_GENERIC, "Allows the admin clear the CT queue");

	// AutoExecConfig
	AutoExecConfig_SetFile("Ratio", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);

	AutoExecConfig_CreateConVar("sm_ratio_version", MYJB_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_sCustomCommandGuard = AutoExecConfig_CreateConVar("sm_ratio_cmds_guard", "g, ct, guards", "Set your custom chat command for become guard(!guard (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandQueue = AutoExecConfig_CreateConVar("sm_ratio_cmds_queue", "vq, queue", "Set your custom chat command for view guard queue (!viewqueue (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandLeave = AutoExecConfig_CreateConVar("sm_ratio_cmds_leave", "lq, stay", "Set your custom chat command for view leave queue (!leavequeue (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandRatio = AutoExecConfig_CreateConVar("sm_ratio_cmds_ratio", "balance", "Set your custom chat command for view/toggle ratio (!ratio (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandRemove = AutoExecConfig_CreateConVar("sm_ratio_cmds_remove", "rq", "Set your custom chat command for admins to remove a player from guard queue (!removequeue (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandClear = AutoExecConfig_CreateConVar("sm_ratio_cmds_clear", "cq", "Set your custom chat command for admins to clear the guard queue (!clearqueue (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandPrisoner = AutoExecConfig_CreateConVar("sm_ratio_cmds_prisoner", "t,terror", "Set your custom chat command for player to move to prisoner (!prisoner (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandSpec = AutoExecConfig_CreateConVar("sm_ratio_cmds_spec", "spec", "Set your custom chat command for player to move to spectator (!spectator (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_fPrisonerPerGuard = AutoExecConfig_CreateConVar("sm_ratio_T_per_CT", "2", "How many prisoners for each guard.", _, true, 1.0);
	gc_bVIPQueue = AutoExecConfig_CreateConVar("sm_ratio_flag", "1", "0 - disabled, 1 - enable VIPs moved to front of queue", _, true, 0.0, true, 1.0);
	gc_bForceTConnect = AutoExecConfig_CreateConVar("sm_ratio_force_t", "1", "0 - disabled, 1 - force player on connect to join T side", _, true, 0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_ratio_vipflag", "a", "Set the flag for VIP");
	gc_bToggle = AutoExecConfig_CreateConVar("sm_ratio_disable", "0", "Allow the admin to toggle 'ratio check & autoswap' on/off with !ratio", _, true, 0.0, true, 1.0);
	gc_bToggleAnnounce = AutoExecConfig_CreateConVar("sm_ratio_disable_announce", "0", "Announce in a chatmessage on roundend when ratio is disabled", _, true, 0.0, true, 1.0);
	gc_bAdsVIP = AutoExecConfig_CreateConVar("sm_ratio_adsvip", "1", "0 - disabled, 1 - enable adverstiment for 'VIPs moved to front of queue' when player types !guard ", _, true, 0.0, true, 1.0);
	gc_iJoinMode = AutoExecConfig_CreateConVar("sm_ratio_join_mode", "1", "0 - instandly join ct/queue, no confirmation / 1 - confirm rules / 2 - Qualification questions", _, true, 0.0, true, 2.0);
	gc_iQuestionTimes = AutoExecConfig_CreateConVar("sm_ratio_questions", "3", "How many question a player have to answer before join ct/queue. need sm_ratio_join_mode 2", _, true, 1.0, true, 5.0);
	gc_bAdminBypass = AutoExecConfig_CreateConVar("sm_ratio_vip_bypass", "1", "Bypass Admin/VIP though agreement / question", _, true, 0.0, true, 1.0);
	gc_bBalanceTerror = AutoExecConfig_CreateConVar("sm_ratio_balance_terror", "1", "0 = Could result in unbalanced teams. 1 = Switch a random T, when nobody is in guardqueue to balance the teams.", _, true, 0.0, true, 1.0);
	gc_bBalanceGuards = AutoExecConfig_CreateConVar("sm_ratio_balance_guard", "1", "Mode to choose a guard to be switch to T on balance the teams. 1 = Last In First Out / 0 = Random Guard", _, true, 0.0, true, 1.0);
	gc_bBalanceWarden = AutoExecConfig_CreateConVar("sm_ratio_balance_warden", "1", "Prevent warden & deputy to be switch to T on balance the teams. Could result in unbalanced teams", _, true, 0.0, true, 1.0);
	gc_bRespawn = AutoExecConfig_CreateConVar("sm_ratio_respawn", "1", "0 - Move player on next round to CT / 1 - Move player immediately to CT and respawn", _, true, 0.0, true, 1.0);

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks
	AddCommandListener(Event_OnJoinTeam, "jointeam");
	HookEvent("player_connect_full", Event_OnFullConnect, EventHookMode_Pre);
	HookEvent("player_team", Event_PlayerTeam_Post, EventHookMode_Post);
	HookEvent("round_end", Event_RoundEnd_Post, EventHookMode_Post);
	HookConVarChange(gc_sAdminFlag, OnSettingChanged);
	
	// FindConVar
	gc_sAdminFlag.GetString(g_sAdminFlag, sizeof(g_sAdminFlag));

	// Prepare
	g_aGuardQueue = CreateArray();
	g_aGuardList = CreateArray();
}

// ConVarChange for Strings
public void OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sAdminFlag)
	{
		strcopy(g_sAdminFlag, sizeof(g_sAdminFlag), newValue);
	}
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	gF_OnClientJoinGuards = CreateGlobalForward("MyJailbreak_OnJoinGuardQueue", ET_Event, Param_Cell);
	
	RegPluginLibrary("myratio");
	return APLRes_Success;
}

public void OnConfigsExecuted()
{
	Handle hConVar = FindConVar("mp_force_pick_time");
	if (hConVar == INVALID_HANDLE)
		return;

	HookConVarChange(hConVar, OnForcePickTimeChanged);
	SetConVarInt(hConVar, 999999);

	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// Join Guardqueue
	gc_sCustomCommandGuard.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  // if command not already exist
			RegConsoleCmd(sCommand, Command_JoinGuardQueue, "Allows the prisoners to queue to CT");
	}

	// Join Prisoners
	gc_sCustomCommandPrisoner.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  // if command not already exist
			RegConsoleCmd(sCommand, Command_JoinTerror, "Allows the player to join prisoners");
	}

	// Join spectator
	gc_sCustomCommandSpec.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  // if command not already exist
			RegConsoleCmd(sCommand, Command_JoinSpec, "Allows the player to join spectator");
	}

	// View guardqueue
	gc_sCustomCommandQueue.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  // if command not already exist
			RegConsoleCmd(sCommand, Command_ViewGuardQueue, "Allows a player to show queue to CT");
	}

	// leave guardqueue
	gc_sCustomCommandLeave.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  // if command not already exist
			RegConsoleCmd(sCommand, Command_LeaveQueue, "Allows a player to leave queue to CT");
	}

	// View/toggle ratio
	gc_sCustomCommandRatio.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  // if command not already exist
		{
			RegConsoleCmd(sCommand, Command_ToggleRatio, "Allows the admin toggle the ratio check and player to see if ratio is enabled");
		}
	}

	// Admin remove player from queue
	gc_sCustomCommandRemove.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  // if command not already exist
			RegAdminCmd(sCommand, AdminCommand_RemoveFromQueue, ADMFLAG_GENERIC, "Allows the admin to remove player from queue to CT");
	}

	// Admin clear queue
	gc_sCustomCommandClear.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  // if command not already exist
			RegAdminCmd(sCommand, AdminCommand_ClearQueue, ADMFLAG_GENERIC, "Allows the admin clear the CT queue");
	}
}

public void OnAllPluginsLoaded()
{
	gp_bWarden = LibraryExists("warden");
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "warden"))
		gp_bWarden = false;
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "warden"))
		gp_bWarden = true;
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

public Action Command_LeaveQueue(int client, int iArgNum)
{
	int iIndex = FindValueInArray(g_aGuardQueue, client);

	if (!g_bRatioEnable)
	{
		CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_disabled");
		return Plugin_Handled;
	}

	if (iIndex == -1)
	{
		CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_notonqueue");
		return Plugin_Handled;
	}
	else
	{
		RemovePlayerFromGuardQueue(client);
		CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_leavedqueue");
		return Plugin_Handled;
	}
}

public Action Command_ViewGuardQueue(int client, int args)
{
	if (!IsValidClient(client, true, true))
		return Plugin_Handled;

	if (!g_bRatioEnable)
	{
		CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_disabled");
		return Plugin_Handled;
	}

	if (GetArraySize(g_aGuardQueue) < 1)
	{
		CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_empty");
		return Plugin_Handled;
	}
	char info[64];

	Panel InfoPanel = new Panel();

	Format(info, sizeof(info), "%T", "ratio_info_title", client);
	InfoPanel.SetTitle(info);
	
	InfoPanel.DrawText("-----------------------------------");
	InfoPanel.DrawText("                                   ");

	for (int i; i < GetArraySize(g_aGuardQueue); i++)
	{
		if (!IsValidClient(GetArrayCell(g_aGuardQueue, i), true, true))
			continue;
		
		char display[120];
		Format(display, sizeof(display), "%N", GetArrayCell(g_aGuardQueue, i));
		InfoPanel.DrawText(display);
	}

	InfoPanel.DrawText("                                   ");
	InfoPanel.DrawText("-----------------------------------");
	Format(info, sizeof(info), "%T", "ratio_close", client);
	InfoPanel.DrawItem(info);
	InfoPanel.Send(client, Handler_NullCancel, 12);

	return Plugin_Handled;
}

public Action Command_JoinGuardQueue(int client, int iArgNum)
{
	if (!IsValidClient(client, true, true))
	{
		return Plugin_Handled;
	}

	if (!g_bRatioEnable)
	{
		CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_disabled");
		return Plugin_Handled;
	}

/*
	if (GetClientTeam(client) != CS_TEAM_T)
	{
		ClientCommand(client, "play %s", g_sRestrictedSound);
		CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_noct");
		return Plugin_Handled;
	}
*/

	if (g_bQueueCooldown[client])
	{
		CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_cooldown");
		return Plugin_Handled;
	}

	Action res = Plugin_Continue;
	Call_StartForward(gF_OnClientJoinGuards);
	Call_PushCell(client);
	Call_Finish(res);

	if (res >= Plugin_Handled)
	{
		ClientCommand(client, "play %s", g_sRestrictedSound);
		return Plugin_Handled;
	}

	if (!CanClientJoinGuards(client))
	{
		int iIndex = FindValueInArray(g_aGuardQueue, client);

		if (iIndex == -1)
		{
			if ((gc_iJoinMode.IntValue == 0) || (gc_bAdminBypass.BoolValue && CheckVipFlag(client, g_sAdminFlag))) AddToQueue(client);
			if ((gc_iJoinMode.IntValue == 1) && ((gc_bAdminBypass.BoolValue && !CheckVipFlag(client, g_sAdminFlag)) || (!gc_bAdminBypass.BoolValue))) Menu_AcceptGuardRules(client);
			if ((gc_iJoinMode.IntValue == 2) && ((gc_bAdminBypass.BoolValue && !CheckVipFlag(client, g_sAdminFlag)) || (!gc_bAdminBypass.BoolValue))) Menu_GuardQuestions(client);
			g_iQuestionTimes[client] = gc_iQuestionTimes.IntValue-1;
		}
		else
		{
			CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_number", iIndex + 1);
			if (gc_bAdsVIP.BoolValue && gc_bVIPQueue.BoolValue && !CheckVipFlag(client, g_sAdminFlag)) CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_advip");
		}

		return Plugin_Handled;
	}
	if ((gc_iJoinMode.IntValue == 0) || (gc_bAdminBypass.BoolValue && CheckVipFlag(client, g_sAdminFlag)))
	{
		if (gc_bRespawn.BoolValue)
		{
			ForcePlayerSuicide(client);
			ChangeClientTeam(client, CS_TEAM_CT);
			SetClientListeningFlags(client, VOICE_NORMAL); // unmute if sm_hosties or admin has muted prisoners on round start
			MinusDeath(client);
		}
		else
		{
			int iIndex = FindValueInArray(g_aGuardQueue, client);
			int iQueueSize = GetArraySize(g_aGuardQueue);
			
			if (iIndex == -1)
			{
				if (CheckVipFlag(client, g_sAdminFlag) && gc_bVIPQueue.BoolValue)
				{
					if (iQueueSize == 0)
						iIndex = PushArrayCell(g_aGuardQueue, client);
					else
					{
						ShiftArrayUp(g_aGuardQueue, 0);
						SetArrayCell(g_aGuardQueue, 0, client);
					}
					CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_thxvip");
					CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_number", iIndex + 1);
				}
				else
				{
					iIndex = PushArrayCell(g_aGuardQueue, client);
					
					CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_number", iIndex + 1);
					if (gc_bAdsVIP.BoolValue && gc_bVIPQueue.BoolValue) CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_advip");
				}
			}
			else
			{
				CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_number", iIndex + 1);
				if (gc_bAdsVIP.BoolValue && gc_bVIPQueue.BoolValue && !CheckVipFlag(client, g_sAdminFlag)) CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_advip");
			}
		}
	}

	if ((gc_iJoinMode.IntValue == 1) && ((gc_bAdminBypass.BoolValue && !CheckVipFlag(client, g_sAdminFlag)) || (!gc_bAdminBypass.BoolValue))) Menu_AcceptGuardRules(client);
	if ((gc_iJoinMode.IntValue == 2) && ((gc_bAdminBypass.BoolValue && !CheckVipFlag(client, g_sAdminFlag)) || (!gc_bAdminBypass.BoolValue))) Menu_GuardQuestions(client);
	g_iQuestionTimes[client] = gc_iQuestionTimes.IntValue-1;

	return Plugin_Handled;
}

public Action AdminCommand_RemoveFromQueue(int client, int args)
{
	if (!IsValidClient(client, true, true))
		return Plugin_Handled;

	if (!g_bRatioEnable)
	{
		CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_disabled");
		return Plugin_Handled;
	}

	if (GetArraySize(g_aGuardQueue) < 1)
	{
		CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_empty");
		return Plugin_Handled;
	}

	Menu hMenu = CreateMenu(ViewQueueMenuHandle);
	char menuinfo[64];
	Format(menuinfo, sizeof(menuinfo), "t", "ratio_remove", client);
	SetMenuTitle(hMenu, menuinfo);

	for (int i; i < GetArraySize(g_aGuardQueue); i++)
	{
		if (!IsValidClient(GetArrayCell(g_aGuardQueue, i), true, true))
			continue;
		
		char userid[11];
		char username[MAX_NAME_LENGTH];
		IntToString(GetClientUserId(i+1), userid, sizeof(userid));
		Format(username, sizeof(username), "%N", GetArrayCell(g_aGuardQueue, i));
		hMenu.AddItem(userid, username);
	}

	hMenu.ExitBackButton = true;
	hMenu.ExitButton = true;
	DisplayMenu(hMenu, client, 15);

	return Plugin_Handled;
}

public Action AdminCommand_ClearQueue(int client, int args)
{
	ClearArray(g_aGuardQueue);
	CPrintToChatAll("%t %t", "ratio_tag", "ratio_clearqueue");
}

public Action Command_ToggleRatio(int client, int args)
{
	if (CheckVipFlag(client, g_sAdminFlag) && gc_bToggle.BoolValue)
	{
		if (g_bRatioEnable)
		{
			g_bRatioEnable = false;
			CPrintToChatAll("%t %t", "ratio_tag", "ratio_hasdisabled");
		}
		else
		{
			g_bRatioEnable = true;
			CPrintToChatAll("%t %t", "ratio_tag", "ratio_hasactivated");
		}
	}
	else
	{
		if (g_bRatioEnable)
		{
			CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_active", gc_fPrisonerPerGuard.FloatValue);
		}
		else
		{
			CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_disabled");
		}
	}

	return Plugin_Handled;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

public void Event_PlayerTeam_Post(Event event, const char[] szName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (event.GetInt("team") == CS_TEAM_CT)
	{
		int iIndex = FindValueInArray(g_aGuardList, client);
		
		if (iIndex == -1)
		{
			iIndex = PushArrayCell(g_aGuardList, client);
		}
		RemovePlayerFromGuardQueue(client);
		
	}
	else RemovePlayerFromGuardList(client);

	return;
}

public Action Event_RoundEnd_Post(Event event, const char[] szName, bool bDontBroadcast)
{
	if (g_bRatioEnable) FixTeamRatio();
	else if (gc_bToggleAnnounce.BoolValue) CPrintToChatAll("%t %t", "ratio_tag", "ratio_disabled");
	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) g_bQueueCooldown[i] = false;
}

public Action Event_OnFullConnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (gc_bForceTConnect.BoolValue && g_bRatioEnable && ((gc_bAdminBypass.BoolValue && !CheckVipFlag(client, g_sAdminFlag)) || !gc_bAdminBypass.BoolValue)) CreateTimer(1.0, Timer_ForceTSide, client);

	return Plugin_Continue;
}

public Action Event_OnJoinTeam(int client, const char[] szCommand, int iArgCount)
{
	if (iArgCount < 1)
		return Plugin_Continue;

	if (!g_bRatioEnable)
	{
		CPrintToChat(client, "%t %t", "ratio_tag", "ratio_disabled");
		return Plugin_Continue;
	}

	char szData[2];
	GetCmdArg(1, szData, sizeof(szData));
	int iTeam = StringToInt(szData);

	if (!iTeam)
	{
		ClientCommand(client, "play %s", g_sRestrictedSound);
		CPrintToChat(client, "%t %t", "ratio_tag", "ratio_auto");
		return Plugin_Handled;
	}

	if (iTeam != CS_TEAM_CT)
		return Plugin_Continue;

	if (g_bQueueCooldown[client])
	{
		CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_cooldown");
		return Plugin_Handled;
	}

	Action res = Plugin_Continue;
	Call_StartForward(gF_OnClientJoinGuards);
	Call_PushCell(client);
	Call_Finish(res);

	if (res >= Plugin_Handled)
	{
		ClientCommand(client, "play %s", g_sRestrictedSound);
		return Plugin_Handled;
	}

	if (!CanClientJoinGuards(client))
	{
		int iIndex = FindValueInArray(g_aGuardQueue, client);

		ClientCommand(client, "play %s", g_sRestrictedSound);

		if (iIndex == -1)
		{
			if ((gc_iJoinMode.IntValue == 0) || (gc_bAdminBypass.BoolValue && CheckVipFlag(client, g_sAdminFlag))) AddToQueue(client);
			if ((gc_iJoinMode.IntValue == 1) && ((gc_bAdminBypass.BoolValue && !CheckVipFlag(client, g_sAdminFlag)) || (!gc_bAdminBypass.BoolValue))) Menu_AcceptGuardRules(client);
			if ((gc_iJoinMode.IntValue == 2) && ((gc_bAdminBypass.BoolValue && !CheckVipFlag(client, g_sAdminFlag)) || (!gc_bAdminBypass.BoolValue))) Menu_GuardQuestions(client);
			g_iQuestionTimes[client] = gc_iQuestionTimes.IntValue-1;
		}
		else
		{
			CPrintToChat(client, "%t %t", "ratio_tag", "ratio_fullqueue", iIndex + 1);
			if (gc_bAdsVIP.BoolValue && gc_bVIPQueue.BoolValue && !CheckVipFlag(client, g_sAdminFlag)) CPrintToChat(client, "%t %t", "ratio_tag", "ratio_advip");
		}

		return Plugin_Handled;
	}

	if ((gc_iJoinMode.IntValue == 0) || (gc_bAdminBypass.BoolValue && CheckVipFlag(client, g_sAdminFlag))) return Plugin_Continue;
	if ((gc_iJoinMode.IntValue == 1) && ((gc_bAdminBypass.BoolValue && !CheckVipFlag(client, g_sAdminFlag)) || (!gc_bAdminBypass.BoolValue))) Menu_AcceptGuardRules(client);
	if ((gc_iJoinMode.IntValue == 2) && ((gc_bAdminBypass.BoolValue && !CheckVipFlag(client, g_sAdminFlag)) || (!gc_bAdminBypass.BoolValue))) Menu_GuardQuestions(client);

	g_iQuestionTimes[client] = gc_iQuestionTimes.IntValue-1;

	return Plugin_Handled;
}

/******************************************************************************
                   FUNCTIONS
******************************************************************************/

void MinusDeath(int client)
{
	if (IsValidClient(client, true, true))
	{
		int frags = GetEntProp(client, Prop_Data, "m_iFrags");
		int deaths = GetEntProp(client, Prop_Data, "m_iDeaths");
		SetEntProp(client, Prop_Data, "m_iFrags", (frags+1));
		SetEntProp(client, Prop_Data, "m_iDeaths", (deaths-1));
	}
}

void AddToQueue(int client)
{
	int iIndex = FindValueInArray(g_aGuardQueue, client);
	int iQueueSize = GetArraySize(g_aGuardQueue);

	if (iIndex == -1)
	{
		if (CheckVipFlag(client, g_sAdminFlag) && gc_bVIPQueue.BoolValue)
		{
			if (iQueueSize == 0)
				iIndex = PushArrayCell(g_aGuardQueue, client);
			else
			{
				ShiftArrayUp(g_aGuardQueue, 0);
				SetArrayCell(g_aGuardQueue, 0, client);
			}
			CPrintToChat(client, "%t %t", "ratio_tag", "ratio_thxvip");
			CPrintToChat(client, "%t %t", "ratio_tag", "ratio_number", iIndex + 1);
		}
		else
		{
			iIndex = PushArrayCell(g_aGuardQueue, client);
			
			CPrintToChat(client, "%t %t", "ratio_tag", "ratio_number", iIndex + 1);
			if (gc_bAdsVIP.BoolValue && gc_bVIPQueue.BoolValue) CPrintToChat(client, "%t %t", "ratio_tag", "ratio_advip");
		}
	}
}

public void OnForcePickTimeChanged(Handle hConVar, const char[] szOldValue, const char[] szNewValue)
{
	SetConVarInt(hConVar, 999999);
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

public void OnClientDisconnect_Post(int client)
{
	RemovePlayerFromGuardQueue(client);
	RemovePlayerFromGuardList(client);
}

public void OnMapStart()
{
	g_bRatioEnable = true;
}

/******************************************************************************
                   MENUS
******************************************************************************/

void Menu_AcceptGuardRules(int client)
{
	char info[64];

	Panel InfoPanel = new Panel();

	Format(info, sizeof(info), "%T", "ratio_accept_title", client);
	InfoPanel.SetTitle(info);

	InfoPanel.DrawText("-----------------------------------");
	Format(info, sizeof(info), "%T", "ratio_accept_line1", client);
	InfoPanel.DrawText(info);
	InfoPanel.DrawText("    ");
	Format(info, sizeof(info), "%T", "ratio_accept_line2", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "ratio_accept_line3", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "ratio_accept_line4", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "ratio_accept_line5", client);
	InfoPanel.DrawText(info);
	InfoPanel.DrawText("    ");
	InfoPanel.DrawText("-----------------------------------");
	InfoPanel.DrawText("    ");

	Format(info, sizeof(info), "%T", "ratio_accept", client);
	InfoPanel.DrawItem(info);
	Format(info, sizeof(info), "%T", "ratio_notaccept", client);
	InfoPanel.DrawItem(info);

	InfoPanel.Send(client, Handler_AcceptGuardRules, 20);
}

public int Handler_AcceptGuardRules(Handle menu, MenuAction action, int param1, int param2)
{
	int client = param1;

	if (action == MenuAction_Select)
	{
		switch(param2)
		{
			case 1:
			{
				if (CanClientJoinGuards(client))
				{
					ForcePlayerSuicide(client);
					ChangeClientTeam(client, CS_TEAM_CT);
					if (gc_bRespawn.BoolValue)
					{
						SetClientListeningFlags(client, VOICE_NORMAL); // unmute if sm_hosties or admin has muted prisoners on round start
						MinusDeath(client);
						CS_RespawnPlayer(client);
					}
				}
				else AddToQueue(client);
				ClientCommand(client, "play %s", g_sRightAnswerSound);
			}
			case 2:
			{
				ClientCommand(client, "play %s", g_sRestrictedSound);
				g_bQueueCooldown[client] = true;
			}
		}
	}
}

void Menu_GuardQuestions(int client)
{
	char info[64], random[64];
	Panel InfoPanel = new Panel();
	int randomquestion = GetRandomInt(1, 5);
	g_iRandomAnswer[client] = GetRandomInt(1, 3);

	Format(info, sizeof(info), "%T", "ratio_question_title", client);
	InfoPanel.SetTitle(info);
	
	InfoPanel.DrawText("-----------------------------------");
	Format(random, sizeof(random), "ratio_question%i_line1", randomquestion);
	Format(info, sizeof(info), "%T", random, client);
	InfoPanel.DrawText(info);
	Format(random, sizeof(random), "ratio_question%i_line2", randomquestion);
	Format(info, sizeof(info), "%T", random, client);
	InfoPanel.DrawText(info);
	InfoPanel.DrawText("-----------------------------------");

	if (g_iRandomAnswer[client] == 1)
	{
		InfoPanel.DrawText("    ");
		Format(random, sizeof(random), "ratio_question%i_right", randomquestion);
		Format(info, sizeof(info), "%T", random, client);
		InfoPanel.DrawItem(info);
	}

	InfoPanel.DrawText("    ");
	Format(random, sizeof(random), "ratio_question%i_wrong1", randomquestion);
	Format(info, sizeof(info), "%T", random, client);
	InfoPanel.DrawItem(info);

	if (g_iRandomAnswer[client] == 2)
	{
		InfoPanel.DrawText("    ");
		Format(random, sizeof(random), "ratio_question%i_right", randomquestion);
		Format(info, sizeof(info), "%T", random, client);
		InfoPanel.DrawItem(info);
	}

	InfoPanel.DrawText("    ");
	Format(random, sizeof(random), "ratio_question%i_wrong2", randomquestion);
	Format(info, sizeof(info), "%T", random, client);
	InfoPanel.DrawItem(info);

	if (g_iRandomAnswer[client] == 3)
	{
		InfoPanel.DrawText("    ");
		Format(random, sizeof(random), "ratio_question%i_right", randomquestion);
		Format(info, sizeof(info), "%T", random, client);
		InfoPanel.DrawItem(info);
	}

	InfoPanel.Send(client, Handler_GuardQuestions, 20);
}


public int Handler_GuardQuestions(Handle menu, MenuAction action, int param1, int param2)
{
	int client = param1;

	if (action == MenuAction_Select)
	{
		switch(param2)
		{
			case 1:
			{
				if (g_iRandomAnswer[client] == 1)
				{
					if (g_iQuestionTimes[client] <= 0)
					{
						if (CanClientJoinGuards(client))
						{
							ForcePlayerSuicide(client);
							ChangeClientTeam(client, CS_TEAM_CT);
							SetClientListeningFlags(client, VOICE_NORMAL); // unmute if sm_hosties or admin has muted prisoners on round start
							if (gc_bRespawn.BoolValue)
							{
								MinusDeath(client);
								CS_RespawnPlayer(client);
							}
						}
						else AddToQueue(client);
					}
					else Menu_GuardQuestions(client);
					ClientCommand(client, "play %s", g_sRightAnswerSound);
					g_iQuestionTimes[client]--;
				}
				else
				{
					ClientCommand(client, "play %s", g_sRestrictedSound);
					g_bQueueCooldown[client] = true;
				}
			}
			case 2:
			{
				if (g_iRandomAnswer[client] == 2)
				{
					if (g_iQuestionTimes[client] <= 0)
					{
						if (CanClientJoinGuards(client))
						{
							ForcePlayerSuicide(client);
							ChangeClientTeam(client, CS_TEAM_CT);
							SetClientListeningFlags(client, VOICE_NORMAL); // unmute if sm_hosties or admin has muted prisoners on round start
							if (gc_bRespawn.BoolValue)
							{
								MinusDeath(client);
								CS_RespawnPlayer(client);
							}
						}
						else AddToQueue(client);
					}
					else Menu_GuardQuestions(client);
					ClientCommand(client, "play %s", g_sRightAnswerSound);
					g_iQuestionTimes[client]--;
				}
				else
				{
					ClientCommand(client, "play %s", g_sRestrictedSound);
					g_bQueueCooldown[client] = true;
				}
			}
			case 3:
			{
				if (g_iRandomAnswer[client] == 3)
				{
					if (g_iQuestionTimes[client] <= 0)
					{
						if (CanClientJoinGuards(client))
						{
							ForcePlayerSuicide(client);
							ChangeClientTeam(client, CS_TEAM_CT);
							SetClientListeningFlags(client, VOICE_NORMAL); // unmute if sm_hosties or admin has muted prisoners on round start
							if (gc_bRespawn.BoolValue)
							{
								MinusDeath(client);
								CS_RespawnPlayer(client);
							}
						}
						else AddToQueue(client);
					}
					else Menu_GuardQuestions(client);
					ClientCommand(client, "play %s", g_sRightAnswerSound);
					g_iQuestionTimes[client]--;
				}
				else
				{
					ClientCommand(client, "play %s", g_sRestrictedSound);
					g_bQueueCooldown[client] = true;
				}
			}
		}
	}
}

public int ViewQueueMenuHandle(Menu hMenu, MenuAction action, int client, int option)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		hMenu.GetItem(option, info, sizeof(info));
		int user = GetClientOfUserId(StringToInt(info));

		RemovePlayerFromGuardQueue(user);

		CPrintToChatAll("%t %t", "ratio_tag", "ratio_removed", client, user);
	}
	else if (action == MenuAction_Cancel)
	{
		if (option == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_menu");
		}
	}
	else if (action == MenuAction_End)
	{
		delete hMenu;
	}
}

/******************************************************************************
                   TIMER
******************************************************************************/

public Action Timer_ForceTSide(Handle timer, any client)
{
	if (IsValidClient(client, true, true))
		ChangeClientTeam(client, CS_TEAM_T);
}

/******************************************************************************
                   STOCKS
******************************************************************************/

bool RemovePlayerFromGuardQueue(int client)
{
	int iIndex = FindValueInArray(g_aGuardQueue, client);

	if (iIndex == -1)
		return;

	RemoveFromArray(g_aGuardQueue, iIndex);
}

bool RemovePlayerFromGuardList(int client)
{
	int iIndex = FindValueInArray(g_aGuardList, client);

	if (iIndex == -1)
		return;

	RemoveFromArray(g_aGuardList, iIndex);
}


bool ShouldMoveGuardToPrisoner()
{
	int iNumGuards, iNumPrisoners;

	for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, true))
	{
		if (GetClientPendingTeam(i) == CS_TEAM_T)
			iNumPrisoners++;
		else if (GetClientPendingTeam(i) == CS_TEAM_CT)
			 iNumGuards++;
	}

	if (iNumGuards <= 1)
		return false;

	if (iNumGuards <= RoundToFloor(float(iNumPrisoners) / gc_fPrisonerPerGuard.FloatValue))
		return false;

	return true;
}

bool ShouldMovePrisonerToGuard()
{
	int iNumGuards, iNumPrisoners;

	for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, true))
	{
		if (GetClientPendingTeam(i) == CS_TEAM_T)
			iNumPrisoners++;
		else if (GetClientPendingTeam(i) == CS_TEAM_CT)
			 iNumGuards++;
	}

	iNumPrisoners--;
	iNumGuards++;

	if (iNumPrisoners < 1)
		return false;

	if (float(iNumPrisoners) / float(iNumGuards) < gc_fPrisonerPerGuard.FloatValue)
		return false;

	return true;
}


void FixTeamRatio()
{
	bool bMovedPlayers;
	while (ShouldMovePrisonerToGuard())
	{
		int client;
		if (GetArraySize(g_aGuardQueue))
		{
			client = GetArrayCell(g_aGuardQueue, 0);
			RemovePlayerFromGuardQueue(client);

			CPrintToChatAll("%t %t", "ratio_tag", "ratio_find", client);
		}
		else if (gc_bBalanceTerror.BoolValue)
		{
			client = GetRandomClientFromTeam(CS_TEAM_T);

			CPrintToChatAll("%t %t", "ratio_tag", "ratio_random", client);
		}
		else
		{
			return;
		}
		
		if (!IsValidClient(client, true, true))
		{
			CPrintToChatAll("%t %t", "ratio_tag", "ratio_novalid");

			break;
		}

		SetClientPendingTeam(client, CS_TEAM_CT);
		SetClientListeningFlags(client, VOICE_NORMAL); // unmute if sm_hosties or admin has muted prisoners on round start
		MinusDeath(client);
		bMovedPlayers = true;
	}

	if (bMovedPlayers)
		return;

	while (ShouldMoveGuardToPrisoner())
	{
		int client;
		
		if (gc_bBalanceGuards.BoolValue)
		{
			int iListSize = GetArraySize(g_aGuardList);
			int iListNum = iListSize-1;
			
			if (GetArraySize(g_aGuardList))
			{
				client = GetArrayCell(g_aGuardList, iListNum);
				
				if (gp_bWarden) if ((warden_iswarden(client) || warden_deputy_isdeputy(client) || (!warden_exist() && (warden_getlast() == client)) || (!warden_deputy_exist() && (warden_deputy_getlast() == client))) && gc_bBalanceWarden.BoolValue)
				{
					iListNum--;
					client = GetArrayCell(g_aGuardList, iListNum);
					
					if (warden_iswarden(client) || warden_deputy_isdeputy(client) || (!warden_exist() && (warden_getlast() == client)) || (!warden_deputy_exist() && (warden_deputy_getlast() == client)))
					{
						iListNum--;
						if (iListNum != -1) client = GetArrayCell(g_aGuardList, iListNum);
					}
				}
			}
			
			if (iListNum == -1)
				break;
		}
		else client = GetRandomClientFromTeam(CS_TEAM_CT);
		
		if (!client)
			break;
		
		CPrintToChatAll("%t %t", "ratio_tag", "ratio_movetot", client);
		SetClientPendingTeam(client, CS_TEAM_T);
		MinusDeath(client);
		RemovePlayerFromGuardList(client);
	}
}

int GetRandomClientFromTeam(int iTeam)
{
	int iNumFound;
	int clients[MAXPLAYERS];

	for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, true))
	{
		if (GetClientPendingTeam(i) != iTeam)
			continue;
		
		if (gp_bWarden) if ((warden_iswarden(i) || warden_deputy_isdeputy(i)) && gc_bBalanceWarden.BoolValue)
			continue;
		
		Action res = Plugin_Continue;
		Call_StartForward(gF_OnClientJoinGuards);
		Call_PushCell(i);
		Call_Finish(res);
		
		if (res >= Plugin_Handled)
			continue;
		
		clients[iNumFound++] = i;
	}

	if (!iNumFound)
		return 0;

	return clients[GetRandomInt(0, iNumFound-1)];
}

bool CanClientJoinGuards(int client)
{
	int iNumGuards, iNumPrisoners;

	for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, true))
	{
		if (GetClientPendingTeam(i) == CS_TEAM_T)
			iNumPrisoners++;
		else if (GetClientPendingTeam(i) == CS_TEAM_CT)
			 iNumGuards++;
	}

	iNumGuards++;

	if (GetClientPendingTeam(client) == CS_TEAM_T)
		iNumPrisoners--;

	if (iNumGuards <= 1)
		return true;

	float fNumPrisonersPerGuard = float(iNumPrisoners) / float(iNumGuards);
	if (fNumPrisonersPerGuard < gc_fPrisonerPerGuard.FloatValue)
		return false;

	int iGuardsNeeded = RoundToCeil(fNumPrisonersPerGuard - gc_fPrisonerPerGuard.FloatValue);
	if (iGuardsNeeded < 1)
		iGuardsNeeded = 1;

	int iQueueSize = GetArraySize(g_aGuardQueue);
	if (iGuardsNeeded > iQueueSize)
		return true;

	for (int i; i < iGuardsNeeded; i++)
	{
		if (!IsValidClient(i, true, true))
			continue;
		
		if (client == GetArrayCell(g_aGuardQueue, i))
			return true;
	}

	return false;
}

int GetClientPendingTeam(int client)
{
	return GetEntProp(client, Prop_Send, "m_iPendingTeamNum");
}

void SetClientPendingTeam(int client, int team)
{
	SetEntProp(client, Prop_Send, "m_iPendingTeamNum", team);
	// MinusDeath(client);
}

public Action Command_JoinTerror(int client, int args)
{
	ChangeTeam(client, CS_TEAM_T);

	return Plugin_Handled;
}

public Action Command_JoinSpec(int client, int args)
{
	ChangeTeam(client, CS_TEAM_SPECTATOR);

	return Plugin_Handled;
}

// Switch Team Menu
void ChangeTeam(int client, int team)
{
	g_hDataPackTeam = CreateDataPack();
	WritePackCell(g_hDataPackTeam, team);

	char info[255];

	Menu menu1 = CreateMenu(ChangeMenu);

	Format(info, sizeof(info), "%T", "ratio_sure", client);
	menu1.SetTitle(info);

	Format(info, sizeof(info), "%T", "ratio_no", client);
	menu1.AddItem("1", info);
	Format(info, sizeof(info), "%T", "ratio_yes", client);
	menu1.AddItem("0", info);

	menu1.ExitBackButton = true;
	menu1.ExitButton = true;
	menu1.Display(client, MENU_TIME_FOREVER);
}

// Switch Team Handler
public int ChangeMenu(Menu menu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		ResetPack(g_hDataPackTeam);
		int team = ReadPackCell(g_hDataPackTeam);

		char Item[11];
		menu.GetItem(selection, Item, sizeof(Item));

		int choice = StringToInt(Item);
		if (choice == 1)
		{
			FakeClientCommand(client, "sm_menu");
		}
		else if (choice == 0)
		{
			if (IsPlayerAlive(client))
			{
				ForcePlayerSuicide(client);
			}

			if ((GetClientTeam(client) == CS_TEAM_CT) && (GetTeamClientCount(CS_TEAM_CT) == 1) && (GetTeamClientCount(CS_TEAM_T) >= 1))
			{
				ChangeClientTeam(client, team);

				if (GetTeamClientCount(CS_TEAM_CT) == 0)
				{
					int newGuard;

					if (GetArraySize(g_aGuardQueue))
					{
						newGuard = GetArrayCell(g_aGuardQueue, 0);
						RemovePlayerFromGuardQueue(newGuard);
						CPrintToChatAll("%t %t", "ratio_tag", "ratio_find", newGuard);
					}
					else if (gc_bBalanceTerror.BoolValue)
					{
						newGuard = GetRandomClientFromTeam(CS_TEAM_T);
						CPrintToChatAll("%t %t", "ratio_tag", "ratio_random", newGuard);
					}
					else
					{
						return;
					}

					if (!IsValidClient(newGuard, true, true))
					{
						CPrintToChatAll("%t %t", "ratio_tag", "ratio_novalid");
					}

					ChangeClientTeam(newGuard, CS_TEAM_CT);
					SetClientListeningFlags(newGuard, VOICE_NORMAL);
					MinusDeath(newGuard);
				}
			}
			else
			{
				ChangeClientTeam(client, team);
			}
		}
	}
	else if (action == MenuAction_Cancel) 
	{
		if (selection == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_menu");
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}