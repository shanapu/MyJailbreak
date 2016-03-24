#include <sourcemod>
#include <cstrike>
#include <colors>
#include <sdktools>
#pragma semicolon 1

#define PLUGIN_VERSION "1.0"


new Handle:g_c_knife = INVALID_HANDLE;
new Handle:g_c_enabled = INVALID_HANDLE;
new bool:g_capitulated[MAXPLAYERS+1] = false;
new Handle:Timer_c[MAXPLAYERS+1];

public Plugin:myinfo = 
{
	name = "Capitulation/Ergeben",
	author = "Jackmaster",
	description = "Strips all sweps",
	version = PLUGIN_VERSION,
	url = "nourl"
}


public OnPluginStart()
{
	HookEvent("round_start", EventRoundStart);
	RegConsoleCmd("sm_c", capitu);
	RegConsoleCmd("sm_e", capitu);
	RegConsoleCmd("sm_ergeben", capitu);
	RegConsoleCmd("sm_capitulation", capitu);
	LoadTranslations("capitulation");
	g_c_enabled = CreateConVar("sm_capitulation_enable", "1.0", "Enable or Disable capitulation Plugin");
	g_c_knife = CreateConVar("sm_capitulation_timer", "10.0", "Time after the player gets a knife");
	AutoExecConfig(true, "plugin.capitulation");
}

public Action:capitu(client, args)
{
	new isOn = GetConVarBool(g_c_enabled);
	if ((isOn) == 1)
	{
		if (GetClientTeam(client) == CS_TEAM_T && (IsPlayerAlive(client)))
		{
			if (!(g_capitulated[client]))
			{
				new Float:timerca = GetConVarFloat(g_c_knife);
				g_capitulated[client] = true;
				TextPrintc(client);
				SetEntityRenderMode(client,RENDER_TRANSCOLOR);
				SetEntityRenderColor(client, 0, 255, 0, 255);
				Timer_c[client] = CreateTimer(timerca, knifes, client);
				new index;
				for (new i; i <= 4; i++)
				{
					if((index = GetPlayerWeaponSlot(client, i)) != -1)
					{
						CS_DropWeapon(client, index, true, false);
						AcceptEntityInput(index, "Kill");
					}
				}
			}
			else
			{
				CPrintToChat(client, "%t", "MESSAGE_ALREADYCAPITULATED");
			}
		}
		else
		{
			CPrintToChat(client, "%t", "MESSAGE_NOTORDEATH");
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
			g_capitulated[client] = false;
			if (Timer_c[client] != INVALID_HANDLE)
			{
				CloseHandle(Timer_c[client]);
				Timer_c[client] = INVALID_HANDLE;
			}
		}
	}
	return Plugin_Continue;
}

public OnClientDisconnect(client)
{
	if (Timer_c[client] != INVALID_HANDLE)
	{
		CloseHandle(Timer_c[client]);
		Timer_c[client] = INVALID_HANDLE;
	}
}

public Action:TextPrintc(client)
{	
	new String:getName[MAX_NAME_LENGTH];
	GetClientName(client, getName, sizeof(getName));
	CPrintToChatAll("%t", "MESSAGE_CAPITULATION", getName);
	PrintCenterTextAll("%t", "CENTERMESSAGE_CAPITULATION", getName);
}

public Action:knifes(Handle:timer, any:client)
{
	if (IsClientConnected(client))
	{
		GivePlayerItem(client,"weapon_knife");
		CPrintToChat(client, "%t", "MESSAGE_KNIFEBACK");
		SetEntityRenderMode(client,RENDER_TRANSCOLOR);
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
	Timer_c[client] = INVALID_HANDLE;
}

