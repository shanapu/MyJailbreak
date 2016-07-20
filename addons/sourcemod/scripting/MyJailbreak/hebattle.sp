//includes
#include <cstrike>
#include <sourcemod>
#include <smartjaildoors>
#include <warden>
#include <emitsoundany>
#include <colors>
#include <autoexecconfig>
#include <myjailbreak>
#include <lastrequest>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//Booleans
bool IsHEbattle; 
bool StartHEbattle; 

//ConVars
ConVar gc_bPlugin;
ConVar gc_bSetW;
ConVar gc_bGrav;
ConVar gc_fGravValue;
ConVar gc_iCooldownStart;
ConVar gc_bSetA;
ConVar gc_bVote;
ConVar gc_iPlayerHP;
ConVar gc_iCooldownDay;
ConVar gc_bSpawnCell;
ConVar gc_iRoundTime;
ConVar gc_iTruceTime;
ConVar gc_bSounds;
ConVar gc_sSoundStartPath;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar g_iGetRoundTime;
ConVar gc_iRounds;
ConVar gc_sCustomCommand;
ConVar gc_sAdminFlag;
ConVar gc_bAllowLR;

//Integers
int g_iOldRoundTime;
int g_iCoolDown;
int g_iTruceTime;
int g_iVoteCount;
int g_iRound;
int g_iMaxRound;

//Handles
Handle TruceTimer;
Handle GravityTimer;
Handle HEbattleMenu;

//Floats
float g_fPos[3];

//Strings
char g_sHasVoted[1500];
char g_sSoundStartPath[256];
char g_sCustomCommand[64];
char g_sEventsLogFile[PLATFORM_MAX_PATH];
char g_sAdminFlag[32];
char g_sOverlayStartPath[256];

public Plugin myinfo = {
	name = "MyJailbreak - HEbattle",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = PLUGIN_VERSION,
	url = URL_LINK
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.HEbattle.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_sethebattle", SetHEbattle, "Allows the Admin or Warden to set hebattle as next round");
	RegConsoleCmd("sm_hebattle", VoteHEbattle, "Allows players to vote for a hebattle");
	
	//AutoExecConfig
	AutoExecConfig_SetFile("HEbattle", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_hebattle_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_hebattle_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_sCustomCommand = AutoExecConfig_CreateConVar("sm_hebattle_cmd", "he", "Set your custom chat command for Event voting. no need for sm_ or !");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_hebattle_warden", "1", "0 - disabled, 1 - allow warden to set hebattle round", _, true,  0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_hebattle_admin", "1", "0 - disabled, 1 - allow admin/vip to set hebattle round", _, true,  0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_hebattle_flag", "g", "Set flag for admin/vip to set this Event Day.");
	gc_bVote = AutoExecConfig_CreateConVar("sm_hebattle_vote", "1", "0 - disabled, 1 - allow player to vote for hebattle", _, true,  0.0, true, 1.0);
	gc_bSpawnCell = AutoExecConfig_CreateConVar("sm_hebattle_spawn", "0", "0 - T teleport to CT spawn, 1 - cell doors auto open", _, true,  0.0, true, 1.0);
	gc_iPlayerHP = AutoExecConfig_CreateConVar("sm_hebattle_hp", "85", "HP a Player get on Spawn", _, true, 1.0);
	gc_bGrav = AutoExecConfig_CreateConVar("sm_hebattle_gravity", "1", "0 - disabled, 1 - enable low gravity", _, true,  0.0, true, 1.0);
	gc_fGravValue= AutoExecConfig_CreateConVar("sm_hebattle_gravity_value", "0.3","Ratio for gravity 0.5 moon / 1.0 earth ", _, true,  0.1, true, 1.0);
	gc_iRounds = AutoExecConfig_CreateConVar("sm_hebattle_rounds", "1", "Rounds to play in a row", _, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_hebattle_roundtime", "5", "Round time in minutes for a single hebattle round", _, true, 1.0);
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_hebattle_trucetime", "15", "Time in seconds players can't deal damage", _, true,  0.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_hebattle_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true,  0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_hebattle_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true,  0.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_hebattle_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true,  0.0, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_hebattle_sounds_start", "music/MyJailbreak/start.mp3", "Path to the soundfile which should be played for start");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_hebattle_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true,  0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_hebattle_overlays_start", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_bAllowLR = AutoExecConfig_CreateConVar("sm_hebattle_allow_lr", "0" , "0 - disabled, 1 - enable LR for last round and end eventday", _, true, 0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("round_end", RoundEnd);
	HookEvent("hegrenade_detonate", HE_Detonate);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sCustomCommand, OnSettingChanged);
	HookConVarChange(gc_sAdminFlag, OnSettingChanged);
	
	//Find
	g_iGetRoundTime = FindConVar("mp_roundtime");
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;
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
			RegConsoleCmd(sBufferCMD, VoteHEbattle, "Allows players to vote for a HE battle");
	}
}

//Initialize Event

public void OnMapStart()
{
	g_iVoteCount = 0;
	g_iRound = 0;
	IsHEbattle = false;
	StartHEbattle = false;
	
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayStartPath);
	if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStartPath);
}

public void OnConfigsExecuted()
{
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iMaxRound = gc_iRounds.IntValue;
	
	char sBufferCMD[64];
	Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
	if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMD, VoteHEbattle, "Allows players to vote for a HE battle");
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

//Admin & Warden set Event

public Action SetHEbattle(int client,int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if(client == 0)
		{
			StartNextRound();
			if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event HE Battle was started by groupvoting");
		}
		else if (warden_iswarden(client))
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
							if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event HEBattle was started by warden %L", client);
						}
						else CPrintToChat(client, "%t %t", "hebattle_tag" , "hebattle_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "hebattle_tag" , "hebattle_progress" , EventDay);
				}
				else CPrintToChat(client, "%t %t", "hebattle_tag" , "hebattle_minplayer");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "hebattle_setbywarden");
		}
		else if (CheckVipFlag(client,g_sAdminFlag))
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
							if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event HEbattle was started by admin %L", client);
						}
						else CPrintToChat(client, "%t %t", "hebattle_tag" , "hebattle_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "hebattle_tag" , "hebattle_progress" , EventDay);
				}
				else CPrintToChat(client, "%t %t", "hebattle_tag" , "hebattle_minplayer");
			}
			else CPrintToChat(client, "%t %t", "hebattle_tag" , "hebattle_setbyadmin");
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "hebattle_tag" , "hebattle_disabled");
}

//Voting for Event

public Action VoteHEbattle(int client,int args)
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
								if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event HEBattle was started by voting");
							}
							else CPrintToChatAll("%t %t", "hebattle_tag" , "hebattle_need", Missing, client);
						}
						else CPrintToChat(client, "%t %t", "hebattle_tag" , "hebattle_voted");
					}
					else CPrintToChat(client, "%t %t", "hebattle_tag" , "hebattle_wait", g_iCoolDown);
					
				}
				else CPrintToChat(client, "%t %t", "hebattle_tag" , "hebattle_progress" , EventDay);
			}
			else CPrintToChat(client, "%t %t", "hebattle_tag" , "hebattle_minplayer");
		}
		else CPrintToChat(client, "%t %t", "hebattle_tag" , "hebattle_voting");
	}
	else CPrintToChat(client, "%t %t", "hebattle_tag" , "hebattle_disabled");
}

//Prepare Event

void StartNextRound()
{
	StartHEbattle = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;
	
	SetEventDay("hebattle");
	SetEventDayPlaned(true);
	
	g_iOldRoundTime = g_iGetRoundTime.IntValue; //save original round time
	g_iGetRoundTime.IntValue = gc_iRoundTime.IntValue;//set event round time
	
	CPrintToChatAll("%t %t", "hebattle_tag" , "hebattle_next");
	PrintHintTextToAll("%t", "hebattle_next_nc");

}

//Round start

public void RoundStart(Handle event, char[] name, bool dontBroadcast)
{
	if (StartHEbattle || IsHEbattle)
	{
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_weapons_enable", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("mp_teammates_are_enemies", 1);
		SetCvar("sm_menu_enable", 0);
		SetEventDayPlaned(false);
		SetEventDayRunning(true);
		IsHEbattle = true;
		g_iRound++;
		StartHEbattle = false;
		SJD_OpenDoors();
		
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
					
					SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
					StripAllWeapons(client);
					GivePlayerItem(client, "weapon_hegrenade");
					SetEntityHealth(client, gc_iPlayerHP.IntValue);
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					
					if (gc_bGrav.BoolValue)
					{
						SetEntityGravity(client, gc_fGravValue.FloatValue);	
					}
					if (!gc_bSpawnCell.BoolValue || (gc_bSpawnCell.BoolValue && !SJD_IsCurrentMapConfigured)) //spawn Terrors to CT Spawn 
					{
						TeleportEntity(client, g_fPos, NULL_VECTOR, NULL_VECTOR);
					}
				}
				g_iTruceTime--;
				TruceTimer = CreateTimer(1.0, StartTimer, _, TIMER_REPEAT);
				GravityTimer = CreateTimer(1.0, CheckGravity, _, TIMER_REPEAT);
				
				//enable lr on last round
				if (gc_bAllowLR.BoolValue)
				{
					if (g_iRound == g_iMaxRound)
					{
						SetCvar("sm_hosties_lr", 1);
					}
				}
				
				CPrintToChatAll("%t %t", "hebattle_tag" ,"hebattle_rounds", g_iRound, g_iMaxRound);
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

public int OnAvailableLR(int Announced)
{
	if (IsHEbattle && gc_bAllowLR.BoolValue)
	{
		LoopClients(client)
		{
			SetEntityGravity(client, 1.0);
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
			StripAllWeapons(client);
			if (GetClientTeam(client) == CS_TEAM_CT)
			{
				FakeClientCommand(client, "sm_guns");
			}
			GivePlayerItem(client, "weapon_knife");
		}
		delete TruceTimer;
		delete GravityTimer;
		if (g_iRound == g_iMaxRound)
		{
			IsHEbattle = false;
			StartHEbattle = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_weapons_enable", 1);
			SetCvar("mp_teammates_are_enemies", 0);
			SetCvar("sm_warden_enable", 1);
			SetCvar("sm_menu_enable", 1);
			g_iGetRoundTime.IntValue = g_iOldRoundTime;
			SetEventDay("none");
			SetEventDayRunning(false);
			CPrintToChatAll("%t %t", "hebattle_tag" , "hebattle_end");
		}
	}

}

stock void CreateInfoPanel(int client)
{
	//Create info Panel
	char info[255];

	HEbattleMenu = CreatePanel();
	Format(info, sizeof(info), "%T", "hebattle_info_title", client);
	SetPanelTitle(HEbattleMenu, info);
	DrawPanelText(HEbattleMenu, "                                   ");
	Format(info, sizeof(info), "%T", "hebattle_info_line1", client);
	DrawPanelText(HEbattleMenu, info);
	DrawPanelText(HEbattleMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "hebattle_info_line2", client);
	DrawPanelText(HEbattleMenu, info);
	Format(info, sizeof(info), "%T", "hebattle_info_line3", client);
	DrawPanelText(HEbattleMenu, info);
	Format(info, sizeof(info), "%T", "hebattle_info_line4", client);
	DrawPanelText(HEbattleMenu, info);
	Format(info, sizeof(info), "%T", "hebattle_info_line5", client);
	DrawPanelText(HEbattleMenu, info);
	Format(info, sizeof(info), "%T", "hebattle_info_line6", client);
	DrawPanelText(HEbattleMenu, info);
	Format(info, sizeof(info), "%T", "hebattle_info_line7", client);
	DrawPanelText(HEbattleMenu, info);
	DrawPanelText(HEbattleMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "warden_close", client);
	DrawPanelItem(HEbattleMenu, info); 
	SendPanelToClient(HEbattleMenu, client, NullHandler, 20);
}
//Round End

public void RoundEnd(Handle event, char[] name, bool dontBroadcast)
{
	int winner = GetEventInt(event, "winner");
	
	if (IsHEbattle)
	{
		LoopClients(client)
		{
			SetEntityGravity(client, 1.0);
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
		}
		delete TruceTimer;
		delete GravityTimer;
		if (winner == 2) PrintHintTextToAll("%t", "hebattle_twin_nc");
		if (winner == 3) PrintHintTextToAll("%t", "hebattle_ctwin_nc");
		if (g_iRound == g_iMaxRound)
		{
			IsHEbattle = false;
			StartHEbattle = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_weapons_enable", 1);
			SetCvar("mp_teammates_are_enemies", 0);
			SetCvar("sm_warden_enable", 1);
			SetCvar("sm_menu_enable", 1);
			g_iGetRoundTime.IntValue = g_iOldRoundTime;
			SetEventDay("none");
			SetEventDayRunning(false);
			CPrintToChatAll("%t %t", "hebattle_tag" , "hebattle_end");
		}
	}
	if (StartHEbattle)
	{
		LoopClients(i) CreateInfoPanel(i);
		
		CPrintToChatAll("%t %t", "hebattle_tag" , "hebattle_next");
		PrintHintTextToAll("%t", "hebattle_next_nc");
	}
}

//Map End

public void OnMapEnd()
{
	IsHEbattle = false;
	StartHEbattle = false;
	g_iVoteCount = 0;
	delete TruceTimer;
	delete GravityTimer;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
}

//Start Timer

public Action StartTimer(Handle timer)
{
	if (g_iTruceTime > 1)
	{
		g_iTruceTime--;
		LoopClients(client) if(IsPlayerAlive(client))
			PrintHintText(client,"%t", "hebattle_timeuntilstart_nc", g_iTruceTime);
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
				PrintHintText(client,"%t", "hebattle_start_nc");
			}
			if(gc_bOverlays.BoolValue) ShowOverlay(client, g_sOverlayStartPath, 2.0);
			if(gc_bSounds.BoolValue)	
			{
				EmitSoundToAllAny(g_sSoundStartPath);
			}
			
		}
		CPrintToChatAll("%t %t", "hebattle_tag" , "hebattle_start");
	}
	
	TruceTimer = null;
	
	return Plugin_Stop;
}

//HE Grenade only

public Action OnWeaponCanUse(int client, int weapon)
{
	if(IsHEbattle == true)
	{
		char sWeapon[32];
		GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));
		if(StrEqual(sWeapon, "weapon_hegrenade"))
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

//Give new Nades after detonation

public Action HE_Detonate(Handle event, const char[] name, bool dontBroadcast)
{
	if (IsHEbattle == true)
	{
		int  target = GetClientOfUserId(GetEventInt(event, "userid"));
		if (GetClientTeam(target) == 1 && !IsPlayerAlive(target))
		{
			return;
		}
		GivePlayerItem(target, "weapon_hegrenade");
	}
	return;
}

//Give back Gravity if it gone -> ladders

public Action CheckGravity(Handle timer)
{
	LoopValidClients(client, false, false)
	{
		if(GetEntityGravity(client) != 1.0)
			SetEntityGravity(client, gc_fGravValue.FloatValue);
	}
}