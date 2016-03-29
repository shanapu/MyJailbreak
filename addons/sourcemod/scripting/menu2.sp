//  Donor Menu (C) 2014 Sarabveer Singh <sarabveer@sarabveer.me>
//  
//  Donor Menu is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, per version 3 of the License.
//  
//  Donor Menu is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with Donor Menu. If not, see <http://www.gnu.org/licenses/>.
//
//  This file incorporates work covered by the following copyright(s):   
//
//   Help Menu 0.3
//   Copyright (C) 2008 chundo <chundo@mefightclub.com>
//   Licensed under GNU GPL version 3
//   Page: <https://forums.alliedmods.net/showthread.php?p=637467>
//

#pragma semicolon 1

#include <sourcemod>
#undef REQUIRE_PLUGIN
#include <updater>

#define PLUGIN_VERSION "1.4"
#define UPDATE_URL    "https://raw.githubusercontent.com/Sarabveer/SM-Plugins/master/donormenu/updater.txt"

enum ChatCommand {
	String:command[32],
	String:description[255]
}

enum DonorMenuType {
	DonorMenuType_List,
	DonorMenuType_Text
}

enum DonorMenu {
	String:dname[32],
	String:title[128],
	DonorMenuType:type,
	Handle:items,
	itemct
}

// CVars
new Handle:g_cvarWelcome = INVALID_HANDLE;
new Handle:g_cvarAdmins = INVALID_HANDLE;

// Help menus
new Handle:g_DonorMenus = INVALID_HANDLE;

// Config parsing
new g_configLevel = -1;

public Plugin:myinfo =
{
	name = "[ANY] Donor Menu",
	author = "Sarabveer(VEER™)",
	description = "Display a Donor menu to users",
	version = PLUGIN_VERSION,
	url = "https://www.sarabveer.me"
}

public OnPluginStart() {
	CreateConVar("sm_donormenu_version", PLUGIN_VERSION, "Donor menu version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	g_cvarWelcome = CreateConVar("sm_donormenu_welcome", "1", "Show welcome message to newly connected users.", FCVAR_PLUGIN);
	g_cvarAdmins = CreateConVar("sm_donormenu_admins", "0", "Show a list of online admins in the menu.", FCVAR_PLUGIN);
	
	RegConsoleCmd("sm_menu2", Command_DonorMenu, "Display the Server menu.", FCVAR_PLUGIN);

	
	
	new String:hc[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, hc, sizeof(hc), "configs/donors.cfg");
	ParseConfigFile(hc);

	AutoExecConfig(false);
	
	if (LibraryExists("updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
	}
}

public OnLibraryAdded(const String:name[])
{
	if (StrEqual(name, "updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
}

public OnMapStart() {
	new String:hc[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, hc, sizeof(hc), "configs/donors.cfg");
	ParseConfigFile(hc);
}

public OnClientPutInServer(client) {
	if (GetConVarBool(g_cvarWelcome))
		CreateTimer(30.0, Timer_WelcomeMessage, client);
}

public Action:Timer_WelcomeMessage(Handle:timer, any:client) {
	if (GetConVarBool(g_cvarWelcome) && IsClientConnected(client) && IsClientInGame(client) && !IsFakeClient(client))
		PrintToChat(client, "[\x04goo\x01] Für das Player Menu, nutze \x04!menu\x01 oder die \x04,\x01-Taste");
}

bool:ParseConfigFile(const String:file[]) {
	if (g_DonorMenus != INVALID_HANDLE) {
		ClearArray(g_DonorMenus);
		CloseHandle(g_DonorMenus);
		g_DonorMenus = INVALID_HANDLE;
	}

	new Handle:parser = SMC_CreateParser();
	SMC_SetReaders(parser, Config_NewSection, Config_KeyValue, Config_EndSection);
	SMC_SetParseEnd(parser, Config_End);

	new line = 0;
	new col = 0;
	new String:error[128];
	new SMCError:result = SMC_ParseFile(parser, file, line, col);
	CloseHandle(parser);

	if (result != SMCError_Okay) {
		SMC_GetErrorString(result, error, sizeof(error));
		LogError("%s on line %d, col %d of %s", error, line, col, file);
	}

	return (result == SMCError_Okay);
}

public SMCResult:Config_NewSection(Handle:parser, const String:section[], bool:quotes) {
	g_configLevel++;
	if (g_configLevel == 1) {
		new hmenu[DonorMenu];
		strcopy(hmenu[dname], sizeof(hmenu[dname]), section);
		hmenu[items] = CreateDataPack();
		hmenu[itemct] = 0;
		if (g_DonorMenus == INVALID_HANDLE)
			g_DonorMenus = CreateArray(sizeof(hmenu));
		PushArrayArray(g_DonorMenus, hmenu[0]);
	}
	return SMCParse_Continue;
}

public SMCResult:Config_KeyValue(Handle:parser, const String:key[], const String:value[], bool:key_quotes, bool:value_quotes) {
	new msize = GetArraySize(g_DonorMenus);
	new hmenu[DonorMenu];
	GetArrayArray(g_DonorMenus, msize-1, hmenu[0]);
	switch (g_configLevel) {
		case 1: {
			if(strcmp(key, "title", false) == 0)
				strcopy(hmenu[title], sizeof(hmenu[title]), value);
			if(strcmp(key, "type", false) == 0) {
				if(strcmp(value, "text", false) == 0)
					hmenu[type] = DonorMenuType_Text;
				else
					hmenu[type] = DonorMenuType_List;
			}
		}
		case 2: {
			WritePackString(hmenu[items], key);
			WritePackString(hmenu[items], value);
			hmenu[itemct]++;
		}
	}
	SetArrayArray(g_DonorMenus, msize-1, hmenu[0]);
	return SMCParse_Continue;
}
public SMCResult:Config_EndSection(Handle:parser) {
	g_configLevel--;
	if (g_configLevel == 1) {
		new hmenu[DonorMenu];
		new msize = GetArraySize(g_DonorMenus);
		GetArrayArray(g_DonorMenus, msize-1, hmenu[0]);
		ResetPack(hmenu[items]);
	}
	return SMCParse_Continue;
}

public Config_End(Handle:parser, bool:halted, bool:failed) {
	if (failed)
		SetFailState("DonorMenu: Plugin Configuration Error");
}

public Action:Command_DonorMenu(client, args) {
	Help_ShowMainMenu(client);
	return Plugin_Handled;
}

Help_ShowMainMenu(client) {
	new Handle:menu = CreateMenu(Help_MainMenuHandler);
	SetMenuExitBackButton(menu, false);
	SetMenuTitle(menu, "[goo] Spieler Menu\n ");
	new msize = GetArraySize(g_DonorMenus);
	new hmenu[DonorMenu];
	new String:menuid[10];
	for (new i = 0; i < msize; ++i) {
		Format(menuid, sizeof(menuid), "DonorMenu_%d", i);
		GetArrayArray(g_DonorMenus, i, hmenu[0]);
		AddMenuItem(menu, menuid, hmenu[dname]);
	}
	if (GetConVarBool(g_cvarAdmins))
		AddMenuItem(menu, "admins", "List Online Admins");
	DisplayMenu(menu, client, 30);
}

public Help_MainMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
	if (action == MenuAction_End) {
		CloseHandle(menu);
	} else if (action == MenuAction_Select) {
		new msize = GetArraySize(g_DonorMenus);
		if (param2 == msize) { // Admins
			new Handle:adminMenu = CreateMenu(Help_MenuHandler);
			SetMenuExitBackButton(adminMenu, true);
			SetMenuTitle(adminMenu, "Online Admins\n ");
			new maxc = GetMaxClients();
			new String:aname[64];
			for (new i = 1; i < maxc; ++i) {
				if (IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i) && (GetUserFlagBits(i) & ADMFLAG_GENERIC) == ADMFLAG_GENERIC) {
					GetClientName(i, aname, sizeof(aname));
					AddMenuItem(adminMenu, aname, aname, ITEMDRAW_DISABLED);
				}
			}
			DisplayMenu(adminMenu, param1, 30);
		} else { // Menu from config file
			if (param2 <= msize) {
				new hmenu[DonorMenu];
				GetArrayArray(g_DonorMenus, param2, hmenu[0]);
				new String:mtitle[512];
				Format(mtitle, sizeof(mtitle), "%s\n ", hmenu[title]);
				if (hmenu[type] == DonorMenuType_Text) {
					new Handle:cpanel = CreatePanel();
					SetPanelTitle(cpanel, mtitle);
					new String:text[128];
					new String:junk[128];
					for (new i = 0; i < hmenu[itemct]; ++i) {
						ReadPackString(hmenu[items], junk, sizeof(junk));
						ReadPackString(hmenu[items], text, sizeof(text));
						DrawPanelText(cpanel, text);
					}
					for (new j = 0; j < 7; ++j)
						DrawPanelItem(cpanel, " ", ITEMDRAW_NOTEXT);
					DrawPanelText(cpanel, " ");
					DrawPanelItem(cpanel, "Back", ITEMDRAW_CONTROL);
					DrawPanelItem(cpanel, " ", ITEMDRAW_NOTEXT);
					DrawPanelText(cpanel, " ");
					DrawPanelItem(cpanel, "Exit", ITEMDRAW_CONTROL);
					ResetPack(hmenu[items]);
					SendPanelToClient(cpanel, param1, Help_MenuHandler, 30);
					CloseHandle(cpanel);
				} else {
					new Handle:cmenu = CreateMenu(Help_CustomMenuHandler);
					SetMenuExitBackButton(cmenu, true);
					SetMenuTitle(cmenu, mtitle);
					new String:cmd[128];
					new String:desc[128];
					for (new i = 0; i < hmenu[itemct]; ++i) {
						ReadPackString(hmenu[items], cmd, sizeof(cmd));
						ReadPackString(hmenu[items], desc, sizeof(desc));
						new drawstyle = ITEMDRAW_DEFAULT;
						if (strlen(cmd) == 0)
							drawstyle = ITEMDRAW_DISABLED;
						AddMenuItem(cmenu, cmd, desc, drawstyle);
					}
					ResetPack(hmenu[items]);
					DisplayMenu(cmenu, param1, 30);
				}
			}
		}
	}
}

public Help_MenuHandler(Handle:menu, MenuAction:action, param1, param2) {
	if (action == MenuAction_End) {
		CloseHandle(menu);
	} else if (menu == INVALID_HANDLE && action == MenuAction_Select && param2 == 8) {
		Help_ShowMainMenu(param1);
	} else if (action == MenuAction_Cancel) {
		if (param2 == MenuCancel_ExitBack)
			Help_ShowMainMenu(param1);
	}
}

public Help_CustomMenuHandler(Handle:menu, MenuAction:action, param1, param2) {
	if (action == MenuAction_End) {
		CloseHandle(menu);
	} else if (action == MenuAction_Select) {
		new String:itemval[32];
		GetMenuItem(menu, param2, itemval, sizeof(itemval));
		if (strlen(itemval) > 0)
			FakeClientCommand(param1, itemval);
	} else if (action == MenuAction_Cancel) {
		if (param2 == MenuCancel_ExitBack)
			Help_ShowMainMenu(param1);
	}
}