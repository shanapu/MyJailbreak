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
#include <chat-processor>
#include <autoexecconfig>
#include <warden>
#include <mystocks>
#include <myjailbreak>

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Booleans
bool g_bIsLateLoad = false;

// Console Variables
ConVar gc_bPlugin;
ConVar gc_bStats;
ConVar gc_bChat;
ConVar gc_sOwnerFlag;
ConVar gc_sAdminFlag;
ConVar gc_sVIPFlag;
ConVar gc_sVIP2Flag;
ConVar gc_bNoOverwrite;

// Strings
char g_sAdminFlag[4];
char g_sOwnerFlag[32];
char g_sVIP2Flag[32];
char g_sVIPFlag[32];

// Info
public Plugin myinfo =
{
	name = "MyJailbreak - PlayerTags",
	description = "Define player tags in chat & stats for Jailbreak Server",
	author = "shanapu",
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_bIsLateLoad = late;

	return APLRes_Success;
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
	gc_sOwnerFlag = AutoExecConfig_CreateConVar("sm_playertag_ownerflag", "z", "Set the flag for Owner");
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_playertag_adminflag", "d", "Set the flag for admin");
	gc_sVIPFlag = AutoExecConfig_CreateConVar("sm_playertag_vipflag", "t", "Set the flag for VIP");
	gc_sVIP2Flag = AutoExecConfig_CreateConVar("sm_playertag_vip2flag", "a", "Set the flag for VIP2");
	gc_bNoOverwrite = AutoExecConfig_CreateConVar("sm_playertag_overwrite", "1", "0 - only show tags for warden, deputy, admin & vip (no overwrite for prisionor & guards) 1 - enable tags for prisoner & guards, too", _, true, 0.0, true, 1.0);

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks - Events to check for Tag
	HookEvent("player_connect", Event_CheckTag);
	HookEvent("player_team", Event_CheckTag);
	HookEvent("player_spawn", Event_CheckTag);
	HookEvent("player_death", Event_CheckTag);
	HookEvent("round_start", Event_CheckTag);

	// FindConVar
	gc_sOwnerFlag.GetString(g_sOwnerFlag, sizeof(g_sOwnerFlag));
	gc_sAdminFlag.GetString(g_sAdminFlag, sizeof(g_sAdminFlag));
	gc_sVIPFlag.GetString(g_sVIPFlag, sizeof(g_sVIPFlag));
	gc_sVIP2Flag.GetString(g_sVIP2Flag, sizeof(g_sVIP2Flag));

	// Late loading
	if (g_bIsLateLoad)
	{
		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
		{
			OnClientPutInServer(i);
		}

		g_bIsLateLoad = false;
	}
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


public void OnClientPutInServer(int client)
{
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

// Give Tag
void HandleTag(int client)
{
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bStats.BoolValue && IsValidClient(client, true, true))
		{
			char tags[64];
			
			if (GetClientTeam(client) == CS_TEAM_T)
			{
				if (CheckVipFlag(client, g_sOwnerFlag))
				{
					Format(tags, sizeof(tags), "%t", "tags_TOWN", LANG_SERVER);
					CS_SetClientClanTag(client, tags);
				}
				else if (CheckVipFlag(client, g_sAdminFlag))
				{
					Format(tags, sizeof(tags), "%t", "tags_TA", LANG_SERVER);
					CS_SetClientClanTag(client, tags);
				}
				else if (CheckVipFlag(client, g_sVIPFlag))
				{
					Format(tags, sizeof(tags), "%t", "tags_TVIP1", LANG_SERVER);
					CS_SetClientClanTag(client, tags);
				}
				else if (CheckVipFlag(client, g_sVIP2Flag))
				{
					Format(tags, sizeof(tags), "%t", "tags_TVIP2", LANG_SERVER);
					CS_SetClientClanTag(client, tags);
				}
				else if (gc_bNoOverwrite.BoolValue)
				{
					Format(tags, sizeof(tags), "%t", "tags_T", LANG_SERVER);
					CS_SetClientClanTag(client, tags);
				}
			}
			else if (GetClientTeam(client) == CS_TEAM_CT)
			{
				if (warden_iswarden(client))
				{
					if (CheckVipFlag(client, g_sOwnerFlag))
					{
						Format(tags, sizeof(tags), "%t", "tags_WOWN", LANG_SERVER);
						CS_SetClientClanTag(client, tags);
					}
					else if (CheckVipFlag(client, g_sAdminFlag))
					{
						Format(tags, sizeof(tags), "%t", "tags_WA", LANG_SERVER);
						CS_SetClientClanTag(client, tags);
					}
					else if (CheckVipFlag(client, g_sVIPFlag))
					{
						Format(tags, sizeof(tags), "%t", "tags_WVIP1", LANG_SERVER);
						CS_SetClientClanTag(client, tags);
					}
					else if (CheckVipFlag(client, g_sVIP2Flag))
					{
						Format(tags, sizeof(tags), "%t", "tags_WVIP2", LANG_SERVER);
						CS_SetClientClanTag(client, tags);
					}
					else if (gc_bNoOverwrite.BoolValue)
					{
						Format(tags, sizeof(tags), "%t", "tags_W", LANG_SERVER);
						CS_SetClientClanTag(client, tags);
					}
				}
				else if (warden_deputy_isdeputy(client))
				{
					if (CheckVipFlag(client, g_sOwnerFlag))
					{
						Format(tags, sizeof(tags), "%t", "tags_DOWN", LANG_SERVER);
						CS_SetClientClanTag(client, tags);
					}
					else if (CheckVipFlag(client, g_sAdminFlag))
					{
						Format(tags, sizeof(tags), "%t", "tags_DA", LANG_SERVER);
						CS_SetClientClanTag(client, tags);
					}
					else if (CheckVipFlag(client, g_sVIPFlag))
					{
						Format(tags, sizeof(tags), "%t", "tags_DVIP1", LANG_SERVER);
						CS_SetClientClanTag(client, tags);
					}
					else if (CheckVipFlag(client, g_sVIP2Flag))
					{
						Format(tags, sizeof(tags), "%t", "tags_DVIP2", LANG_SERVER);
						CS_SetClientClanTag(client, tags);
					}
					else if (gc_bNoOverwrite.BoolValue)
					{
						Format(tags, sizeof(tags), "%t", "tags_D", LANG_SERVER);
						CS_SetClientClanTag(client, tags);
					}
				}
				else if (CheckVipFlag(client, g_sOwnerFlag))
				{
					Format(tags, sizeof(tags), "%t", "tags_CTOWN", LANG_SERVER);
					CS_SetClientClanTag(client, tags);
				}
				else if (CheckVipFlag(client, g_sAdminFlag))
				{
					Format(tags, sizeof(tags), "%t", "tags_CTA", LANG_SERVER);
					CS_SetClientClanTag(client, tags);
				}
				else if (CheckVipFlag(client, g_sVIPFlag))
				{
					Format(tags, sizeof(tags), "%t", "tags_CTVIP1", LANG_SERVER);
					CS_SetClientClanTag(client, tags);
				}
				else if (CheckVipFlag(client, g_sVIP2Flag))
				{
					Format(tags, sizeof(tags), "%t", "tags_CTVIP2", LANG_SERVER);
					CS_SetClientClanTag(client, tags);
				}
				else if (gc_bNoOverwrite.BoolValue)
				{
					Format(tags, sizeof(tags), "%t", "tags_CT", LANG_SERVER);
					CS_SetClientClanTag(client, tags);
				}
			}
		}
	}
}

// Check Chat & add Tag
public Action CP_OnChatMessage(int& author, ArrayList recipients, char[] flagstring, char[] name, char[] message, bool& processcolors, bool& removecolors)
{
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bChat.BoolValue)
		{
			if (GetClientTeam(author) == CS_TEAM_T) 
			{
				if (CheckVipFlag(author, g_sOwnerFlag))
				{
					Format(name, MAXLENGTH_NAME, "%t %s", "tags_TOWN_chat", name);
				}
				else if (CheckVipFlag(author, g_sAdminFlag))
				{
					Format(name, MAXLENGTH_NAME, "%t %s", "tags_TA_chat", name);
				}
				else if (CheckVipFlag(author, g_sVIPFlag))
				{
					Format(name, MAXLENGTH_NAME, "%t %s", "tags_TVIP1_chat", name);
				}
				else if (CheckVipFlag(author, g_sVIP2Flag))
				{
					Format(name, MAXLENGTH_NAME, "%t %s", "tags_TVIP2_chat", name);
				}
				else if (gc_bNoOverwrite.BoolValue)
				{
					Format(name, MAXLENGTH_NAME, "%t %s", "tags_T_chat", name);
				}
			}
			else if (GetClientTeam(author) == CS_TEAM_CT)
			{
				if (warden_iswarden(author))
				{
					if (CheckVipFlag(author, g_sOwnerFlag))
					{
						Format(name, MAXLENGTH_NAME, "%t %s", "tags_WOWN_chat", name);
					}
					else if (CheckVipFlag(author, g_sAdminFlag))
					{
						Format(name, MAXLENGTH_NAME, "%t %s", "tags_WA_chat", name);
					}
					else if (CheckVipFlag(author, g_sVIPFlag))
					{
						Format(name, MAXLENGTH_NAME, "%t %s", "tags_WVIP1_chat", name);
					}
					else if (CheckVipFlag(author, g_sVIP2Flag))
					{
						Format(name, MAXLENGTH_NAME, "%t %s", "tags_WVIP2_chat", name);
					}
					else if (gc_bNoOverwrite.BoolValue)
					{
						Format(name, MAXLENGTH_NAME, "%t %s", "tags_W_chat", name);
					}
				}
				else if (warden_deputy_isdeputy(author))
				{
					if (CheckVipFlag(author, g_sOwnerFlag))
					{
						Format(name, MAXLENGTH_NAME, "%t %s", "tags_DOWN_chat", name);
					}
					else if (CheckVipFlag(author, g_sAdminFlag))
					{
						Format(name, MAXLENGTH_NAME, "%t %s", "tags_DA_chat", name);
					}
					else if (CheckVipFlag(author, g_sVIPFlag))
					{
						Format(name, MAXLENGTH_NAME, "%t %s", "tags_DVIP1_chat", name);
					}
					else if (CheckVipFlag(author, g_sVIP2Flag))
					{
						Format(name, MAXLENGTH_NAME, "%t %s", "tags_DVIP2_chat", name);
					}
					else if (gc_bNoOverwrite.BoolValue)
					{
						Format(name, MAXLENGTH_NAME, "%t %s", "tags_D_chat", name);
					}
				}
				else if (CheckVipFlag(author, g_sOwnerFlag))
				{
					Format(name, MAXLENGTH_NAME, "%t %s", "tags_CTOWN_chat", name);
				}
				else if (CheckVipFlag(author, g_sAdminFlag))
				{
					Format(name, MAXLENGTH_NAME, "%t %s", "tags_CTA_chat", name);
				}
				else if (CheckVipFlag(author, g_sVIPFlag))
				{
					Format(name, MAXLENGTH_NAME, "%t %s", "tags_CTVIP1_chat", name);
				}
				else if (CheckVipFlag(author, g_sVIP2Flag))
				{
					Format(name, MAXLENGTH_NAME, "%t %s", "tags_CTVIP2_chat", name);
				}
				else if (gc_bNoOverwrite.BoolValue)
				{
					Format(name, MAXLENGTH_NAME, "%t %s", "tags_CT_chat", name);
				}
			}
			Format(message, MAXLENGTH_MESSAGE, "{default}%s", message);
			
		}
	}

	return Plugin_Changed;
}