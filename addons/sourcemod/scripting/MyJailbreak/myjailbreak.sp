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
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */


/******************************************************************************
                   STARTUP
******************************************************************************/


//Includes
#include <myjailbreak>


//Compiler Options
#pragma semicolon 1
#pragma newdecls required


//Console Variables
ConVar gc_bTag;
ConVar gc_bLogging;
ConVar gc_bShootButton;


//Booleans
bool EventDayPlanned = false;
bool EventDayRunning = false;
bool LastGuardRuleActive = false;


//Strings
char IsEventDay[128] = "none";


//Modules
#include "MyJailbreak/Modules/fog.sp"
#include "MyJailbreak/Modules/beacon.sp"


//Info
public Plugin myinfo = {
	name = "MyJailbreak - Core",
	author = "shanapu",
	description = "MyJailbreak - core plugin",
	version = PLUGIN_VERSION,
	url = URL_LINK
};


//Start
public void OnPluginStart()
{
	//Admin commands
	RegAdminCmd("sm_endround", Command_EndRound, ADMFLAG_CHANGEMAP);
	
	
	//AutoExecConfig
	AutoExecConfig_SetFile("MyJailbreak", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);
	
	
	//Create Console Variables
	gc_bTag = AutoExecConfig_CreateConVar("sm_myjb_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch you sv_tags", _, true,  0.0, true, 1.0);
	gc_bLogging = AutoExecConfig_CreateConVar("sm_myjb_log", "1", "Allow MyJailbreak to log events, freekills & eventdays in logs/MyJailbreak", _, true,  0.0, true, 1.0);
	gc_bShootButton = AutoExecConfig_CreateConVar("sm_myjb_shoot_buttons", "1", "0 - disabled, 1 - allow player to trigger a map button by shooting it", _, true,  0.0, true, 1.0);
	
	
	Beacon_OnPluginStart();
	
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", Event_RoundStart);
}


//Initialize Plugin - check/set sv_tags for MyJailbreak
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
}


/******************************************************************************
                   COMMANDS
******************************************************************************/


//End the current round instandly
public Action Command_EndRound(int client, int args)
{
	CS_TerminateRound(5.5, CSRoundEnd_Draw, true); 
}


/******************************************************************************
                   EVENTS
******************************************************************************/


public Action Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	if(gc_bShootButton.BoolValue)
	{
		int ent = -1;
		while((ent = FindEntityByClassname(ent, "func_button")) != -1)
		{
			SetEntProp(ent, Prop_Data, "m_spawnflags", GetEntProp(ent, Prop_Data, "m_spawnflags")|512);
		}
	}
}


/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/


//Prepare modules
public void OnMapStart()
{
	Fog_OnMapStart();
	Beacon_OnMapStart();
	
	LastGuardRuleActive = false;
}


//Reset Plugin
public void OnMapEnd()
{
	EventDayPlanned = false;
	EventDayRunning = false;
	LastGuardRuleActive = false;
	SetEventDayName("none");
	
	Beacon_OnMapEnd();
}


/******************************************************************************
                   NATIVES
******************************************************************************/


//Register Natives
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("SetEventDayName", Native_SetEventDayName);
	CreateNative("GetEventDayName", Native_GetEventDayName);
	CreateNative("IsEventDayRunning", Native_IsEventDayRunning);
	CreateNative("SetEventDayRunning", Native_SetEventDayNameRunning);
	CreateNative("SetEventDayPlanned", Native_SetEventDayPlanned);
	CreateNative("IsEventDayPlanned", Native_IsEventDayPlanned);
	CreateNative("IsLastGuardRule", Native_IsLastGuardRule);
	CreateNative("SetLastGuardRule", Native_SetLastGuardRule);
	CreateNative("ActiveLogging", Native_GetActiveLogging);
	CreateNative("FogOn", Native_FogOn);
	CreateNative("FogOff", Native_FogOff);
	CreateNative("BeaconOn", Native_BeaconOn);
	CreateNative("BeaconOff", Native_BeaconOff);
	
	
	if (GetEngineVersion() != Engine_CSGO)
	{
		SetFailState("Game is not supported. CS:GO ONLY");
	}
	RegPluginLibrary("myjailbreak");
	
	return APLRes_Success;
}


//Boolean Is Event Day running (true = running)
public int Native_IsEventDayRunning(Handle plugin,int argc)
{
	if(!EventDayRunning)
	{
		return false;
	}
	return true;
}


//Boolean Set Event Day running (true = running)
public int Native_SetEventDayNameRunning(Handle plugin,int argc)
{
	EventDayRunning = GetNativeCell(1);
}


//Boolean Is Event Day planned (true = planned)
public int Native_IsEventDayPlanned(Handle plugin,int argc)
{
	if(!EventDayPlanned)
	{
		return false;
	}
	return true;
}


//Boolean Set Event Day planned (true = planned)
public int Native_SetEventDayPlanned(Handle plugin,int argc)
{
	EventDayPlanned = GetNativeCell(1);
}


//Set Event Day Name
public int Native_SetEventDayName(Handle plugin,int argc)
{
	char buffer[64];
	GetNativeString(1, buffer, 64);
	
	Format(IsEventDay, sizeof(IsEventDay), buffer);
}


//Get Event Day Name
public int Native_GetEventDayName(Handle plugin,int argc)
{
	SetNativeString(1, IsEventDay, sizeof(IsEventDay));
}


//Boolean Is Last Guard Rule active (true = active)
public int Native_IsLastGuardRule(Handle plugin,int argc)
{
	if(!LastGuardRuleActive)
	{
		return false;
	}
	return true;
}


//Boolean Set Last Guard Rule active (true = active)
public int Native_SetLastGuardRule(Handle plugin,int argc)
{
	LastGuardRuleActive = GetNativeCell(1);
}


//Check if logging is active
public int Native_GetActiveLogging(Handle plugin,int argc)
{
	if(gc_bLogging.BoolValue) return true;
	else return false;
}