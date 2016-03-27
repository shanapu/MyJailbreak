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

bool IsZombie = false;
bool StartZombie = false;

ConVar gc_bPlugin;
ConVar gc_bTag;
ConVar gc_iRoundTime;
ConVar gc_iRoundLimits;
ConVar gc_iFreezeTime;
ConVar g_iSetRoundTime;

int g_iOldRoundTime;
int g_iFreezeTime;
int g_iRoundLimits;

int VoteCount = 0;
int ZombieRound = 0;


Handle FreezeTimer;
Handle ZombieMenu;
Handle UseCvar;



char voted[1500];


public Plugin myinfo = {
	name = "MyJailbreak - Zombie",
	author = "shanapu & Floody.de, fransico",
	description = "Jailbreak Zombie script",
	version = PLUGIN_VERSION,
	url = ""
};



public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreakWarden.phrases");
	LoadTranslations("MyJailbreakZombie.phrases");
	
	RegConsoleCmd("sm_setzombie", SetZombie);
	RegConsoleCmd("sm_zombie", VoteZombie);
	RegConsoleCmd("sm_undead", VoteZombie);
	
	AutoExecConfig_SetFile("MyJailbreak_zombie");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_zombie_version", "PLUGIN_VERSION", "The version of the SourceMod plugin MyJailBreak - War", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_zombie_enable", "1", "0 - disabled, 1 - enable war");
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_zombie_roundtime", "5", "Round time for a single war round");
	g_iSetRoundTime = FindConVar("mp_roundtime");
	gc_iFreezeTime = AutoExecConfig_CreateConVar("sm_zombie_g_iFreezeTime", "35", "Time freeze zombies");
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	gc_iRoundLimits = AutoExecConfig_CreateConVar("sm_zombie_roundsnext", "3", "Rounds until event can be started again.");
	g_iRoundLimits = gc_iRoundLimits.IntValue;
	gc_bTag = AutoExecConfig_CreateConVar("sm_zombie_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch you sv_tags", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	AutoExecConfig_CacheConvars();
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	AutoExecConfig(true, "MyJailbreak_Zombie");
	
	IsZombie = false;
	StartZombie = false;
	VoteCount = 0;
	ZombieRound = 0;
	
	HookEvent("round_start", RoundStart);
	HookEvent("round_end", RoundEnd);
}


public void OnMapStart()
{
	VoteCount = 0;
	ZombieRound = 0;
	IsZombie = false;
	StartZombie = false;
	g_iRoundLimits = 0;
	
	PrecacheModel("models/player/custom_player/zombie/revenant/revenant_v2.mdl");
	
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	
}

public void OnConfigsExecuted()
{
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_iRoundLimits = 0;
	
	if (gc_bTag.BoolValue)
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

public void RoundEnd(Handle:event, char[] name, bool:dontBroadcast)
{
	int winner = GetEventInt(event, "winner");
	
	if (IsZombie)
	{
		for(int client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client)) SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
		}
		
		if (FreezeTimer != null) KillTimer(FreezeTimer);
		
		
		if (winner == 2) PrintCenterTextAll("%t", "zombie_twin");
		if (winner == 3) PrintCenterTextAll("%t", "zombie_ctwin");
		IsZombie = false;
		StartZombie = false;
		ZombieRound = 0;
		Format(voted, sizeof(voted), "");
		SetCvar("sm_hosties_lr", 1);
		SetCvar("sm_war_enable", 1);
		SetCvar("sm_weapons_t", 0);
		SetCvar("sm_weapons_ct", 1);
		SetCvar("sm_noscope_enable", 1);
		SetCvar("sm_hide_enable", 1);
		SetCvar("sm_duckhunt_enable", 1);
		SetCvar("sm_catch_enable", 1);
		SetCvar("sm_dice_enable", 1);
		SetCvar("sm_beacon_enabled", 0);
		SetCvar("sv_infinite_ammo", 0);
		SetCvar("sm_ffa_enable", 1);
		SetCvar("sm_warden_enable", 1);
		g_iSetRoundTime.IntValue = g_iOldRoundTime;
		CPrintToChatAll("%t %t", "zombie_tag" , "zombie_end");
	}
	if (StartZombie)
	{
	g_iOldRoundTime = g_iSetRoundTime.IntValue;
	g_iSetRoundTime.IntValue = gc_iRoundTime.IntValue;
	}
}

public Action SetZombie(int client,int args)
{
	if (gc_bPlugin.BoolValue)	
	{
	if (warden_iswarden(client) || CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
	{
	if (g_iRoundLimits == 0)
	{
	StartZombie = true;
	g_iRoundLimits = gc_iRoundLimits.IntValue;
	VoteCount = 0;
	SetCvar("sm_hide_enable", 0);
	SetCvar("sm_ffa_enable", 0);
	SetCvar("sm_war_enable", 0);
	SetCvar("sm_duckhunt_enable", 0);
	SetCvar("sm_catch_enable", 0);
	SetCvar("sm_noscope_enable", 0);
	CPrintToChatAll("%t %t", "zombie_tag" , "zombie_next");
		
	}else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_wait", g_iRoundLimits);
	}else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

public Action:OnWeaponCanUse(client, weapon)
{
	char sWeapon[32];
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


public void RoundStart(Handle:event, char[] name, bool:dontBroadcast)
{
	if (StartZombie)
	{
		char info1[255], info2[255], info3[255], info4[255], info5[255], info6[255], info7[255], info8[255];
		
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_beacon_enabled", 1);
		SetCvar("sm_weapons_t", 1);
		SetCvar("sm_weapons_ct", 0);
		SetCvar("sv_infinite_ammo", 1);
		SetCvar("sm_dice_enable", 0);
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
				for(int client=1; client <= MaxClients; client++)
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
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					SendPanelToClient(ZombieMenu, client, Pass, 15);
					SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
					}
				}
				g_iFreezeTime--;
				FreezeTimer = CreateTimer(1.0, Zombie, _, TIMER_REPEAT);
				}
	}else
	{
		if (g_iRoundLimits > 0) g_iRoundLimits--;
	}
}

public Pass(Handle:menu, MenuAction:action, param1, param2)
{
}


public Action:Zombie(Handle:timer)
{
	if (g_iFreezeTime > 1)
	{
		g_iFreezeTime--;
		for (int client=1; client <= MaxClients; client++)
		if (IsClientInGame(client) && IsPlayerAlive(client))
			{
		if (GetClientTeam(client) == 3)
	{
	PrintCenterText(client,"%t", "zombie_timetounfreeze", g_iFreezeTime);
	}
		if (GetClientTeam(client) == 2)
	{
	PrintCenterText(client,"%t", "zombie_timetozombie", g_iFreezeTime);
	}
		}
		return Plugin_Continue;
	}
	
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	
	if (ZombieRound > 0)
	{
		for (int client=1; client <= MaxClients; client++)
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
	
	FreezeTimer = null;
	
	return Plugin_Stop;
}


public Action VoteZombie(int client,int args)
{
	char steamid[64];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	
	if (gc_bPlugin.BoolValue)
	{	
		if (GetTeamClientCount(3) > 0)
		{
			if (g_iRoundLimits == 0)
			{
				if (!IsZombie && !StartZombie)
				{
					if (StrContains(voted, steamid, true) == -1)
					{
	int playercount = (GetClientCount(true) / 2);
	
	VoteCount++;
	
	int Missing = playercount - VoteCount + 1;
	
	Format(voted, sizeof(voted), "%s,%s", voted, steamid);
	
	if (VoteCount > playercount)
	{
		StartZombie = true;
		
		SetCvar("sm_hide_enable", 0);
		SetCvar("sm_ffa_enable", 0);
		SetCvar("sm_war_enable", 0);
		SetCvar("sm_duckhunt_enable", 0);
		SetCvar("sm_catch_enable", 0);
		SetCvar("sm_noscope_enable", 0);
		
		g_iRoundLimits = gc_iRoundLimits.IntValue;
		VoteCount = 0;
		
		CPrintToChatAll("%t %t", "zombie_tag" , "zombie_next");
	}
	else CPrintToChatAll("%t %t", "zombie_tag" , "zombie_need", Missing);
	
					}
					else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_voted");
				}
				else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_progress");
			}
			else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_wait", g_iRoundLimits);
		}
		else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_minct");
	}
	else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_disabled");
}



public SetCvar(char cvarName[64], value)
{
	UseCvar = FindConVar(cvarName);
	if(UseCvar == null) return;
	
	int flags = GetConVarFlags(UseCvar);
	flags &= ~FCVAR_NOTIFY;
	SetConVarFlags(UseCvar, flags);

	SetConVarInt(UseCvar, value);

	flags |= FCVAR_NOTIFY;
	SetConVarFlags(UseCvar, flags);
}

public SetCvarF(char cvarName[64], Float:value)
{
	UseCvar = FindConVar(cvarName);
	if(UseCvar == null) return;

	int flags = GetConVarFlags(UseCvar);
	flags &= ~FCVAR_NOTIFY;
	SetConVarFlags(UseCvar, flags);

	SetConVarFloat(UseCvar, value);

	flags |= FCVAR_NOTIFY;
	SetConVarFlags(UseCvar, flags);
}

public OnMapEnd()
{
	IsZombie = false;
	StartZombie = false;
	VoteCount = 0;
	ZombieRound = 0;
	
	voted[0] = '\0';
}