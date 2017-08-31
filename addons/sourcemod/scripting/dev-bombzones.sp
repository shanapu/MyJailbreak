/*
 * Custom Bomb Spots
 * by: shanapu
 * https://github.com/shanapu/
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


#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <devzones>

bool bBomb[MAXPLAYERS + 1];

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = {
	name = "Custom Bomb Spots - Dev-Zones module",
	author = "shanapu",
	description = "Add custom Bomb Spots with Dev-Zones",
	version = "1.0",
	url = "https://github.com/shanapu/"
};

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_PostThink, OnPostThink);
}

public OnPluginStart()
{
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("bomb_exploded",Event_BombExploded);
}

public void Event_BombExploded(Event event, char[] name, bool dontBroadcast)
{
	CS_TerminateRound(5.0, CSRoundEnd_TargetBombed);
}

public void Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	int client = GetRandomTerror();
	GivePlayerItem(client, "weapon_c4");
}

public Event_PlayerSpawn(Handle event,char [] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	bBomb[client] = false;

	if ((GetClientTeam(client) == CS_TEAM_CT)
	{
		SetEntProp(client, Prop_Send, "m_bHasDefuser", 1);
	}
}

public void OnPostThink(int client)
{
	if (bBomb[client])
	{
		SetEntProp(client, Prop_Send, "m_bInBombZone", 1);
	}
	else
	{
		SetEntProp(client, Prop_Send, "m_bInBombZone", 0);
	}
}

public int Zone_OnClientEntry(int client, char [] zone)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client))
		return;

	if(StrContains(zone, "bombspot", false) != 0)
		return;

	bBomb[client] = true;
}

public int Zone_OnClientLeave(int client, char [] zone)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client))
		return;

	if(StrContains(zone, "bombspot", false) != 0)
		return;

	bBomb[client] = false;
}

int GetRandomTerror()
{
	int[] clients = new int[MaxClients];
	int clientCount;

	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
	{
		if ((GetClientTeam(i) == CS_TEAM_T) && IsPlayerAlive(i))
		{
			clients[clientCount++] = i;
		}
	}

	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)];
}