/*
 * MyJailbreak - Warden - Icon Module.
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
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <colors>
#include <autoexecconfig>
#include <warden>
#include <mystocks>
#include <myjailbreak>


//Compiler Options
#pragma semicolon 1
#pragma newdecls required


//Console Variables
ConVar gc_bIconWarden;
ConVar gc_sIconWardenPath;
ConVar gc_bIconDeputy;
ConVar gc_sIconDeputyPath;
ConVar gc_bIconGuard;
ConVar gc_sIconGuardPath;
ConVar gc_bIconPrisoner;
ConVar gc_sIconPrisonerPath;


//Integers
int g_iIcon[MAXPLAYERS + 1] = {-1, ...};


//Strings
char g_sIconWardenPath[256];
char g_sIconDeputyPath[256];
char g_sIconGuardPath[256];
char g_sIconPrisonerPath[256];


//Start
public void Icon_OnPluginStart()
{
	//AutoExecConfig
	gc_bIconWarden = AutoExecConfig_CreateConVar("sm_warden_icon_enable", "1", "0 - disabled, 1 - enable the icon above the wardens head", _, true,  0.0, true, 1.0);
	gc_sIconWardenPath = AutoExecConfig_CreateConVar("sm_warden_icon", "decals/MyJailbreak/warden" , "Path to the warden icon DONT TYPE .vmt or .vft");
	gc_bIconDeputy = AutoExecConfig_CreateConVar("sm_warden_icon_deputy_enable", "1", "0 - disabled, 1 - enable the icon above the deputy head", _, true,  0.0, true, 1.0);
	gc_sIconDeputyPath = AutoExecConfig_CreateConVar("sm_warden_icon_deputy", "decals/MyJailbreak/warden-2" , "Path to the deputy icon DONT TYPE .vmt or .vft");
	gc_bIconGuard = AutoExecConfig_CreateConVar("sm_warden_icon_ct_enable", "1", "0 - disabled, 1 - enable the icon above the guards head", _, true,  0.0, true, 1.0);
	gc_sIconGuardPath = AutoExecConfig_CreateConVar("sm_warden_icon_ct", "decals/MyJailbreak/ct" , "Path to the guard icon DONT TYPE .vmt or .vft");
	gc_bIconPrisoner = AutoExecConfig_CreateConVar("sm_warden_icon_t_enable", "1", "0 - disabled, 1 - enable the icon above the prisoners head", _, true,  0.0, true, 1.0);
	gc_sIconPrisonerPath = AutoExecConfig_CreateConVar("sm_warden_icon_t", "decals/MyJailbreak/terror-fix" , "Path to the prisoner icon DONT TYPE .vmt or .vft");
	
	
	//Hooks
	HookEvent("round_poststart", Icon_Event_PostRoundStart);
	HookEvent("player_death", Icon_Event_PlayerDeathTeam);
	HookEvent("player_team", Icon_Event_PlayerDeathTeam);
	HookConVarChange(gc_sIconWardenPath, Icon_OnSettingChanged);
	HookConVarChange(gc_sIconDeputyPath, Icon_OnSettingChanged);
	HookConVarChange(gc_sIconGuardPath, Icon_OnSettingChanged);
	HookConVarChange(gc_sIconPrisonerPath, Icon_OnSettingChanged);
	
	
	//FindConVar
	gc_sIconWardenPath.GetString(g_sIconWardenPath , sizeof(g_sIconWardenPath));
	gc_sIconWardenPath.GetString(g_sIconDeputyPath , sizeof(g_sIconDeputyPath));
	gc_sIconGuardPath.GetString(g_sIconGuardPath , sizeof(g_sIconGuardPath));
	gc_sIconPrisonerPath.GetString(g_sIconPrisonerPath , sizeof(g_sIconPrisonerPath));
}


public int Icon_OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sIconWardenPath)
	{
		strcopy(g_sIconWardenPath, sizeof(g_sIconWardenPath), newValue);
		if (gc_bIconWarden.BoolValue) PrecacheModelAnyDownload(g_sIconWardenPath);
	}
	else if (convar == gc_sIconDeputyPath)
	{
		strcopy(g_sIconDeputyPath, sizeof(g_sIconDeputyPath), newValue);
		if (gc_bIconDeputy.BoolValue) PrecacheModelAnyDownload(g_sIconDeputyPath);
	}
	else if (convar == gc_sIconGuardPath)
	{
		strcopy(g_sIconGuardPath, sizeof(g_sIconGuardPath), newValue);
		if (gc_bIconGuard.BoolValue) PrecacheModelAnyDownload(g_sIconGuardPath);
	}
	else if (convar == gc_sIconPrisonerPath)
	{
		strcopy(g_sIconPrisonerPath, sizeof(g_sIconPrisonerPath), newValue);
		if (gc_bIconPrisoner.BoolValue) PrecacheModelAnyDownload(g_sIconPrisonerPath);
	}
}


/******************************************************************************
                   EVENTS
******************************************************************************/


public void Icon_Event_PostRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	CreateTimer(0.1, Timer_Delay);
}


public void Icon_Event_PlayerDeathTeam(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));  //Get the dead clients id
	RemoveIcon(client);
}


public void Icon_OnClientDisconnect(int client)
{
	RemoveIcon(client);
}


/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/


public void Icon_OnMapStart()
{
	if (gc_bIconWarden.BoolValue) PrecacheModelAnyDownload(g_sIconWardenPath);
	if (gc_bIconGuard.BoolValue) PrecacheModelAnyDownload(g_sIconGuardPath);
	if (gc_bIconPrisoner.BoolValue) PrecacheModelAnyDownload(g_sIconPrisonerPath);
	if (gc_bIconDeputy.BoolValue) PrecacheModelAnyDownload(g_sIconDeputyPath);
}


public void Icon_OnWardenCreation(int client)
{
	CreateTimer(0.1, Timer_Delay);
}


public void Icon_OnWardenRemoved(int client)
{
	CreateTimer(0.1, Timer_Delay);
}


public void Icon_OnDeputyCreation(int client)
{
	CreateTimer(0.1, Timer_Delay);
}


public void Icon_OnDeputyRemoved(int client)
{
	CreateTimer(0.1, Timer_Delay);
}


public Action Timer_Delay(Handle timer, Handle pack)
{
	LoopValidClients(i, true, false) SpawnIcon(i);
}


/******************************************************************************
                   FUNCTIONS
******************************************************************************/


public Action Should_TransmitG(int entity, int client)
{
	char m_ModelName[PLATFORM_MAX_PATH];
	char iconbuffer[256];
	Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconGuardPath);
	GetEntPropString(entity, Prop_Data, "m_ModelName", m_ModelName, sizeof(m_ModelName));
	if (StrEqual( iconbuffer, m_ModelName))
		return Plugin_Continue;
	return Plugin_Handled;
}


public Action Should_TransmitW(int entity, int client)
{
	char m_ModelName[PLATFORM_MAX_PATH];
	char iconbuffer[256];
	Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconWardenPath);
	GetEntPropString(entity, Prop_Data, "m_ModelName", m_ModelName, sizeof(m_ModelName));
	if (StrEqual( iconbuffer, m_ModelName))
		return Plugin_Continue;
	return Plugin_Handled;
}


public Action Should_TransmitD(int entity, int client)
{
	char m_ModelName[PLATFORM_MAX_PATH];
	char iconbuffer[256];
	Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconDeputyPath);
	GetEntPropString(entity, Prop_Data, "m_ModelName", m_ModelName, sizeof(m_ModelName));
	if (StrEqual( iconbuffer, m_ModelName))
		return Plugin_Continue;
	return Plugin_Handled;
}


public Action Should_TransmitP(int entity, int client)
{
	char m_ModelName[PLATFORM_MAX_PATH];
	char iconbuffer[256];
	Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconPrisonerPath);
	GetEntPropString(entity, Prop_Data, "m_ModelName", m_ModelName, sizeof(m_ModelName));
	if (StrEqual( iconbuffer, m_ModelName))
		return Plugin_Continue;
	return Plugin_Handled;
}


/******************************************************************************
                   STOCKS
******************************************************************************/


stock int SpawnIcon(int client) 
{
	if (!IsClientInGame(client) || !IsPlayerAlive(client) || (!gc_bIconWarden.BoolValue && IsClientWarden(client)) || (!gc_bIconGuard.BoolValue && (GetClientTeam(client) == CS_TEAM_CT && !IsClientWarden(client) && !IsClientDeputy(client))) || (!gc_bIconDeputy.BoolValue && (!IsClientWarden(client) && IsClientDeputy(client))) || (!gc_bIconPrisoner.BoolValue && (GetClientTeam(client) == CS_TEAM_T))) return -1;
	
	RemoveIcon(client);
	
	char iTarget[16];
	Format(iTarget, 16, "client%d", client);
	DispatchKeyValue(client, "targetname", iTarget);

	g_iIcon[client] = CreateEntityByName("env_sprite");

	if (!g_iIcon[client]) return -1;
	char iconbuffer[256];
	if (IsClientWarden(client)) Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconWardenPath);
	else if (IsClientDeputy(client)) Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconDeputyPath);
	else if (GetClientTeam(client) == CS_TEAM_CT) Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconGuardPath);
	else if (GetClientTeam(client) == CS_TEAM_T) Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconPrisonerPath);
	
	DispatchKeyValue(g_iIcon[client], "model", iconbuffer);
	DispatchKeyValue(g_iIcon[client], "classname", "env_sprite");
	DispatchKeyValue(g_iIcon[client], "spawnflags", "1");
	DispatchKeyValue(g_iIcon[client], "scale", "0.3");
	DispatchKeyValue(g_iIcon[client], "rendermode", "1");
	DispatchKeyValue(g_iIcon[client], "rendercolor", "255 255 255");
	DispatchSpawn(g_iIcon[client]);
	
	float origin[3];
	GetClientAbsOrigin(client, origin);
	origin[2] = origin[2] + 90.0;
	
	TeleportEntity(g_iIcon[client], origin, NULL_VECTOR, NULL_VECTOR);
	SetVariantString(iTarget);
	AcceptEntityInput(g_iIcon[client], "SetParent", g_iIcon[client], g_iIcon[client], 0);
	if (IsClientWarden(client)) SDKHook(g_iIcon[client], SDKHook_SetTransmit, Should_TransmitW);
	else if (IsClientDeputy(client)) SDKHook(g_iIcon[client], SDKHook_SetTransmit, Should_TransmitD);
	else if (GetClientTeam(client) == CS_TEAM_CT)  SDKHook(g_iIcon[client], SDKHook_SetTransmit, Should_TransmitG);
	else if (GetClientTeam(client) == CS_TEAM_T)  SDKHook(g_iIcon[client], SDKHook_SetTransmit, Should_TransmitP);
	return g_iIcon[client];
}


stock void RemoveIcon(int client) 
{
	if (g_iIcon[client] > 0 && IsValidEdict(g_iIcon[client]))
	{
		AcceptEntityInput(g_iIcon[client], "Kill");
		g_iIcon[client] = -1;
	}
}