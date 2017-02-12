/*
 * MyJailbreak - Duckhunt Event Day Plugin.
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
 * this program. If not, see <http:// www.gnu.org/licenses/>.
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
#include <smlib>
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
bool g_bIsDuckHunt = false;
bool g_bStartDuckHunt = false;

// Plugin bools
bool gp_bWarden;
bool gp_bHosties;
bool gp_bSmartJailDoors;
bool gp_bMyJailbreak;

// Console Variables
ConVar gc_bPlugin;
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_bSetABypassCooldown;
ConVar gc_bVote;
ConVar gc_iHunterHP;
ConVar gc_iHunterHPincrease;
ConVar gc_iChickenHP;
ConVar gc_bFlyMode;
ConVar gc_bSounds;
ConVar gc_fBeaconTime;
ConVar gc_sSoundStartPath;
ConVar gc_iCooldownDay;
ConVar gc_iRoundTime;
ConVar gc_iCooldownStart;
ConVar gc_iTruceTime;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar gc_iRounds;
ConVar gc_sAdminFlag;
ConVar gc_bAllowLR;
ConVar gc_sCustomCommandVote;
ConVar gc_sCustomCommandSet;

// Extern Convars
ConVar g_iMPRoundTime;
ConVar g_iTerrorForLR;
ConVar g_bAllowTP;

// Integers
int g_iOldRoundTime;
int g_iCoolDown;
int g_iTruceTime;
int g_iVoteCount;
int g_iRound;
int g_iMaxRound;
int g_iTsLR;
int g_iCollision_Offset;

// Handles
Handle g_hTimerTruce;
Handle g_hTimerBeacon;

// Strings
char g_sHasVoted[1500];
char g_sSoundStartPath[256];
char g_sHunterModel[256] = "models/player/custom_player/legacy/tm_phoenix_heavy.mdl";
char g_sEventsLogFile[PLATFORM_MAX_PATH];
char g_sAdminFlag[32];
char g_sModelPathCTPrevious[MAXPLAYERS+1][256];
char g_sModelPathTPrevious[MAXPLAYERS+1][256];
char g_sOverlayStartPath[256];

// Info
public Plugin myinfo = {
	name = "MyJailbreak - DuckHunt",
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
	LoadTranslations("MyJailbreak.DuckHunt.phrases");

	// Client Commands
	RegConsoleCmd("sm_setduckhunt", Command_SetDuckHunt, "Allows the Admin or Warden to set duckhunt as next round");
	RegConsoleCmd("sm_duckhunt", Command_VoteDuckHunt, "Allows players to vote for a duckhunt");
	RegConsoleCmd("drop", Command_ToggleFly);

	// AutoExecConfig
	AutoExecConfig_SetFile("DuckHunt", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);

	AutoExecConfig_CreateConVar("sm_duckhunt_version", MYJB_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_duckhunt_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true, 0.0, true, 1.0);
	gc_sCustomCommandVote = AutoExecConfig_CreateConVar("sm_duckhunt_cmds_vote", "duck, hunt", "Set your custom chat command for Event voting(!duckhunt (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandSet = AutoExecConfig_CreateConVar("sm_duckhunt_cmds_set", "sduck, shunt, sduckhunt", "Set your custom chat command for set Event(!setduckhunt (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_duckhunt_warden", "1", "0 - disabled, 1 - allow warden to set duckhunt round", _, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_duckhunt_admin", "1", "0 - disabled, 1 - allow admin/vip to set duckhunt round", _, true, 0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_duckhunt_flag", "g", "Set flag for admin/vip to set this Event Day.");
	gc_bVote = AutoExecConfig_CreateConVar("sm_duckhunt_vote", "1", "0 - disabled, 1 - allow player to vote for duckhunt", _, true, 0.0, true, 1.0);
	gc_iRounds = AutoExecConfig_CreateConVar("sm_duckhunt_rounds", "1", "Rounds to play in a row", _, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_duckhunt_roundtime", "5", "Round time in minutes for a single duckhunt round", _, true, 1.0);
	gc_fBeaconTime = AutoExecConfig_CreateConVar("sm_duckhunt_beacon_time", "240", "Time in seconds until the beacon turned on (set to 0 to disable)", _, true, 0.0);
	gc_bFlyMode = AutoExecConfig_CreateConVar("sm_duckhunt_flymode", "1", "0 - Low gravity, 1 - 'Flymode' (like a slow noclip with clipping). Bit difficult", _, true, 0.0, true, 1.0);
	gc_iHunterHP = AutoExecConfig_CreateConVar("sm_duckhunt_hunter_hp", "850", "HP the hunters got on Spawn", _, true, 1.0);
	gc_iHunterHPincrease = AutoExecConfig_CreateConVar("sm_duckhunt_hunter_hp_extra", "100", "HP the Hunter get additional per extra duck", _, true, 1.0);
	gc_iChickenHP = AutoExecConfig_CreateConVar("sm_duckhunt_chicken_hp", "100", "HP the chicken got on Spawn", _, true, 1.0);
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_duckhunt_trucetime", "15", "Time in seconds until cells open / players can't deal damage", _, true, 0.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_duckhunt_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true, 0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_duckhunt_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true, 0.0);
	gc_bSetABypassCooldown = AutoExecConfig_CreateConVar("sm_duckhunt_cooldown_admin", "1", "0 - disabled, 1 - ignore the cooldown when admin/vip set duckhunt round", _, true, 0.0, true, 1.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_duckhunt_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true, 0.0, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_duckhunt_sounds_start", "music/MyJailbreak/duckhunt.mp3", "Path to the soundfile which should be played for start");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_duckhunt_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true, 0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_duckhunt_overlays_start", "overlays/MyJailbreak/start", "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_bAllowLR = AutoExecConfig_CreateConVar("sm_duckhunt_allow_lr", "0", "0 - disabled, 1 - enable LR for last round and end eventday", _, true, 0.0, true, 1.0);

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("weapon_reload", Event_WeaponReload);
	HookEvent("hegrenade_detonate", Event_HE_Detonate);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sAdminFlag, OnSettingChanged);

	// FindConVar
	g_bAllowTP = FindConVar("sv_allow_thirdperson");
	g_iMPRoundTime = FindConVar("mp_roundtime");
	gc_sOverlayStartPath.GetString(g_sOverlayStartPath, sizeof(g_sOverlayStartPath));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
	gc_sAdminFlag.GetString(g_sAdminFlag, sizeof(g_sAdminFlag));

	// Offsets
	g_iCollision_Offset = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");

	if (g_bAllowTP == INVALID_HANDLE)
	{
		SetFailState("sv_allow_thirdperson not found!");
	}
	
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
	if (convar == gc_sOverlayStartPath)
	{
		strcopy(g_sOverlayStartPath, sizeof(g_sOverlayStartPath), newValue);
		if (gc_bOverlays.BoolValue)
		{
			PrecacheDecalAnyDownload(g_sOverlayStartPath);
		}
	}
	else if (convar == gc_sSoundStartPath)
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
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iMaxRound = gc_iRounds.IntValue;

	// FindConVar
	if (gp_bHosties)
	{
		g_iTerrorForLR = FindConVar("sm_hosties_lr_ts_max");
	}

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
			RegConsoleCmd(sCommand, Command_VoteDuckHunt, "Allows players to vote for a duckhunt");
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
			RegConsoleCmd(sCommand, Command_SetDuckHunt, "Allows the Admin or Warden to set duckhunt as next round");
		}
	}
}

/******************************************************************************
                   COMMANDS
******************************************************************************/

// Admin & Warden set Event
public Action Command_SetDuckHunt(int client, int args)
{
	if (!gc_bPlugin.BoolValue)
	{
		CReplyToCommand(client, "%t %t", "duckhunt_tag", "duckhunt_disabled");
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
			LogToFileEx(g_sEventsLogFile, "Event duckhunt was started by groupvoting");
		}
	}
	else if (CheckVipFlag(client, g_sAdminFlag)) // Called by admin/VIP
	{
		if (!gc_bSetA.BoolValue)
		{
			CReplyToCommand(client, "%t %t", "duckhunt_tag", "duckhunt_setbyadmin");
			return Plugin_Handled;
		}

		if (GetTeamClientCount(CS_TEAM_CT) == 0 || GetTeamClientCount(CS_TEAM_T) == 0)
		{
			CReplyToCommand(client, "%t %t", "duckhunt_tag", "duckhunt_minplayer");
			return Plugin_Handled;
		}

		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				CReplyToCommand(client, "%t %t", "duckhunt_tag", "duckhunt_progress", EventDay);
				return Plugin_Handled;
			}
		}

		if (g_iCoolDown > 0 && !gc_bSetABypassCooldown.BoolValue)
		{
			CReplyToCommand(client, "%t %t", "duckhunt_tag", "duckhunt_wait", g_iCoolDown);
			return Plugin_Handled;
		}

		StartNextRound();

		if (!gp_bMyJailbreak)
		{
			return Plugin_Handled;
		}

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Duckhunt was started by admin %L", client);
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
			CReplyToCommand(client, "%t %t", "warden_tag", "duckhunt_setbywarden");
			return Plugin_Handled;
		}

		if (GetTeamClientCount(CS_TEAM_CT) == 0 || GetTeamClientCount(CS_TEAM_T) == 0)
		{
			CReplyToCommand(client, "%t %t", "duckhunt_tag", "duckhunt_minplayer");
			return Plugin_Handled;
		}

		if (gp_bMyJailbreak)
		{
			char EventDay[64];
			MyJailbreak_GetEventDayName(EventDay);

			if (!StrEqual(EventDay, "none", false))
			{
				CReplyToCommand(client, "%t %t", "duckhunt_tag", "duckhunt_progress", EventDay);
				return Plugin_Handled;
			}
		}

		if (g_iCoolDown > 0)
		{
			CReplyToCommand(client, "%t %t", "duckhunt_tag", "duckhunt_wait", g_iCoolDown);
			return Plugin_Handled;
		}

		StartNextRound();

		if (!gp_bMyJailbreak)
		{
			return Plugin_Handled;
		}

		if (MyJailbreak_ActiveLogging())
		{
			LogToFileEx(g_sEventsLogFile, "Event Duckhunt was started by warden %L", client);
		}
	}
	else
	{
		CReplyToCommand(client, "%t %t", "warden_tag", "warden_notwarden");
	}

	return Plugin_Handled;
}

// Voting for Event
public Action Command_VoteDuckHunt(int client, int args)
{
	if (!gc_bPlugin.BoolValue)
	{
		CReplyToCommand(client, "%t %t", "duckhunt_tag", "duckhunt_disabled");
		return Plugin_Handled;
	}

	if (!gc_bVote.BoolValue)
	{
		CReplyToCommand(client, "%t %t", "duckhunt_tag", "duckhunt_voting");
		return Plugin_Handled;
	}

	if (GetTeamClientCount(CS_TEAM_CT) == 0 || GetTeamClientCount(CS_TEAM_T) == 0)
	{
		CReplyToCommand(client, "%t %t", "duckhunt_tag", "duckhunt_minplayer");
		return Plugin_Handled;
	}

	if (gp_bMyJailbreak)
	{
		char EventDay[64];
		MyJailbreak_GetEventDayName(EventDay);

		if (!StrEqual(EventDay, "none", false))
		{
			CReplyToCommand(client, "%t %t", "duckhunt_tag", "duckhunt_progress", EventDay);
			return Plugin_Handled;
		}
	}

	if (g_iCoolDown > 0)
	{
		CReplyToCommand(client, "%t %t", "duckhunt_tag", "duckhunt_wait", g_iCoolDown);
		return Plugin_Handled;
	}

	char steamid[24];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));

	if (StrContains(g_sHasVoted, steamid, true) != -1)
	{
		CReplyToCommand(client, "%t %t", "duckhunt_tag", "duckhunt_voted");
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
			LogToFileEx(g_sEventsLogFile, "Event Duckhunt was started by voting");
		}
	}
	else
	{
		CPrintToChatAll("%t %t", "duckhunt_tag", "duckhunt_need", Missing, client);
	}

	return Plugin_Handled;
}

public Action Command_ToggleFly(int client, int args)
{
	if (g_bIsDuckHunt && (GetClientTeam(client) == CS_TEAM_T) && gc_bFlyMode.BoolValue)
	{
		MoveType movetype = GetEntityMoveType(client);

		if (movetype != MOVETYPE_FLY)
		{
			SetEntityMoveType(client, MOVETYPE_FLY);

			return Plugin_Handled;
		}
		else
		{
			SetEntityMoveType(client, MOVETYPE_WALK);

			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

/******************************************************************************
                   EVENTS
******************************************************************************/

// Round start
public void Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	if (!g_bStartDuckHunt && !g_bIsDuckHunt)
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

	SetCvar("sm_menu_enable", 0);
	SetCvar("sm_weapons_enable", 0);
	SetConVarInt(g_bAllowTP, 1);

	if (gp_bMyJailbreak)
	{
		MyJailbreak_SetEventDayPlanned(false);
		MyJailbreak_SetEventDayRunning(true, 0);

		if (gc_fBeaconTime.FloatValue > 0.0)
		{
			g_hTimerBeacon = CreateTimer(gc_fBeaconTime.FloatValue, Timer_BeaconOn, TIMER_FLAG_NO_MAPCHANGE);
		}
	}

	g_bIsDuckHunt = true;
	g_iRound++;
	g_bStartDuckHunt = false;

	if (g_iRound > 0)
	{
		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
		{
			CreateInfoPanel(i);
			
			StripAllPlayerWeapons(i);
			SetEntData(i, g_iCollision_Offset, 2, 4, true);
			SetEntProp(i, Prop_Data, "m_takedamage", 0, 1);
			
			if (GetClientTeam(i) == CS_TEAM_CT && IsValidClient(i, false, false))
			{
				int HunterHP = gc_iHunterHP.IntValue;
				int difference = (GetAliveTeamCount(CS_TEAM_T) - GetAliveTeamCount(CS_TEAM_CT));
				
				if (difference > 0) HunterHP = HunterHP + (gc_iHunterHPincrease.IntValue * difference);
				
				SetEntityHealth(i, HunterHP);
				GivePlayerItem(i, "weapon_nova");
			}
			if (GetClientTeam(i) == CS_TEAM_T && IsValidClient(i, false, false))
			{
				if (gc_bFlyMode.BoolValue)
				{
					SetEntityMoveType(i, MOVETYPE_FLY);
				}
				else
				{
					SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.2);
					SetEntityGravity(i, 0.3);
				}
				SetEntityHealth(i, gc_iChickenHP.IntValue);
				GivePlayerItem(i, "weapon_hegrenade");
				ClientCommand(i, "thirdperson");
			}
		}

		if (gp_bHosties)
		{
			// enable lr on last round
			g_iTsLR = GetAliveTeamCount(CS_TEAM_T);

			if (gc_bAllowLR.BoolValue)
			{
				if (g_iRound == g_iMaxRound && g_iTsLR > g_iTerrorForLR.IntValue)
				{
					SetCvar("sm_hosties_lr", 1);
				}
			}
		}

		CreateTimer (1.1, Timer_SetModel);

		g_iTruceTime--;
		g_hTimerTruce = CreateTimer(1.0, Timer_StartEvent, _, TIMER_REPEAT);

		CPrintToChatAll("%t %t", "duckhunt_tag", "duckhunt_rounds", g_iRound, g_iMaxRound);
	}
}

// Round End
public void Event_RoundEnd(Event event, char[] name, bool dontBroadcast)
{
	if (g_bIsDuckHunt)
	{
		for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, false, true))
		{
			SetEntData(i, g_iCollision_Offset, 0, 4, true);

			SetEntityGravity(i, 1.0);

			FirstPerson(i);

			SetEntityMoveType(i, MOVETYPE_WALK);
		}

		delete g_hTimerBeacon;
		delete g_hTimerTruce;

		int winner = event.GetInt("winner");
		if (winner == 2)
		{
			PrintCenterTextAll("%t", "duckhunt_twin_nc");
		}
		if (winner == 3)
		{
			PrintCenterTextAll("%t", "duckhunt_ctwin_nc");
		}

		if (g_iRound == g_iMaxRound)
		{
			g_bIsDuckHunt = false;
			g_bStartDuckHunt = false;
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

			SetCvar("sm_weapons_enable", 1);
			SetCvar("sm_menu_enable", 1);
			SetConVarInt(g_bAllowTP, 0);

			g_iMPRoundTime.IntValue = g_iOldRoundTime;

			if (gp_bMyJailbreak)
			{
				MyJailbreak_SetEventDayRunning(false, winner);
				MyJailbreak_SetEventDayName("none"); // tell myjailbreak event is ended
			}

			CPrintToChatAll("%t %t", "duckhunt_tag", "duckhunt_end");
		}
	}

	if (g_bStartDuckHunt)
	{
		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
		{
			CreateInfoPanel(i);
		}

		CPrintToChatAll("%t %t", "duckhunt_tag", "duckhunt_next");
		PrintCenterTextAll("%t", "duckhunt_next_nc");
	}
}

// Give new Nades after detonation to chicken
public void Event_HE_Detonate(Event event, const char[] name, bool dontBroadcast)
{
	if (g_bIsDuckHunt)
	{
		int target = GetClientOfUserId(event.GetInt("userid"));

		if (GetClientTeam(target) == 1 && !IsPlayerAlive(target))
		{
			return;
		}

		GivePlayerItem(target, "weapon_hegrenade");
	}

	return;
}

// Give new Ammo to Hunter
public void Event_WeaponReload(Event event, char[] name, bool dontBroadcast)
{
	if (g_bIsDuckHunt)
	{
		int client = GetClientOfUserId(event.GetInt("userid"));

		if (IsValidClient(client, false, false) && (GetClientTeam(client) == CS_TEAM_CT))
		{
			SetPlayerAmmo(client, Client_GetActiveWeapon(client), _, 32);
		}
	}
}

public void Event_PlayerDeath(Event event, char[] name, bool dontBroadcast)
{
	if (g_bIsDuckHunt)
	{
		int client = GetClientOfUserId(event.GetInt("userid"));

		FirstPerson(client);
		SetEntityMoveType(client, MOVETYPE_WALK);
	}
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

// Initialize Event
public void OnMapStart()
{
	g_iVoteCount = 0;
	g_iRound = 0;
	g_bIsDuckHunt = false;
	g_bStartDuckHunt = false;

	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;

	// Precache Sound & Overlay
	if (gc_bSounds.BoolValue)
	{
		PrecacheSoundAnyDownload(g_sSoundStartPath);
	}

	if (gc_bOverlays.BoolValue)
	{
		PrecacheDecalAnyDownload(g_sOverlayStartPath);
	}

	PrecacheModel("models/chicken/chicken.mdl", true);
	PrecacheModel(g_sHunterModel, true);
	AddFileToDownloadsTable("materials/models/props_farm/chicken_white.vmt");
	AddFileToDownloadsTable("materials/models/props_farm/chicken_white.vtf");
	AddFileToDownloadsTable("models/chicken/chicken.dx90.vtx");
	AddFileToDownloadsTable("models/chicken/chicken.phy");
	AddFileToDownloadsTable("models/chicken/chicken.vvd");
	AddFileToDownloadsTable("models/chicken/chicken.mdl");
}

// Map End
public void OnMapEnd()
{
	g_bIsDuckHunt = false;
	g_bStartDuckHunt = false;

	delete g_hTimerTruce;

	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';

	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
	{
		FirstPerson(i);
		SetEntityMoveType(i, MOVETYPE_WALK);
	}
}

// Listen for Last Lequest
public void OnAvailableLR(int Announced)
{
	if (g_bIsDuckHunt && gc_bAllowLR.BoolValue && (g_iTsLR > g_iTerrorForLR.IntValue))
	{
		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i))
		{
			StripAllPlayerWeapons(i);

			if (IsValidClient(i, false, true))
			{
				SetEntData(i, g_iCollision_Offset, 0, 4, true);
				SetEntityGravity(i, 1.0);
				FirstPerson(i);

				if (GetClientTeam(i) == CS_TEAM_CT)
				{
					FakeClientCommand(i, "sm_weapons");
					SetEntityModel(i, g_sModelPathCTPrevious[i]);
				}

				if (GetClientTeam(i) == CS_TEAM_T)
					SetEntityModel(i, g_sModelPathTPrevious[i]);
			}
			GivePlayerItem(i, "weapon_knife");
		}

		delete g_hTimerBeacon;

		if (g_hTimerTruce != null) KillTimer(g_hTimerTruce);

		if (g_iRound == g_iMaxRound)
		{
			g_bIsDuckHunt = false;
			g_bStartDuckHunt = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");

			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_weapons_enable", 1);
			SetCvar("sm_menu_enable", 1);
			SetConVarInt(g_bAllowTP, 0);

			if (gp_bWarden)
			{
				SetCvar("sm_warden_enable", 1);
			}

			g_iMPRoundTime.IntValue = g_iOldRoundTime;

			if (gp_bMyJailbreak)
			{
				MyJailbreak_SetEventDayName("none");
				MyJailbreak_SetEventDayRunning(false, 0);
			}

			CPrintToChatAll("%t %t", "duckhunt_tag", "duckhunt_end");
		}
	}
}

// Set Client Hook
public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

// Nova & Grenade only
public Action OnWeaponCanUse(int client, int weapon)
{
	if (g_bIsDuckHunt)
	{
		char sWeapon[32];
		GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));

		if ((GetClientTeam(client) == CS_TEAM_T && StrEqual(sWeapon, "weapon_hegrenade")) || (GetClientTeam(client) == CS_TEAM_CT && StrEqual(sWeapon, "weapon_nova")))
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

// Only right click attack for chicken
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon) 
{
	if (g_bIsDuckHunt)
	{
		if ((GetClientTeam(client) == CS_TEAM_T) && IsClientInGame(client) && IsPlayerAlive(client) && buttons & IN_ATTACK)
		{
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

public void OnClientDisconnect(int client)
{
	if (g_bIsDuckHunt)
	{
		FirstPerson(client);
	}
}

/******************************************************************************
                   FUNCTIONS
******************************************************************************/

// Back to First Person
void FirstPerson(int client)
{
	if (IsValidClient(client, false, true))
	{
		ClientCommand(client, "firstperson");
	}
}

// Prepare Event
void StartNextRound()
{
	g_bStartDuckHunt = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;

	if (gp_bMyJailbreak)
	{
		char buffer[32];
		Format(buffer, sizeof(buffer), "%T", "duckhunt_name", LANG_SERVER);
		MyJailbreak_SetEventDayName(buffer);
		MyJailbreak_SetEventDayPlanned(true);
	}

	g_iOldRoundTime = g_iMPRoundTime.IntValue; // save original round time
	g_iMPRoundTime.IntValue = gc_iRoundTime.IntValue; // set event round time

	CPrintToChatAll("%t %t", "duckhunt_tag", "duckhunt_next");
	PrintCenterTextAll("%t", "duckhunt_next_nc");
}

/******************************************************************************
                   MENUS
******************************************************************************/

void CreateInfoPanel(int client)
{
	// Create info Panel
	char info[255];

	Panel InfoPanel = new Panel();

	Format(info, sizeof(info), "%T", "duckhunt_info_title", client);
	InfoPanel.SetTitle(info);

	InfoPanel.DrawText("                                   ");
	Format(info, sizeof(info), "%T", "duckhunt_info_line1", client);
	InfoPanel.DrawText(info);
	InfoPanel.DrawText("-----------------------------------");
	Format(info, sizeof(info), "%T", "duckhunt_info_line2", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "duckhunt_info_line3", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "duckhunt_info_line4", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "duckhunt_info_line5", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "duckhunt_info_line6", client);
	InfoPanel.DrawText(info);
	Format(info, sizeof(info), "%T", "duckhunt_info_line7", client);
	InfoPanel.DrawText(info);
	InfoPanel.DrawText("-----------------------------------");

	Format(info, sizeof(info), "%T", "warden_close", client);
	InfoPanel.DrawItem(info);

	InfoPanel.Send(client, Handler_NullCancel, 20);
}

/******************************************************************************
                   TIMER
******************************************************************************/

// Start Timer
public Action Timer_StartEvent(Handle timer)
{
	if (g_iTruceTime > 1)
	{
		g_iTruceTime--;

		PrintCenterTextAll("%t", "duckhunt_timeuntilstart_nc", g_iTruceTime);

		return Plugin_Continue;
	}

	g_iTruceTime = gc_iTruceTime.IntValue;

	if (g_iRound > 0)
	{
		for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i)) if (IsPlayerAlive(i))
		{
			if (GetClientTeam(i) == CS_TEAM_T)
			{
				SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);
				SetEntityGravity(i, 0.3);
			}
			if (GetClientTeam(i) == CS_TEAM_CT)
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

		PrintCenterTextAll("%t", "duckhunt_start_nc");
		CPrintToChatAll("%t %t", "duckhunt_tag", "duckhunt_start");
	}

	if (gp_bSmartJailDoors)
	{
		SJD_OpenDoors();
	}

	g_hTimerTruce = null;

	return Plugin_Stop;
}

// Delay Set model for sm_skinchooser
public Action Timer_SetModel(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, false))
	{
		if (GetClientTeam(i) == CS_TEAM_CT)
		{
			GetEntPropString(i, Prop_Data, "m_ModelName", g_sModelPathCTPrevious[i], sizeof(g_sModelPathCTPrevious[]));
			SetEntityModel(i, g_sHunterModel);
		}

		if (GetClientTeam(i) == CS_TEAM_T)
		{
			GetEntPropString(i, Prop_Data, "m_ModelName", g_sModelPathTPrevious[i], sizeof(g_sModelPathTPrevious[]));
			SetEntityModel(i, "models/chicken/chicken.mdl");
		}
	}
}

// Beacon Timer
public Action Timer_BeaconOn(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i, true, false)) 
	{
		MyJailbreak_BeaconOn(i, 2.0);
	}

	g_hTimerBeacon = null;
}