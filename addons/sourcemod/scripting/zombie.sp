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

//Defines
#define PLUGIN_VERSION "0.1"

//Booleans
bool IsZombie = false;
bool StartZombie = false;

//ConVars
ConVar gc_bPlugin;
ConVar gc_bTag;
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_iRoundWait;
ConVar gc_bVote;
ConVar gc_iRoundTime;
ConVar gc_iRoundLimits;
ConVar gc_iFreezeTime;
ConVar gc_sModelPath;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar g_iSetRoundTime;

//Integers
int g_iOldRoundTime;
int g_iFreezeTime;
int g_iRoundLimits;
int g_iVoteCount = 0;
int ZombieRound = 0;

//Handles
Handle FreezeTimer;
Handle ZombieMenu;
Handle UseCvar;

//Strings
char g_sOverlayStart[256];
char g_sZombieModel[256];
char g_sHasVoted[1500];

public Plugin myinfo = {
	name = "MyJailbreak - Zombie",
	author = "shanapu & Floody.de, Franc1sco",
	description = "Jailbreak Zombie script",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreakWarden.phrases");
	LoadTranslations("MyJailbreakZombie.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_setzombie", SetZombie);
	RegConsoleCmd("sm_zombie", VoteZombie);
	RegConsoleCmd("sm_undead", VoteZombie);
	
	//AutoExecConfig
	AutoExecConfig_SetFile("MyJailbreak_zombie");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_zombie_version", PLUGIN_VERSION, "The version of the SourceMod plugin MyJailBreak - zombie", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_zombie_enable", "1", "0 - disabled, 1 - enable zombie");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_zombie_setw", "1", "0 - disabled, 1 - allow warden to set zombie round", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_zombie_seta", "1", "0 - disabled, 1 - allow admin to set zombie round", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_zombie_vote", "1", "0 - disabled, 1 - allow player to vote for zombie", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_zombie_roundtime", "5", "Round time for a single zombie round");
	gc_iFreezeTime = AutoExecConfig_CreateConVar("sm_zombie_freezetime", "35", "Time freeze zombies");
	gc_iRoundLimits = AutoExecConfig_CreateConVar("sm_zombie_roundsnext", "3", "Rounds until event can be started again.");
	gc_iRoundWait = AutoExecConfig_CreateConVar("sm_zombie_roundwait", "3", "Rounds until event can be started after mapchange.", FCVAR_NOTIFY, true, 0.0, true, 255.0);
	gc_sModelPath = AutoExecConfig_CreateConVar("sm_zombie_model", "models/player/custom_player/zombie/revenant/revenant_v2.mdl", "Path to the model for zombies.");
	gc_sModelPath.GetString(g_sZombieModel, sizeof(g_sZombieModel));
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_zombie_overlays", "1", "0 - disabled, 1 - enable overlays", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_zombie_overlaystart_path", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_bTag = AutoExecConfig_CreateConVar("sm_zombie_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch you sv_tags", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("round_end", RoundEnd);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sModelPath, OnSettingChanged);
	
	//FindConVar
	g_iSetRoundTime = FindConVar("mp_roundtime");
	g_iRoundLimits = gc_iRoundLimits.IntValue;
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	gc_sOverlayStartPath.GetString(g_sOverlayStart , sizeof(g_sOverlayStart));
	
	
	IsZombie = false;
	StartZombie = false;
	g_iVoteCount = 0;
	ZombieRound = 0;
}

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sModelPath)
	{
		strcopy(g_sZombieModel, sizeof(g_sZombieModel), newValue);
		PrecacheModel(g_sZombieModel);
	}
	else if(convar == gc_sOverlayStartPath)
	{
		strcopy(g_sOverlayStart, sizeof(g_sOverlayStart), newValue);
		PrecacheOverlayAnyDownload(g_sOverlayStart);
	}
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

public void OnMapStart()
{
	g_iVoteCount = 0;
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
					}
					else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_wait", g_iRoundLimits);
				}
				else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_progress");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "zombie_setbywarden");
		}
		else if (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
		{
			if (gc_bSetA.BoolValue)
			{
				if (!IsZombie && !StartZombie)
				{
					if (g_iRoundLimits == 0)
					{
						StartNextRound();
					}
					else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_wait", g_iRoundLimits);
				}
				else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_progress");
			}
			else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_setbyadmin");
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_disabled");
}

public Action VoteZombie(int client,int args)
{
	char steamid[64];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	
	if (gc_bPlugin.BoolValue)
	{	
		if (gc_bVote.BoolValue)
		{
			if (GetTeamClientCount(CS_TEAM_CT) > 0)
			{
				if (!IsZombie && !StartZombie)
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
							else CPrintToChatAll("%t %t", "zombie_tag" , "zombie_need", Missing, client);
						}
						else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_voted");
					}
					else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_wait", g_iRoundLimits);
				}
				else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_progress");
			}
			else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_minct");
		}
		else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_voting");
	}
	else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_disabled");
}

void StartNextRound()
{
	StartZombie = true;
	g_iRoundLimits = gc_iRoundLimits.IntValue;
	g_iVoteCount = 0;
	SetCvar("sm_hide_enable", 0);
	SetCvar("sm_ffa_enable", 0);
	SetCvar("sm_freeday_enable", 0);
	SetCvar("sm_dodgeball_enable", 0);
	SetCvar("sm_war_enable", 0);
	SetCvar("sm_duckhunt_enable", 0);
	SetCvar("sm_catch_enable", 0);
	SetCvar("sm_noscope_enable", 0);
	CPrintToChatAll("%t %t", "zombie_tag" , "zombie_next");
	PrintHintTextToAll("%t", "zombie_next_nc");
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
		ServerCommand("sm_removewarden");
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
						if (GetClientTeam(client) == CS_TEAM_CT)
						{
							SetEntityModel(client, g_sZombieModel);
							SetEntityMoveType(client, MOVETYPE_NONE);
							SetEntityHealth(client, 10000);
							StripAllWeapons(client);
							GivePlayerItem(client, "weapon_knife");
						}
						if (GetClientTeam(client) == CS_TEAM_T)
						{
							SetEntityHealth(client, 65);
							GivePlayerItem(client, "weapon_negev");
							GivePlayerItem(client, "weapon_tec9");
							GivePlayerItem(client, "weapon_hegrenade");
						}
						SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
						SendPanelToClient(ZombieMenu, client, Pass, 15);
						SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
					}
				}
				g_iFreezeTime--;
				FreezeTimer = CreateTimer(1.0, Zombie, _, TIMER_REPEAT);
			}
	}
	else
	{
		if (g_iRoundLimits > 0) g_iRoundLimits--;
	}
}

public Action:Zombie(Handle:timer)
{
	if (g_iFreezeTime > 1)
	{
		g_iFreezeTime--;
		for (int client=1; client <= MaxClients; client++)
		if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				if (GetClientTeam(client) == CS_TEAM_CT)
				{
					PrintCenterText(client,"%t", "zombie_timetounfreeze_nc", g_iFreezeTime);
				}
				if (GetClientTeam(client) == CS_TEAM_T)
				{
					PrintCenterText(client,"%t", "zombie_timetozombie_nc", g_iFreezeTime);
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
				if (GetClientTeam(client) == CS_TEAM_CT)
				{
					SetEntityMoveType(client, MOVETYPE_WALK);
					SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.4);
				}
				SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
			}
			CreateTimer( 0.0, ShowOverlayStart, client);
		}
	}
	PrintHintTextToAll("%t", "zombie_start_nc");
	CPrintToChatAll("%t %t", "zombie_tag" , "zombie_start");
	FreezeTimer = null;
	
	return Plugin_Stop;
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
		
		
		if (winner == 2) PrintHintTextToAll("%t", "zombie_twin_nc");
		if (winner == 3) PrintHintTextToAll("%t", "zombie_ctwin_nc");
		IsZombie = false;
		StartZombie = false;
		ZombieRound = 0;
		Format(g_sHasVoted, sizeof(g_sHasVoted), "");
		SetCvar("sm_hosties_lr", 1);
		SetCvar("sm_war_enable", 1);
		SetCvar("sm_weapons_t", 0);
		SetCvar("sm_weapons_ct", 1);
		SetCvar("sm_noscope_enable", 1);
		SetCvar("sm_hide_enable", 1);
		SetCvar("sm_duckhunt_enable", 1);
		SetCvar("sm_catch_enable", 1);
		SetCvar("sm_dodgeball_enable", 1);
		SetCvar("sm_dice_enable", 1);
		SetCvar("sm_beacon_enabled", 0);
		SetCvar("sv_infinite_ammo", 0);
		SetCvar("sm_freeday_enable", 1);
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

public Pass(Handle:menu, MenuAction:action, param1, param2)
{
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

public Action  DeleteOverlay( Handle timer, any client ) 
{
	if(IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client))
	{
	int iFlag = GetCommandFlags( "r_screenoverlay" ) & ( ~FCVAR_CHEAT ); 
	SetCommandFlags( "r_screenoverlay", iFlag ); 
	ClientCommand( client, "r_screenoverlay \"\"" );
	}
	return Plugin_Continue;
}

stock StripAllWeapons(iClient)
{
	int iEnt;
	for (int i = 0; i <= 4; i++)
	{
		while ((iEnt = GetPlayerWeaponSlot(iClient, i)) != -1)
		{
			RemovePlayerItem(iClient, iEnt);
			AcceptEntityInput(iEnt, "Kill");
		}
	}
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
	g_iVoteCount = 0;
	ZombieRound = 0;
	g_sHasVoted[0] = '\0';
}