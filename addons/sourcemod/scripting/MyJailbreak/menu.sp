/*
 * MyJailbreak - Menu Plugin.
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
#include <colors>
#include <autoexecconfig>
#include <warden>
#include <mystocks>
#include <myjailbreak>
#include <adminmenu>

// Optional Plugins
#undef REQUIRE_PLUGIN
#include <smartjaildoors>
#include <myweapons>
#define REQUIRE_PLUGIN

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

// Booleans
bool g_bIsLateLoad;
bool gp_bMyJailShop;
bool gp_bSmartJailDoors;
bool gp_bMyWeapons;

// Integers
int g_iCoolDown;

// Console Variables
ConVar gc_bPlugin;
ConVar gc_bTerror;
ConVar gc_bCTerror;
ConVar gc_bWarden;
ConVar gc_bDeputy;
ConVar gc_bDaysSet;
ConVar gc_bDaysVote;
ConVar gc_bClose;
ConVar gc_bStart;
ConVar gc_bWelcome;
ConVar gc_bTeam;
ConVar gc_sCustomCommandMenu;
ConVar gc_sCustomCommandDays;
ConVar gc_sCustomCommandSetDay;
ConVar gc_sCustomCommandVoting;
ConVar gc_iCooldownDay;
ConVar gc_iCooldownStart;
ConVar gc_sAdminFlag;
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_bVoting;
ConVar gc_iAdminMenu;
ConVar gc_bCleanMenu;

// 3rd party Convars
ConVar g_bMath;
ConVar g_bMathDeputy;
ConVar g_bCheck;
ConVar g_bFF;
ConVar g_bZeus;
ConVar g_bCowboy;
ConVar g_bRules;
ConVar g_bAdminFF;
ConVar g_bAdminFFDeputy;
ConVar g_bWar;
ConVar g_bMute;
ConVar g_bMuteDeputy;
ConVar g_bSuicideBomber;
ConVar g_bKnife;
ConVar g_bFFA;
ConVar g_bExtend;
ConVar g_bExtendDeputy;
ConVar g_bLaserDeputy;
ConVar g_bPainterDeputy;
ConVar g_bLaser;
ConVar g_bPainter;
ConVar g_bNoBlock;
ConVar g_bNoBlockDeputy;
ConVar g_bZombie;
ConVar g_bNoScope;
ConVar g_bGhosts;
ConVar g_bTeleport;
ConVar g_bHEbattle;
ConVar g_bHide;
ConVar g_bCatch;
ConVar g_bTorch;
ConVar g_bArmsRace;
ConVar g_bDrunk;
ConVar g_bFreeday;
ConVar g_bDuckHunt;
ConVar g_bCountdown;
ConVar g_bCountdownDeputy;
ConVar g_bVote;
ConVar g_bOpen;
ConVar g_bOpenDeputy;
ConVar g_bRandomDeputy;
ConVar g_bRandom;
ConVar g_bRequest;
ConVar g_bWarden;
ConVar g_bDeputy;
ConVar g_bDeputySet;
ConVar g_bDeputyBecome;
ConVar g_bWardenCount;
ConVar g_bWardenRebel;
ConVar g_bWardenCountDeputy;
ConVar g_bWardenRebelDeputy;
ConVar g_bSparksDeputy;
ConVar g_bPlayerFreedayDeputy;
ConVar g_bPlayerFreedayGuard;
ConVar g_bSparks;
ConVar g_bPlayerFreeday;
ConVar g_bDealDamage;
ConVar g_bEndRound;
ConVar gc_sAdminFlagBulletSparks;
ConVar gc_sAdminFlagLaser;
ConVar gc_sAdminFlagPainter;
ConVar gc_bOrders;
ConVar gc_bOrdersDeputy;

ConVar g_bVoteWar;
ConVar g_bVoteZeus;
ConVar g_bVoteFFA;
ConVar g_bVoteTorch;
ConVar g_bVoteZombie;
ConVar g_bVoteDrunk;
ConVar g_bVoteGhosts;
ConVar g_bVoteCowboy;
ConVar g_bVoteNoScope;
ConVar g_bVoteHide;
ConVar g_bVoteKnife;
ConVar g_bVoteSuicideBomber;
ConVar g_bVoteCatch;
ConVar g_bVoteHEbattle;
ConVar g_bVoteFreeday;
ConVar g_bVoteDuckHunt;
ConVar g_bVoteDealDamage;
ConVar g_bVoteTeleport;
ConVar g_bVoteArmsRace;

ConVar g_bAdminWar;
ConVar g_bAdminZeus;
ConVar g_bAdminFFA;
ConVar g_bAdminTorch;
ConVar g_bAdminZombie;
ConVar g_bAdminDrunk;
ConVar g_bAdminGhosts;
ConVar g_bAdminCowboy;
ConVar g_bAdminNoScope;
ConVar g_bAdminHide;
ConVar g_bAdminKnife;
ConVar g_bAdminSuicideBomber;
ConVar g_bAdminCatch;
ConVar g_bAdminHEbattle;
ConVar g_bAdminFreeday;
ConVar g_bAdminDuckHunt;
ConVar g_bAdminDealDamage;
ConVar g_bAdminTeleport;
ConVar g_bAdminArmsRace;

ConVar g_bWardenWar;
ConVar g_bWardenZeus;
ConVar g_bWardenFFA;
ConVar g_bWardenTorch;
ConVar g_bWardenZombie;
ConVar g_bWardenDrunk;
ConVar g_bWardenGhosts;
ConVar g_bWardenCowboy;
ConVar g_bWardenNoScope;
ConVar g_bWardenHide;
ConVar g_bWardenKnife;
ConVar g_bWardenSuicideBomber;
ConVar g_bWardenCatch;
ConVar g_bWardenHEbattle;
ConVar g_bWardenFreeday;
ConVar g_bWardenDuckHunt;
ConVar g_bWardenDealDamage;
ConVar g_bWardenTeleport;
ConVar g_bWardenArmsRace;


// Strings
char g_sAdminFlagBulletSparks[64];
char g_sAdminFlagLaser[64];
char g_sAdminFlagPainter[64];
char g_sAdminFlag[64];

// Handles
Handle gH_TopMenu = INVALID_HANDLE;
TopMenuObject gM_MyJB = INVALID_TOPMENUOBJECT;

// Info
public Plugin myinfo = {
	name = "MyJailbreak - Menus",
	author = "shanapu",
	description = "Jailbreak Menu",
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
	LoadTranslations("MyJailbreak.Menu.phrases");

	// Client Commands
	RegConsoleCmd("sm_menu", Command_OpenMenu, "opens the menu depends on players team/rank");
	RegConsoleCmd("buyammo1", Command_OpenMenu, "opens the menu depends on players team/rank");
	RegConsoleCmd("sm_eventdays", Command_VoteEventDays, "open a vote EventDays menu for player");
	RegConsoleCmd("sm_setday", Command_SetEventDay, "open a Set EventDays menu for Warden/Admin");
	RegConsoleCmd("sm_voteday", Command_VotingMenu, "Allows warden & admin to opens event day voting");

	// AutoExecConfig
	AutoExecConfig_SetFile("Menu", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);

	AutoExecConfig_CreateConVar("sm_menu_version", MYJB_VERSION, "The version of the SourceMod plugin MyJailbreak - Menu", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_menu_enable", "1", "0 - disabled, 1 - enable jailbrek menu", _, true, 0.0, true, 1.0);
	gc_sCustomCommandMenu = AutoExecConfig_CreateConVar("sm_menu_cmds_menu", "panel, menus, m", "Set your custom chat command for open menu(!menu (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandDays = AutoExecConfig_CreateConVar("sm_menu_cmds_days", "days, day, ed", "Set your custom chat command for open menu(!eventdays (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandSetDay = AutoExecConfig_CreateConVar("sm_menu_cmds_setday", "sd, setdays", "Set your custom chat command for open menu(!menu (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_sCustomCommandVoting = AutoExecConfig_CreateConVar("sm_menu_cmds_voting", "vd, votedays", "Set your custom chat command for open menu(!menu (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))");
	gc_bCTerror = AutoExecConfig_CreateConVar("sm_menu_ct", "1", "0 - disabled, 1 - enable ct jailbreak menu", _, true, 0.0, true, 1.0);
	gc_bTerror = AutoExecConfig_CreateConVar("sm_menu_t", "1", "0 - disabled, 1 - enable t jailbreak menu", _, true, 0.0, true, 1.0);
	gc_bWarden = AutoExecConfig_CreateConVar("sm_menu_warden", "1", "0 - disabled, 1 - enable warden jailbreak menu", _, true, 0.0, true, 1.0);
	gc_bDeputy = AutoExecConfig_CreateConVar("sm_menu_deputy", "1", "0 - disabled, 1 - enable deputy jailbreak menu", _, true, 0.0, true, 1.0);
	gc_bDaysVote = AutoExecConfig_CreateConVar("sm_menu_votedays", "1", "0 - disabled, 1 - enable vote eventdays menu", _, true, 0.0, true, 1.0);
	gc_bDaysSet = AutoExecConfig_CreateConVar("sm_menu_setdays", "1", "0 - disabled, 1 - enable set eventdays menu", _, true, 0.0, true, 1.0);
	gc_bCleanMenu = AutoExecConfig_CreateConVar("sm_menu_clean", "1", "remove 1. & 2. on first page, cause conflict with weapon switch", _, true, 0.0, true, 1.0);
	gc_bClose = AutoExecConfig_CreateConVar("sm_menu_close", "0", "0 - disabled, 1 - enable close menu after action", _, true, 0.0, true, 1.0);
	gc_bStart = AutoExecConfig_CreateConVar("sm_menu_start", "1", "0 - disabled, 1 - enable open menu on every roundstart", _, true, 0.0, true, 1.0);
	gc_bTeam = AutoExecConfig_CreateConVar("sm_menu_team", "1", "0 - disabled, 1 - enable join team on menu", _, true, 0.0, true, 1.0);
	gc_bWelcome = AutoExecConfig_CreateConVar("sm_menu_welcome", "1", "Show welcome message to newly connected users.", _, true, 0.0, true, 1.0);
	gc_bVoting = AutoExecConfig_CreateConVar("sm_menu_voteday", "1", "0 - disabled, 1 - enable voting for a eventday", _, true, 0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_menu_flag", "g", "Set flag for admin/vip to start a voting & get admin menu");
	gc_iAdminMenu = AutoExecConfig_CreateConVar("sm_menu_admin", "2", "0 - disable admin commands in all menus, 1 - show admin commands only in MyJailbreak menu, 2 - show admin commands only in !admin menu, 3 - show admin commands in all menus", _, true, 0.0, true, 3.0);
	gc_bSetW = AutoExecConfig_CreateConVar("sm_menu_voteday_warden", "1", "0 - disabled, 1 - allow warden to start a voting", _, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_menu_voteday_admin", "1", "0 - disabled, 1 - allow admin/vip  to start a voting", _, true, 0.0, true, 1.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_menu_voteday_cooldown_day", "3", "Rounds cooldown after a voting until voting can be start again", _, true, 0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_menu_voteday_cooldown_start", "3", "Rounds until voting can be start after mapchange.", _, true, 0.0);

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();

	// Hooks
	HookEvent("player_spawn", Event_OnPlayerSpawn);
	HookEvent("round_start", Event_RoundStart);
	HookConVarChange(gc_sAdminFlag, OnSettingChanged);

	// Find
	gc_sAdminFlag.GetString(g_sAdminFlag, sizeof(g_sAdminFlag));

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

void MyAdminMenuReady(Handle h_TopMenu)
{
	if (gc_iAdminMenu.IntValue < 2)
		return;

	// block double calls
	if (h_TopMenu == gH_TopMenu)
		return;

	gH_TopMenu = h_TopMenu;

	// Build MyJailbreak menu
	gM_MyJB = AddToTopMenu(gH_TopMenu, "MyJailbreak", TopMenuObject_Category, Handler_AdminMenu_Category, INVALID_TOPMENUOBJECT);

	if (gM_MyJB != INVALID_TOPMENUOBJECT)
	{
		if (g_bEndRound.BoolValue)
		{
			AddToTopMenu(gH_TopMenu, "sm_endround", TopMenuObject_Item, Handler_AdminMenu_EndRound, gM_MyJB, "sm_endround");
		}
		if (gc_bVoting.BoolValue)
		{
			AddToTopMenu(gH_TopMenu, "sm_votedays", TopMenuObject_Item, Handler_AdminMenu_VoteDays, gM_MyJB, "sm_voteday");
		}
		if (gc_bDaysSet.BoolValue)
		{
			AddToTopMenu(gH_TopMenu, "sm_setday", TopMenuObject_Item, Handler_AdminMenu_SetDay, gM_MyJB, "sm_setday");
		}
		AddToTopMenu(gH_TopMenu, "sm_setwarden", TopMenuObject_Item, Handler_AdminMenu_SetWarden, gM_MyJB, "sm_setwarden");
		AddToTopMenu(gH_TopMenu, "sm_removewarden", TopMenuObject_Item, Handler_AdminMenu_RemoveWarden, gM_MyJB, "sm_removewarden");
		AddToTopMenu(gH_TopMenu, "sm_removedeputy", TopMenuObject_Item, Handler_AdminMenu_RemoveDeputy, gM_MyJB, "sm_removedeputy");
		AddToTopMenu(gH_TopMenu, "sm_removequeue", TopMenuObject_Item, Handler_AdminMenu_RemoveQueue, gM_MyJB, "sm_removequeue");
		AddToTopMenu(gH_TopMenu, "sm_clearqueue", TopMenuObject_Item, Handler_AdminMenu_ClearQueue, gM_MyJB, "sm_clearqueue");
	}
}

public void Handler_AdminMenu_Category(Handle h_TopMenu, TopMenuAction action, TopMenuObject item, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case (TopMenuAction_DisplayTitle):
		{
			Format(buffer, maxlength, "MyJailbreak:");
		}
		case (TopMenuAction_DisplayOption):
		{
			Format(buffer, maxlength, "MyJailbreak");
		}
	}
}

public void Handler_AdminMenu_EndRound(Handle h_TopMenu, TopMenuAction action, TopMenuObject item, int param, char[] buffer, int maxlength)
{
	char info[32];

	switch (action)
	{
		case (TopMenuAction_DisplayOption):
		{
			Format(info, sizeof(info), "%T", "menu_endround", param);
			Format(buffer, maxlength, info);
		}
		case (TopMenuAction_SelectOption):
		{
			FakeClientCommand(param, "sm_endround");
		}
	}
}

public void Handler_AdminMenu_VoteDays(Handle h_TopMenu, TopMenuAction action, TopMenuObject item, int param, char[] buffer, int maxlength)
{
	char info[32];

	switch (action)
	{
		case (TopMenuAction_DisplayOption):
		{
			Format(info, sizeof(info), "%T", "menu_voteday", param);
			Format(buffer, maxlength, info);
		}
		case (TopMenuAction_SelectOption):
		{
			FakeClientCommand(param, "sm_voteday");
		}
	}
}

public void Handler_AdminMenu_SetDay(Handle h_TopMenu, TopMenuAction action, TopMenuObject item, int param, char[] buffer, int maxlength)
{
	char info[32];

	switch (action)
	{
		case (TopMenuAction_DisplayOption):
		{
			Format(info, sizeof(info), "%T", "menu_seteventdays", param);
			Format(buffer, maxlength, info);
		}
		case (TopMenuAction_SelectOption):
		{
			FakeClientCommand(param, "sm_setday");
		}
	}
}

public void Handler_AdminMenu_RemoveWarden(Handle h_TopMenu, TopMenuAction action, TopMenuObject item, int param, char[] buffer, int maxlength)
{
	char info[32];

	switch (action)
	{
		case (TopMenuAction_DisplayOption):
		{
			Format(info, sizeof(info), "%T", "menu_removewarden", param);
			Format(buffer, maxlength, info);
		}
		case (TopMenuAction_SelectOption):
		{
			FakeClientCommand(param, "sm_removewarden");
		}
	}
}

public void Handler_AdminMenu_RemoveDeputy(Handle h_TopMenu, TopMenuAction action, TopMenuObject item, int param, char[] buffer, int maxlength)
{
	char info[32];

	switch (action)
	{
		case (TopMenuAction_DisplayOption):
		{
			Format(info, sizeof(info), "%T", "menu_removedeputy", param);
			Format(buffer, maxlength, info);
		}
		case (TopMenuAction_SelectOption):
		{
			FakeClientCommand(param, "sm_removedeputy");
		}
	}
}

public void Handler_AdminMenu_SetWarden(Handle h_TopMenu, TopMenuAction action, TopMenuObject item, int param, char[] buffer, int maxlength)
{
	char info[32];

	switch (action)
	{
		case (TopMenuAction_DisplayOption):
		{
			Format(info, sizeof(info), "%T", "menu_setwarden", param);
			Format(buffer, maxlength, info);
		}
		case (TopMenuAction_SelectOption):
		{
			FakeClientCommand(param, "sm_setwarden");
		}
	}
}

public void Handler_AdminMenu_RemoveQueue(Handle h_TopMenu, TopMenuAction action, TopMenuObject item, int param, char[] buffer, int maxlength)
{
	char info[32];

	switch (action)
	{
		case (TopMenuAction_DisplayOption):
		{
			Format(info, sizeof(info), "%T", "menu_removequeue", param);
			Format(buffer, maxlength, info);
		}
		case (TopMenuAction_SelectOption):
		{
			FakeClientCommand(param, "sm_removequeue");
		}
	}
}

public void Handler_AdminMenu_ClearQueue(Handle h_TopMenu, TopMenuAction action, TopMenuObject item, int param, char[] buffer, int maxlength)
{
	char info[32];

	switch (action)
	{
		case (TopMenuAction_DisplayOption):
		{
			Format(info, sizeof(info), "%T", "menu_clearqueue", param);
			Format(buffer, maxlength, info);
		}
		case (TopMenuAction_SelectOption):
		{
			FakeClientCommand(param, "sm_clearqueue");
		}
	}
}

// ConVarChange for Strings
public void OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sAdminFlag)
	{
		strcopy(g_sAdminFlag, sizeof(g_sAdminFlag), newValue);
	}
}

// Check for optional Plugins
public void OnAllPluginsLoaded()
{
	gp_bMyJailShop = LibraryExists("myjailshop");
	gp_bSmartJailDoors = LibraryExists("smartjaildoors");
	gp_bMyWeapons = LibraryExists("myweapons");
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "myjailshop"))
		gp_bMyJailShop = false;

	if (StrEqual(name, "smartjaildoors"))
		gp_bSmartJailDoors = false;

	if (StrEqual(name, "myweapons"))
		gp_bMyWeapons = false;
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "myjailshop"))
		gp_bMyJailShop = true;

	if (StrEqual(name, "smartjaildoors"))
		gp_bSmartJailDoors = true;

	if (StrEqual(name, "myweapons"))
		gp_bMyWeapons = true;
}

// FindConVar
public void OnConfigsExecuted()
{
	g_bWarden = FindConVar("sm_warden_enable");
	g_bDeputy = FindConVar("sm_warden_deputy_enable");
	g_bDeputySet = FindConVar("sm_warden_deputy_set");
	g_bDeputyBecome = FindConVar("sm_warden_deputy_become");
	g_bWardenCountDeputy = FindConVar("sm_warden_counter_deputy");
	g_bWardenRebelDeputy = FindConVar("sm_warden_mark_rebel_deputy");
	g_bWardenCount = FindConVar("sm_warden_counter");
	g_bWardenRebel = FindConVar("sm_warden_mark_rebel");
	g_bRules = FindConVar("sm_hosties_rules_enable");
	g_bCheck = FindConVar("sm_hosties_checkplayers_enable");
	g_bMathDeputy = FindConVar("sm_warden_math_deputy");
	g_bNoBlockDeputy = FindConVar("sm_warden_noblock_deputy");
	g_bExtendDeputy = FindConVar("sm_warden_extend_deputy");
	g_bMath = FindConVar("sm_warden_math");
	g_bNoBlock = FindConVar("sm_warden_noblock");
	g_bExtend = FindConVar("sm_warden_extend");
	g_bMute = FindConVar("sm_warden_mute");
	g_bMuteDeputy = FindConVar("sm_warden_mute_deputy");
	g_bPainter = FindConVar("sm_warden_painter");
	g_bLaser = FindConVar("sm_warden_laser");
	g_bSparks = FindConVar("sm_warden_bulletsparks");
	g_bPainterDeputy = FindConVar("sm_warden_painter_deputy");
	g_bLaserDeputy = FindConVar("sm_warden_laser_deputy");
	g_bSparksDeputy = FindConVar("sm_warden_bulletsparks_deputy");
	g_bCountdown = FindConVar("sm_warden_countdown");
	g_bCountdownDeputy = FindConVar("sm_warden_countdown_deputy");
	g_bVote = FindConVar("sm_warden_vote");
	g_bFF = FindConVar("mp_teammates_are_enemies");
	g_bRequest = FindConVar("sm_request_enable");
	g_bOpen = FindConVar("sm_warden_open_enable");
	g_bAdminFF = FindConVar("sm_warden_ff");
	g_bRandom = FindConVar("sm_warden_random");
	g_bPlayerFreeday = FindConVar("sm_warden_freeday_enable");
	g_bOpenDeputy = FindConVar("sm_warden_open_deputy");
	g_bAdminFFDeputy = FindConVar("sm_warden_ff_deputy");
	g_bRandomDeputy = FindConVar("sm_warden_random_deputy");
	g_bPlayerFreedayDeputy = FindConVar("sm_warden_freeday_deputy");
	g_bPlayerFreedayGuard = FindConVar("sm_warden_freeday_guards");
	gc_sAdminFlagBulletSparks = FindConVar("sm_warden_bulletsparks_flag");
	gc_sAdminFlagLaser = FindConVar("sm_warden_laser_flag");
	gc_sAdminFlagPainter = FindConVar("sm_warden_painter_flag");
	gc_bOrders = FindConVar("sm_warden_orders");
	gc_bOrdersDeputy = FindConVar("sm_warden_orders_deputy");
	g_bEndRound = FindConVar("sm_myjb_allow_endround");

	g_bWar = FindConVar("sm_war_enable");
	g_bZeus = FindConVar("sm_zeus_enable");
	g_bFFA = FindConVar("sm_ffa_enable");
	g_bTorch = FindConVar("sm_torch_enable");
	g_bZombie = FindConVar("sm_zombie_enable");
	g_bDrunk = FindConVar("sm_drunk_enable");
	g_bGhosts = FindConVar("sm_ghosts_enable");
	g_bCowboy = FindConVar("sm_cowboy_enable");
	g_bNoScope = FindConVar("sm_noscope_enable");
	g_bHide = FindConVar("sm_hide_enable");
	g_bKnife = FindConVar("sm_knifefight_enable");
	g_bSuicideBomber = FindConVar("sm_suicidebomber_enable");
	g_bCatch = FindConVar("sm_catch_enable");
	g_bHEbattle = FindConVar("sm_hebattle_enable");
	g_bFreeday = FindConVar("sm_freeday_enable");
	g_bDuckHunt = FindConVar("sm_duckhunt_enable");
	g_bDealDamage = FindConVar("sm_dealdamage_enable");
	g_bTeleport = FindConVar("sm_teleport_enable");
	g_bArmsRace = FindConVar("sm_armsrace_enable");

	g_bVoteWar = FindConVar("sm_war_vote");
	g_bVoteZeus = FindConVar("sm_zeus_vote");
	g_bVoteFFA = FindConVar("sm_ffa_vote");
	g_bVoteTorch = FindConVar("sm_torch_vote");
	g_bVoteZombie = FindConVar("sm_zombie_vote");
	g_bVoteDrunk = FindConVar("sm_drunk_vote");
	g_bVoteGhosts = FindConVar("sm_ghosts_vote");
	g_bVoteCowboy = FindConVar("sm_cowboy_vote");
	g_bVoteNoScope = FindConVar("sm_noscope_vote");
	g_bVoteHide = FindConVar("sm_hide_vote");
	g_bVoteKnife = FindConVar("sm_knifefight_vote");
	g_bVoteSuicideBomber = FindConVar("sm_suicidebomber_vote");
	g_bVoteCatch = FindConVar("sm_catch_vote");
	g_bVoteHEbattle = FindConVar("sm_hebattle_vote");
	g_bVoteFreeday = FindConVar("sm_freeday_vote");
	g_bVoteDuckHunt = FindConVar("sm_duckhunt_vote");
	g_bVoteDealDamage = FindConVar("sm_dealdamage_vote");
	g_bVoteTeleport = FindConVar("sm_teleport_vote");
	g_bVoteArmsRace = FindConVar("sm_armsrace_vote");

	g_bAdminWar = FindConVar("sm_war_admin");
	g_bAdminZeus = FindConVar("sm_zeus_admin");
	g_bAdminFFA = FindConVar("sm_ffa_admin");
	g_bAdminTorch = FindConVar("sm_torch_admin");
	g_bAdminZombie = FindConVar("sm_zombie_admin");
	g_bAdminDrunk = FindConVar("sm_drunk_admin");
	g_bAdminGhosts = FindConVar("sm_ghosts_admin");
	g_bAdminCowboy = FindConVar("sm_cowboy_admin");
	g_bAdminNoScope = FindConVar("sm_noscope_admin");
	g_bAdminHide = FindConVar("sm_hide_admin");
	g_bAdminKnife = FindConVar("sm_knifefight_admin");
	g_bAdminSuicideBomber = FindConVar("sm_suicidebomber_admin");
	g_bAdminCatch = FindConVar("sm_catch_admin");
	g_bAdminHEbattle = FindConVar("sm_hebattle_admin");
	g_bAdminFreeday = FindConVar("sm_freeday_admin");
	g_bAdminDuckHunt = FindConVar("sm_duckhunt_admin");
	g_bAdminDealDamage = FindConVar("sm_dealdamage_admin");
	g_bAdminTeleport = FindConVar("sm_teleport_admin");
	g_bAdminArmsRace = FindConVar("sm_armsrace_admin");

	g_bWardenWar = FindConVar("sm_war_warden");
	g_bWardenZeus = FindConVar("sm_zeus_warden");
	g_bWardenFFA = FindConVar("sm_ffa_warden");
	g_bWardenTorch = FindConVar("sm_torch_warden");
	g_bWardenZombie = FindConVar("sm_zombie_warden");
	g_bWardenDrunk = FindConVar("sm_drunk_warden");
	g_bWardenGhosts = FindConVar("sm_ghosts_warden");
	g_bWardenCowboy = FindConVar("sm_cowboy_warden");
	g_bWardenNoScope = FindConVar("sm_noscope_warden");
	g_bWardenHide = FindConVar("sm_hide_warden");
	g_bWardenKnife = FindConVar("sm_knifefight_warden");
	g_bWardenSuicideBomber = FindConVar("sm_suicidebomber_warden");
	g_bWardenCatch = FindConVar("sm_catch_warden");
	g_bWardenHEbattle = FindConVar("sm_hebattle_warden");
	g_bWardenFreeday = FindConVar("sm_freeday_warden");
	g_bWardenDuckHunt = FindConVar("sm_duckhunt_warden");
	g_bWardenDealDamage = FindConVar("sm_dealdamage_warden");
	g_bWardenTeleport = FindConVar("sm_teleport_warden");
	g_bWardenArmsRace = FindConVar("sm_armsrace_warden");

	gc_sAdminFlagLaser.GetString(g_sAdminFlagLaser, sizeof(g_sAdminFlagLaser));
	gc_sAdminFlagPainter.GetString(g_sAdminFlagPainter, sizeof(g_sAdminFlagPainter));
	gc_sAdminFlagBulletSparks.GetString(g_sAdminFlagBulletSparks, sizeof(g_sAdminFlagBulletSparks));

	// Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];

	// Menu
	gc_sCustomCommandMenu.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  // if command not already exist
			RegConsoleCmd(sCommand, Command_OpenMenu, "opens the menu depends on players team/rank");
	}

	// Days Menu
	gc_sCustomCommandDays.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  // if command not already exist
			RegConsoleCmd(sCommand, Command_VoteEventDays, "open a vote EventDays menu for player");
	}

	// Set Day
	gc_sCustomCommandSetDay.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  // if command not already exist
			RegConsoleCmd(sCommand, Command_SetEventDay, "open a Set EventDays menu for Warden/Admin");
	}

	// Voting
	gc_sCustomCommandVoting.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));

	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  // if command not already exist
			RegConsoleCmd(sCommand, Command_VotingMenu, "Allows warden & admin to opens event day voting");
	}

	Handle topmenu;
	if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != INVALID_HANDLE))
	{
		MyAdminMenuReady(topmenu);
	}
}

/******************************************************************************
                   EVENTS
******************************************************************************/

// Open Menu on Spawn
public void Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (gc_bStart.BoolValue)
	{
		Command_OpenMenu(client, 0);
	}
}


public void Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	char EventDay[64];
	MyJailbreak_GetEventDayName(EventDay);

	if (!StrEqual(EventDay, "none", false))
	{
		g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	}
	else if (g_iCoolDown > 0) g_iCoolDown--;
}

/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/

// Welcome/Info Message
public void OnClientPutInServer(int client)
{
	if (gc_bWelcome.BoolValue)
	{
		CreateTimer(35.0, Timer_WelcomeMessage, client);
	}
}

public void OnMapStart()
{
	g_iCoolDown = gc_iCooldownStart.IntValue +1;
}

/******************************************************************************
                   MENUS
******************************************************************************/

// Main Menu
public Action Command_OpenMenu(int client, int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (IsValidClient(client, false, true))
		{
			char menuinfo[255];
			Format(menuinfo, sizeof(menuinfo), "%T", "menu_info_title", client);
			Menu mainmenu = new Menu(JBMenuHandler);
			mainmenu.SetTitle(menuinfo);

			if(gc_bCleanMenu.BoolValue)
			{
				mainmenu.AddItem("1", "0", ITEMDRAW_SPACER);
				mainmenu.AddItem("1", "0", ITEMDRAW_SPACER);
			}

			if (warden_iswarden(client) && gc_bWarden.BoolValue) // HERE STARTS THE WARDEN MENU
			{
				/* Warden PLACEHOLDER
				Format(menuinfo, sizeof(menuinfo), "%T", "menu_PLACEHOLDER", client);
				mainmenu.AddItem("PLACEHOLDER", menuinfo);
				*/
				if (gp_bMyWeapons)
				{
					if (MyWeapons_GetTeamStatus(CS_TEAM_CT))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_guns", client);
						mainmenu.AddItem("guns", menuinfo);
					}
				}
				if (g_bOpen != null && gp_bSmartJailDoors)
				{
					if (g_bOpen.BoolValue && SJD_IsCurrentMapConfigured())
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_opencell", client);
						mainmenu.AddItem("cellopen", menuinfo);
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_closecell", client);
						mainmenu.AddItem("cellclose", menuinfo);
					}
				}
				if (g_bDeputy != null && g_bDeputySet != null)
				{
					if (g_bDeputy.BoolValue && g_bDeputySet.BoolValue && !warden_deputy_exist() && (GetAlivePlayersCount(CS_TEAM_CT) > 1))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_deputyset", client);
						mainmenu.AddItem("setdeputy", menuinfo);
					}
				}
				if (gc_bOrders != null)
				{
					if (gc_bOrders.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_orders", client);
						mainmenu.AddItem("orders", menuinfo);
					}
				}
				if (g_bCountdown != null)
				{
					if (g_bCountdown.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_countdown", client);
						mainmenu.AddItem("countdown", menuinfo);
					}
				}
				if (g_bWardenCount != null)
				{
					if (g_bWardenCount.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_count", client);
						mainmenu.AddItem("count", menuinfo);
					}
				}
				if (g_bPlayerFreeday != null)
				{
					if (g_bPlayerFreeday.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_playerfreeday", client);
						mainmenu.AddItem("playerfreeday", menuinfo);
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_playerremovefreeday", client);
						mainmenu.AddItem("playerremovefreeday", menuinfo);
					}
				}
				if (g_bWardenRebel != null)
				{
					if (g_bWardenRebel.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_rebel", client);
						mainmenu.AddItem("rebel", menuinfo);
					}
				}
				if (g_bMath != null)
				{
					if (g_bMath.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_math", client);
						mainmenu.AddItem("math", menuinfo);
					}
				}
				if (gc_bVoting.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_voteday", client);
					mainmenu.AddItem("voteday", menuinfo);
				}
				if (gc_bDaysSet.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_seteventdays", client);
					mainmenu.AddItem("setdays", menuinfo);
				}
				if (g_bSparks != null)
				{
					if (g_bSparks.BoolValue && CheckVipFlag(client, g_sAdminFlagBulletSparks))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_sparks", client);
						mainmenu.AddItem("sparks", menuinfo);
					}
				}
				if (g_bPainter != null)
				{
					if (g_bPainter.BoolValue && CheckVipFlag(client, g_sAdminFlagPainter))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_painter", client);
						mainmenu.AddItem("painter", menuinfo);
					}
				}
				if (g_bLaser != null)
				{
					if (g_bLaser.BoolValue && CheckVipFlag(client, g_sAdminFlagLaser))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_laser", client);
						mainmenu.AddItem("laser", menuinfo);
					}
				}
				if (g_bExtend != null)
				{
					if (g_bExtend.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_extend", client);
						mainmenu.AddItem("extend", menuinfo);
					}
				}
				if (g_bMute != null)
				{
					if (g_bMute.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_mute", client);
						mainmenu.AddItem("mute", menuinfo);
					}
				}
				if (g_bCheck != null)
				{
					if (g_bCheck.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_check", client);
						mainmenu.AddItem("check", menuinfo);
					}
				}
				if (g_bAdminFF != null)
				{
					if (g_bAdminFF.BoolValue)
					{
						if (!g_bFF.BoolValue)
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_ffon", client);
							mainmenu.AddItem("setff", menuinfo);
						}
						else
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_ffoff", client);
							mainmenu.AddItem("setff", menuinfo);
						}
					}
				}
				if (g_bNoBlock != null)
				{
					if (g_bNoBlock.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_noblock", client);
						mainmenu.AddItem("noblock", menuinfo);
					}
				}
				if (g_bRandom != null)
				{
					if (g_bRandom.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_randomdead", client);
						mainmenu.AddItem("kill", menuinfo);
					}
				}
				if (g_bDeputy != null && g_bDeputySet != null)
				{
					if (g_bDeputy.BoolValue && g_bDeputySet.BoolValue && warden_deputy_exist())
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_removedeputy", client);
						mainmenu.AddItem("undeputy", menuinfo);
					}
				}
				Format(menuinfo, sizeof(menuinfo), "%T", "menu_unwarden", client);
				mainmenu.AddItem("unwarden", menuinfo);
			}// HERE END THE WARDEN MENU
			else if (warden_deputy_isdeputy(client) && gc_bDeputy.BoolValue) // HERE STARTS THE DEPUTY MENU)
			{
				/* Deputy PLACEHOLDER
				Format(menuinfo, sizeof(menuinfo), "%T", "menu_PLACEHOLDER", client);
				mainmenu.AddItem("PLACEHOLDER", menuinfo);
				*/
				if (gp_bMyWeapons)
				{
					if (MyWeapons_GetTeamStatus(CS_TEAM_CT))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_guns", client);
						mainmenu.AddItem("guns", menuinfo);
					}
				}
				if (g_bOpen != null && gp_bSmartJailDoors)
				{
					if (g_bOpen.BoolValue && g_bOpenDeputy.BoolValue && SJD_IsCurrentMapConfigured())
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_opencell", client);
						mainmenu.AddItem("cellopen", menuinfo);
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_closecell", client);
						mainmenu.AddItem("cellclose", menuinfo);
					}
				}
				if (gc_bOrdersDeputy != null)
				{
					if (gc_bOrdersDeputy.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_orders", client);
						mainmenu.AddItem("orders", menuinfo);
					}
				}
				if (g_bCountdown != null)
				{
					if (g_bCountdown.BoolValue && g_bCountdownDeputy.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_countdown", client);
						mainmenu.AddItem("countdown", menuinfo);
					}
				}
				if (g_bWardenCount != null)
				{
					if (g_bWardenCount.BoolValue && g_bWardenCountDeputy.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_count", client);
						mainmenu.AddItem("count", menuinfo);
					}
				}
				if (g_bPlayerFreeday != null)
				{
					if (g_bPlayerFreeday.BoolValue && g_bPlayerFreedayDeputy.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_playerfreeday", client);
						mainmenu.AddItem("playerfreeday", menuinfo);
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_playerremovefreeday", client);
						mainmenu.AddItem("playerremovefreeday", menuinfo);
					}
				}
				if (g_bWardenRebel != null)
				{
					if (g_bWardenRebel.BoolValue && g_bWardenRebelDeputy.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_rebel", client);
						mainmenu.AddItem("rebel", menuinfo);
					}
				}
				if (g_bMath != null)
				{
					if (g_bMath.BoolValue && g_bMathDeputy.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_math", client);
						mainmenu.AddItem("math", menuinfo);
					}
				}
				if (g_bSparks != null)
				{
					if (g_bSparks.BoolValue && g_bSparksDeputy.BoolValue && CheckVipFlag(client, g_sAdminFlagBulletSparks))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_sparks", client);
						mainmenu.AddItem("sparks", menuinfo);
					}
				}
				if (g_bPainter != null)
				{
					if (g_bPainter.BoolValue && g_bPainterDeputy.BoolValue && CheckVipFlag(client, g_sAdminFlagPainter))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_painter", client);
						mainmenu.AddItem("painter", menuinfo);
					}
				}
				if (g_bLaser != null)
				{
					if (g_bLaser.BoolValue && g_bLaserDeputy.BoolValue && CheckVipFlag(client, g_sAdminFlagLaser))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_laser", client);
						mainmenu.AddItem("laser", menuinfo);
					}
				}
				if (g_bExtend != null)
				{
					if (g_bExtend.BoolValue && g_bExtendDeputy.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_extend", client);
						mainmenu.AddItem("extend", menuinfo);
					}
				}
				if (g_bMute != null)
				{
					if (g_bMute.BoolValue && g_bMuteDeputy.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_mute", client);
						mainmenu.AddItem("mute", menuinfo);
					}
				}
				if (g_bCheck != null)
				{
					if (g_bCheck.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_check", client);
						mainmenu.AddItem("check", menuinfo);
					}
				}
				if (g_bAdminFF != null)
				{
					if (g_bAdminFF.BoolValue && g_bAdminFFDeputy.BoolValue)
					{
						if (!g_bFF.BoolValue)
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_ffon", client);
							mainmenu.AddItem("setff", menuinfo);
						}
						else
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_ffoff", client);
							mainmenu.AddItem("setff", menuinfo);
						}
					}
				}
				if (g_bNoBlock != null)
				{
					if (g_bNoBlock.BoolValue && g_bNoBlockDeputy.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_noblock", client);
						mainmenu.AddItem("noblock", menuinfo);
					}
				}
				if (g_bRandom != null)
				{
					if (g_bRandom.BoolValue && g_bRandomDeputy.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_randomdead", client);
						mainmenu.AddItem("kill", menuinfo);
					}
				}
				Format(menuinfo, sizeof(menuinfo), "%T", "menu_undeputy", client);
				mainmenu.AddItem("undeputy", menuinfo);
			}// HERE END THE WARDEN MENU
			else if (GetClientTeam(client) == CS_TEAM_CT && gc_bCTerror.BoolValue) // HERE STARTS THE CT MENU
			{
				/* CT PLACEHOLDER
				Format(menuinfo, sizeof(menuinfo), "%T", "menu_PLACEHOLDER", client);
				mainmenu.AddItem("PLACEHOLDER", menuinfo);
				*/
				if (gp_bMyWeapons)
				{
					if (MyWeapons_GetTeamStatus(CS_TEAM_CT))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_guns", client);
						mainmenu.AddItem("guns", menuinfo);
					}
				}
				if (g_bWarden != null)
				{
					if (!warden_exist() && IsPlayerAlive(client))
					{
						if (g_bWarden.BoolValue)
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_getwarden", client);
							mainmenu.AddItem("getwarden", menuinfo);
						}
						
					}
					if (g_bDeputy != null && g_bDeputyBecome != null)
					{
						if (warden_exist() && g_bDeputy.BoolValue && g_bDeputyBecome.BoolValue && !warden_deputy_exist())
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_deputybecome", client);
							mainmenu.AddItem("becomedeputy", menuinfo);
						}
					}
				}
				if (g_bPlayerFreeday != null)
				{
					if (g_bPlayerFreeday.BoolValue && g_bPlayerFreedayGuard.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_playerfreeday", client);
						mainmenu.AddItem("playerfreeday", menuinfo);
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_playerremovefreeday", client);
						mainmenu.AddItem("playerremovefreeday", menuinfo);
					}
				}
				
				char EventDay[64];
				MyJailbreak_GetEventDayName(EventDay);
				
				if (StrEqual(EventDay, "none", false)) // is an other event running or set?
				{
					if (gc_bDaysVote.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_voteeventdays", client);
						mainmenu.AddItem("votedays", menuinfo);
					}
				}
				
				if (g_bCheck != null)
				{
					if (g_bCheck.BoolValue && IsPlayerAlive(client))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_check", client);
						mainmenu.AddItem("check", menuinfo);
					}
				}
				if (gc_bTeam.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_joint", client);
					mainmenu.AddItem("ChangeTeamT", menuinfo);

					Format(menuinfo, sizeof(menuinfo), "%T", "menu_joinspec", client);
					mainmenu.AddItem("ChangeTeamSpec", menuinfo);
				}
			}// HERE END THE CT MENU
			else if (GetClientTeam(client) == CS_TEAM_T && gc_bTerror.BoolValue) // HERE STARTS THE T MENU
			{
				/* TERROR PLACEHOLDER
				Format(menuinfo, sizeof(menuinfo), "%T", "menu_PLACEHOLDER", client);
				mainmenu.AddItem("PLACEHOLDER", menuinfo);
				*/
				if (gp_bMyWeapons)
				{
					if (MyWeapons_GetTeamStatus(CS_TEAM_T))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_guns", client);
						mainmenu.AddItem("guns", menuinfo);
					}
				}
				if (gp_bMyJailShop)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_jailshop", client);
					mainmenu.AddItem("jailshop", menuinfo);
				}
				if (GetCommandFlags("sm_gangs") != INVALID_FCVAR_FLAGS)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_gangs", client);
					mainmenu.AddItem("gangs", menuinfo);
				}
				if (g_bRequest != null)
				{
					if (g_bRequest.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_request", client);
						mainmenu.AddItem("request", menuinfo);
					}
				}
				if (g_bWarden != null)
				{
					if (warden_exist())
					{
						if (g_bWarden.BoolValue)
						{
							if (g_bVote.BoolValue)
							{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_votewarden", client);
								mainmenu.AddItem("votewarden", menuinfo);
							}
						}
					}
				}
				
				char EventDay[64];
				MyJailbreak_GetEventDayName(EventDay);
				
				if (StrEqual(EventDay, "none", false)) // is an other event running or set?
				{
					if (gc_bDaysVote.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_voteeventdays", client);
						mainmenu.AddItem("votedays", menuinfo);
					}
				}
				if (gc_bTeam.BoolValue)
				{
					if (GetCommandFlags("sm_guard") != INVALID_FCVAR_FLAGS)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_guardct", client);
						mainmenu.AddItem("guard", menuinfo);
					}
					else
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_joinct", client);
						mainmenu.AddItem("ChangeTeamCT", menuinfo);
					}

					Format(menuinfo, sizeof(menuinfo), "%T", "menu_joinspec", client);
					mainmenu.AddItem("ChangeTeamSpec", menuinfo);
				}
			}
			else if (GetClientTeam(client) == CS_TEAM_SPECTATOR) // HERE STARTS THE SPEC MENU
			{
				if (gc_bTeam.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_joint", client);
					mainmenu.AddItem("ChangeTeamT", menuinfo);

					if (GetCommandFlags("sm_guard") != INVALID_FCVAR_FLAGS)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_guardct", client);
						mainmenu.AddItem("guard", menuinfo);
					}
					else
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_joinct", client);
						mainmenu.AddItem("ChangeTeamCT", menuinfo);
					}

					Format(menuinfo, sizeof(menuinfo), "%T", "menu_joinspec", client);
					mainmenu.AddItem("ChangeTeamSpec", menuinfo);
				}
			}
			if (g_bRules != null)
			{
				if (g_bRules.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_rules", client);
					mainmenu.AddItem("rules", menuinfo);
				}
			}
			if (CheckVipFlag(client, g_sAdminFlag))
			{
				/* ADMIN PLACEHOLDER
				Format(menuinfo, sizeof(menuinfo), "%T", "menu_PLACEHOLDER", client);
				mainmenu.AddItem("PLACEHOLDER", menuinfo);
				*/
				if (gc_iAdminMenu.IntValue == 1 || gc_iAdminMenu.IntValue == 3)
				{
					char EventDay[64];
					MyJailbreak_GetEventDayName(EventDay);
					
					if (StrEqual(EventDay, "none", false)) // is an other event running or set?
					{
						if (!warden_iswarden(client))
						{
							if (gc_bVoting.BoolValue)
							{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_voteday", client);
								mainmenu.AddItem("voteday", menuinfo);
							}
							if (gc_bDaysSet.BoolValue)
							{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_seteventdays", client);
								mainmenu.AddItem("setdays", menuinfo);
							}
						}
					}
					if (g_bWarden != null)
					{
						if (g_bWarden.BoolValue)
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_setwarden", client);
							mainmenu.AddItem("setwarden", menuinfo);
							if (warden_exist())
							{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_removewarden", client);
								mainmenu.AddItem("removewarden", menuinfo);
							}
							if (warden_deputy_exist())
							{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_removedeputy", client);
								mainmenu.AddItem("undeputy", menuinfo);
							}
						}
					}
					if (LibraryExists("myratio"))
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_removequeue", client);
						mainmenu.AddItem("removequeue", menuinfo);
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_clearqueue", client);
						mainmenu.AddItem("clearqueue", menuinfo);
					}
					if (g_bEndRound != null)
					{
						if (g_bEndRound.BoolValue)
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_endround", client);
							mainmenu.AddItem("endround", menuinfo);
						}
					}
				}
				Format(menuinfo, sizeof(menuinfo), "%T", "menu_admin", client);
				mainmenu.AddItem("admin", menuinfo);
			}
			/* PLAYER PLACEHOLDER
			Format(menuinfo, sizeof(menuinfo), "%T", "menu_PLACEHOLDER", client);
			mainmenu.AddItem("PLACEHOLDER", menuinfo);
			*/
			
			mainmenu.ExitButton = true;
			mainmenu.Display(client, MENU_TIME_FOREVER);
		}
	}
	return Plugin_Handled;
}

// Main Handle
public int JBMenuHandler(Menu mainmenu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		mainmenu.GetItem(selection, info, sizeof(info));
		
		if (strcmp(info, "ChangeTeamT") == 0)
		{
			FakeClientCommand(client, "sm_prisoner");
		}
		if (strcmp(info, "ChangeTeamCT") == 0)
		{
			ClientCommand(client, "jointeam %i", CS_TEAM_CT);
		}
		if (strcmp(info, "ChangeTeamSpec") == 0)
		{
			FakeClientCommand(client, "sm_spectator");
		}
		/* Command PLACEHOLDER
		else if (strcmp(info, "PLACEHOLDER") == 0)
		{
			FakeClientCommand(client, "sm_YOURCOMMAND");
		}
		*/
		else if (strcmp(info, "endround") == 0)
		{
			FakeClientCommand(client, "sm_endround");
		}
		else if (strcmp(info, "removequeue") == 0)
		{
			FakeClientCommand(client, "sm_removequeue");
		}
		else if (strcmp(info, "clearqueue") == 0)
		{
			FakeClientCommand(client, "sm_clearqueue");
		}
		else if (strcmp(info, "request") == 0)
		{
			FakeClientCommand(client, "sm_request");
		}
		else if (strcmp(info, "lastR") == 0)
		{
			FakeClientCommand(client, "sm_lr");
		}
		else if (strcmp(info, "setwarden") == 0)
		{
			FakeClientCommand(client, "sm_sw");
		}
		else if (strcmp(info, "gangs") == 0)
		{
			FakeClientCommand(client, "sm_gangs");
		}
		else if (strcmp(info, "rules") == 0)
		{
			FakeClientCommand(client, "sm_rules");
		}
		else if (strcmp(info, "jailshop") == 0)
		{
			FakeClientCommand(client, "sm_jailshop");
		}
		else if (strcmp(info, "guns") == 0)
		{
			FakeClientCommand(client, "sm_weapon");
		}
		else if (strcmp(info, "playerfreeday") == 0)
		{
			FakeClientCommand(client, "sm_givefreeday");
		}
		else if (strcmp(info, "playerremovefreeday") == 0)
		{
			FakeClientCommand(client, "sm_removefreeday");
		}
		else if (strcmp(info, "votedays") == 0)
		{
			FakeClientCommand(client, "sm_eventdays");
		}
		else if (strcmp(info, "voteday") == 0)
		{
			FakeClientCommand(client, "sm_voteday");
		}
		else if (strcmp(info, "setdays") == 0)
		{
			FakeClientCommand(client, "sm_setday");
		}
		else if (strcmp(info, "orders") == 0)
		{
			FakeClientCommand(client, "sm_order");
		}
		else if (strcmp(info, "setdeputy") == 0)
		{
			FakeClientCommand(client, "sm_deputy");
		}
		else if (strcmp(info, "count") == 0)
		{
			FakeClientCommand(client, "sm_count");
		}
		else if (strcmp(info, "laser") == 0)
		{
			FakeClientCommand(client, "sm_laser");
		}
		else if (strcmp(info, "painter") == 0)
		{
			FakeClientCommand(client, "sm_painter");
		}
		else if (strcmp(info, "extend") == 0)
		{
			FakeClientCommand(client, "sm_extend");
		}
		else if (strcmp(info, "admin") == 0)
		{
			FakeClientCommand(client, "sm_admin");
		}
		else if (strcmp(info, "countdown") == 0)
		{
			FakeClientCommand(client, "sm_cdmenu");
		}
		else if (strcmp(info, "mute") == 0)
		{
			FakeClientCommand(client, "sm_wmute");
		}
		else if (strcmp(info, "rebel") == 0)
		{
			FakeClientCommand(client, "sm_markrebel");
		}
		else if (strcmp(info, "kill") == 0)
		{
			FakeClientCommand(client, "sm_killrandom");
		}
		else if (strcmp(info, "check") == 0)
		{
			FakeClientCommand(client, "sm_checkplayers");
		}
		else if (strcmp(info, "guard") == 0)
		{
			FakeClientCommand(client, "sm_guard");
		}
		else if (strcmp(info, "getwarden") == 0)
		{
			FakeClientCommand(client, "sm_warden");
			Command_OpenMenu(client, 0);
		}
		else if (strcmp(info, "unwarden") == 0)
		{
			FakeClientCommand(client, "sm_unwarden");
			Command_OpenMenu(client, 0);
		}
		else if (strcmp(info, "undeputy") == 0)
		{
			FakeClientCommand(client, "sm_undeputy");
			Command_OpenMenu(client, 0);
		}
		else if (strcmp(info, "removewarden") == 0)
		{
			FakeClientCommand(client, "sm_removewarden");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "sparks") == 0)
		{
			FakeClientCommand(client, "sm_sparks");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "becomedeputy") == 0)
		{
			FakeClientCommand(client, "sm_deputy");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "setff") == 0)
		{
			FakeClientCommand(client, "sm_setff");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "math") == 0)
		{
			FakeClientCommand(client, "sm_math");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "cellclose") == 0)
		{
			FakeClientCommand(client, "sm_close");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "cellopen") == 0)
		{
			FakeClientCommand(client, "sm_open");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "noblock") == 0)
		{
			FakeClientCommand(client, "sm_noblock");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "votewarden") == 0)
		{
			FakeClientCommand(client, "sm_vetowarden");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		} 
	}
	else if (action == MenuAction_End)
	{
		delete mainmenu;
	}
}

// Event Day Voting Menu
public Action Command_VoteEventDays(int client, int args)
{
	if (gc_bDaysVote.BoolValue)
	{
			Menu daysmenu = new Menu(VoteEventMenuHandler);
			
			char menuinfo[255];
			
			Format(menuinfo, sizeof(menuinfo), "%T", "menu_event_Titlevote", client);
			daysmenu.SetTitle(menuinfo);

			if(gc_bCleanMenu.BoolValue)
			{
				daysmenu.AddItem("1", "0", ITEMDRAW_SPACER);
				daysmenu.AddItem("1", "0", ITEMDRAW_SPACER);
			}
			
			if (g_bWar != null)
			{
				if (g_bWar.BoolValue && g_bVoteWar.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_war", client);
					daysmenu.AddItem("votewar", menuinfo);
				}
			}
			if (g_bFFA != null)
			{
				if (g_bFFA.BoolValue && g_bVoteFFA.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_ffa", client);
					daysmenu.AddItem("voteffa", menuinfo);
				}
			}
			if (g_bZombie != null)
			{
				if (g_bZombie.BoolValue && g_bVoteZombie.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_zombie", client);
					daysmenu.AddItem("votezombie", menuinfo);
				}
			}
			if (g_bHide != null)
			{
				if (g_bHide.BoolValue && g_bVoteHide.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_hide", client);
					daysmenu.AddItem("votehide", menuinfo);
				}
			}
			if (g_bCatch != null)
			{
				if (g_bCatch.BoolValue && g_bVoteCatch.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_catch", client);
					daysmenu.AddItem("votecatch", menuinfo);
				}
			}
			if (g_bGhosts != null)
			{
				if (g_bGhosts.BoolValue && g_bVoteGhosts.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_ghosts", client);
					daysmenu.AddItem("voteGhosts", menuinfo);
				}
			}
			if (g_bTeleport != null)
			{
				if (g_bTeleport.BoolValue && g_bVoteTeleport.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_teleport", client);
					daysmenu.AddItem("voteTeleport", menuinfo);
				}
			}
			if (g_bArmsRace != null)
			{
				if (g_bArmsRace.BoolValue && g_bVoteArmsRace.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_armsrace", client);
					daysmenu.AddItem("voteArmsRace", menuinfo);
				}
			}
			if (g_bSuicideBomber != null)
			{
				if (g_bSuicideBomber.BoolValue && g_bVoteSuicideBomber.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_suicidebomber", client);
					daysmenu.AddItem("voteSuicideBomber", menuinfo);
				}
			}
			if (g_bHEbattle != null)
			{
				if (g_bHEbattle.BoolValue && g_bVoteHEbattle.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_hebattle", client);
					daysmenu.AddItem("votehebattle", menuinfo);
				}
			}
			if (g_bNoScope != null)
			{
				if (g_bNoScope.BoolValue && g_bVoteNoScope.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_noscope", client);
					daysmenu.AddItem("votenoscope", menuinfo);
				}
			}
			if (g_bDuckHunt != null)
			{
				if (g_bDuckHunt.BoolValue && g_bVoteDuckHunt.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_duckhunt", client);
					daysmenu.AddItem("voteduckhunt", menuinfo);
				}
			}
			if (g_bZeus != null)
			{
				if (g_bZeus.BoolValue && g_bVoteZeus.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_zeus", client);
					daysmenu.AddItem("votezeus", menuinfo);
				}
			}
			if (g_bDealDamage != null)
			{
				if (g_bDealDamage.BoolValue && g_bVoteDealDamage.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_dealdamge", client);
					daysmenu.AddItem("votedeal", menuinfo);
				}
			}
			if (g_bDrunk != null)
			{
				if (g_bDrunk.BoolValue && g_bVoteDrunk.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_drunk", client);
					daysmenu.AddItem("votedrunk", menuinfo);
				}
			}
			if (g_bKnife != null)
			{
				if (g_bKnife.BoolValue && g_bVoteKnife.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_knifefight", client);
					daysmenu.AddItem("voteknife", menuinfo);
				}
			}
			if (g_bTorch != null)
			{
				if (g_bTorch.BoolValue && g_bVoteTorch.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_torch", client);
					daysmenu.AddItem("votetorch", menuinfo);
				}
			}
			if (g_bCowboy != null)
			{
				if (g_bCowboy.BoolValue && g_bVoteCowboy.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_cowboy", client);
					daysmenu.AddItem("votecowboy", menuinfo);
				}
			}
			if (g_bFreeday != null)
			{
				if (g_bFreeday.BoolValue && g_bVoteFreeday.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_Freeday", client);
					daysmenu.AddItem("voteFreeday", menuinfo);
				}
			}
			daysmenu.ExitButton = true;
			daysmenu.ExitBackButton = true;
			daysmenu.Display(client, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}

// Event Day Voting Handler
public int VoteEventMenuHandler(Menu daysmenu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		
		daysmenu.GetItem(selection, info, sizeof(info));
		
		if (strcmp(info, "votewar") == 0)
		{
			FakeClientCommand(client, "sm_war");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "voteTeleport") == 0)
		{
			FakeClientCommand(client, "sm_teleport");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "voteArmsRace") == 0)
		{
			FakeClientCommand(client, "sm_armsrace");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "voteffa") == 0)
		{
			FakeClientCommand(client, "sm_ffa");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "votezombie") == 0)
		{
			FakeClientCommand(client, "sm_zombie");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		} 
		else if (strcmp(info, "votezeus") == 0)
		{
			FakeClientCommand(client, "sm_zeus");
			if (!gc_bClose.BoolValue)
			{
					Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "voteGhosts") == 0)
		{
			FakeClientCommand(client, "sm_ghosts");
			if (!gc_bClose.BoolValue)
			{
					Command_OpenMenu(client, 0);
			}
		} 
		else if (strcmp(info, "votecatch") == 0)
		{
			FakeClientCommand(client, "sm_catch");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "votedrunk") == 0)
		{
			FakeClientCommand(client, "sm_drunk");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "votecowboy") == 0)
		{
			FakeClientCommand(client, "sm_cowboy");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "voteSuicideBomber") == 0)
		{
			FakeClientCommand(client, "sm_suicidebomber");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "votenoscope") == 0)
		{
			FakeClientCommand(client, "sm_noscope");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "votetorch") == 0)
		{
			FakeClientCommand(client, "sm_torch");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "votedeal") == 0)
		{
			FakeClientCommand(client, "sm_dealdamage");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "votehebattle") == 0)
		{
			FakeClientCommand(client, "sm_hebattle");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "voteduckhunt") == 0)
		{
			FakeClientCommand(client, "sm_duckhunt");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "votehide") == 0)
		{
			FakeClientCommand(client, "sm_hide");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "voteknife") == 0)
		{
			FakeClientCommand(client, "sm_knifefight");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "voteFreeday") == 0)
		{
			FakeClientCommand(client, "sm_Freeday");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
	}
	else if (action == MenuAction_Cancel) 
	{
		if (selection == MenuCancel_ExitBack) 
		{
			Command_OpenMenu(client, 0);
		}
	}
	else if (action == MenuAction_End)
	{
		delete daysmenu;
	}
}

// Event Days Set Menu
public Action Command_SetEventDay(int client, int args)
{
	if (CheckVipFlag(client, g_sAdminFlag))
	{
		Command_SetAdminEventDay(client);
	}
	else if (warden_iswarden(client))
	{
		Command_SetWardenEventDay(client);
	}
}
// Wardens Event Days Set  Menu
void Command_SetWardenEventDay(int client)
{
	if (gc_bDaysSet.BoolValue)
	{
			Menu daysmenu = new Menu(SetEventMenuHandler);
			
			char menuinfo[255];
			
			Format(menuinfo, sizeof(menuinfo), "%T", "menu_event_Titlestart", client);
			daysmenu.SetTitle(menuinfo);
			
			if (g_bWar != null)
			{
				if (g_bWar.BoolValue && g_bWardenWar.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_war", client);
					daysmenu.AddItem("setwar", menuinfo);
				}
			}
			if (g_bFFA != null)
			{
				if (g_bFFA.BoolValue && g_bWardenFFA.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_ffa", client);
					daysmenu.AddItem("setffa", menuinfo);
				}
			}
			if (g_bZombie != null)
			{
				if (g_bZombie.BoolValue && g_bWardenZombie.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_zombie", client);
					daysmenu.AddItem("setzombie", menuinfo);
				}
			}
			if (g_bHide != null)
			{
				if (g_bHide.BoolValue && g_bWardenHide.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_hide", client);
					daysmenu.AddItem("sethide", menuinfo);
				}
			}
			if (g_bCatch != null)
			{
				if (g_bCatch.BoolValue && g_bWardenCatch.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_catch", client);
					daysmenu.AddItem("setcatch", menuinfo);
				}
			}
			if (g_bTeleport != null)
			{
				if (g_bTeleport.BoolValue && g_bWardenTeleport.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_teleport", client);
					daysmenu.AddItem("setTeleport", menuinfo);
				}
			}
			if (g_bArmsRace != null)
			{
				if (g_bArmsRace.BoolValue && g_bWardenArmsRace.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_armsrace", client);
					daysmenu.AddItem("setArmsRace", menuinfo);
				}
			}
			if (g_bGhosts != null)
			{
				if (g_bGhosts.BoolValue && g_bWardenGhosts.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_ghosts", client);
					daysmenu.AddItem("setGhosts", menuinfo);
				}
			}
			if (g_bSuicideBomber != null)
			{
				if (g_bSuicideBomber.BoolValue && g_bWardenSuicideBomber.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_suicidebomber", client);
					daysmenu.AddItem("setSuicideBomber", menuinfo);
				}
			}
			if (g_bHEbattle != null)
			{
				if (g_bHEbattle.BoolValue && g_bWardenHEbattle.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_hebattle", client);
					daysmenu.AddItem("sethebattle", menuinfo);
				}
			}
			if (g_bNoScope != null)
			{
				if (g_bNoScope.BoolValue && g_bWardenNoScope.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_noscope", client);
					daysmenu.AddItem("setnoscope", menuinfo);
				}
			}
			if (g_bDuckHunt != null)
			{
				if (g_bDuckHunt.BoolValue && g_bWardenDuckHunt.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_duckhunt", client);
					daysmenu.AddItem("setduckhunt", menuinfo);
				}
			}
			if (g_bDealDamage != null)
			{
				if (g_bDealDamage.BoolValue && g_bWardenDealDamage.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_dealdamge", client);
					daysmenu.AddItem("setdeal", menuinfo);
				}
			}
			if (g_bZeus != null)
			{
				if (g_bZeus.BoolValue && g_bWardenZeus.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_zeus", client);
					daysmenu.AddItem("setzeus", menuinfo);
				}
			}
			if (g_bDrunk != null)
			{
				if (g_bDrunk.BoolValue && g_bWardenDrunk.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_drunk", client);
					daysmenu.AddItem("setdrunk", menuinfo);
				}
			}
			if (g_bKnife != null)
			{
				if (g_bKnife.BoolValue && g_bWardenKnife.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_knifefight", client);
					daysmenu.AddItem("setknife", menuinfo);
				}
			}
			if (g_bTorch != null)
			{
				if (g_bTorch.BoolValue && g_bWardenTorch.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_torch", client);
					daysmenu.AddItem("settorch", menuinfo);
				}
			}
			if (g_bCowboy != null)
			{
				if (g_bCowboy.BoolValue && g_bWardenCowboy.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_cowboy", client);
					daysmenu.AddItem("setcowboy", menuinfo);
				}
			}
			if (g_bFreeday != null)
			{
				if (g_bFreeday.BoolValue && g_bWardenFreeday.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_Freeday", client);
					daysmenu.AddItem("setFreeday", menuinfo);
				}
			}
			daysmenu.ExitButton = true;
			daysmenu.ExitBackButton = true;
			daysmenu.Display(client, MENU_TIME_FOREVER);
	}
}

// Admins Event Days Set Menu
void Command_SetAdminEventDay(int client)
{
	if (gc_bDaysSet.BoolValue)
	{
			Menu daysmenu = new Menu(SetEventMenuHandler);
			
			char menuinfo[255];
			
			Format(menuinfo, sizeof(menuinfo), "%T", "menu_event_Titlestart", client);
			daysmenu.SetTitle(menuinfo);
			
			if (g_bWar != null)
			{
				if (g_bWar.BoolValue && g_bAdminWar.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_war", client);
					daysmenu.AddItem("setwar", menuinfo);
				}
			}
			if (g_bFFA != null)
			{
				if (g_bFFA.BoolValue && g_bAdminFFA.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_ffa", client);
					daysmenu.AddItem("setffa", menuinfo);
				}
			}
			if (g_bTeleport != null)
			{
				if (g_bTeleport.BoolValue && g_bAdminTeleport.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_teleport", client);
					daysmenu.AddItem("setTeleport", menuinfo);
				}
			}
			if (g_bArmsRace != null)
			{
				if (g_bArmsRace.BoolValue && g_bAdminArmsRace.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_armsrace", client);
					daysmenu.AddItem("setArmsRace", menuinfo);
				}
			}
			if (g_bZombie != null)
			{
				if (g_bZombie.BoolValue && g_bAdminZombie.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_zombie", client);
					daysmenu.AddItem("setzombie", menuinfo);
				}
			}
			if (g_bHide != null)
			{
				if (g_bHide.BoolValue && g_bAdminHide.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_hide", client);
					daysmenu.AddItem("sethide", menuinfo);
				}
			}
			if (g_bCatch != null)
			{
				if (g_bCatch.BoolValue && g_bAdminCatch.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_catch", client);
					daysmenu.AddItem("setcatch", menuinfo);
				}
			}
			if (g_bGhosts != null)
			{
				if (g_bGhosts.BoolValue && g_bAdminGhosts.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_ghosts", client);
					daysmenu.AddItem("setGhosts", menuinfo);
				}
			}
			if (g_bSuicideBomber != null)
			{
				if (g_bSuicideBomber.BoolValue && g_bAdminSuicideBomber.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_suicidebomber", client);
					daysmenu.AddItem("setSuicideBomber", menuinfo);
				}
			}
			if (g_bHEbattle != null)
			{
				if (g_bHEbattle.BoolValue && g_bAdminHEbattle.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_hebattle", client);
					daysmenu.AddItem("sethebattle", menuinfo);
				}
			}
			if (g_bNoScope != null)
			{
				if (g_bNoScope.BoolValue && g_bAdminNoScope.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_noscope", client);
					daysmenu.AddItem("setnoscope", menuinfo);
				}
			}
			if (g_bDuckHunt != null)
			{
				if (g_bDuckHunt.BoolValue && g_bAdminDuckHunt.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_duckhunt", client);
					daysmenu.AddItem("setduckhunt", menuinfo);
				}
			}
			if (g_bDealDamage != null)
			{
				if (g_bDealDamage.BoolValue && g_bAdminDealDamage.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_dealdamge", client);
					daysmenu.AddItem("setdeal", menuinfo);
				}
			}
			if (g_bZeus != null)
			{
				if (g_bZeus.BoolValue && g_bAdminZeus.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_zeus", client);
					daysmenu.AddItem("setzeus", menuinfo);
				}
			}
			if (g_bDrunk != null)
			{
				if (g_bDrunk.BoolValue && g_bAdminDrunk.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_drunk", client);
					daysmenu.AddItem("setdrunk", menuinfo);
				}
			}
			if (g_bKnife != null)
			{
				if (g_bKnife.BoolValue && g_bAdminKnife.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_knifefight", client);
					daysmenu.AddItem("setknife", menuinfo);
				}
			}
			if (g_bTorch != null)
			{
				if (g_bTorch.BoolValue && g_bAdminTorch.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_torch", client);
					daysmenu.AddItem("settorch", menuinfo);
				}
			}
			if (g_bCowboy != null)
			{
				if (g_bCowboy.BoolValue && g_bAdminCowboy.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_cowboy", client);
					daysmenu.AddItem("setcowboy", menuinfo);
				}
			}
			if (g_bFreeday != null)
			{
				if (g_bFreeday.BoolValue && g_bAdminFreeday.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_Freeday", client);
					daysmenu.AddItem("setFreeday", menuinfo);
				}
			}
			daysmenu.ExitButton = true;
			daysmenu.ExitBackButton = true;
			daysmenu.Display(client, MENU_TIME_FOREVER);
	}
}

// Event Days Set Handler
public int SetEventMenuHandler(Menu daysmenu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		
		daysmenu.GetItem(selection, info, sizeof(info));
		
		if (strcmp(info, "setwar") == 0)
		{
			FakeClientCommand(client, "sm_setwar");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "setffa") == 0)
		{
			FakeClientCommand(client, "sm_setffa");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "setTeleport") == 0)
		{
			FakeClientCommand(client, "sm_setteleport");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "setArmsRace") == 0)
		{
			FakeClientCommand(client, "sm_setarmsrace");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "setzombie") == 0)
		{
			FakeClientCommand(client, "sm_setzombie");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "settorch") == 0)
		{
			FakeClientCommand(client, "sm_settorch");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "setcowboy") == 0)
		{
			FakeClientCommand(client, "sm_setcowboy");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "setGhosts") == 0)
		{
			FakeClientCommand(client, "sm_setghosts");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "setzeus") == 0)
		{
			FakeClientCommand(client, "sm_setzeus");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "setdeal") == 0)
		{
			FakeClientCommand(client, "sm_setdealdamage");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		} 
		else if (strcmp(info, "setcatch") == 0)
		{
			FakeClientCommand(client, "sm_setcatch");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		} 
		else if (strcmp(info, "setdrunk") == 0)
		{
			FakeClientCommand(client, "sm_setdrunk");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "setSuicideBomber") == 0)
		{
			FakeClientCommand(client, "sm_setsuicidebomber");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "setnoscope") == 0)
		{
			FakeClientCommand(client, "sm_setnoscope");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "sethebattle") == 0)
		{
			FakeClientCommand(client, "sm_sethebattle");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "setduckhunt") == 0)
		{
			FakeClientCommand(client, "sm_setduckhunt");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "sethide") == 0)
		{
			FakeClientCommand(client, "sm_sethide");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "setknife") == 0)
		{
			FakeClientCommand(client, "sm_setknifefight");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
		else if (strcmp(info, "setFreeday") == 0)
		{
			FakeClientCommand(client, "sm_setfreeday");
			if (!gc_bClose.BoolValue)
			{
				Command_OpenMenu(client, 0);
			}
		}
	}
	else if (action == MenuAction_Cancel) 
	{
		if (selection == MenuCancel_ExitBack) 
		{
			Command_OpenMenu(client, 0);
		}
	}
	else if (action == MenuAction_End)
	{
		delete daysmenu;
	}
}

public Action Command_VotingMenu(int client, int args)
{
	if (gc_bPlugin.BoolValue && gc_bVoting.BoolValue)
	{
		if ((warden_iswarden(client) && gc_bSetW.BoolValue) || (CheckVipFlag(client, g_sAdminFlag) && gc_bSetA.BoolValue))
		{
			if ((GetTeamClientCount(CS_TEAM_CT) > 0) && (GetTeamClientCount(CS_TEAM_T) > 0))
			{
				char EventDay[64];
				MyJailbreak_GetEventDayName(EventDay);
				
				if (StrEqual(EventDay, "none", false))
				{
					if (g_iCoolDown == 0)
					{
						if (IsVoteInProgress())
						{
							return Plugin_Handled;
						}
						char menuinfo[64];
						Menu menu = new Menu(VotingMenuHandler);
						menu.VoteResultCallback = VotingResults;
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_voting", LANG_SERVER);
						menu.SetTitle(menuinfo);
						
						if(gc_bCleanMenu.BoolValue)
						{
							menu.AddItem("1", "0", ITEMDRAW_SPACER);
							menu.AddItem("1", "0", ITEMDRAW_SPACER);
						}
						

						Format(menuinfo, sizeof(menuinfo), "%T", "menu_noevent", LANG_SERVER);
						menu.AddItem("No Event", menuinfo);

						if (GetCommandFlags("sm_setwar") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_war", LANG_SERVER);
								menu.AddItem("war", menuinfo);
						}
						if (GetCommandFlags("sm_setffa") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_ffa", LANG_SERVER);
								menu.AddItem("ffa", menuinfo);
						}
						if (GetCommandFlags("sm_setzombie") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_zombie", LANG_SERVER);
								menu.AddItem("zombie", menuinfo);
						}
						if (GetCommandFlags("sm_sethide") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_hide", LANG_SERVER);
								menu.AddItem("hide", menuinfo);
						}
						if (GetCommandFlags("sm_setcatch") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_catch", LANG_SERVER);
								menu.AddItem("catch", menuinfo);
						}
						if (GetCommandFlags("sm_setsuicidebomber") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_suicidebomber", LANG_SERVER);
								menu.AddItem("suicidebomber", menuinfo);
						}
						if (GetCommandFlags("sm_setghosts") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_ghosts", LANG_SERVER);
								menu.AddItem("ghosts", menuinfo);
						}
						if (GetCommandFlags("sm_setteleport") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_teleport", LANG_SERVER);
								menu.AddItem("teleport", menuinfo);
						}
						if (GetCommandFlags("sm_setarmsrace") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_armsrace", LANG_SERVER);
								menu.AddItem("armsrace", menuinfo);
						}
						if (GetCommandFlags("sm_sethebattle") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_hebattle", LANG_SERVER);
								menu.AddItem("hebattle", menuinfo);
						}
						if (GetCommandFlags("sm_setnoscope") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_noscope", LANG_SERVER);
								menu.AddItem("noscope", menuinfo);
						}
						if (GetCommandFlags("sm_setduckhunt") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_duckhunt", LANG_SERVER);
								menu.AddItem("duckhunt", menuinfo);
						}
						if (GetCommandFlags("sm_setzeus") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_zeus", LANG_SERVER);
								menu.AddItem("zeus", menuinfo);
						}
						if (GetCommandFlags("sm_setdealdamage") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_dealdamge", LANG_SERVER);
								menu.AddItem("dealdamage", menuinfo);
						}
						if (GetCommandFlags("sm_setdrunk") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_drunk", LANG_SERVER);
								menu.AddItem("drunk", menuinfo);
						}
						if (GetCommandFlags("sm_setknifefight") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_knifefight", LANG_SERVER);
								menu.AddItem("knifefight", menuinfo);
						}
						if (GetCommandFlags("sm_settorch") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_torch", LANG_SERVER);
								menu.AddItem("torch", menuinfo);
						}
						if (GetCommandFlags("sm_setcowboy") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_cowboy", LANG_SERVER);
								menu.AddItem("cowboy", menuinfo);
						}
						if (GetCommandFlags("sm_setfreeday") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_Freeday", LANG_SERVER);
								menu.AddItem("freeday", menuinfo);
						}
						menu.ExitButton = true;
						menu.DisplayVoteToAll(25);
						g_iCoolDown = gc_iCooldownDay.IntValue + 1;
					}
					else CReplyToCommand(client, "%t %t", "menu_tag", "menu_wait", g_iCoolDown);
				}
				else CReplyToCommand(client, "%t %t", "menu_tag", "menu_progress", EventDay);
			}
			else CReplyToCommand(client, "%t %t", "menu_tag", "menu_minplayer");
		}
		else CReplyToCommand(client, "%t %t", "menu_tag", "warden_notwarden");
	}
	else CReplyToCommand(client, "%t %t", "menu_tag", "menu_disabled");

	return Plugin_Handled;
}

public int VotingMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		/* This is called after VoteEnd */
		delete menu;
	}
}

public int VotingResults(Menu menu, int num_votes, int num_clients, const int[][] client_info, int num_items, const int[][] item_info)
{
	char EventDay[64];
	MyJailbreak_GetEventDayName(EventDay);
	
	if (StrEqual(EventDay, "none", false))
	{
		/* See if there were multiple winners */
		int winner = 0;
		if (num_items > 1 && (item_info[0][VOTEINFO_ITEM_VOTES] == item_info[1][VOTEINFO_ITEM_VOTES]))
		{
			winner = GetRandomInt(0, 1);
			CPrintToChatAll("%t %t", "menu_tag", "menu_votingdraw");
		}
		char event[64];
		menu.GetItem(item_info[winner][VOTEINFO_ITEM_INDEX], event, sizeof(event));
		CPrintToChatAll("%t %t", "menu_tag", "menu_votingwon", event, num_clients, num_items);
		
		if (!StrEqual("No Event",event)) ServerCommand("sm_set%s", event);
	}
	else CPrintToChatAll("%t %t", "menu_tag", "menu_votingcancel", EventDay);
}

/******************************************************************************
                   TIMER
******************************************************************************/

public Action Timer_WelcomeMessage(Handle timer, any client)
{
	if (gc_bWelcome.BoolValue && IsValidClient(client, false, true))
	{
		CPrintToChat(client, "%t %t", "menu_tag", "menu_info");
	}
}
