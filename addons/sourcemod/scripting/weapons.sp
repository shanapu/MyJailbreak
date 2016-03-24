#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <clientprefs>
#include <wardn>
#include <colors>
#include <autoexecconfig>

#define VERSION "0.x"

new Handle:Timers[MAXPLAYERS + 1] = INVALID_HANDLE;

new bool:newWeaponsSelected[MAXPLAYERS+1];
new bool:rememberChoice[MAXPLAYERS+1];
new bool:weaponsGivenThisRound[MAXPLAYERS + 1] = { false, ... };

// Menus
new Handle:optionsMenu1 = INVALID_HANDLE;
new Handle:optionsMenu2 = INVALID_HANDLE;
new Handle:optionsMenu3 = INVALID_HANDLE;
new Handle:optionsMenu4 = INVALID_HANDLE;

new String:primaryWeapon[MAXPLAYERS + 1][24];
new String:secondaryWeapon[MAXPLAYERS + 1][24];

ConVar gc_bTagEnabled;
new Handle:g_enabled=INVALID_HANDLE;
new Handle:g_Tenabled=INVALID_HANDLE;
new Handle:g_CTenabled=INVALID_HANDLE;

enum weapons
{
	String:ItemName[64],
	String:desc[64]
}

new Handle:array_primary;
new Handle:array_secondary;

public Plugin:myinfo =
{
	name = "Jailbreak Weapons",
	author = "shanpau, franug",
	description = "plugin",
	version = VERSION,
	url = "http://www.shanapu.de/"
};

new Handle:weapons1 = INVALID_HANDLE;
new Handle:weapons2 = INVALID_HANDLE;
//new Handle:remember = INVALID_HANDLE;

public OnPluginStart()
{
	
	LoadTranslations("MyJailbreakWeapons.phrases");

	array_primary = CreateArray(128);
	array_secondary = CreateArray(128);
	ListWeapons();
	
	// Create menus
	optionsMenu1 = BuildOptionsMenu(true);
	optionsMenu2 = BuildOptionsMenu(false);
	optionsMenu3 = BuildOptionsMenuWeapons(true);
	optionsMenu4 = BuildOptionsMenuWeapons(false);
	
	HookEvent("player_spawn", Event_PlayerSpawn);

	AutoExecConfig_SetFile("MyJailbreak_weapons");
	AutoExecConfig_SetCreateFile(true);
	
	g_enabled = AutoExecConfig_CreateConVar("sm_weapons_enable", "1", "0 - disabled, 1 - enable weapons");
	g_Tenabled = AutoExecConfig_CreateConVar("sm_weapons_t", "0", "0 - disabled, 1 - enable weapons for T");
	g_CTenabled = AutoExecConfig_CreateConVar("sm_weapons_ct", "1", "0 - disabled, 1 - enable weapons for CT");
	gc_bTagEnabled = AutoExecConfig_CreateConVar("sm_weapons_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch you sv_tags", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	AutoExecConfig_CacheConvars();
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	AutoExecConfig(true, "MyJailbreak_weapons");
	
	
	AddCommandListener(Event_Say, "say");
	AddCommandListener(Event_Say, "say_team");
	
	weapons1 = RegClientCookie("Primary Weapons", "", CookieAccess_Private);
	weapons2 = RegClientCookie("Secondary Weapons", "", CookieAccess_Private);
	//remember = RegClientCookie("Remember Weapons", "", CookieAccess_Private);
}

public OnConfigsExecuted()
{
	
	if (gc_bTagEnabled.BoolValue)
	{
		ConVar hTags = FindConVar("sv_tags");
		char sTags[128];
		hTags.GetString(sTags, sizeof(sTags));
		if (StrContains(sTags, "MyJailbreak", false) == -1)
		{
			StrCat(sTags, sizeof(sTags), ", MyJailbreak");
			hTags.SetString(sTags);
		}
	}
}

Handle:BuildOptionsMenu(bool:sameWeaponsEnabled)
{
	decl String:info1[255], String:info2[255], String:info3[255], String:info4[255], String:info5[255], String:info6[255];


	new sameWeaponsStyle = (sameWeaponsEnabled) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED;
	new Handle:menu3 = CreateMenu(Menu_Options);
	Format(info1, sizeof(info1), "%T\n ", "weapons_info_Title", LANG_SERVER);
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

DisplayOptionsMenu(clientIndex)
{
	if (strcmp(primaryWeapon[clientIndex], "") == 0 || strcmp(secondaryWeapon[clientIndex], "") == 0)
		DisplayMenu(optionsMenu2, clientIndex, 30);
	else
		DisplayMenu(optionsMenu1, clientIndex, 30);
}

Handle:BuildOptionsMenuWeapons(bool:primary)
{
	decl String:info7[255], String:info8[255];
	new Handle:menu;
	new Items[weapons];
	if(primary)
	{
		menu = CreateMenu(Menu_Primary);
		Format(info7, sizeof(info7), "%T\n ", "weapons_info_prim", LANG_SERVER);
		SetMenuTitle(menu, info7);
		SetMenuExitButton(menu, true);
		for(new i=0;i<GetArraySize(array_primary);++i)
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
		for(new i=0;i<GetArraySize(array_secondary);++i)
		{
			GetArrayArray(array_secondary, i, Items[0]);
			AddMenuItem(menu, Items[ItemName], Items[desc]);
		}
	}
	
	return menu;

}


public Menu_Options(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		decl String:info[24];
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

public Menu_Primary(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		decl String:info[24];
		GetMenuItem(menu, param2, info, sizeof(info));
		primaryWeapon[param1] = info;
		DisplayMenu(optionsMenu4, param1, MENU_TIME_FOREVER);
	}
}

public Menu_Secondary(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		decl String:info[24];
		GetMenuItem(menu, param2, info, sizeof(info));
		secondaryWeapon[param1] = info;
		GiveSavedWeapons(param1);
		if (!IsPlayerAlive(param1))
			newWeaponsSelected[param1] = true;
		if (newWeaponsSelected[param1])
			CPrintToChat(param1, "%t %t", "weapons_tag", "weapons_next");
	}
}

public OnMapStart()
{
	SetBuyZones("Disable");
}

public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new clientIndex = GetClientOfUserId(GetEventInt(event, "userid"));
	
	//CancelClientMenu(clientIndex);
	DeathTimer(clientIndex);
	Timers[clientIndex] = CreateTimer(1.0, GetWeapons, clientIndex);
}

public Action:GetWeapons(Handle:timer, any:clientIndex)
{
	Timers[clientIndex] = INVALID_HANDLE;
	if (GetClientTeam(clientIndex) > 1 && IsPlayerAlive(clientIndex))
	{
	if(GetConVarInt(g_enabled) == 1)	
	{
	if(GetConVarInt(g_Tenabled) == 1)	
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
	}else if(GetClientTeam(clientIndex) == 3)
	{
	if(GetConVarInt(g_CTenabled) == 1)	
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

public Action:Fix(Handle:timer, any:clientIndex)
{
	Timers[clientIndex] = INVALID_HANDLE;
	if (GetClientTeam(clientIndex) > 1 && IsPlayerAlive(clientIndex))
	{
		GiveSavedWeaponsFix(clientIndex);
	}
}

GiveSavedWeaponsFix(clientIndex)
{
	if (IsPlayerAlive(clientIndex))
	{		
		if(GetConVarInt(g_enabled) == 1)
		{
		if(GetConVarInt(g_Tenabled) == 1)
		{
		
		
		//StripAllWeapons(clientIndex);
		if(GetPlayerWeaponSlot(clientIndex, CS_SLOT_PRIMARY) == -1)
		{
			if (StrEqual(primaryWeapon[clientIndex], "random"))
			{
				// Select random menu item (excluding "Random" option)
				new random = GetRandomInt(0, GetArraySize(array_primary)-1);
				new Items[weapons];
				GetArrayArray(array_primary, random, Items[0]);
				GivePlayerItem(clientIndex, Items[ItemName]);
			}
			else
				GivePlayerItem(clientIndex, primaryWeapon[clientIndex]);
		}
			
		if(GetPlayerWeaponSlot(clientIndex, CS_SLOT_SECONDARY) == -1)
		{
			if (StrEqual(secondaryWeapon[clientIndex], "random"))
			{
				// Select random menu item (excluding "Random" option)
				new random = GetRandomInt(0, GetArraySize(array_secondary)-1);
				new Items[weapons];
				GetArrayArray(array_secondary, random, Items[0]);
				GivePlayerItem(clientIndex, Items[ItemName]);
			}
			else
				GivePlayerItem(clientIndex, secondaryWeapon[clientIndex]);
		}


		if(GetPlayerWeaponSlot(clientIndex, CS_SLOT_GRENADE) == -1) GivePlayerItem(clientIndex, "weapon_hegrenade");
		//GivePlayerItem(clientIndex, "weapon_hegrenade");
		//GivePlayerItem(clientIndex, "weapon_decoy");
		//GivePlayerItem(clientIndex, "weapon_flashbang");
		//GivePlayerItem(clientIndex, "weapon_molotov");
		//GivePlayerItem(clientIndex, "weapon_decoy");
		//GivePlayerItem(clientIndex, "weapon_flashbang");
		//GivePlayerItem(clientIndex, "weapon_molotov");
		weaponsGivenThisRound[clientIndex] = true;
		}
		else if(GetClientTeam(clientIndex) == 3)
	{
	if(GetConVarInt(g_CTenabled) == 1)	
	{
	if(GetPlayerWeaponSlot(clientIndex, CS_SLOT_PRIMARY) == -1)
		{
			if (StrEqual(primaryWeapon[clientIndex], "random"))
			{
				// Select random menu item (excluding "Random" option)
				new random = GetRandomInt(0, GetArraySize(array_primary)-1);
				new Items[weapons];
				GetArrayArray(array_primary, random, Items[0]);
				GivePlayerItem(clientIndex, Items[ItemName]);
			}
			else
				GivePlayerItem(clientIndex, primaryWeapon[clientIndex]);
		}
			
		if(GetPlayerWeaponSlot(clientIndex, CS_SLOT_SECONDARY) == -1)
		{
			if (StrEqual(secondaryWeapon[clientIndex], "random"))
			{
				// Select random menu item (excluding "Random" option)
				new random = GetRandomInt(0, GetArraySize(array_secondary)-1);
				new Items[weapons];
				GetArrayArray(array_secondary, random, Items[0]);
				GivePlayerItem(clientIndex, Items[ItemName]);
			}
			else
				GivePlayerItem(clientIndex, secondaryWeapon[clientIndex]);
		}


		if(GetPlayerWeaponSlot(clientIndex, CS_SLOT_GRENADE) == -1) GivePlayerItem(clientIndex, "weapon_hegrenade");
		//GivePlayerItem(clientIndex, "weapon_hegrenade");
		//GivePlayerItem(clientIndex, "weapon_decoy");
		//GivePlayerItem(clientIndex, "weapon_flashbang");
		//GivePlayerItem(clientIndex, "weapon_molotov");
		//GivePlayerItem(clientIndex, "weapon_decoy");
		//GivePlayerItem(clientIndex, "weapon_flashbang");
		//GivePlayerItem(clientIndex, "weapon_molotov");
		weaponsGivenThisRound[clientIndex] = true;
	}
	}
	}
	}
}

SetBuyZones(const String:status[])
{
	new maxEntities = GetMaxEntities();
	decl String:class[24];
	
	for (new i = MaxClients + 1; i < maxEntities; i++)
	{
		if (IsValidEdict(i))
		{
			GetEdictClassname(i, class, sizeof(class));
			if (StrEqual(class, "func_buyzone"))
				AcceptEntityInput(i, status);
		}
	}
}

public Action:Event_Say(clientIndex, const String:command[], arg)
{
	static String:menuTriggers[][] = { "gun", "!gun", "/gun", "guns", "!guns", "/guns", "weapon", "!weapon", "/weapon", "weapons", "!weapons", "/weapons" };
	
	if (clientIndex != 0 && IsClientInGame(clientIndex))
	{
		// Retrieve and clean up text.
		decl String:text[24];
		GetCmdArgString(text, sizeof(text));
		StripQuotes(text);
		TrimString(text);
	
		for(new i = 0; i < sizeof(menuTriggers); i++)
		{
			if (StrEqual(text, menuTriggers[i], false))
			{
				rememberChoice[clientIndex] = false;
				DisplayOptionsMenu(clientIndex);
				return Plugin_Handled;
			}
		}
	}
	return Plugin_Continue;
}

GiveSavedWeapons(clientIndex)
{

	if (!weaponsGivenThisRound[clientIndex] && IsPlayerAlive(clientIndex))
	{
		
		StripAllWeapons(clientIndex);
		if (StrEqual(primaryWeapon[clientIndex], "random"))
		{
			// Select random menu item (excluding "Random" option)
			new random = GetRandomInt(0, GetArraySize(array_primary)-1);
			new Items[weapons];
			GetArrayArray(array_primary, random, Items[0]);
			GivePlayerItem(clientIndex, Items[ItemName]);
		}
		else
			GivePlayerItem(clientIndex, primaryWeapon[clientIndex]);

		if (StrEqual(secondaryWeapon[clientIndex], "random"))
		{
			// Select random menu item (excluding "Random" option)
			new random = GetRandomInt(0, GetArraySize(array_secondary)-1);
			new Items[weapons];
			GetArrayArray(array_secondary, random, Items[0]);
			GivePlayerItem(clientIndex, Items[ItemName]);
		}
		else
			GivePlayerItem(clientIndex, secondaryWeapon[clientIndex]);

		if (warden_iswarden(clientIndex))
		{
		GivePlayerItem(clientIndex, "weapon_healthshot");
		GivePlayerItem(clientIndex, "weapon_tagrenade");
		}
		
		//GivePlayerItem(clientIndex, "weapon_decoy");
		//GivePlayerItem(clientIndex, "weapon_flashbang");
		//GivePlayerItem(clientIndex, "weapon_molotov");
		//GivePlayerItem(clientIndex, "weapon_decoy");
		//GivePlayerItem(clientIndex, "weapon_flashbang");
		//GivePlayerItem(clientIndex, "weapon_molotov");
		weaponsGivenThisRound[clientIndex] = true;
		
		GivePlayerItem(clientIndex, "weapon_knife");
		//FakeClientCommand(clientIndex,"use weapon_knife");
		FakeClientCommand(clientIndex,"sm_menu");
		
		Timers[clientIndex] = CreateTimer(6.0, Fix, clientIndex);
	}
}

stock StripAllWeapons(iClient)
{
    new iEnt;
    for (new i = 0; i <= 4; i++)
    {
        while ((iEnt = GetPlayerWeaponSlot(iClient, i)) != -1)
        {
            RemovePlayerItem(iClient, iEnt);
            AcceptEntityInput(iEnt, "Kill");
        }
    }
}  

public OnClientPutInServer(client)
{
	ResetClientSettings(client);
}

public OnClientCookiesCached(client)
{
	GetClientCookie(client, weapons1, primaryWeapon[client], 24);
	GetClientCookie(client, weapons2, secondaryWeapon[client], 24);
	//rememberChoice[client] = GetCookie(client);
	rememberChoice[client] = false;
}

ResetClientSettings(clientIndex)
{
	weaponsGivenThisRound[clientIndex] = false;
	newWeaponsSelected[clientIndex] = false;
}

public OnClientDisconnect(clientIndex)
{
	DeathTimer(clientIndex);
	
	SetClientCookie(clientIndex, weapons1, primaryWeapon[clientIndex]);
	SetClientCookie(clientIndex, weapons2, secondaryWeapon[clientIndex]);
	
/* 	if(rememberChoice[clientIndex]) SetClientCookie(clientIndex, remember, "On");
	else SetClientCookie(clientIndex, remember, "Off"); */
}

DeathTimer(client)
{
	if (Timers[client] != INVALID_HANDLE)
    {
		KillTimer(Timers[client]);
		Timers[client] = INVALID_HANDLE;
	}
}


ListWeapons()
{
	ClearArray(array_primary);
	ClearArray(array_secondary);
	
	new Items[weapons];
	
	Format(Items[ItemName], 64, "weapon_m4a1");
	Format(Items[desc], 64, "M4A1");
	PushArrayArray(array_primary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_m4a1_silencer");
	Format(Items[desc], 64, "M4A1-S");
	PushArrayArray(array_primary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_ak47");
	Format(Items[desc], 64, "AK-47");
	PushArrayArray(array_primary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_aug");
	Format(Items[desc], 64, "AUG");
	PushArrayArray(array_primary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_galilar");
	Format(Items[desc], 64, "Galil AR");
	PushArrayArray(array_primary, Items[0]);
	
 	Format(Items[ItemName], 64, "weapon_awp");
	Format(Items[desc], 64, "AWP");
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
	
	Format(Items[ItemName], 64, "weapon_bizon");
	Format(Items[desc], 64, "PP-Bizon");
	PushArrayArray(array_primary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_p90");
	Format(Items[desc], 64, "P90");
	PushArrayArray(array_primary, Items[0]);
	
 	Format(Items[ItemName], 64, "weapon_scar20");
	Format(Items[desc], 64, "SCAR-20");
	PushArrayArray(array_primary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_g3sg1");
	Format(Items[desc], 64, "G3SG1");
	PushArrayArray(array_primary, Items[0]); 
	
	Format(Items[ItemName], 64, "weapon_ump45");
	Format(Items[desc], 64, "UMP-45");
	PushArrayArray(array_primary, Items[0]);
	
	Format(Items[ItemName], 64, "weapon_mp7");
	Format(Items[desc], 64, "MP7");
	PushArrayArray(array_primary, Items[0]);

	Format(Items[ItemName], 64, "weapon_famas");
	Format(Items[desc], 64, "FAMAS");
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

/* bool:GetCookie(client)
{
	decl String:buffer[10];
	GetClientCookie(client, remember, buffer, sizeof(buffer));
	
	return StrEqual(buffer, "On");
} */