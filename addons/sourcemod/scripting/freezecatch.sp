//includes
#include <cstrike>
#include <sourcemod>
#include <sdktools>
#include <smartjaildoors>
#include <sdkhooks>

//Compiler Options
#pragma semicolon 1

#define PLUGIN_VERSION   "0.1"

new freezetime;
new roundtime;
new roundtimenormal;
new votecount;
new CatchRound;
new RoundLimits;

new bool:catched[MAXPLAYERS+1];

new Handle:LimitTimer;
new Handle:CatchTimer;
new Handle:WeaponTimer;
new Handle:CatchMenu;
new Handle:roundtimec;
new Handle:roundtimenormalc;
new Handle:freezetimec;
new Handle:RoundLimitsc;
new Handle:g_wenabled=INVALID_HANDLE;
new Handle:g_catchprefix=INVALID_HANDLE;
new Handle:g_catchcmd=INVALID_HANDLE;
new Handle:cvar;

new bool:IsCatch;
new bool:StartCatch;

new String:voted[1500];
new String:g_wcatchprefix[64];
char g_wcatchcmd[64];


public Plugin myinfo = {
	name = "MyJailbreak - Catch & freeze",
	author = "shanapu & Floody.de, fransico",
	description = "Jailbreak Catch script",
	version = PLUGIN_VERSION,
	url = ""
};



public OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreakCatch.phrases");
	
	RegAdminCmd("sm_setcatch", SetCatch, ADMFLAG_GENERIC);
	
	CreateConVar("sm_catch_version", "PLUGIN_VERSION", "The version of the SourceMod plugin MyJailBreak - War", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_wenabled = CreateConVar("sm_catch_enable", "1", "0 - disabled, 1 - enable war");
	g_catchprefix = CreateConVar("sm_catch_prefix", "war", "Insert your Jailprefix. shown in braces [war]");
	g_catchcmd = CreateConVar("sm_catch_cmd", "!verstecken", "Insert your 2nd chat trigger. !war still enabled");
	roundtimec = CreateConVar("sm_catch_roundtime", "5", "Round time for a single war round");
	roundtimenormalc = CreateConVar("sm_nocatch_roundtime", "12", "set round time after a war round zour normal mp_roudntime");
	RoundLimitsc = CreateConVar("sm_catch_roundsnext", "3", "Runden nach Krieg oder Mapstart bis Krieg gestartet werden kann");
	

	GetConVarString(g_catchprefix, g_wcatchprefix, sizeof(g_wcatchprefix));
	GetConVarString(g_catchcmd, g_wcatchcmd, sizeof(g_wcatchcmd));
	
	AutoExecConfig(true, "MyJailbreak_Catch");
	
	IsCatch = false;
	StartCatch = false;
	votecount = 0;
	CatchRound = 0;
	
	HookEvent("round_start", RoundStart);
	HookEvent("player_say", PlayerSay);
	HookEvent("round_end", RoundEnd);
	HookEvent("player_team", EventPlayerTeam);
	HookEvent("player_death", EventPlayerTeam);
	
	for(new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i)) OnClientPutInServer(i);
}


public OnMapStart()
{
	//new String:voted[1500];

	votecount = 0;
	CatchRound = 0;
	IsCatch = false;
	StartCatch = false;
	RoundLimits = 0;
	
	
	freezetime = GetConVarInt(freezetimec);
	roundtime = GetConVarInt(roundtimec);
	roundtimenormal = GetConVarInt(roundtimenormalc);
}

public OnConfigsExecuted()
{
	roundtime = GetConVarInt(roundtimec);
	roundtimenormal = GetConVarInt(roundtimenormalc);
	RoundLimits = 0;
}

public RoundEnd(Handle:event, String:name[], bool:dontBroadcast)
{
	new winner = GetEventInt(event, "winner");
	
	if (IsCatch)
	{
		for(new client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client)) SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
		}
		
		if (LimitTimer != INVALID_HANDLE) KillTimer(LimitTimer);
		if (CatchTimer != INVALID_HANDLE) KillTimer(CatchTimer);
		if (WeaponTimer != INVALID_HANDLE) KillTimer(WeaponTimer);
		
		roundtime = GetConVarInt(roundtimec);
		roundtimenormal = GetConVarInt(roundtimenormalc);
		
		if (winner == 2) PrintCenterTextAll("%t", "catch_twin");
		if (winner == 3) PrintCenterTextAll("%t", "catch_ctwin");
		IsCatch = false;
		StartCatch = false;
		CatchRound = 0;
		Format(voted, sizeof(voted), "");
		SetCvar("sm_hosties_lr", 1);
		SetCvar("sm_war_enable", 1);
		SetCvar("sm_hide_enable", 1);
		SetCvar("dice_enable", 1);
		SetCvar("sm_beacon_enabled", 0);
		SetCvar("sv_infinite_ammo", 0);
		SetCvar("sm_warffa_enable", 1);
		SetCvar("sm_warden_enable", 1);
		SetCvar("mp_roundtime", roundtimenormal);
		SetCvar("mp_roundtime_hostage", roundtimenormal);
		SetCvar("mp_roundtime_defuse", roundtimenormal);
		PrintToChatAll("[%s] %t", g_wcatchprefix, "catch_end");
	}
	if (StartCatch)
	{
	SetCvar("mp_roundtime", roundtime);
	SetCvar("mp_roundtime_hostage", roundtime);
	SetCvar("mp_roundtime_defuse", roundtime);
	}
}

public Action SetCatch(int client,int args)
{
	if(GetConVarInt(g_wenabled) == 1)	
	{
	StartCatch = true;
	RoundLimits = GetConVarInt(RoundLimitsc);
	votecount = 0;
	PrintToChatAll("[%s] %t", g_wcatchprefix, "catch_next");
	}
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action:OnWeaponCanUse(client, weapon)
{
	decl String:sWeapon[32];
	GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));

	if(!StrEqual(sWeapon, "weapon_knife"))
		{
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
			if(IsCatch == true)
			{
			return Plugin_Handled;
			}
			}
		}
	return Plugin_Continue;
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(victim) || attacker == victim || !IsValidClient(attacker)) return Plugin_Continue;
	
	if(IsCatch == false)
	{
		return Plugin_Continue;
	}
	
	if(GetClientTeam(victim) == CS_TEAM_T && GetClientTeam(attacker) == CS_TEAM_CT && !catched[victim])
	{
		CatchEm(victim, attacker);
		CheckStatus();
	}
	if(GetClientTeam(victim) == CS_TEAM_T && GetClientTeam(attacker) == CS_TEAM_T && catched[victim] && !catched[attacker])
	{
		FreeEm(victim, attacker);
	}

	
	return Plugin_Handled;
}

public IsValidClient( client ) 
{
	if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) 
	return false; 
	
	return true; 
}

public RoundStart(Handle:event, String:name[], bool:dontBroadcast)
{
	if (StartCatch)
	{
		
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_war_enable", 0);
		SetCvar("sm_warffa_enable", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_beacon_enabled", 1);
		SetCvar("sm_hide_enable", 0);
		SetCvar("sv_infinite_ammo", 1);
		SetCvar("dice_enable", 0);
		IsCatch = true;
		CatchRound++;
		StartCatch = false;
		SJD_OpenDoors();

		CatchMenu = CreatePanel();
		DrawPanelText(CatchMenu, "Wir spielen eine Catch Round!");

		DrawPanelText(CatchMenu, "Die Terrors verstecken sich ");
		DrawPanelText(CatchMenu, "-----------------------------------");
		DrawPanelText(CatchMenu, "Die Counter werden zu catchs");
		DrawPanelText(CatchMenu, "								   ");
		DrawPanelText(CatchMenu, "- In der Waffenstillstandsphase darf man schon aus der Waffenkammer!");
		DrawPanelText(CatchMenu, "- Alle normalen Jailregeln sind dabei aufgehoben!");
		DrawPanelText(CatchMenu, "- Buchstaben-, Yard- und Waffenkammercampen ist verboten!");
		DrawPanelText(CatchMenu, "- Der letzte Terrorist hat keinen Wunsch!");
		DrawPanelText(CatchMenu, "- Jeder darf überall hin wo er will!");
		DrawPanelText(CatchMenu, "-----------------------------------");
		
		if (CatchRound > 0)
			{
				for(new client=1; client <= MaxClients; client++)
				{
					
					if (IsClientInGame(client))
					{
						if (GetClientTeam(client) == 3) //ct
						{

						}
						if (GetClientTeam(client) == 2) //t
						{

						}
					}
					PrintToChatAll("[%s] Versteckt euch die Catchs kommen", g_wcatchprefix);
					if (IsClientInGame(client))
					{
					SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					SendPanelToClient(CatchMenu, client, Pass, 15);
					SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
					}
				}
				
				PrintCenterTextAll("%t", "catch_start");
				PrintToChatAll("[%s] %t", g_wcatchprefix, "catch_start");
				}
	}
}

public Pass(Handle:menu, MenuAction:action, param1, param2)
{
}


public PlayerSay(Handle:event, String:name[], bool:dontBroadcast)
{
	decl String:text[256];
	decl String:steamid[64];
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	GetClientAuthString(client, steamid, sizeof(steamid));
	GetEventString(event, "text", text, sizeof(text));
	
	if (StrEqual(text, g_wcatchcmd) || StrEqual(text, "!catch"))
	{
	if(GetConVarInt(g_wenabled) == 1)
	{	
		if (GetTeamClientCount(3) > 0)
		{
			if (RoundLimits == 0)
			{
				if (!IsCatch && !StartCatch)
				{
					if (StrContains(voted, steamid, true) == -1)
					{
						new playercount = (GetClientCount(true) / 2);
						
						votecount++;
						
						new Missing = playercount - votecount + 1;
						
						Format(voted, sizeof(voted), "%s,%s", voted, steamid);
						
						if (votecount > playercount)
						{
							StartCatch = true;
							
							RoundLimits = GetConVarInt(RoundLimitsc);
							votecount = 0;
							
							PrintToChatAll("[%s] %t", g_wcatchprefix, "catch_next");
						}
						else PrintToChatAll("[%s] %i Votes bis Krieg beginnt", g_wcatchprefix, Missing);
						
					}
					else PrintToChat(client, "[%s] %t", g_wcatchprefix, "catch_voted");
				}
				else PrintToChat(client, "[%s] %t", g_wcatchprefix, "catch_progress");
			}
			else PrintToChat(client, "[%s] Du musst noch %i Runden warten", g_wcatchprefix, RoundLimits);
		}
		else PrintToChat(client, "[%s] %t", g_wcatchprefix, "catch_minct");
	}
	else PrintToChat(client, "[%s] %t", g_wcatchprefix, "catch_disabled");
	}
}



public SetCvar(String:cvarName[64], value)
{
	cvar = FindConVar(cvarName);
	if(cvar == INVALID_HANDLE) return;
	
	new flags = GetConVarFlags(cvar);
	flags &= ~FCVAR_NOTIFY;
	SetConVarFlags(cvar, flags);

	SetConVarInt(cvar, value);

	flags |= FCVAR_NOTIFY;
	SetConVarFlags(cvar, flags);
}

public SetCvarF(String:cvarName[64], Float:value)
{
	cvar = FindConVar(cvarName);
	if(cvar == INVALID_HANDLE) return;

	new flags = GetConVarFlags(cvar);
	flags &= ~FCVAR_NOTIFY;
	SetConVarFlags(cvar, flags);

	SetConVarFloat(cvar, value);

	flags |= FCVAR_NOTIFY;
	SetConVarFlags(cvar, flags);
}

public OnMapEnd()
{
	IsCatch = false;
	StartCatch = false;
	votecount = 0;
	CatchRound = 0;
	
	voted[0] = '\0';
}

public OnClientDisconnect_Post(client)
{
	if(IsCatch == false)
	{
		return;
	}
	CheckStatus();
}
public Action:EventPlayerTeam(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(IsCatch == false)
	{
		return;
	}
	CheckStatus();
}

CatchEm(client, attacker)
{
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
	SetEntityRenderColor(client, 0, 0, 255, 255);
	catched[client] = true;
	
	PrintToChatAll("[\x04goo.event\x01] Wärter %N hat Häftling %N gefreezt", attacker, client);
}

FreeEm(client, attacker)
{
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	SetEntityRenderColor(client, 255, 255, 255, 0);
	catched[client] = false;
	
	PrintToChatAll("[\x04goo.event\x01] Häftling %N hat %N befreit", attacker, client);
}

CheckStatus()
{
	new number = 0;
	for (new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T && !catched[i]) number++;
		
	if(number == 0) CS_TerminateRound(5.0, CSRoundEnd_CTWin);
}