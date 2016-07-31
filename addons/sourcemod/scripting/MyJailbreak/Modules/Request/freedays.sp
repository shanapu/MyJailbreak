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
#include <myjailbreak> //... all other includes in myjailbreak.inc


//Compiler Options
#pragma semicolon 1
#pragma newdecls required


//Console Variables
ConVar gc_sCustomCommandGiveFreeDay;
ConVar gc_iFreeDayColorRed;
ConVar gc_iFreeDayColorGreen;
ConVar gc_iFreeDayColorBlue;


//Strings
char g_sCustomCommandGiveFreeDay[64];


//Start
public void Freedays_OnPluginStart()
{
	//Client Commands
	RegConsoleCmd("sm_givefreeday", Command_FreeDay, "Allows a warden to give a freeday to a player");
	
	
	//AutoExecConfig
	gc_sCustomCommandGiveFreeDay = AutoExecConfig_CreateConVar("sm_freekill_freeday_cmd", "gfd", "Set your custom chat command for give a freeday. no need for sm_ or !");
	gc_iFreeDayColorRed = AutoExecConfig_CreateConVar("sm_freekill_freeday_color_red", "0","What color to turn the warden into (set R, G and B values to 255 to disable) (Rgb): x - red value", _, true, 0.0, true, 255.0);
	gc_iFreeDayColorGreen = AutoExecConfig_CreateConVar("sm_freekill_freeday_color_green", "200","What color to turn the warden into (rGb): x - green value", _, true, 0.0, true, 255.0);
	gc_iFreeDayColorBlue = AutoExecConfig_CreateConVar("sm_freekill_freeday_color_blue", "0","What color to turn the warden into (rgB): x - blue value", _, true, 0.0, true, 255.0);
	
	
	//Hooks 
	HookEvent("round_poststart",  Freedays_Event_RoundStart_Post);
	HookEvent("player_death", Freedays_Event_PlayerDeath);
	HookConVarChange(gc_sCustomCommandGiveFreeDay, Freedays_OnSettingChanged);
	
	
	//FindConVar
	gc_sCustomCommandGiveFreeDay.GetString(g_sCustomCommandGiveFreeDay , sizeof(g_sCustomCommandGiveFreeDay));
}


public int Freedays_OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sCustomCommandGiveFreeDay)
	{
		strcopy(g_sCustomCommandGiveFreeDay, sizeof(g_sCustomCommandGiveFreeDay), newValue);
		char sBufferCMD[64];
		Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommandGiveFreeDay);
		if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
			RegConsoleCmd(sBufferCMD, Command_FreeDay, "Allows a warden to give a freeday to a player");
	}
}


/******************************************************************************
                   COMMANDS
******************************************************************************/


public Action Command_FreeDay(int warden, int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bFreeKillFreeDayVictim.BoolValue)
		{
			if (IsValidClient(warden, false, true))
			{
				char info1[255];
				Menu menu5 = CreateMenu(Handler_GiveFreeDay);
				Format(info1, sizeof(info1), "%T", "request_givefreeday", warden);
				menu5.SetTitle(info1);
				LoopValidClients(i,true,true)
				{
					if((GetClientTeam(i) == CS_TEAM_T) && !g_bHaveFreeDay[i])
					{
							char userid[11];
							char username[MAX_NAME_LENGTH];
							IntToString(GetClientUserId(i), userid, sizeof(userid));
							if(IsPlayerAlive(i))Format(username, sizeof(username), "%N", i);
							if(!IsPlayerAlive(i))Format(username, sizeof(username), "%N [†]", i);
							menu5.AddItem(userid,username);
							
					}
				}
				menu5.ExitBackButton = true;
				menu5.ExitButton = true;
				menu5.Display(warden,MENU_TIME_FOREVER);
			}
		}
	}
}


/******************************************************************************
                   EVENTS
******************************************************************************/


public Action  Freedays_Event_RoundStart_Post(Handle event, char [] name, bool dontBroadcast)
{
	char EventDay[64];
	GetEventDayName(EventDay);
	
	LoopClients(client)
	{
		g_iFreeKillCounter[client] = 0;
		g_iKilledBy[client] = 0;
		g_iHasKilled[client] = 0;
		
		if(StrEqual(EventDay, "none", false) && g_bHaveFreeDay[client])
		{
			CPrintToChatAll("%t %t", "request_tag", "request_havefreeday", client);
			SetEntityRenderColor(client, gc_iFreeDayColorRed.IntValue, gc_iFreeDayColorGreen.IntValue, gc_iFreeDayColorBlue.IntValue, 255);
			g_bHaveFreeDay[client] = false;
		}
	}
}


public Action Freedays_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int victim = GetClientOfUserId(GetEventInt(event, "userid")); // Get the dead clients id
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker")); // Get the attacker clients id
	
	if(IsValidClient(attacker, true, false) && (attacker != victim))
	{
		g_iKilledBy[victim] = attacker;
		g_iHasKilled[attacker] = victim;
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
	char sBufferCMDFreekill[64];
	
	Format(sBufferCMDFreekill, sizeof(sBufferCMDFreekill), "sm_%s", g_sCustomCommandFreekill);
	if(GetCommandFlags(sBufferCMDFreekill) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMDFreekill, Command_Freekill, "Allows a dead terrorist to report a freekill");
}


/******************************************************************************
                   MENUS
******************************************************************************/


public int Handler_GiveFreeDay(Menu menu5, MenuAction action, int client, int Position)
{
	if(action == MenuAction_Select)
	{
		char name[32];
		menu5.GetItem(Position,name,sizeof(name));
		int user = GetClientOfUserId(StringToInt(name)); 
		
		g_bHaveFreeDay[user] = true;
		CPrintToChatAll("%t %t", "warden_tag", "request_personalfreeday", user);
		CPrintToChat(user, "%t %t", "warden_tag", "request_freedayforyou");
		Command_FreeDay(client,0);
	}
	else if(action == MenuAction_Cancel)
	{
		if(Position == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_menu");
		}
	}
	else if(action == MenuAction_End)
	{
		delete menu5;
	}
}