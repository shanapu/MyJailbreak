//Includes
#include <sourcemod>
#include <cstrike>
#include <warden>
#include <emitsoundany>
#include <colors>
#include <autoexecconfig>
#include <myjailbreak>
#include <scp>
#include <lastrequest>
#include <smlib>
#include <smartjaildoors>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//ConVars
ConVar gc_bPlugin;
ConVar gc_bVote;
ConVar gc_bStayWarden;
ConVar gc_bBecomeWarden;
ConVar gc_bChooseRandom;
ConVar gc_bSounds;
ConVar gc_bOverlays;
ConVar gc_sWarden;
ConVar gc_sUnWarden;
ConVar gc_sModelPath;
ConVar gc_bModel;
ConVar gc_bBetterNotes;
ConVar g_bMenuClose;
ConVar gc_sCustomCommand;
ConVar gc_fRandomTimer;

//Bools
bool IsLR = false;

//Integers
int g_iWarden = -1;
int g_iTempWarden[MAXPLAYERS+1] = -1;
int g_iVoteCount;
int g_iBeamSprite = -1;
int g_iHaloSprite = -1;
int g_iSmokeSprite;
int g_iLastButtons[MAXPLAYERS+1];
// int g_iHaloSpritecolor[4] = {255,255,255,255};
int g_iColors[8][4] = 
{
	{255,255,255,255},  //white
	{255,0,0,255},  //red
	{20,255,20,255},  //green
	{0,65,255,255},  //blue
	{255,255,0,255},  //yellow
	{0,255,255,255},  //cyan
	{255,0,255,255},  //magenta
	{255,80,0,255}
};

//Handles
Handle gF_OnWardenCreated;
Handle gF_OnWardenRemoved;
Handle gF_OnWardenCreatedByUser;
Handle gF_OnWardenCreatedByAdmin;
Handle gF_OnWardenDisconnected;
Handle gF_OnWardenDeath;
Handle gF_OnWardenRemovedBySelf;
Handle gF_OnWardenRemovedByAdmin;
Handle RandomTimer = null;

//Strings
char g_sHasVoted[1500];
char g_sModelPath[256];
char g_sWardenModel[256];
char g_sUnWarden[256];
char g_sWarden[256];
char g_sCustomCommand[64];
char g_sMyJBLogFile[PLATFORM_MAX_PATH];

//Modules
#include "MyJailbreak/Warden/mute.sp"
#include "MyJailbreak/Warden/bulletsparks.sp"
#include "MyJailbreak/Warden/countdown.sp"
#include "MyJailbreak/Warden/math.sp"
#include "MyJailbreak/Warden/disarm.sp"
#include "MyJailbreak/Warden/noblock.sp"
#include "MyJailbreak/Warden/celldoors.sp"
#include "MyJailbreak/Warden/extendtime.sp"
#include "MyJailbreak/Warden/friendlyfire.sp"
#include "MyJailbreak/Warden/reminder.sp"
#include "MyJailbreak/Warden/randomkill.sp"
#include "MyJailbreak/Warden/handcuffs.sp"
#include "MyJailbreak/Warden/backstab.sp"
#include "MyJailbreak/Warden/gundrop.sp"
#include "MyJailbreak/Warden/marker.sp"
#include "MyJailbreak/Warden/icon.sp"
#include "MyJailbreak/Warden/color.sp"
#include "MyJailbreak/Warden/laser.sp"
#include "MyJailbreak/Warden/painter.sp"


public Plugin myinfo = {
	name = "MyJailbreak - Warden",
	author = "shanapu, ecca, ESKO & .#zipcore",
	description = "Jailbreak Warden script",
	version = PLUGIN_VERSION,
	url = URL_LINK
};

public void OnPluginStart() 
{
	//Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	
	//Client commands
	RegConsoleCmd("sm_w", Command_BecomeWarden, "Allows the player taking the charge over prisoners");
	RegConsoleCmd("sm_warden", Command_BecomeWarden, "Allows the player taking the charge over prisoners");
	RegConsoleCmd("sm_uw", Command_ExitWarden, "Allows the player to retire from the position");
	RegConsoleCmd("sm_unwarden", Command_ExitWarden, "Allows the player to retire from the position");
	RegConsoleCmd("sm_hg", Command_BecomeWarden, "Allows the player taking the charge over prisoners");
	RegConsoleCmd("sm_headguard", Command_BecomeWarden, "Allows the player taking the charge over prisoners");
	RegConsoleCmd("sm_uhg", Command_ExitWarden, "Allows the player to retire from the position");
	RegConsoleCmd("sm_unheadguard", Command_ExitWarden, "Allows the player to retire from the position");
	RegConsoleCmd("sm_com", Command_BecomeWarden, "Allows the player taking the charge over prisoners");
	RegConsoleCmd("sm_commander", Command_BecomeWarden, "Allows the player taking the charge over prisoners");
	RegConsoleCmd("sm_uc", Command_ExitWarden, "Allows the player to retire from the position");
	RegConsoleCmd("sm_uncommander", Command_ExitWarden, "Allows the player to retire from the position");
	RegConsoleCmd("sm_vw", Command_VoteWarden, "Allows the player to vote to retire Warden");
	RegConsoleCmd("sm_votewarden", Command_VoteWarden, "Allows the player to vote to retire Warden");
	RegConsoleCmd("sm_vetowarden", Command_VoteWarden, "Allows the player to vote to retire Warden");
	
	//Admin commands
	RegAdminCmd("sm_sw", AdminCommand_SetWarden, ADMFLAG_GENERIC);
	RegAdminCmd("sm_setwarden", AdminCommand_SetWarden, ADMFLAG_GENERIC);
	RegAdminCmd("sm_rw", AdminCommand_RemoveWarden, ADMFLAG_GENERIC);
	RegAdminCmd("sm_fw", AdminCommand_RemoveWarden, ADMFLAG_GENERIC);
	RegAdminCmd("sm_firewarden", AdminCommand_RemoveWarden, ADMFLAG_GENERIC);
	RegAdminCmd("sm_removewarden", AdminCommand_RemoveWarden, ADMFLAG_GENERIC);
	
	//Forwards
	gF_OnWardenCreated = CreateGlobalForward("warden_OnWardenCreated", ET_Ignore, Param_Cell);
	gF_OnWardenRemoved = CreateGlobalForward("warden_OnWardenRemoved", ET_Ignore, Param_Cell);
	gF_OnWardenCreatedByUser = CreateGlobalForward("warden_OnWardenCreatedByUser", ET_Ignore, Param_Cell);
	gF_OnWardenCreatedByAdmin = CreateGlobalForward("warden_OnWardenCreatedByAdmin", ET_Ignore, Param_Cell);
	gF_OnWardenDisconnected = CreateGlobalForward("warden_OnWardenDisconnected", ET_Ignore, Param_Cell);
	gF_OnWardenDeath = CreateGlobalForward("warden_OnWardenDeath", ET_Ignore, Param_Cell);
	gF_OnWardenRemovedBySelf = CreateGlobalForward("warden_OnWardenRemovedBySelf", ET_Ignore, Param_Cell);
	gF_OnWardenRemovedByAdmin = CreateGlobalForward("warden_OnWardenRemovedByAdmin", ET_Ignore, Param_Cell);
	
	//AutoExecConfig
	AutoExecConfig_SetFile("Warden", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_warden_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_warden_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_sCustomCommand = AutoExecConfig_CreateConVar("sm_warden_cmd", "simon", "Set your custom chat command for become warden. no need for sm_ or !");
	gc_bBecomeWarden = AutoExecConfig_CreateConVar("sm_warden_become", "1", "0 - disabled, 1 - enable !w / !warden - player can choose to be warden. If disabled you should need sm_warden_choose_random 1", _, true,  0.0, true, 1.0);
	gc_bChooseRandom = AutoExecConfig_CreateConVar("sm_warden_choose_random", "0", "0 - disabled, 1 - enable pick random warden if there is still no warden after sm_warden_choose_time", _, true,  0.0, true, 1.0);
	gc_fRandomTimer = AutoExecConfig_CreateConVar("sm_warden_choose_time", "45.0", "Time in seconds a random warden will picked when no warden was set. need sm_warden_choose_random 1", _, true,  1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_warden_vote", "1", "0 - disabled, 1 - enable player vote against warden", _, true,  0.0, true, 1.0);
	gc_bStayWarden = AutoExecConfig_CreateConVar("sm_warden_stay", "1", "0 - disabled, 1 - enable warden stay after round end", _, true,  0.0, true, 1.0);
	gc_bBetterNotes = AutoExecConfig_CreateConVar("sm_warden_better_notifications", "1", "0 - disabled, 1 - Will use hint and center text", _, true, 0.0, true, 1.0);
	gc_bModel = AutoExecConfig_CreateConVar("sm_warden_model", "1", "0 - disabled, 1 - enable warden model", 0, true, 0.0, true, 1.0);
	gc_sModelPath = AutoExecConfig_CreateConVar("sm_warden_model_path", "models/player/custom_player/legacy/security/security.mdl", "Path to the model for warden.");
	gc_bSounds = AutoExecConfig_CreateConVar("sm_warden_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true,  0.0, true, 1.0);
	gc_sWarden = AutoExecConfig_CreateConVar("sm_warden_sounds_warden", "music/MyJailbreak/warden.mp3", "Path to the soundfile which should be played for a int warden.");
	gc_sUnWarden = AutoExecConfig_CreateConVar("sm_warden_sounds_unwarden", "music/MyJailbreak/unwarden.mp3", "Path to the soundfile which should be played when there is no warden anymore.");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_warden_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true,  0.0, true, 1.0);
	
	Mute_OnPluginStart();
	Disarm_OnPluginStart();
	BulletSparks_OnPluginStart();
	Countdown_OnPluginStart();
	Math_OnPluginStart();
	NoBlock_OnPluginStart();
	CellDoors_OnPluginStart();
	ExtendTime_OnPluginStart();
	FriendlyFire_OnPluginStart();
	Reminder_OnPluginStart();
	RandomKill_OnPluginStart();
	HandCuffs_OnPluginStart();
	BackStab_OnPluginStart();
	Marker_OnPluginStart();
	GunDropPrevention_OnPluginStart();
	Icon_OnPluginStart();
	Color_OnPluginStart();
	Laser_OnPluginStart();
	Painter_OnPluginStart();
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("round_poststart", PostRoundStart);
	HookEvent("player_death", playerDeath);
	HookEvent("player_team", EventPlayerTeam);
	HookEvent("round_end", RoundEnd);
	HookEvent("weapon_fire", WeaponFire);
	HookConVarChange(gc_sModelPath, OnSettingChanged);
	HookConVarChange(gc_sUnWarden, OnSettingChanged);
	HookConVarChange(gc_sWarden, OnSettingChanged);
	
	//FindConVar
	g_bMenuClose = FindConVar("sm_menu_close");
	gc_sWarden.GetString(g_sWarden, sizeof(g_sWarden));
	gc_sUnWarden.GetString(g_sUnWarden, sizeof(g_sUnWarden));
	gc_sModelPath.GetString(g_sWardenModel, sizeof(g_sWardenModel));
	gc_sCustomCommand.GetString(g_sCustomCommand , sizeof(g_sCustomCommand));
	
	SetLogFile(g_sMyJBLogFile, "MyJB");

}

//ConVarChange for Strings

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sWarden)
	{
		strcopy(g_sWarden, sizeof(g_sWarden), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sWarden);
	}
	else if(convar == gc_sUnWarden)
	{
		strcopy(g_sUnWarden, sizeof(g_sUnWarden), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sUnWarden);
	}
	else if(convar == gc_sModelPath)
	{
		strcopy(g_sWardenModel, sizeof(g_sWardenModel), newValue);
		if(gc_bModel.BoolValue) PrecacheModel(g_sWardenModel);
	}
	else if(convar == gc_sCustomCommand)
	{
		strcopy(g_sCustomCommand, sizeof(g_sCustomCommand), newValue);
		char sBufferCMD[64];
		Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
		if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
			RegConsoleCmd(sBufferCMD, Command_BecomeWarden, "Allows the player taking the charge over prisoners");
	}
}

//Initialize Plugin

public void OnConfigsExecuted()
{
	Math_OnConfigsExecuted();
	RandomKill_OnConfigsExecuted();
	
	char sBufferCMD[64];
	Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
	if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMD, Command_BecomeWarden, "Allows the player taking the charge over prisoners");
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("warden_exist", Native_ExistWarden);
	CreateNative("warden_iswarden", Native_IsWarden);
	CreateNative("warden_set", Native_SetWarden);
	CreateNative("warden_removed", Native_RemoveWarden);
	CreateNative("warden_get", Native_GetWarden);
	
	RegPluginLibrary("warden");
	return APLRes_Success;
}

public void OnMapStart()
{
	Countdown_OnMapStart();
	Math_OnMapStart();
	HandCuffs_OnMapStart();
	Marker_OnMapStart();
	Reminder_OnMapStart();
	Icon_OnMapStart();
	Laser_OnMapStart();
	Painter_OnMapStart();
	
	if(gc_bSounds.BoolValue)
	{
		PrecacheSoundAnyDownload(g_sWarden);
		PrecacheSoundAnyDownload(g_sUnWarden);
	}
	
	g_iVoteCount = 0;
	PrecacheModel(g_sWardenModel);
	g_iSmokeSprite = PrecacheModel("materials/sprites/steam1.vmt");
	g_iBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_iHaloSprite = PrecacheModel("materials/sprites/glow01.vmt");
	PrecacheSound(SOUND_THUNDER, true);
}

public void OnClientPutInServer(int client)
{
	BulletSparks_OnClientPutInServer(client);
	HandCuffs_OnClientPutInServer(client);
	BackStab_OnClientPutInServer(client);
	Laser_OnClientPutInServer(client);
	Painter_OnClientPutInServer(client);
}

//Round Start


public void PostRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if(gc_bPlugin.BoolValue)
	{
		if ((!IsWardenExist) && gc_bBecomeWarden.BoolValue)
		{
			RandomTimer = CreateTimer(gc_fRandomTimer.FloatValue, ChooseRandom);
			CPrintToChatAll("%t %t", "warden_tag" , "warden_nowarden");
			if(gc_bBetterNotes.BoolValue)
			{
				PrintCenterTextAll("%t", "warden_nowarden_nc");
			}
		}
	}
}


public void RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if(!gc_bPlugin.BoolValue)
	{
		if (IsWardenExist)
		{
			CreateTimer(0.1, Timer_RemoveColor, g_iWarden);
			SetEntityModel(g_iWarden, g_sModelPath);
			Forward_OnWardenRemoved(g_iWarden);
			g_iWarden = -1;
		}
	}
	char EventDay[64];
	GetEventDay(EventDay);
	
	if(!StrEqual(EventDay, "none", false) || !gc_bStayWarden.BoolValue)
	{
		if (IsWardenExist)
		{
			CreateTimer( 0.1, Timer_RemoveColor, g_iWarden);
			SetEntityModel(g_iWarden, g_sModelPath);
			Forward_OnWardenRemoved(g_iWarden);
			g_iWarden = -1;
			
		}
	}
	if(IsWardenExist)
	{
		if(gc_bModel.BoolValue) SetEntityModel(g_iWarden, g_sWardenModel);
	}
	IsLR = false;
}

//Round End

public void RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	IsLR = false;
}

//!w

public Action Command_BecomeWarden(int client, int args)
{
	if(gc_bPlugin.BoolValue)
	{
		if (!IsWardenExist)
		{
			if (gc_bBecomeWarden.BoolValue)
			{
				if (GetClientTeam(client) == CS_TEAM_CT)
				{
					if (IsPlayerAlive(client))
					{
						SetTheWarden(client);
						Forward_OnWardenCreatedByUser(client);
					}
					else CPrintToChat(client, "%t %t", "warden_tag" , "warden_playerdead");
				}
				else CPrintToChat(client, "%t %t", "warden_tag" , "warden_ctsonly");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_nobecome", g_iWarden);
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_exist", g_iWarden);
	}
	else CPrintToChat(client, "%t %t", "warden_tag" , "warden_disabled");
}

//!uw

public Action Command_ExitWarden(int client, int args) 
{
	if(gc_bPlugin.BoolValue)
	{
		if(IsClientWarden(client))
		{
			CPrintToChatAll("%t %t", "warden_tag" , "warden_retire", client);
			
			if(gc_bBetterNotes.BoolValue)
			{
				PrintCenterTextAll("%t", "warden_retire_nc", client);
			}
			Forward_OnWardenRemovedBySelf(client);
			RemoveTheWarden();
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "warden_tag" , "warden_disabled");
}

//!vw

public Action Command_VoteWarden(int client,int args)
{
	if(gc_bPlugin.BoolValue)
	{
		if(gc_bVote.BoolValue)
		{
			char steamid[64];
			GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
			if (IsWardenExist)
			{
				if (StrContains(g_sHasVoted, steamid, true) == -1)
				{
					int playercount = (GetClientCount(true) / 2);
					g_iVoteCount++;
					int Missing = playercount - g_iVoteCount + 1;
					Format(g_sHasVoted, sizeof(g_sHasVoted), "%s,%s", g_sHasVoted, steamid);
					
					if (g_iVoteCount > playercount)
					{
						if(MyJBLogging(true)) LogToFileEx(g_sMyJBLogFile, "Player %L was kick as warden by voting", g_iWarden);
						RemoveTheWarden();
					}
					else CPrintToChatAll("%t %t", "warden_tag" , "warden_need", Missing, client);
				}
				else CPrintToChat(client, "%t %t", "warden_tag" , "warden_voted");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_noexist");
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_voting");
	}
	else CPrintToChat(client, "%t %t", "warden_tag" , "warden_disabled");
}

//Warden died

public Action playerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(GetEventInt(event, "userid")); // Get the dead clients id
	
	if(IsClientWarden(client)) // Aww damn , he is the warden
	{
		CPrintToChatAll("%t %t", "warden_tag" , "warden_dead", client);
		
		if(gc_bBetterNotes.BoolValue)
		{
			PrintCenterTextAll("%t", "warden_dead_nc", client);
		}
		if(gc_bSounds.BoolValue)
		{
			EmitSoundToAllAny(g_sUnWarden);
		}
		if (RandomTimer != null)
		KillTimer(RandomTimer);
			
		RandomTimer = null;
		RandomTimer = CreateTimer(gc_fRandomTimer.FloatValue, ChooseRandom);
		Forward_OnWardenDeath(client);
		g_iWarden = -1;
	}
}

//Set new Warden for Admin Menu

public Action AdminCommand_SetWarden(int client,int args)
{
	if(gc_bPlugin.BoolValue)	
	{
		if(IsValidClient(client, false, false))
		{
			char info1[255];
			Menu menu = CreateMenu(Handler_SetWarden);
			Format(info1, sizeof(info1), "%T", "warden_choose", client);
			menu.SetTitle(info1);
			LoopValidClients(i, true, false)
			{
				if(GetClientTeam(i) == CS_TEAM_CT && IsClientWarden(i) == false)
				{
					char userid[11];
					char username[MAX_NAME_LENGTH];
					IntToString(GetClientUserId(i), userid, sizeof(userid));
					Format(username, sizeof(username), "%N", i);
					menu.AddItem(userid,username);
				}
			}
			menu.ExitBackButton = true;
			menu.ExitButton = true;
			menu.Display(client,MENU_TIME_FOREVER);
		}
	}
	return Plugin_Handled;
}

//Overwrite new Warden for Admin Menu

public int Handler_SetWarden(Menu menu, MenuAction action, int client, int Position)
{
	if(action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position,Item,sizeof(Item));
		
		LoopValidClients(i, true, false)
		{
			if(GetClientTeam(i) == CS_TEAM_CT && IsClientWarden(i) == false)
			{
				char info4[255], info2[255], info3[255];
				int userid = GetClientUserId(i);
				if(userid == StringToInt(Item))
				{
					if(IsWardenExist)  // if(IsWardenExist() == true)
					{
						g_iTempWarden[client] = userid;
						Menu menu1 = CreateMenu(Handler_SetWardenOverwrite);
						Format(info4, sizeof(info4), "%T", "warden_remove", client);
						menu1.SetTitle(info4);
						Format(info3, sizeof(info3), "%T", "warden_yes", client);
						Format(info2, sizeof(info2), "%T", "warden_no", client);
						menu1.AddItem("1", info3);
						menu1.AddItem("0", info2);
						menu1.ExitBackButton = true;
						menu1.ExitButton = true;
						menu1.Display(client,MENU_TIME_FOREVER);
					}
					else
					{
						SetTheWarden(i);
						Forward_OnWardenCreatedByAdmin(i);
					}
				}
			}
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(Position == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_menu");
		}
	}
	else if(action == MenuAction_End)
	{
		delete menu;
	}
}

//Set/Overwrite new Warden for Admin Handler

public int Handler_SetWardenOverwrite(Menu menu, MenuAction action, int client, int Position)
{
	if(action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position,Item,sizeof(Item));
		int choice = StringToInt(Item);
		if(choice == 1)
		{
			int newwarden = GetClientOfUserId(g_iTempWarden[client]);
			if (g_iWarden != -1)CPrintToChatAll("%t %t", "warden_tag" , "warden_removed", client, g_iWarden);
			
			if(MyJBLogging(true)) LogToFileEx(g_sMyJBLogFile, "Admin %L kick player %L warden and set %L as new", client, g_iWarden, newwarden);
			
			RemoveTheWarden();
			SetTheWarden(newwarden);
			Forward_OnWardenCreatedByAdmin(newwarden);
		}
		if(g_bMenuClose != null)
		{
			if(!g_bMenuClose)
			{
				FakeClientCommand(client, "sm_menu");
			}
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(Position == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_menu");
		}
	}
	else if(action == MenuAction_End)
	{
		delete menu;
	}
}

//warden change team

public Action EventPlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(IsClientWarden(client))
	{	
		CPrintToChatAll("%t %t", "warden_tag" , "warden_retire", client);
		
		if(gc_bBetterNotes.BoolValue)
		{
			PrintCenterTextAll("%t", "warden_retire_nc", client);
		}
		RemoveTheWarden();
		Forward_OnWardenRemoved(client);
		Forward_OnWardenDeath(client);
	}
}

//Warden disconnect

public void OnClientDisconnect(int client)
{
	if(IsClientWarden(client))
	{
		CPrintToChatAll("%t %t", "warden_tag" , "warden_disconnected", client);
		
		if(gc_bBetterNotes.BoolValue)
		{
			PrintCenterTextAll("%t", "warden_disconnected_nc", client);
		}
		Forward_OnWardenRemoved(client);
		Forward_OnWardenDisconnected(client);
		if(gc_bSounds.BoolValue)
		{
			EmitSoundToAllAny(g_sUnWarden);
		}
		g_iWarden = -1;
	}
	
	Painter_OnClientDisconnect(client);
	HandCuffs_OnClientDisconnect(client);
}

//Set a new warden

void SetTheWarden(int client)
{
	if(gc_bPlugin.BoolValue)
	{
		CPrintToChatAll("%t %t", "warden_tag" , "warden_new", client);
		if(gc_bBetterNotes.BoolValue) PrintCenterTextAll("%t", "warden_new_nc", client);
		
		g_iWarden = client;

		GetEntPropString(client, Prop_Data, "m_ModelName", g_sModelPath, sizeof(g_sModelPath));
		if(gc_bModel.BoolValue)
		{
			SetEntityModel(client, g_sWardenModel);
		}
		SetClientListeningFlags(client, VOICE_NORMAL);
		Forward_OnWardenCreation(client);
		
		if(gc_bSounds.BoolValue)
		{
			EmitSoundToAllAny(g_sWarden);
		}
		if (RandomTimer != null)
		KillTimer(RandomTimer);
			
		RandomTimer = null;
	}
	else CPrintToChat(client, "%t %t", "warden_tag" , "warden_disabled");
}

//Remove player Warden

public Action AdminCommand_RemoveWarden(int client, int args)
{
	if(g_iWarden != -1)
	{
		CPrintToChatAll("%t %t", "warden_tag" , "warden_removed", client, g_iWarden);  // if client is console !=
		if(gc_bBetterNotes.BoolValue) PrintCenterTextAll("%t", "warden_removed_nc", client, g_iWarden);
		
		if(MyJBLogging(true)) LogToFileEx(g_sMyJBLogFile, "Admin %L removed player %L as warden", client, g_iWarden);
		
		RemoveTheWarden();
		Forward_OnWardenRemovedByAdmin(client);
	}
	return Plugin_Handled;
}

void RemoveTheWarden()
{
	CreateTimer( 0.1, Timer_RemoveColor, g_iWarden);
	SetEntityModel(g_iWarden, g_sModelPath);
	if (RandomTimer != null)
		KillTimer(RandomTimer);
	
	RandomTimer = null;
	RandomTimer = CreateTimer(gc_fRandomTimer.FloatValue, ChooseRandom);
	
	Forward_OnWardenRemoved(g_iWarden);
	
	if(gc_bSounds.BoolValue)
	{
		EmitSoundToAllAny(g_sUnWarden);
	}
	
	g_iVoteCount = 0;
	Format(g_sHasVoted, sizeof(g_sHasVoted), "");
	g_sHasVoted[0] = '\0';
	
	g_iWarden = -1;
}

public void OnMapEnd()
{
	if (g_iWarden != -1)
	{
		CreateTimer(0.1, Timer_RemoveColor, g_iWarden);
		Forward_OnWardenRemoved(g_iWarden);
		g_iWarden = -1;
	}
	
	Math_OnMapEnd();
	Mute_OnMapEnd();
	Countdown_OnMapEnd();
	Reminder_OnMapEnd();
	HandCuffs_OnMapEnd();
	Marker_OnMapEnd();
	Laser_OnMapEnd();
	Painter_OnMapEnd();
}


//choose random warden

public Action ChooseRandom(Handle timer, Handle pack)
{
	if(gc_bPlugin.BoolValue)
	{
		if(!IsWardenExist)
		{
			if(gc_bChooseRandom.BoolValue)
			{
				int i = GetRandomPlayer(CS_TEAM_CT);
				if(i > 0)
				{
					CPrintToChatAll("%t %t", "warden_tag", "warden_randomwarden"); 
					SetTheWarden(i);
				}
			}
		}
	}
	if (RandomTimer != null)
		KillTimer(RandomTimer);
			
	RandomTimer = null;
}

public int OnAvailableLR(int Announced)
{
	IsLR = true;
	
	GunDropPrevention_OnAvailableLR(Announced);
	Mute_OnAvailableLR(Announced);
	HandCuffs_OnAvailableLR(Announced);
}

// Check Keyboard Input for modules

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if(IsClientWarden(client) && gc_bPlugin.BoolValue)
	{
		HandCuffs_OnPlayerRunCmd(client, buttons, impulse, vel, angles, weapon);
		Marker_OnPlayerRunCmd(client, buttons, impulse, vel, angles, weapon);
		Laser_OnPlayerRunCmd(client, buttons, impulse, vel, angles, weapon);
		Painter_OnPlayerRunCmd(client, buttons, impulse, vel, angles, weapon);
	}
	return Plugin_Continue;
}

//Stocks

stock bool IsWardenExist()
{
	if(!IsWardenExist)
	{
		return false;
	}
	return true;
}

stock bool IsClientWarden(int client)
{
	if(client != g_iWarden)
	{
		return false;
	}
	return true;
}

//Natives

public int Native_ExistWarden(Handle plugin, int numParams)
{
	if(!IsWardenExist)
	{
		return false;
	}
	return true;
}

public int Native_IsWarden(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if(!IsClientInGame(client) && !IsClientConnected(client))
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);
	
	if(IsClientWarden(client))
		return true;
	
	return false;
}

public int Native_SetWarden(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!IsClientInGame(client) && !IsClientConnected(client))
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);
	
	if(!IsWardenExist)
		SetTheWarden(client);
}

public int Native_RemoveWarden(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!IsClientInGame(client) && !IsClientConnected(client))
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);
	
	if(IsClientWarden(client))
		RemoveTheWarden();
}

public int Native_GetWarden(Handle plugin, int argc)
{
	return g_iWarden;
}

//Forwards

void Forward_OnWardenCreation(int client)
{
	Call_StartForward(gF_OnWardenCreated);
	Call_PushCell(client);
	Call_Finish();
	
	Icon_OnWardenCreation(client);
	Color_OnWardenCreation(client);
	Laser_OnWardenCreation(client);
	Painter_OnWardenCreation(client);

}

void Forward_OnWardenRemoved(int client)
{
	Call_StartForward(gF_OnWardenRemoved);
	Call_PushCell(client);
	Call_Finish();
	
	
	Marker_OnWardenRemoved();
	Icon_OnWardenRemoved(client);
	Color_OnWardenRemoved(client);
	Laser_OnWardenRemoved(client);
	Painter_OnWardenRemoved(client);
}

void Forward_OnWardenCreatedByUser(int client)
{
	Call_StartForward(gF_OnWardenCreatedByUser);
	Call_PushCell(client);
	Call_Finish();
}

void Forward_OnWardenCreatedByAdmin(int client)
{
	Call_StartForward(gF_OnWardenCreatedByAdmin);
	Call_PushCell(client);
	Call_Finish();
}

void Forward_OnWardenRemovedByAdmin(int client)
{
	Call_StartForward(gF_OnWardenRemovedByAdmin);
	Call_PushCell(client);
	Call_Finish();
}

void Forward_OnWardenRemovedBySelf(int client)
{
	Call_StartForward(gF_OnWardenRemovedBySelf);
	Call_PushCell(client);
	Call_Finish();
}

void Forward_OnWardenDisconnected(int client)
{
	Call_StartForward(gF_OnWardenDisconnected);
	Call_PushCell(client);
	Call_Finish();
}

void Forward_OnWardenDeath(int client)
{
	Call_StartForward(gF_OnWardenDeath);
	Call_PushCell(client);
	Call_Finish();
}