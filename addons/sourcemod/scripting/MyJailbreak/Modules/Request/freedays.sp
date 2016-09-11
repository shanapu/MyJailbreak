/*
 * MyJailbreak - Request - Freedays Module.
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
#include <colors>
#include <autoexecconfig>
#include <warden>
#include <mystocks>
#include <myjailbreak>


//Compiler Options
#pragma semicolon 1
#pragma newdecls required


//Console Variables
ConVar gc_sCustomCommandGiveFreeDay;
ConVar gc_bFreeDayDeputy;
ConVar gc_iFreeDayColorRed;
ConVar gc_iFreeDayColorGreen;
ConVar gc_iFreeDayColorBlue;


//Start
public void Freedays_OnPluginStart()
{
	//Client Commands
	RegConsoleCmd("sm_givefreeday", Command_FreeDay, "Allows a warden to give a freeday to a player");
	
	
	//AutoExecConfig
	gc_sCustomCommandGiveFreeDay = AutoExecConfig_CreateConVar("sm_freekill_cmds_freeday", "gfd, setfreeday, sfd", "Set your custom chat command for give a freeday(!givefreeday (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_iFreeDayColorRed = AutoExecConfig_CreateConVar("sm_freekill_freeday_color_red", "0", "What color to turn the warden into (set R, G and B values to 255 to disable) (Rgb): x - red value", _, true, 0.0, true, 255.0);
	gc_iFreeDayColorGreen = AutoExecConfig_CreateConVar("sm_freekill_freeday_color_green", "200", "What color to turn the warden into (rGb): x - green value", _, true, 0.0, true, 255.0);
	gc_iFreeDayColorBlue = AutoExecConfig_CreateConVar("sm_freekill_freeday_color_blue", "0", "What color to turn the warden into (rgB): x - blue value", _, true, 0.0, true, 255.0);
	gc_bFreeDayDeputy= AutoExecConfig_CreateConVar("sm_freekill_freeday_victim_deputy", "1", "0 - disabled, 1 - Allow the deputy to set a personal freeday next round");
	
	
	//Hooks 
	HookEvent("round_poststart",  Freedays_Event_RoundStart_Post);
}


/******************************************************************************
                   COMMANDS
******************************************************************************/


public Action Command_FreeDay(int client, int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bFreeKillFreeDayVictim.BoolValue)
		{
			if (warden_iswarden(client) || (warden_deputy_isdeputy(client) && gc_bFreeDayDeputy.BoolValue))
			{
				char info1[255];
				Menu menu5 = CreateMenu(Handler_GiveFreeDay);
				Format(info1, sizeof(info1), "%T", "request_givefreeday", client);
				menu5.SetTitle(info1);
				LoopValidClients(i, true, true)
				{
					if ((GetClientTeam(i) == CS_TEAM_T) && !g_bHaveFreeDay[i])
					{
							char userid[11];
							char username[MAX_NAME_LENGTH];
							IntToString(GetClientUserId(i), userid, sizeof(userid));
							if (IsPlayerAlive(i))Format(username, sizeof(username), "%N", i);
							if (!IsPlayerAlive(i))Format(username, sizeof(username), "%N [†]", i);
							menu5.AddItem(userid, username);
							
					}
				}
				menu5.ExitBackButton = true;
				menu5.ExitButton = true;
				menu5.Display(client, MENU_TIME_FOREVER);
			}
			else CReplyToCommand(client, "%t %t", "warden_tag" , "warden_notwarden"); 
		}
	}
	return Plugin_Handled;
}


/******************************************************************************
                   EVENTS
******************************************************************************/


public void Freedays_Event_RoundStart_Post(Event event, char [] name, bool dontBroadcast)
{
	char EventDay[64];
	GetEventDayName(EventDay);
	
	LoopClients(client)
	{
		g_iFreeKillCounter[client] = 0;
		
		if (StrEqual(EventDay, "none", false) && g_bHaveFreeDay[client])
		{
			CPrintToChatAll("%t %t", "request_tag", "request_havefreeday", client);
			SetEntityRenderColor(client, gc_iFreeDayColorRed.IntValue, gc_iFreeDayColorGreen.IntValue, gc_iFreeDayColorBlue.IntValue, 255);
			g_bHaveFreeDay[client] = false;
		}
	}
}


/******************************************************************************
                   FORWARDS LISTENING
******************************************************************************/


public void Freedays_OnMapStart()
{
	LoopClients(client) g_bHaveFreeDay[client] = false;
}


public void Freedays_OnConfigsExecuted()
{
	//Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];
	
	//Give freeday
	gc_sCustomCommandGiveFreeDay.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));
	
	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  //if command not already exist
			RegConsoleCmd(sCommand, Command_FreeDay, "Allows a warden to give a freeday to a player");
	}
}


/******************************************************************************
                   MENUS
******************************************************************************/


public int Handler_GiveFreeDay(Menu menu5, MenuAction action, int client, int Position)
{
	if (action == MenuAction_Select)
	{
		char name[32];
		menu5.GetItem(Position, name, sizeof(name));
		int user = GetClientOfUserId(StringToInt(name)); 
		
		g_bHaveFreeDay[user] = true;
		CPrintToChatAll("%t %t", "warden_tag", "request_personalfreeday", user);
		CPrintToChat(user, "%t %t", "warden_tag", "request_freedayforyou");
		Command_FreeDay(client, 0);
	}
	else if (action == MenuAction_Cancel)
	{
		if (Position == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_menu");
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu5;
	}
}