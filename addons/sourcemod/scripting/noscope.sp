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
#define PLUGIN_VERSION "0.1"

//Booleans
bool IsNoScope = false; 
bool StartNoScope = false; 

//ConVars
ConVar gc_bPlugin;
ConVar gc_bTag;
ConVar gc_bSetW;
ConVar gc_bGrav;
ConVar gc_fGravValue;
ConVar gc_iRoundWait;
ConVar gc_bSetA;
ConVar gc_bVote;
ConVar gc_iRoundLimits;
ConVar gc_iRoundTime;
ConVar gc_iTruceTime;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar g_iSetRoundTime;

//Integers
int g_iOldRoundTime;
int g_iRoundLimits;
int g_iTruceTime;
int g_iVoteCount = 0;
int NoScopeRound = 0;
int m_flNextSecondaryAttack;

//Handles
Handle TruceTimer;
Handle NoScopeMenu;
Handle UseCvar;

//Strings
char g_sHasVoted[1500];
char g_sOverlayStart[256];

public Plugin myinfo = {
	name = "MyJailbreak - NoScope",
	author = "shanapu & Floody.de, Franc1sco",
	description = "Jailbreak NoScope script",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreakWarden.phrases");
	LoadTranslations("MyJailbreakNoScope.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_setnoscope", SetNoScope);
	RegConsoleCmd("sm_noscope", VoteNoScope);
	RegConsoleCmd("sm_scout", VoteNoScope);
	
	//AutoExecConfig
	AutoExecConfig_SetFile("MyJailbreak_noscope");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_noscope_version", PLUGIN_VERSION, "The version of the SourceMod plugin MyJailBreak - noscope", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_noscope_enable", "1", "0 - disabled, 1 - enable noscope");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_noscope_setw", "1", "0 - disabled, 1 - allow warden to set noscope round", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_noscope_seta", "1", "0 - disabled, 1 - allow admin to set noscope round", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_noscope_vote", "1", "0 - disabled, 1 - allow player to vote for noscope", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bGrav = AutoExecConfig_CreateConVar("sm_noscope_gravity", "1", "0 - disabled, 1 - enable low Gravity for noscope", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_fGravValue= AutoExecConfig_CreateConVar("sm_noscope_gravity_value", "0.3","Ratio for Gravity 1.0 earth 0.5 moon", 0, true, 0.1, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_noscope_roundtime", "5", "Round time for a single noscope round");
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_noscope_nodamage", "15", "Time for no damage");
	gc_iRoundLimits = AutoExecConfig_CreateConVar("sm_noscope_roundsnext", "3", "Rounds until event can be started again.");
	gc_iRoundWait = AutoExecConfig_CreateConVar("sm_noscope_roundwait", "3", "Rounds until event can be started after mapchange.", FCVAR_NOTIFY, true, 0.0, true, 255.0);
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_noscope_overlays", "1", "0 - disabled, 1 - enable overlays", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_noscope_overlaystart_path", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_bTag = AutoExecConfig_CreateConVar("sm_noscope_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookEvent("round_end", RoundEnd);
	
	//Find
	g_iSetRoundTime = FindConVar("mp_roundtime");
	g_iRoundLimits = gc_iRoundLimits.IntValue;
	g_iTruceTime = gc_iTruceTime.IntValue;
	gc_sOverlayStartPath.GetString(g_sOverlayStart , sizeof(g_sOverlayStart));
	m_flNextSecondaryAttack = FindSendPropInfo("CBaseCombatWeapon", "m_flNextSecondaryAttack");
	
	IsNoScope = false;
	StartNoScope = false;
	g_iVoteCount = 0;
	NoScopeRound = 0;
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
	PrecacheOverlayAnyDownload(g_sOverlayStart);
	g_iVoteCount = 0;
	NoScopeRound = 0;
	IsNoScope = false;
	StartNoScope = false;
	g_iRoundLimits = gc_iRoundWait.IntValue;
	g_iTruceTime = gc_iTruceTime.IntValue;
	
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
	SDKHook(client, SDKHook_PreThink, OnPreThink);
}

public Action SetNoScope(int client,int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (warden_iswarden(client))
		{
			if (gc_bSetW.BoolValue)
			{
				if (!IsNoScope && !StartNoScope)
				{
					if (g_iRoundLimits == 0)
					{
						StartNextRound();
					}
					else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_wait", g_iRoundLimits);
				}
				else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_progress");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "nocscope_setbywarden");
		}
		else if (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
			{
				if (gc_bSetA.BoolValue)
				{
					if (!IsNoScope && !StartNoScope)
					{
						if (g_iRoundLimits == 0)
						{
							StartNextRound();
						}
						else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_wait", g_iRoundLimits);
					}
					else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_progress");
				}
				else CPrintToChat(client, "%t %t", "nocscope_tag" , "noscope_setbyadmin");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_disabled");
}

public Action VoteNoScope(int client,int args)
{
	char steamid[64];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	
	if (gc_bPlugin.BoolValue)
	{	
		if (gc_bVote.BoolValue)
		{	
			if (!IsNoScope && !StartNoScope)
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
						}else CPrintToChatAll("%t %t", "noscope_tag" , "noscope_need", Missing, client);
					}
					else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_voted");
				}
				else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_wait", g_iRoundLimits);
			}
			else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_progress");
		}
		else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_voting");
	}
	else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_disabled");
}

void StartNextRound()
{
	StartNoScope = true;
	g_iRoundLimits = gc_iRoundLimits.IntValue;
	g_iVoteCount = 0;
	SetCvar("sm_war_enable", 0);
	SetCvar("sm_zombie_enable", 0);
	SetCvar("sm_ffa_enable", 0);
	SetCvar("sm_dodgeball_enable", 0);
	SetCvar("sm_freeday_enable", 0);
	SetCvar("sm_hide_enable", 0);
	SetCvar("sm_catch_enable", 0);
	SetCvar("sm_duckhunt_enable", 0);
	CPrintToChatAll("%t %t", "noscope_tag" , "noscope_next");
	PrintHintTextToAll("%t", "noscope_next_nc");

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
		ServerCommand("sm_removewarden");
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
						GivePlayerItem(client, "weapon_ssg08");
						
						if (gc_bGrav.BoolValue)
						{
							SetEntityGravity(client, gc_fGravValue.FloatValue);	
						}
						
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
	}
	else
	{
		if (g_iRoundLimits > 0) g_iRoundLimits--;
	}
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
		}
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:OnPreThink(client)
{
	int iWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	MakeNoScope(iWeapon);
	return Plugin_Continue;
}

stock MakeNoScope(weapon)
{
	if (IsNoScope == true)
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
}

public Action:NoScope(Handle:timer)
{
	if (g_iTruceTime > 1)
	{
		g_iTruceTime--;
		for (int client=1; client <= MaxClients; client++)
		if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				PrintCenterText(client,"%t", "noscope_timetounfreeze_nc", g_iTruceTime);
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
				SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
				if (gc_bGrav.BoolValue)
				{
					SetEntityGravity(client, gc_fGravValue.FloatValue);	
				}
			}
			CreateTimer( 0.0, ShowOverlayStart, client);
		}
	}
	PrintHintTextToAll("%t", "noscope_start_nc");
	CPrintToChatAll("%t %t", "noscope_tag" , "noscope_start");
	
	TruceTimer = null;
	
	return Plugin_Stop;
}

public void RoundEnd(Handle:event, char[] name, bool:dontBroadcast)
{
	int winner = GetEventInt(event, "winner");
	
	if (IsNoScope)
	{
		for(int client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client)) SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
			SetEntityGravity(client, 1.0);
		}
		
		if (TruceTimer != null) KillTimer(TruceTimer);
		if (winner == 2) PrintHintTextToAll("%t", "noscope_twin_nc");
		if (winner == 3) PrintHintTextToAll("%t", "noscope_ctwin_nc");
		IsNoScope = false;
		StartNoScope = false;
		NoScopeRound = 0;
		Format(g_sHasVoted, sizeof(g_sHasVoted), "");
		SetCvar("sm_hosties_lr", 1);
		SetCvar("sm_war_enable", 1);
		SetCvar("sm_dice_enable", 1);
		SetCvar("sm_weapons_enable", 1);
		SetCvar("sm_zombie_enable", 1);
		SetCvar("sm_freeday_enable", 1);
		SetCvar("sm_hide_enable", 1);
		SetCvar("sm_dodgeball_enable", 1);
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

	for(int i = 1; i <= MaxClients; i++)
	if(IsClientInGame(i)) SDKUnhook(i, SDKHook_PreThink, OnPreThink);
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
	g_iVoteCount = 0;
	NoScopeRound = 0;
	g_sHasVoted[0] = '\0';
}