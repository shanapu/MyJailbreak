//includes
#include <sourcemod>
#include <cstrike>
#include <myjailbreak>


//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//ConVars
ConVar gc_bTag;
ConVar gc_bLogging;

//Strings
char IsEventDay[128] = "none";

public Plugin myinfo = {
	name = "myjailbreak",
	author = "shanapu",
	description = "MyJailbreak - core plugin",
	version = PLUGIN_VERSION,
	url = URL_LINK
};

public void OnPluginStart()
{
	gc_bTag = CreateConVar("sm_myjb_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch you sv_tags", _, true,  0.0, true, 1.0);
	gc_bLogging = CreateConVar("sm_myjb_log", "1", "Allow MyJailbreak to log events, freekills & eventdays in logs/MyJailbreak", _, true,  0.0, true, 1.0);
	
	 // no warning on compile
//	HookEvent("round_start", RoundStart);
	}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("SetEventDay", Native_SetEventDay);
	CreateNative("GetEventDay", Native_GetEventDay);
	CreateNative("MyJBLogging", Native_GetMyJBLogging);
	
	if (GetEngineVersion() != Engine_CSGO)
	{
		SetFailState("Game is not supported. CS:GO ONLY");
	}
	RegPluginLibrary("myjailbreak");
	return APLRes_Success;
	
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

/*   NOT GOOD!!!   work in progress
public void RoundStart(Handle event, char[] name, bool dontBroadcast)
{
	for(int client=1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client))
		{
			char EventDay[64];
			GetEventDay(EventDay);
			
			if(StrEqual(EventDay, "none", false))
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
}
*/

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
