//includes
#include <cstrike>
#include <sourcemod>
#include <colors>
#include <sdktools>
#include <smartjaildoors>
#include <sdkhooks>

//Compiler Options
#pragma semicolon 1

#define PLUGIN_VERSION   "0.x"

new roundtime;
new roundtimenormal;
new votecount;
new CatchRound;
new RoundLimits;

new bool:catched[MAXPLAYERS+1];


ConVar gc_bTagEnabled;


new Handle:CatchMenu;
new Handle:roundtimec;
new Handle:roundtimenormalc;
new Handle:RoundLimitsc;
new Handle:g_wenabled=INVALID_HANDLE;
new Handle:cvar;

new bool:IsCatch;
new bool:StartCatch;

new String:voted[1500];



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
	roundtimec = CreateConVar("sm_catch_roundtime", "5", "Round time for a single war round");
	roundtimenormalc = CreateConVar("sm_nocatch_roundtime", "12", "set round time after a war round zour normal mp_roudntime");
	RoundLimitsc = CreateConVar("sm_catch_roundsnext", "3", "Runden nach Krieg oder Mapstart bis Krieg gestartet werden kann");
	gc_bTagEnabled = CreateConVar("sm_hide_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch you sv_tags", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	
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
	
	

	roundtime = GetConVarInt(roundtimec);
	roundtimenormal = GetConVarInt(roundtimenormalc);
}

public OnConfigsExecuted()
{
	roundtime = GetConVarInt(roundtimec);
	roundtimenormal = GetConVarInt(roundtimenormalc);
	RoundLimits = 0;
	
	if (gc_bTagEnabled.BoolValue)
	{
		ConVar hTags = FindConVar("sv_tags");
		char sTags[128];
		hTags.GetString(sTags, sizeof(sTags));
		if (StrContains(sTags, "MyJailbreak", false) == -1)
		{
			StrCat(sTags, sizeof(sTags), ", MyJailbreak");
			hTags.SetString(sTags);
		}
	}
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
		SetCvar("sm_zombie_enable", 1);
		SetCvar("sm_duckhunt_enable", 1);
		SetCvar("dice_enable", 1);
		SetCvar("sm_beacon_enabled", 0);
		SetCvar("sv_infinite_ammo", 0);
		SetCvar("sm_ffa_enable", 1);
		SetCvar("sm_warden_enable", 1);
		SetCvar("mp_roundtime", roundtimenormal);
		SetCvar("mp_roundtime_hostage", roundtimenormal);
		SetCvar("mp_roundtime_defuse", roundtimenormal);
		CPrintToChatAll("%t %t", "catch_tag" , "catch_end");
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
	CPrintToChatAll("%t %t", "catch_tag" , "catch_next");
	}
}

public OnClientPutInServer(client)
{
	catched[client] = false;
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
		decl String:info1[255], String:info2[255], String:info3[255], String:info4[255], String:info5[255], String:info6[255], String:info7[255], String:info8[255];
		
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_beacon_enabled", 1);
		SetCvar("sv_infinite_ammo", 1);
		SetCvar("dice_enable", 0);
		IsCatch = true;
		CatchRound++;
		StartCatch = false;
		SJD_OpenDoors();
		CatchMenu = CreatePanel();
		Format(info1, sizeof(info1), "%T", "catch_info_Title", LANG_SERVER);
		SetPanelTitle(CatchMenu, info1);
		DrawPanelText(CatchMenu, "                                   ");
		Format(info2, sizeof(info2), "%T", "catch_info_Line1", LANG_SERVER);
		DrawPanelText(CatchMenu, info2);
		DrawPanelText(CatchMenu, "-----------------------------------");
		Format(info3, sizeof(info3), "%T", "catch_info_Line2", LANG_SERVER);
		DrawPanelText(CatchMenu, info3);
		Format(info4, sizeof(info4), "%T", "catch_info_Line3", LANG_SERVER);
		DrawPanelText(CatchMenu, info4);
		Format(info5, sizeof(info5), "%T", "catch_info_Line4", LANG_SERVER);
		DrawPanelText(CatchMenu, info5);
		Format(info6, sizeof(info6), "%T", "catch_info_Line5", LANG_SERVER);
		DrawPanelText(CatchMenu, info6);
		Format(info7, sizeof(info7), "%T", "catch_info_Line6", LANG_SERVER);
		DrawPanelText(CatchMenu, info7);
		Format(info8, sizeof(info8), "%T", "catch_info_Line7", LANG_SERVER);
		DrawPanelText(CatchMenu, info8);
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
						catched[client] = false;
						}
					}
					if (IsClientInGame(client))
					{
					SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					SendPanelToClient(CatchMenu, client, Pass, 15);
					}
				}
				
				PrintCenterTextAll("%t", "catch_start");
				CPrintToChatAll("%t %t", "catch_tag" , "catch_start");
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
	
	if (StrEqual(text, "!fangen") || StrEqual(text, "!catch"))
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
							
							SetCvar("sm_hide_enable", 0);
							SetCvar("sm_ffa_enable", 0);
							SetCvar("sm_zombie_enable", 0);
							SetCvar("sm_duckhunt_enable", 0);
							SetCvar("sm_war_enable", 0);
							
							CPrintToChatAll("%t %t", "catch_tag" , "catch_next");
						}
						else CPrintToChatAll("%t %t", "catch_tag" , "catch_need", Missing);
						
					}
					else CPrintToChat(client, "%t %t", "catch_tag" , "catch_voted");
				}
				else CPrintToChat(client, "%t %t", "catch_tag" , "catch_progress");
			}
			else CPrintToChat(client, "%t %t", "catch_tag" , "war_wait", RoundLimits);
		}
		else CPrintToChat(client, "%t %t", "catch_tag" , "catch_minct");
	}
	else CPrintToChat(client, "%t %t", "catch_tag" , "catch_disabled");
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
	
	CPrintToChatAll("%t %t", "catch_tag" , "catch_catch", attacker, client);
}

FreeEm(client, attacker)
{
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	SetEntityRenderColor(client, 255, 255, 255, 0);
	catched[client] = false;
	
	CPrintToChatAll("%t %t", "catch_tag" , "catch_unfreeze", attacker, client);
}

CheckStatus()
{
	new number = 0;
	for (new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T && !catched[i]) number++;
		
	if(number == 0) CS_TerminateRound(5.0, CSRoundEnd_CTWin);
	CPrintToChatAll("%t %t", "catch_tag" , "catch_end");
}