//includes
#include <cstrike>
#include <sourcemod>
#include <sdktools>
#include <smartjaildoors>
#include <wardn>
#include <colors>
#include <sdkhooks>
#include <autoexecconfig>

//Compiler Options
#pragma semicolon 1

//Defines
#define PLUGIN_VERSION   "0.1"

//Booleans
bool IsNoScope = false; 
bool StartNoScope = false; 

//ConVars
ConVar gc_bPlugin;
ConVar gc_bTag;
ConVar gc_iRoundLimits;
ConVar gc_iRoundTime;
ConVar gc_iTruceTime;
ConVar g_iSetRoundTime;

//Integers
int g_iOldRoundTime;
int g_iRoundLimits;
int g_iTruceTime;
int VoteCount = 0;
int NoScopeRound = 0;
int m_flNextSecondaryAttack;

//Handles
Handle TruceTimer;
Handle NoScopeMenu;
Handle UseCvar;

//Characters
char voted[1500];


public Plugin myinfo = {
	name = "MyJailbreak - NoScope",
	author = "shanapu & Floody.de, fransico",
	description = "Jailbreak NoScope script",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreakWarden.phrases");
	LoadTranslations("MyJailbreakNoScope.phrases");
	
	RegConsoleCmd("sm_setnoscope", SetNoScope);
	RegConsoleCmd("sm_noscope", VoteNoScope);
	RegConsoleCmd("sm_scout", VoteNoScope);
	
	AutoExecConfig_SetFile("MyJailbreak_noscope");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_noscope_version", "PLUGIN_VERSION", "The version of the SourceMod plugin MyJailBreak - War", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_noscope_enable", "1", "0 - disabled, 1 - enable war");
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_noscope_roundtime", "5", "Round time for a single war round");
	g_iSetRoundTime = FindConVar("mp_roundtime");
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_noscope_g_iTruceTime", "15", "Time freeze noscopes");
	g_iTruceTime = gc_iTruceTime.IntValue;
	gc_iRoundLimits = AutoExecConfig_CreateConVar("sm_noscope_roundsnext", "3", "Rounds until event can be started again.");
	g_iRoundLimits = gc_iRoundLimits.IntValue;
	gc_bTag = AutoExecConfig_CreateConVar("sm_noscope_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	g_iSetRoundTime = FindConVar("mp_roundtime");

	AutoExecConfig_CacheConvars();
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	AutoExecConfig(true, "MyJailbreak_NoScope");
	
	IsNoScope = false;
	StartNoScope = false;
	VoteCount = 0;
	NoScopeRound = 0;
	
	HookEvent("round_start", RoundStart);
	
	HookEvent("round_end", RoundEnd);
	
	
	m_flNextSecondaryAttack = FindSendPropInfo("CBaseCombatWeapon", "m_flNextSecondaryAttack");
}


public void OnMapStart()
{


	VoteCount = 0;
	NoScopeRound = 0;
	IsNoScope = false;
	StartNoScope = false;
	g_iRoundLimits = 0;
	
	g_iTruceTime = gc_iTruceTime.IntValue;
	
}

public void OnConfigsExecuted()
{
	g_iTruceTime = gc_iTruceTime.IntValue;
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
	
	if (IsNoScope)
	{
		for(int client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client)) SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
		}
		
		if (TruceTimer != null) KillTimer(TruceTimer);

		
		
		if (winner == 2) PrintCenterTextAll("%t", "noscope_twin");
		if (winner == 3) PrintCenterTextAll("%t", "noscope_ctwin");
		IsNoScope = false;
		StartNoScope = false;
		NoScopeRound = 0;
		Format(voted, sizeof(voted), "");
		SetCvar("sm_hosties_lr", 1);
		SetCvar("sm_war_enable", 1);
		SetCvar("sm_dice_enable", 1);
		SetCvar("sm_weapons_enable", 1);
		SetCvar("sm_zombie_enable", 1);
		SetCvar("sm_hide_enable", 1);
		SetCvar("sm_duckhunt_enable", 1);
		SetCvar("sm_ffa_enable", 1);
		SetCvar("mp_teammates_are_enemies", 0);
		SetCvar("sm_beacon_enabled", 0);
		SetCvar("sm_warden_enable", 1);
		g_iSetRoundTime.IntValue = g_iOldRoundTime;
		CPrintToChatAll("%t %t", "noscope_tag" , "noscope_end");
		
	}
	if (StartNoScope)
	{
	g_iOldRoundTime = g_iSetRoundTime.IntValue;
	g_iSetRoundTime.IntValue = gc_iRoundTime.IntValue;
	}
	
	for(int i = 1; i <= MaxClients; i++)
	if(IsClientInGame(i)) SDKUnhook(i, SDKHook_PreThink, OnPreThink);
}

public Action SetNoScope(int client,int args)
{
	if (gc_bPlugin.BoolValue)	
	{
	if (warden_iswarden(client) || CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
	{
	if (g_iRoundLimits == 0)
	{
	StartNoScope = true;
	g_iRoundLimits = gc_iRoundLimits.IntValue;
	VoteCount = 0;
	SetCvar("sm_war_enable", 0);
	SetCvar("sm_zombie_enable", 0);
	SetCvar("sm_ffa_enable", 0);
	SetCvar("sm_hide_enable", 0);
	SetCvar("sm_catch_enable", 0);
	SetCvar("sm_duckhunt_enable", 0);
	CPrintToChatAll("%t %t", "noscope_tag" , "noscope_next");
	}else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_wait", g_iRoundLimits);
	}else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
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

		char sWeapon[32];
		GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));

		if(StrEqual(sWeapon, "weapon_ssg08") || StrEqual(sWeapon, "weapon_knife"))
		{
		
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
			return Plugin_Continue;
			}
		}return Plugin_Handled;
	}return Plugin_Continue;
}

public Action:OnPreThink(client)
{
	int iWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	MakeNoScope(iWeapon);
	return Plugin_Continue;
}

stock MakeNoScope(weapon)
{
	if(IsValidEdict(weapon))
	{
		char classname[MAX_NAME_LENGTH];

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

public void RoundStart(Handle:event, char[] name, bool:dontBroadcast)
{
	if (StartNoScope)
	{
		char info1[255], info2[255], info3[255], info4[255], info5[255], info6[255], info7[255], info8[255];
		SetCvar("sm_hosties_lr", 0);

		SetCvar("sm_weapons_enable", 0);
		SetCvar("sm_beacon_enabled", 1);
		SetCvar("sm_warden_enable", 0);
		SetCvar("mp_teammates_are_enemies", 1);

		SetCvar("sm_dice_enable", 0);
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
				for(int client=1; client <= MaxClients; client++)
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
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					SendPanelToClient(NoScopeMenu, client, Pass, 15);
					SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
					}
				}
				g_iTruceTime--;
				TruceTimer = CreateTimer(1.0, NoScope, _, TIMER_REPEAT);
			}
		for(int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i)) SDKHook(i, SDKHook_PreThink, OnPreThink);
	}else
	{
		if (g_iRoundLimits > 0) g_iRoundLimits--;
	}
}



public Pass(Handle:menu, MenuAction:action, param1, param2)
{
}


public Action:NoScope(Handle:timer)
{
	if (g_iTruceTime > 1)
	{
		g_iTruceTime--;
		for (int client=1; client <= MaxClients; client++)
		if (IsClientInGame(client) && IsPlayerAlive(client))
			{
		
						PrintCenterText(client,"%t", "noscope_timetounfreeze", g_iTruceTime);
			}
		return Plugin_Continue;
	}
	
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	if (NoScopeRound > 0)
	{
		for (int client=1; client <= MaxClients; client++)
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
	CPrintToChatAll("%t %t", "noscope_tag" , "noscope_start");
	
	TruceTimer = null;
	
	return Plugin_Stop;
}

public Action VoteNoScope(int client,int args)
{
	char steamid[64];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	
	if (gc_bPlugin.BoolValue)
	{	
		if (GetTeamClientCount(3) > 0)
		{
			if (g_iRoundLimits == 0)
			{
				if (!IsNoScope && !StartNoScope)
				{
					if (StrContains(voted, steamid, true) == -1)
					{
						int playercount = (GetClientCount(true) / 2);
						
						VoteCount++;
						
						int Missing = playercount - VoteCount + 1;
						
						Format(voted, sizeof(voted), "%s,%s", voted, steamid);
						
						if (VoteCount > playercount)
						{
							StartNoScope = true;
							
							g_iRoundLimits = gc_iRoundLimits.IntValue;
							VoteCount = 0;
							SetCvar("sm_war_enable", 0);
							SetCvar("sm_zombie_enable", 0);
							SetCvar("sm_ffa_enable", 0);
							SetCvar("sm_hide_enable", 0);
							SetCvar("sm_catch_enable", 0);
							SetCvar("sm_duckhunt_enable", 0);
							CPrintToChatAll("%t %t", "noscope_tag" , "noscope_next");
						}else CPrintToChatAll("%t %t", "noscope_tag" , "noscope_need", Missing);
					}
					else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_voted");
				}
				else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_progress");
			}
			else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_wait", g_iRoundLimits);
		}
		else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_minct");
	}
	else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_disabled");
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
	IsNoScope = false;
	StartNoScope = false;
	VoteCount = 0;
	NoScopeRound = 0;
	
	voted[0] = '\0';
}