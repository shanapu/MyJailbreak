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
#define PLUGIN_VERSION "0.1"

//Booleans
bool IsFFA = false;
bool StartFFA = false;

//ConVars
ConVar gc_bPlugin;
ConVar gc_bTag;
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_bVote;
ConVar gc_iRoundWait;
ConVar gc_bSpawnCell;
ConVar gc_iRoundTime;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar gc_iRoundLimits;
ConVar gc_iTruceTime;
ConVar g_iSetRoundTime;

//Integers
int g_iOldRoundTime;
int g_iRoundLimits;
int g_iTruceTime;
int g_iVoteCount;
int FFARound;
int FogIndex = -1;

//Floats
float mapFogStart = 0.0;
float mapFogEnd = 150.0;
float mapFogDensity = 0.99;
float Pos[3];

//Handles
Handle FreezeTimer;
Handle TruceTimer;
Handle FFAMenu;
Handle UseCvar;

//Strings
char g_sHasVoted[1500];
char g_sOverlayStart[256];

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
	
	//Client Commands
	RegConsoleCmd("sm_setffa", Setffa);
	RegConsoleCmd("sm_ffa", VoteFFA);
	RegConsoleCmd("sm_warffa", VoteFFA);
	
	//AutoExecConfig
	AutoExecConfig_SetFile("MyJailbreak_ffa");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_ffa_version", PLUGIN_VERSION, "The version of the SourceMod plugin MyJailBreak - ffa", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_ffa_enable", "1", "0 - disabled, 1 - enable FFA");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_ffa_setw", "1", "0 - disabled, 1 - allow warden to set ffa round", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_ffa_seta", "1", "0 - disabled, 1 - allow admin to set ffa round", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_ffa_vote", "1", "0 - disabled, 1 - allow player to vote for ffa", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bSpawnCell = AutoExecConfig_CreateConVar("sm_ffa_spawn", "1", "0 - teleport to weaponroom, 1 - standart spawn - cell doors auto open");
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_ffa_roundtime", "5", "Round time for a single ffa round");
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_ffa_nodamage", "30", "Time after g_iFreezeTime; damage disbaled");
	gc_iRoundLimits = AutoExecConfig_CreateConVar("sm_ffa_roundsnext", "3", "Rounds until event can be started again.");
	gc_iRoundWait = AutoExecConfig_CreateConVar("sm_ffa_roundwait", "3", "Rounds until event can be started after mapchange.", FCVAR_NOTIFY, true, 0.0, true, 255.0);
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_ffa_overlays", "1", "0 - disabled, 1 - enable overlays", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_ffa_overlaystart_path", "overlays/MyJailbreak/ansage3" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_bTag = AutoExecConfig_CreateConVar("sm_ffa_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch you sv_tags", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("round_end", RoundEnd);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	
	//FindConVar
	gc_sOverlayStartPath.GetString(g_sOverlayStart , sizeof(g_sOverlayStart));
	g_iSetRoundTime = FindConVar("mp_roundtime");
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iRoundLimits = gc_iRoundLimits.IntValue;
	
	
	IsFFA = false;
	StartFFA = false;
	g_iVoteCount = 0;
	FFARound = 0;

}

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sOverlayStartPath)
	{
		strcopy(g_sOverlayStart, sizeof(g_sOverlayStart), newValue);
	}
}

public void OnMapStart()
{
	PrecacheOverlayAnyDownload(g_sOverlayStart);
	g_iVoteCount = 0;
	FFARound = 0;
	IsFFA = false;
	StartFFA = false;
	g_iRoundLimits = gc_iRoundWait.IntValue;
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
	g_iRoundLimits = gc_iRoundWait.IntValue;
	
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

void PrecacheOverlayAnyDownload(char[] sOverlay)
{
	if(gc_bOverlays.BoolValue)
	{
		char sBufferVmt[256];
		char sBufferVtf[256];
		Format(sBufferVmt, sizeof(sBufferVmt), "%s.vmt", sOverlay);
		Format(sBufferVtf, sizeof(sBufferVtf), "%s.vtf", sOverlay);
		PrecacheDecal(sBufferVmt, true);
		PrecacheDecal(sBufferVtf, true);
		Format(sBufferVmt, sizeof(sBufferVmt), "materials/%s.vmt", sOverlay);
		Format(sBufferVtf, sizeof(sBufferVtf), "materials/%s.vtf", sOverlay);
		AddFileToDownloadsTable(sBufferVmt);
		AddFileToDownloadsTable(sBufferVtf);
	}
}

public Action Setffa(int client,int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (warden_iswarden(client))
		{
			if (gc_bSetW.BoolValue)
			{
				if (!IsFFA && !StartFFA)
				{
					if (g_iRoundLimits == 0)
					{
						StartNextRound();
					}
					else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_wait", g_iRoundLimits);
				}
				else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_progress");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "war_setbywarden");
		}
		else if (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
			{
				if (gc_bSetA.BoolValue)
				{
					if (!IsFFA && !StartFFA)
					{
						if (g_iRoundLimits == 0)
						{
							StartNextRound();
						}
						else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_wait", g_iRoundLimits);
					}
					else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_progress");
				}
				else CPrintToChat(client, "%t %t", "ffa_tag" , "war_setbyadmin");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_disabled");
}

public Action VoteFFA(int client,int args)
{
	char steamid[64];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	
	if (gc_bPlugin.BoolValue)
	{	
		if (gc_bVote.BoolValue)
		{
			if (GetTeamClientCount(3) > 0)
			{
				if (!IsFFA && !StartFFA)
				{
					if (g_iRoundLimits == 0)
					{
						if (StrContains(g_sHasVoted, steamid, true) == -1)
						{
							int playercount = (GetClientCount(true) / 2);
							g_iVoteCount++;
							int Missing = playercount - g_iVoteCount + 1;
							Format(g_sHasVoted, sizeof(g_sHasVoted), "%s,%s", g_sHasVoted, steamid);
							
							if (g_iVoteCount > playercount)
							{
								StartNextRound();
							}
							else CPrintToChatAll("%t %t", "ffa_tag" , "ffa_need", Missing, client);
						}
						else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_voted");
					}
					else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_wait", g_iRoundLimits);
				}
				else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_progress");
			}
			else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_minct");
		}
		else CPrintToChat(client, "%t %t", "war_tag" , "war_voting");
	}
	else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_disabled");
}

void StartNextRound()
{ 
	StartFFA = true;
	g_iRoundLimits = gc_iRoundLimits.IntValue;
	g_iVoteCount = 0;
	SetCvar("sm_hide_enable", 0);
	SetCvar("sm_war_enable", 0);
	SetCvar("sm_zombie_enable", 0);
	SetCvar("sm_duckhunt_enable", 0);
	SetCvar("sm_noscope_enable", 0);
	SetCvar("sm_catch_enable", 0);
	CPrintToChatAll("%t %t", "ffa_tag" , "ffa_next");
	PrintHintTextToAll("%t", "ffa_next_nc");
}

public void RoundStart(Handle:event, char[] name, bool:dontBroadcast)
{
	if (StartFFA || IsFFA)
	{
		{AcceptEntityInput(FogIndex, "TurnOn");}
		char info1[255], info2[255], info3[255], info4[255], info5[255], info6[255], info7[255], info8[255];
		char info9[255], info10[255], info11[255], info12[255];
		
		SetCvar("sm_dice_enable", 0);
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_beacon_enabled", 1);
		SetCvar("sm_weapons_t", 1);
		SetCvar("sm_freeday_enable", 0);
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
		}
		else
		{
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
								TeleportEntity(client, Pos1, NULL_VECTOR, NULL_VECTOR);
							}
						}
					}
				}
				CPrintToChatAll("%t %t", "ffa_tag" ,"ffa_rounds", FFARound);
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


public Action:NoDamage(Handle:timer)
{
	if (g_iTruceTime > 1)
	{
		g_iTruceTime--;
		
		PrintHintTextToAll("%t", "ffa_damage", g_iTruceTime);
		
		return Plugin_Continue;
	}
	
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	PrintHintTextToAll("%t", "ffa_start");
	
	for(int client=1; client <= MaxClients; client++) 
	{
		if (IsClientInGame(client) && IsPlayerAlive(client)) 
		{
		SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
		CreateTimer( 0.0, ShowOverlayStart, client);
		}
	}

	CPrintToChatAll("%t %t", "ffa_tag" , "ffa_start");
	DoFog();
	AcceptEntityInput(FogIndex, "TurnOff");
	TruceTimer = null;
	
	return Plugin_Stop;
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
		if (winner == 2) PrintHintTextToAll("%t", "ffa_twin"); 
		if (winner == 3) PrintHintTextToAll("%t", "ffa_ctwin");
		if (FFARound == 3)
		{
			IsFFA = false;
			FFARound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_dice_enable", 1);
			SetCvar("sm_beacon_enabled", 0);
			SetCvar("sm_warden_enable", 1);
			SetCvar("sm_hide_enable", 1);
			SetCvar("sm_noscope_enable", 1);
			SetCvar("sm_zombie_enable", 1);
			SetCvar("sm_freeday_enable", 1);
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

public Pass(Handle:menu, MenuAction:action, param1, param2)
{
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

public Action ShowOverlayStart( Handle timer, any client ) {
	
	if(gc_bOverlays.BoolValue && IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client))
	{
	int iFlag = GetCommandFlags( "r_screenoverlay" ) & ( ~FCVAR_CHEAT ); 
	SetCommandFlags( "r_screenoverlay", iFlag ); 
	ClientCommand( client, "r_screenoverlay \"%s.vtf\"", g_sOverlayStart);
	CreateTimer( 2.0, DeleteOverlay, client );
	}
	return Plugin_Continue;
	
}

public Action  DeleteOverlay( Handle timer, any client ) {
	int iFlag = GetCommandFlags( "r_screenoverlay" ) & ( ~FCVAR_CHEAT ); 
	SetCommandFlags( "r_screenoverlay", iFlag ); 
	ClientCommand( client, "r_screenoverlay \"\"" );
	
	return Plugin_Continue;
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
	g_iVoteCount = 0;
	FFARound = 0;
	g_sHasVoted[0] = '\0';
}