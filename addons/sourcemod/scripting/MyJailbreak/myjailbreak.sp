//includes
#include <sourcemod>
#include <cstrike>
#include <colors>
#include <myjailbreak>


//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//ConVars
ConVar gc_bTag;
ConVar gc_bLogging;

//Integers
int FogIndex = -1;

//Floats
float mapFogStart = 0.0;
float mapFogEnd = 150.0;
float mapFogDensity = 0.99;

//Bools
bool EventDayPlaned = false;
bool EventDayRunning = false;

//Strings
char IsEventDay[128] = "none";

//Handles

public Plugin myinfo = {
	name = "MyJailbreak - Core",
	author = "shanapu",
	description = "MyJailbreak - core plugin",
	version = PLUGIN_VERSION,
	url = URL_LINK
};

public void OnPluginStart()
{
	gc_bTag = CreateConVar("sm_myjb_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch you sv_tags", _, true,  0.0, true, 1.0);
	gc_bLogging = CreateConVar("sm_myjb_log", "1", "Allow MyJailbreak to log events, freekills & eventdays in logs/MyJailbreak", _, true,  0.0, true, 1.0);
	
	RegAdminCmd("sm_endround", Command_EndRound, ADMFLAG_GENERIC);
	
//	RegAdminCmd("sm_fogoff", CommandFogOff, ADMFLAG_ROOT, "");
//	RegAdminCmd("sm_fogon", CommandFogOn, ADMFLAG_ROOT, "");
//	HookEvent("round_start", RoundStart);
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("SetEventDay", Native_SetEventDay);
	CreateNative("GetEventDay", Native_GetEventDay);
	CreateNative("FogOn", Native_FogOn);
	CreateNative("FogOff", Native_FogOff);
	CreateNative("MyJBLogging", Native_GetMyJBLogging);
	CreateNative("IsEventDayRunning", Native_IsEventDayRunning);
	CreateNative("IsEventDayPlaned", Native_IsEventDayPlaned);
	CreateNative("SetEventDayRunning", Native_SetEventDayRunning);
	CreateNative("SetEventDayPlaned", Native_SetEventDayPlaned);
	
	if (GetEngineVersion() != Engine_CSGO)
	{
		SetFailState("Game is not supported. CS:GO ONLY");
	}
	RegPluginLibrary("myjailbreak");
	return APLRes_Success;
	
}

public Action Command_EndRound(int client, int args)
{
	CS_TerminateRound(0.5, CSRoundEnd_Draw, true); 
}

public int Native_IsEventDayRunning(Handle plugin,int argc)
{
	if(!EventDayRunning) return true;
	else return false;
}
public int Native_SetEventDayRunning(Handle plugin,int argc)
{
	EventDayRunning = GetNativeCell(1);
//	CPrintToChatAll("{darkred}DEBUG: EventDayRunning %b",EventDayRunning);
}

public int Native_IsEventDayPlaned(Handle plugin,int argc)
{
	if(!EventDayPlaned) return true;
	else return false;
}
public int Native_SetEventDayPlaned(Handle plugin,int argc)
{
	EventDayPlaned = GetNativeCell(1);
//	CPrintToChatAll("{darkred}DEBUG: EventDayPlaned %b",EventDayPlaned);
}

//Set sv_tags

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

//Darken the Map
public void OnMapEnd()
{
	EventDayPlaned = false;
	EventDayRunning = false;
	SetEventDay("none");
}
public void OnMapStart()
{
	int ent; 
	ent = FindEntityByClassname(-1, "env_fog_controller");
	if (ent != -1) 
	{
		FogIndex = ent;
	}
	else
	{
		FogIndex = CreateEntityByName("env_fog_controller");
		DispatchSpawn(FogIndex);
	}
	DoFog();
	AcceptEntityInput(FogIndex, "TurnOff");
}
/*
public Action CommandFogOff(int client, int args)
{
	AcceptEntityInput(FogIndex, "TurnOff");
	PrintToChatAll("fog off");
}

public Action CommandFogOn(int client, int args)
{
	AcceptEntityInput(FogIndex, "TurnOn");
	PrintToChatAll("fog on");
}
*/
public int Native_FogOff(Handle plugin,int argc)
{AcceptEntityInput(FogIndex, "TurnOff");}

public int Native_FogOn(Handle plugin,int argc)
{AcceptEntityInput(FogIndex, "TurnOn");}

public void DoFog()
{
	if(FogIndex != -1)
	{
		DispatchKeyValue(FogIndex, "fogblend", "0");
		DispatchKeyValue(FogIndex, "fogcolor", "0 0 0");
		DispatchKeyValue(FogIndex, "fogcolor2", "0 0 0");
		DispatchKeyValueFloat(FogIndex, "fogstart", mapFogStart);
		DispatchKeyValueFloat(FogIndex, "fogend", mapFogEnd);
		DispatchKeyValueFloat(FogIndex, "fogmaxdensity", mapFogDensity);
	}
}
/*
public void RoundStart(Handle event, char[] name, bool dontBroadcast)
{
	
	if(!IsEventDayRunning(false))
	{
		g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	}
	else if (g_iCoolDown > 0) g_iCoolDown--;
	
	for(int client=1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client))
		{
			char EventDay[64];
			GetEventDay(EventDay);
			
			if(IsEventDayRunning(false))
			{
				if (GetClientTeam(client) == CS_TEAM_T)
				{
					StripAllWeapons(client);
					GivePlayerItem(client, "weapon_knife");
				}
				
			//	SetCvar("sm_YOUR_CVAR", 1);		// No EventDay
			//	SetCvar("sm_YOUR_CVAR", 1);		// No EventDay
			}
			else
			{
			//	SetCvar("sm_YOUR_CVAR", 0);		// Is EventDay
			//	SetCvar("sm_YOUR_CVAR", 0);		// Is EventDay
			}
		
		}
	}
}*/

public int Native_SetEventDay(Handle plugin,int argc)
{
	char buffer[64];
	GetNativeString(1, buffer, 64);
	
	Format(IsEventDay, sizeof(IsEventDay), buffer);
}

public int Native_GetEventDay(Handle plugin,int argc)
{
	SetNativeString(1, IsEventDay, sizeof(IsEventDay));
}

public int Native_GetMyJBLogging(Handle plugin,int argc)
{
	if(gc_bLogging.BoolValue) return true;
	else return false;
}

