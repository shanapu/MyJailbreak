//includes
#include <cstrike>
#include <sourcemod>
#include <sdktools>
#include <smartjaildoors>
#include <wardn>
#include <emitsoundany>
#include <colors>
#include <sdkhooks>
#include <autoexecconfig>
#include <myjailbreak>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//Booleans
bool IsNoScope = false; 
bool StartNoScope = false; 

//ConVars
ConVar gc_bPlugin;
ConVar gc_bTag;
ConVar gc_bSetW;
ConVar gc_bGrav;
ConVar gc_fGravValue;
ConVar gc_iCooldownStart;
ConVar gc_bSetA;
ConVar gc_bVote;
ConVar gc_iCooldownDay;
ConVar gc_iRoundTime;
ConVar gc_iTruceTime;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar g_iSetRoundTime;
ConVar gc_bSounds;
ConVar gc_sSoundStartPath;

//Integers
int g_iOldRoundTime;
int g_iCoolDown;
int g_iTruceTime;
int g_iVoteCount = 0;
int NoScopeRound = 0;
int m_flNextSecondaryAttack;

//Handles
Handle TruceTimer;
Handle NoScopeMenu;

//Strings
char g_sHasVoted[1500];
char g_sSoundStartPath[256];

public Plugin myinfo = {
	name = "MyJailbreak - NoScope",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = PLUGIN_VERSION,
	url = "shanapu.de"
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.NoScope.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_setnoscope", SetNoScope);
	RegConsoleCmd("sm_noscope", VoteNoScope);

	
	//AutoExecConfig
	AutoExecConfig_SetFile("MyJailbreak.NoScope");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_noscope_version", PLUGIN_VERSION, "The version of this MyJailBreak SourceMod plugin", FCVAR_SPONLY|FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_noscope_enable", "1", "0 - disabled, 1 - enable this MyJailBreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_bSetW = AutoExecConfig_CreateConVar("sm_noscope_warden", "1", "0 - disabled, 1 - allow warden to set noscope round", _, true,  0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_noscope_admin", "1", "0 - disabled, 1 - allow admin to set noscope round", _, true,  0.0, true, 1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_noscope_vote", "1", "0 - disabled, 1 - allow player to vote for noscope", _, true,  0.0, true, 1.0);
	gc_bGrav = AutoExecConfig_CreateConVar("sm_noscope_gravity", "1", "0 - disabled, 1 - enable low Gravity for noscope", _, true,  0.0, true, 1.0);
	gc_fGravValue= AutoExecConfig_CreateConVar("sm_noscope_gravity_value", "0.3","Ratio for Gravity 1.0 earth 0.5 moon", _, true, 0.1, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_noscope_roundtime", "5", "Round time in minutes for a single noscope round", _, true, 1.0);
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_noscope_trucetime", "15", "Time in seconds players can't deal damage", _, true,  0.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_noscope_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true,  0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_noscope_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true, 1.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_noscope_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true, 0.1, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_noscope_sounds_start", "music/myjailbreak/start.mp3", "Path to the soundfile which should be played for a start.");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_noscope_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true,  0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_noscope_overlays_start", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_bTag = AutoExecConfig_CreateConVar("sm_noscope_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster", _, true,  0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookEvent("round_end", RoundEnd);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	
	//Find
	g_iSetRoundTime = FindConVar("mp_roundtime");
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;
	gc_sOverlayStartPath.GetString(g_sOverlayStart , sizeof(g_sOverlayStart));
	m_flNextSecondaryAttack = FindSendPropInfo("CBaseCombatWeapon", "m_flNextSecondaryAttack");
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
}

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sOverlayStartPath)
	{
		strcopy(g_sOverlayStart, sizeof(g_sOverlayStart), newValue);
		if(gc_bOverlays.BoolValue) PrecacheOverlayAnyDownload(g_sOverlayStart);
	}
	else if(convar == gc_sSoundStartPath)
	{
		strcopy(g_sSoundStartPath, sizeof(g_sSoundStartPath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStartPath);
	}
}

public void OnMapStart()
{
	if(gc_bSounds.BoolValue)	
	{
		PrecacheSoundAnyDownload(g_sSoundStartPath);
	}	
	if(gc_bOverlays.BoolValue) PrecacheOverlayAnyDownload(g_sOverlayStart);
	g_iVoteCount = 0;
	NoScopeRound = 0;
	IsNoScope = false;
	StartNoScope = false;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;
}

public void OnConfigsExecuted()
{
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	
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

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	
	if (IsNoScope)
	{
		SDKHook(client, SDKHook_PreThink, OnPreThink);
	}
}

public Action SetNoScope(int client,int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (warden_iswarden(client))
		{
			if (gc_bSetW.BoolValue)
			{
				char EventDay[64];
				GetEventDay(EventDay);
				
				if(StrEqual(EventDay, "none", false))
				{
					if (g_iCoolDown == 0)
					{
						StartNextRound();
					}
					else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_wait", g_iCoolDown);
				}
				else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_progress" , EventDay);
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "nocscope_setbywarden");
		}
		else if (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
			{
				if (gc_bSetA.BoolValue)
				{
					char EventDay[64];
					GetEventDay(EventDay);
					
					if(StrEqual(EventDay, "none", false))
					{
						if (g_iCoolDown == 0)
						{
							StartNextRound();
						}
						else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_progress" , EventDay);
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
			char EventDay[64];
			GetEventDay(EventDay);
			
			if(StrEqual(EventDay, "none", false))
			{
				if (g_iCoolDown == 0)
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
				else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_wait", g_iCoolDown);
			}
			else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_progress" , EventDay);
		}
		else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_voting");
	}
	else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_disabled");
}

void StartNextRound()
{

	StartNoScope = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;
	
	SetEventDay("noscope");
	
	CPrintToChatAll("%t %t", "noscope_tag" , "noscope_next");
	PrintHintTextToAll("%t", "noscope_next_nc");
}

public void RoundStart(Handle event, char[] name, bool dontBroadcast)
{
	if (StartNoScope)
	{
		char info1[255], info2[255], info3[255], info4[255], info5[255], info6[255], info7[255], info8[255];
		
		ServerCommand("sm_removewarden");
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_weapons_enable", 0);
		
		SetCvar("sv_infinite_ammo", 2);
		SetCvar("sm_warden_enable", 0);
		SetCvar("mp_teammates_are_enemies", 1);
		
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
						if (gc_bGrav.BoolValue)
						{
							SetEntityGravity(client, gc_fGravValue.FloatValue);	
						}
						StripAllWeapons(client);
						GivePlayerItem(client, "weapon_ssg08");
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
		char EventDay[64];
		GetEventDay(EventDay);
	
		if(!StrEqual(EventDay, "none", false))
		{
			g_iCoolDown = gc_iCooldownDay.IntValue + 1;
		}
		else if (g_iCoolDown > 0) g_iCoolDown--;
	}
}

public Action OnWeaponCanUse(int client, int weapon)
{
	char sWeapon[32];
	GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));
	
	if(!StrEqual(sWeapon, "weapon_ssg08"))
		{
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				if(IsNoScope)
				{
					return Plugin_Handled;
				}
			}
		}
	return Plugin_Continue;
}

public Action OnPreThink(int client)
{
	int iWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	MakeNoScope(iWeapon);
	return Plugin_Continue;
}


stock void MakeNoScope(int weapon)
{
	if (IsNoScope == true)
	{
		if(IsValidEdict(weapon))
		{
			char classname[MAX_NAME_LENGTH];
			if (GetEdictClassname(weapon, classname, sizeof(classname)) || StrEqual(classname[7], "ssg08"))
			{
				SetEntDataFloat(weapon, m_flNextSecondaryAttack, GetGameTime() + 1.0);
			}
		}
	}
}

public Action NoScope(Handle timer)
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
			if(gc_bOverlays.BoolValue) CreateTimer( 0.0, ShowOverlayStart, client);
			if(gc_bSounds.BoolValue)	
			{
				EmitSoundToAllAny(g_sSoundStartPath);
			}
		}
	}
	PrintHintTextToAll("%t", "noscope_start_nc");
	CPrintToChatAll("%t %t", "noscope_tag" , "noscope_start");
	
	TruceTimer = null;
	
	return Plugin_Stop;
}

public void RoundEnd(Handle event, char[] name, bool dontBroadcast)
{
	int winner = GetEventInt(event, "winner");
	
	if (IsNoScope)
	{
		for(int client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client)) SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
			if (IsClientInGame(client)) SetEntityGravity(client, 1.0);
			
		}
		
		if (TruceTimer != null) KillTimer(TruceTimer);
		if (winner == 2) PrintHintTextToAll("%t", "noscope_twin_nc");
		if (winner == 3) PrintHintTextToAll("%t", "noscope_ctwin_nc");
		IsNoScope = false;
		StartNoScope = false;
		NoScopeRound = 0;
		Format(g_sHasVoted, sizeof(g_sHasVoted), "");
		SetCvar("sm_hosties_lr", 1);
		SetCvar("sm_weapons_enable", 1);
		SetCvar("sv_infinite_ammo", 0);
		SetCvar("mp_teammates_are_enemies", 0);
		
		SetCvar("sm_warden_enable", 1);
		g_iSetRoundTime.IntValue = g_iOldRoundTime;
		SetEventDay("none");
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

public void OnMapEnd()
{
	IsNoScope = false;
	StartNoScope = false;
	g_iVoteCount = 0;
	NoScopeRound = 0;
	g_sHasVoted[0] = '\0';
	SetEventDay("none");
}