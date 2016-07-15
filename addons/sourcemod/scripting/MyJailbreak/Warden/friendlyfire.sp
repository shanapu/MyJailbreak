// Friendly Fire module for MyJailbreak - Warden

//Includes
#include <sourcemod>
#include <cstrike>
#include <warden>
#include <colors>
#include <autoexecconfig>
#include <myjailbreak>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//ConVars
ConVar gc_bFF;
ConVar g_bFF;

public void FriendlyFire_OnPluginStart()
{
	//Client commands
	RegConsoleCmd("sm_setff", Command_FriendlyFire, "Allows player to see the state and the Warden to toggle friendly fire");
	
	//AutoExecConfig
	gc_bFF = AutoExecConfig_CreateConVar("sm_warden_ff", "1", "0 - disabled, 1 - enable switch ff for T ", _, true,  0.0, true, 1.0);
	
	//Hooks
	HookEvent("round_end", FriendlyFire_RoundEnd);
	
	//FindConVar
	g_bFF = FindConVar("mp_teammates_are_enemies");
}

public void FriendlyFire_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if(gc_bPlugin.BoolValue)
	{
		if (g_bFF.BoolValue) 
		{
			SetCvar("mp_teammates_are_enemies", 0);
			g_bFF = FindConVar("mp_teammates_are_enemies");
			CPrintToChatAll("%t %t", "warden_tag", "warden_ffisoff" );
		}
	}
}

public Action Command_FriendlyFire(int client, int args)
{
	if (gc_bFF.BoolValue) 
	{
		if (g_bFF.BoolValue) 
		{
			if (client == g_iWarden)
			{
				SetCvar("mp_teammates_are_enemies", 0);
				g_bFF = FindConVar("mp_teammates_are_enemies");
				CPrintToChatAll("%t %t", "warden_tag", "warden_ffisoff" );
			}else CPrintToChatAll("%t %t", "warden_tag", "warden_ffison" );
			
		}
		else
		{	
			if (client == g_iWarden)
			{
				SetCvar("mp_teammates_are_enemies", 1);
				g_bFF = FindConVar("mp_teammates_are_enemies");
				CPrintToChatAll("%t %t", "warden_tag", "warden_ffison" );
			}
			else CPrintToChatAll("%t %t", "warden_tag", "warden_ffisoff" );
		}
	}
}
