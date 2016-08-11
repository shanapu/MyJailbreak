/*
 * MyJailbreak - Request - Heal Module.
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
ConVar gc_bHeal;
ConVar gc_bHealthShot;
ConVar gc_fHealTime;
ConVar gc_iHealLimit;
ConVar gc_bHealthCheck;
ConVar gc_iHealColorRed;
ConVar gc_iHealColorGreen;
ConVar gc_iHealColorBlue;
ConVar gc_sCustomCommandHeal;
ConVar gc_sAdminFlagHeal;


//Booleans
bool g_bHealed[MAXPLAYERS+1];


//Integers
int g_iHealCounter[MAXPLAYERS+1];


//Handles
Handle HealTimer[MAXPLAYERS+1];


//Strings
char g_sCustomCommandHeal[64];
char g_sAdminFlagHeal[32];


//Start
public void Heal_OnPluginStart()
{
	//Client commands
	RegConsoleCmd("sm_heal", Command_Heal, "Allows a Terrorist request healing");
	
	
	//AutoExecConfig
	gc_bHeal = AutoExecConfig_CreateConVar("sm_heal_enable", "1", "0 - disabled, 1 - enable heal");
	gc_sCustomCommandHeal = AutoExecConfig_CreateConVar("sm_heal_cmd", "cure", "Set your custom chat command for Heal. no need for sm_ or !");
	gc_bHealthShot = AutoExecConfig_CreateConVar("sm_heal_healthshot", "1", "0 - disabled, 1 - enable give healthshot on accept to terror");
	gc_bHealthCheck = AutoExecConfig_CreateConVar("sm_heal_check", "1", "0 - disabled, 1 - enable check if player is already full health");
	gc_iHealLimit = AutoExecConfig_CreateConVar("sm_heal_limit", "2", "Сount how many times you can use the command");
	gc_fHealTime = AutoExecConfig_CreateConVar("sm_heal_time", "10.0", "Time after the player gets his normal colors back");
	gc_iHealColorRed = AutoExecConfig_CreateConVar("sm_heal_color_red", "240","What color to turn the heal Terror into (set R, G and B values to 255 to disable) (Rgb): x - red value", _, true, 0.0, true, 255.0);
	gc_iHealColorGreen = AutoExecConfig_CreateConVar("sm_heal_color_green", "0","What color to turn the heal Terror into (rGb): x - green value", _, true, 0.0, true, 255.0);
	gc_iHealColorBlue = AutoExecConfig_CreateConVar("sm_heal_color_blue", "100","What color to turn the heal Terror into (rgB): x - blue value", _, true, 0.0, true, 255.0);
	gc_sAdminFlagHeal = AutoExecConfig_CreateConVar("sm_repeat_flag", "a", "Set flag for admin/vip to get one more heal. No flag = feature is available for all players!");
	
	
	//Hooks 
	HookEvent("round_start", Heal_Event_RoundStart);
	HookConVarChange(gc_sCustomCommandHeal, Heal_OnSettingChanged);
	HookConVarChange(gc_sAdminFlagHeal, Heal_OnSettingChanged);
	
	
	//FindConVar
	gc_sCustomCommandHeal.GetString(g_sCustomCommandHeal , sizeof(g_sCustomCommandHeal));
	gc_sAdminFlagHeal.GetString(g_sAdminFlagHeal , sizeof(g_sAdminFlagHeal));
}


public int Heal_OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sCustomCommandHeal)
	{
		strcopy(g_sCustomCommandHeal, sizeof(g_sCustomCommandHeal), newValue);
		char sBufferCMD[64];
		Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommandHeal);
		if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
			RegConsoleCmd(sBufferCMD, Command_Heal, "Allows a Terrorist request a healing");
	}
	else if(convar == gc_sAdminFlagHeal)
	{
		strcopy(g_sAdminFlagHeal, sizeof(g_sAdminFlagHeal), newValue);
	}
}


/******************************************************************************
                   COMMANDS
******************************************************************************/


//heal
public Action Command_Heal(int client, int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bHeal.BoolValue)
		{
			if (GetClientTeam(client) == CS_TEAM_T && (IsPlayerAlive(client)))
			{
				if (HealTimer[client] == null)
				{
					if (g_iHealCounter[client] < gc_iHealLimit.IntValue)
					{
						if (warden_exist())
						{
							if((GetClientHealth(client) < 100) || !gc_bHealthCheck.BoolValue)
							{
								if(!IsRequest)
								{
									IsRequest = true;
									RequestTimer = CreateTimer (gc_fHealTime.FloatValue, Timer_IsRequest);
									g_bHealed[client] = true;
									g_iHealCounter[client]++;
									CPrintToChatAll("%t %t", "request_tag", "request_heal", client);
									SetEntityRenderColor(client, gc_iHealColorRed.IntValue, gc_iHealColorGreen.IntValue, gc_iHealColorBlue.IntValue, 255);
									HealTimer[client] = CreateTimer(gc_fHealTime.FloatValue, Timer_ResetColorHeal, client);
									LoopClients(i) HealMenu(i);
								}
								else CPrintToChat(client, "%t %t", "request_tag", "request_processing");
							}
							else CPrintToChat(client, "%t %t", "request_tag", "request_fullhp");
						}
						else CPrintToChat(client, "%t %t", "request_tag", "warden_noexist");
					}
					else CPrintToChat(client, "%t %t", "request_tag", "request_healtimes", gc_iHealLimit.IntValue);
				}
				else CPrintToChat(client, "%t %t", "request_tag", "request_alreadyhealed");
			}
			else CPrintToChat(client, "%t %t", "request_tag", "request_notalivect");
		}
	}
	return Plugin_Handled;
}


/******************************************************************************
                   EVENTS
******************************************************************************/


public void Heal_Event_RoundStart(Event event, char [] name, bool dontBroadcast)
{
	LoopClients(client)
	{
		delete HealTimer[client];
		
		g_iHealCounter[client] = 0;
		g_bHealed[client] = false;
		
		if(CheckVipFlag(client,g_sAdminFlagHeal)) g_iHealCounter[client] = -1;
	}
}


/******************************************************************************
                   FORWARDS LISTENING
******************************************************************************/


public void Heal_OnConfigsExecuted()
{
	char sBufferCMDHeal[64];
	
	Format(sBufferCMDHeal, sizeof(sBufferCMDHeal), "sm_%s", g_sCustomCommandHeal);
	if(GetCommandFlags(sBufferCMDHeal) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMDHeal, Command_Heal, "Allows a Terrorist request healing");
}

public void Heal_OnClientPutInServer(int client)
{
	g_iHealCounter[client] = 0;
	if(CheckVipFlag(client,g_sAdminFlagHeal)) g_iHealCounter[client] = -1;
	g_bHealed[client] = false;
}

public void Heal_OnClientDisconnect(int client)
{
	delete HealTimer[client];
}


/******************************************************************************
                   MENUS
******************************************************************************/


public Action HealMenu(int warden)
{
	if (IsValidClient(warden, false, false) && warden_iswarden(warden))
	{
		char info5[255], info6[255], info7[255];
		Menu menu1 = CreateMenu(HealMenuHandler);
		Format(info5, sizeof(info5), "%T", "request_acceptheal", warden);
		menu1.SetTitle(info5);
		Format(info6, sizeof(info6), "%T", "warden_no", warden);
		Format(info7, sizeof(info7), "%T", "warden_yes", warden);
		menu1.AddItem("1", info7);
		menu1.AddItem("0", info6);
		menu1.Display(warden,gc_fHealTime.IntValue);
	}
}


public int HealMenuHandler(Menu menu, MenuAction action, int client, int Position)
{
	if(action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position,Item,sizeof(Item));
		int choice = StringToInt(Item);
		if(choice == 1)
		{
			LoopClients(i) if(g_bHealed[i])
			{
				IsRequest = false;
				RequestTimer = null;
				if(gc_bHealthShot.BoolValue) GivePlayerItem(i, "weapon_healthshot");
				CPrintToChat(i, "%t %t", "request_tag", "request_health");
				CPrintToChatAll("%t %t", "warden_tag", "request_accepted", i, client);
			}
		}
		if(choice == 0)
		{
			IsRequest = false;
			RequestTimer = null;
			LoopClients(i) if(g_bHealed[i])
			{
				CPrintToChatAll("%t %t", "warden_tag", "request_noaccepted", i, client);
			}
		}
	}
}



/******************************************************************************
                   TIMER
******************************************************************************/


public Action Timer_ResetColorHeal(Handle timer, any client)
{
	if (IsClientConnected(client))
	{
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
	HealTimer[client] = null;
	g_bHealed[client] = false;
}