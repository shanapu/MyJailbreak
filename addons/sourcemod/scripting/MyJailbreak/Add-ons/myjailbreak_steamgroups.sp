/*
 * MyJailbreak - Steam Groups Support.
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
 * this program. If not, see <http://www.gnu.org/licenses/>.
 */

/******************************************************************************
                   STARTUP
******************************************************************************/

// Includes
#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <colors>
#include <autoexecconfig>
#include <mystocks>
#include <SteamWorks>

// Optional Plugins
#undef REQUIRE_PLUGIN
#include <myjailbreak>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Console Variables
ConVar gc_iGroupRatio;
ConVar gc_iGroupWarden;

//Bools
bool g_bIsLateLoad = false;
bool IsMemberRatio[MAXPLAYERS+1] = {false, ...};
bool IsMemberWarden[MAXPLAYERS+1] = {false, ...};

// Info
public Plugin myinfo = {
	name = "MyJailbreak - Steam Groups Support for Ratio & Warden", 
	author = "shanapu, Addicted, good_live", 
	description = "Adds support for steam groups to MyJB ratio & warden", 
	version = MYJB_VERSION, 
	url = MYJB_URL_LINK
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_bIsLateLoad = late;

	return APLRes_Success;
}

// Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Ratio.phrases");
	LoadTranslations("MyJailbreak.Warden.phrases");

	// AutoExecConfig
	AutoExecConfig_SetFile("Ratio", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);

	gc_iGroupRatio = AutoExecConfig_CreateConVar("sm_ratio_steamgroup", "0000000", "Steamgroup a player must be member before join CT (Find it on your steam groups edit page) (0000000 = disabled)");

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// AutoExecConfig
	AutoExecConfig_SetFile("Warden", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);

	gc_iGroupWarden = AutoExecConfig_CreateConVar("sm_warden_steamgroup", "0000000", "Steamgroup a player must be member before become Warden (Find it on your steam groups edit page) (0000000 = disabled)");

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks
	HookEvent("player_spawn", Event_OnPlayerSpawn, EventHookMode_Post);

	// Late loading
	if (g_bIsLateLoad)
	{
		LoopClients(i)
		{
			OnClientPostAdminCheck(i);
		}

		g_bIsLateLoad = false;
	}
}

public void OnAllPluginsLoaded()
{
	if (!LibraryExists("myratio") && !LibraryExists("warden"))
	{
		SetFailState("MyJailbreaks Ratio (ratio.smx) and Warden (warden.smx) plugins are missing. You need at least one of them.");
	}
}

public Action warden_OnWardenCreate(int client)
{
	if (!IsMemberWarden[client] && gc_iGroupWarden.IntValue != 0)
	{
		CPrintToChat(client, "%t %t", "warden_tag", "warden_steamgroup");
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action MyJailbreak_OnJoinGuardQueue(int client)
{
	if (!IsMemberRatio[client] && gc_iGroupRatio.IntValue != 0)
	{
		CPrintToChat(client, "%t %t", "ratio_tag", "ratio_steamgroup");
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public void OnClientPostAdminCheck(int client)
{
	SteamWorks_GetUserGroupStatus(client, gc_iGroupRatio.IntValue);
	SteamWorks_GetUserGroupStatus(client, gc_iGroupWarden.IntValue);
}

public int SteamWorks_OnClientGroupStatus(int authid, int groupAccountID, bool isMember, bool isOfficer)
{
	int client = GetUserAuthID(authid);
	if (client == -1)
		return;

	if (isMember)
	{
		if (groupAccountID == gc_iGroupRatio.IntValue) IsMemberRatio[client] = true;
		if (groupAccountID == gc_iGroupWarden.IntValue) IsMemberWarden[client] = true;
	}
	else
	{
		IsMemberWarden[client] = false;
		IsMemberRatio[client] = false;
	}
}

int GetUserAuthID(int authid)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i)) return -1;
		
		char[] charauth = new char[64];
		char[] authchar = new char[64];
		GetClientAuthId(i, AuthId_Steam3, charauth, 64);
		IntToString(authid, authchar, 64);
		if(StrContains(charauth, authchar) != -1) return i;
	}
	
	return -1;
}

public void OnClientDisconnect(int client)
{
	IsMemberRatio[client] = false;
	IsMemberWarden[client] = false;
}

public Action Event_OnPlayerSpawn(Event event, const char[] name, bool bDontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (GetClientTeam(client) != 3) 
		return Plugin_Continue;

	if (!IsValidClient(client, false, false))
		return Plugin_Continue;

	if (!IsMemberRatio[client] && gc_iGroupRatio.IntValue != 0)
	{
		CPrintToChat(client, "%t %t", "ratio_tag", "ratio_steamgroup");
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