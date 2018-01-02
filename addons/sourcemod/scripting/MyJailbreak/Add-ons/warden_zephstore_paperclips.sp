/*
 * MyJailbreak Warden - Zephyrus store PaperClips
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

// Integers
int g_iRoundLimit[MAXPLAYERS+1] = {0,...};

// ConVars
ConVar gc_iRoundLimit;
ConVar gc_iAmount;

char g_sPrefix[64];

// Info
public Plugin myinfo = {
	name = "MyJailbreak - Wardens Paperclips Support for Zephyrus Store",
	author = "shanapu",
	description = "Adds support for MyJB wardens paperclips to Zephyrus Store plugin",
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
};

public void OnPluginStart()
{
	Store_RegisterHandler("paperclips", "", PaperClips_OnMapStart, PaperClips_Reset, PaperClips_Config, PaperClips_Equip, PaperClips_Remove, false);

	AutoExecConfig_SetFile("plugin.store");
	AutoExecConfig_SetCreateFile(true);

	gc_iRoundLimit = AutoExecConfig_CreateConVar("sm_store_paperclips_round_limit", "1", "Number of times you can buy paperclips in a round", _, true, 1.0);
	gc_iAmount = AutoExecConfig_CreateConVar("sm_store_paperclips_amount", "2", "Number of paperclips you get", _, true, 1.0);

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	HookEvent("round_start", Event_RoundStart);
}

public void OnConfigsExecuted()
{
	ConVar cBuffer = FindConVar("sm_store_chat_tag");
	cBuffer.GetString(g_sPrefix, sizeof(g_sPrefix));
}

public void Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;

		g_iRoundLimit[i] = 0;
	}
}

public void PaperClips_OnMapStart()
{
}

public void PaperClips_Reset()
{
}

public int PaperClips_Config(Handle kv, int itemid)
{
	Store_SetDataIndex(itemid, 0);

	return true;
}

public int PaperClips_Equip(int client, int id)
{
	if (g_iRoundLimit[client] >= gc_iRoundLimit.IntValue)
	{
		CPrintToChat(client, "%s You have reached the maximum amount of paperclips you can buy this round.", g_sPrefix);
		return 1;
	}

	warden_handcuffs_givepaperclip(client, gc_iAmount.IntValue);

	++g_iRoundLimit[client];
	return 0;
}

public int PaperClips_Remove(int client)
{
	return 0;
}