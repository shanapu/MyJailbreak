//includes
#include <sourcemod>
#include <colors>
#include <sdktools>
#include <cstrike>
#include <wardn>
#include <emitsoundany>
#include <smartjaildoors>
#include <sdkhooks>
#include <autoexecconfig>
#include <myjailbreak>


//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//Booleans
bool IsDuckHunt;
bool StartDuckHunt;

//ConVars
ConVar gc_bPlugin;
ConVar gc_bTag;
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_bVote;
ConVar gc_bSounds;
ConVar gc_sSoundStartPath;
ConVar gc_iCooldownDay;
ConVar gc_iRoundTime;
ConVar gc_iCooldownStart;
ConVar gc_iTruceTime;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar g_iSetRoundTime;
ConVar g_bAllowTP;

//Integers
int g_iOldRoundTime;
int g_iCoolDown;
int g_iTruceTime;
int g_iVoteCount = 0;
int DuckHuntRound = 0;

//Handles
Handle TruceTimer;
Handle DuckHuntMenu;

//Strings

char g_sHasVoted[1500];
char g_sSoundStartPath[256];
char huntermodel[256] = "models/player/custom_player/legacy/tm_phoenix_heavy.mdl";

public Plugin myinfo = {
	name = "MyJailbreak - DuckHunt",
	author = "shanapu & Floody.de, Franc1sco",
	description = "Jailbreak DuckHunt script",
	version = PLUGIN_VERSION,
	url = "shanapu.de"
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreakWarden.phrases");
	LoadTranslations("MyJailbreakDuckHunt.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_setduckhunt", SetDuckHunt);
	RegConsoleCmd("sm_duckhunt", VoteDuckHunt);
	
	//AutoExecConfig
	AutoExecConfig_SetFile("MyJailbreak_duckhunt");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_duckhunt_version", PLUGIN_VERSION, "The version of the SourceMod plugin MyJailBreak - duckhunt", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_duckhunt_enable", "1", "0 - disabled, 1 - enable duckhunt");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_duckhunt_warden", "1", "0 - disabled, 1 - allow warden to set duckhunt round", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_duckhunt_admin", "1", "0 - disabled, 1 - allow admin to set duckhunt round", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_duckhunt_vote", "1", "0 - disabled, 1 - allow player to vote for duckhunt", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_duckhunt_roundtime", "5", "Round time for a single duckhunt round");
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_duckhunt_trucetime", "15", "Time freeze duckhunts");
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_duckhunt_cooldown_day", "3", "Rounds cooldown after a event until this event can startet");
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_duckhunt_cooldown_start", "3", "Rounds until event can be started after mapchange.", FCVAR_NOTIFY, true, 0.0, true, 255.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_duckhunt_sounds_enable", "1", "0 - disabled, 1 - enable warden sounds");
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_duckhunt_sounds_start", "music/myjailbreak/start.mp3", "Path to the soundfile which should be played for a start countdown.");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_duckhunt_overlays_enable", "1", "0 - disabled, 1 - enable overlays", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_duckhunt_overlays_start", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_bTag = AutoExecConfig_CreateConVar("sm_duckhunt_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("round_end", RoundEnd);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookEvent("hegrenade_detonate", HE_Detonate);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
//	HookEvent("weapon_reload", Reloadweapon);
	
	
	//FindConVar
	g_bAllowTP = FindConVar("sv_allow_thirdperson");
	g_iSetRoundTime = FindConVar("mp_roundtime");
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	gc_sOverlayStartPath.GetString(g_sOverlayStart , sizeof(g_sOverlayStart));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
	
	if(g_bAllowTP == INVALID_HANDLE)
	{
		SetFailState("sv_allow_thirdperson not found!");
	}
	
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
	g_iVoteCount = 0;
	DuckHuntRound = 0;
	IsDuckHunt = false;
	StartDuckHunt = false;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;
	PrecacheModel("models/chicken/chicken.mdl", true);
	PrecacheModel(huntermodel, true);
	if(gc_bOverlays.BoolValue) PrecacheOverlayAnyDownload(g_sOverlayStart);
	if(gc_bSounds.BoolValue)	
	{
		PrecacheSoundAnyDownload(g_sSoundStartPath);
	}	
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
}

public Action SetDuckHunt(int client,int args)
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
					else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_wait", g_iCoolDown);
				}
				else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_progress" , EventDay);
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "duckhunt_setbywarden");
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
						else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_progress" , EventDay);
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
							}
							else CPrintToChatAll("%t %t", "duckhunt_tag" , "duckhunt_need", Missing, client);
						}
						else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_voted");
					}
					else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_wait");
				}
				else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_progress", g_iCoolDown);
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
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;
	
	SetEventDay("duckhunt");
	
	CPrintToChatAll("%t %t", "duckhunt_tag" , "duckhunt_next");
	PrintHintTextToAll("%t", "duckhunt_next_nc");
}

public void RoundStart(Handle event, char[] name, bool dontBroadcast)
{

	if (StartDuckHunt)
	{
		char info1[255], info2[255], info3[255], info4[255], info5[255], info6[255], info7[255], info8[255];
		
		ServerCommand("sm_removewarden");
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		
		SetCvar("sm_weapons_enable", 0);
		SetConVarInt(g_bAllowTP, 1);
		
		IsDuckHunt = true;
		DuckHuntRound++;
		StartDuckHunt = false;

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
							SetEntityModel(client, huntermodel);
							SetEntityHealth(client, 600);
							GivePlayerItem(client, "weapon_nova");
//							int iEnt = GivePlayerItem(client, "weapon_nova");
//							lib_SetWeaponAmmo(iEnt,8,120);
							
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
		char EventDay[64];
		GetEventDay(EventDay);
		
		if(!StrEqual(EventDay, "none", false))
		{
			g_iCoolDown = gc_iCooldownDay.IntValue + 1;
		}
		else if (g_iCoolDown > 0) g_iCoolDown--;
	}
}

/* 
public Action Reloadweapon(Handle event, const char[] name, bool dontBroadcast)
{
	if(IsDuckHunt == true)
	{
		
		int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
		int weapon = GivePlayerItem(iClient, "weapon_nova");
		
		if(GetClientTeam(iClient) == CS_TEAM_CT)
		{
			SetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", 32);
		}
	}
}
*/

public Action OnWeaponCanUse(int client, int weapon)
{
	if(IsDuckHunt == true)
	{
		char sWeapon[32];
		GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));
		if((GetClientTeam(client) == CS_TEAM_T && StrEqual(sWeapon, "weapon_hegrenade")) || (GetClientTeam(client) == CS_TEAM_CT && StrEqual(sWeapon, "weapon_nova")))
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

public Action DuckHunt(Handle timer)
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
			if(gc_bSounds.BoolValue)	
			{
				EmitSoundToAllAny(g_sSoundStartPath);
			}
		}
	}
	PrintHintTextToAll("%t", "duckhunt_start_nc");
	CPrintToChatAll("%t %t", "duckhunt_tag" , "duckhunt_start");
	SJD_OpenDoors();
	TruceTimer = null;
	return Plugin_Stop;
}

public void RoundEnd(Handle event, char[] name, bool dontBroadcast)
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
		SetCvar("sm_weapons_enable", 1);
		SetCvar("sm_warden_enable", 1);
		SetConVarInt(g_bAllowTP, 0);
		g_iSetRoundTime.IntValue = g_iOldRoundTime;
		SetEventDay("none");
		CPrintToChatAll("%t %t", "duckhunt_tag" , "duckhunt_end");
	}

	if (StartDuckHunt)
	{
		g_iOldRoundTime = g_iSetRoundTime.IntValue;
		g_iSetRoundTime.IntValue = gc_iRoundTime.IntValue;
	}
}

public Action HE_Detonate(Handle event, const char[] name, bool dontBroadcast)
{
	if (IsDuckHunt == true)
	{
		int target = GetClientOfUserId(GetEventInt(event, "userid"));
		if (GetClientTeam(target) == 1 && !IsPlayerAlive(target))
		{
			return;
		}
		GivePlayerItem(target, "weapon_hegrenade");
	}
	return;
}

public Action FP(int client)
{
	ClientCommand(client, "firstperson");
}

public void OnClientDisconnect(int client)
{
	if (IsDuckHunt == true)
	{
		FP(client);
	}
}

public void OnMapEnd()
{
	IsDuckHunt = false;
	StartDuckHunt = false;
	g_iVoteCount = 0;
	DuckHuntRound = 0;
	g_sHasVoted[0] = '\0';
	for(int client=1; client <= MaxClients; client++)
	{
		FP(client);
	}
}