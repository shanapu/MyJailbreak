//includes

#include <sourcemod>
#include <colors>
#include <sdktools>
#include <cstrike>
#include <wardn>
#include <smartjaildoors>
#include <sdkhooks>
#include <autoexecconfig>

//Compiler Options
#pragma semicolon 1

//Defines
#define PLUGIN_VERSION "0.1"

//Booleans
bool IsDuckHunt;
bool StartDuckHunt;

//ConVars
ConVar gc_bPlugin;
ConVar gc_bTag;
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_bVote;
ConVar gc_iRoundLimits;
ConVar gc_iRoundTime;
ConVar gc_iRoundWait;
ConVar gc_iTruceTime;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar g_iSetRoundTime;

//Integers
int g_iOldRoundTime;
int g_iRoundLimits;
int g_iTruceTime;
int g_iVoteCount = 0;
int DuckHuntRound = 0;

//Handles
Handle TruceTimer;
Handle DuckHuntMenu;
Handle UseCvar;

//Strings
char g_sOverlayStart[256];
char g_sHasVoted[1500];
char model[256] = "models/player/custom_player/legacy/tm_phoenix_heavy.mdl";

public Plugin myinfo = {
	name = "MyJailbreak - DuckHunt",
	author = "shanapu & Floody.de, Franc1sco",
	description = "Jailbreak DuckHunt script",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreakWarden.phrases");
	LoadTranslations("MyJailbreakDuckHunt.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_setduckhunt", SetDuckHunt);
	RegConsoleCmd("sm_duckhunt", VoteDuckHunt);
	RegConsoleCmd("sm_duck", VoteDuckHunt);
	
	//AutoExecConfig
	AutoExecConfig_SetFile("MyJailbreak_duckhunt");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_duckhunt_version", PLUGIN_VERSION, "The version of the SourceMod plugin MyJailBreak - duckhunt", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_duckhunt_enable", "1", "0 - disabled, 1 - enable duckhunt");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_duckhunt_setw", "1", "0 - disabled, 1 - allow warden to set duckhunt round", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_duckhunt_seta", "1", "0 - disabled, 1 - allow admin to set duckhunt round", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_duckhunt_vote", "1", "0 - disabled, 1 - allow player to vote for duckhunt", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_duckhunt_roundtime", "5", "Round time for a single duckhunt round");
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_duckhunt_nodamage", "15", "Time freeze duckhunts");
	gc_iRoundLimits = AutoExecConfig_CreateConVar("sm_duckhunt_roundsnext", "3", "Rounds until event can be started again.");
	gc_iRoundWait = AutoExecConfig_CreateConVar("sm_duckhunt_roundwait", "3", "Rounds until event can be started after mapchange.", FCVAR_NOTIFY, true, 0.0, true, 255.0);
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_duckhunt_overlays", "1", "0 - disabled, 1 - enable overlays", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_duckhunt_overlaystart_path", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_bTag = AutoExecConfig_CreateConVar("sm_duckhunt_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("round_end", RoundEnd);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookEvent("hegrenade_detonate", HE_Detonate);
	
	//FindConVar
	g_iSetRoundTime = FindConVar("mp_roundtime");
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iRoundLimits = gc_iRoundLimits.IntValue;
	gc_sOverlayStartPath.GetString(g_sOverlayStart , sizeof(g_sOverlayStart));
	
	IsDuckHunt = false;
	StartDuckHunt = false;
	g_iVoteCount = 0;
	DuckHuntRound = 0;
}

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sOverlayStartPath)
	{
		strcopy(g_sOverlayStart, sizeof(g_sOverlayStart), newValue);
		PrecacheOverlayAnyDownload(g_sOverlayStart);
	}
}

public void OnMapStart()
{
	g_iVoteCount = 0;
	DuckHuntRound = 0;
	IsDuckHunt = false;
	StartDuckHunt = false;
	g_iRoundLimits = gc_iRoundWait.IntValue;
	g_iTruceTime = gc_iTruceTime.IntValue;
	PrecacheModel("models/chicken/chicken.mdl", true);
	PrecacheModel(model, true);
	PrecacheOverlayAnyDownload(g_sOverlayStart);
	AddFileToDownloadsTable("materials/models/props_farm/chicken_white.vmt");
	AddFileToDownloadsTable("materials/models/props_farm/chicken_white.vtf");
	AddFileToDownloadsTable("models/chicken/chicken.dx90.vtx");
	AddFileToDownloadsTable("models/chicken/chicken.phy");
	AddFileToDownloadsTable("models/chicken/chicken.vvd");
	AddFileToDownloadsTable("models/chicken/chicken.mdl");
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

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

public Action SetDuckHunt(int client,int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (warden_iswarden(client))
		{
			if (gc_bSetW.BoolValue)
			{
				if (!IsDuckHunt && !StartDuckHunt)
				{
					if (g_iRoundLimits == 0)
					{
						StartNextRound();
					}
					else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_wait", g_iRoundLimits);
				}
				else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_progress");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "duckhunt_setbywarden");
		}
		else if (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)) 
			{
				if (gc_bSetA.BoolValue)
				{
					if (!IsDuckHunt && !StartDuckHunt)
					{
						if (g_iRoundLimits == 0)
						{
							StartNextRound();
						}
						else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_wait", g_iRoundLimits);
					}
					else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_progress");
				}
				else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_setbyadmin");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_disabled");
}

public Action VoteDuckHunt(int client,int args)
{
	char steamid[64];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	
	if (gc_bPlugin.BoolValue)
	{	
		if (gc_bVote.BoolValue)
		{
			if (GetTeamClientCount(CS_TEAM_CT) > 0)
			{
				if (g_iRoundLimits == 0)
				{
					if (!IsDuckHunt && !StartDuckHunt)
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
							else CPrintToChatAll("%t %t", "duckhunt_tag" , "duckhunt_need", Missing, client);
						}
						else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_voted");
					}
					else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_progress");
				}
				else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_wait", g_iRoundLimits);
			}
			else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_minct");
		}
		else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_voting");
	}
	else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_disabled");
}

void StartNextRound()
{
	StartDuckHunt = true;
	g_iRoundLimits = gc_iRoundLimits.IntValue;
	g_iVoteCount = 0;
	SetCvar("sm_war_enable", 0);
	SetCvar("sm_zombie_enable", 0);
	SetCvar("sm_ffa_enable", 0);
	SetCvar("sm_hide_enable", 0);
	SetCvar("sm_dodgeball_enable", 0);
	SetCvar("sm_freeday_enable", 0);
	SetCvar("sm_catch_enable", 0);
	SetCvar("sm_noscope_enable", 0);
	CPrintToChatAll("%t %t", "duckhunt_tag" , "duckhunt_next");
	PrintHintTextToAll("%t", "duckhunt_next_nc");
}

public void RoundStart(Handle:event, char[] name, bool:dontBroadcast)
{
	if (StartDuckHunt)
	{
		char info1[255], info2[255], info3[255], info4[255], info5[255], info6[255], info7[255], info8[255];
		
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_beacon_enabled", 1);
		SetCvar("sv_infinite_ammo", 2);
		SetCvar("sm_dice_enable", 0);
		SetCvar("sm_weapons_enable", 0);
		IsDuckHunt = true;
		DuckHuntRound++;
		StartDuckHunt = false;
		ServerCommand("sm_removewarden");
		DuckHuntMenu = CreatePanel();
		Format(info1, sizeof(info1), "%T", "duckhunt_info_Title", LANG_SERVER);
		SetPanelTitle(DuckHuntMenu, info1);
		DrawPanelText(DuckHuntMenu, "                                   ");
		Format(info2, sizeof(info2), "%T", "duckhunt_info_Line1", LANG_SERVER);
		DrawPanelText(DuckHuntMenu, info2);
		DrawPanelText(DuckHuntMenu, "-----------------------------------");
		Format(info3, sizeof(info3), "%T", "duckhunt_info_Line2", LANG_SERVER);
		DrawPanelText(DuckHuntMenu, info3);
		Format(info4, sizeof(info4), "%T", "duckhunt_info_Line3", LANG_SERVER);
		DrawPanelText(DuckHuntMenu, info4);
		Format(info5, sizeof(info5), "%T", "duckhunt_info_Line4", LANG_SERVER);
		DrawPanelText(DuckHuntMenu, info5);
		Format(info6, sizeof(info6), "%T", "duckhunt_info_Line5", LANG_SERVER);
		DrawPanelText(DuckHuntMenu, info6);
		Format(info7, sizeof(info7), "%T", "duckhunt_info_Line6", LANG_SERVER);
		DrawPanelText(DuckHuntMenu, info7);
		Format(info8, sizeof(info8), "%T", "duckhunt_info_Line7", LANG_SERVER);
		DrawPanelText(DuckHuntMenu, info8);
		DrawPanelText(DuckHuntMenu, "-----------------------------------");
		
		if (DuckHuntRound > 0)
			{
				for(int client=1; client <= MaxClients; client++)
				{
					if (IsClientInGame(client))
					{
						StripAllWeapons(client);
						if (GetClientTeam(client) == CS_TEAM_CT)
						{
							SetEntityModel(client, model);
							SetEntityHealth(client, 600);
							GivePlayerItem(client, "weapon_nova");
						}
						if (GetClientTeam(client) == CS_TEAM_T)
						{
							SetEntityModel(client, "models/chicken/chicken.mdl");
							SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.2);
							SetEntityGravity(client, 0.3);
							SetEntityHealth(client, 150);
							GivePlayerItem(client, "weapon_hegrenade");
							ClientCommand(client, "thirdperson");
						}
						SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
						SendPanelToClient(DuckHuntMenu, client, Pass, 15);
						SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
					}
				}
				g_iTruceTime--;
				TruceTimer = CreateTimer(1.0, DuckHunt, _, TIMER_REPEAT);
			}
	}
	else
	{
		if (g_iRoundLimits > 0) g_iRoundLimits--;
	}
}

public Action:OnWeaponCanUse(client, weapon)
{
	if(IsDuckHunt == true)
	{

		char sWeapon[32];
		GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));

		if((GetClientTeam(client) == 2 && StrEqual(sWeapon, "weapon_hegrenade")) || (GetClientTeam(client) == 3 && StrEqual(sWeapon, "weapon_nova")))
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

public Action:DuckHunt(Handle:timer)
{
	if (g_iTruceTime > 1)
	{
		g_iTruceTime--;
		for (int client=1; client <= MaxClients; client++)
		if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				PrintCenterText(client,"%t", "duckhunt_timetounfreeze_nc", g_iTruceTime);
			}
		return Plugin_Continue;
	}
	
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	if (DuckHuntRound > 0)
	{
		for (int client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				if (GetClientTeam(client) == CS_TEAM_T)
					{
						SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
						SetEntityGravity(client, 0.3);
					}
				if (GetClientTeam(client) == CS_TEAM_CT)
					{
						SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
					}
			}
			CreateTimer( 0.0, ShowOverlayStart, client);
		}
	}
	PrintHintTextToAll("%t", "duckhunt_start_nc");
	CPrintToChatAll("%t %t", "duckhunt_tag" , "duckhunt_start");
	SJD_OpenDoors();
	TruceTimer = null;
	return Plugin_Stop;
}

public void RoundEnd(Handle:event, char[] name, bool:dontBroadcast)
{
	int winner = GetEventInt(event, "winner");
	
	if (IsDuckHunt)
	{
		for(int client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client))
				{
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
					SetEntityGravity(client, 1.0);
					FP(client);
				}
		}
		if (TruceTimer != null) KillTimer(TruceTimer);
		
		if (winner == 2) PrintHintTextToAll("%t", "duckhunt_twin_nc");
		if (winner == 3) PrintHintTextToAll("%t", "duckhunt_ctwin_nc");
		IsDuckHunt = false;
		StartDuckHunt = false;
		DuckHuntRound = 0;
		Format(g_sHasVoted, sizeof(g_sHasVoted), "");
		SetCvar("sm_hosties_lr", 1);
		SetCvar("sm_war_enable", 1);
		SetCvar("sm_noscope_enable", 1);
		SetCvar("sm_dice_enable", 1);
		SetCvar("sm_freeday_enable", 1);
		SetCvar("sm_dodgeball_enable", 1);
		SetCvar("sm_weapons_enable", 1);
		SetCvar("sm_zombie_enable", 1);
		SetCvar("sm_catch_enable", 1);
		SetCvar("sv_infinite_ammo", 0);
		SetCvar("sm_hide_enable", 1);
		SetCvar("sm_ffa_enable", 1);
		SetCvar("sm_beacon_enabled", 0);
		SetCvar("sm_warden_enable", 1);
		g_iSetRoundTime.IntValue = g_iOldRoundTime;
		CPrintToChatAll("%t %t", "duckhunt_tag" , "duckhunt_end");
	}
	if (StartDuckHunt)
	{
		g_iOldRoundTime = g_iSetRoundTime.IntValue;
		g_iSetRoundTime.IntValue = gc_iRoundTime.IntValue;
	}
}

public HE_Detonate(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (IsDuckHunt == true)
	{
	new target = GetClientOfUserId(GetEventInt(event, "userid"));
	if (GetClientTeam(target) == 1 && !IsPlayerAlive(target))
	{
		return;
	}
	GivePlayerItem(target, "weapon_hegrenade");
	}
	return;
}

public Pass(Handle:menu, MenuAction:action, param1, param2)
{
}

public FP(client)
{
	ClientCommand(client, "firstperson");
}

public Action ShowOverlayStart( Handle timer, any client ) 
{
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
	IsDuckHunt = false;
	StartDuckHunt = false;
	g_iVoteCount = 0;
	DuckHuntRound = 0;
	g_sHasVoted[0] = '\0';
}