#include <sourcemod>
#include <cstrike>
#include <colors>
#pragma semicolon 1

#define PLUGIN_VERSION "1.0"


new Handle:g_colorback = INVALID_HANDLE;
new Handle:g_enabled = INVALID_HANDLE;
new bool:g_refused[MAXPLAYERS+1] = false;
new Handle:Timers[MAXPLAYERS+1];

public Plugin:myinfo = 
{
	name = "Refuse/Verweigern",
	author = "Jackmaster",
	description = "You can refuse a game",
	version = PLUGIN_VERSION,
	url = "nourl"
}


public OnPluginStart()
{
	HookEvent("round_start", EventRoundStart);
	RegConsoleCmd("sm_refuse", refusing);
	RegConsoleCmd("sm_v", refusing);
	RegConsoleCmd("sm_verweigern", refusing);
	LoadTranslations("refuse");
	g_enabled = CreateConVar("sm_refuse_enable", "1.0", "Enable or Disable Refuse Plugin");
	g_colorback = CreateConVar("sm_refuse_time_back", "10.0", "Time after the player gets his normal colors back");
	AutoExecConfig(true, "plugin.refuse");
}

public Action:refusing(client, args)
{
	new isOn = GetConVarBool(g_enabled);
	if ((isOn) == 1)
	{
		if (GetClientTeam(client) == CS_TEAM_T && (IsPlayerAlive(client)))
		{
			if (!(g_refused[client]))
			{
				g_refused[client] = true;
				new Float:refuse_color_time = GetConVarFloat(g_colorback);
				SetEntityRenderMode(client,RENDER_TRANSCOLOR);
				SetEntityRenderColor(client, 0, 0, 255, 255);
				TextPrint(client);
				Timers[client] = CreateTimer(refuse_color_time, ResetColor, client);
			}
			else
			{
				CPrintToChat(client, "%t", "MESSAGE_ALREADYREFUSED");
			}
		}
		else
		{
			CPrintToChat(client, "%t", "MESSAGE_DEATHORNOTT");
		}
	}
	return Plugin_Handled;
}

public Action:EventRoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	for(new client=1; client<=MaxClients; client++)
	{
		if (IsClientConnected(client))
		{
			g_refused[client] = false;
			if (Timers[client] != INVALID_HANDLE)
			{
				CloseHandle(Timers[client]);
				Timers[client] = INVALID_HANDLE;
			}
		}
	}
	return Plugin_Continue;
}

public OnClientDisconnect(client)
{
	if (Timers[client] != INVALID_HANDLE)
	{
		CloseHandle(Timers[client]);
		Timers[client] = INVALID_HANDLE;
	}
}

public Action:TextPrint(client)
{	
	new String:getName[MAX_NAME_LENGTH];
	GetClientName(client, getName, sizeof(getName));
	CPrintToChatAll("%t", "MESSAGE_REFUSING", getName);
}

public Action:ResetColor(Handle:timer, any:client)
{
	if (IsClientConnected(client))
	{
		SetEntityRenderMode(client,RENDER_TRANSCOLOR);
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
	Timers[client] = INVALID_HANDLE;
}