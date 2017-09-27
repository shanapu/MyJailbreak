/*
 * MyJailbreak - Warden - Withheld Last Request Module.
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
#include <colors>
#include <autoexecconfig>
#include <warden>
#include <mystocks>

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

bool g_bIsNoLR = false;

// Console Variables
ConVar gc_bNoLR;
ConVar gc_bNoLRDeputy;
ConVar gc_sCustomCommandNoLR;
ConVar gc_sCustomCommandLR;

Handle g_aLRcmds;

// Start
public void NoLR_OnPluginStart()
{
	// Client commands
	RegConsoleCmd("sm_nolastrequest", Command_NoLR, "Allows the Warden to witheld the last request");

	// AutoExecConfig
	gc_bNoLR = AutoExecConfig_CreateConVar("sm_warden_withheld_lr_enable", "1", "0 - disabled, 1 - warden can witheld prisoners Last request commands (need sm_hosties_lr_autodisplay = 0", _, true, 0.0, true, 1.0);
	gc_bNoLRDeputy = AutoExecConfig_CreateConVar("sm_warden_withheld_lr_deputy", "1", "0 - disabled, 1 - deputy can witheld prisoners Last request commands", _, true, 0.0, true, 1.0);
	gc_sCustomCommandNoLR = AutoExecConfig_CreateConVar("sm_warden_cmds_withheld_lr", "nolr, noLR", "Set your custom chat commands for witheld Last request(!nolastrequest (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands)");
	gc_sCustomCommandLR = AutoExecConfig_CreateConVar("sm_warden_cmds_lr", "lr,lastrequest,lr,lastrequest,", "Set your last request commands (add custom !lr cmds)(no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands)");

	// Hooks
	AddCommandListener(NoLR_Event_Say, "say");
	AddCommandListener(NoLR_Event_Say, "say_team");
	HookEvent("round_start", NoLR_Event_RoundStart);

	g_aLRcmds = CreateArray(16);
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

public Action Command_NoLR(int client, int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bNoLR.BoolValue)
		{
			if (IsClientWarden(client) || (IsClientDeputy(client) && gc_bNoLRDeputy.BoolValue))
			{
				if (g_bIsNoLR)
				{
					g_bIsNoLR = false;
					CPrintToChatAll("%t %t", "warden_tag", "warden_withhold_off");
				}
				else
				{
					g_bIsNoLR = true;
					CPrintToChatAll("%t %t", "warden_tag", "warden_withhold_on");
				}
			}
			else CReplyToCommand(client, "%t %t", "warden_tag", "warden_notwarden");
		}
	}

	return Plugin_Handled;
}


/******************************************************************************
                   EVENTS
******************************************************************************/

public void NoLR_Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_bIsNoLR = false;
}

/******************************************************************************
                   FORWARDS LISTENING
******************************************************************************/

public void NoLR_OnConfigsExecuted()
{
	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// NoLR
	gc_sCustomCommandNoLR.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  // if command not already exist
			RegConsoleCmd(sCommand, Command_NoLR, "Allows the Warden to witheld the last request");
	}

	// Custom Last request commands
	gc_sCustomCommandLR.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	ClearArray(g_aLRcmds);

	for (int i = 0; i < iCount; i++)
	{
		PushArrayString(g_aLRcmds, sCommandsL[i]);
	}
}

//Tested all ways I can imagine. I#m dumb?!
//I don't get it. It won't work. I don't know why. I'm too confused. I going to sleep. 


public Action NoLR_Event_Say(int client, char[] command, int args)
{
	if(!g_bIsNoLR || !gc_bNoLR.BoolValue || !gc_bPlugin.BoolValue)
		return Plugin_Continue;

	char sBuffer[32];
	GetCmdArg(1, sBuffer, sizeof(sBuffer));

	CPrintToChat(client, "%t NoLR_Event_Say - command : %s - args: %i - buffer: %s", "warden_tag", command, args, sBuffer);

	if (FindStringInArray(g_aLRcmds, sBuffer) != -1)
	{
		CPrintToChat(client, "%t %t", "warden_tag", "warden_withhold_lr");
		return Plugin_Handled;
	}

	return Plugin_Continue;
}


//https://forums.alliedmods.net/showpost.php?p=2077110&postcount=10
public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if(!g_bIsNoLR || !gc_bNoLR.BoolValue || !gc_bPlugin.BoolValue)
		return Plugin_Continue;

	CPrintToChat(client, "%t OnClientSayCommand - command : %s - args: %s", "warden_tag", command, sArgs);

	if (FindStringInArray(g_aLRcmds, sArgs) != -1)
	{
		CPrintToChat(client, "%t %t", "warden_tag", "warden_withhold_lr");
		return Plugin_Stop; ///also return Plugin_Handled;
	}

	return Plugin_Continue;
}
