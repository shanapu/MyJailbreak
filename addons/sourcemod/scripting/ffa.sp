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

#define PLUGIN_VERSION   "0.x"

ConVar gc_bPlugin;
ConVar gc_bTag;
ConVar gc_bSpawnCell;
ConVar gc_iRoundTime;
ConVar gc_iRoundLimits;
ConVar gc_iTruceTime;

ConVar g_iSetRoundTime;


int g_iOldRoundTime;
int g_iRoundLimits;
int g_iTruceTime;


int VoteCount;
int FFARound;


int FogIndex = -1;
float mapFogStart = 0.0;
float mapFogEnd = 150.0;
float mapFogDensity = 0.99;

Handle FreezeTimer;
Handle TruceTimer;
Handle FFAMenu;
Handle UseCvar;

bool IsFFA = false;
bool StartFFA = false;

char voted[1500];


float Pos[3];


public Plugin myinfo = {
	name = "MyJailbreak - War FFA",
	author = "shanapu & Floody.de",
	description = "Jailbreak War FFA script",
	version = PLUGIN_VERSION,
	url = ""
};



public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreakWarden.phrases");
	LoadTranslations("MyJailbreakFfa.phrases");
	
	RegConsoleCmd("sm_setffa", Setffa);
	RegConsoleCmd("sm_ffa", VoteFFA);
	RegConsoleCmd("sm_warffa", VoteFFA);
	
	AutoExecConfig_SetFile("MyJailbreak_ffa");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_ffa_version", "PLUGIN_VERSION", "The version of the SourceMod plugin MyJailBreak - War", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_ffa_enable", "1", "0 - disabled, 1 - enable FFA");
	gc_bSpawnCell = AutoExecConfig_CreateConVar("sm_ffa_spawn", "1", "0 - teleport to weaponroom, 1 - standart spawn - cell doors auto open");
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_ffa_roundtime", "5", "Round time for a single war round");
	g_iSetRoundTime = FindConVar("mp_roundtime");
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_ffa_nodamage", "30", "Time after g_iFreezeTime; damage disbaled");
	g_iTruceTime = gc_iTruceTime.IntValue;
	gc_iRoundLimits = AutoExecConfig_CreateConVar("sm_ffa_roundsnext", "3", "Rounds until event can be started again.");
	g_iRoundLimits = gc_iRoundLimits.IntValue;
	gc_bTag = AutoExecConfig_CreateConVar("sm_ffa_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch you sv_tags", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	AutoExecConfig_CacheConvars();
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	AutoExecConfig(true, "MyJailbreak_ffa");
	
	IsFFA = false;
	StartFFA = false;
	VoteCount = 0;
	FFARound = 0;
	
	HookEvent("round_start", RoundStart);
	
	HookEvent("round_end", RoundEnd);
}


public void OnMapStart()
{


	VoteCount = 0;
	FFARound = 0;
	IsFFA = false;
	StartFFA = false;
	g_iRoundLimits = 0;
	

	g_iTruceTime = gc_iTruceTime.IntValue;
	
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
	
	if (IsFFA)
	{
	
		for(int client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client)) SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
		}

		if (FreezeTimer != null) KillTimer(FreezeTimer);
		if (TruceTimer != null) KillTimer(TruceTimer);
		
		
		if (winner == 2) PrintCenterTextAll("%t", "ffa_twin"); 
		if (winner == 3) PrintCenterTextAll("%t", "ffa_ctwin");

		if (FFARound == 3)
		{
			IsFFA = false;
			FFARound = 0;
			Format(voted, sizeof(voted), "");
			SetCvar("sm_hosties_lr", 1);
			SetCvar("dice_enable", 1);
			SetCvar("sm_beacon_enabled", 0);
			SetCvar("sm_warden_enable", 1);
			SetCvar("sm_hide_enable", 1);
			SetCvar("sm_noscope_enable", 1);
			SetCvar("sm_zombie_enable", 1);
			SetCvar("sm_weapons_t", 0);
			SetCvar("sm_weapons_ct", 1);
			SetCvar("sm_war_enable", 1);
			SetCvar("sm_duckhunt_enable", 1);
			SetCvar("sm_catch_enable", 1);
			SetCvar("mp_teammates_are_enemies", 0);
			SetCvar("mp_friendlyfire", 0);
			g_iSetRoundTime.IntValue = g_iOldRoundTime;
			CPrintToChatAll("%t %t", "ffa_tag" , "ffa_end");
		}
	}
	if (StartFFA)
	{
	g_iOldRoundTime = g_iSetRoundTime.IntValue;
	g_iSetRoundTime.IntValue = gc_iRoundTime.IntValue;
	}
}

public Action Setffa(int client,int args)
{
	if (gc_bPlugin.BoolValue)	
	{
	if (warden_iswarden(client) || CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
	{
	if (g_iRoundLimits == 0)
	{
	StartFFA = true;
	g_iRoundLimits = gc_iRoundLimits.IntValue;
	VoteCount = 0;
								
	SetCvar("sm_hide_enable", 0);
	SetCvar("sm_war_enable", 0);
	SetCvar("sm_zombie_enable", 0);
	SetCvar("sm_duckhunt_enable", 0);
	SetCvar("sm_noscope_enable", 0);
	SetCvar("sm_catch_enable", 0);
							
	CPrintToChatAll("%t %t", "ffa_tag" , "ffa_next");
	}else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_wait", g_iRoundLimits);
	}else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
}

public void RoundStart(Handle:event, char[] name, bool:dontBroadcast)
{
	if (StartFFA || IsFFA)
	{
		{AcceptEntityInput(FogIndex, "TurnOn");}
		char info1[255], info2[255], info3[255], info4[255], info5[255], info6[255], info7[255], info8[255];
		char info9[255], info10[255], info11[255], info12[255];
		SetCvar("dice_enable", 0);
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_beacon_enabled", 1);
		SetCvar("sm_weapons_t", 1);
		SetCvar("sm_weapons_ct", 1);
		SetCvar("mp_teammates_are_enemies", 1);
		SetCvar("mp_friendlyfire", 1);
		FFARound++;
		IsFFA = true;
		StartFFA = false;
		if (gc_bSpawnCell.BoolValue)
		{
		SJD_OpenDoors();
		}
		FFAMenu = CreatePanel();
		Format(info1, sizeof(info1), "%T", "ffa_info_Title", LANG_SERVER);
		SetPanelTitle(FFAMenu, info1);
		DrawPanelText(FFAMenu, "                                   ");
		Format(info10, sizeof(info10), "%T", "RoundOne", LANG_SERVER);
		if (FFARound == 1) DrawPanelText(FFAMenu, info10);
		Format(info11, sizeof(info11), "%T", "RoundTwo", LANG_SERVER);
		if (FFARound == 2) DrawPanelText(FFAMenu, info11);
		Format(info12, sizeof(info12), "%T", "RoundThree", LANG_SERVER);
		if (FFARound == 3) DrawPanelText(FFAMenu, info12);
		DrawPanelText(FFAMenu, "                                   ");
		if (!gc_bSpawnCell.BoolValue)
		{
		Format(info2, sizeof(info2), "%T", "ffa_info_Tele", LANG_SERVER);
		DrawPanelText(FFAMenu, info2);
		DrawPanelText(FFAMenu, "-----------------------------------");
		Format(info3, sizeof(info3), "%T", "ffa_info_Line2", LANG_SERVER);
		DrawPanelText(FFAMenu, info3);
		Format(info4, sizeof(info4), "%T", "ffa_info_Line3", LANG_SERVER);
		DrawPanelText(FFAMenu, info4);
		Format(info5, sizeof(info5), "%T", "ffa_info_Line4", LANG_SERVER);
		DrawPanelText(FFAMenu, info5);
		Format(info6, sizeof(info6), "%T", "ffa_info_Line5", LANG_SERVER);
		DrawPanelText(FFAMenu, info6);
		Format(info7, sizeof(info7), "%T", "ffa_info_Line6", LANG_SERVER);
		DrawPanelText(FFAMenu, info7);
		Format(info8, sizeof(info8), "%T", "ffa_info_Line7", LANG_SERVER);
		DrawPanelText(FFAMenu, info8);
		DrawPanelText(FFAMenu, "-----------------------------------");
		}else{
		Format(info9, sizeof(info9), "%T", "ffa_info_Spawn", LANG_SERVER);
		DrawPanelText(FFAMenu, info9);
		DrawPanelText(FFAMenu, "-----------------------------------");
		Format(info3, sizeof(info3), "%T", "ffa_info_Line2", LANG_SERVER);
		DrawPanelText(FFAMenu, info3);
		Format(info4, sizeof(info4), "%T", "ffa_info_Line3", LANG_SERVER);
		DrawPanelText(FFAMenu, info4);
		Format(info5, sizeof(info5), "%T", "ffa_info_Line4", LANG_SERVER);
		DrawPanelText(FFAMenu, info5);
		Format(info6, sizeof(info6), "%T", "ffa_info_Line5", LANG_SERVER);
		DrawPanelText(FFAMenu, info6);
		Format(info7, sizeof(info7), "%T", "ffa_info_Line6", LANG_SERVER);
		DrawPanelText(FFAMenu, info7);
		Format(info8, sizeof(info8), "%T", "ffa_info_Line7", LANG_SERVER);
		DrawPanelText(FFAMenu, info8);
		DrawPanelText(FFAMenu, "-----------------------------------");
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

			if (FFARound > 0)
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
					}else
					{
					if (IsClientInGame(client))
					{
						if (GetClientTeam(client) == 3)
						{
							TeleportEntity(client, Pos1, NULL_VECTOR, NULL_VECTOR);
						}
						if (GetClientTeam(client) == 2)
						{
							TeleportEntity(client, Pos1, NULL_VECTOR, NULL_VECTOR);
						}
					}
					}
				}CPrintToChatAll("%t %t", "ffa_tag" ,"ffa_rounds", FFARound);
			}
			for(int client=1; client <= MaxClients; client++)
			{
				if (IsClientInGame(client))
				{
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					SendPanelToClient(FFAMenu, client, Pass, 15);
					SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
				}
			}
			TruceTimer = CreateTimer(1.0, NoDamage, _, TIMER_REPEAT);
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

public Action:NoDamage(Handle:timer)
{
	if (g_iTruceTime > 1)
	{
		g_iTruceTime--;
		
		PrintCenterTextAll("%t", "ffa_damage", g_iTruceTime);
		
		return Plugin_Continue;
	}
	
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	PrintCenterTextAll("%t", "ffa_start");
	
	for(int client=1; client <= MaxClients; client++) 
	{
		if (IsClientInGame(client) && IsPlayerAlive(client)) SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
	}

	CPrintToChatAll("%t %t", "ffa_tag" , "ffa_start");
	DoFog();
	AcceptEntityInput(FogIndex, "TurnOff");
	TruceTimer = null;
	
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

public Action VoteFFA(int client,int args)
{
	char steamid[64];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	
	if (gc_bPlugin.BoolValue)
	{	
		if (GetTeamClientCount(3) > 0)
		{
			if (g_iRoundLimits == 0)
			{
				if (!IsFFA && !StartFFA)
				{
					if (StrContains(voted, steamid, true) == -1)
					{
						int playercount = (GetClientCount(true) / 2);
						
						VoteCount++;
						
						int Missing = playercount - VoteCount + 1;
						
						Format(voted, sizeof(voted), "%s,%s", voted, steamid);
						
						if (VoteCount > playercount)
						{
							StartFFA = true;
							
							SetCvar("sm_hide_enable", 0);
							SetCvar("sm_war_enable", 0);
							SetCvar("sm_zombie_enable", 0);
							SetCvar("sm_duckhunt_enable", 0);
							SetCvar("sm_catch_enable", 0);
							SetCvar("sm_noscope_enable", 0);
							
							g_iRoundLimits = gc_iRoundLimits.IntValue;
							VoteCount = 0;
							
							CPrintToChatAll("%t %t", "ffa_tag" , "ffa_next");
						}
						else CPrintToChatAll("%t %t", "ffa_tag" , "ffa_need", Missing);
						
					}
					else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_voted");
				}
				else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_progress");
			}
			else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_wait", g_iRoundLimits);
		}
		else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_minct");
	}
	else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_disabled");
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
	IsFFA = false;
	StartFFA = false;
	VoteCount = 0;
	FFARound = 0;
	
	voted[0] = '\0';
}