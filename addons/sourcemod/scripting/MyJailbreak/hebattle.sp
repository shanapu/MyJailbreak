//includes
#include <cstrike>
#include <sourcemod>

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
bool IsHEbattle; 
bool StartHEbattle; 

//ConVars
ConVar gc_bPlugin;
ConVar gc_bSetW;
ConVar gc_bGrav;
ConVar gc_fGravValue;
ConVar gc_iCooldownStart;
ConVar gc_bSetA;
ConVar gc_bVote;
ConVar gc_iCooldownDay;
ConVar gc_bSpawnCell;
ConVar gc_iRoundTime;
ConVar gc_iTruceTime;
ConVar gc_bSounds;
ConVar gc_sSoundStartPath;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar g_iGetRoundTime;
ConVar gc_iRounds;

//Integers
int g_iOldRoundTime;
int g_iCoolDown;
int g_iTruceTime;
int g_iVoteCount;
int g_iRound;
int g_iMaxRound;

//Handles
Handle TruceTimer;
Handle HEbattleMenu;

//Floats
float Pos[3];

//Strings
char g_sHasVoted[1500];
char g_sSoundStartPath[256];

public Plugin myinfo = {
	name = "MyJailbreak - HEbattle",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = PLUGIN_VERSION,
	url = URL_LINK
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.HEbattle.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_sethebattle", SetHEbattle, "Allows the Admin or Warden to set hebattle as next round");
	RegConsoleCmd("sm_hebattle", VoteHEbattle, "Allows players to vote for a hebattle");
	
	//AutoExecConfig
	AutoExecConfig_SetFile("HEbattle", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_hebattle_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_hebattle_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_bSetW = AutoExecConfig_CreateConVar("sm_hebattle_warden", "1", "0 - disabled, 1 - allow warden to set hebattle round", _, true,  0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_hebattle_admin", "1", "0 - disabled, 1 - allow admin to set hebattle round", _, true,  0.0, true, 1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_hebattle_vote", "1", "0 - disabled, 1 - allow player to vote for hebattle", _, true,  0.0, true, 1.0);
	gc_bSpawnCell = AutoExecConfig_CreateConVar("sm_hebattle_spawn", "0", "0 - T teleport to CT spawn, 1 - cell doors auto open", _, true,  0.0, true, 1.0);
	gc_bGrav = AutoExecConfig_CreateConVar("sm_hebattle_gravity", "1", "0 - disabled, 1 - enable low gravity", _, true,  0.0, true, 1.0);
	gc_fGravValue= AutoExecConfig_CreateConVar("sm_hebattle_gravity_value", "0.3","Ratio for gravity 0.5 moon / 1.0 earth ", _, true,  0.1, true, 1.0);
	gc_iRounds = AutoExecConfig_CreateConVar("sm_hebattle_rounds", "1", "Rounds to play in a row", _, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_hebattle_roundtime", "5", "Round time in minutes for a single hebattle round", _, true, 1.0);
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_hebattle_trucetime", "15", "Time in seconds players can't deal damage", _, true,  0.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_hebattle_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true,  0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_hebattle_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true,  0.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_hebattle_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true,  0.0, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_hebattle_sounds_start", "music/myjailbreak/start.mp3", "Path to the soundfile which should be played for start");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_hebattle_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true,  0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_hebattle_overlays_start", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("round_end", RoundEnd);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookEvent("hegrenade_detonate", HE_Detonate);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	
	//Find
	g_iGetRoundTime = FindConVar("mp_roundtime");
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;
	gc_sOverlayStartPath.GetString(g_sOverlayStart , sizeof(g_sOverlayStart));
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
	g_iVoteCount = 0;
	g_iRound = 0;
	IsHEbattle = false;
	StartHEbattle = false;
	
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	if(gc_bOverlays.BoolValue) PrecacheOverlayAnyDownload(g_sOverlayStart);
	if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStartPath);
}

public void OnConfigsExecuted()
{
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iMaxRound = gc_iRounds.IntValue;
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

public Action SetHEbattle(int client,int args)
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
					else CPrintToChat(client, "%t %t", "hebattle_tag" , "hebattle_wait", g_iCoolDown);
				}
				else CPrintToChat(client, "%t %t", "hebattle_tag" , "hebattle_progress" , EventDay);
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "hebattle_setbywarden");
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
						else CPrintToChat(client, "%t %t", "hebattle_tag" , "hebattle_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "hebattle_tag" , "hebattle_progress" , EventDay);
				}
				else CPrintToChat(client, "%t %t", "hebattle_tag" , "hebattle_setbyadmin");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "hebattle_tag" , "hebattle_disabled");
}

public Action VoteHEbattle(int client,int args)
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
						}
						else CPrintToChatAll("%t %t", "hebattle_tag" , "hebattle_need", Missing, client);
					}
					else CPrintToChat(client, "%t %t", "hebattle_tag" , "hebattle_voted");
				}
				else CPrintToChat(client, "%t %t", "hebattle_tag" , "hebattle_wait", g_iCoolDown);
			}
			else CPrintToChat(client, "%t %t", "hebattle_tag" , "hebattle_progress" , EventDay);
		}
		else CPrintToChat(client, "%t %t", "hebattle_tag" , "hebattle_voting");
	}
	else CPrintToChat(client, "%t %t", "hebattle_tag" , "hebattle_disabled");
}

void StartNextRound()
{
	StartHEbattle = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;
	
	SetEventDay("hebattle");
	
	CPrintToChatAll("%t %t", "hebattle_tag" , "hebattle_next");
	PrintHintTextToAll("%t", "hebattle_next_nc");

}

public void RoundStart(Handle event, char[] name, bool dontBroadcast)
{
	if (StartHEbattle || IsHEbattle)
	{
		char info1[255], info2[255], info3[255], info4[255], info5[255], info6[255], info7[255], info8[255];
		
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_weapons_enable", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("mp_teammates_are_enemies", 1);
		SetCvar("sm_menu_enable", 0);
		IsHEbattle = true;

		g_iRound++;
		StartHEbattle = false;
		SJD_OpenDoors();
		HEbattleMenu = CreatePanel();
		Format(info1, sizeof(info1), "%T", "hebattle_info_title", LANG_SERVER);
		SetPanelTitle(HEbattleMenu, info1);
		DrawPanelText(HEbattleMenu, "                                   ");
		Format(info2, sizeof(info2), "%T", "hebattle_info_line1", LANG_SERVER);
		DrawPanelText(HEbattleMenu, info2);
		DrawPanelText(HEbattleMenu, "-----------------------------------");
		Format(info3, sizeof(info3), "%T", "hebattle_info_line2", LANG_SERVER);
		DrawPanelText(HEbattleMenu, info3);
		Format(info4, sizeof(info4), "%T", "hebattle_info_line3", LANG_SERVER);
		DrawPanelText(HEbattleMenu, info4);
		Format(info5, sizeof(info5), "%T", "hebattle_info_line4", LANG_SERVER);
		DrawPanelText(HEbattleMenu, info5);
		Format(info6, sizeof(info6), "%T", "hebattle_info_line5", LANG_SERVER);
		DrawPanelText(HEbattleMenu, info6);
		Format(info7, sizeof(info7), "%T", "hebattle_info_line6", LANG_SERVER);
		DrawPanelText(HEbattleMenu, info7);
		Format(info8, sizeof(info8), "%T", "hebattle_info_line7", LANG_SERVER);
		DrawPanelText(HEbattleMenu, info8);
		DrawPanelText(HEbattleMenu, "-----------------------------------");
		
		int RandomCT = 0;
		
		for(int client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client))
			{
				if (GetClientTeam(client) == CS_TEAM_CT)
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
			
			if (g_iRound > 0)
			{
				for(int client=1; client <= MaxClients; client++)
				{
					if (IsClientInGame(client))
					{
						
						if (gc_bGrav.BoolValue)
						{
							SetEntityGravity(client, gc_fGravValue.FloatValue);	
						}
						SendPanelToClient(HEbattleMenu, client, NullHandler, 15);
						SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
						StripAllWeapons(client);
						GivePlayerItem(client, "weapon_hegrenade");
						SetEntityHealth(client, 85);
						if (!gc_bSpawnCell.BoolValue)
						{
							TeleportEntity(client, Pos1, NULL_VECTOR, NULL_VECTOR);
						}
					}
				}
				g_iTruceTime--;
				TruceTimer = CreateTimer(1.0, HEbattle, _, TIMER_REPEAT);
				CPrintToChatAll("%t %t", "hebattle_tag" ,"hebattle_rounds", g_iRound, g_iMaxRound);
			}
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

public Action OnWeaponCanUse(int client, int weapon)
{
	if(IsHEbattle == true)
	{
		char sWeapon[32];
		GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));
		if(StrEqual(sWeapon, "weapon_hegrenade"))
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

public Action HE_Detonate(Handle event, const char[] name, bool dontBroadcast)
{
	if (IsHEbattle == true)
	{
		int  target = GetClientOfUserId(GetEventInt(event, "userid"));
		if (GetClientTeam(target) == 1 && !IsPlayerAlive(target))
		{
			return;
		}
		GivePlayerItem(target, "weapon_hegrenade");
	}
	return;
}

public Action HEbattle(Handle timer)
{
	if (g_iTruceTime > 1)
	{
		g_iTruceTime--;
		for (int client=1; client <= MaxClients; client++)
		if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				PrintCenterText(client,"%t", "hebattle_timeuntilstart_nc", g_iTruceTime);
			}
		return Plugin_Continue;
	}
	
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	if (g_iRound > 0)
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
	PrintHintTextToAll("%t", "hebattle_start_nc");
	CPrintToChatAll("%t %t", "hebattle_tag" , "hebattle_start");
	
	TruceTimer = null;
	
	return Plugin_Stop;
}

public void RoundEnd(Handle event, char[] name, bool dontBroadcast)
{
	int winner = GetEventInt(event, "winner");
	
	if (IsHEbattle)
	{
		for(int client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client)) SetEntityGravity(client, 1.0);
		}
		
		if (TruceTimer != null) KillTimer(TruceTimer);
		if (winner == 2) PrintHintTextToAll("%t", "hebattle_twin_nc");
		if (winner == 3) PrintHintTextToAll("%t", "hebattle_ctwin_nc");
		if (g_iRound == g_iMaxRound)
		{
			IsHEbattle = false;
			StartHEbattle = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_weapons_enable", 1);
			SetCvar("mp_teammates_are_enemies", 0);
			SetCvar("sm_warden_enable", 1);
			SetCvar("sm_menu_enable", 1);
			g_iGetRoundTime.IntValue = g_iOldRoundTime;
			SetEventDay("none");
			CPrintToChatAll("%t %t", "hebattle_tag" , "hebattle_end");
		}
	}
	if (StartHEbattle)
	{
		g_iOldRoundTime = g_iGetRoundTime.IntValue;
		g_iGetRoundTime.IntValue = gc_iRoundTime.IntValue;
	}
}

public void OnMapEnd()
{
	IsHEbattle = false;
	StartHEbattle = false;
	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
	SetEventDay("none");
}