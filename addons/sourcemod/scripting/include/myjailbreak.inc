#if defined _myjailbreak_included_
	#endinput
#endif
#define _myjailbreak_included_

#define PLUGIN_VERSION "0.4"


#include <sdktools>

Handle IntCvar;
Handle FloatCvar;
char g_sOverlayStart[256];




native SetEventDay(const char[] name);




native GetEventDay(char[] CurrentEventDay);



stock PrecacheOverlayAnyDownload(char[] sOverlay)
{
	char sBufferVmt[256];
	char sBufferVtf[256];
	Format(sBufferVmt, sizeof(sBufferVmt), "%s.vmt", sOverlay);
	Format(sBufferVtf, sizeof(sBufferVtf), "%s.vtf", sOverlay);
	PrecacheDecal(sBufferVmt, true);
	PrecacheDecal(sBufferVtf, true);
	Format(sBufferVmt, sizeof(sBufferVmt), "materials/%s.vmt", sOverlay);
	Format(sBufferVtf, sizeof(sBufferVtf), "materials/%s.vtf", sOverlay);
	AddFileToDownloadsTable(sBufferVmt);
	AddFileToDownloadsTable(sBufferVtf);
}

stock PrecacheSoundAnyDownload(char[] sSound)
{
	PrecacheSoundAny(sSound);
	char sBuffer[256];
	Format(sBuffer, sizeof(sBuffer), "sound/%s", sSound);
	AddFileToDownloadsTable(sBuffer);
	
}

stock StripAllWeapons(int iClient)
{
	int iEnt;
	for (int i = 0; i <= 4; i++)
	{
		while ((iEnt = GetPlayerWeaponSlot(iClient, i)) != -1)
		{
			RemovePlayerItem(iClient, iEnt);
			AcceptEntityInput(iEnt, "Kill");
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
		CreateTimer( 2.0, DeleteOverlay, client );
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

public Pass(Handle:menu, MenuAction:action, param1, param2)
{
}