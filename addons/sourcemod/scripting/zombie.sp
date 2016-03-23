//includes
#include <cstrike>
#include <sourcemod>
#include <sdktools>
#include <colors>
#include <smartjaildoors>
#include <sdkhooks>
#include <wardn>
#include <autoexecconfig>

//Compiler Options
#pragma semicolon 1

#define PLUGIN_VERSION   "0.x"
ConVar gc_bTagEnabled;
new freezetime;
new roundtime;
new roundtimenormal;
new votecount;
new ZombieRound;
new RoundLimits;

new Handle:LimitTimer;
new Handle:ZombieTimer;
new Handle:WeaponTimer;
new Handle:ZombieMenu;
new Handle:roundtimec;
new Handle:roundtimenormalc;
new Handle:freezetimec;
new Handle:RoundLimitsc;
new Handle:g_wenabled=INVALID_HANDLE;
new Handle:cvar;

new bool:IsZombie;
new bool:StartZombie;

new String:voted[1500];


public Plugin myinfo = {
	name = "MyJailbreak - Zombie",
	author = "shanapu & Floody.de, fransico",
	description = "Jailbreak Zombie script",
	version = PLUGIN_VERSION,
	url = ""
};



public OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreakWarden.phrases");
	LoadTranslations("MyJailbreakZombie.phrases");
	
	RegConsoleCmd("sm_setzombie", SetZombie);
	
	AutoExecConfig_SetFile("MyJailbreak_zombie");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_zombie_version", "PLUGIN_VERSION", "The version of the SourceMod plugin MyJailBreak - War", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_wenabled = AutoExecConfig_CreateConVar("sm_zombie_enable", "1", "0 - disabled, 1 - enable war");
	roundtimec = AutoExecConfig_CreateConVar("sm_zombie_roundtime", "5", "Round time for a single war round");
	roundtimenormalc = AutoExecConfig_CreateConVar("sm_nozombie_roundtime", "12", "set round time after a war round zour normal mp_roudntime");
	freezetimec = AutoExecConfig_CreateConVar("sm_zombie_freezetime", "35", "Time freeze zombies");
	RoundLimitsc = AutoExecConfig_CreateConVar("sm_zombie_roundsnext", "3", "Rounds until event can be started again.");
	gc_bTagEnabled = AutoExecConfig_CreateConVar("sm_zombie_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch you sv_tags", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	AutoExecConfig_CacheConvars();
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	AutoExecConfig(true, "MyJailbreak_Zombie");
	
	IsZombie = false;
	StartZombie = false;
	votecount = 0;
	ZombieRound = 0;
	
	HookEvent("round_start", RoundStart);
	HookEvent("player_say", PlayerSay);
	HookEvent("round_end", RoundEnd);
}


public OnMapStart()
{
	//new String:voted[1500];

	votecount = 0;
	ZombieRound = 0;
	IsZombie = false;
	StartZombie = false;
	RoundLimits = 0;
	
	PrecacheModel("models/player/custom_player/zombie/revenant/revenant_v2.mdl");
	
	freezetime = GetConVarInt(freezetimec);
	roundtime = GetConVarInt(roundtimec);
	roundtimenormal = GetConVarInt(roundtimenormalc);
	
}

public OnConfigsExecuted()
{
	roundtime = GetConVarInt(roundtimec);
	roundtimenormal = GetConVarInt(roundtimenormalc);
	freezetime = GetConVarInt(freezetimec);
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
	
	if (IsZombie)
	{
		for(new client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client)) SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
		}
		
		if (LimitTimer != INVALID_HANDLE) KillTimer(LimitTimer);
		if (ZombieTimer != INVALID_HANDLE) KillTimer(ZombieTimer);
		if (WeaponTimer != INVALID_HANDLE) KillTimer(WeaponTimer);
		
		roundtime = GetConVarInt(roundtimec);
		roundtimenormal = GetConVarInt(roundtimenormalc);
		
		if (winner == 2) PrintCenterTextAll("%t", "zombie_twin");
		if (winner == 3) PrintCenterTextAll("%t", "zombie_ctwin");
		IsZombie = false;
		StartZombie = false;
		ZombieRound = 0;
		Format(voted, sizeof(voted), "");
		SetCvar("sm_hosties_lr", 1);
		SetCvar("sm_war_enable", 1);
		SetCvar("sm_noscope_enable", 1);
		SetCvar("sm_hide_enable", 1);
		SetCvar("sm_duckhunt_enable", 1);
		SetCvar("sm_catch_enable", 1);
		SetCvar("dice_enable", 1);
		SetCvar("sm_beacon_enabled", 0);
		SetCvar("sv_infinite_ammo", 0);
		SetCvar("sm_ffa_enable", 1);
		SetCvar("sm_warden_enable", 1);
		SetCvar("mp_roundtime", roundtimenormal);
		SetCvar("mp_roundtime_hostage", roundtimenormal);
		SetCvar("mp_roundtime_defuse", roundtimenormal);
		CPrintToChatAll("%t %t", "zombie_tag" , "zombie_end");
	}
	if (StartZombie)
	{
	SetCvar("mp_roundtime", roundtime);
	SetCvar("mp_roundtime_hostage", roundtime);
	SetCvar("mp_roundtime_defuse", roundtime);
	}
}

public Action SetZombie(int client,int args)
{
	if(GetConVarInt(g_wenabled) == 1)	
	{
	if (warden_iswarden(client) || CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
	{
	if (RoundLimits == 0)
	{
	StartZombie = true;
	RoundLimits = GetConVarInt(RoundLimitsc);
	votecount = 0;
	CPrintToChatAll("%t %t", "zombie_tag" , "zombie_next");
	}else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_wait", RoundLimits);
	}else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

public Action:OnWeaponCanUse(client, weapon)
{
	decl String:sWeapon[32];
	GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));

	if(!StrEqual(sWeapon, "weapon_knife"))
		{
			if(GetClientTeam(client) == 3 )
			{
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
			if(IsZombie == true)
			{
			return Plugin_Handled;
			}
			}
			}
		}
	return Plugin_Continue;
}


public RoundStart(Handle:event, String:name[], bool:dontBroadcast)
{
	if (StartZombie)
	{
		decl String:info1[255], String:info2[255], String:info3[255], String:info4[255], String:info5[255], String:info6[255], String:info7[255], String:info8[255];
		
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_beacon_enabled", 1);
		SetCvar("sv_infinite_ammo", 1);
		SetCvar("dice_enable", 0);
		IsZombie = true;
		ZombieRound++;
		StartZombie = false;
		SJD_OpenDoors();

		ZombieMenu = CreatePanel();
		Format(info1, sizeof(info1), "%T", "zombie_info_Title", LANG_SERVER);
		SetPanelTitle(ZombieMenu, info1);
		DrawPanelText(ZombieMenu, "                                   ");
		Format(info2, sizeof(info2), "%T", "zombie_info_Line1", LANG_SERVER);
		DrawPanelText(ZombieMenu, info2);
		DrawPanelText(ZombieMenu, "-----------------------------------");
		Format(info3, sizeof(info3), "%T", "zombie_info_Line2", LANG_SERVER);
		DrawPanelText(ZombieMenu, info3);
		Format(info4, sizeof(info4), "%T", "zombie_info_Line3", LANG_SERVER);
		DrawPanelText(ZombieMenu, info4);
		Format(info5, sizeof(info5), "%T", "zombie_info_Line4", LANG_SERVER);
		DrawPanelText(ZombieMenu, info5);
		Format(info6, sizeof(info6), "%T", "zombie_info_Line5", LANG_SERVER);
		DrawPanelText(ZombieMenu, info6);
		Format(info7, sizeof(info7), "%T", "zombie_info_Line6", LANG_SERVER);
		DrawPanelText(ZombieMenu, info7);
		Format(info8, sizeof(info8), "%T", "zombie_info_Line7", LANG_SERVER);
		DrawPanelText(ZombieMenu, info8);
		DrawPanelText(ZombieMenu, "-----------------------------------");
		
		if (ZombieRound > 0)
			{
				for(new client=1; client <= MaxClients; client++)
				{
					
					if (IsClientInGame(client))
					{
						if (GetClientTeam(client) == 3)
						{
						SetEntityModel(client, "models/player/custom_player/zombie/revenant/revenant_v2.mdl");
						SetEntityMoveType(client, MOVETYPE_NONE);
						SetEntityHealth(client, 10000);
						}
						if (GetClientTeam(client) == 2)
						{
						SetEntityHealth(client, 65);
						GivePlayerItem(client, "weapon_negev");
						GivePlayerItem(client, "weapon_tec9");
						GivePlayerItem(client, "weapon_hegrenade");
						}
					}
					if (IsClientInGame(client))
					{
					SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					SendPanelToClient(ZombieMenu, client, Pass, 15);
					SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
					}
				}
				freezetime--;
				ZombieTimer = CreateTimer(1.0, Zombie, _, TIMER_REPEAT);
				}
	}
}

public Pass(Handle:menu, MenuAction:action, param1, param2)
{
}


public Action:Zombie(Handle:timer)
{
	if (freezetime > 1)
	{
		freezetime--;
		for (new client=1; client <= MaxClients; client++)
		if (IsClientInGame(client) && IsPlayerAlive(client))
			{
		if (GetClientTeam(client) == 3)
						{
						PrintCenterText(client,"%t", "zombie_timetounfreeze", freezetime);
						}
		if (GetClientTeam(client) == 2)
						{
						PrintCenterText(client,"%t", "zombie_timetozombie", freezetime);
						}
		}
		return Plugin_Continue;
	}
	
	freezetime = GetConVarInt(freezetimec);
	
	if (ZombieRound > 0)
	{
		for (new client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				if (GetClientTeam(client) == 3)
				{
				SetEntityMoveType(client, MOVETYPE_WALK);
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.4);
				}
				SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
			}
		}
	}
	PrintCenterTextAll("%t", "zombie_start");
	CPrintToChatAll("%t %t", "zombie_tag" , "zombie_start");
	
	ZombieTimer = INVALID_HANDLE;
	
	return Plugin_Stop;
}


public PlayerSay(Handle:event, String:name[], bool:dontBroadcast)
{
	decl String:text[256];
	decl String:steamid[64];
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	GetClientAuthString(client, steamid, sizeof(steamid));
	GetEventString(event, "text", text, sizeof(text));
	
	if (StrEqual(text, "!undead") || StrEqual(text, "!zombie"))
	{
	if(GetConVarInt(g_wenabled) == 1)
	{	
		if (GetTeamClientCount(3) > 0)
		{
			if (RoundLimits == 0)
			{
				if (!IsZombie && !StartZombie)
				{
					if (StrContains(voted, steamid, true) == -1)
					{
						new playercount = (GetClientCount(true) / 2);
						
						votecount++;
						
						new Missing = playercount - votecount + 1;
						
						Format(voted, sizeof(voted), "%s,%s", voted, steamid);
						
						if (votecount > playercount)
						{
							StartZombie = true;
							
							SetCvar("sm_hide_enable", 0);
							SetCvar("sm_ffa_enable", 0);
							SetCvar("sm_war_enable", 0);
							SetCvar("sm_duckhunt_enable", 0);
							SetCvar("sm_catch_enable", 0);
							SetCvar("sm_noscope_enable", 0);
							
							RoundLimits = GetConVarInt(RoundLimitsc);
							votecount = 0;
							
							CPrintToChatAll("%t %t", "zombie_tag" , "zombie_next");
						}
						else CPrintToChatAll("%t %t", "zombie_tag" , "zombie_need", Missing);
						
					}
					else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_voted");
				}
				else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_progress");
			}
			else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_wait", RoundLimits);
		}
		else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_minct");
	}
	else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_disabled");
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
	IsZombie = false;
	StartZombie = false;
	votecount = 0;
	ZombieRound = 0;
	
	voted[0] = '\0';
}