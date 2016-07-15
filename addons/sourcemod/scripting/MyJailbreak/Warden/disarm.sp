// Disarm module for MyJailbreak - Warden

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
ConVar gc_bDisarm;
ConVar gc_iDisarm;
ConVar gc_iDisarmMode;

//Integers
int g_iDisarm;

public void Disarm_OnPluginStart()
{
	//AutoExecConfig
	gc_bDisarm = AutoExecConfig_CreateConVar("sm_warden_disarm", "1", "0 - disabled, 1 - enable disarm weapon on shot the arms/hands", _, true,  0.0, true, 1.0);
	gc_iDisarm = AutoExecConfig_CreateConVar("sm_warden_disarm_mode", "1", "1 - Only warden can disarm, 2 - All CT can disarm, 3 - Everyone can disarm (CT & T)", _, true,  1.0, true, 3.0);
	gc_iDisarmMode = AutoExecConfig_CreateConVar("sm_warden_disarm_drop", "1", "1 - weapon will drop, 2 - weapon  disapear", _, true,  1.0, true, 2.0);
	
	//Hooks 
	HookEvent("player_hurt", Disarm_PlayerHurt);
	HookEvent("round_start", Disarm_RoundStart);
}

public void Disarm_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_iDisarm = gc_iDisarm.IntValue;
}

public Action Disarm_PlayerHurt(Handle event, char[] name, bool dontBroadcast)
{
	if(gc_bPlugin.BoolValue && gc_bDisarm.BoolValue)
	{
		int victim 			= GetClientOfUserId(GetEventInt(event, "userid"));
		int attacker 		= GetClientOfUserId(GetEventInt(event, "attacker"));
		int hitgroup		= GetEventInt(event, "hitgroup");
		int victimweapon = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
		
		if (IsValidClient(attacker,true,false) && IsValidClient(victim,true,false))
		{
			if ((warden_iswarden(attacker) && g_iDisarm == 1) || ((GetClientTeam(attacker) == CS_TEAM_CT) && g_iDisarm == 2) || ((GetClientTeam(attacker) != GetClientTeam(victim)) && g_iDisarm == 3))
			{
				if(hitgroup == 4 || hitgroup == 5)
				{
					if(victimweapon != -1)
					{
						CPrintToChatAll("%t %t", "warden_tag", "warden_disarmed", victim, attacker);
						PrintHintText(victim, "%t", "warden_lostgun");
						
						if(gc_iDisarmMode.IntValue == 1)
						{
							CS_DropWeapon(victim, victimweapon, true, true);
							return Plugin_Stop;
						}
						else if(gc_iDisarmMode.IntValue == 2)
						{
							CS_DropWeapon(victim, victimweapon, true, true);
							
							if(IsValidEdict(victimweapon))
							{
								if (Entity_GetOwner(victimweapon) == -1)
								{
									AcceptEntityInput(victimweapon, "Kill");
								}
							}
							return Plugin_Stop;
						}
					}
				}
			}
		}
	}
	return Plugin_Continue;
}
