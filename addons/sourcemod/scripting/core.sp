//includes
#include <sourcemod>
#include <cstrike>
#include <myjailbreak>

//Compiler Options
#pragma semicolon 1

//Defines
#define PLUGIN_VERSION "0.2"

//Strings
char IsEventDay[128] = "none";

public Plugin myinfo = {
	name = "MyJailbreak - core",
	author = "shanapu",
	description = "Jailbreak",
	version = PLUGIN_VERSION,
	url = ""
};

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	CreateNative("SetEventDay", Native_SetEventDay);
	CreateNative("GetEventDay", Native_GetEventDay);
}

public Native_SetEventDay(Handle:plugin, argc)
{
	decl String:buffer[64];
	GetNativeString(1, buffer, 64);
	
	Format(IsEventDay, sizeof(IsEventDay), buffer);
}

public Native_GetEventDay(Handle:plugin, argc)
{
	SetNativeString(1, IsEventDay, sizeof(IsEventDay));
}
