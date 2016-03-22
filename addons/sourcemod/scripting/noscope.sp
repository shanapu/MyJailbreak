//includes
#include <cstrike>
#include <sourcemod>
#include <sdktools>
#include <smartjaildoors>
#include <wardn>
#include <sdkhooks>

//Compiler Options
#pragma semicolon 1

#define PLUGIN_VERSION   "0.1"

ConVar gc_bTagEnabled;
new preparetime;
new roundtime;
new roundtimenormal;
new votecount;
new NoScopeRound;
new RoundLimits;
new m_flNextSecondaryAttack;

new Handle:LimitTimer;
new Handle:NoScopeTimer;
new Handle:WeaponTimer;
new Handle:NoScopeMenu;
new Handle:roundtimec;
new Handle:roundtimenormalc;
new Handle:preparetimec;
new Handle:RoundLimitsc;
new Handle:g_wenabled=INVALID_HANDLE;
new Handle:cvar;

new bool:IsNoScope;
new bool:StartNoScope;

new String:voted[1500];



public Plugin myinfo = {
	name = "MyJailbreak - NoScope",
	author = "shanapu & Floody.de, fransico",
	description = "Jailbreak NoScope script",
	version = PLUGIN_VERSION,
	url = ""
};



public OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreakNoScope.phrases");
	
	RegAdminCmd("sm_setnoscope", SetNoScope, ADMFLAG_GENERIC);
	
	CreateConVar("sm_noscope_version", "PLUGIN_VERSION", "The version of the SourceMod plugin MyJailBreak - War", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_wenabled = CreateConVar("sm_noscope_enable", "1", "0 - disabled, 1 - enable war");
	roundtimec = CreateConVar("sm_noscope_roundtime", "5", "Round time for a single war round");
	roundtimenormalc = CreateConVar("sm_nonoscope_roundtime", "12", "set round time after a war round zour normal mp_roudntime");
	preparetimec = CreateConVar("sm_noscope_preparetime", "15", "Time freeze noscopes");
	RoundLimitsc = CreateConVar("sm_noscope_roundsnext", "3", "Runden nach Krieg oder Mapstart bis Krieg gestartet werden kann");
	gc_bTagEnabled = CreateConVar("sm_noscope_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster", FCVAR_NOTIFY, true, 0.0, true, 1.0);



	
	AutoExecConfig(true, "MyJailbreak_NoScope");
	
	IsNoScope = false;
	StartNoScope = false;
	votecount = 0;
	NoScopeRound = 0;
	
	HookEvent("round_start", RoundStart);
	HookEvent("player_say", PlayerSay);
	HookEvent("round_end", RoundEnd);
	
	
	m_flNextSecondaryAttack = FindSendPropOffs("CBaseCombatWeapon", "m_flNextSecondaryAttack");
}


public OnMapStart()
{
	//new String:voted[1500];

	votecount = 0;
	NoScopeRound = 0;
	IsNoScope = false;
	StartNoScope = false;
	RoundLimits = 0;
	
	preparetime = GetConVarInt(preparetimec);
	roundtime = GetConVarInt(roundtimec);
	roundtimenormal = GetConVarInt(roundtimenormalc);
	
}

public OnConfigsExecuted()
{
	roundtime = GetConVarInt(roundtimec);
	roundtimenormal = GetConVarInt(roundtimenormalc);
	preparetime = GetConVarInt(preparetimec);
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
	
	if (IsNoScope)
	{
		for(new client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client)) SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
		}
		
		if (LimitTimer != INVALID_HANDLE) KillTimer(LimitTimer);
		if (NoScopeTimer != INVALID_HANDLE) KillTimer(NoScopeTimer);
		if (WeaponTimer != INVALID_HANDLE) KillTimer(WeaponTimer);
		
		roundtime = GetConVarInt(roundtimec);
		roundtimenormal = GetConVarInt(roundtimenormalc);
		
		if (winner == 2) PrintCenterTextAll("%t", "noscope_twin");
		if (winner == 3) PrintCenterTextAll("%t", "noscope_ctwin");
		IsNoScope = false;
		StartNoScope = false;
		NoScopeRound = 0;
		Format(voted, sizeof(voted), "");
		SetCvar("sm_hosties_lr", 1);
		SetCvar("sm_war_enable", 1);
		SetCvar("dice_enable", 1);
		SetCvar("sm_zombie_enable", 1);
		SetCvar("sm_hide_enable", 1);
		SetCvar("sm_duckhunt_enable", 1);
		SetCvar("sm_ffa_enable", 1);
		SetCvar("sm_beacon_enabled", 0);
		SetCvar("sv_infinite_ammo", 0);
		SetCvar("sm_warden_enable", 1);
		SetCvar("mp_roundtime", roundtimenormal);
		SetCvar("mp_roundtime_hostage", roundtimenormal);
		SetCvar("mp_roundtime_defuse", roundtimenormal);
		PrintToChatAll("%t %t", "noscope_tag" , "noscope_end");
		
	}
	if (StartNoScope)
	{
	SetCvar("mp_roundtime", roundtime);
	SetCvar("mp_roundtime_hostage", roundtime);
	SetCvar("mp_roundtime_defuse", roundtime);
	}
	
	for(new i = 1; i <= MaxClients; i++)
	if(IsClientInGame(i)) SDKUnhook(i, SDKHook_PreThink, OnPreThink);
}

public Action SetNoScope(int client,int args)
{
	if(GetConVarInt(g_wenabled) == 1)	
	{
	if (warden_iswarden(client)) 
	{
	StartNoScope = true;
	RoundLimits = GetConVarInt(RoundLimitsc);
	votecount = 0;
	PrintToChatAll("%t %t", "noscope_tag" , "noscope_next");
	}
	}
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	SDKHook(client, SDKHook_PreThink, OnPreThink);
}

public Action:OnWeaponCanUse(client, weapon)
{
	if(IsNoScope == true)
		{

		decl String:sWeapon[32];
		GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));

		if(StrEqual(sWeapon, "weapon_ssg08") || StrEqual(sWeapon, "weapon_knife"))
		{
		
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
			return Plugin_Continue;
			}
		}
		return Plugin_Handled;
		}
		return Plugin_Continue;
		}

public Action:OnPreThink(client)
{
	new iWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	MakeNoScope(iWeapon);
	return Plugin_Continue;
}

stock MakeNoScope(weapon)
{
	if(IsValidEdict(weapon))
	{
		decl String:classname[MAX_NAME_LENGTH];

		if (GetEdictClassname(weapon, classname, sizeof(classname))
		|| StrEqual(classname[7], "ssg08")  || StrEqual(classname[7], "aug")
		|| StrEqual(classname[7], "sg550")  || StrEqual(classname[7], "sg552")
		|| StrEqual(classname[7], "sg556")  || StrEqual(classname[7], "awp")
		|| StrEqual(classname[7], "scar20") || StrEqual(classname[7], "g3sg1"))
		{
			SetEntDataFloat(weapon, m_flNextSecondaryAttack, GetGameTime() + 1.0);
		}
	}
}

public RoundStart(Handle:event, String:name[], bool:dontBroadcast)
{
	if (StartNoScope)
	{
		decl String:info1[255], String:info2[255], String:info3[255], String:info4[255], String:info5[255], String:info6[255], String:info7[255], String:info8[255];
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_war_enable", 0);
		SetCvar("sm_zombie_enable", 0);
		SetCvar("sm_ffa_enable", 0);
		SetCvar("sm_beacon_enabled", 1);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_hide_enable", 0);
		SetCvar("dice_enable", 0);
		SetCvar("sv_infinite_ammo", 1);
		IsNoScope = true;
		NoScopeRound++;
		StartNoScope = false;
		
		SJD_OpenDoors();
		
		NoScopeMenu = CreatePanel();
		Format(info1, sizeof(info1), "%T", "noscope_info_Title", LANG_SERVER);
		SetPanelTitle(NoScopeMenu, info1);
		DrawPanelText(NoScopeMenu, "                                   ");
		Format(info2, sizeof(info2), "%T", "noscope_info_Line1", LANG_SERVER);
		DrawPanelText(NoScopeMenu, info2);
		DrawPanelText(NoScopeMenu, "-----------------------------------");
		Format(info3, sizeof(info3), "%T", "noscope_info_Line2", LANG_SERVER);
		DrawPanelText(NoScopeMenu, info3);
		Format(info4, sizeof(info4), "%T", "noscope_info_Line3", LANG_SERVER);
		DrawPanelText(NoScopeMenu, info4);
		Format(info5, sizeof(info5), "%T", "noscope_info_Line4", LANG_SERVER);
		DrawPanelText(NoScopeMenu, info5);
		Format(info6, sizeof(info6), "%T", "noscope_info_Line5", LANG_SERVER);
		DrawPanelText(NoScopeMenu, info6);
		Format(info7, sizeof(info7), "%T", "noscope_info_Line6", LANG_SERVER);
		DrawPanelText(NoScopeMenu, info7);
		Format(info8, sizeof(info8), "%T", "noscope_info_Line7", LANG_SERVER);
		DrawPanelText(NoScopeMenu, info8);
		DrawPanelText(NoScopeMenu, "-----------------------------------");
		
		if (NoScopeRound > 0)
			{
				for(new client=1; client <= MaxClients; client++)
				{
					
					if (IsClientInGame(client))
					{
						if (GetClientTeam(client) == 3)
						{
						GivePlayerItem(client, "weapon_ssg08");
						SetEntityGravity(client, 0.3);
						}
						if (GetClientTeam(client) == 2)
						{
						GivePlayerItem(client, "weapon_ssg08");
						SetEntityGravity(client, 0.3);
						}
					}
					if (IsClientInGame(client))
					{
					SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					SendPanelToClient(NoScopeMenu, client, Pass, 15);
					SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
					}
				}
				preparetime--;
				NoScopeTimer = CreateTimer(1.0, NoScope, _, TIMER_REPEAT);
			}
		for(new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i)) SDKHook(i, SDKHook_PreThink, OnPreThink);
	}
}



public Pass(Handle:menu, MenuAction:action, param1, param2)
{
}


public Action:NoScope(Handle:timer)
{
	if (preparetime > 1)
	{
		preparetime--;
		for (new client=1; client <= MaxClients; client++)
		if (IsClientInGame(client) && IsPlayerAlive(client))
			{
		
						PrintCenterText(client,"%t", "noscope_timetounfreeze", preparetime);
			}
		return Plugin_Continue;
	}
	
	preparetime = GetConVarInt(preparetimec);
	
	if (NoScopeRound > 0)
	{
		for (new client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
			if (GetClientTeam(client) == 2)
				{
				SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
				SetEntityGravity(client, 0.3);
				}
			if (GetClientTeam(client) == 3)
				{
				SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
				SetEntityGravity(client, 0.3);
				}
			}
		}
	}
	PrintCenterTextAll("%t", "noscope_start");
	PrintToChatAll("%t %t", "noscope_tag" , "noscope_start");
	
	NoScopeTimer = INVALID_HANDLE;
	
	return Plugin_Stop;
}


public PlayerSay(Handle:event, String:name[], bool:dontBroadcast)
{
	decl String:text[256];
	decl String:steamid[64];
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	GetClientAuthString(client, steamid, sizeof(steamid));
	GetEventString(event, "text", text, sizeof(text));
	
	if (StrEqual(text, "!scout") || StrEqual(text, "!noscope"))
	{
	if(GetConVarInt(g_wenabled) == 1)
	{	
		if (GetTeamClientCount(3) > 0)
		{
			if (RoundLimits == 0)
			{
				if (!IsNoScope && !StartNoScope)
				{
					if (StrContains(voted, steamid, true) == -1)
					{
						new playercount = (GetClientCount(true) / 2);
						
						votecount++;
						
						new Missing = playercount - votecount + 1;
						
						Format(voted, sizeof(voted), "%s,%s", voted, steamid);
						
						if (votecount > playercount)
						{
							StartNoScope = true;
							
							RoundLimits = GetConVarInt(RoundLimitsc);
							votecount = 0;
							
							PrintToChatAll("%t %t", "noscope_tag" , "noscope_next");
						}
						else PrintToChatAll("%t %t", "noscope_tag" , "noscope_need", Missing);
						
					}
					else PrintToChat(client, "%t %t", "noscope_tag" , "noscope_voted");
				}
				else PrintToChat(client, "%t %t", "noscope_tag" , "noscope_progress");
			}
			else PrintToChat(client, "%t %t", "noscope_tag" , "noscope_wait", RoundLimits);
		}
		else PrintToChat(client, "%t %t", "noscope_tag" , "noscope_minct");
	}
	else PrintToChat(client, "%t %t", "noscope_tag" , "noscope_disabled");
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
	IsNoScope = false;
	StartNoScope = false;
	votecount = 0;
	NoScopeRound = 0;
	
	voted[0] = '\0';
}