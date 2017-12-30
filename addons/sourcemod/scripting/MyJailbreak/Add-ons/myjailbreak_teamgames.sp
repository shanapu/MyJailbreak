/*
 * MyJailbreak - TeamGames friendly fire Toggle Plugin.
 * by: shanapu
 * https://github.com/shanapu/MyJB-TG-friendlyfire/
 * https://github.com/KissLick/TeamGames
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

// Includes
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <mystocks>
#include <myjailbreak>
#include <teamgames>

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Variables
ConVar Cvar_tg_team_none_attack;
ConVar Cvar_tg_cvar_friendlyfire;
ConVar Cvar_tg_ct_friendlyfire;
int OldCvar_tg_team_none_attack;
int OldCvar_tg_cvar_friendlyfire;
int OldCvar_tg_ct_friendlyfire;

// Info
public Plugin myinfo = {
	name = "MyJailbreak - Teamgames - FF toggle", 
	author = "shanapu", 
	description = "MyJailbreak - toggle TeamGames friendly fire on MyJailbreak eventdays", 
	version = MYJB_VERSION, 
	url = MYJB_URL_LINK
};

public void MyJailbreak_OnEventDayStart(char[] EventDayName)
{
	// Get the Cvar Value
	Cvar_tg_team_none_attack = FindConVar("tg_team_none_attack");
	Cvar_tg_cvar_friendlyfire = FindConVar("tg_cvar_friendlyfire");
	Cvar_tg_ct_friendlyfire = FindConVar("tg_ct_friendlyfire");

	// Save the Cvar Value
	OldCvar_tg_team_none_attack = Cvar_tg_team_none_attack.IntValue;
	OldCvar_tg_cvar_friendlyfire = Cvar_tg_cvar_friendlyfire.IntValue;
	OldCvar_tg_ct_friendlyfire = Cvar_tg_ct_friendlyfire.IntValue;

	// Change the Cvar Value
	Cvar_tg_team_none_attack.IntValue = 1;
	Cvar_tg_cvar_friendlyfire.IntValue = 1;
	Cvar_tg_ct_friendlyfire.IntValue = 1;
}

public void MyJailbreak_OnEventDayEnd(char[] EventDayName, int winner)
{
	// Replace the Cvar Value with old value
	Cvar_tg_team_none_attack.IntValue = OldCvar_tg_team_none_attack;
	Cvar_tg_cvar_friendlyfire.IntValue = OldCvar_tg_cvar_friendlyfire;
	Cvar_tg_ct_friendlyfire.IntValue = OldCvar_tg_ct_friendlyfire;
}

public void MyJailbreak_OnLastGuardRuleStart()
{
	TG_StopGame(TG_ErrorTeam, _, true, true);

	TG_ClearTeam(TG_RedTeam);
	TG_ClearTeam(TG_BlueTeam);

	TG_FenceDestroy();
}

public Action TG_OnPlayerRebel(int client, TG_Team team)
{
	if (MyJailbreak_IsEventDayRunning())
	{
		return Plugin_Handled;
	}
	else return Plugin_Continue;
}