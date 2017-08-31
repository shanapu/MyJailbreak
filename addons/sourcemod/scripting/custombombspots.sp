/*
 * Custom Bomb Spots
 * by: shanapu
 * https://github.com/shanapu/
 * 
 * Copyright (C) 2016-2017 Thomas Schmidt (shanapu)
 *
 * This file is part of the MyJailbreak SourceMod Plugin.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 */


#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <devzones>

bool bBomb[MAXPLAYERS+1] = {false, ...}; 



new Handle:g_Timer_BombDefused = INVALID_HANDLE;
new Handle:g_Timer_CheckCanDefuse = INVALID_HANDLE;

new bool:g_bPressedUse[MAXPLAYERS];
new g_iDefuser = -1; //Index of the person who defused the bomb
new g_iC4Ent = -1; //Entity Index of the dropped c4


Handle g_hBeaconTimer				= INVALID_HANDLE;
float g_vecBeaconOrigin[3];
int g_BeamIndex = -1;

ConVar g_hCvarBeaconRadius			= null;
ConVar g_hCvarBeaconLifetime		= null;
ConVar g_hCvarBeaconWidth			= null;
ConVar g_hCvarBeaconAmplitude		= null;
ConVar g_hCvarBeaconColor			= null;
ConVar g_hCvarBeaconRandomColor		= null;


#pragma semicolon 1
//#pragma newdecls required

public Plugin myinfo = {
	name = "Custom Bomb Spots",
	author = "shanapu",
	description = "Add custom Bomb Spots with Dev-Zones",
	version = "1.6",
	url = "https://github.com/shanapu/"
};

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_PostThink, OnPostThink);
}

public void OnMapStart() {
	g_BeamIndex = PrecacheModel("materials/sprites/laserbeam.vmt", true);
}

public void OnMapEnd() {
	delete g_hBeaconTimer;
}

public void OnPluginStart()
{
	g_hCvarBeaconRadius			= CreateConVar("bomb_beacon_radius",		"600.0",		"Set beacon radius");
	g_hCvarBeaconLifetime		= CreateConVar("bomb_beacon_lifetime",		"1.0",			"Set beacon lifetime");
	g_hCvarBeaconWidth			= CreateConVar("bomb_beacon_width",			"10.0",			"Set beacon width");
	g_hCvarBeaconAmplitude		= CreateConVar("bomb_beacon_amplitude",		"1.0",			"Set beacon amplitude");
	g_hCvarBeaconColor			= CreateConVar("bomb_beacon_color",			"255 0 0 255",	"Set beacon color");
	g_hCvarBeaconRandomColor	= CreateConVar("bomb_beacon_randomcolor",	"1",			"Set beacon randomcolor");
	AutoExecConfig(true);
	
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("bomb_exploded",Event_BombExploded);
}

public void Event_BombExploded(Event event, char[] name, bool dontBroadcast)
{
	CS_TerminateRound(5.0, CSRoundEnd_TargetBombed);
	
	delete g_hBeaconTimer;
}

public void Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	delete g_hBeaconTimer;
	int client = GetRandomTerror();
	GivePlayerItem(client, "weapon_c4");
}

public void Event_PlayerSpawn(Event event, char [] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	bBomb[client] = false;

	if (GetClientTeam(client) == CS_TEAM_CT)
	{
		SetEntProp(client, Prop_Send, "m_bHasDefuser", 1);
	}
}

public void OnPostThink(int client)
{
	if (bBomb[client])
	{
		SetEntProp(client, Prop_Send, "m_bInBombZone", 1);
		SetEntProp(client, Prop_Send, "m_bInNoDefuseArea", 0);
	}
	else
	{
		SetEntProp(client, Prop_Send, "m_bInBombZone", 0);
		SetEntProp(client, Prop_Send, "m_bInNoDefuseArea", 1);
	}
}

public int Zone_OnClientEntry(int client, char [] zone)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client))
		return;

	if(StrContains(zone, "bombspot", false) != 0)
		return;

	bBomb[client] = true;
}

public int Zone_OnClientLeave(int client, char [] zone)
{
	if(client < 1 || client > MaxClients || !IsClientInGame(client) ||!IsPlayerAlive(client))
		return;

	if(StrContains(zone, "bombspot", false) != 0)
		return;

	bBomb[client] = false;
}

int GetRandomTerror()
{
	int[] clients = new int[MaxClients];
	int clientCount;

	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
	{
		if ((GetClientTeam(i) == CS_TEAM_T) && IsPlayerAlive(i))
		{
			clients[clientCount++] = i;
		}
	}

	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)];
}



public Action:Event_PlayerDeath(Handle:hEvent, const String:szName[], bool:bDontBroadcast)
{
	new iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if(iClient == g_iDefuser)
	{
		DisableTimers();
		CreateBarTime(iClient, 0);
		g_bPressedUse[iClient] = false;
	}
}

public OnEntityCreated(entity, const String:classname[])
{
	if(StrEqual(classname, "planted_c4", false))
	{
		g_iC4Ent = entity;

		GetEntPropVector(g_iC4Ent, Prop_Send, "m_vecOrigin", g_vecBeaconOrigin);
		g_vecBeaconOrigin[2] = g_vecBeaconOrigin[2]+10;

		Timer_BombBeacon(INVALID_HANDLE);
		g_hBeaconTimer = CreateTimer(1.0, Timer_BombBeacon, _, TIMER_REPEAT);
	}
}

public Action:OnPlayerRunCmd(iClient, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if(IsClientInGame(iClient) && IsPlayerAlive(iClient) && GetClientTeam(iClient) == CS_TEAM_CT)
	{
		if(!g_bPressedUse[iClient] && (buttons & IN_USE))
		{
			g_bPressedUse[iClient] = true;
			
			if(g_iDefuser == -1)
			{
				if(IsTargetInSightRange(iClient, g_iC4Ent))
				{
					new String:szPlayerName[32];
					GetClientName(iClient, szPlayerName, sizeof(szPlayerName));
					g_iDefuser = iClient;
					
					new iDefuseKit = GetEntProp(iClient, Prop_Send, "m_bHasDefuser");
					new Float:flDefuseTime = 10.0;
						
					
					if(!iDefuseKit)
					{
						AnnouncementToAll("%s %s", szPlayerName, "is defusing the bomb!");
						g_Timer_BombDefused = CreateTimer(flDefuseTime, BombDefused, iClient);
						g_Timer_CheckCanDefuse = CreateTimer(0.1, CheckCanDefuse, iClient, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
						CreateBarTime(iClient, 10);
					}
					else if(iDefuseKit)
					{
						AnnouncementToAll("%s %s", szPlayerName, "is defusing the bomb!");
						g_Timer_BombDefused = CreateTimer((flDefuseTime*0.5), BombDefused, iClient);
						g_Timer_CheckCanDefuse = CreateTimer(0.1, CheckCanDefuse, iClient, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
						CreateBarTime(iClient, RoundToNearest(10.0*0.5));
					}

				}
			}
			else
			{
				decl String:szPlayerName[32];
				GetClientName(g_iDefuser, szPlayerName, sizeof(szPlayerName));
				Announcement(iClient, "%s %s", szPlayerName, "is already defusing the bomb!");
			}
		}
	}
	
	if(g_bPressedUse[iClient] && !(buttons & IN_USE))
	{
		if(g_Timer_BombDefused != INVALID_HANDLE)
		{
			DisableTimers();
			CreateBarTime(iClient, 0);
		}
		
		g_bPressedUse[iClient] = false;
	}
}

public Action:BombDefused(Handle:hTimer, any:iClient)
{
	RemoveEdict(g_iC4Ent);
	g_Timer_BombDefused = INVALID_HANDLE;
	SetEntProp(iClient, Prop_Send, "m_bIsDefusing", 0);
	
	new iMoney = (GetEntProp(iClient, Prop_Send, "m_iAccount")+200);
	for(new i=1;i<=MaxClients;i++)
	{
		if(IsClientInGame(i) && GetClientTeam(iClient) == CS_TEAM_CT)
		{
			SetEntProp(i, Prop_Send, "m_iAccount", iMoney);
		}
	}
	
	new String:szPlayerName[32];
	GetClientName(iClient, szPlayerName, sizeof(szPlayerName));
	AnnouncementToAll("%s %s", szPlayerName, "has defused the bomb!!");
	

	new iTeamScore = (CS_GetTeamScore(CS_TEAM_CT) + 1);
	CS_SetTeamScore(CS_TEAM_CT, iTeamScore);
	SetTeamScore(CS_TEAM_CT, iTeamScore);
	CS_TerminateRound(5.0, CSRoundEnd_BombDefused, false);

}

public Action:CheckCanDefuse(Handle:hTimer, any:iClient)
{
	if(IsClientInGame(iClient))
	{
		if(!IsTargetInSightRange(iClient, g_iC4Ent))
		{
			DisableTimers();
			CreateBarTime(iClient, 0);
			g_bPressedUse[iClient] = false;
		}
	}
}

public DisableTimers()
{
	g_iDefuser = -1;
	
	if(g_Timer_BombDefused != INVALID_HANDLE)
	{
		KillTimer(g_Timer_BombDefused);
		g_Timer_BombDefused = INVALID_HANDLE;
	}
	
	if(g_Timer_CheckCanDefuse != INVALID_HANDLE)
	{
		KillTimer(g_Timer_CheckCanDefuse);
		g_Timer_CheckCanDefuse = INVALID_HANDLE;
	}
}

public CreateBarTime(iClient, iDuration)
{
	if(IsClientInGame(iClient))
	{
		if(iDuration)
		{
			g_iDefuser = iClient;
			SetEntProp(iClient, Prop_Send, "m_bIsDefusing", 1);
			SetEntPropFloat(iClient, Prop_Send, "m_flProgressBarStartTime", GetGameTime());
		}
		else
		{
			g_iDefuser = -1;
			SetEntProp(iClient, Prop_Send, "m_bIsDefusing", 0);
		}
		SetEntProp(iClient, Prop_Send, "m_iProgressBarDuration", iDuration);
	}
}

stock AnnouncementToAll(const String:szAnnouncement[], any:...)
{
	decl String:szAnnouncementBuffer[192];

	for (new i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i))
			continue;

		VFormat(szAnnouncementBuffer, sizeof(szAnnouncementBuffer), szAnnouncement, 2);
		PrintToChat(i, "%s", szAnnouncementBuffer);
	}
}

stock Announcement(iClient, const String:szAnnouncement[], any:...)
{
	decl String:szAnnouncementBuffer[192];

	VFormat(szAnnouncementBuffer, sizeof(szAnnouncementBuffer), szAnnouncement, 3);
	PrintToChat(iClient, "%s", szAnnouncementBuffer);

}

stock bool:IsTargetInSightRange(client, target, Float:angle=90.0, Float:distance=0.0, bool:heightcheck=true, bool:negativeangle=false)
{
	if(angle > 360.0 || angle < 0.0)
		return false;
		
	if(!IsClientConnected(client) && !(client))
		return false;
		
	if(!IsValidEdict(target))
		return false;
		
	decl Float:clientpos[3], Float:targetpos[3], Float:anglevector[3], Float:targetvector[3], Float:resultangle, Float:resultdistance;
	
	GetClientEyeAngles(client, anglevector);
	anglevector[0] = anglevector[2] = 0.0;
	GetAngleVectors(anglevector, anglevector, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(anglevector, anglevector);
	if(negativeangle)
		NegateVector(anglevector);

	GetClientAbsOrigin(client, clientpos);
	GetEntPropVector(target, Prop_Send, "m_vecOrigin", targetpos);
	if(heightcheck && distance > 0)
		resultdistance = GetVectorDistance(clientpos, targetpos);
	clientpos[2] = targetpos[2] = 0.0;
	MakeVectorFromPoints(clientpos, targetpos, targetvector);
	NormalizeVector(targetvector, targetvector);
	
	resultangle = RadToDeg(ArcCosine(GetVectorDotProduct(targetvector, anglevector)));
	
	// Check if player is close enough to target bomb
	new Float:flDistance;
	flDistance = GetVectorDistance(clientpos, targetpos, false);
	
	if(flDistance > 45.0)
		return false;
	
	if(resultangle <= angle/2)	
	{
		if(distance > 0)
		{
			if(!heightcheck)
				resultdistance = GetVectorDistance(clientpos, targetpos);
			if(distance >= resultdistance)
				return true;
			else
				return false;
		}
		else
			return true;
	}
	else
		return false;
}


public Action Timer_BombBeacon(Handle timer) {
	int color[4];
	if (GetConVarInt(g_hCvarBeaconRandomColor) == 1) {
		PickRandomColor(color);
	} else {
		GetConVarColor(g_hCvarBeaconColor, color);
	}
	SetEntPropEnt(g_iC4Ent, Prop_Send, "m_bSpotted", 1);
	TE_SetupBeamRingPoint(g_vecBeaconOrigin, 10.0, GetConVarFloat(g_hCvarBeaconRadius), g_BeamIndex, -1, 0, 30, GetConVarFloat(g_hCvarBeaconLifetime), GetConVarFloat(g_hCvarBeaconWidth), GetConVarFloat(g_hCvarBeaconAmplitude), color, 0, 0);
	TE_SendToAll();
}

stock void PickRandomColor(int color[4], int min = 1, int max = 255, int alpha = 255) {
	color[0] = GetRandomInt(min, max);
	color[1] = GetRandomInt(min, max);
	color[2] = GetRandomInt(min, max);
	if (alpha == -1) {
		color[3] = GetRandomInt(min, max);
	} else {
		color[3] = alpha;
	}
}

stock bool GetConVarColor(const Handle convar, int color[4]) {
	char szColor[4][16];
	GetConVarString(g_hCvarBeaconColor, szColor[0], sizeof(szColor[]));

	if (ExplodeString(szColor[0], " ", szColor, 4, sizeof(szColor[])) == 4) {
		color[0] = StringToInt(szColor[0]);
		color[1] = StringToInt(szColor[1]);
		color[2] = StringToInt(szColor[2]);
		color[3] = StringToInt(szColor[3]);

		return true;
	}

	return false;
}


