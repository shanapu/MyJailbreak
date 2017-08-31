/*
 * ToggleRadar Plugin.
 * by: shanapu
 * 
 * Copyright (C) 2016-2017 Thomas Schmidt (shanapu)
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

//Credits https://github.com/m-khan/MHAN_Funzies/blob/master/scripting/noradar.sp

// Includes
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <mystocks>

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "ToggleRadar",
	author = "shanapu",
	description = "Toggle players radar with !radar",
	version = "1.0",
	url = "https://github.com/shanapu/"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_ttt", Command_radar, "Allows player to toggle the radar.");
}

public Action Command_radar(int client, int args)
{
	SetCvar("mat_showmiplevels", 1);
}