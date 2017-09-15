/*
 * MyJailbreak - Core Plugin.
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
#include <autoexecconfig>
#include <mystocks>
#include <myjailbreak>

#undef REQUIRE_PLUGIN
#include <hosties>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Console Variables
ConVar gc_bTag;
ConVar gc_bLogging;
ConVar gc_bShootButton;
ConVar gc_sCustomCommandEndRound;
ConVar gc_bEndRound;
ConVar gc_iRandomEventDay;
ConVar gc_iRandomEventDayPercent;
ConVar gc_iRandomEventDayStartDelay;
ConVar gc_iRandomEventDayType;

// Booleans
bool g_bEventDayPlanned = false;
bool g_bEventDayRunning = false;
bool g_bLastGuardRuleActive = false;
bool gp_bHosties;

// Integers
int g_iRandomArraySize = 0;
int g_iRoundNumber = 0;

// Handles
Handle gF_OnEventDayStart;
Handle gF_OnEventDayEnd;
Handle g_aRandomList;


ConVar Cvar_sm_hosties_announce_rebel_down;
ConVar Cvar_sm_hosties_rebel_color;
ConVar Cvar_sm_hosties_mute;
ConVar Cvar_sm_hosties_announce_attack;
ConVar Cvar_sm_hosties_announce_wpn_attack;
ConVar Cvar_sm_hosties_freekill_notify;
ConVar Cvar_sm_hosties_freekill_treshold;

int OldCvar_sm_hosties_rebel_color;
int OldCvar_sm_hosties_announce_rebel_down;
int OldCvar_sm_hosties_mute;
int OldCvar_sm_hosties_announce_attack;
int OldCvar_sm_hosties_announce_wpn_attack;
int OldCvar_sm_hosties_freekill_notify;
int OldCvar_sm_hosties_freekill_treshold;

// Strings
char g_sEventDayName[128] = "none";
char g_sEventDays[][32] = {
						"war",
						"ffa",
						"zombie",
						"hide",
						"catch",
						"suicidebomber",
						"ghosts",
						"teleport",
						"armsrace",
						"oneinthechamber",
						"hebattle",
						"noscope",
						"duckhunt",
						"zeus",
						"dealdamage",
						"drunk",
						"knifefight",
						"cowboy",
						"freeday"
						}; // 19 event days

// Modules
#include "MyJailbreak/Modules/fog.sp"
#include "MyJailbreak/Modules/beacon.sp"

// Info
public Plugin myinfo = {
	name = "MyJailbreak - Core",
	author = "shanapu",
	description = "MyJailbreak - core plugin",
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
};

// Start
public void OnPluginStart()
{
	// Admin commands
	RegAdminCmd("sm_endround", Command_EndRound, ADMFLAG_CHANGEMAP);

	// AutoExecConfig
	AutoExecConfig_SetFile("MyJailbreak", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);

	// Create Console Variables
	gc_bTag = AutoExecConfig_CreateConVar("sm_myjb_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch you sv_tags", _, true, 0.0, true, 1.0);
	gc_bLogging = AutoExecConfig_CreateConVar("sm_myjb_log", "1", "Allow MyJailbreak to log events, freekills & eventdays in logs/MyJailbreak", _, true, 0.0, true, 1.0);
	gc_bShootButton = AutoExecConfig_CreateConVar("sm_myjb_shoot_buttons", "1", "0 - disabled, 1 - allow player to trigger a map button by shooting it", _, true, 0.0, true, 1.0);
	gc_sCustomCommandEndRound = AutoExecConfig_CreateConVar("sm_myjb_cmds_endround", "er, stopround, end", "Set your custom chat commands for admins to end the current round(!endround (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands)");
	gc_bEndRound = AutoExecConfig_CreateConVar("sm_myjb_allow_endround", "0", "0 - disabled, 1 - enable !endround command for testing (disable against abusing)");
	gc_iRandomEventDay = AutoExecConfig_CreateConVar("sm_myjb_random_round", "6", "0 - disabled / Every x round could be an event day or voting");
	gc_iRandomEventDayType = AutoExecConfig_CreateConVar("sm_myjb_random_type", "1", "0 - Start an eventday voting / 1 - start an random eventday");
	gc_iRandomEventDayPercent = AutoExecConfig_CreateConVar("sm_myjb_random_chance", "60", "Chance that the choosen round would be an event day");
	gc_iRandomEventDayStartDelay = AutoExecConfig_CreateConVar("sm_myjb_random_mapstart_delay", "6", "Wait after mapchange x rounds before try first random eventday or voting");
	
	Beacon_OnPluginStart();

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	
	g_aRandomList = CreateArray();
}

public void OnAllPluginsLoaded()
{
	gp_bHosties = LibraryExists("lastrequest");
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "lastrequest"))
		gp_bHosties = false;
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "lastrequest"))
		gp_bHosties = true;
}

// Initialize Plugin - check/set sv_tags for MyJailbreak
public void OnConfigsExecuted()
{
	if (gc_bTag.BoolValue)
	{
		ConVar hTags = FindConVar("sv_tags");
		char sTags[128];
		hTags.GetString(sTags, sizeof(sTags));
		if (StrContains(sTags, "MyJailbreak", false) == -1)
		{
			StrCat(sTags, sizeof(sTags), ", MyJailbreak");
			hTags.SetString(sTags);
		}
	}

	if (gc_iRandomEventDay.IntValue != 0)
	{
		ClearArray(g_aRandomList);

		char buffer[64];
		
		for(int i = 0; i <= sizeof(g_sEventDays)-1; i++)
		{
			Format(buffer, sizeof(buffer), "sm_%s", g_sEventDays[i]);
			if (GetCommandFlags(buffer) != INVALID_FCVAR_FLAGS)
			{
				PushArrayString(g_aRandomList, g_sEventDays[i]);
			}
		}
		g_iRandomArraySize = GetArraySize(g_aRandomList);
	}

	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// End round
	gc_sCustomCommandEndRound.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ","");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  // if command not already exist
			RegAdminCmd(sCommand, Command_EndRound, ADMFLAG_CHANGEMAP);
	}
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

// End the current round instandly
public Action Command_EndRound(int client, int args)
{
	if (gc_bEndRound.BoolValue) CS_TerminateRound(5.5, CSRoundEnd_Draw, true);

	return Plugin_Handled;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (gc_bShootButton.BoolValue)
	{
		int ent = -1;
		while ((ent = FindEntityByClassname(ent, "func_button")) != -1)
		{
			SetEntProp(ent, Prop_Data, "m_spawnflags", GetEntProp(ent, Prop_Data, "m_spawnflags")|512);
		}
	}

	if (gc_iRandomEventDay.IntValue == 0 || g_iRandomArraySize == 0)
		return;

	if (MyJailbreak_IsEventDayPlanned() || MyJailbreak_IsEventDayRunning())
		return;

	g_iRoundNumber++;

	if (g_iRoundNumber <= gc_iRandomEventDayStartDelay.IntValue)
		return;

	g_iRoundNumber -= gc_iRandomEventDay.IntValue;

	int chance = GetRandomInt(0, 100);
	if (chance > gc_iRandomEventDayPercent.IntValue)
		return;

	if (gc_iRandomEventDayType.BoolValue)
	{
		int randomEvent = GetRandomInt(0, g_iRandomArraySize-1);
		ServerCommand("sm_set%s", g_sEventDays[randomEvent]);
	}
	else ServerCommand("sm_voteday");

}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

// Prepare modules
public void OnMapStart()
{
	Fog_OnMapStart();
	Beacon_OnMapStart();
	g_bLastGuardRuleActive = false;
	g_iRoundNumber = 0;
}

// Reset Plugin
public void OnMapEnd()
{
	g_bEventDayPlanned = false;
	g_bEventDayRunning = false;
	g_bLastGuardRuleActive = false;

	MyJailbreak_SetEventDayName("none");

	Beacon_OnMapEnd();
}

/******************************************************************************
                   NATIVES
******************************************************************************/

// Register Natives
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (GetEngineVersion() != Engine_CSGO)
	{
		SetFailState("Game is not supported. CS:GO ONLY");
	}

	CreateNative("MyJailbreak_SetEventDayName", Native_SetEventDayName);
	CreateNative("MyJailbreak_GetEventDayName", Native_GetEventDayName);
	CreateNative("MyJailbreak_IsEventDayRunning", Native_IsEventDayRunning);
	CreateNative("MyJailbreak_SetEventDayRunning", Native_SetEventDayRunning);
	CreateNative("MyJailbreak_SetEventDayPlanned", Native_SetEventDayPlanned);
	CreateNative("MyJailbreak_IsEventDayPlanned", Native_IsEventDayPlanned);
	CreateNative("MyJailbreak_IsLastGuardRule", Native_IsLastGuardRule);
	CreateNative("MyJailbreak_SetLastGuardRule", Native_SetLastGuardRule);

	CreateNative("MyJailbreak_ActiveLogging", Native_GetActiveLogging);

	CreateNative("MyJailbreak_FogOn", Native_FogOn);
	CreateNative("MyJailbreak_FogOff", Native_FogOff);

	CreateNative("MyJailbreak_BeaconOn", Native_BeaconOn);
	CreateNative("MyJailbreak_BeaconOff", Native_BeaconOff);

	gF_OnEventDayStart = CreateGlobalForward("MyJailbreak_OnEventDayStart", ET_Ignore, Param_String);
	gF_OnEventDayEnd = CreateGlobalForward("MyJailbreak_OnEventDayEnd", ET_Ignore, Param_String, Param_Cell);

	RegPluginLibrary("myjailbreak");

	return APLRes_Success;
}

// Boolean Is Event Day running (true = running)
public int Native_IsEventDayRunning(Handle plugin, int argc)
{
	if (!g_bEventDayRunning)
	{
		return false;
	}

	return true;
}

// Boolean Set Event Day running (true = running)
public int Native_SetEventDayRunning(Handle plugin, int argc)
{
	g_bEventDayRunning = GetNativeCell(1);
	int winner = GetNativeCell(2);

	if (g_bEventDayRunning)
	{
		Call_StartForward(gF_OnEventDayStart);
		Call_PushString(g_sEventDayName);
		Call_Finish();

		if (gp_bHosties)
		{
			ToggleConVars(true);
		}
	}
	else
	{
		Call_StartForward(gF_OnEventDayEnd);
		Call_PushString(g_sEventDayName);
		Call_PushCell(winner);
		Call_Finish();

		if (gp_bHosties)
		{
			ToggleConVars(false);
		}
	}
}

void ToggleConVars(bool IsEventDay)
{
	if (!gp_bHosties)
		return;

	if (IsEventDay)
	{
		// Get the Cvar Value
		Cvar_sm_hosties_announce_rebel_down = FindConVar("sm_hosties_announce_rebel_down");
		Cvar_sm_hosties_rebel_color = FindConVar("sm_hosties_rebel_color");
		Cvar_sm_hosties_mute = FindConVar("sm_hosties_mute");
		Cvar_sm_hosties_announce_attack = FindConVar("sm_hosties_announce_attack");
		Cvar_sm_hosties_announce_wpn_attack = FindConVar("sm_hosties_announce_wpn_attack");
		Cvar_sm_hosties_freekill_notify = FindConVar("sm_hosties_freekill_notify");
		Cvar_sm_hosties_freekill_treshold = FindConVar("sm_hosties_freekill_treshold");

		// Save the Cvar Value
		OldCvar_sm_hosties_rebel_color = Cvar_sm_hosties_rebel_color.IntValue;
		OldCvar_sm_hosties_announce_rebel_down = Cvar_sm_hosties_announce_rebel_down.IntValue;
		OldCvar_sm_hosties_mute = Cvar_sm_hosties_mute.IntValue;
		OldCvar_sm_hosties_announce_attack = Cvar_sm_hosties_announce_attack.IntValue;
		OldCvar_sm_hosties_announce_wpn_attack = Cvar_sm_hosties_announce_wpn_attack.IntValue;
		OldCvar_sm_hosties_freekill_notify = Cvar_sm_hosties_freekill_notify.IntValue;
		OldCvar_sm_hosties_freekill_treshold = Cvar_sm_hosties_freekill_treshold.IntValue;

		// Change the Cvar Value
		Cvar_sm_hosties_announce_rebel_down.IntValue = 0;
		Cvar_sm_hosties_rebel_color.IntValue = 0;
		Cvar_sm_hosties_mute.IntValue = 0;
		Cvar_sm_hosties_announce_attack.IntValue = 0;
		Cvar_sm_hosties_announce_wpn_attack.IntValue = 0;
		Cvar_sm_hosties_freekill_notify.IntValue = 0;
		Cvar_sm_hosties_freekill_treshold.IntValue = 0;
	}
	else
	{
		// Replace the Cvar Value with old value
		Cvar_sm_hosties_announce_rebel_down.IntValue = OldCvar_sm_hosties_announce_rebel_down;
		Cvar_sm_hosties_rebel_color.IntValue = OldCvar_sm_hosties_rebel_color;
		Cvar_sm_hosties_mute.IntValue = OldCvar_sm_hosties_mute;
		Cvar_sm_hosties_announce_attack.IntValue = OldCvar_sm_hosties_announce_attack;
		Cvar_sm_hosties_announce_wpn_attack.IntValue = OldCvar_sm_hosties_announce_wpn_attack;
		Cvar_sm_hosties_freekill_notify.IntValue = OldCvar_sm_hosties_freekill_notify;
		Cvar_sm_hosties_freekill_treshold.IntValue = OldCvar_sm_hosties_freekill_treshold;
	}
}

// Boolean Is Event Day planned (true = planned)
public int Native_IsEventDayPlanned(Handle plugin, int argc)
{
	if (!g_bEventDayPlanned)
	{
		return false;
	}

	return true;
}

// Boolean Set Event Day planned (true = planned)
public int Native_SetEventDayPlanned(Handle plugin, int argc)
{
	g_bEventDayPlanned = GetNativeCell(1);
}

// Set Event Day Name
public int Native_SetEventDayName(Handle plugin, int argc)
{
	char buffer[64];
	GetNativeString(1, buffer, 64);

	Format(g_sEventDayName, sizeof(g_sEventDayName), buffer);
}

// Get Event Day Name
public int Native_GetEventDayName(Handle plugin, int argc)
{
	SetNativeString(1, g_sEventDayName, sizeof(g_sEventDayName));
}

// Boolean Is Last Guard Rule active (true = active)
public int Native_IsLastGuardRule(Handle plugin, int argc)
{
	if (!g_bLastGuardRuleActive)
	{
		return false;
	}

	return true;
}

// Boolean Set Last Guard Rule active (true = active)
public int Native_SetLastGuardRule(Handle plugin, int argc)
{
	g_bLastGuardRuleActive = GetNativeCell(1);
}

// Check if logging is active
public int Native_GetActiveLogging(Handle plugin, int argc)
{
	if (gc_bLogging.BoolValue) return true;
	else return false;
}