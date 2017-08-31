/*
 * Vote Restrict Sniper
 * by: shanapu
 * 
 * Copyright (C) 2017 Thomas Schmidt (shanapu)
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


#define COMMAND "sm_nosniper"
#define FLAGS "a,b,c"
#define VOTE_QST "Restrict sniper for %i rounds?"
#define VOTE_YES "Yes"
#define VOTE_NO "No"
#define ONE_VOTE_MSG "Only one voting per map"
#define RESTRICT_MSG "Vote successful! Sniper resticted!"
#define MAX_ROUNDS 10


/******************************************************************************
                   EDIT HERE
******************************************************************************/



// Includes
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

bool g_bRestrictSnipers = false;
bool g_bVoted = false;
int g_iRoundCount;
int g_iRounds;

public Plugin myinfo =
{
	name = "Vote restict sniper",
	author = "shanapu",
	description = "Admins/VIP can vote to restrict sniper",
	version = "1.2",
	url = "https://github.com/shanapu/"
};

public void OnMapStart()
{
	g_bVoted = false;
}

public void OnPluginStart()
{
	RegConsoleCmd(COMMAND, Command_Vote, "");

	HookEvent("round_end", Event_RoundEnd);
}

public void Event_RoundEnd(Event event, char[] name, bool dontBroadcast)
{
	if (g_bRestrictSnipers)
	{
		g_iRoundCount++;

		if(g_iRoundCount >= g_iRounds)
		{
			g_bRestrictSnipers = false;
		}
	}
}

public Action Command_Vote(int client, int args)
{
	if (!CheckVipFlag(client, FLAGS))
	{
		return;
	}

	if (g_bVoted)
	{
		ReplyToCommand(client, ONE_VOTE_MSG);
		return;
	}

	if (IsVoteInProgress())
	{
		return;
	}

	if (args < 1)
	{
		ReplyToCommand(client, "Use: %s <rounds>", COMMAND);
		return;
	}

	char arg[10];
	GetCmdArg(1, arg, sizeof(arg));
	g_iRounds = StringToInt(arg);

	if (g_iRounds > MAX_ROUNDS)
	{
		ReplyToCommand(client, "Must be less than %i rounds", MAX_ROUNDS+1);
		return;
	}

	Menu menu = new Menu(Handle_VoteMenu);
	menu.SetTitle(VOTE_QST, g_iRounds);
	menu.AddItem("yes", VOTE_YES);
	menu.AddItem("no", VOTE_NO);
	menu.ExitButton = false;
	menu.DisplayVoteToAll(20);

	g_bVoted = true;
}

public int Handle_VoteMenu(Menu menu, MenuAction action, int param1,int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_VoteEnd)
	{
		if (param1 == 0)
		{
			g_iRoundCount = 0;
			g_bRestrictSnipers = true;
			for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
			{
				StripSniper(i);
			}
			PrintToChatAll(RESTRICT_MSG);
		}
	}
}

void StripSniper(int client)
{
	int weapon;
	if ((weapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY)) != -1)
	{
		char sWeapon[32];
		GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));

		if (StrEqual(sWeapon, "weapon_awp") || 
			StrEqual(sWeapon, "weapon_ssg08") || 
			StrEqual(sWeapon, "weapon_g3sg1") || 
			StrEqual(sWeapon, "weapon_scar20"))
		{
			RemovePlayerItem(client, weapon);
			AcceptEntityInput(weapon, "Kill");
		}
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

public Action OnWeaponCanUse(int client, int weapon)
{
	if (!g_bRestrictSnipers)
	{
		return Plugin_Continue;
	}

	char sWeapon[32];
	GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));

	if (StrEqual(sWeapon, "weapon_awp") || 
		StrEqual(sWeapon, "weapon_ssg08") || 
		StrEqual(sWeapon, "weapon_g3sg1") || 
		StrEqual(sWeapon, "weapon_scar20"))
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action CS_OnBuyCommand(int client, const char [] weapon)
{
	if (!g_bRestrictSnipers)
	{
		return Plugin_Continue;
	}

	if (StrEqual(weapon, "weapon_awp") || 
		StrEqual(weapon, "weapon_ssg08") || 
		StrEqual(weapon, "weapon_g3sg1") || 
		StrEqual(weapon, "weapon_scar20"))
	{
		ClientCommand(client, "play buttons/button11.wav");
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

bool CheckVipFlag(int client, char [] flagsNeed)
{
	int iCount = 0;
	char sflagNeed[22][8], sflagFormat[64];
	bool bEntitled = false;

	Format(sflagFormat, sizeof(sflagFormat), flagsNeed);
	ReplaceString(sflagFormat, sizeof(sflagFormat), " ", "");
	iCount = ExplodeString(sflagFormat, ",", sflagNeed, sizeof(sflagNeed), sizeof(sflagNeed[]));

	for (int i = 0; i < iCount; i++)
	{
		if ((GetUserFlagBits(client) & ReadFlagString(sflagNeed[i]) == ReadFlagString(sflagNeed[i])) || (GetUserFlagBits(client) & ADMFLAG_ROOT))
		{
			bEntitled = true;
			break;
		}
	}

	return bEntitled;
}