/*
 * MyJailbreak - Player HUD Plugin.
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
#include <myjailbreak>

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Booleans
bool g_bIsLateLoad = false;

// Console Variables
ConVar gc_bPlugin;
ConVar gc_sCustomCommandHUD;

// Booleans
g_bEnableHud[MAXPLAYERS+1] = true;

// Info
public Plugin myinfo =
{
	name = "MyJailbreak - Player HUD",
	description = "A player HUD to display game informations",
	author = "shanapu",
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_bIsLateLoad = late;

	return APLRes_Success;
}

// Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.HUD.phrases");

	RegConsoleCmd("sm_hud", Command_HUD, "Allows player to toggle the hud display.");

	// AutoExecConfig
	AutoExecConfig_SetFile("HUD", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);

	AutoExecConfig_CreateConVar("sm_hud_version", MYJB_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_hud_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true, 0.0, true, 1.0);
	gc_sCustomCommandHUD = AutoExecConfig_CreateConVar("sm_hud_cmds", "HUD", "Set your custom chat commands for toggle HUD(!hud (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks - Events to check for Tag
	HookEvent("player_death", Event_PlayerTeamDeath);
	HookEvent("player_team", Event_PlayerTeamDeath);

	// Late loading
	if (g_bIsLateLoad)
	{
		LoopClients(i)
		{
			OnClientPutInServer(i);
		}

		g_bIsLateLoad = false;
	}
}

// Initialize Plugin
public void OnConfigsExecuted()
{
	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// HUd
	gc_sCustomCommandHUD.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  // if command not already exist
		{
			RegConsoleCmd(sCommand, Command_HUD, "Allows player to toggle the hud display.");
		}
	}
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

// Toggle hud
public Action Command_HUD(int client, int args)
{
	if (!g_bEnableHud[client])
	{
		g_bEnableHud[client] = true;
		CReplyToCommand(client, "%t %t", "hud_tag", "hud_on");
	}
	else
	{
		g_bEnableHud[client] = false;
		CReplyToCommand(client, "%t %t", "hud_tag", "hud_off");
	}

	return Plugin_Handled;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

// Warden change Team
public void Event_PlayerTeamDeath(Event event, const char[] name, bool dontBroadcast)
{
	ShowHUD();
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

// Prepare Plugin & modules
public void OnMapStart()
{
	if (gc_bPlugin.BoolValue)
	{
		CreateTimer(1.0, Timer_ShowHUD, _, TIMER_REPEAT);
	}
}

public void OnClientPutInServer(int client)
{
	g_bEnableHud[client] = true;
}

public void warden_OnWardenCreatedByUser(int client)
{
	ShowHUD();
}

public void warden_OnWardenCreatedByAdmin(int client)
{
	ShowHUD();
}

public void warden_OnWardenRemoved(int client)
{
	ShowHUD();
}

/******************************************************************************
                   TIMER
******************************************************************************/

public Action Timer_ShowHUD(Handle timer, Handle pack)
{
	ShowHUD();
}

/******************************************************************************
                   FUNCTIONS
******************************************************************************/

void ShowHUD()
{
	int warden = warden_get();
	int aliveCT = GetAliveTeamCount(CS_TEAM_CT);
	int allCT = GetTeamClientCount(CS_TEAM_CT);
	int aliveT = GetAliveTeamCount(CS_TEAM_T);
	int allT = GetTeamClientCount(CS_TEAM_T);

	char EventDay[64];
	MyJailbreak_GetEventDayName(EventDay);

	if (gc_bPlugin.BoolValue)
	{
		LoopValidClients(i, false, true)
		{
			if (g_bEnableHud[i])
			{
				if (MyJailbreak_IsLastGuardRule())
				{
					int lastCT = GetLastAlive(CS_TEAM_CT);

					if (lastCT != -1)
					{
						if (MyJailbreak_IsEventDayPlanned())
						{
							PrintHintText(i, "<font face='Arial' color='#006699'>%t </font>%N</font>\n<font face='Arial' color='#B980EF'>%t</font> %s\n<font color='#5E97D8'>%t</font> %i/%i\t<font color='#E3AD39'>%t</font> %i/%i\n", "hud_lastCT", lastCT, "hud_planned", EventDay, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
						}
						else
						{
							PrintHintText(i, "<font face='Arial' color='#006699'>%t </font>%N</font>\n<font color='#5E97D8'>%t</font> %i/%i\t<font color='#E3AD39'>%t</font> %i/%i\n", "hud_lastCT", lastCT, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
						}
					}
				}
				else if (MyJailbreak_IsEventDayRunning())
				{
					PrintHintText(i, "<font face='Arial' color='#B980EF'>%t </font>%s\n<font color='#5E97D8'>%t</font> %i/%i\t<font color='#E3AD39'>%t</font> %i/%i\n", "hud_running", EventDay, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
				}
				else if (warden == -1)
				{
					if (MyJailbreak_IsEventDayPlanned())
					{
						PrintHintText(i, "<font face='Arial' color='#006699'>%t </font><font face='Arial' color='#FE4040'>%t</font>\n<font color='#B980EF'>%t</font> %s\n<font color='#5E97D8'>%t</font> %i/%i\t<font color='#E3AD39'>%t</font> %i/%i", "hud_warden", "hud_nowarden", "hud_planned", EventDay, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
					}
					else
					{
						PrintHintText(i, "<font face='Arial' color='#006699'>%t </font><font face='Arial' color='#FE4040'>%t</font>\n<font color='#5E97D8'>%t</font> %i/%i\t<font color='#E3AD39'>%t</font> %i/%i\n", "hud_warden", "hud_nowarden", "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
					}
				}
				else
				{
					if (MyJailbreak_IsEventDayPlanned())
					{
						PrintHintText(i, "<font face='Arial' color='#006699'>%t </font>%N\n<font face='Arial' color='#B980EF'>%t</font> %s\n<font color='#5E97D8'>%t</font> %i/%i\t<font color='#E3AD39'>%t</font> %i/%i\n", "hud_warden", warden, "hud_planned", EventDay, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
					}
					else
					{
						PrintHintText(i, "<font face='Arial' color='#006699'>%t </font>%N\n<font color='#5E97D8'>%t</font> %i/%i\t<font color='#E3AD39'>%t</font> %i/%i\n", "hud_warden", warden, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
					}
				}
			}
		}
	}
}