#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "1.0.0"

public Plugin:myinfo =
{
	name		= "Test",
	author		= "FrozDark",
	description	= "",
	version		= PLUGIN_VERSION,
	url			= "www.hlmod.ru"
}

/*
public OnMapStart()
{
	decl Float:fMins[3], Float:fMaxs[3];
	GetEntPropVector(0, Prop_Send, "m_vecMins", fMins);
	GetEntPropVector(0, Prop_Send, "m_vecMaxs", fMaxs);
	
	new func_bomb_target = CreateEntityByName("func_bomb_target");
	DispatchSpawn(func_bomb_target);
	
	TeleportEntity(func_bomb_target, {0.0, 0.0, 0.0}, NULL_VECTOR, NULL_VECTOR);
	
	SetEntPropVector(func_bomb_target, Prop_Send, "m_vecMins", fMins);
	SetEntPropVector(func_bomb_target, Prop_Send, "m_vecMaxs", fMaxs);
}
*/

public void OnClientPutInServer(int client)
{
//    SDKHook(client, SDKHook_PreThink, OnPreThink);
    SDKHook(client, SDKHook_PostThink, OnPostThink);
}

public void OnPreThink(int client)
{
    SetEntProp(client, Prop_Send, "m_bInBombZone", 1);
}  

public void OnPostThink(int client)
{
    SetEntProp(client, Prop_Send, "m_bInBombZone", 1);
}  