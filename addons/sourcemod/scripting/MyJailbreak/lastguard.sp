/*
 * MyJailbreak - Last Guard Rule Plugin.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
 * 
 * Copyright (C) 2016-2017 Thomas Schmidt (shanapu)
 *
 * This file is part of the MyJailbreak SourceMod Plugin.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 */

/******************************************************************************
                   STARTUP
******************************************************************************/

// Includes
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <emitsoundany>
#include <colors>
#include <autoexecconfig>
#include <mystocks>

// Optional Plugins
#undef REQUIRE_PLUGIN
#include <myjailbreak>
#include <myweapons>
#include <hosties>
#include <lastrequest>
#include <smartjaildoors>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Booleans
bool g_bIsLastGuard = false;
bool g_bAllowLastGuard = false;
bool g_bIsLR = false;
bool g_bMinCT = false;

bool gp_bMyJailBreak;
bool gp_bHosties;
bool gp_bSmartJailDoors;
bool gp_bMyWeapons;

// Console Variables
ConVar gc_bPlugin;
ConVar gc_bSetCT;
ConVar gc_bVote;
ConVar gc_bAutomatic;
ConVar gc_iMinCT;
ConVar gc_fBeaconTime;
ConVar gc_iTruceTime;
ConVar gc_iTime;
ConVar gc_iTimePerT;
ConVar gc_bFreeze;
ConVar gc_iHPmultipler;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar gc_bSounds;
ConVar gc_sSoundStartPath;
ConVar gc_sSoundLastCTPath;
ConVar gc_sCustomCommandLGR;

// Integers
int g_iTruceTime;
int g_iVoteCount;
int g_iCollision_Offset;

// Handles
Handle g_hTimerTruce;
Handle g_hTimerBeacon;
Handle gF_OnLastGuardStart;

// Strings
char g_sHasVoted[1500];
char g_sSoundStartPath[256];
char g_sSoundLastCTPath[256];
char g_sMyJBLogFile[PLATFORM_MAX_PATH];
char g_sOverlayStartPath[256];

// Info
public Plugin myinfo = {
	name = "MyJailbreak - Last Guard Rule",
	author = "shanapu",
	description = "Last Guard Rule for Jailbreak Server",
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
};

// Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.LastGuard.phrases");

	// Client Commands
	RegConsoleCmd("sm_lastguard", Command_VoteLastGuard, "Allows terrors to vote and last CT to set Last Guard Rule");	

	// AutoExecConfig
	AutoExecConfig_SetFile("LastGuard", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);

	AutoExecConfig_CreateConVar("sm_lastguard_version", MYJB_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_lastguard_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true, 0.0, true, 1.0);
	gc_sCustomCommandLGR = AutoExecConfig_CreateConVar("sm_lastguard_cmds", "lg, lgr, lastguardrule", "Set your custom chat command for Last Guard Rule(!lastguard (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_bSetCT = AutoExecConfig_CreateConVar("sm_lastguard_ct", "1", "0 - disabled, 1 - allow last CT to set Last Guard Rule", _, true, 0.0, true, 1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_lastguard_vote", "1", "0 - disabled, 1 - allow alive player to vote for Last Guard Rule", _, true, 0.0, true, 1.0);
	gc_bAutomatic = AutoExecConfig_CreateConVar("sm_lastguard_auto", "0", "0 - disabled, 1 - Last Guard Rule will start automatic if there is only 1 CT. Disables sm_lastguard_vote & sm_lastguard_ct.", _, true, 0.0, true, 1.0);
	gc_iMinCT = AutoExecConfig_CreateConVar("sm_lastguard_minct", "2", "How many Counter-Terrorist must be on Roundstart to enable LGR? ", _, true, 2.0);
	gc_iHPmultipler = AutoExecConfig_CreateConVar("sm_lastguard_hp", "50", "How many percent of the combined Terror Health the CT get? (3 terror alive with 100HP = 300HP / 50% = CT get 150HP)", _, true, 0.0);
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_lastguard_trucetime", "10", "Time in seconds players can't deal damage. Half of this time you are freezed", _, true, 8.0);
	gc_iTime = AutoExecConfig_CreateConVar("sm_lastguard_time", "5", "Time in minutes to end the last guard rule - 0 = keep original time", _, true, 0.0);
	gc_fBeaconTime = AutoExecConfig_CreateConVar("sm_lastguard_beacon_time", "300", "Time in seconds until the beacon turned on (set to 0 to disable)", _, true, 0.0);
	gc_iTimePerT = AutoExecConfig_CreateConVar("sm_lastguard_time_per_T", "60", "Time in seconds to add to sm_lastguard_time per living terror - 0 = no extra time per t", _, true, 0.0);
	gc_bFreeze = AutoExecConfig_CreateConVar("sm_lastguard_freeze", "0", "0 - disabled, 1 - Freeze all players the half of trucetime.", _, true, 0.0, true, 1.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_lastguard_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true, 0.1, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_lastguard_sounds_start", "music/MyJailbreak/start.mp3", "Path to the soundfile which should be played for LGR beginn.");
	gc_sSoundLastCTPath = AutoExecConfig_CreateConVar("sm_lastguard_sounds_beginn", "music/MyJailbreak/lastct.mp3", "Path to the soundfile which should be played for LGR anouncment.");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_lastguard_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true, 0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_lastguard_overlays_start", "overlays/MyJailbreak/start", "Path to the start Overlay DONT TYPE .vmt or .vft");

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_team", Event_PlayerTeamDeath);
	HookEvent("player_death", Event_PlayerTeamDeath);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundLastCTPath, OnSettingChanged);

	//Forward
	gF_OnLastGuardStart = CreateGlobalForward("MyJailbreak_OnLastGuardRuleStart", ET_Ignore);

	// Find
	g_iTruceTime = gc_iTruceTime.IntValue;
	gc_sOverlayStartPath.GetString(g_sOverlayStartPath, sizeof(g_sOverlayStartPath));
	gc_sSoundLastCTPath.GetString(g_sSoundLastCTPath, sizeof(g_sSoundLastCTPath));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));

	// Offsets
	g_iCollision_Offset = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");

	// Logs
	SetLogFile(g_sMyJBLogFile, "MyJB", "MyJailbreak");
}


// ConVarChange for Strings
public void OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sOverlayStartPath)
	{
		strcopy(g_sOverlayStartPath, sizeof(g_sOverlayStartPath), newValue);
		if (gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayStartPath);
	}
	else if (convar == gc_sSoundStartPath)
	{
		strcopy(g_sSoundStartPath, sizeof(g_sSoundStartPath), newValue);
		if (gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStartPath);
	}
	else if (convar == gc_sSoundLastCTPath)
	{
		strcopy(g_sSoundLastCTPath, sizeof(g_sSoundLastCTPath), newValue);
		if (gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundLastCTPath);
	}
}

public void OnAllPluginsLoaded()
{
	gp_bMyJailBreak = LibraryExists("myjailbreak");
	gp_bHosties = LibraryExists("hosties");
	gp_bSmartJailDoors = LibraryExists("smartjaildoors");
	gp_bMyWeapons = LibraryExists("myweapons");
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "myjailbreak"))
		gp_bMyJailBreak = false;

	if (StrEqual(name, "hosties"))
		gp_bHosties = false;

	if (StrEqual(name, "smartjaildoors"))
		gp_bSmartJailDoors = false;

	if (StrEqual(name, "myweapons"))
		gp_bMyWeapons = false;
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "myjailbreak"))
		gp_bMyJailBreak = true;

	if (StrEqual(name, "hosties"))
		gp_bHosties = true;

	if (StrEqual(name, "smartjaildoors"))
		gp_bSmartJailDoors = true;

	if (StrEqual(name, "myweapons"))
		gp_bMyWeapons = true;
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

// Voting for Last Guard Rule
public Action Command_VoteLastGuard(int client, int args)
{
	char steamid[24];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));

	if (gc_bPlugin.BoolValue && !gc_bAutomatic.BoolValue && g_bMinCT)
	{
		if (gc_bVote.BoolValue && (GetClientTeam(client) == CS_TEAM_T) && IsPlayerAlive(client))
		{
			if ((GetAlivePlayersCount(CS_TEAM_CT) == 1) && (GetAlivePlayersCount(CS_TEAM_T) > 1))
			{
				if (gp_bMyJailBreak)
				{
					if (MyJailbreak_IsEventDayRunning())
					{
						char EventDay[64];
						MyJailbreak_GetEventDayName(EventDay);
						
						CReplyToCommand(client, "%t %t", "lastguard_tag", "lastguard_progress", EventDay);
						return Plugin_Handled;
					}
				}
				if (!g_bIsLastGuard)
				{
					if (!g_bIsLR)
					{
						if (StrContains(g_sHasVoted, steamid, true) == -1)
						{
							int playercount = (GetAlivePlayersCount(CS_TEAM_T) / 2);
							g_iVoteCount++;
							int Missing = playercount - g_iVoteCount + 1;
							Format(g_sHasVoted, sizeof(g_sHasVoted), "%s, %s", g_sHasVoted, steamid);
							
							if (g_iVoteCount > playercount)
							{
								StartLastGuard();
								if (gp_bMyJailBreak) if (MyJailbreak_ActiveLogging()) LogToFileEx(g_sMyJBLogFile, "Last Guard Rule was started by voting");
							}
							else CPrintToChatAll("%t %t", "lastguard_tag", "lastguard_need", Missing, client);
						}
						else CReplyToCommand(client, "%t %t", "lastguard_tag", "lastguard_voted");
					}
					else CReplyToCommand(client, "%t %t", "lastguard_tag", "lastguard_lr");
				}
				else CReplyToCommand(client, "%t %t", "lastguard_tag", "lastguard_running");
			}
			else CReplyToCommand(client, "%t %t", "lastguard_tag", "lastguard_minplayer");
		}
		else if (gc_bSetCT.BoolValue && (GetClientTeam(client) == CS_TEAM_CT) && IsPlayerAlive(client))
		{
			if ((GetAlivePlayersCount(CS_TEAM_CT) == 1) && (GetAlivePlayersCount(CS_TEAM_T) > 1))
			{
				if (gp_bMyJailBreak)
				{
					if (MyJailbreak_IsEventDayRunning())
					{
						char EventDay[64];
						MyJailbreak_GetEventDayName(EventDay);
						
						CReplyToCommand(client, "%t %t", "lastguard_tag", "lastguard_progress", EventDay);
						return Plugin_Handled;
					}
				}
				if (!g_bIsLastGuard)
				{
					if (!g_bIsLR)
					{
						StartLastGuard();
						if (gp_bMyJailBreak) if (MyJailbreak_ActiveLogging()) LogToFileEx(g_sMyJBLogFile, "Last Guard Rule was started by last CT %L", client);
					}
					else CReplyToCommand(client, "%t %t", "lastguard_tag", "lastguard_lr");
				}
				else CReplyToCommand(client, "%t %t", "lastguard_tag", "lastguard_running");
			}
			else CReplyToCommand(client, "%t %t", "lastguard_tag", "lastguard_minplayer");
		}
		else CReplyToCommand(client, "%t %t", "lastguard_tag", "lastguard_notalive");
	}
	else CReplyToCommand(client, "%t %t", "lastguard_tag", "lastguard_disabled");

	return Plugin_Handled;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

// Initialize Event
public void Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	g_bIsLR = false;
	g_bIsLastGuard = false;
	g_bMinCT = false;
	g_iVoteCount = 0;
	g_bAllowLastGuard = false;

	CreateTimer(2.5, Timer_LastGuardBeginn);

	if (GetAlivePlayersCount(CS_TEAM_CT) >= gc_iMinCT.IntValue)
	{
		g_bMinCT = true;
	}
}

// Round End
public void Event_RoundEnd(Event event, char[] name, bool dontBroadcast)
{

	if (g_bIsLastGuard)
	{
		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
		{
			SetEntData(i, g_iCollision_Offset, 0, 4, true);
		}

		delete g_hTimerTruce;
		delete g_hTimerBeacon;

		int winner = event.GetInt("winner");
		if (winner == 2)
		{
			PrintCenterTextAll("%t", "lastguard_twin_nc");
		}
		if (winner == 3)
		{
			PrintCenterTextAll("%t", "lastguard_ctwin_nc");
		}

		if (gp_bMyJailBreak)
		{
			MyJailbreak_SetLastGuardRule(false);
		}
		
		if (gp_bMyWeapons)
		{
			MyWeapons_AllowTeam(CS_TEAM_T, false);
			MyWeapons_AllowTeam(CS_TEAM_CT, true);
		}

		if (gp_bHosties)
		{
			SetCvar("sm_hosties_lr", 1);
		}

		SetCvar("sm_warden_enable", 1);

		CPrintToChatAll("%t %t", "lastguard_tag", "lastguard_end");
	}

	Format(g_sHasVoted, sizeof(g_sHasVoted), "");

	g_bIsLastGuard = false;
	g_bAllowLastGuard = false;
	g_bIsLR = false;
}

// Check player count when player dies or change team
public void Event_PlayerTeamDeath(Event event, const char[] name, bool dontBroadcast)
{
	if (g_bAllowLastGuard)
	{
		CheckStatus();
	}
}

/******************************************************************************
                   FUNCTIONS
******************************************************************************/

// Prepare Event
void StartLastGuard()
{
	if (g_bAllowLastGuard)
	{
		g_bIsLastGuard = true;
		g_iVoteCount = 0;

		if (gp_bSmartJailDoors)
		{
			SJD_OpenDoors();
		}

		if (gp_bMyJailBreak)
		{
			MyJailbreak_SetLastGuardRule(true);

			Call_StartForward(gF_OnLastGuardStart);
			Call_Finish();

			if (gc_fBeaconTime.FloatValue > 0.0)
			{
				g_hTimerBeacon = CreateTimer(gc_fBeaconTime.FloatValue, Timer_BeaconOn, TIMER_FLAG_NO_MAPCHANGE);
			}
		}

		if (gp_bHosties)
		{
			SetCvar("sm_hosties_lr", 0);
		}

		if (gp_bMyWeapons)
		{
			MyWeapons_AllowTeam(CS_TEAM_T, true);
			MyWeapons_AllowTeam(CS_TEAM_CT, true);
		}

		SetCvar("sm_warden_enable", 0);

		int Tcount = (GetAlivePlayersCount(CS_TEAM_T)*gc_iTimePerT.IntValue);
		if (gc_iTime.IntValue != 0)
		{
			GameRules_SetProp("m_iRoundTime", (60+Tcount+(gc_iTime.IntValue*60)), 4, 0, true);
		}

		if (gc_bSounds.BoolValue)
		{
			CreateTimer(0.5, Timer_LastGuardSound);
		}

		int HPterrors = 0;
		int HPterBuffer = 0;

		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) if (IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T)
		{
			HPterBuffer = (GetClientHealth(i) + HPterrors);
			HPterrors = HPterBuffer;
			HPterBuffer = 0;

			SetEntityMoveType(i, MOVETYPE_WALK);

			SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);

			SetEntityRenderColor(i, 255, 255, 255, 255);

			CreateTimer(0.0, DeleteOverlay, GetClientUserId(i));

			if (gp_bHosties)
			{
				ChangeRebelStatus(i, true);
			}
		}

		int HPCT = RoundToCeil(HPterrors * (gc_iHPmultipler.FloatValue / 100.0));

		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
		{
			char info[64];

			Panel InfoPanel = new Panel();

			Format(info, sizeof(info), "%T", "lastguard_info_title", i);
			InfoPanel.SetTitle(info);

			InfoPanel.DrawText("                                   ");
			Format(info, sizeof(info), "%T", "lastguard_info_line1", i);
			InfoPanel.DrawText(info);
			InfoPanel.DrawText("-----------------------------------");
			Format(info, sizeof(info), "%T", "lastguard_info_line2", i);
			InfoPanel.DrawText(info);
			Format(info, sizeof(info), "%T", "lastguard_info_line3", i);
			InfoPanel.DrawText(info);
			Format(info, sizeof(info), "%T", "lastguard_info_line4", i);
			InfoPanel.DrawText(info);
			Format(info, sizeof(info), "%T", "lastguard_info_line5", i);
			InfoPanel.DrawText(info);
			Format(info, sizeof(info), "%T", "lastguard_info_line6", i);
			InfoPanel.DrawText(info);
			Format(info, sizeof(info), "%T", "lastguard_info_line7", i);
			InfoPanel.DrawText(info);
			InfoPanel.DrawText("-----------------------------------");

			Format(info, sizeof(info), "%T", "lastguard_close", i);
			InfoPanel.DrawItem(info);

			InfoPanel.Send(i, Handler_NullCancel, 20);

			SetEntData(i, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
			SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);

			if (gc_bFreeze.BoolValue)
			{
				SetEntityMoveType(i, MOVETYPE_NONE);
				SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 0.0);
			}

			if (IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_CT)
			{
				SetEntityHealth(i, HPCT);
				CPrintToChatAll("%t %t", "lastguard_tag", "lastguard_hp", GetAlivePlayersCount(CS_TEAM_T), HPterrors, i, HPCT);
			}
		}

		g_iTruceTime--;
		g_hTimerTruce = CreateTimer(1.0, Timer_TruceUntilStart, _, TIMER_REPEAT);

		CPrintToChatAll("%t %t", "lastguard_tag", "lastguard_startnow");
		PrintCenterTextAll("%t", "lastguard_startnow_nc");
	}
}

// check count for automatic 
void CheckStatus()
{
	if (gc_bPlugin.BoolValue && !g_bIsLR && !g_bIsLastGuard && gc_bAutomatic.BoolValue)
	{
		if ((GetAlivePlayersCount(CS_TEAM_CT) == 1) && (GetAlivePlayersCount(CS_TEAM_T) > 1) && !g_bIsLastGuard && !g_bIsLR && g_bMinCT)
		{
			if (gp_bMyJailBreak) if (MyJailbreak_IsEventDayRunning())
			return;

			StartLastGuard();
			if (gp_bMyJailBreak) if (MyJailbreak_ActiveLogging())
			{
				LogToFileEx(g_sMyJBLogFile, "Last Guard Rule was started automatic");
			}

			g_bMinCT = false;
		}
	}
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

// Prepare Plugin & modules
public void OnMapStart()
{
	g_iVoteCount = 0;
	g_bIsLastGuard = false;
	g_bIsLR = false;

	g_iTruceTime = gc_iTruceTime.IntValue;

	if (gc_bSounds.BoolValue)
	{
		PrecacheSoundAnyDownload(g_sSoundStartPath);   // Add sound to download and precache table
	}

	if (gc_bSounds.BoolValue)
	{
		PrecacheSoundAnyDownload(g_sSoundLastCTPath);   // Add sound to download and precache table
	}

	if (gc_bOverlays.BoolValue)
	{
		PrecacheDecalAnyDownload(g_sOverlayStartPath);   // Add overlay to download and precache table
	}
}

public void OnConfigsExecuted()
{
	g_iTruceTime = gc_iTruceTime.IntValue;

	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// Last guard rule
	gc_sCustomCommandLGR.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  // if command not already exist
		{
			RegConsoleCmd(sCommand, Command_VoteLastGuard, "Allows terrors to vote and last CT to set Last Guard Rule");	
		}
	}
}

// Map End
public void OnMapEnd()
{
	g_bIsLastGuard = false;
	g_bAllowLastGuard = false;

	delete g_hTimerTruce;

	g_iVoteCount = 0;
	g_sHasVoted[0] = '\0';

	if (gp_bMyJailBreak)
	{
		MyJailbreak_SetLastGuardRule(false);
	}
}

// Client Disconnect
public void OnClientDisconnect_Post(int client)
{
	if (g_bAllowLastGuard)CheckStatus();
}

// When a last request is available
public void OnAvailableLR(int Announced)
{
	g_bIsLR = true;

	delete g_hTimerBeacon;
}

/******************************************************************************
                   TIMER
******************************************************************************/

// Start Timer
public Action Timer_TruceUntilStart(Handle timer)
{
	if (g_iTruceTime > 1)
	{
		g_iTruceTime--;
		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) if (IsPlayerAlive(i))
		{
			if (gc_bFreeze.BoolValue && (g_iTruceTime <= (gc_iTruceTime.IntValue / 2)) && (GetEntityMoveType(i) == MOVETYPE_NONE))
			{
				SetEntityMoveType(i, MOVETYPE_WALK);
				SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
				PrintCenterText(i, "%t", "lastguard_movenow_nc", g_iTruceTime);
				CPrintToChat(i, "%t %t", "lastguard_tag", "lastguard_movenow");
			}

			PrintCenterTextAll("%t", "lastguard_timeuntilstart_nc", g_iTruceTime);
		}

		return Plugin_Continue;
	}

	g_iTruceTime = gc_iTruceTime.IntValue;

	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) if (IsPlayerAlive(i))
	{
		SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);

		if (gc_bOverlays.BoolValue)
		{
			ShowOverlay(i, g_sOverlayStartPath, 2.0);
		}

		FakeClientCommand(i, "sm_weapons");
	}

	if (gc_bSounds.BoolValue)
	{
		EmitSoundToAllAny(g_sSoundStartPath);
	}

	g_hTimerTruce = null;

	PrintCenterTextAll("%t", "lastguard_start_nc");
	CPrintToChatAll("%t %t", "lastguard_tag", "lastguard_start");

	return Plugin_Stop;
}

public Action Timer_LastGuardSound(Handle timer)
{
	EmitSoundToAllAny(g_sSoundLastCTPath);
}

public Action Timer_LastGuardBeginn(Handle timer)
{
	g_bAllowLastGuard = true;
}

public Action Timer_BeaconOn(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, false))
	{
		MyJailbreak_BeaconOn(i, 2.0);
	}

	g_hTimerBeacon = null;
}
