#include <cstrike>
#include <colors>
#include <sourcemod>

#include <smartjaildoors>
#include <wardn>
#include <emitsoundany>
#include <autoexecconfig>
#include <myjailbreak>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//Booleans
bool IsWar;
bool StartWar;

//ConVars
ConVar gc_bPlugin;
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_bVote;
ConVar gc_bSpawnCell;
ConVar gc_iRounds;
ConVar gc_iRoundTime;
ConVar gc_iCooldownDay;
ConVar gc_iCooldownStart;
ConVar gc_iFreezeTime;
ConVar gc_iTruceTime;
ConVar gc_bSounds;
ConVar gc_sSoundStartPath;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar g_iGetRoundTime;

//Integers
int g_iOldRoundTime;
int g_iCoolDown;
int g_iFreezeTime;
int g_iTruceTime;
int g_iVoteCount;
int g_iRound;
int g_iMaxRound;

//Handles
Handle FreezeTimer;
Handle TruceTimer;
Handle WarMenu;

//Strings
char g_sHasVoted[1500];
char g_sSoundStartPath[256];

//Floats
float Pos[3];

public Plugin myinfo = {
	name = "MyJailbreak - War",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = PLUGIN_VERSION,
	url = URL_LINK
};

public void OnPluginStart()
{
	//Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.War.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_setwar", SetWar, "Allows the Admin or Warden to set a war for next rounds");
	RegConsoleCmd("sm_war", VoteWar, "Allows players to vote for a war");
	
	//AutoExecConfig
	AutoExecConfig_SetFile("Warfare", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_war_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_war_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_bSetW = AutoExecConfig_CreateConVar("sm_war_warden", "1", "0 - disabled, 1 - allow warden to set war round", _, true,  0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_war_admin", "1", "0 - disabled, 1 - allow admin to set war round", _, true,  0.0, true, 1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_war_vote", "1", "0 - disabled, 1 - allow player to vote for war", _, true,  0.0, true, 1.0);
	gc_bSpawnCell = AutoExecConfig_CreateConVar("sm_war_spawn", "0", "0 - teleport to ct and freeze, 1 - T teleport to CT spawn, 1 - standart spawn & cell doors auto open", _, true,  0.0, true, 1.0);
	gc_iRounds = AutoExecConfig_CreateConVar("sm_war_rounds", "3", "Rounds to play in a row", _, true, 1.0);
	gc_iFreezeTime = AutoExecConfig_CreateConVar("sm_war_freezetime", "30", "Time in seconds the terrorist freezed - need sm_war_spawn 0", _, true,  0.0);
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_war_trucetime", "15", "Time after freezetime damage disbaled", _, true,  0.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_war_roundtime", "5", "Round time in minutes for a single war round", _, true,  1.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_war_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true,  0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_war_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true,  0.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_war_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true,  0.0, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_war_sounds_start", "music/myjailbreak/start.mp3", "Path to the soundfile which should be played for start.");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_war_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true,  0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_war_overlays_start", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("round_end", RoundEnd);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	
	//FindConVar
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iMaxRound = gc_iRounds.IntValue;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iGetRoundTime = FindConVar("mp_roundtime");
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
	IsWar = false;
	StartWar = false;
	
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStartPath);
	if(gc_bOverlays.BoolValue) PrecacheOverlayAnyDownload(g_sOverlayStart);
}

public void OnConfigsExecuted()
{
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iMaxRound = gc_iRounds.IntValue;
}

public Action SetWar(int client,int args)
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
						else CPrintToChat(client, "%t %t", "war_tag" , "war_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "war_tag" , "war_progress" , EventDay);
				}
				else CPrintToChat(client, "%t %t", "war_tag" , "war_minplayer");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "war_setbywarden");
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
							else CPrintToChat(client, "%t %t", "war_tag" , "war_wait", g_iCoolDown);
						}
						else CPrintToChat(client, "%t %t", "war_tag" , "war_progress" , EventDay);
					}
					else CPrintToChat(client, "%t %t", "war_tag" , "war_minplayer");
				}
				else CPrintToChat(client, "%t %t", "war_tag" , "war_setbyadmin");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden"); 
	}
	else CPrintToChat(client, "%t %t", "war_tag" , "war_disabled");
}

public Action VoteWar(int client,int args)
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
							
							if(g_iVoteCount > playercount)
							{
								StartNextRound();
							}
							else CPrintToChatAll("%t %t", "war_tag" , "war_need", Missing, client);
						}
						else CPrintToChat(client, "%t %t", "war_tag" , "war_voted");
					}
					else CPrintToChat(client, "%t %t", "war_tag" , "war_wait", g_iCoolDown);
				}
				else CPrintToChat(client, "%t %t", "war_tag" , "war_progress" , EventDay);
			}
			else CPrintToChat(client, "%t %t", "war_tag" , "war_minplayer");
		}
		else CPrintToChat(client, "%t %t", "war_tag" , "war_voting");
	}
	else CPrintToChat(client, "%t %t", "war_tag" , "war_disabled");
}

void StartNextRound()
{
	StartWar = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;
	SetEventDay("war");
	
	CPrintToChatAll("%t %t", "war_tag" , "war_next");
	PrintHintTextToAll("%t", "war_next_nc");
}

public void RoundStart(Handle event, char[] name, bool dontBroadcast)
{
	if (StartWar || IsWar)
	{
		char info1[255], info2[255], info3[255], info4[255], info5[255], info6[255], info7[255], info8[255];
		
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_weapons_t", 1);
		SetCvar("sm_weapons_ct", 1);
		SetCvar("sm_menu_enable", 0);
		g_iRound++;
		IsWar = true;
		StartWar = false;
		if (gc_bSpawnCell.BoolValue)
		{
			SJD_OpenDoors();
			g_iFreezeTime = 0;
		}
		WarMenu = CreatePanel();
		Format(info1, sizeof(info1), "%T", "war_info_title", LANG_SERVER);
		SetPanelTitle(WarMenu, info1);
		DrawPanelText(WarMenu, "                                   ");
		Format(info2, sizeof(info2), "%T", "war_info_line1", LANG_SERVER);
		DrawPanelText(WarMenu, info2);
		DrawPanelText(WarMenu, "-----------------------------------");
		Format(info3, sizeof(info3), "%T", "war_info_line2", LANG_SERVER);
		DrawPanelText(WarMenu, info3);
		Format(info4, sizeof(info4), "%T", "war_info_line3", LANG_SERVER);
		DrawPanelText(WarMenu, info4);
		Format(info5, sizeof(info5), "%T", "war_info_line4", LANG_SERVER);
		DrawPanelText(WarMenu, info5);
		Format(info6, sizeof(info6), "%T", "war_info_line5", LANG_SERVER);
		DrawPanelText(WarMenu, info6);
		Format(info7, sizeof(info7), "%T", "war_info_line6", LANG_SERVER);
		DrawPanelText(WarMenu, info7);
		Format(info8, sizeof(info8), "%T", "war_info_line7", LANG_SERVER);
		DrawPanelText(WarMenu, info8);
		DrawPanelText(WarMenu, "-----------------------------------");
		
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
					if (!gc_bSpawnCell.BoolValue)
					{
						if (IsClientInGame(client))
						{
							TeleportEntity(client, Pos1, NULL_VECTOR, NULL_VECTOR);
							if (!gc_bSpawnCell.BoolValue)
							{
								SetEntityMoveType(client, MOVETYPE_NONE);
							}
						}
					}
				}
				CPrintToChatAll("%t %t", "war_tag" ,"war_rounds", g_iRound, g_iMaxRound);
			}
			for(int client=1; client <= MaxClients; client++)
			{
				if (IsClientInGame(client))
				{
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					SendPanelToClient(WarMenu, client, NullHandler, 15);
					SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
				}
			}
			
			g_iFreezeTime--;
			
			if (!gc_bSpawnCell.BoolValue)
			{
				FreezeTimer = CreateTimer(1.0, Freezed, _, TIMER_REPEAT);
			}
			else
			{
				TruceTimer = CreateTimer(1.0, NoDamage, _, TIMER_REPEAT);
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

public Action Freezed(Handle timer)
{
	if (g_iFreezeTime > 1)
	{
		g_iFreezeTime--;
		
		PrintHintTextToAll("%t", "war_timetohide_nc", g_iFreezeTime);
		
		return Plugin_Continue;
	}
	
	Pos[2] = Pos[2] - 45;
	
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	
	if (g_iRound > 0)
	{
		for (int client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				if (GetClientTeam(client) == CS_TEAM_T)
				{
					SetEntityMoveType(client, MOVETYPE_WALK);
					TeleportEntity(client, Pos, NULL_VECTOR, NULL_VECTOR);
				}
			}
		}
	}
	
	TruceTimer = CreateTimer(1.0, NoDamage, _, TIMER_REPEAT);
	FreezeTimer = null;
	return Plugin_Stop;
}

public Action NoDamage(Handle timer)
{
	if (g_iTruceTime > 1)
	{
		g_iTruceTime--;
		
		PrintHintTextToAll("%t", "war_damage_nc", g_iTruceTime);
		
		return Plugin_Continue;
	}
	
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	
	
	for(int client=1; client <= MaxClients; client++) 
	{
		if (IsClientInGame(client) && IsPlayerAlive(client)) 
		{
			SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
			if(gc_bOverlays.BoolValue) CreateTimer( 0.0, ShowOverlayStart, client);
			if(gc_bSounds.BoolValue)	
			{
				EmitSoundToAllAny(g_sSoundStartPath);
			}
			CPrintToChatAll("%t %t", "war_tag" , "war_start");
			PrintCenterText(client,"%t", "war_start_nc");
		}
	}
	
	TruceTimer = null;
	return Plugin_Stop;
}

public void RoundEnd(Handle event, char[] name, bool dontBroadcast)
{
	int winner = GetEventInt(event, "winner");
	
	if (IsWar)
	{
		for(int client=1; client <= MaxClients; client++)
		{
			if (IsValidClient(client, false, true)) SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
		}
		
		if (FreezeTimer != null) KillTimer(FreezeTimer);
		if (TruceTimer != null) KillTimer(TruceTimer);
		if (winner == 2) PrintHintTextToAll("%t", "war_twin_nc"); 
		if (winner == 3) PrintHintTextToAll("%t", "war_ctwin_nc");
		if (g_iRound == g_iMaxRound)
		{
			IsWar = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_warden_enable", 1);
			SetCvar("sm_weapons_t", 0);
			SetCvar("sm_weapons_ct", 1);
			SetCvar("sm_menu_enable", 1);
			g_iGetRoundTime.IntValue = g_iOldRoundTime;
			SetEventDay("none");
			CPrintToChatAll("%t %t", "war_tag" , "war_end");
		}
	}
	if (StartWar)
	{
		g_iOldRoundTime = g_iGetRoundTime.IntValue;
		g_iGetRoundTime.IntValue = gc_iRoundTime.IntValue;
	}
}

public void OnMapEnd()
{
	IsWar = false;
	StartWar = false;
	if (FreezeTimer != null) KillTimer(FreezeTimer);
	if (TruceTimer != null) KillTimer(TruceTimer);
	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
	SetEventDay("none");
}