#if defined _myjailbreak_included_
	#endinput
#endif
#define _myjailbreak_included_

#define PLUGIN_VERSION "Beta 6.0 dev"
#define URL_LINK "https://github.com/shanapu/MyJailbreak"

#include <sdktools>
#include <sdkhooks>
#include <lastrequest>

#define LoopClients(%1) for(int %1 = 1; %1 <= MaxClients; %1++) if(IsClientInGame(%1))
#define LoopValidClients(%1,%2,%3) for(int %1 = 1; %1 <= MaxClients; %1++) if(IsValidClient(%1, %2, %3))

Handle IntCvar;
Handle FloatCvar;


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

native bool MyJBLogging(bool IsLogging);

native SetEventDayRunning(bool SetRunning);
native bool IsEventDayRunning(bool IsRunning);

native SetEventDayPlaned(bool SetPlaned);
native bool IsEventDayPlaned(bool IsPlaned);

native FogOn();

native FogOff();

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
	if((weapon = GetPlayerWeaponSlot(client, CS_SLOT_KNIFE)) != -1) {    //strip knife slot 2 times for taser
		SDKHooks_DropWeapon(client, weapon, NULL_VECTOR, NULL_VECTOR); 
		AcceptEntityInput(weapon, "Kill"); 
	}
}

public Action ShowOverlay(int client, char [] path, float deletetime) 
{
	if(IsValidClient(client, false, true))
	{
		int iFlag = GetCommandFlags( "r_screenoverlay" ) & ( ~FCVAR_CHEAT ); 
		SetCommandFlags( "r_screenoverlay", iFlag ); 
		ClientCommand( client, "r_screenoverlay \"%s.vtf\"", path);
		if (deletetime != 0.0) CreateTimer( deletetime, DeleteOverlay, client );
	}
	return Plugin_Continue;
}

public Action ShowOverlayAll(char [] path, float deletetime) 
{
	LoopValidClients(client, false, true)
	{
		int iFlag = GetCommandFlags( "r_screenoverlay" ) & ( ~FCVAR_CHEAT ); 
		SetCommandFlags( "r_screenoverlay", iFlag ); 
		ClientCommand( client, "r_screenoverlay \"%s.vtf\"", path);
		if (deletetime != 0.0) CreateTimer( deletetime, DeleteOverlay, client );
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

public NullHandler(Handle menu, MenuAction action, param1, param2)
{
	if (action == MenuAction_Select) 
	{
		switch (param2) 
		{
			default: //cancel
			{
				return;
			}
		}
	}
}

public Action SetLogFile(char LogFile[PLATFORM_MAX_PATH] , char [] FileName)
{
		char sDate[12];
		FormatTime(sDate, sizeof(sDate), "%y-%m-%d");
		Format(LogFile, sizeof(LogFile), "logs/MyJailbreak/%s-%s.log", FileName, sDate);
		
		BuildPath(Path_SM, LogFile, sizeof(LogFile), LogFile);
}

stock void SetPlayerWeaponAmmo(int client, int weaponEnt, int clip = -1, int ammo = -1)
{
	if (weaponEnt == INVALID_ENT_REFERENCE)
		return;

	if (clip != -1)
		SetEntProp(weaponEnt, Prop_Send, "m_iClip1", clip);

	if (ammo != -1) {
		int iOffset = FindDataMapInfo(client, "m_iAmmo") + (GetEntProp(weaponEnt, Prop_Data, "m_iPrimaryAmmoType") * 4);
		SetEntData(client, iOffset, ammo, 4, true);

		if (GetEngineVersion() == Engine_CSGO) {
			SetEntProp(weaponEnt, Prop_Send, "m_iPrimaryReserveAmmoCount", ammo);
		}
	}
}

public Action Timer_RemoveColor( Handle timer, any client ) 
{
	if(IsValidClient(client, true, true))
	{
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
}

stock int GetRandomPlayer(int team) 
{
	int[] clients = new int[MaxClients];
	int clientCount;
	LoopClients(i)
	{
		if ((GetClientTeam(i) == team) && IsPlayerAlive(i) && !IsClientRebel(i))
		{
			clients[clientCount++] = i;
		}
	}
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)];
}

stock int GetAlivePlayersCount(int iTeam)
{
	int iCount, i; iCount = 0;

	for( i = 1; i <= MaxClients; i++ )
		if(IsValidClient(i,true,false) && !IsClientRebel(i) && GetClientTeam( i ) == iTeam )
		iCount++;

	return iCount;
}

stock int GetAliveTeamCount(int team)
{
	int number = 0;
	LoopClients(i) if(IsPlayerAlive(i) && GetClientTeam(i) == team) number++;
	return number;
}

stock bool CheckVipFlag(int client, const char[] flagsNeed)
{
	if((GetUserFlagBits(client) & ReadFlagString(flagsNeed) == ReadFlagString(flagsNeed)) || (GetUserFlagBits(client) & ADMFLAG_ROOT))
	{
		return true;
	}
	else return false;
}
