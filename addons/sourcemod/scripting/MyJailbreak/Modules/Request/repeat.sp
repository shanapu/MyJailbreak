/*
 * MyJailbreak - Request Repeat Module.
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
#include <colors>
#include <autoexecconfig>
#include <warden>
#include <mystocks>

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Console Variables
ConVar gc_bRepeat;
ConVar gc_iRepeatLimit;
ConVar gc_sSoundRepeatPath;
ConVar gc_sCustomCommandRepeat;
ConVar gc_sAdminFlagRepeat;

// Booleans
bool g_bRepeated[MAXPLAYERS+1];

// Integers
int g_iRepeatCounter[MAXPLAYERS+1];

// Handles
Handle g_hTimerRepeat[MAXPLAYERS+1];
Handle g_hPanelRepeat;

// Strings
char g_sSoundRepeatPath[256];
char g_sAdminFlagRepeat[32];

// Start
public void Repeat_OnPluginStart()
{
	// Client commands
	RegConsoleCmd("sm_repeat", Command_Repeat, "Allows a Terrorist request repeat");

	// AutoExecConfig
	gc_bRepeat = AutoExecConfig_CreateConVar("sm_repeat_enable", "1", "0 - disabled, 1 - enable repeat");
	gc_sCustomCommandRepeat = AutoExecConfig_CreateConVar("sm_repeat_cmds", "what, rep, again", "Set your custom chat command for Repeat.(!repeat (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_iRepeatLimit = AutoExecConfig_CreateConVar("sm_repeat_limit", "2", "Сount how many times you can use the command");
	gc_sSoundRepeatPath = AutoExecConfig_CreateConVar("sm_repeat_sound", "music/MyJailbreak/repeat.mp3", "Path to the soundfile which should be played for a repeat.");
	gc_sAdminFlagRepeat = AutoExecConfig_CreateConVar("sm_repeat_flag", "a", "Set flag for admin/vip to get one more repeat. No flag = feature is available for all players!");

	// Hooks 
	HookEvent("round_start", Repeat_Event_RoundStart);
	HookConVarChange(gc_sSoundRepeatPath, Repeat_OnSettingChanged);
	HookConVarChange(gc_sAdminFlagRepeat, Repeat_OnSettingChanged);

	// FindConVar
	gc_sSoundRepeatPath.GetString(g_sSoundRepeatPath, sizeof(g_sSoundRepeatPath));
	gc_sAdminFlagRepeat.GetString(g_sAdminFlagRepeat, sizeof(g_sAdminFlagRepeat));
}

public void Repeat_OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sSoundRepeatPath)
	{
		strcopy(g_sSoundRepeatPath, sizeof(g_sSoundRepeatPath), newValue);
		if (gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundRepeatPath);
	}
	else if (convar == gc_sAdminFlagRepeat)
	{
		strcopy(g_sAdminFlagRepeat, sizeof(g_sAdminFlagRepeat), newValue);
	}
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

public Action Command_Repeat(int client, int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bRepeat.BoolValue)
		{
			if (GetClientTeam(client) == CS_TEAM_T && IsPlayerAlive(client))
			{
				if (g_hTimerRepeat[client] == null)
				{
					if (g_iRepeatCounter[client] < gc_iRepeatLimit.IntValue)
					{
						g_iRepeatCounter[client]++;
						g_bRepeated[client] = true;
						CPrintToChatAll("%t %t", "request_tag", "request_repeatpls", client);
						g_hTimerRepeat[client] = CreateTimer(10.0, Timer_RepeatEnd, client);
						if (warden_exist())
						{
							LoopClients(i) if (warden_iswarden(i) || warden_deputy_isdeputy(i)) RepeatMenu(i);
						}
						else LoopValidClients(i, false, false) if (GetClientTeam(client) == CS_TEAM_CT) RepeatMenu(i);
						
						if (gc_bSounds.BoolValue)EmitSoundToAllAny(g_sSoundRepeatPath);
					}
					else CReplyToCommand(client, "%t %t", "request_tag", "request_repeattimes", gc_iRepeatLimit.IntValue);
				}
				else CReplyToCommand(client, "%t %t", "request_tag", "request_alreadyrepeat");
			}
			else CReplyToCommand(client, "%t %t", "request_tag", "request_notalivect");
		}
	}

	return Plugin_Handled;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

public void Repeat_Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	LoopClients(client)
	{
		delete g_hTimerRepeat[client];
		
		g_bRepeated[client] = false;
		g_iRepeatCounter[client] = 0;
		
		if (CheckVipFlag(client, g_sAdminFlagRepeat)) g_iRepeatCounter[client] = -1;
	}
}

/******************************************************************************
                   FORWARDS LISTENING
******************************************************************************/

public void Repeat_OnMapStart()
{
	if (gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundRepeatPath);
}

public void Repeat_OnConfigsExecuted()
{
	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// Repeat
	gc_sCustomCommandRepeat.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  // if command not already exist
			RegConsoleCmd(sCommand, Command_Repeat, "Allows a Terrorist request repeat");
	}
}

public void Repeat_OnClientPutInServer(int client)
{
	g_iRepeatCounter[client] = 0;
	if (CheckVipFlag(client, g_sAdminFlagRepeat)) g_iRepeatCounter[client] = -1;

	g_bRepeated[client] = false;
}


public void Repeat_OnClientDisconnect(int client)
{
	delete g_hTimerRepeat[client];
}


/******************************************************************************
                   MENUS
******************************************************************************/


void RepeatMenu(int client)
{
	char info1[255];

	g_hPanelRepeat = CreatePanel();
	Format(info1, sizeof(info1), "%T", "request_repeat", client);
	SetPanelTitle(g_hPanelRepeat, info1);
	DrawPanelText(g_hPanelRepeat, "-----------------------------------");
	DrawPanelText(g_hPanelRepeat, "                                   ");
	for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true))
	{
		if (g_bRepeated[i])
		{
			char userid[11];
			char username[MAX_NAME_LENGTH];
			IntToString(GetClientUserId(i), userid, sizeof(userid));
			Format(username, sizeof(username), "%N", i);
			DrawPanelText(g_hPanelRepeat, username);
		}
	}
	DrawPanelText(g_hPanelRepeat, "                                   ");
	DrawPanelText(g_hPanelRepeat, "-----------------------------------");
	Format(info1, sizeof(info1), "%T", "request_close", client);
	DrawPanelItem(g_hPanelRepeat, info1);
	SendPanelToClient(g_hPanelRepeat, client, Handler_NullCancel, 20);
}

/******************************************************************************
                   TIMER
******************************************************************************/

public Action Timer_RepeatEnd(Handle timer, any client)
{
	g_hTimerRepeat[client] = null;
	g_bRepeated[client] = false;
}