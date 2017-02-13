/*
 * MyJailbreak - Deal Damage Event Day Plugin.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
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
#include <hosties>
#include <lastrequest>
#include <warden>
#include <myjailbreak>
#include <smartjaildoors>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Booleans
bool g_bIsLateLoad = false;
bool g_bIsTruce = false;
bool g_bIsDealDamage = false;
bool g_bStartDealDamage = false;

// Plugin bools
bool gp_bWarden;
bool gp_bHosties;
bool gp_bSmartJailDoors;
bool gp_bMyJailbreak;

// Console Variables    gc_i = global convar integer / gc_b = global convar bool ...
ConVar gc_bPlugin;
ConVar gc_bSetW;
ConVar gc_iCooldownStart;
ConVar gc_bSetA;
ConVar gc_bSetABypassCooldown;
ConVar gc_bSpawnCell;
ConVar gc_bVote;
ConVar gc_fBeaconTime;
ConVar gc_iCooldownDay;
ConVar gc_iRoundTime;
ConVar gc_iTruceTime;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar gc_bSounds;
ConVar gc_iRounds;
ConVar gc_sSoundStartPath;
ConVar gc_sCustomCommandVote;
ConVar gc_sCustomCommandSet;
ConVar gc_bChat;
ConVar gc_bConsole;
ConVar gc_bShowPanel;
ConVar gc_bSpawnRandom;
ConVar gc_sAdminFlag;

// Extern Convars
ConVar g_iMPRoundTime;
ConVar g_bHUD;

// Integers    g_i = global integer
int g_iOldRoundTime;
int g_iOldHUD;
int g_iCoolDown;
int g_iTruceTime;
int g_iVoteCount;
int g_iRound;
int g_iMaxRound;
int g_iDamageCT;
int g_iDamageT;
int g_iDamageDealed[MAXPLAYERS+1];
int g_iBestT = -1;
int g_iBestCT = -1;
int g_iBestTdamage = 0;
int g_iBestCTdamage = 0;
int g_iBestPlayer = -1;
int g_iTotalDamage = 0;
int g_iCollision_Offset;

// Floats    g_i = global float
float g_fPos[3];

// Handles
Handle g_hTimerTruce;
Handle g_hTimerRound;
Handle g_hTimerBeacon;

// Strings    g_s = global string
char g_sHasVoted[1500];
char g_sSoundStartPath[256];
char g_sEventsLogFile[PLATFORM_MAX_PATH];
char g_sAdminFlag[32];
char g_sOverlayStartPath[256];

// Info
public Plugin myinfo = {
	name = "MyJailbreak - DealDamage",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = MYJB_VERSION,
	url = MYJB_URL_LINK
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_bIsLateLoad = late;

	return APLRes_Success;
}

// Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.DealDamage.phrases");

	// Client Commands
	RegConsoleCmd("sm_setdealdamage", Command_SetDealDamage, "Allows the Admin or Warden to set dealdamage as next round");
	RegConsoleCmd("sm_dealdamage", Command_VoteDealDamage, "Allows players to vote for a dealdamage");

	// AutoExecConfig
	AutoExecConfig_SetFile("DealDamage", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);

	AutoExecConfig_CreateConVar("sm_dealdamage_version", MYJB_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_dealdamage_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true, 0.0, true, 1.0);
	gc_sCustomCommandVote = AutoExecConfig_CreateConVar("sm_dealdamage_cmds_vote", "dd, damage, deal", "Set your custom chat command for Event voting(!dealdamage (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandSet = AutoExecConfig_CreateConVar("sm_dealdamage_cmds_set", "sdd, sdeal, sdamage", "Set your custom chat command for set Event(!setdealdamage (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_dealdamage_warden", "1", "0 - disabled, 1 - allow warden to set dealdamage round", _, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_dealdamage_admin", "1", "0 - disabled, 1 - allow admin/vip to set dealdamage round", _, true, 0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_dealdamage_flag", "g", "Set flag for admin/vip to set this Event Day.");
	gc_bVote = AutoExecConfig_CreateConVar("sm_dealdamage_vote", "1", "0 - disabled, 1 - allow player to vote for dealdamage", _, true, 0.0, true, 1.0);
	gc_bSpawnCell = AutoExecConfig_CreateConVar("sm_dealdamage_spawn", "1", "0 - T teleport to CT spawn, 1 - cell doors auto open", _, true, 0.0, true, 1.0);
	gc_bSpawnRandom = AutoExecConfig_CreateConVar("sm_dealdamage_randomspawn", "1", "0 - disabled, 1 - use random spawns on map (sm_dealdamage_spawn 1)", _, true, 0.0, true, 1.0);
	gc_bShowPanel = AutoExecConfig_CreateConVar("sm_dealdamage_panel", "1", "0 - disabled, 1 - enable show results on a Panel", _, true, 0.0, true, 1.0);
	gc_bChat = AutoExecConfig_CreateConVar("sm_dealdamage_chat", "1", "0 - disabled, 1 - enable print results in chat", _, true, 0.0, true, 1.0);
	gc_bConsole = AutoExecConfig_CreateConVar("sm_dealdamage_console", "1", "0 - disabled, 1 - enable print results in client console", _, true, 0.0, true, 1.0);
	gc_iRounds = AutoExecConfig_CreateConVar("sm_dealdamage_rounds", "2", "Rounds to play in a row", _, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_dealdamage_roundtime", "2", "Round time in minutes for a single dealdamage round", _, true, 1.0);
	gc_fBeaconTime = AutoExecConfig_CreateConVar("sm_dealdamage_beacon_time", "90", "Time in seconds until the beacon turned on (set to 0 to disable)", _, true, 0.0);
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_dealdamage_trucetime", "15", "Time in seconds players can't deal damage", _, true, 0.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_dealdamage_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true, 0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_dealdamage_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true, 0.0);
	gc_bSetABypassCooldown = AutoExecConfig_CreateConVar("sm_dealdamage_cooldown_admin", "1", "0 - disabled, 1 - ignore the cooldown when admin/vip set dealdamage round", _, true, 0.0, true, 1.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_dealdamage_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true, 0.1, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_dealdamage_sounds_start", "music/MyJailbreak/start.mp3", "Path to the soundfile which should be played for a start.");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_dealdamage_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true, 0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_dealdamage_overlays_start", "overlays/MyJailbreak/start", "Path to the start Overlay DONT TYPE .vmt or .vft");

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sAdminFlag, OnSettingChanged);

	// Find
	g_iMPRoundTime = FindConVar("mp_roundtime");
	gc_sOverlayStartPath.GetString(g_sOverlayStartPath, sizeof(g_sOverlayStartPath));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
	gc_sAdminFlag.GetString(g_sAdminFlag, sizeof(g_sAdminFlag));

	// Offsets
	g_iCollision_Offset = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");

	// Logs
	SetLogFile(g_sEventsLogFile, "Events", "MyJailbreak");

	// Late loading
	if (g_bIsLateLoad)
	{
		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
		{
			OnClientPutInServer(i);
		}

		g_bIsLateLoad = false;
	}
}

// ConVarChange for Strings
public void OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sOverlayStartPath)    // Add overlay to download and precache table if changed
	{
		strcopy(g_sOverlayStartPath, sizeof(g_sOverlayStartPath), newValue);
		if (gc_bOverlays.BoolValue)
		{
			PrecacheDecalAnyDownload(g_sOverlayStartPath);
		}
	}
	else if (convar == gc_sSoundStartPath)    // Add sound to download and precache table if changed
	{
		strcopy(g_sSoundStartPath, sizeof(g_sSoundStartPath), newValue);
		if (gc_bSounds.BoolValue)
		{
			PrecacheSoundAnyDownload(g_sSoundStartPath);
		}
	}
	else if (convar == gc_sAdminFlag)
	{
		strcopy(g_sAdminFlag, sizeof(g_sAdminFlag), newValue);
	}
}

public void OnAllPluginsLoaded()
{
	gp_bWarden = LibraryExists("warden");
	gp_bHosties = LibraryExists("lastrequest");
	gp_bSmartJailDoors = LibraryExists("smartjaildoors");
	gp_bMyJailbreak = LibraryExists("myjailbreak");
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "warden"))
		gp_bWarden = false;

	if (StrEqual(name, "lastrequest"))
		gp_bHosties = false;

	if (StrEqual(name, "smartjaildoors"))
		gp_bSmartJailDoors = false;

	if (StrEqual(name, "myjailbreak"))
		gp_bMyJailbreak = false;
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "warden"))
		gp_bWarden = true;

	if (StrEqual(name, "lastrequest"))
		gp_bHosties = true;

	if (StrEqual(name, "smartjaildoors"))
		gp_bSmartJailDoors = true;

	if (StrEqual(name, "myjailbreak"))
		gp_bMyJailbreak = true;
}

// Initialize Plugin
public void OnConfigsExecuted()
{
	// Find Convar Times
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iMaxRound = gc_iRounds.IntValue;

	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// Vote
	gc_sCustomCommandVote.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  // if command not already exist
		{
			RegConsoleCmd(sCommand, Command_VoteDealDamage, "Allows players to vote for a dealdamage");
		}
	}

	// Set
	gc_sCustomCommandSet.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  // if command not already exist
		{
			RegConsoleCmd(sCommand, Command_SetDealDamage, "Allows the Admin or Warden to set dealdamage as next round");
		}
	}
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

// Admin & Warden set Event
public Action Command_SetDealDamage(int client, int args)
{
	if (!gc_bPlugin.BoolValue)
	{
		CReplyToCommand(client, "%t %t", "dealdamage_tag", "dealdamage_disabled");
		return Plugin_Handled;
	}

	if (client == 0) // Called by a server/voting
	{
		StartNextRound();

		if (!gp_bMyJailbreak)
		{
			return Plugin_Handled;
		}

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Deal Damage was started by groupvoting");
		}
	}
	else if (CheckVipFlag(client, g_sAdminFlag)) // Called by admin/VIP
	{
		if (!gc_bSetA.BoolValue)
		{
			CReplyToCommand(client, "%t %t", "dealdamage_tag", "dealdamage_setbyadmin");
			return Plugin_Handled;
		}

		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				CReplyToCommand(client, "%t %t", "dealdamage_tag", "dealdamage_progress", EventDay);
				return Plugin_Handled;
			}
		}

		if (g_iCoolDown > 0 && !gc_bSetABypassCooldown.BoolValue)
		{
			CReplyToCommand(client, "%t %t", "dealdamage_tag", "dealdamage_wait", g_iCoolDown);
			return Plugin_Handled;
		}

		StartNextRound();

		if (!gp_bMyJailbreak)
		{
			return Plugin_Handled;
		}

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Deal Damage was started by admin %L", client);
		}
	}
	else if (gp_bWarden) // Called by warden
	{
		if (!warden_iswarden(client))
		{
			CReplyToCommand(client, "%t %t", "warden_tag", "warden_notwarden");
			return Plugin_Handled;
		}

		if (!gc_bSetW.BoolValue)
		{
			CReplyToCommand(client, "%t %t", "warden_tag", "dealdamage_setbywarden");
			return Plugin_Handled;
		}

		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				CReplyToCommand(client, "%t %t", "dealdamage_tag", "dealdamage_progress", EventDay);
				return Plugin_Handled;
			}
		}

		if (g_iCoolDown > 0)
		{
			CReplyToCommand(client, "%t %t", "dealdamage_tag", "dealdamage_wait", g_iCoolDown);
			return Plugin_Handled;
		}

		StartNextRound();

		if (!gp_bMyJailbreak)
		{
			return Plugin_Handled;
		}

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Deal Damage was started by warden %L", client);
		}
	}
	else
	{
		CReplyToCommand(client, "%t %t", "warden_tag", "warden_notwarden");
	}

	return Plugin_Handled;
}

// Voting for Event
public Action Command_VoteDealDamage(int client, int args)
{
	if (!gc_bPlugin.BoolValue)
	{
		CReplyToCommand(client, "%t %t", "dealdamage_tag", "dealdamage_disabled");
		return Plugin_Handled;
	}

	if (!gc_bVote.BoolValue)
	{
		CReplyToCommand(client, "%t %t", "dealdamage_tag", "dealdamage_voting");
		return Plugin_Handled;
	}

	if (gp_bMyJailbreak)
	{
		char EventDay[64];
		MyJailbreak_GetEventDayName(EventDay);

		if (!StrEqual(EventDay, "none", false))
		{
			CReplyToCommand(client, "%t %t", "dealdamage_tag", "dealdamage_progress", EventDay);
			return Plugin_Handled;
		}
	}

	if (g_iCoolDown > 0)
	{
		CReplyToCommand(client, "%t %t", "dealdamage_tag", "dealdamage_wait", g_iCoolDown);
		return Plugin_Handled;
	}

	char steamid[24];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));

	if (StrContains(g_sHasVoted, steamid, true) != -1)
	{
		CReplyToCommand(client, "%t %t", "dealdamage_tag", "dealdamage_voted");
		return Plugin_Handled;
	}

	int playercount = (GetClientCount(true) / 2);
	g_iVoteCount += 1;

	int Missing = playercount - g_iVoteCount + 1;
	Format(g_sHasVoted, sizeof(g_sHasVoted), "%s, %s", g_sHasVoted, steamid);

	if (g_iVoteCount > playercount)
	{
		StartNextRound();

		if (!gp_bMyJailbreak)
		{
			return Plugin_Handled;
		}

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Deal Damage was started by voting");
		}
	}
	else
	{
		CPrintToChatAll("%t %t", "dealdamage_tag", "dealdamage_need", Missing, client);
	}

	return Plugin_Handled;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

// Round start
public void Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	if (!g_bStartDealDamage && !g_bIsDealDamage)
	{
		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				g_iCoolDown = gc_iCooldownDay.IntValue + 1;
			}
			else if (g_iCoolDown > 0)
			{
				g_iCoolDown -= 1;
			}
		}
		else if (g_iCoolDown > 0)
		{
			g_iCoolDown -= 1;
		}

		return;
	}

	if (gp_bWarden)
	{
		SetCvar("sm_warden_enable", 0);
	}

	if (gp_bHosties)
	{
		SetCvar("sm_hosties_lr", 0);
	}

	SetCvar("sm_weapons_enable", 1);
	SetCvar("sm_weapons_t", 1);
	SetCvar("sm_weapons_ct", 1);
	SetCvar("sm_menu_enable", 0);
	SetCvar("sm_hud_enable", 0);

	if (gp_bMyJailbreak)
	{
		MyJailbreak_SetEventDayPlanned(false);
		MyJailbreak_SetEventDayRunning(true, 0);

		if (gc_fBeaconTime.FloatValue > 0.0)
		{
			g_hTimerBeacon = CreateTimer(gc_fBeaconTime.FloatValue, Timer_BeaconOn, TIMER_FLAG_NO_MAPCHANGE);
		}
	}

	g_iBestT = 0;
	g_iBestCT = 0;
	g_iBestTdamage = 0;
	g_iBestCTdamage = 0;
	g_iBestPlayer = 0;
	g_iDamageCT = 0;
	g_iDamageT = 0;
	g_iTotalDamage = 0;

	float RoundTime = (gc_iRoundTime.FloatValue*60-5);
	g_hTimerRound = CreateTimer (RoundTime, Timer_EndTheRound);

	g_bIsDealDamage = true;
	g_bIsTruce = true;
	g_bStartDealDamage = false;
	g_iRound += 1; // Add Round number

	if (!gc_bSpawnCell.BoolValue || !gp_bSmartJailDoors || (gc_bSpawnCell.BoolValue && (SJD_IsCurrentMapConfigured() != true))) // spawn Terrors to CT Spawn 
	{
		int RandomCT = 0;
		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
		{
			if (GetClientTeam(i) == CS_TEAM_CT)
			{
				RandomCT = i;
				break;
			}
		}

		if (RandomCT)
		{
			for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
			{
				GetClientAbsOrigin(RandomCT, g_fPos);
				
				g_fPos[2] = g_fPos[2] + 5;
				
				TeleportEntity(i, g_fPos, NULL_VECTOR, NULL_VECTOR);
			}
		}
	}

	if (g_iRound > 0)
	{
		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
		{
			SetEntData(i, g_iCollision_Offset, 2, 4, true); // NoBlock
			CreateInfoPanel(i);
			SetEntProp(i, Prop_Data, "m_takedamage", 0, 1); // disable damage
			g_iDamageDealed[i] = 0;
		}

		// Set Start Timer
		g_iTruceTime -= 1;
		g_hTimerTruce = CreateTimer(1.0, Timer_StartEvent, _, TIMER_REPEAT);
		CPrintToChatAll("%t %t", "dealdamage_tag", "dealdamage_rounds", g_iRound, g_iMaxRound);
	}
}

// Round End
public void Event_RoundEnd(Event event, char[] name, bool dontBroadcast)
{
	if (g_bIsDealDamage) // if event was running this round
	{
		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
		{
			SetEntData(i, g_iCollision_Offset, 0, 4, true); // disbale noblock
		}

		delete g_hTimerTruce; // kill start time if still running
		delete g_hTimerBeacon;

		int winner = event.GetInt("winner");
		if (winner == 2)
		{
			PrintCenterTextAll("%t", "dealdamage_twin_nc", g_iDamageT);
		}
		if (winner == 3)
		{
			PrintCenterTextAll("%t", "dealdamage_ctwin_nc", g_iDamageCT);
		}

		if (g_iRound == g_iMaxRound) // if this was the last round
		{
			// return to default start values
			g_bIsDealDamage = false;
			g_bStartDealDamage = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");

			if (gp_bHosties)
			{
				SetCvar("sm_hosties_lr", 1);
			}

			if (gp_bWarden)
			{
				SetCvar("sm_warden_enable", 1);
			}

			if (gc_bSpawnRandom.BoolValue)
			{
				SetCvar("mp_randomspawn", 0);
				SetCvar("mp_randomspawn_los", 0);
			}

			SetCvar("sm_weapons_enable", 1);
			SetCvar("sv_infinite_ammo", 0);
			SetCvar("sm_menu_enable", 1);
			SetCvar("sm_weapons_t", 0);
			SetCvar("sm_hud_enable", g_iOldHUD);

			g_iMPRoundTime.IntValue = g_iOldRoundTime; // return to original round time

			if (gp_bMyJailbreak)
			{
				MyJailbreak_SetEventDayRunning(false, winner);
				MyJailbreak_SetEventDayName("none"); // tell myjailbreak event is ended
			}

			CPrintToChatAll("%t %t", "dealdamage_tag", "dealdamage_end");
		}
	}

	if (g_bStartDealDamage)
	{
		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
		{
			CreateInfoPanel(i);
		}

		CPrintToChatAll("%t %t", "dealdamage_tag", "dealdamage_next");
		PrintCenterTextAll("%t", "dealdamage_next_nc");
	}
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

// Initialize Event
public void OnMapStart()
{
	// set default start values
	g_iVoteCount = 0; // how many player voted for the event
	g_iRound = 0;
	g_bIsDealDamage = false;
	g_bStartDealDamage = false;

	// Precache Sound & Overlay
	if (gc_bSounds.BoolValue)
	{
		PrecacheSoundAnyDownload(g_sSoundStartPath);
	}

	if (gc_bOverlays.BoolValue)
	{
		PrecacheDecalAnyDownload(g_sOverlayStartPath);
	}
}

// Map End
public void OnMapEnd()
{
	// return to default start values
	g_bIsDealDamage = false;
	g_bStartDealDamage = false;

	delete g_hTimerTruce; // kill start time if still running
	delete g_hTimerRound; // kill start time if still running
	delete g_hTimerBeacon;

	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
}

// Set Client Hook
public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakedamage);
}

public Action OnTakedamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if (!IsValidClient(victim, true, false) || attacker == victim || !IsValidClient(attacker, true, false) || !g_bIsDealDamage)
		return Plugin_Continue;

	if ((GetClientTeam(attacker) == CS_TEAM_CT) && (GetClientTeam(victim) == CS_TEAM_T) && !g_bIsTruce)
	{
		g_iDamageCT = g_iDamageCT + RoundToCeil(damage);
	}

	if ((GetClientTeam(attacker) == CS_TEAM_T) && (GetClientTeam(victim) == CS_TEAM_CT) && !g_bIsTruce)
	{
		g_iDamageT = g_iDamageT + RoundToCeil(damage);
	}

	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
	{
		PrintHintText(i, "<font face='Arial' color='#0055FF'>%t  </font> %i %t \n<font face='Arial' color='#FF0000'>%t  </font> %i %t \n<font face='Arial' color='#00FF00'>%t  </font> %i %t", "dealdamage_ctdealed", g_iDamageCT, "dealdamage_hpdamage", "dealdamage_tdealed", g_iDamageT, "dealdamage_hpdamage", "dealdamage_clientdealed", g_iDamageDealed[i], "dealdamage_hpdamage");
	}

	if ((GetClientTeam(attacker) != GetClientTeam(victim)))
	{
		g_iDamageDealed[attacker] = g_iDamageDealed[attacker] + RoundToCeil(damage);
	}

	return Plugin_Handled;
}

/******************************************************************************
                   FUNCTIONS
******************************************************************************/

// Prepare Event
void StartNextRound()
{
	g_bStartDealDamage = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;

	if (gp_bMyJailbreak)
	{
		char buffer[32];
		Format(buffer, sizeof(buffer), "%T", "dealdamage_name", LANG_SERVER);
		MyJailbreak_SetEventDayName(buffer);
		MyJailbreak_SetEventDayPlanned(true);
	}

	g_iOldRoundTime = g_iMPRoundTime.IntValue; // save original round time
	g_iMPRoundTime.IntValue = gc_iRoundTime.IntValue; // set event round time

	g_bHUD = FindConVar("sm_hud_enable");
	g_iOldHUD = g_bHUD.IntValue;

	if (gc_bSpawnRandom.BoolValue)
	{
		SetCvar("mp_randomspawn", 1);
		SetCvar("mp_randomspawn_los", 1);
	}

	CPrintToChatAll("%t %t", "dealdamage_tag", "dealdamage_next");
	PrintCenterTextAll("%t", "dealdamage_next_nc");
}

/******************************************************************************
                   MENUS
******************************************************************************/

void CreateInfoPanel(int client)
{
	// Create info Panel
	char info[255];

	Panel InfoPanel = new Panel();

	Format(info, sizeof(info), "%T", "dealdamage_info_title", client);
	InfoPanel.SetTitle(info);

	InfoPanel.DrawText("                                   ");
	Format(info, sizeof(info), "%T", "dealdamage_info_line1", client);
	InfoPanel.DrawText(info);
	InfoPanel.DrawText("-----------------------------------");
	Format(info, sizeof(info), "%T", "dealdamage_info_line2", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "dealdamage_info_line3", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "dealdamage_info_line4", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "dealdamage_info_line5", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "dealdamage_info_line6", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "dealdamage_info_line7", client);
	InfoPanel.DrawText(info);
	InfoPanel.DrawText("-----------------------------------");

	Format(info, sizeof(info), "%T", "warden_close", client);
	InfoPanel.DrawItem(info);

	InfoPanel.Send(client, Handler_NullCancel, 20); // open info Panel
}

void SendResults(int client)
{
	char info[128];

	Panel InfoPanel = new Panel();
	Format(info, sizeof(info), "%t", "dealdamage_result");
	InfoPanel.SetTitle(info);

	if (gc_bConsole.BoolValue) PrintToConsole(client, info);
	Format(info, sizeof(info), "%t %t", "dealdamage_tag", "dealdamage_result");
	if (gc_bChat.BoolValue) CPrintToChat(client, info);
	InfoPanel.DrawText("                                   ");
	Format(info, sizeof(info), "%t", "dealdamage_total", g_iTotalDamage);
	InfoPanel.DrawText(info);
	if (gc_bConsole.BoolValue) PrintToConsole(client, info);
	Format(info, sizeof(info), "%t %t", "dealdamage_tag", "dealdamage_total", g_iTotalDamage);
	if (gc_bChat.BoolValue) CPrintToChat(client, info);
	Format(info, sizeof(info), "%t", "dealdamage_most", g_iBestPlayer, g_iDamageDealed[g_iBestPlayer]);
	InfoPanel.DrawText(info);
	if (gc_bConsole.BoolValue) PrintToConsole(client, info);
	Format(info, sizeof(info), "%t %t", "dealdamage_tag", "dealdamage_most", g_iBestPlayer, g_iDamageDealed[g_iBestPlayer]);
	if (gc_bChat.BoolValue) CPrintToChat(client, info);
	InfoPanel.DrawText("                                   ");
	Format(info, sizeof(info), "%t", "dealdamage_ct", g_iDamageCT);
	InfoPanel.DrawText(info);
	if (gc_bConsole.BoolValue) PrintToConsole(client, info);
	Format(info, sizeof(info), "%t %t", "dealdamage_tag", "dealdamage_ct", g_iDamageCT);
	if (gc_bChat.BoolValue) CPrintToChat(client, info);
	Format(info, sizeof(info), "%t", "dealdamage_t", g_iDamageT);
	InfoPanel.DrawText(info);
	if (gc_bConsole.BoolValue) PrintToConsole(client, info);
	Format(info, sizeof(info), "%t %t", "dealdamage_tag", "dealdamage_t", g_iDamageT);
	if (gc_bChat.BoolValue) CPrintToChat(client, info);
	InfoPanel.DrawText("                                   ");
	Format(info, sizeof(info), "%t", "dealdamage_bestct", g_iBestCT, g_iBestCTdamage);
	InfoPanel.DrawText(info);
	if (gc_bConsole.BoolValue) PrintToConsole(client, info);
	Format(info, sizeof(info), "%t %t", "dealdamage_tag", "dealdamage_bestct", g_iBestCT, g_iBestCTdamage);
	if (gc_bChat.BoolValue) CPrintToChat(client, info);
	Format(info, sizeof(info), "%t", "dealdamage_bestt", g_iBestT, g_iBestTdamage);
	InfoPanel.DrawText(info);
	if (gc_bConsole.BoolValue) PrintToConsole(client, info);
	Format(info, sizeof(info), "%t %t", "dealdamage_tag", "dealdamage_bestt", g_iBestT, g_iBestTdamage);
	if (gc_bChat.BoolValue) CPrintToChat(client, info);
	Format(info, sizeof(info), "%t", "dealdamage_client", g_iDamageDealed[client]);
	InfoPanel.DrawText(info);
	if (gc_bConsole.BoolValue) PrintToConsole(client, info);
	InfoPanel.DrawText("                                   ");
	Format(info, sizeof(info), "%t %t", "dealdamage_tag", "dealdamage_client", g_iDamageDealed[client]);
	if (gc_bChat.BoolValue) CPrintToChat(client, info);

	if (gc_bShowPanel.BoolValue) InfoPanel.Send(client, Handler_NullCancel, 20); // open info Panel
}

/******************************************************************************
                   TIMER
******************************************************************************/

// Start Timer
public Action Timer_StartEvent(Handle timer)
{
	if (g_iTruceTime > 1) // countdown to start
	{
		g_iTruceTime--;

		PrintCenterTextAll("%t", "dealdamage_timeuntilstart_nc", g_iTruceTime);

		return Plugin_Continue;
	}

	g_iTruceTime = gc_iTruceTime.IntValue;

	if (g_iRound > 0)
	{
		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
		{
			if (IsPlayerAlive(i))
			{
				SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);
			}

			if (gc_bOverlays.BoolValue)
			{
				ShowOverlay(i, g_sOverlayStartPath, 2.0);
			}
		}

		if (gc_bSounds.BoolValue)
		{
			EmitSoundToAllAny(g_sSoundStartPath);
		}

		PrintCenterTextAll("%t", "dealdamage_start_nc");
		CPrintToChatAll("%t %t", "dealdamage_tag", "dealdamage_start");
	}

	g_hTimerTruce = null;
	g_bIsTruce = false;

	return Plugin_Stop;
}

public Action Timer_BeaconOn(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, false))
	{
		MyJailbreak_BeaconOn(i, 2.0);
	}

	g_hTimerBeacon = null;
}

public Action Timer_EndTheRound(Handle timer)
{
	if (g_iDamageCT > g_iDamageT) 
	{
		CS_TerminateRound(5.0, CSRoundEnd_CTWin);

		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) if (GetClientTeam(i) == CS_TEAM_T)
		{
			ForcePlayerSuicide(i);
		}
	}
	else if (g_iDamageCT < g_iDamageT) 
	{
		CS_TerminateRound(5.0, CSRoundEnd_TerroristWin);

		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) if (GetClientTeam(i) == CS_TEAM_CT)
		{
			ForcePlayerSuicide(i);
		}
	}
	else
	{
		CS_TerminateRound(5.0, CSRoundEnd_Draw);
	}

	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
	{
		if (GetClientTeam(i) == CS_TEAM_CT && (g_iDamageDealed[i] > g_iBestCTdamage))
		{
			g_iBestCTdamage = g_iDamageDealed[i];
			g_iBestCT = i;
		}

		if (GetClientTeam(i) == CS_TEAM_T && (g_iDamageDealed[i] > g_iBestTdamage))
		{
			g_iBestTdamage = g_iDamageDealed[i];
			g_iBestT = i;
		}
	}

	if (g_iBestCTdamage > g_iBestTdamage)
	{
		g_iBestPlayer = g_iBestCT;
	}
	else g_iBestPlayer = g_iBestT;

	g_iTotalDamage = g_iDamageCT + g_iDamageT;

	for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, true))
	{
		SendResults(i);
	}

	g_hTimerRound = null;
	delete g_hTimerRound;

	if (MyJailbreak_ActiveLogging())
	{
		LogToFileEx(g_sEventsLogFile, "Damage Deal Result: g_iBestCT: %N Dmg: %i g_iBestT: %N Dmg: %i CT Damage: %i T Damage: %i Total Damage: %i", g_iBestCT, g_iBestCTdamage, g_iBestT, g_iBestTdamage, g_iDamageCT, g_iDamageT, g_iTotalDamage);
	}
}