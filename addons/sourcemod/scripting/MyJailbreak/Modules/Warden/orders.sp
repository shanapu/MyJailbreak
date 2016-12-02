/*
 * MyJailbreak - Warden - Orders Warden Module.
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
#include <autoexecconfig>
#include <emitsoundany>
#include <warden>
#include <mystocks>


//Compiler Options
#pragma semicolon 1
#pragma newdecls required


//Console Variables
ConVar gc_sCustomCommandMenu;
ConVar gc_bOrders;
ConVar gc_bOrdersDeputy;


//Strings
char g_sMenuFile[64];
char g_sCurrentMap[64];


//Info
public void Orders_OnPluginStart()
{
	RegConsoleCmd("sm_order", Command_OrderMenu, "opens the order menu");
	
	//AutoExecConfig
	gc_bOrders = AutoExecConfig_CreateConVar("sm_warden_orders", "1", "0 - disabled, 1 - enable allow warden to use the orders menu", _, true,  0.0, true, 1.0);
	gc_bOrdersDeputy = AutoExecConfig_CreateConVar("sm_warden_orders_deputy", "1", "0 - disabled, 1 - enable orders-feature for deputy, too", _, true,  0.0, true, 1.0);
	gc_sCustomCommandMenu = CreateConVar("sm_warden_cmds_orders", "order", "Set your custom chat command for open menu(!menu (no 'sm_'/'!')(seperate with comma ',')(max. 12 commands))");
	
	BuildPath(Path_SM, g_sMenuFile, sizeof(g_sMenuFile), "configs/MyJailbreak/orders.cfg");
	
//	AddCommandListener(Event_Say, "say");
//	AddCommandListener(Event_Say, "say_team");
}


/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/


public void Orders_OnMapStart()
{
	GetCurrentMap(g_sCurrentMap, sizeof(g_sCurrentMap));
	
	Handle hFile = OpenFile(g_sMenuFile, "rt");
	if (!hFile)
	{
		SetFailState("MyJailbreak Warden - Can't open File: %s", g_sMenuFile);
		// return Plugin_Handled;
	}
	
	KeyValues kvMenu = CreateKeyValues("Menu");
	
	if (!kvMenu.ImportFromFile(g_sMenuFile))
	{
		SetFailState("MyJailbreak Warden - Can't read %s correctly! (ImportFromFile)", g_sMenuFile);
	}
	if (!kvMenu.GotoFirstSubKey())
	{
		SetFailState("MyJailbreak Warden - Can't read %s correctly! (GotoFirstSubKey)", g_sMenuFile);
	}
	do
	{
		char sSound[64];
		char sOverlay[64];
		
		kvMenu.GetString("overlay", sOverlay, sizeof(sOverlay));
		kvMenu.GetString("sound", sSound, sizeof(sSound));
		if (strlen(sOverlay) > 0)PrecacheDecalAnyDownload(sOverlay);
		if (strlen(sSound) > 0)PrecacheSoundAnyDownload(sSound);
	}
	while (kvMenu.GotoNextKey());
}


// char g_sCommand[][128]; // some vale  todo


public void Orders_OnConfigsExecuted()
{
	//Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][64], sCommand[64];
	
	//Menu
	gc_sCustomCommandMenu.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));
	
	for(int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  //if command not already exist
			RegConsoleCmd(sCommand, Command_OrderMenu, "opens the menu");
	}
	/*
	
	Handle hFile = OpenFile(g_sMenuFile, "rt");
	if (!hFile)
	{
		SetFailState("MyJailbreak Warden - Can't open File: %s", g_sMenuFile);
		// return Plugin_Handled;
	}
	
	KeyValues kvMenu = CreateKeyValues("Menu");
	
	if (!kvMenu.ImportFromFile(g_sMenuFile))
	{
		SetFailState("MyJailbreak Warden - Can't read %s correctly! (ImportFromFile)", g_sMenuFile);
	}
	if (!kvMenu.GotoFirstSubKey())
	{
		SetFailState("MyJailbreak Warden - Can't read %s correctly! (GotoFirstSubKey)", g_sMenuFile);
	}
	do
	{
		char sNumber[4];
		int num = StringToInt(sNumber);
		
		kvMenu.GetSectionName(sNumber, sizeof(sNumber));
		kvMenu.GetString("commands", sCommands, sizeof(sCommands));
		
		Format(g_sCommand[num], sizeof(sCommands), sCommands);
	}
	while (kvMenu.GotoNextKey());
	*/
}

/*
public Action Event_Say(int client, char [] command,int arg)
{
	//listen for custom order commands
	
	char text[24];
	GetCmdArgString(text, sizeof(text));
	StripQuotes(text);
	TrimString(text);
	
	
	for(int i = 0; i < sizeof(g_sCommand); i++)
	{
		if (StrEqual(text, g_sCommand[i], false))
		{
			PrintToChatAll("Hello world %i", i+1);
			char num[4];
			IntToString(i+1,num,sizeof(num));
			Command_Handler(num);
		}
	}
	
}
*/

public Action Command_Handler(char [] number)
{
		Handle hFile = OpenFile(g_sMenuFile, "rt");
		
		if (hFile)
		{
			KeyValues kvMenu = CreateKeyValues("Menu");
			
			if (!kvMenu.ImportFromFile(g_sMenuFile))
			{
				SetFailState("MyJailbreak Warden - Can't read %s correctly! (ImportFromFile)", g_sMenuFile);
				delete kvMenu;
			}
			
			if (kvMenu.JumpToKey(number, false))
			{
				char sValue[PLATFORM_MAX_PATH];
				
				kvMenu.GetString("chat", sValue, sizeof(sValue));
				if (strlen(sValue) > 0)
				{
					CPrintToChatAll("%t %s", "warden_tag", sValue);
				}
				
				kvMenu.GetString("HUD", sValue, sizeof(sValue));
				if (strlen(sValue) > 0)
				{
					PrintCenterTextAll("%s", sValue);
				}
				
				kvMenu.GetString("overlay", sValue, sizeof(sValue));
				if (strlen(sValue) > 0)
				{
					char sTime[12];
					char sTeam[6];
					char szTeam[4][6];
					kvMenu.GetString("overlay_time", sTime, sizeof(sTime));
					kvMenu.GetString("overlay_team", sTeam, sizeof(sTeam));
					
					ReplaceString(sTeam, sizeof(sTeam), " ", "");
					int iCount = ExplodeString(sTeam, ",", szTeam, sizeof(szTeam), sizeof(szTeam[]));
					
					for (int iTeam = 0; iTeam < iCount; iTeam++)
					{
						LoopValidClients(i, false, false)
						if (GetClientTeam(i) == StringToInt(szTeam[iTeam])) ShowOverlay(i ,sValue, StringToFloat(sTime));
					}
				}
				
				kvMenu.GetString("sound", sValue, sizeof(sValue));
				if (strlen(sValue) > 0)
				{
					EmitSoundToAllAny(sValue);
				}
			}
		}
		else SetFailState("MyJailbreak Warden - Can't open File: %s", g_sMenuFile);
	
}

/******************************************************************************
                   COMMANDS
******************************************************************************/


public Action Command_OrderMenu(int client, int iItem)
{
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bOrders.BoolValue)
		{
			if (IsClientWarden(client) || (IsClientDeputy(client) && gc_bOrdersDeputy.BoolValue))
			{
				Menu_BuildOrderMenu(client);
			}
			else CReplyToCommand(client, "%t %t", "warden_tag" , "warden_notwarden"); 
		}
	}
	return Plugin_Handled;
}


/******************************************************************************
                   MENUS
******************************************************************************/


public Action Menu_BuildOrderMenu(int client)
{
	char sText[512];
	Format(sText, sizeof(sText), "Menu");
	
	Menu menu = new Menu(Handler_Menu);
	menu.SetTitle(sText);
	
	Handle hFile = OpenFile(g_sMenuFile, "rt");
	
	if (!hFile)
	{
		SetFailState("MyJailbreak Warden - Can't open File: %s", g_sMenuFile);
		// return Plugin_Handled;
	}
	
	KeyValues kvMenu = CreateKeyValues("Menu");
	
	if (!kvMenu.ImportFromFile(g_sMenuFile))
	{
		SetFailState("MyJailbreak Warden - Can't read %s correctly! (ImportFromFile)", g_sMenuFile);
		return Plugin_Handled;
	}
	if (!kvMenu.GotoFirstSubKey())
	{
		SetFailState("MyJailbreak Warden - Can't read %s correctly! (GotoFirstSubKey)", g_sMenuFile);
		return Plugin_Handled;
	}
	do
	{
		char sNumber[4];
		char sTitle[64];
		char sMaps[PLATFORM_MAX_PATH];
		
		kvMenu.GetSectionName(sNumber, sizeof(sNumber));
		kvMenu.GetString("title", sTitle, sizeof(sTitle));
		kvMenu.GetString("maps", sMaps, sizeof(sMaps));
		
		if ((StrContains(sMaps, g_sCurrentMap, true) == -1) && (strlen(sTitle) > 0))
		{
			menu.AddItem(sNumber, sTitle);
		}
	}
	while (kvMenu.GotoNextKey());
	
	if (kvMenu)
	{
		delete kvMenu;
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	
	return Plugin_Continue;
}


public int Handler_Menu(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char sParam[32];
		GetMenuItem(menu, param, sParam, sizeof(sParam));
		
		Handle hFile = OpenFile(g_sMenuFile, "rt");
		
		if (hFile)
		{
			KeyValues kvMenu = CreateKeyValues("Menu");
			
			if (!kvMenu.ImportFromFile(g_sMenuFile))
			{
				SetFailState("MyJailbreak Warden - Can't read %s correctly! (ImportFromFile)", g_sMenuFile);
				delete kvMenu;
			}
			
			if (kvMenu.JumpToKey(sParam, false))
			{
				char sValue[PLATFORM_MAX_PATH];
				
				kvMenu.GetString("chat", sValue, sizeof(sValue));
				if (strlen(sValue) > 0)
				{
					CPrintToChatAll("%t %s", "warden_tag", sValue);
				}
				
				kvMenu.GetString("HUD", sValue, sizeof(sValue));
				if (strlen(sValue) > 0)
				{
					PrintCenterTextAll("%s", sValue);
				}
				
				kvMenu.GetString("overlay", sValue, sizeof(sValue));
				if (strlen(sValue) > 0)
				{
					char sTime[12];
					char sTeam[6];
					char szTeam[4][6];
					kvMenu.GetString("overlay_time", sTime, sizeof(sTime));
					kvMenu.GetString("overlay_team", sTeam, sizeof(sTeam));
					
					ReplaceString(sTeam, sizeof(sTeam), " ", "");
					int iCount = ExplodeString(sTeam, ",", szTeam, sizeof(szTeam), sizeof(szTeam[]));
					
					for (int iTeam = 0; iTeam < iCount; iTeam++)
					{
						LoopValidClients(i, false, false)
						if (GetClientTeam(i) == StringToInt(szTeam[iTeam])) ShowOverlay(i ,sValue, StringToFloat(sTime));
					}
				}
				
				kvMenu.GetString("sound", sValue, sizeof(sValue));
				if (strlen(sValue) > 0)
				{
					EmitSoundToAllAny(sValue);
				}
				delete kvMenu;
			}
		}
		else SetFailState("MyJailbreak Warden - Can't open File: %s", g_sMenuFile);
	}
	else if (action == MenuAction_Cancel)
	{
		if (param == MenuCancel_ExitBack)
		{
			Menu_BuildOrderMenu(client);
		
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}