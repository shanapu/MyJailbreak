/*
 * MyJailbreak - Player Tags Plugin.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
 * 
 * Copyright (C) 2016-2017 Thomas Schmidt (shanapu)
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
 * this program. If not, see <http://www.gnu.org/licenses/>.
 */

/******************************************************************************
                   STARTUP
******************************************************************************/

// Includes
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <autoexecconfig>
#include <mystocks>

// Optional Plugins
#undef REQUIRE_PLUGIN
#include <myjailbreak>
#include <chat-processor>
#include <ccc>
#include <store>
#include <togsclantags>
#include <warden>
#include <myjbwarden>

#tryinclude <scp>
#if !defined _scp_included
#include <cp-scp-wrapper>
#endif
#define REQUIRE_PLUGIN


// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Booleans
bool gp_bChatProcessor = false;
bool gp_bStore = false;
bool gp_bCCC = false;
bool gp_bTOGsTags = false;
bool gp_bMyJBWarden = false;
bool gp_bWarden = false;

// Console Variables
ConVar gc_bPlugin;
ConVar gc_bStats;
ConVar gc_bChat;
ConVar gc_bExtern;
ConVar gc_bNoOverwrite;

// Enum
enum g_eROLES
{
	SPECTATOR,
	GUARD,
	DEPUTY,
	WARDEN,
	PRISONER
}

// Strings
char g_sConfigFile[64];
char g_sChatTag[MAXPLAYERS + 1][g_eROLES][64];
char g_sStatsTag[MAXPLAYERS + 1][g_eROLES][64];
char g_sPlayerTag[MAXPLAYERS + 1][64];

// Info
public Plugin myinfo =
{
	name = "MyJailbreak - PlayerTags",
	description = "Define player tags in chat & stats for Jailbreak Server",
	author = "shanapu",
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
}

// Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.PlayerTags.phrases");

	// AutoExecConfig
	AutoExecConfig_SetFile("PlayerTags", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);

	AutoExecConfig_CreateConVar("sm_playertag_version", MYJB_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_playertag_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true, 0.0, true, 1.0);
	gc_bStats = AutoExecConfig_CreateConVar("sm_playertag_stats", "1", "0 - disabled, 1 - enable PlayerTag in stats", _, true, 0.0, true, 1.0);
	gc_bChat = AutoExecConfig_CreateConVar("sm_playertag_chat", "1", "0 - disabled, 1 - enable PlayerTag in chat", _, true, 0.0, true, 1.0);
	gc_bExtern = AutoExecConfig_CreateConVar("sm_playertag_extern", "1", "0 - disabled, 1 - don't overwrite chat tags given by extern plugins ccc, togsclantags or zephyrus store", _, true, 0.0, true, 1.0);
	gc_bNoOverwrite = AutoExecConfig_CreateConVar("sm_playertag_overwrite", "1", "0 - if no tag is set in config clear the tag (show nothing) / 1 - if no tag is set in config show players steam group tag", _, true, 0.0, true, 1.0);

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks - Events to check for Tag
	HookEvent("player_connect", Event_CheckTag);
	HookEvent("player_team", Event_CheckTag);
	HookEvent("player_spawn", Event_CheckTag);
	HookEvent("player_death", Event_CheckTag);
	HookEvent("round_start", Event_CheckTag);

	BuildPath(Path_SM, g_sConfigFile, sizeof(g_sConfigFile), "configs/MyJailbreak/player_tags.cfg");
}

// Check for supported plugins
public void OnAllPluginsLoaded()
{
	gp_bChatProcessor = LibraryExists("chat-processor");
	gp_bCCC = LibraryExists("ccc");
	gp_bTOGsTags = LibraryExists("togsclantags");
	gp_bStore = LibraryExists("store");
	gp_bWarden = LibraryExists("warden");
	gp_bMyJBWarden = LibraryExists("myjbwarden");
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "chat-processor"))
		gp_bChatProcessor = false;

	else if (StrEqual(name, "ccc"))
		gp_bCCC = false;

	else if (StrEqual(name, "togsclantags"))
		gp_bTOGsTags = false;

	else if (StrEqual(name, "store"))
		gp_bStore = false;

	else if (StrEqual(name, "warden"))
		gp_bWarden = false;

	else if (StrEqual(name, "myjbwarden"))
		gp_bMyJBWarden = false;
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "chat-processor"))
		gp_bChatProcessor = true;

	else if (StrEqual(name, "ccc"))
		gp_bCCC = true;

	else if (StrEqual(name, "togsclantags"))
		gp_bTOGsTags = true;

	else if (StrEqual(name, "store"))
		gp_bStore = true;

	else if (StrEqual(name, "warden"))
		gp_bWarden = true;

	else if (StrEqual(name, "myjbwarden"))
		gp_bMyJBWarden = true;

}

/******************************************************************************
                   EVENTS
******************************************************************************/

public void Event_CheckTag(Event event, char[] name, bool dontBroadcast)
{
	CreateTimer(1.0, Timer_DelayCheck);
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

public void OnClientPostAdminCheck(int client)
{
	CS_GetClientClanTag(client, g_sPlayerTag[client], sizeof(g_sPlayerTag[]));

	// Search for matching tag in cfg
	LoadPlayerTags(client);

	// Apply tag first time
	HandleTag(client);
}

public void warden_OnWardenCreatedByUser(int client)
{
	HandleTag(client);
}

public void warden_OnWardenCreatedByAdmin(int client)
{
	HandleTag(client);
}

public void warden_OnWardenRemoved(int client)
{
	CreateTimer(1.0, Timer_DelayCheck);
}

/******************************************************************************
                   TIMER
******************************************************************************/

public Action Timer_DelayCheck(Handle timer) 
{
	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
	{
		HandleTag(i);
	}
}

/******************************************************************************
                   FUNCTIONS
******************************************************************************/

void LoadPlayerTags(int client)
{
	Handle hFile = OpenFile(g_sConfigFile, "rt");

	if (!hFile)
	{
		SetFailState("MyJailbreak PlayerTags - Can't open File: %s", g_sConfigFile);
		return;
	}

	KeyValues kvMenu = new KeyValues("PlayerTags");

	if (!kvMenu.ImportFromFile(g_sConfigFile))
	{
		SetFailState("MyJailbreak PlayerTags - Can't read %s correctly! (ImportFromFile)", g_sConfigFile);
		return;
	}

	char steamid[24];
	if (!GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid)))
	{
		LogError("COULDN'T GET STEAMID of %L", client);
		return;
	}

	// Check SteamID
	if (kvMenu.JumpToKey(steamid, false))
	{
		GetTags(client, kvMenu);

		delete kvMenu;
		return;
	}

	// Check SteamID again with bad steam universe
	steamid[6] = '0';

	if (kvMenu.JumpToKey(steamid, false))
	{
		GetTags(client, kvMenu);

		delete kvMenu;
		return;
	}

	// Check groups
	AdminId admin = GetUserAdmin(client);
	if (admin != INVALID_ADMIN_ID)
	{
		char sGroup[32];
		admin.GetGroup(0, sGroup, sizeof(sGroup));
		Format(sGroup, sizeof(sGroup), "@%s", sGroup);
		
		if (kvMenu.JumpToKey(sGroup))
		{
			GetTags(client, kvMenu);
			return;
		}
	}
	
	// Check flags
	char[] sFlags = "abcdefghijklnmopqrstz"; //Idk if it's required 'z' here

	// backwards loop
	for (int i = strlen(sFlags)-1; i >= 0 ; i--)
	{
		if (GetUserFlagBits(client) & ReadFlagString(sFlags[i]))
			if (kvMenu.JumpToKey(sFlags[i]))
			{
				GetTags(client, kvMenu);
				
				delete kvMenu;
				return;
			}
	}

	// use the default tags
	if (kvMenu.JumpToKey("default", false))
	{
		GetTags(client, kvMenu);
	}

	delete kvMenu;
}

void GetTags(int client, KeyValues kvMenu)
{
	kvMenu.GetString("spectator", g_sStatsTag[client][SPECTATOR], sizeof(g_sStatsTag), "");
	kvMenu.GetString("warden", g_sStatsTag[client][WARDEN], sizeof(g_sStatsTag), "");
	kvMenu.GetString("deputy", g_sStatsTag[client][DEPUTY], sizeof(g_sStatsTag), "");
	kvMenu.GetString("guard", g_sStatsTag[client][GUARD], sizeof(g_sStatsTag), "");
	kvMenu.GetString("prisoner", g_sStatsTag[client][PRISONER], sizeof(g_sStatsTag), "");

	kvMenu.GetString("spectator_chat", g_sChatTag[client][SPECTATOR], sizeof(g_sChatTag), "");
	kvMenu.GetString("warden_chat", g_sChatTag[client][WARDEN], sizeof(g_sChatTag), "");
	kvMenu.GetString("deputy_chat", g_sChatTag[client][DEPUTY], sizeof(g_sChatTag), "");
	kvMenu.GetString("guard_chat", g_sChatTag[client][GUARD], sizeof(g_sChatTag), "");
	kvMenu.GetString("prisoner_chat", g_sChatTag[client][PRISONER], sizeof(g_sChatTag), "");
}

// Give Tag
void HandleTag(int client)
{
	if (!gc_bPlugin.BoolValue)
		return;

	if (!gc_bStats.BoolValue || !IsValidClient(client, true, true))
		return;

	if (gp_bTOGsTags && !gc_bExtern.BoolValue)
	{
		if (TOGsClanTags_HasAnyTag(client))
			return;
	}

	if (GetClientTeam(client) == CS_TEAM_T)
	{
		if (gc_bNoOverwrite.BoolValue && strlen(g_sStatsTag[client][PRISONER]) < 1)
		{
			CS_SetClientClanTag(client, g_sPlayerTag[client]);
		}
		else
		{
			CS_SetClientClanTag(client, g_sStatsTag[client][PRISONER]);
		}
	}
	else if (GetClientTeam(client) == CS_TEAM_CT)
	{
		if (gp_bWarden && warden_iswarden(client))
		{
			if (gc_bNoOverwrite.BoolValue && strlen(g_sStatsTag[client][WARDEN]) < 1)
			{
				CS_SetClientClanTag(client, g_sPlayerTag[client]);
			}
			else
			{
				CS_SetClientClanTag(client, g_sStatsTag[client][WARDEN]);
			}
		}
		else if (gp_bMyJBWarden && warden_deputy_isdeputy(client))
		{
			if (gc_bNoOverwrite.BoolValue && strlen(g_sStatsTag[client][DEPUTY]) < 1)
			{
				CS_SetClientClanTag(client, g_sPlayerTag[client]);
			}
			else
			{
				CS_SetClientClanTag(client, g_sStatsTag[client][DEPUTY]);
			}
		}
		else
		{
			if (gc_bNoOverwrite.BoolValue && strlen(g_sStatsTag[client][GUARD]) < 1)
			{
				CS_SetClientClanTag(client, g_sPlayerTag[client]);
			}
			else
			{
				CS_SetClientClanTag(client, g_sStatsTag[client][GUARD]);
			}
		}
	}
	else if (GetClientTeam(client) == CS_TEAM_SPECTATOR)
	{
		if (gc_bNoOverwrite.BoolValue && strlen(g_sStatsTag[client][SPECTATOR]) < 1)
		{
			CS_SetClientClanTag(client, g_sPlayerTag[client]);
		}
		else
		{
			CS_SetClientClanTag(client, g_sStatsTag[client][SPECTATOR]);
		}
	}
}

// Check Chat & add Tag
public Action CP_OnChatMessage(int &client, ArrayList recipients, char[] flagstring, char[] name, char[] message, bool& processcolors, bool& removecolors)
{
	if (!gc_bPlugin.BoolValue || !gp_bChatProcessor)
		return Plugin_Continue;

	if (!gc_bChat.BoolValue)
		return Plugin_Continue;

	if (gp_bCCC && !gc_bExtern.BoolValue)
	{
		char sColor[32];
		CCC_GetTag(client, sColor, sizeof(sColor));

		if (strlen(sColor) > 0)
			return Plugin_Continue;
	}

	if (gp_bTOGsTags && !gc_bExtern.BoolValue)
	{
		if (TOGsClanTags_HasAnyTag(client))
			return Plugin_Continue;
	}

	if (gp_bStore && !gc_bExtern.BoolValue)
	{
		if (Store_GetEquippedItem(client, "nametag") < 0 && 
			Store_GetEquippedItem(client, "namecolor") < 0 && 
			Store_GetEquippedItem(client, "msgcolor") < 0)
			return Plugin_Continue;
	}

	if (GetClientTeam(client) == CS_TEAM_T)
	{
		if (gc_bNoOverwrite.BoolValue && strlen(g_sChatTag[client][PRISONER]) < 1)
		{
			Format(name, MAXLENGTH_NAME, "%s %s", g_sPlayerTag[client], name);
		}
		else
		{
			Format(name, MAXLENGTH_NAME, "%s %s", g_sChatTag[client][PRISONER], name);
		}
	}
	else if (GetClientTeam(client) == CS_TEAM_CT)
	{
		if (gp_bWarden && warden_iswarden(client))
		{
			if (gc_bNoOverwrite.BoolValue && strlen(g_sChatTag[client][WARDEN]) < 1)
			{
				Format(name, MAXLENGTH_NAME, "%s %s", g_sPlayerTag[client], name);
			}
			else
			{
				Format(name, MAXLENGTH_NAME, "%s %s", g_sChatTag[client][WARDEN], name);
			}
		}
		else if (gp_bMyJBWarden && warden_deputy_isdeputy(client))
		{
			if (gc_bNoOverwrite.BoolValue && strlen(g_sChatTag[client][DEPUTY]) < 1)
			{
				Format(name, MAXLENGTH_NAME, "%s %s", g_sPlayerTag[client], name);
			}
			else
			{
				Format(name, MAXLENGTH_NAME, "%s %s", g_sChatTag[client][DEPUTY], name);
			}
		}
		else
		{
			if (gc_bNoOverwrite.BoolValue && strlen(g_sChatTag[client][GUARD]) < 1)
			{
				Format(name, MAXLENGTH_NAME, "%s %s", g_sPlayerTag[client], name);
			}
			else
			{
				Format(name, MAXLENGTH_NAME, "%s %s", g_sChatTag[client][GUARD], name);
			}
		}
	}
	else if (GetClientTeam(client) == CS_TEAM_SPECTATOR)
	{
		if (gc_bNoOverwrite.BoolValue && strlen(g_sChatTag[client][SPECTATOR]) < 1)
		{
			Format(name, MAXLENGTH_NAME, "%s %s", g_sPlayerTag[client], name);
		}
		else
		{
			Format(name, MAXLENGTH_NAME, "%s %s", g_sChatTag[client][SPECTATOR], name);
		}
	}

	Format(message, MAXLENGTH_MESSAGE, "{default}%s", message);

	return Plugin_Changed;
}

public Action OnChatMessage(int &client, Handle recipients, char[] name, char[] message)
{
	if (!gc_bPlugin.BoolValue || !gp_bChatProcessor)
		return Plugin_Continue;

	if (!gc_bChat.BoolValue)
		return Plugin_Continue;

	if (gp_bCCC && !gc_bExtern.BoolValue)
	{
		char sColor[32];
		CCC_GetTag(client, sColor, sizeof(sColor));

		if (strlen(sColor) > 0)
			return Plugin_Continue;
	}

	if (gp_bTOGsTags && !gc_bExtern.BoolValue)
	{
		if (TOGsClanTags_HasAnyTag(client))
			return Plugin_Continue;
	}

	if (gp_bStore && !gc_bExtern.BoolValue)
	{
		if (Store_GetEquippedItem(client, "nametag") < 0 && 
			Store_GetEquippedItem(client, "namecolor") < 0 && 
			Store_GetEquippedItem(client, "msgcolor") < 0)
			return Plugin_Continue;
	}

	if (GetClientTeam(client) == CS_TEAM_T)
	{
		if (gc_bNoOverwrite.BoolValue && strlen(g_sChatTag[client][PRISONER]) < 1)
		{
			Format(name, MAXLENGTH_NAME, "%s %s", g_sPlayerTag[client], name);
		}
		else
		{
			Format(name, MAXLENGTH_NAME, "%s %s", g_sChatTag[client][PRISONER], name);
		}
	}
	else if (GetClientTeam(client) == CS_TEAM_CT)
	{
		if (gp_bWarden && warden_iswarden(client))
		{
			if (gc_bNoOverwrite.BoolValue && strlen(g_sChatTag[client][WARDEN]) < 1)
			{
				Format(name, MAXLENGTH_NAME, "%s %s", g_sPlayerTag[client], name);
			}
			else
			{
				Format(name, MAXLENGTH_NAME, "%s %s", g_sChatTag[client][WARDEN], name);
			}
		}
		else if (gp_bMyJBWarden && warden_deputy_isdeputy(client))
		{
			if (gc_bNoOverwrite.BoolValue && strlen(g_sChatTag[client][DEPUTY]) < 1)
			{
				Format(name, MAXLENGTH_NAME, "%s %s", g_sPlayerTag[client], name);
			}
			else
			{
				Format(name, MAXLENGTH_NAME, "%s %s", g_sChatTag[client][DEPUTY], name);
			}
		}
		else
		{
			if (gc_bNoOverwrite.BoolValue && strlen(g_sChatTag[client][GUARD]) < 1)
			{
				Format(name, MAXLENGTH_NAME, "%s %s", g_sPlayerTag[client], name);
			}
			else
			{
				Format(name, MAXLENGTH_NAME, "%s %s", g_sChatTag[client][GUARD], name);
			}
		}
	}
	else if (GetClientTeam(client) == CS_TEAM_SPECTATOR)
	{
		if (gc_bNoOverwrite.BoolValue && strlen(g_sChatTag[client][SPECTATOR]) < 1)
		{
			Format(name, MAXLENGTH_NAME, "%s %s", g_sPlayerTag[client], name);
		}
		else
		{
			Format(name, MAXLENGTH_NAME, "%s %s", g_sChatTag[client][SPECTATOR], name);
		}
	}

	return Plugin_Changed;
}