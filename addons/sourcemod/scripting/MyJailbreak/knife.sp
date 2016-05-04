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
bool IsKnifeFight; 
bool StartKnifeFight; 

//ConVars
ConVar gc_bPlugin;
ConVar gc_bSetW;
ConVar gc_bGrav;
ConVar gc_fGravValue;
ConVar gc_bIce;
ConVar gc_bThirdPerson;
ConVar gc_fIceValue;
ConVar gc_iCooldownStart;
ConVar gc_bSetA;
ConVar gc_bSpawnCell;
ConVar gc_bVote;
ConVar gc_iCooldownDay;
ConVar gc_iRoundTime;
ConVar gc_iTruceTime;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar gc_bSounds;
ConVar gc_sSoundStartPath;
ConVar g_iSetRoundTime;
ConVar g_bAllowTP;
ConVar gc_iRounds;

//Integers
int g_iOldRoundTime;
int g_iCoolDown;
int g_iTruceTime;
int g_iVoteCount;
int g_iRound;
int g_iMaxRound;

//Floats
float Pos[3];

//Handles
Handle TruceTimer;
Handle KnifeFightMenu;

//Strings
char g_sHasVoted[1500];
char g_sSoundStartPath[256];

public Plugin myinfo = {
	name = "MyJailbreak - KnifeFight",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = PLUGIN_VERSION,
	url = URL_LINK
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.KnifeFight.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_setknifefight", SetKnifeFight, "Allows the Admin or Warden to set knifefight as next round");
	RegConsoleCmd("sm_knifefight", VoteKnifeFight, "Allows players to vote for a knifefight");
	
	//AutoExecConfig
	AutoExecConfig_SetFile("KnifeFight", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_knifefight_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_knifefight_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_bSetW = AutoExecConfig_CreateConVar("sm_knifefight_warden", "1", "0 - disabled, 1 - allow warden to set knifefight round", _, true,  0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_knifefight_admin", "1", "0 - disabled, 1 - allow admin to set knifefight round", _, true,  0.0, true, 1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_knifefight_vote", "1", "0 - disabled, 1 - allow player to vote for knifefight", _, true,  0.0, true, 1.0);
	gc_bSpawnCell = AutoExecConfig_CreateConVar("sm_knifefight_spawn", "0", "0 - T teleport to CT spawn, 1 - cell doors auto open", _, true,  0.0, true, 1.0);
	gc_iRounds = AutoExecConfig_CreateConVar("sm_knifefight_rounds", "1", "Rounds to play in a row", _, true, 1.0);
	gc_bThirdPerson = AutoExecConfig_CreateConVar("sm_knifefight_thirdperson", "1", "0 - disabled, 1 - enable thirdperson", _, true,  0.0, true, 1.0);
	gc_bGrav = AutoExecConfig_CreateConVar("sm_knifefight_gravity", "1", "0 - disabled, 1 - enable low gravity", _, true,  0.0, true, 1.0);
	gc_fGravValue= AutoExecConfig_CreateConVar("sm_knifefight_gravity_value", "0.3","Ratio for Gravity 1.0 earth 0.5 moon", _, true, 0.1, true, 1.0);
	gc_bIce = AutoExecConfig_CreateConVar("sm_knifefight_iceskate", "1", "0 - disabled, 1 - enable iceskate", _, true,  0.0, true, 1.0);
	gc_fIceValue= AutoExecConfig_CreateConVar("sm_knifefight_iceskate_value", "c","Ratio iceskate (5.2 normal)", _, true, 0.1, true, 5.2);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_knifefight_roundtime", "5", "Round time in minutes for a single knifefight round", _, true, 1.0);
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_knifefight_trucetime", "15", "Time in seconds players can't deal damage", _, true, 0.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_knifefight_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true, 0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_knifefight_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true, 0.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_knifefight_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true, 0.0, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_knifefight_sounds_start", "music/myjailbreak/start.mp3", "Path to the soundfile which should be played for a start.");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_knifefight_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true,  0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_knifefight_overlays_start", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("round_end", RoundEnd);
	HookEvent("player_death", PlayerDeath);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	
	//Find
	g_bAllowTP = FindConVar("sv_allow_thirdperson");
	g_iSetRoundTime = FindConVar("mp_roundtime");
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;
	gc_sOverlayStartPath.GetString(g_sOverlayStart , sizeof(g_sOverlayStart));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
	
	if(g_bAllowTP == INVALID_HANDLE)
	{
		SetFailState("sv_allow_thirdperson not found!");
	}
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
	IsKnifeFight = false;
	StartKnifeFight = false;
	
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

public Action SetKnifeFight(int client,int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (warden_iswarden(client))
		{
			if (gc_bSetW.BoolValue)
			{
				if ((GetTeamClientCount(CS_TEAM_CT) > 0) && (GetTeamClientCount(CS_TEAM_T) > 0 ))
				{
					char EventDay[64];
					GetEventDay(EventDay);
					
					if(StrEqual(EventDay, "none", false))
					{
						if (g_iCoolDown == 0)
						{
							StartNextRound();
						}
						else CPrintToChat(client, "%t %t", "knifefight_tag" , "knifefight_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "knifefight_tag" , "knifefight_progress" , EventDay);
				}
				else CPrintToChat(client, "%t %t", "knifefight_tag" , "knifefight_minplayer");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "knifefight_setbywarden");
		}
		else if (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
			{
				if (gc_bSetA.BoolValue)
				{
					if ((GetTeamClientCount(CS_TEAM_CT) > 0) && (GetTeamClientCount(CS_TEAM_T) > 0 ))
					{
						char EventDay[64];
						GetEventDay(EventDay);
						
						if(StrEqual(EventDay, "none", false))
						{
							if (g_iCoolDown == 0)
							{
								StartNextRound();
							}
							else CPrintToChat(client, "%t %t", "knifefight_tag" , "knifefight_wait", g_iCoolDown);
						}
						else CPrintToChat(client, "%t %t", "knifefight_tag" , "knifefight_progress" , EventDay);
					}
					else CPrintToChat(client, "%t %t", "knifefight_tag" , "knifefight_minplayer");
				}
				else CPrintToChat(client, "%t %t", "knifefight_tag" , "knifefight_setbyadmin");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "knifefight_tag" , "knifefight_disabled");
}

public Action VoteKnifeFight(int client,int args)
{
	char steamid[64];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bVote.BoolValue)
		{
			if ((GetTeamClientCount(CS_TEAM_CT) > 0) && (GetTeamClientCount(CS_TEAM_T) > 0 ))
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
							else CPrintToChatAll("%t %t", "knifefight_tag" , "knifefight_need", Missing, client);
						}
						else CPrintToChat(client, "%t %t", "knifefight_tag" , "knifefight_voted");
					}
					else CPrintToChat(client, "%t %t", "knifefight_tag" , "knifefight_wait", g_iCoolDown);
				}
				else CPrintToChat(client, "%t %t", "knifefight_tag" , "knifefight_progress" , EventDay);
			}
			else CPrintToChat(client, "%t %t", "knifefight_tag" , "knifefight_minplayer");
		}
		else CPrintToChat(client, "%t %t", "knifefight_tag" , "knifefight_voting");
	}
	else CPrintToChat(client, "%t %t", "knifefight_tag" , "knifefight_disabled");
}

void StartNextRound()
{
	StartKnifeFight = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;
	
	SetEventDay("knifefight");
	
	CPrintToChatAll("%t %t", "knifefight_tag" , "knifefight_next");
	PrintHintTextToAll("%t", "knifefight_next_nc");

}

public void RoundStart(Handle event, char[] name, bool dontBroadcast)
{
	if (StartKnifeFight || IsKnifeFight)
	{
		char info1[255], info2[255], info3[255], info4[255], info5[255], info6[255], info7[255], info8[255];
		
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_weapons_enable", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_menu_enable", 0);
		SetCvar("mp_teammates_are_enemies", 1);
		SetConVarInt(g_bAllowTP, 1);
		IsKnifeFight = true;
		
		g_iRound++;
		StartKnifeFight = false;
		SJD_OpenDoors();
		KnifeFightMenu = CreatePanel();
		Format(info1, sizeof(info1), "%T", "knifefight_info_title", LANG_SERVER);
		SetPanelTitle(KnifeFightMenu, info1);
		DrawPanelText(KnifeFightMenu, "                                   ");
		Format(info2, sizeof(info2), "%T", "knifefight_info_line1", LANG_SERVER);
		DrawPanelText(KnifeFightMenu, info2);
		DrawPanelText(KnifeFightMenu, "-----------------------------------");
		Format(info3, sizeof(info3), "%T", "knifefight_info_line2", LANG_SERVER);
		DrawPanelText(KnifeFightMenu, info3);
		Format(info4, sizeof(info4), "%T", "knifefight_info_line3", LANG_SERVER);
		DrawPanelText(KnifeFightMenu, info4);
		Format(info5, sizeof(info5), "%T", "knifefight_info_line4", LANG_SERVER);
		DrawPanelText(KnifeFightMenu, info5);
		Format(info6, sizeof(info6), "%T", "knifefight_info_line5", LANG_SERVER);
		DrawPanelText(KnifeFightMenu, info6);
		Format(info7, sizeof(info7), "%T", "knifefight_info_line6", LANG_SERVER);
		DrawPanelText(KnifeFightMenu, info7);
		Format(info8, sizeof(info8), "%T", "knifefight_info_line7", LANG_SERVER);
		DrawPanelText(KnifeFightMenu, info8);
		DrawPanelText(KnifeFightMenu, "-----------------------------------");
		
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
						if (gc_bIce.BoolValue)
						{
							SetCvarFloat("sv_friction", gc_fIceValue.FloatValue);
						}
						if (gc_bThirdPerson.BoolValue && IsValidClient(client, false, false))
						{
							ClientCommand(client, "thirdperson");
						}
						SendPanelToClient(KnifeFightMenu, client, NullHandler, 15);
						SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
						StripAllWeapons(client);
						GivePlayerItem(client, "weapon_knife");
						if (!gc_bSpawnCell.BoolValue)
						{
							TeleportEntity(client, Pos1, NULL_VECTOR, NULL_VECTOR);
						}
					}
				}
				g_iTruceTime--;
				TruceTimer = CreateTimer(1.0, KnifeFight, _, TIMER_REPEAT);
				CPrintToChatAll("%t %t", "knifefight_tag" ,"knifefight_rounds", g_iRound, g_iMaxRound);
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
	if(IsKnifeFight == true)
	{
		char sWeapon[32];
		GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));
		if(StrEqual(sWeapon, "weapon_knife"))
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

public Action KnifeFight(Handle timer)
{
	if (g_iTruceTime > 1)
	{
		g_iTruceTime--;
		for (int client=1; client <= MaxClients; client++)
		if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				PrintCenterText(client,"%t", "knifefight_timeuntilstart_nc", g_iTruceTime);
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
				PrintCenterText(client,"%t", "knifefight_start_nc");
			}
			if(gc_bOverlays.BoolValue) CreateTimer( 0.0, ShowOverlayStart, client);
			if(gc_bSounds.BoolValue)	
			{
				EmitSoundToAllAny(g_sSoundStartPath);
			}
			
			CPrintToChatAll("%t %t", "knifefight_tag" , "knifefight_start");
		}
	}
	
	TruceTimer = null;
	
	return Plugin_Stop;
}

public void RoundEnd(Handle event, char[] name, bool dontBroadcast)
{
	int winner = GetEventInt(event, "winner");
	
	if (IsKnifeFight)
	{
		for(int client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client))
			{
				SetEntityGravity(client, 1.0);
				FP(client);
			}
		}
		if (TruceTimer != null) KillTimer(TruceTimer);
		if (winner == 2) PrintHintTextToAll("%t", "knifefight_twin_nc");
		if (winner == 3) PrintHintTextToAll("%t", "knifefight_ctwin_nc");
		if (g_iRound == g_iMaxRound)
		{
			IsKnifeFight = false;
			StartKnifeFight = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_weapons_enable", 1);
			SetCvar("sm_warden_enable", 1);
			SetCvar("sm_menu_enable", 0);
			SetCvar("mp_teammates_are_enemies", 0);
			SetCvarFloat("sv_friction", 5.2);
			SetConVarInt(g_bAllowTP, 0);
			
			g_iSetRoundTime.IntValue = g_iOldRoundTime;
			SetEventDay("none");
			CPrintToChatAll("%t %t", "knifefight_tag" , "knifefight_end");
		}
	}
	if (StartKnifeFight)
	{
		g_iOldRoundTime = g_iSetRoundTime.IntValue;
		g_iSetRoundTime.IntValue = gc_iRoundTime.IntValue;
	}
}

public Action FP(int client)
{
	if(IsValidClient(client, false, false))
	{
		ClientCommand(client, "firstperson");
	}
}

public void OnClientDisconnect(int client)
{
	if (IsKnifeFight == true)
	{
		FP(client);
	}
}

public void PlayerDeath(Handle event, char [] name, bool dontBroadcast)
{
	if(IsKnifeFight == true)
	{
		int client = GetClientOfUserId(GetEventInt(event, "userid"));
		FP(client);
	}
}

public void OnMapEnd()
{
	IsKnifeFight = false;
	StartKnifeFight = false;
	if (TruceTimer != null) KillTimer(TruceTimer);
	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
	SetEventDay("none");
	for(int client=1; client <= MaxClients; client++)
	{
		FP(client);
	}
}