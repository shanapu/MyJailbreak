/*
 * MyJailbreak Warden - Zephyrus store Freeday
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
#include <autoexecconfig>
#include <colors>
#include <warden>
#include <myjbwarden>
#include <store>

// Optional Plugins
#undef REQUIRE_PLUGIN
#include <myjailbreak>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required


// Info
public Plugin myinfo = {
	name = "MyJailbreak - Wardens Freeday Support for Zephyrus Store",
	author = "shanapu",
	description = "Adds support for MyJB wardens freeday to Zephyrus Store plugin",
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
};

public void OnPluginStart()
{
	Store_RegisterHandler("freeday", "", Freeday_OnMapStart, Freeday_Reset, Freeday_Config, Freeday_Equip, Freeday_Remove, false);

	AutoExecConfig_SetFile("plugin.store");
	AutoExecConfig_SetCreateFile(true);

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
}


public void Freeday_OnMapStart()
{
}

public void Freeday_Reset()
{
}

public int Freeday_Config(Handle kv, int itemid)
{
	Store_SetDataIndex(itemid, 0);

	return true;
}

public int Freeday_Equip(int client, int id)
{
	warden_freeday_set(client);

	return 0;
}

public int Freeday_Remove(int client)
{
	return 0;
}