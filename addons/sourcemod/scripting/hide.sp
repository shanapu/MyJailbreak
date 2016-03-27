//includes
#include <cstrike>
#include <sourcemod>
#include <colors>
#include <sdktools>
#include <wardn>
#include <smartjaildoors>
#include <autoexecconfig>

//Compiler Options
#pragma semicolon 1

//Defines
#define PLUGIN_VERSION   "0.x"

//Booleans
bool IsHide = false; 
bool StartHide = false; 

//ConVars
ConVar gc_bPlugin;
ConVar gc_bTag;
ConVar gc_iRoundTime;
ConVar gc_iRoundLimits;
ConVar gc_iFreezeTime;
ConVar g_iSetRoundTime;

//Integers
int g_iOldRoundTime;
int g_iFreezeTime;
int g_iRoundLimits;
int VoteCount = 0;
int HideRound = 0;
int FogIndex = -1;

//Handles
Handle FreezeTimer;
Handle HideMenu;
Handle UseCvar;

//Characters
char voted[1500];

//Float
float mapFogStart = 0.0;
float mapFogEnd = 150.0;
float mapFogDensity = 0.99;


public Plugin myinfo = {
	name = "MyJailbreak - HideInTheDark",
	author = "shanapu & Floody.de, fransico",
	description = "Jailbreak Hide script",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreakWarden.phrases");
	LoadTranslations("MyJailbreakHide.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_sethide", SetHide);
	RegConsoleCmd("sm_hide", VoteHide);
	RegConsoleCmd("sm_hideindark", VoteHide);
	
	//ConVars with AutoExecConfig	
	AutoExecConfig_SetFile("MyJailbreak_hide");
	AutoExecConfig_SetCreateFile(true);
	AutoExecConfig_CreateConVar("sm_hide_version", "PLUGIN_VERSION", "The version of the SourceMod plugin MyJailBreak - War", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_hide_enable", "1", "0 - disabled, 1 - enable war");
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_hide_roundtime", "5", "Round time for a single war round");
	g_iSetRoundTime = FindConVar("mp_roundtime");
	gc_iFreezeTime = AutoExecConfig_CreateConVar("sm_hide_g_iFreezeTime", "30", "Time freeze T");
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	gc_iRoundLimits = AutoExecConfig_CreateConVar("sm_hide_roundsnext", "3", "Rounds until event can be started again.");
	g_iRoundLimits = gc_iRoundLimits.IntValue;
	gc_bTag = AutoExecConfig_CreateConVar("sm_hide_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	AutoExecConfig_CacheConvars();
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	AutoExecConfig(true, "MyJailbreak_Hide");
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("round_end", RoundEnd);
	
	IsHide = false;
	StartHide = false;
	VoteCount = 0;
	HideRound = 0;
}


public void OnMapStart()
{


	VoteCount = 0;
	HideRound = 0;
	IsHide = false;
	StartHide = false;
	g_iRoundLimits = 0;
	g_iFreezeTime = gc_iFreezeTime.IntValue;

	int ent; 
	ent = FindEntityByClassname(-1, "env_fog_controller");
	if (ent != -1) 
	{
		FogIndex = ent;
	}
	else
	{
		FogIndex = CreateEntityByName("env_fog_controller");
		DispatchSpawn(FogIndex);
	}
	DoFog();
	AcceptEntityInput(FogIndex, "TurnOff");
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
	
	if (IsHide)
	{
		for(int client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client)) 
			{
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
			}
		}
		
		if (FreezeTimer != null) KillTimer(FreezeTimer);

		
		if (winner == 2) PrintCenterTextAll("%t", "hide_twin");
		if (winner == 3) PrintCenterTextAll("%t", "hide_ctwin");
		IsHide = false;
		StartHide = false;
		HideRound = 0;
		Format(voted, sizeof(voted), "");
		SetCvar("sm_hosties_lr", 1);
		SetCvar("sm_war_enable", 1);
		SetCvar("sm_zombie_enable", 1);
		SetCvar("sm_ffa_enable", 1);
		SetCvar("sm_noscope_enable", 1);
		SetCvar("sm_duckhunt_enable", 1);
		SetCvar("sm_weapons_t", 0);
		SetCvar("sm_weapons_ct", 1);
		SetCvar("sm_catch_enable", 1);
		SetCvar("sm_warden_enable", 1);
		SetCvar("sm_dice_enable", 1);
		g_iSetRoundTime.IntValue = g_iOldRoundTime;
		CPrintToChatAll("%t %t", "hide_tag" , "hide_end");
		DoFog();
		AcceptEntityInput(FogIndex, "TurnOff");
		
	}
	if (StartHide)
	{
	g_iOldRoundTime = g_iSetRoundTime.IntValue;
	g_iSetRoundTime.IntValue = gc_iRoundTime.IntValue;
	}
}

public Action SetHide(int client,int args)
{
	if (gc_bPlugin.BoolValue)	
	{
	if (warden_iswarden(client) || CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
	{
	if (g_iRoundLimits == 0)
	{
	StartHide = true;
	g_iRoundLimits = gc_iRoundLimits.IntValue;
	
	SetCvar("sm_war_enable", 0);
	SetCvar("sm_ffa_enable", 0);
	SetCvar("sm_zombie_enable", 0);
	SetCvar("sm_duckhunt_enable", 0);
	SetCvar("sm_catch_enable", 0);
	SetCvar("sm_noscope_enable", 0);
		
	VoteCount = 0;
	CPrintToChatAll("%t %t", "hide_tag" , "hide_next");
	}else CPrintToChat(client, "%t %t", "hide_tag" , "hide_wait", g_iRoundLimits);
	}else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
}

public void RoundStart(Handle:event, char[] name, bool:dontBroadcast)
{
	if (StartHide)
	{
		char info1[255], info2[255], info3[255], info4[255], info5[255], info6[255], info7[255], info8[255];
		
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_dice_enable", 0);
		SetCvar("sm_weapons_t", 0);
		SetCvar("sm_weapons_ct", 1);
		IsHide = true;
		HideRound++;
		StartHide = false;
		SJD_OpenDoors();

		HideMenu = CreatePanel();
		Format(info1, sizeof(info1), "%T", "hide_info_Title", LANG_SERVER);
		SetPanelTitle(HideMenu, info1);
		DrawPanelText(HideMenu, "                                   ");
		Format(info2, sizeof(info2), "%T", "hide_info_Line1", LANG_SERVER);
		DrawPanelText(HideMenu, info2);
		DrawPanelText(HideMenu, "-----------------------------------");
		Format(info3, sizeof(info3), "%T", "hide_info_Line2", LANG_SERVER);
		DrawPanelText(HideMenu, info3);
		Format(info4, sizeof(info4), "%T", "hide_info_Line3", LANG_SERVER);
		DrawPanelText(HideMenu, info4);
		Format(info5, sizeof(info5), "%T", "hide_info_Line4", LANG_SERVER);
		DrawPanelText(HideMenu, info5);
		Format(info6, sizeof(info6), "%T", "hide_info_Line5", LANG_SERVER);
		DrawPanelText(HideMenu, info6);
		Format(info7, sizeof(info7), "%T", "hide_info_Line6", LANG_SERVER);
		DrawPanelText(HideMenu, info7);
		Format(info8, sizeof(info8), "%T", "hide_info_Line7", LANG_SERVER);
		DrawPanelText(HideMenu, info8);
		DrawPanelText(HideMenu, "-----------------------------------");
		
		if (HideRound > 0)
			{
				for(int client=1; client <= MaxClients; client++)
				{
					
					if (IsClientInGame(client))
					{
	if (GetClientTeam(client) == 3)
	{
	SetEntityMoveType(client, MOVETYPE_NONE);
	GivePlayerItem(client, "weapon_tagrenade");
	}
					}
					if (IsClientInGame(client))
					{
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					SendPanelToClient(HideMenu, client, Pass, 15);
					SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
					}
				}
				g_iFreezeTime--;
				FreezeTimer = CreateTimer(1.0, Freezed, _, TIMER_REPEAT);
			}
		{AcceptEntityInput(FogIndex, "TurnOn");}
	}else
	{
		if (g_iRoundLimits > 0) g_iRoundLimits--;
	}
}

public Pass(Handle:menu, MenuAction:action, param1, param2)
{
}


public Action:Freezed(Handle:timer)
{
	if (g_iFreezeTime > 1)
	{
		g_iFreezeTime--;
		for (int client=1; client <= MaxClients; client++)
		if (IsClientInGame(client) && IsPlayerAlive(client))
			{
		if (GetClientTeam(client) == 3)
	{
	PrintCenterText(client,"%t", "hide_timetounfreeze", g_iFreezeTime);
	}
		if (GetClientTeam(client) == 2)
	{
	PrintCenterText(client,"%t", "hide_timetohide", g_iFreezeTime);
	}
		}
		return Plugin_Continue;
	}
	
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	
	if (HideRound > 0)
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
				if (GetClientTeam(client) == 2)
				{
				SetEntityMoveType(client, MOVETYPE_NONE);
				SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.4);
				}
			}
		}
	}
	PrintCenterTextAll("%t", "hide_start");
	CPrintToChatAll("%t %t", "hide_tag" , "hide_start");


	
	FreezeTimer = null;
	
	return Plugin_Stop;
}

DoFog()
{
	if(FogIndex != -1)
	{
		DispatchKeyValue(FogIndex, "fogblend", "0");
		DispatchKeyValue(FogIndex, "fogcolor", "0 0 0");
		DispatchKeyValue(FogIndex, "fogcolor2", "0 0 0");
		DispatchKeyValueFloat(FogIndex, "fogstart", mapFogStart);
		DispatchKeyValueFloat(FogIndex, "fogend", mapFogEnd);
		DispatchKeyValueFloat(FogIndex, "fogmaxdensity", mapFogDensity);
	}
}

public Action VoteHide(int client,int args)
{
	char steamid[64];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	
	if (gc_bPlugin.BoolValue)
	{	
		if (GetTeamClientCount(3) > 0)
		{
			if (g_iRoundLimits == 0)
			{
				if (!IsHide && !StartHide)
				{
					if (StrContains(voted, steamid, true) == -1)
					{
	int playercount = (GetClientCount(true) / 2);
	
	VoteCount++;
	
	int Missing = playercount - VoteCount + 1;
	
	Format(voted, sizeof(voted), "%s,%s", voted, steamid);
	
	if (VoteCount > playercount)
	{
		StartHide = true;
		
		SetCvar("sm_war_enable", 0);
		SetCvar("sm_ffa_enable", 0);
		SetCvar("sm_zombie_enable", 0);
		SetCvar("sm_duckhunt_enable", 0);
		SetCvar("sm_catch_enable", 0);
		SetCvar("sm_noscope_enable", 0);
		
		g_iRoundLimits = gc_iRoundLimits.IntValue;
		VoteCount = 0;
		
		CPrintToChatAll("%t %t", "hide_tag" , "hide_next");
	}
	else CPrintToChatAll("%t %t", "hide_tag" , "hide_need", Missing);
	
					}
					else CPrintToChat(client, "%t %t", "hide_tag" , "hide_voted");
				}
				else CPrintToChat(client, "%t %t", "hide_tag" , "hide_progress");
			}
			else CPrintToChat(client, "%t %t", "hide_tag" , "hide_wait", g_iRoundLimits);
		}
		else CPrintToChat(client, "%t %t", "hide_tag" , "hide_minct");
	}
	else CPrintToChat(client, "%t %t", "hide_tag" , "hide_disabled");
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

public void OnMapEnd()
{
	IsHide = false;
	StartHide = false;
	VoteCount = 0;
	HideRound = 0;
	
	voted[0] = '\0';
}