#if defined _myjailbreak_included_
	#endinput
#endif
#define _myjailbreak_included_

#define PLUGIN_VERSION "0.9.0"
#define URL_LINK "https://github.com/shanapu/MyJailbreak"

#include <sdktools>
#include <sdkhooks>

Handle IntCvar;
Handle FloatCvar;
char g_sOverlayStart[256];

public SharedPlugin:__pl_myjailbreak =
{
	name = "myjailbreak",
	file = "myjailbreak.smx",
	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};

native SetEventDay(const char[] name);

native GetEventDay(char[] CurrentEventDay);

stock PrecacheDecalAnyDownload(char[] sDecal)
{
	char sBufferVmt[256];
	char sBufferVtf[256];
	Format(sBufferVmt, sizeof(sBufferVmt), "%s.vmt", sDecal);
	Format(sBufferVtf, sizeof(sBufferVtf), "%s.vtf", sDecal);
	PrecacheDecal(sBufferVmt, true);
	PrecacheDecal(sBufferVtf, true);
	Format(sBufferVmt, sizeof(sBufferVmt), "materials/%s.vmt", sDecal);
	Format(sBufferVtf, sizeof(sBufferVtf), "materials/%s.vtf", sDecal);
	AddFileToDownloadsTable(sBufferVmt);
	AddFileToDownloadsTable(sBufferVtf);
}

stock PrecacheModelAnyDownload(char[] sModel)
{
	char sBufferVmt[256];
	char sBufferVtf[256];
	Format(sBufferVmt, sizeof(sBufferVmt), "materials/%s.vmt", sModel);
	Format(sBufferVtf, sizeof(sBufferVtf), "materials/%s.vtf", sModel);
	AddFileToDownloadsTable(sBufferVmt);
	AddFileToDownloadsTable(sBufferVtf);
	PrecacheModel(sBufferVmt, true);
	PrecacheModel(sBufferVtf, true);
}

stock PrecacheSoundAnyDownload(char[] sSound)
{
	PrecacheSoundAny(sSound);
	char sBuffer[256];
	Format(sBuffer, sizeof(sBuffer), "sound/%s", sSound);
	AddFileToDownloadsTable(sBuffer);
}

stock StripAllWeapons(int client)
{
	int weapon;
	for (int i = 0; i <= 4; i++)
	{
		if((weapon = GetPlayerWeaponSlot(client, i)) != -1) { 
		SDKHooks_DropWeapon(client, weapon, NULL_VECTOR, NULL_VECTOR); 
		AcceptEntityInput(weapon, "Kill"); 
		}
	}
}

public Action ShowOverlayStart( Handle timer, any client ) 
{
	if(IsValidClient(client, false, true))
	{
		int iFlag = GetCommandFlags( "r_screenoverlay" ) & ( ~FCVAR_CHEAT ); 
		SetCommandFlags( "r_screenoverlay", iFlag ); 
		ClientCommand( client, "r_screenoverlay \"%s.vtf\"", g_sOverlayStart);
		CreateTimer( 2.5, DeleteOverlay, client );
	}
	return Plugin_Continue;
}

public Action DeleteOverlay( Handle timer, any client ) 
{
	if(IsValidClient(client, false, true))
	{
		int iFlag = GetCommandFlags( "r_screenoverlay" ) & ( ~FCVAR_CHEAT ); 
		SetCommandFlags( "r_screenoverlay", iFlag ); 
		ClientCommand( client, "r_screenoverlay \"\"" );
	}
	return Plugin_Continue;
}

public SetCvar(char cvarName[64],int value)
{
	IntCvar = FindConVar(cvarName);
	if(IntCvar == null) return;
	
	int flags = GetConVarFlags(IntCvar);
	flags &= ~FCVAR_NOTIFY;
	SetConVarFlags(IntCvar, flags);
	
	SetConVarInt(IntCvar, value);
	
	flags |= FCVAR_NOTIFY;
	SetConVarFlags(IntCvar, flags);
}

public SetCvarFloat(char cvarName[64], float value)
{
	FloatCvar = FindConVar(cvarName);
	if(FloatCvar == INVALID_HANDLE) return;
	
	new flags = GetConVarFlags(FloatCvar);
	flags &= ~FCVAR_NOTIFY;
	SetConVarFlags(FloatCvar, flags);
	
	SetConVarFloat(FloatCvar, value);
	
	flags |= FCVAR_NOTIFY;
	SetConVarFlags(FloatCvar, flags);
}

public SetCvarString(char cvarName[64], char[] value)
{
	Handle cvar = FindConVar(cvarName);
	SetConVarString(cvar, value, true);
}

stock bool IsValidClient(int client, bool bAllowBots = false, bool bAllowDead = true)
{
	if(!(1 <= client <= MaxClients) || !IsClientInGame(client) || (IsFakeClient(client) && !bAllowBots) || IsClientSourceTV(client) || IsClientReplay(client) || (!bAllowDead && !IsPlayerAlive(client)))
	{
		return false;
	}
	return true;
}

public NullHandler(Handle:menu, MenuAction:action, param1, param2)
{
}