/*
 * MyJailbreak - Ratio - CT Ban Support.
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
#include <cstrike>
#include <colors>
#include <mystocks>
#include <clientprefs>

// Optional Plugins
#undef REQUIRE_PLUGIN
#include <myjailbreak>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Handles
Handle g_hCookieCTBan;

// Info
public Plugin myinfo = {
	name = "MyJailbreak - Ratio - CT Ban Support", 
	author = "shanapu, Addicted, good_live", 
	description = "Adds support for databombs CT Bans plugin to MyJB ratio", 
	version = MYJB_VERSION, 
	url = MYJB_URL_LINK
};

// Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Ratio.phrases");
	
	// Cookies
	if ((g_hCookieCTBan = FindClientCookie("Banned_From_CT")) == INVALID_HANDLE)
		g_hCookieCTBan = RegClientCookie("Banned_From_CT", "Tells if you are restricted from joining the CT team", CookieAccess_Protected);
}

public void OnAllPluginsLoaded()
{
	if (!LibraryExists("myratio"))
		SetFailState("You're missing the MyJailbreak - Ratio (ratio.smx) plugin");
}

public Action MyJailbreak_OnJoinGuardQueue(int client)
{
	char szCookie[2];
	GetClientCookie(client, g_hCookieCTBan, szCookie, sizeof(szCookie));
	if (szCookie[0] == '1')
	{
		CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_banned");
		PrintCenterText(client, "%t", "ratio_banned_nc");
		FakeClientCommand(client, "sm_isbanned @me");
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
