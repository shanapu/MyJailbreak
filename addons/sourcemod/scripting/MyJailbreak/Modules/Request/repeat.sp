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


//Console Variables
ConVar gc_bRepeat;
ConVar gc_iRepeatLimit;
ConVar gc_sSoundRepeatPath;
ConVar gc_sCustomCommandRepeat;
ConVar gc_sAdminFlagRepeat;


//Booleans
bool g_bRepeated[MAXPLAYERS+1];


//Integers
int g_iRepeatCounter[MAXPLAYERS+1];


//Handles
Handle RepeatTimer[MAXPLAYERS+1];
Handle RepeatPanel;


//Strings
char g_sSoundRepeatPath[256];
char g_sCustomCommandRepeat[64];
char g_sAdminFlagRepeat[32];


//Start
public void Repeat_OnPluginStart()
{
	//Client commands
	RegConsoleCmd("sm_repeat", Command_Repeat, "Allows a Terrorist request repeat");
	
	
	//AutoExecConfig
	gc_bRepeat = AutoExecConfig_CreateConVar("sm_repeat_enable", "1", "0 - disabled, 1 - enable repeat");
	gc_sCustomCommandRepeat = AutoExecConfig_CreateConVar("sm_repeat_cmd", "what", "Set your custom chat command for Repeat. no need for sm_ or !");
	gc_iRepeatLimit = AutoExecConfig_CreateConVar("sm_repeat_limit", "2", "Сount how many times you can use the command");
	gc_sSoundRepeatPath = AutoExecConfig_CreateConVar("sm_repeat_sound", "music/MyJailbreak/repeat.mp3", "Path to the soundfile which should be played for a repeat.");
	gc_sAdminFlagRepeat = AutoExecConfig_CreateConVar("sm_repeat_flag", "a", "Set flag for admin/vip to get one more repeat. No flag = feature is available for all players!");
	
	
	//Hooks 
	HookEvent("round_start", Repeat_Event_RoundStart);
	HookConVarChange(gc_sSoundRepeatPath, Repeat_OnSettingChanged);
	HookConVarChange(gc_sCustomCommandRepeat, Repeat_OnSettingChanged);
	HookConVarChange(gc_sAdminFlagRepeat, Repeat_OnSettingChanged);
	
	
	//FindConVar
	gc_sSoundRepeatPath.GetString(g_sSoundRepeatPath, sizeof(g_sSoundRepeatPath));
	gc_sCustomCommandRepeat.GetString(g_sCustomCommandRepeat , sizeof(g_sCustomCommandRepeat));
	gc_sAdminFlagRepeat.GetString(g_sAdminFlagRepeat , sizeof(g_sAdminFlagRepeat));
}


public int Repeat_OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sSoundRepeatPath)
	{
		strcopy(g_sSoundRepeatPath, sizeof(g_sSoundRepeatPath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundRepeatPath);
	}
	else if(convar == gc_sCustomCommandRepeat)
	{
		strcopy(g_sCustomCommandRepeat, sizeof(g_sCustomCommandRepeat), newValue);
		char sBufferCMD[64];
		Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommandRepeat);
		if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
			RegConsoleCmd(sBufferCMD, Command_Repeat, "Allows a Terrorist request a repeat");
	}
	else if(convar == gc_sAdminFlagRepeat)
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
				if (RepeatTimer[client] == null)
				{
					if (g_iRepeatCounter[client] < gc_iRepeatLimit.IntValue)
					{
						g_iRepeatCounter[client]++;
						g_bRepeated[client] = true;
						CPrintToChatAll("%t %t", "request_tag", "request_repeatpls", client);
						RepeatTimer[client] = CreateTimer(10.0, Timer_RepeatEnd, client);
						if (warden_exist()) LoopClients(i) RepeatMenu(i);
						if(gc_bSounds.BoolValue)EmitSoundToAllAny(g_sSoundRepeatPath);
					}
					else CPrintToChat(client, "%t %t", "request_tag", "request_repeattimes", gc_iRepeatLimit.IntValue);
				}
				else CPrintToChat(client, "%t %t", "request_tag", "request_alreadyrepeat");
			}
			else CPrintToChat(client, "%t %t", "request_tag", "request_notalivect");
		}
	}
	return Plugin_Handled;
}


/******************************************************************************
                   EVENTS
******************************************************************************/


public Action Repeat_Event_RoundStart(Handle event, char [] name, bool dontBroadcast)
{
	LoopClients(client)
	{
		delete RepeatTimer[client];
		
		g_bRepeated[client] = false;
		g_iRepeatCounter[client] = 0;
		
		if(CheckVipFlag(client,g_sAdminFlagRepeat)) g_iRepeatCounter[client] = -1;
	}
}


/******************************************************************************
                   FORWARDS LISTENING
******************************************************************************/


public void Repeat_OnMapStart()
{
	if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundRepeatPath);
}


public void Repeat_OnConfigsExecuted()
{
	char sBufferCMDRepeat[64];
	
	Format(sBufferCMDRepeat, sizeof(sBufferCMDRepeat), "sm_%s", g_sCustomCommandRepeat);
	if(GetCommandFlags(sBufferCMDRepeat) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMDRepeat, Command_Repeat, "Allows a Terrorist request repeat");
}


public void Repeat_OnClientPutInServer(int client)
{
	g_iRepeatCounter[client] = 0;
	if(CheckVipFlag(client,g_sAdminFlagRepeat)) g_iRepeatCounter[client] = -1;
	
	g_bRepeated[client] = false;
}


public void Repeat_OnClientDisconnect(int client)
{
	delete RepeatTimer[client];
}


/******************************************************************************
                   MENUS
******************************************************************************/


public Action RepeatMenu(int warden)
{
	if (IsValidClient(warden, false, false) && warden_iswarden(warden))
	{
		char info1[255];
		RepeatPanel = CreatePanel();
		Format(info1, sizeof(info1), "%T", "request_repeat", warden);
		SetPanelTitle(RepeatPanel, info1);
		DrawPanelText(RepeatPanel, "-----------------------------------");
		DrawPanelText(RepeatPanel, "                                   ");
		for(int i = 1;i <= MaxClients;i++) if(IsValidClient(i, true))
		{
			if(g_bRepeated[i])
			{
				char userid[11];
				char username[MAX_NAME_LENGTH];
				IntToString(GetClientUserId(i), userid, sizeof(userid));
				Format(username, sizeof(username), "%N", i);
				DrawPanelText(RepeatPanel,username);
			}
		}
		DrawPanelText(RepeatPanel, "                                   ");
		DrawPanelText(RepeatPanel, "-----------------------------------");
		Format(info1, sizeof(info1), "%T", "warden_close", warden);
		DrawPanelItem(RepeatPanel, info1); 
		SendPanelToClient(RepeatPanel, warden, Handler_NullCancel, 20);
	}
}


/******************************************************************************
                   TIMER
******************************************************************************/


public Action Timer_RepeatEnd(Handle timer, any client)
{
	RepeatTimer[client] = null;
	g_bRepeated[client] = false;
}

