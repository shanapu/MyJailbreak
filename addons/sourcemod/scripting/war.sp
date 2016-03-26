//Includes
#include <cstrike>
#include <colors>
#include <sourcemod>
#include <sdktools>
#include <smartjaildoors>
#include <wardn>
#include <autoexecconfig>

//Compiler Options
#pragma semicolon 1

//Defines
#define PLUGIN_VERSION		"0.x"

//Booleans
bool IsWar = false;
bool StartWar = false;

//ConVars
ConVar gc_bPlugin;
ConVar gc_bTag;
ConVar gc_bSpawnCell;
ConVar gc_iRoundTime;
ConVar gc_iRoundLimits;
ConVar gc_iFreezeTime;
ConVar gc_iTruceTime;
ConVar g_iSetRoundTime;

//Integers
int g_iOldRoundTime;
int g_iRoundLimits;
int g_iFreezeTime;
int g_iTruceTime;
int VoteCount = 0;
int WarRound = 0;

//Handles
Handle FreezeTimer;
Handle TruceTimer;
Handle WarMenu;
Handle UseCvar;

//Characters
char voted[1500];

//Floats
float Pos[3];


public Plugin myinfo = {
	name = "MyJailbreak - War",
	author = "shanapu & Floody.de",
	description = "Jailbreak War script",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	//Translation
	LoadTranslations("MyJailbreakWarden.phrases");
	LoadTranslations("MyJailbreakWar.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_setwar", SetWar);
	RegConsoleCmd("sm_war", VoteWar);
	RegConsoleCmd("sm_krieg", VoteWar);
	
	//ConVars with AutoExecConfig
	AutoExecConfig_SetFile("MyJailbreak_war");
	AutoExecConfig_SetCreateFile(true);
	AutoExecConfig_CreateConVar("sm_war_version", "PLUGIN_VERSION", "The version of the SourceMod plugin MyJailBreak - War", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_war_enable", "1", "0 - disabled, 1 - enable war", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bSpawnCell = AutoExecConfig_CreateConVar("sm_war_spawn", "1", "0 - teleport to ct and freeze, 1 - stay in cell open cell doors with aw/weapon menu - need sjd", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_iFreezeTime = AutoExecConfig_CreateConVar("sm_war_g_iFreezeTime", "30", "Time freeze T", FCVAR_NOTIFY, true, 0.0, true, 999.0);
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_war_nodamage", "30", "Time after g_iFreezeTime; damage disbaled", FCVAR_NOTIFY, true, 0.0, true, 999.0);
	g_iTruceTime = gc_iTruceTime.IntValue;
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_war_roundtime", "5", "Round time for a single war round", FCVAR_NOTIFY, true, 0.0, true, 999.0);
	g_iSetRoundTime = FindConVar("mp_roundtime");
	gc_iRoundLimits = AutoExecConfig_CreateConVar("sm_war_roundsnext", "3", "Rounds until event can be started again.", FCVAR_NOTIFY, true, 0.0, true, 255.0);
	g_iRoundLimits = gc_iRoundLimits.IntValue;
	gc_bTag = AutoExecConfig_CreateConVar("sm_war_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	AutoExecConfig_CacheConvars();
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	AutoExecConfig(true, "MyJailbreak_War");
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("round_end", RoundEnd);
	
	VoteCount = 0;
	WarRound = 0;
	IsWar = false;
	StartWar = false;
}

public void OnMapStart()
{
	VoteCount = 0;
	WarRound = 0;
	IsWar = false;
	StartWar = false;
	g_iRoundLimits = 0;
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_iTruceTime = gc_iTruceTime.IntValue;
}

public void OnConfigsExecuted()
{
	g_iFreezeTime = gc_iFreezeTime.IntValue;
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
	
	if (IsWar)
	{
		for(int client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client)) SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
		}
		
		if (FreezeTimer != null) KillTimer(FreezeTimer);
		if (TruceTimer != null) KillTimer(TruceTimer);
		if (winner == 2) PrintCenterTextAll("%t", "war_twin"); 
		if (winner == 3) PrintCenterTextAll("%t", "war_ctwin");
		
		if (WarRound == 3)
		{
			IsWar = false;
			WarRound = 0;
			Format(voted, sizeof(voted), "");
			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_warden_enable", 1);
			SetCvar("sm_hide_enable", 1);
			SetCvar("sm_weapons_t", 0);
			SetCvar("sm_weapons_ct", 1);
			SetCvar("sm_zombie_enable", 1);
			SetCvar("sm_noscope_enable", 1);
			SetCvar("dice_enable", 1);
			SetCvar("sm_beacon_enabled", 0);
			SetCvar("sm_ffa_enable", 1);
			SetCvar("sm_duckhunt_enable", 1);
			SetCvar("sm_catch_enable", 1);
			g_iSetRoundTime.IntValue = g_iOldRoundTime;
			CPrintToChatAll("%t %t", "war_tag" , "war_end");
		}
	}
	if (StartWar)
	{
		g_iOldRoundTime = g_iSetRoundTime.IntValue;
		g_iSetRoundTime.IntValue = gc_iRoundTime.IntValue;
	}
}

public Action SetWar(int client,int args)
{
	if (gc_bPlugin.BoolValue)	
	{	
		if (warden_iswarden(client) || CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
		{
			if (g_iRoundLimits == 0)
			{
				StartWar = true;
				g_iRoundLimits = gc_iRoundLimits.IntValue;
				VoteCount = 0;
				SetCvar("sm_noscope_enable", 0);
				SetCvar("sm_hide_enable", 0);
				SetCvar("sm_ffa_enable", 0);
				SetCvar("sm_zombie_enable", 0);
				SetCvar("sm_duckhunt_enable", 0);
				SetCvar("sm_catch_enable", 0);
				CPrintToChatAll("%t %t", "war_tag" , "war_next");
			}
			else CPrintToChat(client, "%t %t", "war_tag" , "war_wait", g_iRoundLimits);
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
}

public void RoundStart(Handle:event, char[] name, bool:dontBroadcast)
{
	if (StartWar || IsWar)
	{
		char info1[255], info2[255], info3[255], info4[255], info5[255], info6[255], info7[255], info8[255];
		char info9[255], info10[255], info11[255], info12[255];
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("dice_enable", 0);
		SetCvar("sm_beacon_enabled", 1);
		SetCvar("sm_weapons_t", 1);
		SetCvar("sm_weapons_ct", 1);
		WarRound++;
		IsWar = true;
		StartWar = false;
		
		if (gc_bSpawnCell.BoolValue)
		{
			SJD_OpenDoors();
			g_iFreezeTime = 0;
		}
		WarMenu = CreatePanel();
		Format(info1, sizeof(info1), "%T", "war_info_Title", LANG_SERVER);
		SetPanelTitle(WarMenu, info1);
		DrawPanelText(WarMenu, "                                   ");
		Format(info10, sizeof(info10), "%T", "RoundOne", LANG_SERVER);
		if (WarRound == 1) DrawPanelText(WarMenu, info10);
		Format(info11, sizeof(info11), "%T", "RoundTwo", LANG_SERVER);
		if (WarRound == 2) DrawPanelText(WarMenu, info11);
		Format(info12, sizeof(info12), "%T", "RoundThree", LANG_SERVER);
		if (WarRound == 3) DrawPanelText(WarMenu, info12);
		DrawPanelText(WarMenu, "                                   ");
		if (!gc_bSpawnCell.BoolValue)
		{
			Format(info2, sizeof(info2), "%T", "war_info_Tele", LANG_SERVER);
			DrawPanelText(WarMenu, info2);
			DrawPanelText(WarMenu, "-----------------------------------");
			Format(info3, sizeof(info3), "%T", "war_info_Line2", LANG_SERVER);
			DrawPanelText(WarMenu, info3);
			Format(info4, sizeof(info4), "%T", "war_info_Line3", LANG_SERVER);
			DrawPanelText(WarMenu, info4);
			Format(info5, sizeof(info5), "%T", "war_info_Line4", LANG_SERVER);
			DrawPanelText(WarMenu, info5);
			Format(info6, sizeof(info6), "%T", "war_info_Line5", LANG_SERVER);
			DrawPanelText(WarMenu, info6);
			Format(info7, sizeof(info7), "%T", "war_info_Line6", LANG_SERVER);
			DrawPanelText(WarMenu, info7);
			Format(info8, sizeof(info8), "%T", "war_info_Line7", LANG_SERVER);
			DrawPanelText(WarMenu, info8);
			DrawPanelText(WarMenu, "-----------------------------------");
		}
		else
		{
			Format(info9, sizeof(info9), "%T", "war_info_Spawn", LANG_SERVER);
			DrawPanelText(WarMenu, info9);
			DrawPanelText(WarMenu, "-----------------------------------");
			Format(info3, sizeof(info3), "%T", "war_info_Line2", LANG_SERVER);
			DrawPanelText(WarMenu, info3);
			Format(info4, sizeof(info4), "%T", "war_info_Line3", LANG_SERVER);
			DrawPanelText(WarMenu, info4);
			Format(info5, sizeof(info5), "%T", "war_info_Line4", LANG_SERVER);
			DrawPanelText(WarMenu, info5);
			Format(info6, sizeof(info6), "%T", "war_info_Line5", LANG_SERVER);
			DrawPanelText(WarMenu, info6);
			Format(info7, sizeof(info7), "%T", "war_info_Line6", LANG_SERVER);
			DrawPanelText(WarMenu, info7);
			Format(info8, sizeof(info8), "%T", "war_info_Line7", LANG_SERVER);
			DrawPanelText(WarMenu, info8);
			DrawPanelText(WarMenu, "-----------------------------------");
		}
		
		int RandomCT = 0;
		
		for(int client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client))
			{
				if (GetClientTeam(client) == 3)
				{
					RandomCT = client;
					break;
				}
			}
		}
		if (RandomCT)
		{	
			float Pos1[3];
			
			GetClientAbsOrigin(RandomCT, Pos);
			GetClientAbsOrigin(RandomCT, Pos1);
			
			Pos[2] = Pos[2] + 45;
			
			if (WarRound > 0)
			{
				for(int client=1; client <= MaxClients; client++)
				{
					if (gc_bSpawnCell.BoolValue)
					{
						if (IsClientInGame(client))
						{
							if (GetClientTeam(client) == 3)
							{
								GivePlayerItem(client, "weapon_m4a1");
								GivePlayerItem(client, "weapon_deagle");
								GivePlayerItem(client, "weapon_hegrenade");
							}
							if (GetClientTeam(client) == 2)
							{
								GivePlayerItem(client, "weapon_ak47");
								GivePlayerItem(client, "weapon_deagle");
								GivePlayerItem(client, "weapon_hegrenade");
							}
						}
					}
					else
					{
						if (IsClientInGame(client))
						{
							if (GetClientTeam(client) == 3)
							{
								TeleportEntity(client, Pos1, NULL_VECTOR, NULL_VECTOR);
							}
							if (GetClientTeam(client) == 2)
							{
								SetEntityMoveType(client, MOVETYPE_NONE);
								TeleportEntity(client, Pos, NULL_VECTOR, NULL_VECTOR);
							}
						}
					}
				}CPrintToChatAll("%t %t", "war_tag" ,"war_rounds", WarRound);
			}
			for(int client=1; client <= MaxClients; client++)
			{
				if (IsClientInGame(client))
				{
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					SendPanelToClient(WarMenu, client, Pass, 15);
					SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
				}
			}
			
			g_iFreezeTime--;
			
			if (!gc_bSpawnCell.BoolValue)
			{
				FreezeTimer = CreateTimer(1.0, Freezed, _, TIMER_REPEAT);
			}
			else
			{
				TruceTimer = CreateTimer(1.0, NoDamage, _, TIMER_REPEAT);
			}
		}
	}
	else
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
		
		PrintCenterTextAll("%t", "war_timetohide", g_iFreezeTime);
		
		return Plugin_Continue;
	}
	
	Pos[2] = Pos[2] - 45;
	
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	
	if (WarRound > 0)
	{
		for (int client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				if (GetClientTeam(client) == 2)
				{
					SetEntityMoveType(client, MOVETYPE_WALK);
					TeleportEntity(client, Pos, NULL_VECTOR, NULL_VECTOR);
					GivePlayerItem(client, "weapon_m4a1");
					GivePlayerItem(client, "weapon_deagle");
					GivePlayerItem(client, "weapon_hegrenade");
					GivePlayerItem(client, "weapon_knife");
				}
			}
		}
	}
	
	TruceTimer = CreateTimer(1.0, NoDamage, _, TIMER_REPEAT);
	
	FreezeTimer = null;
	
	return Plugin_Stop;
}

public Action:NoDamage(Handle:timer)
{
	if (g_iTruceTime > 1)
	{
		g_iTruceTime--;
		
		PrintCenterTextAll("%t", "war_damage", g_iTruceTime);
		
		return Plugin_Continue;
	}
	
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	PrintCenterTextAll("%t", "war_start");
	
	for(int client=1; client <= MaxClients; client++) 
	{
		if (IsClientInGame(client) && IsPlayerAlive(client)) SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
	}

	CPrintToChatAll("%t %t", "war_tag" , "war_start");
	
	TruceTimer = null;
	
	return Plugin_Stop;
}

public Action VoteWar(int client,int args)
{
	char steamid[64];

	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	
	if (gc_bPlugin.BoolValue)
	{	
		if (GetTeamClientCount(3) > 0)
		{
			if (g_iRoundLimits == 0)
			{
				if (!IsWar && !StartWar)
				{
					if (StrContains(voted, steamid, true) == -1)
					{
						int playercount = (GetClientCount(true) / 2);
						
						VoteCount++;
						
						int Missing = playercount - VoteCount + 1;
						
						Format(voted, sizeof(voted), "%s,%s", voted, steamid);
						
						if (VoteCount > playercount)
						{
							StartWar = true;
							
							g_iRoundLimits = gc_iRoundLimits.IntValue;
							VoteCount = 0;
							
							SetCvar("sm_hide_enable", 0);
							SetCvar("sm_ffa_enable", 0);
							SetCvar("sm_noscope_enable", 0);
							SetCvar("sm_zombie_enable", 0);
							SetCvar("sm_duckhunt_enable", 0);
							SetCvar("sm_catch_enable", 0);
							
							CPrintToChatAll("%t %t", "war_tag" , "war_next");
						}
						else CPrintToChatAll("%t %t", "war_tag" , "war_need", Missing);
						
					}
					else CPrintToChat(client, "%t %t", "war_tag" , "war_voted");
				}
				else CPrintToChat(client, "%t %t", "war_tag" , "war_progress");
			}
			else CPrintToChat(client, "%t %t", "war_tag" , "war_wait", g_iRoundLimits);
		}
		else CPrintToChat(client, "%t %t", "war_tag" , "war_minct");
	}
	else CPrintToChat(client, "%t %t", "war_tag" , "war_disabled");
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
	IsWar = false;
	StartWar = false;
	VoteCount = 0;
	WarRound = 0;
	
	voted[0] = '\0';
}