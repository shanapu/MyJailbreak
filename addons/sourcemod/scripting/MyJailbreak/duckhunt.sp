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
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */


/******************************************************************************
                   STARTUP
******************************************************************************/


//Includes
#include <myjailbreak> //... all other includes in myjailbreak.inc


//Compiler Options
#pragma semicolon 1
#pragma newdecls required


//Booleans
bool IsDuckHunt;
bool StartDuckHunt;


//Console Variables
ConVar gc_bPlugin;
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_bVote;
ConVar gc_iHunterHP;
ConVar gc_iChickenHP;
ConVar gc_bSounds;
ConVar gc_fBeaconTime;
ConVar gc_sSoundStartPath;
ConVar gc_iCooldownDay;
ConVar gc_iRoundTime;
ConVar gc_iCooldownStart;
ConVar gc_iTruceTime;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar g_iGetRoundTime;
ConVar g_bAllowTP;
ConVar gc_iRounds;
ConVar gc_sCustomCommand;
ConVar gc_sAdminFlag;
ConVar gc_bAllowLR;
ConVar g_ciTsLR;

//Integers
int g_iOldRoundTime;
int g_iCoolDown;
int g_iTruceTime;
int g_iVoteCount;
int g_iRound;
int g_iMaxRound;
int g_iTsLR;

//Handles
Handle TruceTimer;
Handle DuckHuntMenu;
Handle BeaconTimer;

//Strings

char g_sHasVoted[1500];
char g_sSoundStartPath[256];
char huntermodel[256] = "models/player/custom_player/legacy/tm_phoenix_heavy.mdl";
char g_sCustomCommand[64];
char g_sEventsLogFile[PLATFORM_MAX_PATH];
char g_sAdminFlag[32];
char g_sModelPathCTPrevious[MAXPLAYERS+1][256];
char g_sModelPathTPrevious[MAXPLAYERS+1][256];
char g_sOverlayStartPath[256];

public Plugin myinfo = {
	name = "MyJailbreak - DuckHunt",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = PLUGIN_VERSION,
	url = URL_LINK
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.DuckHunt.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_setduckhunt", SetDuckHunt, "Allows the Admin or Warden to set duckhunt as next round");
	RegConsoleCmd("sm_duckhunt", VoteDuckHunt, "Allows players to vote for a duckhunt");
	
	//AutoExecConfig
	AutoExecConfig_SetFile("DuckHunt", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_duckhunt_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_duckhunt_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_sCustomCommand = AutoExecConfig_CreateConVar("sm_duckhunt_cmd", "duck", "Set your custom chat command for Event voting. no need for sm_ or !");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_duckhunt_warden", "1", "0 - disabled, 1 - allow warden to set duckhunt round", _, true,  0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_duckhunt_admin", "1", "0 - disabled, 1 - allow admin/vip to set duckhunt round", _, true,  0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_duckhunt_flag", "g", "Set flag for admin/vip to set this Event Day.");
	gc_bVote = AutoExecConfig_CreateConVar("sm_duckhunt_vote", "1", "0 - disabled, 1 - allow player to vote for duckhunt", _, true,  0.0, true, 1.0);
	gc_iRounds = AutoExecConfig_CreateConVar("sm_duckhunt_rounds", "1", "Rounds to play in a row", _, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_duckhunt_roundtime", "5", "Round time in minutes for a single duckhunt round", _, true, 1.0);
	gc_fBeaconTime = AutoExecConfig_CreateConVar("sm_duckhunt_beacon_time", "240", "Time in seconds until the beacon turned on (set to 0 to disable)", _, true, 0.0);
	gc_iChickenHP = AutoExecConfig_CreateConVar("sm_duckhunt_chicken_hp", "100", "THP the chicken got on Spawn", _, true, 1.0);
	gc_iHunterHP = AutoExecConfig_CreateConVar("sm_duckhunt_hunter_hp", "850", "HP the hunters got on Spawn", _, true, 1.0);
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_duckhunt_trucetime", "15", "Time in seconds until cells open / players can't deal damage", _, true,  0.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_duckhunt_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true,  0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_duckhunt_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true,  0.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_duckhunt_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true,  0.0, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_duckhunt_sounds_start", "music/MyJailbreak/duckhunt.mp3", "Path to the soundfile which should be played for start");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_duckhunt_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true,  0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_duckhunt_overlays_start", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_bAllowLR = AutoExecConfig_CreateConVar("sm_duckhunt_allow_lr", "0" , "0 - disabled, 1 - enable LR for last round and end eventday", _, true, 0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("weapon_reload", Event_WeaponReload);
	HookEvent("hegrenade_detonate", Event_HE_Detonate);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sCustomCommand, OnSettingChanged);
	HookConVarChange(gc_sAdminFlag, OnSettingChanged);
	
	//FindConVar
	g_bAllowTP = FindConVar("sv_allow_thirdperson");
	g_iGetRoundTime = FindConVar("mp_roundtime");
	g_ciTsLR = FindConVar("sm_hosties_lr_ts_max");
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	gc_sOverlayStartPath.GetString(g_sOverlayStartPath , sizeof(g_sOverlayStartPath));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
	gc_sCustomCommand.GetString(g_sCustomCommand , sizeof(g_sCustomCommand));
	gc_sAdminFlag.GetString(g_sAdminFlag , sizeof(g_sAdminFlag));

	if(g_bAllowTP == INVALID_HANDLE)
	{
		SetFailState("sv_allow_thirdperson not found!");
	}
	
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
	else if(convar == gc_sSoundStartPath)
	{
		strcopy(g_sSoundStartPath, sizeof(g_sSoundStartPath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStartPath);
	}
	else if(convar == gc_sAdminFlag)
	{
		strcopy(g_sAdminFlag, sizeof(g_sAdminFlag), newValue);
	}
	else if(convar == gc_sCustomCommand)
	{
		strcopy(g_sCustomCommand, sizeof(g_sCustomCommand), newValue);
		char sBufferCMD[64];
		Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
		if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
			RegConsoleCmd(sBufferCMD, VoteDuckHunt, "Allows players to vote for a duckhunt");
	}
}

//Initialize Event

public void OnMapStart()
{
	g_iVoteCount = 0;
	g_iRound = 0;
	IsDuckHunt = false;
	StartDuckHunt = false;
	
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayStartPath);
	if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStartPath);
	PrecacheModel("models/chicken/chicken.mdl", true);
	PrecacheModel(huntermodel, true);
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
	g_iMaxRound = gc_iRounds.IntValue;
	
	char sBufferCMD[64];
	Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
	if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMD, VoteDuckHunt, "Allows players to vote for a duckhunt");
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

//Admin & Warden set Event

public Action SetDuckHunt(int client,int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if(client == 0)
		{
			StartNextRound();
			if(ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event DuckHunt was started by groupvoting");
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
							if(ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event Duckhunt was started by warden %L", client);
						}
						else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_progress" , EventDay);
				}
				else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_minplayer");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "duckhunt_setbywarden");
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
								if(ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event Duckhunt was started by admin %L", client);
							}
							else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_wait", g_iCoolDown);
						}
						else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_progress" , EventDay);
					}
					else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_minplayer");
				}
				else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_setbyadmin");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_disabled");
}

//Voting for Event

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
							
							if (g_iVoteCount > playercount)
							{
								StartNextRound();
								if(ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event Duckhunt was started by voting");
							}
							else CPrintToChatAll("%t %t", "duckhunt_tag" , "duckhunt_need", Missing, client);
						}
						else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_voted");
					}
					else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_wait", g_iCoolDown);
				}
				else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_progress", EventDay);
			}
			else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_minplayer");
		}
		else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_voting");
	}
	else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_disabled");
}

//Prepare Event

void StartNextRound()
{
	StartDuckHunt = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;
	
	char buffer[32];
	Format(buffer, sizeof(buffer), "%T", "duckhunt_name", LANG_SERVER);
	SetEventDayName(buffer);
	SetEventDayPlanned(true);
	
	g_iOldRoundTime = g_iGetRoundTime.IntValue; //save original round time
	g_iGetRoundTime.IntValue = gc_iRoundTime.IntValue;//set event round time
	
	CPrintToChatAll("%t %t", "duckhunt_tag" , "duckhunt_next");
	PrintCenterTextAll("%t", "duckhunt_next_nc");
}

public Action Timer_SetModel(Handle timer)
{
	LoopValidClients(client, true, false)
	{
		if (GetClientTeam(client) == CS_TEAM_CT)
		{
			GetEntPropString(client, Prop_Data, "m_ModelName", g_sModelPathCTPrevious[client], sizeof(g_sModelPathCTPrevious[]));
			SetEntityModel(client, huntermodel);
		}
		if (GetClientTeam(client) == CS_TEAM_T)
		{
			GetEntPropString(client, Prop_Data, "m_ModelName", g_sModelPathTPrevious[client], sizeof(g_sModelPathTPrevious[]));
			SetEntityModel(client, "models/chicken/chicken.mdl");
		}
	}
}


public Action Timer_BeaconOn(Handle timer)
{
	LoopValidClients(i,true,false) BeaconOn(i, 2.0);
	BeaconTimer = null;
}

//Round start

public void Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	if (StartDuckHunt || IsDuckHunt)
	{
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_menu_enable", 0);
		SetCvar("sm_weapons_enable", 0);
		SetConVarInt(g_bAllowTP, 1);
		SetEventDayPlanned(false);
		SetEventDayRunning(true);
		
		if (gc_fBeaconTime.FloatValue > 0.0) BeaconTimer = CreateTimer(gc_fBeaconTime.FloatValue, Timer_BeaconOn, TIMER_FLAG_NO_MAPCHANGE);
		
		IsDuckHunt = true;
		g_iRound++;
		StartDuckHunt = false;
		
		if (g_iRound > 0)
			{
				LoopClients(client)
				{
					CreateInfoPanel(client);
					
					StripAllPlayerWeapons(client);
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
					
					if (GetClientTeam(client) == CS_TEAM_CT && IsValidClient(client, false, false))
					{
						SetEntityHealth(client, gc_iHunterHP.IntValue);
						GivePlayerItem(client, "weapon_nova");
					}
					if (GetClientTeam(client) == CS_TEAM_T && IsValidClient(client, false, false))
					{
						SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.2);
						SetEntityGravity(client, 0.3);
						SetEntityHealth(client, gc_iChickenHP.IntValue);
						GivePlayerItem(client, "weapon_hegrenade");
						ClientCommand(client, "thirdperson");
					}
				}
				
				CreateTimer (1.1, Timer_SetModel);
				
				//enable lr on last round
				g_iTsLR = GetAliveTeamCount(CS_TEAM_T);
				
				if (gc_bAllowLR.BoolValue)
				{
					if ((g_iRound == g_iMaxRound) && (g_iTsLR > g_ciTsLR.IntValue))
					{
						SetCvar("sm_hosties_lr", 1);
					}
				}
				
				CPrintToChatAll("%t %t", "duckhunt_tag" ,"duckhunt_rounds", g_iRound, g_iMaxRound);
				g_iTruceTime--;
				TruceTimer = CreateTimer(1.0, StartTimer, _, TIMER_REPEAT);
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
	if (IsDuckHunt && gc_bAllowLR.BoolValue && (g_iTsLR > g_ciTsLR.IntValue))
	{
		LoopClients(client)
		{
			StripAllPlayerWeapons(client);
			
			if (IsValidClient(client, false, true))
			{
				SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
				SetEntityGravity(client, 1.0);
				FP(client);
				if (GetClientTeam(client) == CS_TEAM_CT)
				{
					FakeClientCommand(client, "sm_guns");
					SetEntityModel(client, g_sModelPathCTPrevious[client]);
				}
				
				if (GetClientTeam(client) == CS_TEAM_T)
					SetEntityModel(client, g_sModelPathTPrevious[client]);
			}
			GivePlayerItem(client, "weapon_knife");
			
		}
		
		delete BeaconTimer;
		if (TruceTimer != null) KillTimer(TruceTimer);
		if (g_iRound == g_iMaxRound)
		{
			IsDuckHunt = false;
			StartDuckHunt = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			
			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_weapons_enable", 1);
			SetCvar("sm_warden_enable", 1);
			SetCvar("sm_menu_enable", 1);
			SetConVarInt(g_bAllowTP, 0);
			g_iGetRoundTime.IntValue = g_iOldRoundTime;
			SetEventDayName("none");
			SetEventDayRunning(false);
			CPrintToChatAll("%t %t", "duckhunt_tag" , "duckhunt_end");
		}
	}

}

stock void CreateInfoPanel(int client)
{
	//Create info Panel
	char info[255];

	DuckHuntMenu = CreatePanel();
	Format(info, sizeof(info), "%T", "duckhunt_info_title", client);
	SetPanelTitle(DuckHuntMenu, info);
	DrawPanelText(DuckHuntMenu, "                                   ");
	Format(info, sizeof(info), "%T", "duckhunt_info_line1", client);
	DrawPanelText(DuckHuntMenu, info);
	DrawPanelText(DuckHuntMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "duckhunt_info_line2", client);
	DrawPanelText(DuckHuntMenu, info);
	Format(info, sizeof(info), "%T", "duckhunt_info_line3", client);
	DrawPanelText(DuckHuntMenu, info);
	Format(info, sizeof(info), "%T", "duckhunt_info_line4", client);
	DrawPanelText(DuckHuntMenu, info);
	Format(info, sizeof(info), "%T", "duckhunt_info_line5", client);
	DrawPanelText(DuckHuntMenu, info);
	Format(info, sizeof(info), "%T", "duckhunt_info_line6", client);
	DrawPanelText(DuckHuntMenu, info);
	Format(info, sizeof(info), "%T", "duckhunt_info_line7", client);
	DrawPanelText(DuckHuntMenu, info);
	DrawPanelText(DuckHuntMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "warden_close", client);
	DrawPanelItem(DuckHuntMenu, info); 
	SendPanelToClient(DuckHuntMenu, client, Handler_NullCancel, 20);
}

//Round End

public void Event_RoundEnd(Event event, char[] name, bool dontBroadcast)
{
	int winner = event.GetInt("winner");
	
	if (IsDuckHunt)
	{
		LoopClients(client)
		{
			if (IsValidClient(client, false, true))
				{
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
					SetEntityGravity(client, 1.0);
					FP(client);
				}
		}
		delete BeaconTimer;
		if (TruceTimer != null) KillTimer(TruceTimer);
		if (winner == 2) PrintCenterTextAll("%t", "duckhunt_twin_nc");
		if (winner == 3) PrintCenterTextAll("%t", "duckhunt_ctwin_nc");
		if (g_iRound == g_iMaxRound)
		{
			IsDuckHunt = false;
			StartDuckHunt = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			
			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_weapons_enable", 1);
			SetCvar("sm_warden_enable", 1);
			SetCvar("sm_menu_enable", 1);
			SetConVarInt(g_bAllowTP, 0);
			g_iGetRoundTime.IntValue = g_iOldRoundTime;
			SetEventDayName("none");
			SetEventDayRunning(false);
			CPrintToChatAll("%t %t", "duckhunt_tag" , "duckhunt_end");
		}
	}
	if (StartDuckHunt)
	{
		LoopClients(i) CreateInfoPanel(i);
		
		CPrintToChatAll("%t %t", "duckhunt_tag" , "duckhunt_next");
		PrintCenterTextAll("%t", "duckhunt_next_nc");
	}
}

//Map End

public void OnMapEnd()
{
	IsDuckHunt = false;
	StartDuckHunt = false;
	delete TruceTimer;
	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
	LoopClients(client)
	{
		FP(client);
	}
}

//Start Timer

public Action StartTimer(Handle timer)
{
	if (g_iTruceTime > 1)
	{
		g_iTruceTime--;
		LoopClients(client) if (IsPlayerAlive(client))
		{
			PrintCenterText(client,"%t", "duckhunt_timeuntilstart_nc", g_iTruceTime);
		}
		return Plugin_Continue;
	}
	
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	if (g_iRound > 0)
	{
		LoopClients(client) if(IsPlayerAlive(client))
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
			PrintCenterText(client,"%t", "duckhunt_start_nc");
			if(gc_bOverlays.BoolValue) ShowOverlay(client, g_sOverlayStartPath, 2.0);
			if(gc_bSounds.BoolValue)	
			{
				EmitSoundToAllAny(g_sSoundStartPath);
			}
		}
		CPrintToChatAll("%t %t", "duckhunt_tag" , "duckhunt_start");
	}
	SJD_OpenDoors();
	TruceTimer = null;
	return Plugin_Stop;
}

//Nova & Grenade only

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

// Only right click attack for chicken

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon) 
{
	if(IsDuckHunt == true)
	{
		if((GetClientTeam(client) == CS_TEAM_T) && IsClientInGame(client) && IsPlayerAlive(client) && buttons & IN_ATTACK)
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

//Give new Nades after detonation to chicken

public void Event_HE_Detonate(Event event, const char[] name, bool dontBroadcast)
{
	if (IsDuckHunt == true)
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

//Give new Ammo to Hunter

public void Event_WeaponReload(Event event, char [] name, bool dontBroadcast)
{
	if(IsDuckHunt == true)
	{
		int client = GetClientOfUserId(event.GetInt("userid"));
		if(IsValidClient(client, false, false) && (GetClientTeam(client) == CS_TEAM_CT))
		{
			SetPlayerWeaponAmmo(client, Client_GetActiveWeapon(client), _, 32);
		}
	}
}


//Back to First Person

public Action FP(int client)
{
	if(IsValidClient(client, false, true))
	{
		ClientCommand(client, "firstperson");
	}
}

public void OnClientDisconnect(int client)
{
	if (IsDuckHunt == true)
	{
		FP(client);
	}
}

public void Event_PlayerDeath(Event event, char [] name, bool dontBroadcast)
{
	if(IsDuckHunt == true)
	{
		int client = GetClientOfUserId(event.GetInt("userid"));
		FP(client);
	}
}
