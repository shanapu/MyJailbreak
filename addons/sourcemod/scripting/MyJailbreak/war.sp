#include <cstrike>
#include <colors>
#include <sourcemod>
#include <smartjaildoors>
#include <warden>
#include <emitsoundany>
#include <autoexecconfig>
#include <myjailbreak>
#include <lastrequest>

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
ConVar gc_sCustomCommand;
ConVar gc_sAdminFlag;
ConVar gc_bAllowLR;

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
char g_sCustomCommand[64];
char g_sEventsLogFile[PLATFORM_MAX_PATH];
char g_sAdminFlag[32];
char g_sOverlayStartPath[256];

//Floats
float g_fPos[3];

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
	
	AutoExecConfig_CreateConVar("sm_war_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_war_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_sCustomCommand = AutoExecConfig_CreateConVar("sm_war_cmd", "TDM", "Set your custom chat command for Event voting. no need for sm_ or !");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_war_warden", "1", "0 - disabled, 1 - allow warden to set war round", _, true,  0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_war_admin", "1", "0 - disabled, 1 - allow admin/vip to set war round", _, true,  0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_war_flag", "g", "Set flag for admin/vip to set this Event Day.");
	gc_bVote = AutoExecConfig_CreateConVar("sm_war_vote", "1", "0 - disabled, 1 - allow player to vote for war", _, true,  0.0, true, 1.0);
	gc_bSpawnCell = AutoExecConfig_CreateConVar("sm_war_spawn", "0", "0 - teleport to ct and freeze, 1 - T teleport to CT spawn, 1 - standart spawn & cell doors auto open", _, true,  0.0, true, 1.0);
	gc_iRounds = AutoExecConfig_CreateConVar("sm_war_rounds", "3", "Rounds to play in a row", _, true, 1.0);
	gc_iFreezeTime = AutoExecConfig_CreateConVar("sm_war_freezetime", "30", "Time in seconds the Terrorists freezed - need sm_war_spawn 0", _, true,  0.0);
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_war_trucetime", "15", "Time after freezetime damage disbaled", _, true,  0.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_war_roundtime", "5", "Round time in minutes for a single war round", _, true,  1.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_war_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true,  0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_war_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true,  0.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_war_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true,  0.0, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_war_sounds_start", "music/MyJailbreak/start.mp3", "Path to the soundfile which should be played for start.");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_war_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true,  0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_war_overlays_start", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_bAllowLR = AutoExecConfig_CreateConVar("sm_war_allow_lr", "0" , "0 - disabled, 1 - enable LR for last round and end eventday", _, true, 0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sCustomCommand, OnSettingChanged);
	HookConVarChange(gc_sAdminFlag, OnSettingChanged);
	
	//FindConVar
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iMaxRound = gc_iRounds.IntValue;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iGetRoundTime = FindConVar("mp_roundtime");
	gc_sOverlayStartPath.GetString(g_sOverlayStartPath , sizeof(g_sOverlayStartPath));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
	gc_sCustomCommand.GetString(g_sCustomCommand , sizeof(g_sCustomCommand));
	gc_sAdminFlag.GetString(g_sAdminFlag , sizeof(g_sAdminFlag));
	
	SetLogFile(g_sEventsLogFile, "Events");
}

//ConVarChange for Strings

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sOverlayStartPath)
	{
		strcopy(g_sOverlayStartPath, sizeof(g_sOverlayStartPath), newValue);
		if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayStartPath);
	}
	else if(convar == gc_sAdminFlag)
	{
		strcopy(g_sAdminFlag, sizeof(g_sAdminFlag), newValue);
	}
	else if(convar == gc_sSoundStartPath)
	{
		strcopy(g_sSoundStartPath, sizeof(g_sSoundStartPath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStartPath);
	}
	else if(convar == gc_sCustomCommand)
	{
		strcopy(g_sCustomCommand, sizeof(g_sCustomCommand), newValue);
		char sBufferCMD[64];
		Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
		if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
			RegConsoleCmd(sBufferCMD, VoteWar, "Allows players to vote for a war");
	}
}

//Initialize Event

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
	if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayStartPath);
}

public void OnConfigsExecuted()
{
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iMaxRound = gc_iRounds.IntValue;
	
	char sBufferCMD[64];
	Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
	if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMD, VoteWar, "Allows players to vote for a war");
}

//Admin & Warden set Event

public Action SetWar(int client,int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if(client == 0)
		{
			StartNextRound();
			if(ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event war was started by groupvoting");
		}
		else if (warden_iswarden(client))
		{
			if (gc_bSetW.BoolValue)
			{
				if ((GetTeamClientCount(CS_TEAM_CT) > 0) && (GetTeamClientCount(CS_TEAM_T) > 0 ))
				{
					char EventDay[64];
					GetEventDayName(EventDay);
					
					if(StrEqual(EventDay, "none", false))
					{
						if (g_iCoolDown == 0)
						{
							StartNextRound();
							if(ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event war was started by warden %L", client);
						}
						else CPrintToChat(client, "%t %t", "war_tag" , "war_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "war_tag" , "war_progress" , EventDay);
				}
				else CPrintToChat(client, "%t %t", "war_tag" , "war_minplayer");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "war_setbywarden");
		}
		else if (CheckVipFlag(client,g_sAdminFlag))
		{
			if (gc_bSetA.BoolValue)
			{
				if ((GetTeamClientCount(CS_TEAM_CT) > 0) && (GetTeamClientCount(CS_TEAM_T) > 0 ))
				{
					char EventDay[64];
					GetEventDayName(EventDay);
					
					if(StrEqual(EventDay, "none", false))
					{
						if (g_iCoolDown == 0)
						{
							StartNextRound();
							if(ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event war was started by admin %L", client);
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

//Voting for Event

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
				GetEventDayName(EventDay);
				
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
								if(ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event war was started by voting");
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

//Prepare Event

void StartNextRound()
{
	StartWar = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;
	SetEventDayName("war");	
	SetEventDayPlanned(true);
	
	g_iOldRoundTime = g_iGetRoundTime.IntValue; //save original round time
	g_iGetRoundTime.IntValue = gc_iRoundTime.IntValue;//set event round time
	
	
	CPrintToChatAll("%t %t", "war_tag" , "war_next");
	PrintHintTextToAll("%t", "war_next_nc");
}

//Round start

public void Event_RoundStart(Handle event, char[] name, bool dontBroadcast)
{
	if (StartWar || IsWar)
	{
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_weapons_t", 1);
		SetCvar("sm_weapons_ct", 1);
		SetCvar("sm_menu_enable", 0);
		SetEventDayPlanned(false);
		SetEventDayRunning(true);
		g_iRound++;
		IsWar = true;
		StartWar = false;
		if (gc_bSpawnCell.BoolValue)
		{
			SJD_OpenDoors();
			g_iFreezeTime = 0;
		}
		
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
			GetClientAbsOrigin(RandomCT, g_fPos);
			
			g_fPos[2] = g_fPos[2] + 5;
			
			if (g_iRound > 0)
			{
				for(int client=1; client <= MaxClients; client++)
				{
					if (!gc_bSpawnCell.BoolValue || (gc_bSpawnCell.BoolValue && !SJD_IsCurrentMapConfigured)) //spawn Terrors to CT Spawn )
					{
						if (IsClientInGame(client))
						{
							TeleportEntity(client, g_fPos, NULL_VECTOR, NULL_VECTOR);
							SetEntityMoveType(client, MOVETYPE_NONE);
						}
					}
				}
				
				//enable lr on last round
				if (gc_bAllowLR.BoolValue)
				{
					if (g_iRound == g_iMaxRound)
					{
						SetCvar("sm_hosties_lr", 1);
					}
				}
				CPrintToChatAll("%t %t", "war_tag" ,"war_rounds", g_iRound, g_iMaxRound);
			}
			LoopClients(client)
			{
				CreateInfoPanel(client);
				
				SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
				SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
			
				if (GetClientTeam(client) == CS_TEAM_CT)
				{
					SetEntityMoveType(client, MOVETYPE_WALK);
					TeleportEntity(client, g_fPos, NULL_VECTOR, NULL_VECTOR);
				}
			}
			
			g_iFreezeTime--;
			
			if (!gc_bSpawnCell.BoolValue || (gc_bSpawnCell.BoolValue && !SJD_IsCurrentMapConfigured)) //spawn Terrors to CT Spawn )
			{
				FreezeTimer = CreateTimer(1.0, FreezedTimer, _, TIMER_REPEAT);
			}
			else
			{
				TruceTimer = CreateTimer(1.0, StartTimer, _, TIMER_REPEAT);
			}
		}
	}
	else
	{
		char EventDay[64];
		GetEventDayName(EventDay);
	
		if(!StrEqual(EventDay, "none", false))
		{
			g_iCoolDown = gc_iCooldownDay.IntValue + 1;
		}
		else if (g_iCoolDown > 0) g_iCoolDown--;
	}
}

public int OnAvailableLR(int Announced)
{
	if (IsWar && gc_bAllowLR.BoolValue)
	{
		LoopValidClients(client, false, true) 
		{
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
			
			StripAllWeapons(client);
			if (GetClientTeam(client) == CS_TEAM_CT)
			{
				FakeClientCommand(client, "sm_guns");
			}
			GivePlayerItem(client, "weapon_knife");
		}
		
		delete FreezeTimer;
		delete TruceTimer;
		
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
			SetEventDayName("none");
			SetEventDayRunning(false);
			CPrintToChatAll("%t %t", "war_tag" , "war_end");
		}
	}

}

stock void CreateInfoPanel(int client)
{
	//Create info Panel
	char info[255];

	WarMenu = CreatePanel();
	Format(info, sizeof(info), "%T", "war_info_title", client);
	SetPanelTitle(WarMenu, info);
	DrawPanelText(WarMenu, "                                   ");
	Format(info, sizeof(info), "%T", "war_info_line1", client);
	DrawPanelText(WarMenu, info);
	DrawPanelText(WarMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "war_info_line2", client);
	DrawPanelText(WarMenu, info);
	Format(info, sizeof(info), "%T", "war_info_line3", client);
	DrawPanelText(WarMenu, info);
	Format(info, sizeof(info), "%T", "war_info_line4", client);
	DrawPanelText(WarMenu, info);
	Format(info, sizeof(info), "%T", "war_info_line5", client);
	DrawPanelText(WarMenu, info);
	Format(info, sizeof(info), "%T", "war_info_line6", client);
	DrawPanelText(WarMenu, info);
	Format(info, sizeof(info), "%T", "war_info_line7", client);
	DrawPanelText(WarMenu, info);
	DrawPanelText(WarMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "warden_close", client);
	DrawPanelItem(WarMenu, info); 
	SendPanelToClient(WarMenu, client, Handler_NullCancel, 20);
}
//Round End

public void Event_RoundEnd(Handle event, char[] name, bool dontBroadcast)
{
	int winner = GetEventInt(event, "winner");
	
	if (IsWar)
	{
		LoopValidClients(client, false, true) SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
		
		delete FreezeTimer;
		delete TruceTimer;
		
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
			SetEventDayName("none");
			SetEventDayRunning(false);
			CPrintToChatAll("%t %t", "war_tag" , "war_end");
		}
	}
	if (StartWar)
	{
		LoopClients(i) CreateInfoPanel(i);
		
		CPrintToChatAll("%t %t", "war_tag" , "war_next");
		PrintHintTextToAll("%t", "war_next_nc");
	}
}

//Map End

public void OnMapEnd()
{
	IsWar = false;
	StartWar = false;
	delete FreezeTimer;
	delete TruceTimer;
	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
}

//Freeze Timer

public Action FreezedTimer(Handle timer)
{
	if (g_iFreezeTime > 1)
	{
		g_iFreezeTime--;
		
		PrintHintTextToAll("%t", "war_timetohide_nc", g_iFreezeTime);
		
		return Plugin_Continue;
	}
	
	g_fPos[2] = g_fPos[2] - 3;
	
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	
	if (g_iRound > 0)
	{
		LoopClients(client) if(IsPlayerAlive(client))
		{
			if (GetClientTeam(client) == CS_TEAM_T)
			{
				SetEntityMoveType(client, MOVETYPE_WALK);
				TeleportEntity(client, g_fPos, NULL_VECTOR, NULL_VECTOR);
			}
		}
	}
	FreezeTimer = null;
	TruceTimer = CreateTimer(1.0, StartTimer, _, TIMER_REPEAT);
	
	return Plugin_Stop;
}

//Start Timer

public Action StartTimer(Handle timer)
{
	if (g_iTruceTime > 1)
	{
		g_iTruceTime--;
		
		PrintHintTextToAll("%t", "war_damage_nc", g_iTruceTime);
		
		return Plugin_Continue;
	}
	
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	
	
	LoopClients(client) if(IsPlayerAlive(client)) 
	{
		SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
		if(gc_bOverlays.BoolValue) ShowOverlay(client, g_sOverlayStartPath, 2.0);
		if(gc_bSounds.BoolValue)
		{
			EmitSoundToAllAny(g_sSoundStartPath);
		}
		PrintHintText(client,"%t", "war_start_nc");
	}
	CPrintToChatAll("%t %t", "war_tag" , "war_start");
	TruceTimer = null;
	return Plugin_Stop;
}
