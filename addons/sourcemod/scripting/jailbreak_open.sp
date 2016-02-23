#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
//#include <captain> 
#include <cstrike>
#include <smartjaildoors>
#include <warden>

new opentimer;

new Handle:countertime = INVALID_HANDLE;
new Handle:Cvar_opentimer = INVALID_HANDLE;

public Plugin:myinfo =
{
	name = "SM Doors Opener",
	author = "Franc1sco steam: franug, shanapu",
	description = ".",
	version = "2.0",
	url = ""
};

public OnPluginStart()
{
	RegConsoleCmd("sm_open", openDoors);
	
	RegConsoleCmd("sm_close", closeDoors);

	HookEvent("round_start", Event_RoundStart);
	Cvar_opentimer = CreateConVar("sm_jb_doorsopenertime", "40", "Time in seconds for open doors on round start when CTs only have bots");
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (countertime != INVALID_HANDLE)
		KillTimer(countertime);
		
	countertime = INVALID_HANDLE;
	
	
	opentimer = GetConVarInt(Cvar_opentimer);
	countertime = CreateTimer(1.0, ccounter, _, TIMER_REPEAT);
}

public Action:ccounter(Handle:timer, Handle:pack)
{
	--opentimer;
	if(opentimer < 1)
	{
		Abrir();
		PrintToChatAll("[\x04goo.jail\x01] Die Zellentüren wurden automatisch geöffnet!");
		
		if (countertime != INVALID_HANDLE)
			KillTimer(countertime);
		
		countertime = INVALID_HANDLE;
	}
}

Abrir()
{
	SJD_OpenDoors(); 
}

public Action:openDoors(client, args) 
{ 
    

    if (warden_iswarden(client))
	{
		PrintToChatAll("[\x04goo.jail\x01] Der Governer hat die Zellentüren geöffnet!"); 
		SJD_OpenDoors(); 
	}
    else 
            PrintToChat(client, "[\x04goo.jail\x01] Du musst Governer sein!"); 
}  

public Action:closeDoors(client, args) 
{ 
    

    if (warden_iswarden(client)) 
	{
		PrintToChatAll("[\x04goo.jail\x01] Der Governer hat die Zellentüren geschlossen!"); 
		SJD_CloseDoors();
	}
    else 
            PrintToChat(client, "[\x04goo.jail\x01] Du musst Governer sein!"); 
}  
