/*
 * MyJailbreak - Core Plugin.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
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
 * this program. If not, see <http:// www.gnu.org/licenses/>.
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

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Console Variables
ConVar gc_bTag;
ConVar gc_bLogging;
ConVar gc_bShootButton;
ConVar gc_sCustomCommandEndRound;
ConVar gc_bEndRound;

// Booleans
bool g_bEventDayPlanned = false;
bool g_bEventDayRunning = false;
bool g_bLastGuardRuleActive = false;

// Strings
char g_sEventDayName[128] = "none";

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

	Beacon_OnPluginStart();

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
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