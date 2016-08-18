/*
 * MyJailbreak - Knife Fight Event Day Plugin.
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
bool IsKnifeFight; 
bool StartKnifeFight; 


//Console Variables
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
ConVar gc_fBeaconTime;
ConVar gc_iRoundTime;
ConVar gc_iTruceTime;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar gc_bSounds;
ConVar gc_sSoundStartPath;
ConVar gc_iRounds;
ConVar gc_sCustomCommandVote;
ConVar gc_sCustomCommandSet;
ConVar gc_sAdminFlag;
ConVar gc_bAllowLR;


//Extern Convars
ConVar g_iMPRoundTime;
ConVar g_iTerrorForLR;
ConVar g_bAllowTP;


//Integers
int g_iOldRoundTime;
int g_iCoolDown;
int g_iTruceTime;
int g_iVoteCount;
int g_iRound;
int g_iMaxRound;
int g_iTsLR;


//Floats
float g_fPos[3];


//Handles
Handle TruceTimer;
Handle GravityTimer;
Handle KnifeFightMenu;
Handle BeaconTimer;


//Strings
char g_sHasVoted[1500];
char g_sSoundStartPath[256];
char g_sEventsLogFile[PLATFORM_MAX_PATH];
char g_sAdminFlag[32];
char g_sOverlayStartPath[256];


//Info
public Plugin myinfo = {
	name = "MyJailbreak - KnifeFight",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = PLUGIN_VERSION,
	url = URL_LINK
};


//Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.KnifeFight.phrases");
	
	
	//Client Commands
	RegConsoleCmd("sm_setknifefight", Command_SetKnifeFight, "Allows the Admin or Warden to set knifefight as next round");
	RegConsoleCmd("sm_knifefight", Command_VoteKnifeFight, "Allows players to vote for a knifefight");
	
	
	//AutoExecConfig
	AutoExecConfig_SetFile("KnifeFight", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_knifefight_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_knifefight_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_sCustomCommandVote = AutoExecConfig_CreateConVar("sm_knifefight_cmds_vote", "knifeday", "Set your custom chat command for Event voting(!knifefight (no 'sm_'/'!')(seperate with comma ',')(max. 12 commands))");
	gc_sCustomCommandSet = AutoExecConfig_CreateConVar("sm_knifefight_cmds_set", "sknifefight,sknife", "Set your custom chat command for set Event(!setknifefight (no 'sm_'/'!')(seperate with comma ',')(max. 12 commands))");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_knifefight_warden", "1", "0 - disabled, 1 - allow warden to set knifefight round", _, true,  0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_knifefight_admin", "1", "0 - disabled, 1 - allow admin/vip to set knifefight round", _, true,  0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_knifefight_flag", "g", "Set flag for admin/vip to set this Event Day.");
	gc_bVote = AutoExecConfig_CreateConVar("sm_knifefight_vote", "1", "0 - disabled, 1 - allow player to vote for knifefight", _, true,  0.0, true, 1.0);
	gc_bSpawnCell = AutoExecConfig_CreateConVar("sm_knifefight_spawn", "0", "0 - T teleport to CT spawn, 1 - cell doors auto open", _, true,  0.0, true, 1.0);
	gc_iRounds = AutoExecConfig_CreateConVar("sm_knifefight_rounds", "1", "Rounds to play in a row", _, true, 1.0);
	gc_bThirdPerson = AutoExecConfig_CreateConVar("sm_knifefight_thirdperson", "1", "0 - disabled, 1 - enable thirdperson", _, true,  0.0, true, 1.0);
	gc_bGrav = AutoExecConfig_CreateConVar("sm_knifefight_gravity", "1", "0 - disabled, 1 - enable low gravity", _, true,  0.0, true, 1.0);
	gc_fGravValue= AutoExecConfig_CreateConVar("sm_knifefight_gravity_value", "0.3","Ratio for Gravity 1.0 earth 0.5 moon", _, true, 0.1, true, 1.0);
	gc_bIce = AutoExecConfig_CreateConVar("sm_knifefight_iceskate", "1", "0 - disabled, 1 - enable iceskate", _, true,  0.0, true, 1.0);
	gc_fIceValue= AutoExecConfig_CreateConVar("sm_knifefight_iceskate_value", "c","Ratio iceskate (5.2 normal)", _, true, 0.1, true, 5.2);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_knifefight_roundtime", "5", "Round time in minutes for a single knifefight round", _, true, 1.0);
	gc_fBeaconTime = AutoExecConfig_CreateConVar("sm_knifefight_beacon_time", "240", "Time in seconds until the beacon turned on (set to 0 to disable)", _, true, 0.0);
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_knifefight_trucetime", "15", "Time in seconds players can't deal damage", _, true, 0.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_knifefight_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true, 0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_knifefight_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true, 0.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_knifefight_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true, 0.0, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_knifefight_sounds_start", "music/MyJailbreak/start.mp3", "Path to the soundfile which should be played for a start.");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_knifefight_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true,  0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_knifefight_overlays_start", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_bAllowLR = AutoExecConfig_CreateConVar("sm_knifefight_allow_lr", "0" , "0 - disabled, 1 - enable LR for last round and end eventday", _, true, 0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	
	//Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_death", Event_PlayerDeath);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sAdminFlag, OnSettingChanged);
	
	
	//Find
	g_bAllowTP = FindConVar("sv_allow_thirdperson");
	g_iMPRoundTime = FindConVar("mp_roundtime");
	g_iTerrorForLR = FindConVar("sm_hosties_lr_ts_max");
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;
	gc_sOverlayStartPath.GetString(g_sOverlayStartPath , sizeof(g_sOverlayStartPath));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
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
	else if(convar == gc_sAdminFlag)
	{
		strcopy(g_sAdminFlag, sizeof(g_sAdminFlag), newValue);
	}
	else if(convar == gc_sSoundStartPath)
	{
		strcopy(g_sSoundStartPath, sizeof(g_sSoundStartPath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStartPath);
	}
}


//Initialize Plugin
public void OnConfigsExecuted()
{
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iMaxRound = gc_iRounds.IntValue;
	
	
	//Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];
	
	//Vote
	gc_sCustomCommandVote.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));
	
	for(int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if(GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  //if command not already exist
			RegConsoleCmd(sCommand, Command_VoteKnifeFight, "Allows players to vote for a knifefight");
	}
	
	//Set
	gc_sCustomCommandSet.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));
	
	for(int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if(GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  //if command not already exist
			RegConsoleCmd(sCommand, Command_SetKnifeFight, "Allows the Admin or Warden to set knifefight as next round");
	}
}


/******************************************************************************
                   COMMANDS
******************************************************************************/


//Admin & Warden set Event
public Action Command_SetKnifeFight(int client,int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if(client == 0)
		{
			StartNextRound();
			if(ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event KnifeFight was started by groupvoting");
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
							if(ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event KnifeFight was started by warden %L", client);
						}
						else CReplyToCommand(client, "%t %t", "knifefight_tag" , "knifefight_wait", g_iCoolDown);
					}
					else CReplyToCommand(client, "%t %t", "knifefight_tag" , "knifefight_progress" , EventDay);
				}
				else CReplyToCommand(client, "%t %t", "knifefight_tag" , "knifefight_minplayer");
			}
			else CReplyToCommand(client, "%t %t", "warden_tag" , "knifefight_setbywarden");
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
							if(ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event KnifeFight was started by admin %L", client);
						}
						else CReplyToCommand(client, "%t %t", "knifefight_tag" , "knifefight_wait", g_iCoolDown);
					}
					else CReplyToCommand(client, "%t %t", "knifefight_tag" , "knifefight_progress" , EventDay);
				}
				else CReplyToCommand(client, "%t %t", "knifefight_tag" , "knifefight_minplayer");
			}
			else CReplyToCommand(client, "%t %t", "knifefight_tag" , "knifefight_setbyadmin");
		}
		else CReplyToCommand(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CReplyToCommand(client, "%t %t", "knifefight_tag" , "knifefight_disabled");
	return Plugin_Handled;
}


//Voting for Event
public Action Command_VoteKnifeFight(int client,int args)
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
							
							if (g_iVoteCount > playercount)
							{
								StartNextRound();
								if(ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event KnifeFight was started by voting");
							}
							else CPrintToChatAll("%t %t", "knifefight_tag" , "knifefight_need", Missing, client);
						}
						else CReplyToCommand(client, "%t %t", "knifefight_tag" , "knifefight_voted");
					}
					else CReplyToCommand(client, "%t %t", "knifefight_tag" , "knifefight_wait", g_iCoolDown);
				}
				else CReplyToCommand(client, "%t %t", "knifefight_tag" , "knifefight_progress" , EventDay);
			}
			else CReplyToCommand(client, "%t %t", "knifefight_tag" , "knifefight_minplayer");
		}
		else CReplyToCommand(client, "%t %t", "knifefight_tag" , "knifefight_voting");
	}
	else CReplyToCommand(client, "%t %t", "knifefight_tag" , "knifefight_disabled");
	return Plugin_Handled;
}


/******************************************************************************
                   EVENTS
******************************************************************************/


//Round start
public void Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	if (StartKnifeFight || IsKnifeFight)
	{
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_weapons_enable", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_menu_enable", 0);
		SetCvar("mp_teammates_are_enemies", 1);
		SetEventDayPlanned(false);
		SetEventDayRunning(true);
		SetConVarInt(g_bAllowTP, 1);
		IsKnifeFight = true;
		
		g_iRound++;
		StartKnifeFight = false;
		SJD_OpenDoors();
		
		if (gc_fBeaconTime.FloatValue > 0.0) BeaconTimer = CreateTimer(gc_fBeaconTime.FloatValue, Timer_BeaconOn, TIMER_FLAG_NO_MAPCHANGE);
		
		int RandomCT = 0;
		
		LoopClients(client) 
		{
			if (GetClientTeam(client) == CS_TEAM_CT)
			{
				RandomCT = client;
				break;
			}
		}
		if (RandomCT)
		{
			GetClientAbsOrigin(RandomCT, g_fPos);
			
			g_fPos[2] = g_fPos[2] + 5;
			
			if (g_iRound > 0)
			{
				LoopClients(client)
				{
					CreateInfoPanel(client);
					
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
					StripAllPlayerWeapons(client);
					GivePlayerItem(client, "weapon_knife");
					
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
					if (!gc_bSpawnCell.BoolValue || (gc_bSpawnCell.BoolValue && !SJD_IsCurrentMapConfigured)) //spawn Terrors to CT Spawn 
					{
						TeleportEntity(client, g_fPos, NULL_VECTOR, NULL_VECTOR);
					}
				}
				g_iTruceTime--;
				TruceTimer = CreateTimer(1.0, Timer_StartEvent, _, TIMER_REPEAT);
				if (gc_bGrav.BoolValue)
				{
					GravityTimer = CreateTimer(1.0, Timer_CheckGravity, _, TIMER_REPEAT);
				}
				
				//enable lr on last round
				g_iTsLR = GetAliveTeamCount(CS_TEAM_T);
				
				if (gc_bAllowLR.BoolValue)
				{
					if ((g_iRound == g_iMaxRound) && (g_iTsLR > g_iTerrorForLR.IntValue))
					{
						SetCvar("sm_hosties_lr", 1);
					}
				}
				
				CPrintToChatAll("%t %t", "knifefight_tag" ,"knifefight_rounds", g_iRound, g_iMaxRound);
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


//Round End
public void Event_RoundEnd(Event event, char[] name, bool dontBroadcast)
{
	int winner = event.GetInt("winner");
	
	if (IsKnifeFight)
	{
		LoopValidClients(client, false, true)
		{
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
			SetEntityGravity(client, 1.0);
			FP(client);
		}
		delete TruceTimer;
		delete BeaconTimer;
		delete GravityTimer;
		if (winner == 2) PrintCenterTextAll("%t", "knifefight_twin_nc");
		if (winner == 3) PrintCenterTextAll("%t", "knifefight_ctwin_nc");
		if (g_iRound == g_iMaxRound)
		{
			IsKnifeFight = false;
			StartKnifeFight = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_weapons_enable", 1);
			SetCvar("sm_warden_enable", 1);
			SetCvar("sm_menu_enable", 1);
			SetCvar("mp_teammates_are_enemies", 0);
			SetCvarFloat("sv_friction", 5.2);
			SetConVarInt(g_bAllowTP, 0);
			g_iMPRoundTime.IntValue = g_iOldRoundTime;
			SetEventDayName("none");
			SetEventDayRunning(false);
			CPrintToChatAll("%t %t", "knifefight_tag" , "knifefight_end");
		}
	}
	if (StartKnifeFight)
	{
		LoopClients(i) CreateInfoPanel(i);
		
		CPrintToChatAll("%t %t", "knifefight_tag" , "knifefight_next");
		PrintCenterTextAll("%t", "knifefight_next_nc");
	}
}


public void Event_PlayerDeath(Event event, char [] name, bool dontBroadcast)
{
	if(IsKnifeFight == true)
	{
		int client = GetClientOfUserId(event.GetInt("userid"));
		FP(client);
	}
}


/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/


//Initialize Event
public void OnMapStart()
{
	g_iVoteCount = 0;
	g_iRound = 0;
	IsKnifeFight = false;
	StartKnifeFight = false;
	
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayStartPath);
	if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStartPath);
}


//Map End
public void OnMapEnd()
{
	IsKnifeFight = false;
	StartKnifeFight = false;
	delete TruceTimer;
	delete GravityTimer;
	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
	LoopClients(client) FP(client);
}


//Listen for Last Lequest
public int OnAvailableLR(int Announced)
{
	if (IsKnifeFight && gc_bAllowLR.BoolValue && (g_iTsLR > g_iTerrorForLR.IntValue))
	{
		LoopValidClients(client, false, true)
		{
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
			SetEntityGravity(client, 1.0);
			FP(client);
			StripAllPlayerWeapons(client);
			if (GetClientTeam(client) == CS_TEAM_CT)
			{
				FakeClientCommand(client, "sm_weapons");
			}
			GivePlayerItem(client, "weapon_knife");
		}
		delete BeaconTimer;
		delete TruceTimer;
		delete GravityTimer;
		if (g_iRound == g_iMaxRound)
		{
			IsKnifeFight = false;
			StartKnifeFight = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_weapons_enable", 1);
			SetCvar("sm_warden_enable", 1);
			SetCvar("sm_menu_enable", 1);
			SetCvar("mp_teammates_are_enemies", 0);
			SetCvarFloat("sv_friction", 5.2);
			SetConVarInt(g_bAllowTP, 0);
			g_iMPRoundTime.IntValue = g_iOldRoundTime;
			SetEventDayName("none");
			SetEventDayRunning(false);
			CPrintToChatAll("%t %t", "knifefight_tag" , "knifefight_end");
		}
	}
}


public void OnClientDisconnect(int client)
{
	if (IsKnifeFight == true)
	{
		FP(client);
	}
}


//Set Client Hook
public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}


//Knife only
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


/******************************************************************************
                   FUNCTIONS
******************************************************************************/


//Prepare Event
void StartNextRound()
{
	StartKnifeFight = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;
	
	char buffer[32];
	Format(buffer, sizeof(buffer), "%T", "knifefight_name", LANG_SERVER);
	SetEventDayName(buffer);
	SetEventDayPlanned(true);
	
	g_iOldRoundTime = g_iMPRoundTime.IntValue; //save original round time
	g_iMPRoundTime.IntValue = gc_iRoundTime.IntValue;//set event round time
	
	CPrintToChatAll("%t %t", "knifefight_tag" , "knifefight_next");
	PrintCenterTextAll("%t", "knifefight_next_nc");
}


//Back to First Person
public Action FP(int client)
{
	if(IsValidClient(client, false, true))
	{
		ClientCommand(client, "firstperson");
	}
}


/******************************************************************************
                   MENUS
******************************************************************************/


stock void CreateInfoPanel(int client)
{
	//Create info Panel
	char info[255];
	
	KnifeFightMenu = CreatePanel();
	Format(info, sizeof(info), "%T", "knifefight_info_title", client);
	SetPanelTitle(KnifeFightMenu, info);
	DrawPanelText(KnifeFightMenu, "                                   ");
	Format(info, sizeof(info), "%T", "knifefight_info_line1", client);
	DrawPanelText(KnifeFightMenu, info);
	DrawPanelText(KnifeFightMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "knifefight_info_line2", client);
	DrawPanelText(KnifeFightMenu, info);
	Format(info, sizeof(info), "%T", "knifefight_info_line3", client);
	DrawPanelText(KnifeFightMenu, info);
	Format(info, sizeof(info), "%T", "knifefight_info_line4", client);
	DrawPanelText(KnifeFightMenu, info);
	Format(info, sizeof(info), "%T", "knifefight_info_line5", client);
	DrawPanelText(KnifeFightMenu, info);
	Format(info, sizeof(info), "%T", "knifefight_info_line6", client);
	DrawPanelText(KnifeFightMenu, info);
	Format(info, sizeof(info), "%T", "knifefight_info_line7", client);
	DrawPanelText(KnifeFightMenu, info);
	DrawPanelText(KnifeFightMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "warden_close", client);
	DrawPanelItem(KnifeFightMenu, info); 
	SendPanelToClient(KnifeFightMenu, client, Handler_NullCancel, 20);
}


/******************************************************************************
                   TIMER
******************************************************************************/


//Start Timer
public Action Timer_StartEvent(Handle timer)
{
	if (g_iTruceTime > 1)
	{
		g_iTruceTime--;
		LoopClients(client) if (IsPlayerAlive(client))
		{
			PrintCenterText(client,"%t", "knifefight_timeuntilstart_nc", g_iTruceTime);
		}
		return Plugin_Continue;
	}
	
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	if (g_iRound > 0)
	{
		LoopClients(client) if (IsPlayerAlive(client))
		{
			SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
			if (gc_bGrav.BoolValue)
			{
				SetEntityGravity(client, gc_fGravValue.FloatValue);	
			}
			PrintCenterText(client,"%t", "knifefight_start_nc");
			if(gc_bOverlays.BoolValue) ShowOverlay(client, g_sOverlayStartPath, 2.0);
			if(gc_bSounds.BoolValue)	
			{
				EmitSoundToAllAny(g_sSoundStartPath);
			}
		}
		CPrintToChatAll("%t %t", "knifefight_tag" , "knifefight_start");
	}
	TruceTimer = null;
	return Plugin_Stop;
}


//Beacon Timer
public Action Timer_BeaconOn(Handle timer)
{
	LoopValidClients(i,true,false) BeaconOn(i, 2.0);
	BeaconTimer = null;
}


//Give back Gravity if it gone -> ladders
public Action Timer_CheckGravity(Handle timer)
{
	LoopValidClients(client, false, false)
	{
		if(GetEntityGravity(client) != 1.0)
			SetEntityGravity(client, gc_fGravValue.FloatValue);
	}
}