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
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_iRoundWait;
ConVar gc_bVote;
ConVar gc_iRoundTime;
ConVar gc_iRoundLimits;
ConVar gc_iFreezeTime;
ConVar g_iSetRoundTime;
ConVar gc_sModelPath;

ConVar gc_bOverlays;
ConVar gc_sOverlayStart;
char g_sOverlayStart[256];

int g_iOldRoundTime;
int g_iFreezeTime;
int g_iRoundLimits;

int VoteCount = 0;
int ZombieRound = 0;


Handle FreezeTimer;
Handle ZombieMenu;
Handle UseCvar;


char g_sZombieModel[256];
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
	
	
	AutoExecConfig_CreateConVar("sm_zombie_version", "PLUGIN_VERSION", "The version of the SourceMod plugin MyJailBreak - zombie", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_zombie_enable", "1", "0 - disabled, 1 - enable zombie");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_zombie_setw", "1", "0 - disabled, 1 - allow warden to set zombie round", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_zombie_seta", "1", "0 - disabled, 1 - allow admin to set zombie round", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_zombie_vote", "1", "0 - disabled, 1 - allow player to vote for zombie", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_zombie_roundtime", "5", "Round time for a single zombie round");
	g_iSetRoundTime = FindConVar("mp_roundtime");
	gc_iFreezeTime = AutoExecConfig_CreateConVar("sm_zombie_freezetime", "35", "Time freeze zombies");
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	gc_iRoundLimits = AutoExecConfig_CreateConVar("sm_zombie_roundsnext", "3", "Rounds until event can be started again.");
	g_iRoundLimits = gc_iRoundLimits.IntValue;
	gc_iRoundWait = AutoExecConfig_CreateConVar("sm_zombie_roundwait", "3", "Rounds until event can be started after mapchange.", FCVAR_NOTIFY, true, 0.0, true, 255.0);
	gc_bTag = AutoExecConfig_CreateConVar("sm_zombie_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch you sv_tags", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_sModelPath = AutoExecConfig_CreateConVar("sm_zombie_model", "models/player/custom_player/zombie/revenant/revenant_v2.mdl", "Path to the model for zombies.");
	gc_sModelPath.GetString(g_sZombieModel, sizeof(g_sZombieModel));
	HookConVarChange(gc_sModelPath, OnSettingChanged);
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_zombie_overlays", "1", "0 - disabled, 1 - enable overlays", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_sOverlayStart = AutoExecConfig_CreateConVar("sm_zombie_overlaystart_path", "overlays/MyJailbreak/ansage3" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_sOverlayStart.GetString(g_sOverlayStart , sizeof(g_sOverlayStart));
	HookConVarChange(gc_sOverlayStart, OnSettingChanged);
	
	
	
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

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sModelPath)
	{
		strcopy(g_sZombieModel, sizeof(g_sZombieModel), newValue);
	}else if(convar == gc_sOverlayStart)
	{
		strcopy(g_sOverlayStart, sizeof(g_sOverlayStart), newValue);
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


public Action ShowOverlayStart( Handle timer, any client ) {
	
	if(gc_bOverlays.BoolValue)
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


public void OnMapStart()
{
	VoteCount = 0;
	ZombieRound = 0;
	IsZombie = false;
	StartZombie = false;
	g_iRoundLimits = gc_iRoundWait.IntValue;
	
	PrecacheModel(g_sZombieModel);
	PrecacheOverlayAnyDownload(g_sOverlayStart);
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	
}

public void OnConfigsExecuted()
{
	g_iFreezeTime = gc_iFreezeTime.IntValue;
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
	if (warden_iswarden(client))
	{
	if (gc_bSetW.BoolValue)	
	{
	if (!IsZombie && !StartZombie)
				{
	if (g_iRoundLimits == 0)
	{
	StartNextRound();
		
	}else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_wait", g_iRoundLimits);
	}
				else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_progress")
	}else CPrintToChat(client, "%t %t", "warden_tag" , "zombie_setbywarden");
	}else if (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
	{
	if (gc_bSetA.BoolValue)	
	{
	if (!IsZombie && !StartZombie)
				{
	if (g_iRoundLimits == 0)
	{
	StartNextRound();
		
	}else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_wait", g_iRoundLimits);
	}
				else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_progress")
	}else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_setbyadmin");
	}else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_disabled");
}
void StartNextRound()
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
	PrintCenterTextAll("%t", "zombie_next_nc");
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
	SetEntityModel(client, g_sZombieModel);
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
			CreateTimer( 0.0, ShowOverlayStart, client);
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
		if (gc_bVote.BoolValue)
		{
		if (GetTeamClientCount(3) > 0)
		{
			if (!IsZombie && !StartZombie)
				{
				if (g_iRoundLimits == 0)
			{
			
					if (StrContains(voted, steamid, true) == -1)
					{
	int playercount = (GetClientCount(true) / 2);
	
	VoteCount++;
	
	int Missing = playercount - VoteCount + 1;
	
	Format(voted, sizeof(voted), "%s,%s", voted, steamid);
	
	if (VoteCount > playercount)
	{
		StartNextRound();
	}
	else CPrintToChatAll("%t %t", "zombie_tag" , "zombie_need", Missing, client);
	
					}
					else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_voted");
				}
			else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_wait", g_iRoundLimits);
		}
				else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_progress");
			}
		else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_minct");
		}else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_voting");
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