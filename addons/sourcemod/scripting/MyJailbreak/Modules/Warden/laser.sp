/*
 * MyJailbreak - Warden - Laser Pointer Module.
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
ConVar gc_bLaser;
ConVar gc_bLaserDeputy;
ConVar gc_sAdminFlagLaser;
ConVar gc_sCustomCommandLaser;


//Boolean
bool g_bLaserUse[MAXPLAYERS+1];
bool g_bLaser[MAXPLAYERS+1] = true;
bool g_bLaserColorRainbow[MAXPLAYERS+1] = true;


//Integers
int g_iLaserColor[MAXPLAYERS+1];


//Strings
char g_sAdminFlagLaser[32];


//Start
public void Laser_OnPluginStart()
{
	//Client commands
	RegConsoleCmd("sm_laser", Command_LaserMenu, "Allows Warden to toggle on/off the wardens Laser pointer");
	
	
	//AutoExecConfig
	gc_bLaser = AutoExecConfig_CreateConVar("sm_warden_laser", "1", "0 - disabled, 1 - enable Warden Laser Pointer with +E ", _, true,  0.0, true, 1.0);
	gc_bLaserDeputy = AutoExecConfig_CreateConVar("sm_warden_laser_deputy", "1", "0 - disabled, 1 - enable Laser Pointer for Deputy, too", _, true,  0.0, true, 1.0);
	gc_sAdminFlagLaser = AutoExecConfig_CreateConVar("sm_warden_laser_flag", "", "Set flag for admin/vip to get warden laser pointer. No flag = feature is available for all players!");
	gc_sCustomCommandLaser = AutoExecConfig_CreateConVar("sm_warden_cmds_laser", "what, rep, again", "Set your custom chat command for Laser Pointer.(!laser (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	
	
	//Hooks
	HookConVarChange(gc_sAdminFlagLaser, Laser_OnSettingChanged);
	
	
	//FindConVar
	gc_sAdminFlagLaser.GetString(g_sAdminFlagLaser , sizeof(g_sAdminFlagLaser));
}


public int Laser_OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sAdminFlagLaser)
	{
		strcopy(g_sAdminFlagLaser, sizeof(g_sAdminFlagLaser), newValue);
	}
}


/******************************************************************************
                   COMMANDS
******************************************************************************/


public Action Command_LaserMenu(int client, int args)
{
	if (gc_bLaser.BoolValue)
	{
		if (IsClientWarden(client) || (IsClientDeputy(client) && gc_bLaserDeputy.BoolValue))
		{
			if (CheckVipFlag(client, g_sAdminFlagLaser))
			{
				char menuinfo[255];
				
				Menu menu = new Menu(Handler_LaserMenu);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_laser_title", client);
				menu.SetTitle(menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_laser_off", client);
				if (g_bLaser[client]) menu.AddItem("off", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_rainbow", client);
				menu.AddItem("rainbow", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_white", client);
				menu.AddItem("white", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_red", client);
				menu.AddItem("red", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_green", client);
				menu.AddItem("green", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_blue", client);
				menu.AddItem("blue", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_yellow", client);
				menu.AddItem("yellow", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_cyan", client);
				menu.AddItem("cyan", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_magenta", client);
				menu.AddItem("magenta", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_orange", client);
				menu.AddItem("orange", menuinfo);
				
				menu.ExitBackButton = true;
				menu.ExitButton = true;
				menu.Display(client, 20);
			}
			else CReplyToCommand(client, "%t %t", "warden_tag", "warden_vipfeature");
		}
		else CReplyToCommand(client, "%t %t", "warden_tag", "warden_notwarden" );
	}
	return Plugin_Handled;
}


/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/


public Action Laser_OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if ((buttons & IN_USE) && (IsClientWarden(client) || (IsClientDeputy(client) && gc_bLaserDeputy.BoolValue)) && gc_bPlugin.BoolValue)
	{
		if (gc_bLaser.BoolValue && CheckVipFlag(client, g_sAdminFlagLaser))
		{
			if (g_bLaser[client])
			{
				g_bLaserUse[client] = true;
				if (IsClientInGame(client) && g_bLaserUse[client])
				{
					float m_fOrigin[3], m_fImpact[3];
					
					if (g_bLaserColorRainbow[client]) g_iLaserColor[client] = GetRandomInt(0, 6);
					
					GetClientEyePosition(client, m_fOrigin);
					GetClientSightEnd(client, m_fImpact);
					TE_SetupBeamPoints(m_fOrigin, m_fImpact, g_iBeamSprite, 0, 0, 0, 0.1, 0.12, 0.0, 1, 0.0, g_iColors[g_iLaserColor[client]], 0);
					TE_SendToAll();
					TE_SetupGlowSprite(m_fImpact, g_iHaloSprite, 0.1, 0.25, g_iColors[1][3] /*g_iHaloSpritecolor[3] */ );
					TE_SendToAll();
				}
			}
		}
	}
	else if (!(buttons & IN_USE))
	{
		g_bLaserUse[client] = false;
	}
}


public void Laser_OnConfigsExecuted()
{
	//Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];
	
	//Repeat
	gc_sCustomCommandLaser.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ", ", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));
	
	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  //if command not already exist
			RegConsoleCmd(sCommand, Command_LaserMenu, "Allows Warden to toggle on/off the wardens Laser pointer");
	}
}


public void Laser_OnMapStart()
{
	LoopClients(i) g_bLaser[i] = true;
}


public void Laser_OnClientPutInServer(int client)
{
	g_bLaserUse[client] = false;
	g_bLaserColorRainbow[client] = true;
}


public void Laser_OnWardenCreation(int client)
{
	g_bLaser[client] = true;
}


public void Laser_OnWardenRemoved(int client)
{
	g_bLaser[client] = false;
}


/******************************************************************************
                   MENUS
******************************************************************************/


public int Handler_LaserMenu(Menu menu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(selection, info, sizeof(info));
		
		if (strcmp(info, "off") == 0)
		{
			g_bLaser[client] = false;
			CPrintToChat(client, "%t %t", "warden_tag", "warden_laseroff");
		}
		else if (strcmp(info, "rainbow") == 0)
		{
			if (!g_bLaser[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_laseron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_laser", g_sColorNamesRainbow);
			g_bLaser[client] = true;
			g_bLaserColorRainbow[client] = true;
		}
		else if (strcmp(info, "white") == 0)
		{
			if (!g_bLaser[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_laseron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_laser", g_sColorNamesWhite);
			g_bLaser[client] = true;
			g_bLaserColorRainbow[client] = false;
			g_iLaserColor[client] = 0;
			
		}
		else if (strcmp(info, "red") == 0)
		{
			if (!g_bLaser[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_laseron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_laser", g_sColorNamesRed);
			g_bLaser[client] = true;
			g_bLaserColorRainbow[client] = false;
			g_iLaserColor[client] = 1;
			
		}
		else if (strcmp(info, "green") == 0)
		{
			if (!g_bLaser[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_laseron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_laser", g_sColorNamesGreen);
			g_bLaser[client] = true;
			g_bLaserColorRainbow[client] = false;
			g_iLaserColor[client] = 2;
			
		}
		else if (strcmp(info, "blue") == 0)
		{
			if (!g_bLaser[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_laseron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_laser", g_sColorNamesBlue);
			g_bLaser[client] = true;
			g_bLaserColorRainbow[client] = false;
			g_iLaserColor[client] = 3;
			
		}
		else if (strcmp(info, "yellow") == 0)
		{
			if (!g_bLaser[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_laseron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_laser", g_sColorNamesYellow);
			g_bLaser[client] = true;
			g_bLaserColorRainbow[client] = false;
			g_iLaserColor[client] = 4;
			
		}
		else if (strcmp(info, "cyan") == 0)
		{
			if (!g_bLaser[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_laseron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_laser", g_sColorNamesCyan);
			g_bLaser[client] = true;
			g_bLaserColorRainbow[client] = false;
			g_iLaserColor[client] = 5;
			
		}
		else if (strcmp(info, "magenta") == 0)
		{
			if (!g_bLaser[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_laseron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_laser", g_sColorNamesMagenta);
			g_bLaser[client] = true;
			g_bLaserColorRainbow[client] = false;
			g_iLaserColor[client] = 6;
			
		}
		else if (strcmp(info, "orange") == 0)
		{
			if (!g_bLaser[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_laseron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_laser", g_sColorNamesOrange);
			g_bLaser[client] = true;
			g_bLaserColorRainbow[client] = false;
			g_iLaserColor[client] = 7;
			
		}
		if (g_bMenuClose != null)
		{
			if (!g_bMenuClose)
			{
				FakeClientCommand(client, "sm_menu");
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


/******************************************************************************
                   STOCKS
******************************************************************************/


stock void GetClientSightEnd(int client, float out[3])
{
	float m_fEyes[3];
	float m_fAngles[3];
	GetClientEyePosition(client, m_fEyes);
	GetClientEyeAngles(client, m_fAngles);
	TR_TraceRayFilter(m_fEyes, m_fAngles, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitPlayers);
	if (TR_DidHit())
		TR_GetEndPosition(out);
}


public bool TraceRayDontHitPlayers(int entity, int mask, any data)
{
	if (0 < entity <= MaxClients)
		return false;
	return true;
}

