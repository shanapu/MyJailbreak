/*
 * MyJailbreak Warden - Custom Module
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
                   EDIT HERE
******************************************************************************/

#define COUNTDOWN_MSG "Warden countdown:"
#define COUNTDOWN_TIME 10
#define COUNTDOWN_SEC "seconds"
#define TIMER_MSG "Padli příkazy!"

/******************************************************************************
                   EDIT HERE
******************************************************************************/





#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <colors>
#include <warden>

#pragma semicolon 1
#pragma newdecls required

Handle g_hTimer;

int g_iTime;

bool g_bRoundStart = false;

public Plugin myinfo = {
	name = "MyJailbreak - Warden Custom Module",
	author = "shanapu",
	description = "Custom Module for MyJailbreaks Warden",
	version = "1.0",
	url = "https://github.com/shanapu"
};

public void OnPluginStart() 
{
	LoadTranslations("MyJailbreak.Warden.phrases");

	HookEvent("round_prestart", Event_PreRoundStart);
}

public void Event_PreRoundStart(Event event, char[] name, bool dontBroadcast)
{
	g_bRoundStart = true;
	CreateTimer(1.0, Timer_RoundStart);
}

public Action Timer_RoundStart(Handle tmr)
{
	g_bRoundStart = false;
}

public Action warden_OnWardenCreate(int client, int caller)
{
	CreateTimer(0.1, Timer_Create);
}

public Action Timer_Create(Handle tmr)
{
	if (warden_exist())
		delete g_hTimer;
}

public void warden_OnWardenRemoved(int client)
{
	g_iTime = COUNTDOWN_TIME;

	if (GetAlivePlayersCount(CS_TEAM_CT) > 1 && !g_bRoundStart)
	{
		g_hTimer = CreateTimer(1.0, Timer_Notification, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Timer_Notification(Handle tmr)
{
	if (g_iTime > 1)
	{
		g_iTime--;

		PrintCenterTextAll("%s %i %s", COUNTDOWN_MSG, g_iTime, COUNTDOWN_SEC);

		return Plugin_Continue;
	}

	PrintCenterTextAll("%s", TIMER_MSG);
	CPrintToChatAll("%t %s", "warden_tag", TIMER_MSG);

	g_hTimer = null;

	return Plugin_Stop;
}

int GetAlivePlayersCount(int team)
{
	int iCount, i; iCount = 0;

	for (i = 1; i <= MaxClients; i++)
		if (IsClientConnected(i) && IsPlayerAlive(i) && GetClientTeam(i) == team)
		iCount++;

	return iCount;
}