/*
 * MyJailbreak - Ratio - CT Bans Support.
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
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http:// www.gnu.org/licenses/>.
 */


/******************************************************************************
                   STARTUP
******************************************************************************/


// Includes
#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <colors>
#include <mystocks>
#include <ct_bans>

// Optional Plugins
#undef REQUIRE_PLUGIN
#include <myjailbreak>
#define REQUIRE_PLUGIN


// Compiler Options
#pragma semicolon 1
#pragma newdecls required


// Info
public Plugin myinfo = {
	name = "MyJailbreak - Ratio - CT Bans Support", 
	author = "shanapu, Addicted, good_live", 
	description = "Adds support for FantoMs CT Bans plugin to MyJB ratio", 
	version = MYJB_VERSION, 
	url = MYJB_URL_LINK
};


// Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Ratio.phrases");
	
	HookEvent("player_spawn", Event_OnPlayerSpawn, EventHookMode_Post);
}


public void OnAllPluginsLoaded()
{
	if (!LibraryExists("myratio"))
		SetFailState("You're missing the MyJailbreak - Ratio (ratio.smx) plugin");
}


public Action MyJailbreak_OnJoinGuardQueue(int client)
{
	if (CTB_IsClientBanned(client))
	{
		CPrintToChat(client, "%t %t", "ratio_tag", "ratio_banned");
		return Plugin_Handled;
	}
	return Plugin_Continue;
}


public Action Event_OnPlayerSpawn(Event event, const char[] name, bool bDontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if (GetClientTeam(client) != 3) 
		return Plugin_Continue;
		
	if (!IsValidClient(client, true, false))
		return Plugin_Continue;
	
	if (CTB_IsClientBanned(client))
	{
		CPrintToChat(client, "%t %t", "ratio_tag", "ratio_banned");
		CreateTimer(5.0, Timer_SlayPlayer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		return Plugin_Continue;
	}
	return Plugin_Continue;
}


public Action Timer_SlayPlayer(Handle hTimer, any iUserId) 
{
	int client = GetClientOfUserId(iUserId);
	
	if ((IsValidClient(client, false, false)) && (GetClientTeam(client) == CS_TEAM_CT))
	{
		ForcePlayerSuicide(client);
		ChangeClientTeam(client, CS_TEAM_T);
		CS_RespawnPlayer(client);
		MinusDeath(client);
	}
	return Plugin_Stop;
}


void MinusDeath(int client)
{
	if (IsValidClient(client, true, true))
	{
		int frags = GetEntProp(client, Prop_Data, "m_iFrags");
		int deaths = GetEntProp(client, Prop_Data, "m_iDeaths");
		SetEntProp(client, Prop_Data, "m_iFrags", (frags+1));
		SetEntProp(client, Prop_Data, "m_iDeaths", (deaths-1));
	}
}