/*
 * MyJailbreak - Weapon Plugin.
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
#include <clientprefs>


//Compiler Options
#pragma semicolon 1
#pragma newdecls required


//Booleans
bool newWeaponsSelected[MAXPLAYERS+1];
bool rememberChoice[MAXPLAYERS+1];
bool weaponsGivenThisRound[MAXPLAYERS + 1] = { false, ... };


//Handles
Handle optionsMenu1 = null;
Handle optionsMenu2 = null;
Handle optionsMenu3 = null;
Handle optionsMenu4 = null;
Handle Timers[MAXPLAYERS + 1] = null;
Handle array_primary;
Handle array_secondary;
Handle weapons1 = null;
Handle weapons2 = null;


//Console Variables
ConVar gc_bSpawn;
ConVar gc_bPlugin;
ConVar gc_bTerror;
ConVar gc_bCTerror;
ConVar gc_bTA;
ConVar gc_bJBmenu;
ConVar gc_bAWP;
ConVar gc_bAutoSniper;
ConVar gc_bHealth;
ConVar gc_sCustomCommand;
ConVar g_bTaser;


//Strings
char primaryWeapon[MAXPLAYERS + 1][24];
char secondaryWeapon[MAXPLAYERS + 1][24];
char g_sCustomCommand[64];


enum weapons
{
	String:ItemName[64],
	String:desc[64]
}


//Info
public Plugin myinfo =
{
	name = "MyJailbreak - Weapons",
	author = "shanapu, Franc1sco",
	description = "Jailbreak weapons script",
	version = PLUGIN_VERSION,
	url = "https://github.com/shanapu/MyJailbreak"
};


//Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Weapons.phrases");
	
	
	//Client Commands
	RegConsoleCmd("sm_guns", Command_Weapons, "Open the weapon menu if enabled (in EventDays/for CT)");
	RegConsoleCmd("sm_gun", Command_Weapons, "Open the weapon menu if enabled (in EventDays/for CT)");
	RegConsoleCmd("sm_weapon", Command_Weapons, "Open the weapon menu if enabled (in EventDays/for CT)");
	RegConsoleCmd("sm_weapons", Command_Weapons, "Open the weapon menu if enabled (in EventDays/for CT)");
	RegConsoleCmd("sm_gunmenu", Command_Weapons, "Open the weapon menu if enabled (in EventDays/for CT)");
	RegConsoleCmd("sm_weaponmenu", Command_Weapons, "Open the weapon menu if enabled (in EventDays/for CT)");
	RegConsoleCmd("sm_giveweapon", Command_Weapons, "Open the weapon menu if enabled (in EventDays/for CT)");
	
	
	//AutoExecConfig
	AutoExecConfig_SetFile("Weapons", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_weapons_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_weapons_enable", "1", "0 - disabled, 1 - enable weapons menu - you shouldn't touch these, cause events days will handle them", _, true,  0.0, true, 1.0);
	gc_sCustomCommand = AutoExecConfig_CreateConVar("sm_weapons_cmd", "arms", "Set your custom chat command for Event voting. no need for sm_ or !");
	gc_bTerror = AutoExecConfig_CreateConVar("sm_weapons_t", "0", "0 - disabled, 1 - enable weapons menu for T - you shouldn't touch these, cause events days will handle them", _, true,  0.0, true, 1.0);
	gc_bCTerror = AutoExecConfig_CreateConVar("sm_weapons_ct", "1", "0 - disabled, 1 - enable weapons menu for CT - you shouldn't touch these, cause events days will handle them", _, true,  0.0, true, 1.0);
	gc_bSpawn = AutoExecConfig_CreateConVar("sm_weapons_spawnmenu", "1", "0 - disabled, 1 -  enable autoopen weapon menu on spawn", _, true,  0.0, true, 1.0);
	gc_bAWP = AutoExecConfig_CreateConVar("sm_weapons_awp", "1", "0 - disabled, 1 - enable AWP in menu", _, true,  0.0, true, 1.0);
	gc_bAutoSniper = AutoExecConfig_CreateConVar("sm_weapons_autosniper", "1", "0 - disabled, 1 - enable scar20 & g3sg1 in menu", _, true,  0.0, true, 1.0);
	gc_bTA = AutoExecConfig_CreateConVar("sm_weapons_warden_tagrenade", "1", "0 - disabled, 1 - warden get a TA grenade with weapons", _, true,  0.0, true, 1.0);
	gc_bHealth = AutoExecConfig_CreateConVar("sm_weapons_warden_healthshot", "1", "0 - disabled, 1 - warden get a healthshot with weapons", _, true,  0.0, true, 1.0);
	gc_bJBmenu = AutoExecConfig_CreateConVar("sm_weapons_jbmenu", "1", "0 - disabled, 1 - enable autoopen the MyJailbreak !menu after weapon given.", _, true,  0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	
	//Hooks
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookConVarChange(gc_sCustomCommand, OnSettingChanged);
	
	
	//Cookies
	weapons1 = RegClientCookie("Primary Weapons", "", CookieAccess_Private);
	weapons2 = RegClientCookie("Secondary Weapons", "", CookieAccess_Private);
	
	
	//FindConVar
	g_bTaser = FindConVar("sm_warden_handcuffs");
	gc_sCustomCommand.GetString(g_sCustomCommand , sizeof(g_sCustomCommand));
}


//ConVarChange for Strings
public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sCustomCommand)
	{
		strcopy(g_sCustomCommand, sizeof(g_sCustomCommand), newValue);
		char sBufferCMD[64];
		Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
		if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
			RegConsoleCmd(sBufferCMD, Command_Weapons, "Open the weapon menu if enabled (in EventDays/for CT)");
	}
}


//Initialize Plugin
public void OnConfigsExecuted()
{
	array_primary = CreateArray(128);
	array_secondary = CreateArray(128);
	ListWeapons();
	
	// Create menus
	optionsMenu1 = Menu_BuildOptionsMenu(true);
	optionsMenu2 = Menu_BuildOptionsMenu(false);
	optionsMenu3 = Menu_BuildWeaponsMenu(true);
	optionsMenu4 = Menu_BuildWeaponsMenu(false);
	
	char sBufferCMD[64];
	Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
	if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMD, Command_Weapons, "Open the weapon menu if enabled (in EventDays/for CT)");
}


/******************************************************************************
                   COMMANDS
******************************************************************************/


//Open the weapon menu
public Action Command_Weapons(int client,int args)
{
	if(gc_bPlugin.BoolValue)	
	{
		if (client != 0 && IsClientInGame(client))
		{
					rememberChoice[client] = false;
					DisplayOptionsMenu(client);
					return Plugin_Handled;
		}
		return Plugin_Continue;
	}
	else CPrintToChat(client, "%t %t", "weapons_tag" , "weapons_disabled");
	return Plugin_Continue;
}


/******************************************************************************
                   EVENTS
******************************************************************************/


//On Player Spawn
public int Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int clientIndex = GetClientOfUserId(GetEventInt(event, "userid"));
	
	KillAllTimer(clientIndex);
	if(gc_bSpawn.BoolValue)
	{
		Timers[clientIndex] = CreateTimer(1.0, Timer_GetWeapons, clientIndex);
	}
}


/******************************************************************************
                   FUNCTIONS
******************************************************************************/


public void GiveSavedWeaponsFix(int clientIndex)
{
	if (IsPlayerAlive(clientIndex))
	{
		if(gc_bPlugin.BoolValue)
		{
			if((gc_bTerror.BoolValue && GetClientTeam(clientIndex) == 2) || (gc_bCTerror.BoolValue && GetClientTeam(clientIndex) == 3))
			{
				//StripAllPlayerWeapons(clientIndex);
				if(GetPlayerWeaponSlot(clientIndex, CS_SLOT_PRIMARY) == -1)
				{
					if (StrEqual(primaryWeapon[clientIndex], "random"))
					{
						// Select random menu item (excluding "Random" option)
						int random = GetRandomInt(0, GetArraySize(array_primary)-1);
						int Items[weapons];
						GetArrayArray(array_primary, random, Items[0]);
						GivePlayerItem(clientIndex, Items[ItemName]);
					}
					else GivePlayerItem(clientIndex, primaryWeapon[clientIndex]);
				}
				if(GetPlayerWeaponSlot(clientIndex, CS_SLOT_SECONDARY) == -1)
				{
					if (StrEqual(secondaryWeapon[clientIndex], "random"))
					{
						// Select random menu item (excluding "Random" option)
						int random = GetRandomInt(0, GetArraySize(array_secondary)-1);
						int Items[weapons];
						GetArrayArray(array_secondary, random, Items[0]);
						GivePlayerItem(clientIndex, Items[ItemName]);
					}
					else GivePlayerItem(clientIndex, secondaryWeapon[clientIndex]);
				}
				if(GetPlayerWeaponSlot(clientIndex, CS_SLOT_GRENADE) == -1) GivePlayerItem(clientIndex, "weapon_hegrenade");
				weaponsGivenThisRound[clientIndex] = true;
			}
		}
	}
}


public void SetBuyZones(const char[] status)
{
	int maxEntities = GetMaxEntities();
	char class[24];
	
	for (int i = MaxClients + 1; i < maxEntities; i++)
	{
		if (IsValidEdict(i))
		{
			GetEdictClassname(i, class, sizeof(class));
			if (StrEqual(class, "func_buyzone"))
				AcceptEntityInput(i, status);
		}
	}
}


public void GiveSavedWeapons(int clientIndex)
{
	if (!weaponsGivenThisRound[clientIndex] && IsPlayerAlive(clientIndex))
	{
		
		StripAllPlayerWeapons(clientIndex);
		GivePlayerItem(clientIndex, "weapon_knife");
		if (warden_iswarden(clientIndex))
		{
			if (gc_bHealth.BoolValue)
			{
				GivePlayerItem(clientIndex, "weapon_healthshot");
				CPrintToChat(clientIndex, "%t %t", "weapons_tag", "weapons_health");
			}
			if (gc_bTA.BoolValue)
			{
				GivePlayerItem(clientIndex, "weapon_tagrenade");
				CPrintToChat(clientIndex, "%t %t", "weapons_tag", "weapons_ta");
			}
			if(g_bTaser != null) if(g_bTaser.BoolValue) GivePlayerItem(clientIndex, "weapon_taser");
		}
		if (StrEqual(primaryWeapon[clientIndex], "random"))
		{
			// Select random menu item (excluding "Random" option)
			int random = GetRandomInt(0, GetArraySize(array_primary)-1);
			int Items[weapons];
			GetArrayArray(array_primary, random, Items[0]);
			GivePlayerItem(clientIndex, Items[ItemName]);
		}
		else GivePlayerItem(clientIndex, primaryWeapon[clientIndex]);
		
		if (StrEqual(secondaryWeapon[clientIndex], "random"))
		{
			// Select random menu item (excluding "Random" option)
			int random = GetRandomInt(0, GetArraySize(array_secondary)-1);
			int Items[weapons];
			GetArrayArray(array_secondary, random, Items[0]);
			GivePlayerItem(clientIndex, Items[ItemName]);
		}
		else GivePlayerItem(clientIndex, secondaryWeapon[clientIndex]);
		
		weaponsGivenThisRound[clientIndex] = true;
		
		if (gc_bJBmenu.BoolValue)
		{
			FakeClientCommand(clientIndex,"sm_menu");
		}
		Timers[clientIndex] = CreateTimer(6.0, Timer_Fix, clientIndex);
	}
}


public void ResetClientSettings(int clientIndex)
{
	weaponsGivenThisRound[clientIndex] = false;
	newWeaponsSelected[clientIndex] = false;
}


public void KillAllTimer(int client)
{
	if (Timers[client] != null)
	{
		KillTimer(Timers[client]);
		Timers[client] = null;
	}
}


public void ListWeapons()
{
	ClearArray(array_primary);
	ClearArray(array_secondary);
	
	int Items[weapons];
	
	Format(Items[ItemName], 64, "weapon_m4a1");
	Format(Items[desc], 64, "M4A1");
	PushArrayArray(array_primary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_m4a1_silencer");
	Format(Items[desc], 64, "M4A1-S");
	PushArrayArray(array_primary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_ak47");
	Format(Items[desc], 64, "AK-47");
	PushArrayArray(array_primary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_famas");
	Format(Items[desc], 64, "FAMAS");
	PushArrayArray(array_primary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_galilar");
	Format(Items[desc], 64, "Galil AR");
	PushArrayArray(array_primary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_aug");
	Format(Items[desc], 64, "AUG");
	PushArrayArray(array_primary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_sg556");
	Format(Items[desc], 64, "SG 553");
	PushArrayArray(array_primary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_negev");
	Format(Items[desc], 64, "Negev");
	PushArrayArray(array_primary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_m249");
	Format(Items[desc], 64, "M249");
	PushArrayArray(array_primary, Items[0]);
	
	if (gc_bAWP.BoolValue)
	{
		Format(Items[ItemName], 64, "weapon_awp");
		Format(Items[desc], 64, "AWP");
		PushArrayArray(array_primary, Items[0]); 
	}
	
	if (gc_bAutoSniper.BoolValue)
	{
		Format(Items[ItemName], 64, "weapon_scar20");
		Format(Items[desc], 64, "SCAR-20");
		PushArrayArray(array_primary, Items[0]);
		
		Format(Items[ItemName], 64, "weapon_g3sg1");
		Format(Items[desc], 64, "G3SG1");
		PushArrayArray(array_primary, Items[0]); 
	}
	
	Format(Items[ItemName], 64, "weapon_bizon");
	Format(Items[desc], 64, "PP-Bizon");
	PushArrayArray(array_primary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_p90");
	Format(Items[desc], 64, "P90");
	PushArrayArray(array_primary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_ump45");
	Format(Items[desc], 64, "UMP-45");
	PushArrayArray(array_primary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_mp7");
	Format(Items[desc], 64, "MP7");
	PushArrayArray(array_primary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_mp9");
	Format(Items[desc], 64, "MP9");
	PushArrayArray(array_primary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_mac10");
	Format(Items[desc], 64, "MAC-10");
	PushArrayArray(array_primary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_ssg08");
	Format(Items[desc], 64, "SSG 08");
	PushArrayArray(array_primary, Items[0]); 
	
	Format(Items[ItemName], 64, "weapon_nova");
	Format(Items[desc], 64, "Nova");
	PushArrayArray(array_primary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_xm1014");
	Format(Items[desc], 64, "XM1014");
	PushArrayArray(array_primary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_sawedoff");
	Format(Items[desc], 64, "Sawed-Off");
	PushArrayArray(array_primary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_mag7");
	Format(Items[desc], 64, "MAG-7");
	PushArrayArray(array_primary, Items[0]);
	

	
	// Secondary weapons
	
	Format(Items[ItemName], 64, "weapon_deagle");
	Format(Items[desc], 64, "Desert Eagle");
	PushArrayArray(array_secondary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_elite");
	Format(Items[desc], 64, "Dual Berettas");
	PushArrayArray(array_secondary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_tec9");
	Format(Items[desc], 64, "Tec-9");
	PushArrayArray(array_secondary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_fiveseven");
	Format(Items[desc], 64, "Five-SeveN");
	PushArrayArray(array_secondary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_cz75a");
	Format(Items[desc], 64, "CZ75-Auto");
	PushArrayArray(array_secondary, Items[0]); 
	
	Format(Items[ItemName], 64, "weapon_glock");
	Format(Items[desc], 64, "Glock-18");
	PushArrayArray(array_secondary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_usp_silencer");
	Format(Items[desc], 64, "USP-S");
	PushArrayArray(array_secondary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_p250");
	Format(Items[desc], 64, "P250");
	PushArrayArray(array_secondary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_hkp2000");
	Format(Items[desc], 64, "P2000");
	PushArrayArray(array_secondary, Items[0]);
	
}


/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/


public void OnMapStart()
{
	SetBuyZones("Disable");
}


public void OnClientPutInServer(int client)
{
	ResetClientSettings(client);
}


public void OnClientCookiesCached(int client)
{
	GetClientCookie(client, weapons1, primaryWeapon[client], 24);
	GetClientCookie(client, weapons2, secondaryWeapon[client], 24);
	rememberChoice[client] = false;
}


public void OnClientDisconnect(int clientIndex)
{
	KillAllTimer(clientIndex);
	
	SetClientCookie(clientIndex, weapons1, primaryWeapon[clientIndex]);
	SetClientCookie(clientIndex, weapons2, secondaryWeapon[clientIndex]);
}


/******************************************************************************
                   MENUS
******************************************************************************/


//Menu first site - choosing mode
Handle Menu_BuildOptionsMenu(bool sameWeaponsEnabled)
{
	char info1[255], info2[255], info3[255], info4[255], info5[255], info6[255];
	
	int sameWeaponsStyle = (sameWeaponsEnabled) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED;
	Handle menu3 = CreateMenu(Handler_BuildOptionsMenu);
	Format(info1, sizeof(info1), "%T\n ", "weapons_info_title", LANG_SERVER);
	SetMenuTitle(menu3, info1);
	SetMenuExitButton(menu3, true);
	Format(info2, sizeof(info2), "%T", "weapons_info_choose", LANG_SERVER);
	AddMenuItem(menu3, "New", info2);
	Format(info3, sizeof(info3), "%T", "weapons_info_same", LANG_SERVER);
	AddMenuItem(menu3, "Same 1", info3, sameWeaponsStyle);
	Format(info4, sizeof(info4), "%T", "weapons_info_sameall", LANG_SERVER);
	AddMenuItem(menu3, "Same All", info4, sameWeaponsStyle);
	Format(info5, sizeof(info5), "%T", "weapons_info_random", LANG_SERVER);
	AddMenuItem(menu3, "Random 1", info5);
	Format(info6, sizeof(info6), "%T", "weapons_info_randomall", LANG_SERVER);
	AddMenuItem(menu3, "Random All", info6);
	return menu3;
}


//Menu Handler first site - choosing mode
public int Handler_BuildOptionsMenu(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[24];
		GetMenuItem(menu, param2, info, sizeof(info));
		
		if (StrEqual(info, "New"))
		{
			if (weaponsGivenThisRound[param1])
				newWeaponsSelected[param1] = true;
			DisplayMenu(optionsMenu3, param1, MENU_TIME_FOREVER);
			rememberChoice[param1] = false;
		}
		else if (StrEqual(info, "Same 1"))
		{
			if (weaponsGivenThisRound[param1])
			{
				newWeaponsSelected[param1] = true;
				CPrintToChat(param1, "%t %t", "weapons_tag", "weapons_same");
			}
			GiveSavedWeapons(param1);
			rememberChoice[param1] = false;
		}
		else if (StrEqual(info, "Same All"))
		{
			if (weaponsGivenThisRound[param1])
				CPrintToChat(param1, "%t %t", "weapons_tag", "weapons_sameall");
			GiveSavedWeapons(param1);
			rememberChoice[param1] = true;
		}
		else if (StrEqual(info, "Random 1"))
		{
			if (weaponsGivenThisRound[param1])
			{
				newWeaponsSelected[param1] = true;
				CPrintToChat(param1, "%t %t", "weapons_tag", "weapons_random");
			}
			primaryWeapon[param1] = "random";
			secondaryWeapon[param1] = "random";
			GiveSavedWeapons(param1);
			rememberChoice[param1] = false;
		}
		else if (StrEqual(info, "Random All"))
		{
			if (weaponsGivenThisRound[param1])
				CPrintToChat(param1, "%t %t", "weapons_tag", "weapons_randomall");
			primaryWeapon[param1] = "random";
			secondaryWeapon[param1] = "random";
			GiveSavedWeapons(param1);
			rememberChoice[param1] = true;
		}
	}
}


//Menu choose weapons
Handle Menu_BuildWeaponsMenu(bool primary)
{
	
	char info7[255], info8[255];
	Handle menu;
	int Items[weapons];
	if(primary)
	{
		menu = CreateMenu(Menu_Primary);
		Format(info7, sizeof(info7), "%T\n ", "weapons_info_prim", LANG_SERVER);
		SetMenuTitle(menu, info7);
		SetMenuExitButton(menu, true);
		for(int i=0;i<GetArraySize(array_primary);++i)
		{
			GetArrayArray(array_primary, i, Items[0]);
			AddMenuItem(menu, Items[ItemName], Items[desc]);
		}
	}
	else
	{
		menu = CreateMenu(Menu_Secondary);
		Format(info8, sizeof(info8), "%T\n ", "weapons_info_sec", LANG_SERVER);
		SetMenuTitle(menu, info8);
		SetMenuExitButton(menu, true);
		for(int i=0;i<GetArraySize(array_secondary);++i)
		{
			GetArrayArray(array_secondary, i, Items[0]);
			AddMenuItem(menu, Items[ItemName], Items[desc]);
		}
	}
	return menu;
}


//Menu choose primary weapons
public int Menu_Primary(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[24];
		GetMenuItem(menu, param2, info, sizeof(info));
		primaryWeapon[param1] = info;
		DisplayMenu(optionsMenu4, param1, MENU_TIME_FOREVER);
	}
}


//Menu choose secondary weapons
public int Menu_Secondary(Handle menu, MenuAction action,int param1,int param2)
{
	if (action == MenuAction_Select)
	{
		char info[24];
		GetMenuItem(menu, param2, info, sizeof(info));
		secondaryWeapon[param1] = info;
		GiveSavedWeapons(param1);
		if (!IsPlayerAlive(param1))
			newWeaponsSelected[param1] = true;
		if (newWeaponsSelected[param1])
			CPrintToChat(param1, "%t %t", "weapons_tag", "weapons_next");
	}
}


//Check for display menu
public void DisplayOptionsMenu(int clientIndex)
{
	if(gc_bPlugin.BoolValue)	
	{
		if((gc_bTerror.BoolValue && GetClientTeam(clientIndex) == 2) || (gc_bCTerror.BoolValue && GetClientTeam(clientIndex) == 3))
		{
			if (strcmp(primaryWeapon[clientIndex], "") == 0 || strcmp(secondaryWeapon[clientIndex], "") == 0)
				DisplayMenu(optionsMenu2, clientIndex, 30);
			else
				DisplayMenu(optionsMenu1, clientIndex, 30);
		}
	}
}


/******************************************************************************
                   TIMER
******************************************************************************/


//Give choosed weapon timer
public Action Timer_GetWeapons(Handle timer, any clientIndex)
{
	Timers[clientIndex] = null;
	if (GetClientTeam(clientIndex) > 1 && IsPlayerAlive(clientIndex))
	{
		if(gc_bPlugin.BoolValue)	
		{
			if(gc_bSpawn.BoolValue)
			{
				if((gc_bTerror.BoolValue && GetClientTeam(clientIndex) == 2) || (gc_bCTerror.BoolValue && GetClientTeam(clientIndex) == 3))
				{
					// Give weapons or display menu.
					weaponsGivenThisRound[clientIndex] = false;
					if (newWeaponsSelected[clientIndex])
					{
						GiveSavedWeapons(clientIndex);
						newWeaponsSelected[clientIndex] = false;
					}
					else if (rememberChoice[clientIndex])
					{
						GiveSavedWeapons(clientIndex);
					}
					else
					{
						DisplayOptionsMenu(clientIndex);
					}
				}
			}
		}
	}
}


public Action Timer_Fix(Handle timer, any clientIndex)
{
	Timers[clientIndex] = null;
	if (GetClientTeam(clientIndex) > 1 && IsPlayerAlive(clientIndex))
	{
		GiveSavedWeaponsFix(clientIndex);
	}
}