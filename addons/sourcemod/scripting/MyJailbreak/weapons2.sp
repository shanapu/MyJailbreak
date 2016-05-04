// Includes
#include <sourcemod>
#include <sdktools>
#include <autoexecconfig>
#include <cstrike>
#include <colors>
#include <myjailbreak>

#pragma semicolon 1



new g_iMaximum;
new g_iUsages[MAXPLAYERS + 1];

new Handle:g_hMode = INVALID_HANDLE;

new Handle:g_hKV;
new Handle:g_hWeaponList;




public Plugin:myinfo =
{
	name = "Stamm Feature Weapons",
	author = "Popoklopsi",
	version = "1.3.2",
	description = "Give VIP's weapons",
	url = "https://forums.alliedmods.net/showthread.php?t=142073"
};



// Add the feature
public OnAllPluginsLoaded()
{
	decl String:path[PLATFORM_MAX_PATH + 1];


	LoadTranslations("stamm/stamm_weapons");

	// Config for CSGO
	Format(path, sizeof(path), "cfg/stamm/features/WeaponSettings_csgo.txt");


	// File doesn't exists? we cen abort here
	if (!FileExists(path))
	{
		SetFailState("Couldn't find the config %s", path);
	}



	// Read the config
	g_hKV = CreateKeyValues("WeaponSettings");
	FileToKeyValues(g_hKV, path);
	
	// Maxium gives
	g_iMaximum = KvGetNum(g_hKV, "maximum");
	
	// Create Menu
	g_hWeaponList = CreateMenu(weaponlist_handler);
	SetMenuTitle(g_hWeaponList, "!give <weapon_name>");
	

	// Parse config
	if (KvGotoFirstSubKey(g_hKV, false))
	{
		decl String:buffer[120];
		decl String:buffer2[120];

		do
		{
			// Get Weaponname
			KvGetSectionName(g_hKV, buffer, sizeof(buffer));

			strcopy(buffer2, sizeof(buffer2), buffer);

			// Replace weapon_ tag
			ReplaceString(buffer, sizeof(buffer), "weapon_", "");

			// And go back
			KvGoBack(g_hKV);
			
			//  Get status of weapon
			if (!StrEqual(buffer2, "maximum") && KvGetNum(g_hKV, buffer2) == 1) 
			{
				AddMenuItem(g_hWeaponList, buffer, buffer);
			}


			KvJumpToKey(g_hKV, buffer2);
		} 
		while (KvGotoNextKey(g_hKV, false));

		// Go Back
		KvRewind(g_hKV);
	}
}

// Load the configs
public OnPluginStart()
{
	// Register commands
	RegConsoleCmd("sm_give", GiveCallback, "Give VIP's Weapons");
	RegConsoleCmd("sm_weapons", InfoCallback, "show Weaponlist");
	RegConsoleCmd("sm_weapon", InfoCallback, "show Weaponlist");
	RegConsoleCmd("sm_guns", InfoCallback, "show Weaponlist");
	RegConsoleCmd("sm_gun", InfoCallback, "show Weaponlist");
	RegConsoleCmd("sm_gunmenu", InfoCallback, "show Weaponlist");
	RegConsoleCmd("sm_giveweapon", InfoCallback, "show Weaponlist");
	
	HookEvent("round_start", RoundStart);

	AutoExecConfig_SetFile("weapons", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);

	g_hMode = AutoExecConfig_CreateConVar("sm_weapons_restrict", "0", "0 - Players on both teams can give weapons themselve, 1 - Only terrorists can give weapons themselves, 2 - Only counter-terrorists can give weapons themselves");
	
	AutoExecConfig_CleanFile();
	AutoExecConfig_ExecuteFile();
}

// Menu handler 
public weaponlist_handler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		if (IsValidClient(param1))
		{
			decl String:choose[64];
				
			GetMenuItem(menu, param2, choose, sizeof(choose));
			
			// Fake command client, explicit to show
			FakeClientCommandEx(param1, "sm_give %s", choose);
		}
	}
}


// Resetz uses
public RoundStart(Handle:event, String:name[], bool:dontBroadcast)
{
	for (new x=0; x <= MaxClients; x++)
	{ 
		g_iUsages[x] = 0;
	}
}





// Also reset usages
public STAMM_OnClientReady(client)
{
	g_iUsages[client] = 0;
}



// Open weapon menu
public Action:InfoCallback(client, args)
{
	if (GetConVarInt(g_hMode) == 1)
	{
		if (GetClientTeam(client) == CS_TEAM_T)
		{
			DisplayMenu(g_hWeaponList, client, 40);
		}
		else
		{
			CPrintToChat(client, "%t", "CTCanNotGive");
		}
	}
	else if (GetConVarInt(g_hMode) == 2)
	{
		if (GetClientTeam(client) == CS_TEAM_CT)
		{
			DisplayMenu(g_hWeaponList, client, 40);
		}
		else
		{
			CPrintToChat(client, "%t", "TCanNotGive");
		}
	}
	else
	{
		DisplayMenu(g_hWeaponList, client, 40);
	}
	return Plugin_Handled;
}

// Give a weapon
public Action:GiveCallback(client, args)
{
	if (IsValidClient(client))
	{


			if (GetCmdArgs() == 1)
			{
				if (GetConVarInt(g_hMode) == 1)
				{
					if (GetClientTeam(client) == CS_TEAM_CT)
					{
						CPrintToChat(client, "%t", "CTCanNotGive");

						return Plugin_Handled;
					}
				}
				else if (GetConVarInt(g_hMode) == 2)
				{
					if (GetClientTeam(client) == CS_TEAM_T)
					{
						CPrintToChat(client, "%t", "TCanNotGive");

						return Plugin_Handled;
					}
				}

				// max. usages not reached
				if (g_iUsages[client] < g_iMaximum)
				{
					decl String:WeaponName[64];
					
					GetCmdArg(1, WeaponName, sizeof(WeaponName));

					// Add weapon tag
					Format(WeaponName, sizeof(WeaponName), "weapon_%s", WeaponName);


					// Enabled?
					if (KvGetNum(g_hKV, WeaponName))
					{
						// Give Item
						GivePlayerItem(client, WeaponName);
						
						g_iUsages[client]++;
					}
					else 
					{
						CPrintToChat(client, "%t", "WeaponFailed");
					}
				}
				else
				{
					CPrintToChat(client, "%t", "MaximumReached");
				}
			}
			else 
			{
				CPrintToChat(client, "%t", "WeaponFailed");
			}
	}

	return Plugin_Handled;
}