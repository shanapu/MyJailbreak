//includes
#include <cstrike>
#include <sourcemod>
#include <smartjaildoors>
#include <warden>
#include <emitsoundany>
#include <colors>
#include <autoexecconfig>
#include <myjailbreak>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//Booleans
bool IsNoScope; 
bool StartNoScope; 

//ConVars
ConVar gc_bPlugin;
ConVar gc_bSetW;
ConVar gc_bGrav;
ConVar gc_fGravValue;
ConVar gc_iCooldownStart;
ConVar gc_bSetA;
ConVar gc_bSpawnCell;
ConVar gc_bVote;
ConVar gc_iWeapon;
ConVar gc_bRandom;
ConVar gc_iCooldownDay;
ConVar gc_iRoundTime;
ConVar gc_iTruceTime;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar g_iGetRoundTime;
ConVar gc_bSounds;
ConVar gc_sSoundStartPath;
ConVar gc_iRounds;
ConVar gc_sCustomCommand;

//Integers
int g_iOldRoundTime;
int g_iCoolDown;
int g_iTruceTime;
int g_iVoteCount;
int g_iRound;
int m_flNextSecondaryAttack;
int g_iMaxRound;

//Handles
Handle TruceTimer;
Handle GravityTimer;
Handle NoScopeMenu;

//Floats
float g_fPos[3];

//Strings
char g_sHasVoted[1500];
char g_sSoundStartPath[256];
char g_sWeapon[32];
char g_sCustomCommand[64];

public Plugin myinfo = {
	name = "MyJailbreak - NoScope",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = PLUGIN_VERSION,
	url = URL_LINK
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.NoScope.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_setnoscope", SetNoScope, "Allows the Admin or Warden to set noscope as next round");
	RegConsoleCmd("sm_noscope", VoteNoScope, "Allows players to vote for a noscope");

	
	//AutoExecConfig
	AutoExecConfig_SetFile("NoScope", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_noscope_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_noscope_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_sCustomCommand = AutoExecConfig_CreateConVar("sm_noscope_cmd", "scope", "Set your custom chat command for Event voting. no need for sm_ or !");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_noscope_warden", "1", "0 - disabled, 1 - allow warden to set noscope round", _, true,  0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_noscope_admin", "1", "0 - disabled, 1 - allow admin to set noscope round", _, true,  0.0, true, 1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_noscope_vote", "1", "0 - disabled, 1 - allow player to vote for noscope", _, true,  0.0, true, 1.0);
	gc_bSpawnCell = AutoExecConfig_CreateConVar("sm_noscope_spawn", "0", "0 - T teleport to CT spawn, 1 - cell doors auto open", _, true,  0.0, true, 1.0);
	gc_iRounds = AutoExecConfig_CreateConVar("sm_noscope_rounds", "1", "Rounds to play in a row", _, true, 1.0);
	gc_iWeapon = AutoExecConfig_CreateConVar("sm_noscope_weapon", "1", "1 - ssg08 / 2 - awp / 3 - scar20 / 4 - g3sg1", _, true,  1.0, true, 4.0);
	gc_bRandom = AutoExecConfig_CreateConVar("sm_noscope_random", "1", "get a random weapon (ssg08,awp,scar20,g3sg1) ignore: sm_noscope_weapon", _, true,  0.0, true, 1.0);
	gc_bGrav = AutoExecConfig_CreateConVar("sm_noscope_gravity", "1", "0 - disabled, 1 - enable low Gravity for noscope", _, true,  0.0, true, 1.0);
	gc_fGravValue= AutoExecConfig_CreateConVar("sm_noscope_gravity_value", "0.3","Ratio for Gravity 1.0 earth 0.5 moon", _, true, 0.1, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_noscope_roundtime", "5", "Round time in minutes for a single noscope round", _, true, 1.0);
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_noscope_trucetime", "15", "Time in seconds players can't deal damage", _, true,  0.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_noscope_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true,  0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_noscope_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true, 0.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_noscope_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true, 0.1, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_noscope_sounds_start", "music/MyJailbreak/start.mp3", "Path to the soundfile which should be played for a start.");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_noscope_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true,  0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_noscope_overlays_start", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("round_end", RoundEnd);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sCustomCommand, OnSettingChanged);
	
	//Find
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iGetRoundTime = FindConVar("mp_roundtime");
	m_flNextSecondaryAttack = FindSendPropInfo("CBaseCombatWeapon", "m_flNextSecondaryAttack");
	gc_sOverlayStartPath.GetString(g_sOverlayStart , sizeof(g_sOverlayStart));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
	gc_sCustomCommand.GetString(g_sCustomCommand , sizeof(g_sCustomCommand));
	
}

//ConVarChange for Strings

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sOverlayStartPath)
	{
		strcopy(g_sOverlayStart, sizeof(g_sOverlayStart), newValue);
		if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayStart);
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
			RegConsoleCmd(sBufferCMD, VoteNoScope, "Allows players to vote for noscope");
	}
}

//Initialize Event

public void OnMapStart()
{
	g_iVoteCount = 0;
	g_iRound = 0;
	IsNoScope = false;
	StartNoScope = false;
	
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStartPath);    //Add sound to download and precache table
	if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayStart);    //Add overlay to download and precache table
}

public void OnConfigsExecuted()
{
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iMaxRound = gc_iRounds.IntValue;
	
	if (gc_iWeapon.IntValue == 1) g_sWeapon = "weapon_ssg08";
	if (gc_iWeapon.IntValue == 2) g_sWeapon = "weapon_awp";
	if (gc_iWeapon.IntValue == 3) g_sWeapon = "weapon_scar20";
	if (gc_iWeapon.IntValue == 4) g_sWeapon = "weapon_g3sg1";
	
	char sBufferCMD[64];    //Register the custom command 
	Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
	if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMD, VoteNoScope, "Allows players to vote for no scope");
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	SDKHook(client, SDKHook_PreThink, OnPreThink);
}

//Admin & Warden set Event

public Action SetNoScope(int client,int args)
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
							LogMessage("Event NoScope was started by Warden %L", client);
						}
						else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_progress" , EventDay);
				}
				else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_minplayer");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "nocscope_setbywarden");
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
								LogMessage("Event NoScope was started by Admin %L", client);
							}
							else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_wait", g_iCoolDown);
						}
						else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_progress" , EventDay);
					}
					else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_minplayer");
				}
				else CPrintToChat(client, "%t %t", "nocscope_tag" , "noscope_setbyadmin");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_disabled");
}

//Voting for Event

public Action VoteNoScope(int client,int args)
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
								LogMessage("Event NoScope was started by voting");
							}
							else CPrintToChatAll("%t %t", "noscope_tag" , "noscope_need", Missing, client);
						}
						else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_voted");
					}
					else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_wait", g_iCoolDown);
				}
				else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_progress" , EventDay);
			}
			else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_minplayer");
		}
		else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_voting");
	}
	else CPrintToChat(client, "%t %t", "noscope_tag" , "noscope_disabled");
}

//Prepare Event

void StartNextRound()
{
	StartNoScope = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;
	
	SetEventDay("noscope");
	
	CPrintToChatAll("%t %t", "noscope_tag" , "noscope_next");
	PrintHintTextToAll("%t", "noscope_next_nc");
}

//Round start

public void RoundStart(Handle event, char[] name, bool dontBroadcast)
{
	if (StartNoScope || IsNoScope)
	{
		char info1[255], info2[255], info3[255], info4[255], info5[255], info6[255], info7[255], info8[255];
		
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_weapons_enable", 0);
		SetCvar("sm_menu_enable", 0);
		SetCvar("sv_infinite_ammo", 2);
		SetCvar("sm_warden_enable", 0);
		SetCvar("mp_teammates_are_enemies", 1);
		
		IsNoScope = true;
		
		if (gc_bRandom.BoolValue)
		{
			int randomnum = GetRandomInt(0, 3);
			
			if(randomnum == 0)g_sWeapon = "weapon_ssg08";
			if(randomnum == 1)g_sWeapon = "weapon_awp";
			if(randomnum == 2)g_sWeapon = "weapon_scar20";
			if(randomnum == 3)g_sWeapon = "weapon_g3sg1";
		}
		
		g_iRound++;
		StartNoScope = false;
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
					NoScopeMenu = CreatePanel();
					Format(info1, sizeof(info1), "%T", "noscope_info_title", client);
					SetPanelTitle(NoScopeMenu, info1);
					DrawPanelText(NoScopeMenu, "                                   ");
					Format(info2, sizeof(info2), "%T", "noscope_info_line1", client);
					DrawPanelText(NoScopeMenu, info2);
					DrawPanelText(NoScopeMenu, "-----------------------------------");
					Format(info3, sizeof(info3), "%T", "noscope_info_line2", client);
					DrawPanelText(NoScopeMenu, info3);
					Format(info4, sizeof(info4), "%T", "noscope_info_line3", client);
					DrawPanelText(NoScopeMenu, info4);
					Format(info5, sizeof(info5), "%T", "noscope_info_line4", client);
					DrawPanelText(NoScopeMenu, info5);
					Format(info6, sizeof(info6), "%T", "noscope_info_line5", client);
					DrawPanelText(NoScopeMenu, info6);
					Format(info7, sizeof(info7), "%T", "noscope_info_line6", client);
					DrawPanelText(NoScopeMenu, info7);
					Format(info8, sizeof(info8), "%T", "noscope_info_line7", client);
					DrawPanelText(NoScopeMenu, info8);
					DrawPanelText(NoScopeMenu, "-----------------------------------");
					SendPanelToClient(NoScopeMenu, client, NullHandler, 20);
					
					StripAllWeapons(client);
					GivePlayerItem(client, g_sWeapon);
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
					
					if (gc_bGrav.BoolValue)
					{
						SetEntityGravity(client, gc_fGravValue.FloatValue);	
					}
					if (!gc_bSpawnCell.BoolValue)
					{
						TeleportEntity(client, g_fPos, NULL_VECTOR, NULL_VECTOR);
					}
				}
				g_iTruceTime--;
				TruceTimer = CreateTimer(1.0, StartTimer, _, TIMER_REPEAT);
				GravityTimer = CreateTimer(1.0, CheckGravity, _, TIMER_REPEAT);
				CPrintToChatAll("%t %t", "noscope_tag" ,"noscope_rounds", g_iRound, g_iMaxRound);
			}
			LoopClients(i) if (IsPlayerAlive(i)) SDKHook(i, SDKHook_PreThink, OnPreThink);
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

//Start Timer

public Action StartTimer(Handle timer)
{
	if (g_iTruceTime > 1)
	{
		g_iTruceTime--;
		LoopClients(client) if (IsPlayerAlive(client))
		{
			PrintHintText(client,"%t", "noscope_timeuntilstart_nc", g_iTruceTime);
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
			PrintHintText(client,"%t", "noscope_start_nc");
			if(gc_bOverlays.BoolValue) CreateTimer( 0.0, ShowOverlayStart, client);
			if(gc_bSounds.BoolValue)	
			{
				EmitSoundToAllAny(g_sSoundStartPath);
			}
		}
		CPrintToChatAll("%t %t", "noscope_tag" , "noscope_start");
	}
	TruceTimer = null;
	
	return Plugin_Stop;
}

//Round End

public void RoundEnd(Handle event, char[] name, bool dontBroadcast)
{
	int winner = GetEventInt(event, "winner");
	
	if (IsNoScope)
	{
		LoopClients(client)
		{
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
			SetEntityGravity(client, 1.0);
		}
		
		delete TruceTimer;
		delete GravityTimer;
	//	if (TruceTimer != null) KillTimer(TruceTimer);
	//	if (GravityTimer != null) KillTimer(GravityTimer);
		if (winner == 2) PrintHintTextToAll("%t", "noscope_twin_nc");
		if (winner == 3) PrintHintTextToAll("%t", "noscope_ctwin_nc");
		if (g_iRound == g_iMaxRound)
		{
			IsNoScope = false;
			StartNoScope = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_weapons_enable", 1);
			SetCvar("sv_infinite_ammo", 0);
			SetCvar("mp_teammates_are_enemies", 0);
			SetCvar("sm_menu_enable", 1);
			SetCvar("sm_warden_enable", 1);
			g_iGetRoundTime.IntValue = g_iOldRoundTime;
			SetEventDay("none");
			CPrintToChatAll("%t %t", "noscope_tag" , "noscope_end");
		}
	}
	if (StartNoScope)
	{
		g_iOldRoundTime = g_iGetRoundTime.IntValue;
		g_iGetRoundTime.IntValue = gc_iRoundTime.IntValue;
		
		CPrintToChatAll("%t %t", "noscope_tag" , "noscope_next");
		PrintHintTextToAll("%t", "noscope_next_nc");
		
		LoopClients(i) SDKUnhook(i, SDKHook_PreThink, OnPreThink);
	}
}

//Map End

public void OnMapEnd()
{
	IsNoScope = false;
	StartNoScope = false;
//	if (TruceTimer != null) KillTimer(TruceTimer);
//	if (GravityTimer != null) KillTimer(GravityTimer);
	delete TruceTimer;
	delete GravityTimer;
	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
	SetEventDay("none");
}

//Scout only

public Action OnWeaponCanUse(int client, int weapon)
{
	char sWeapon[32];
	GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));
	
	if(!StrEqual(sWeapon, g_sWeapon))
		{
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				if(IsNoScope)
				{
					return Plugin_Handled;
				}
			}
		}
	return Plugin_Continue;
}

public Action OnPreThink(int client)
{
	int iWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	MakeNoScope(iWeapon);
	return Plugin_Continue;
}

//No Scope

stock void MakeNoScope(int weapon)
{
	if (IsNoScope == true)
	{
		if(IsValidEdict(weapon))
		{
			char classname[MAX_NAME_LENGTH];
			if (GetEdictClassname(weapon, classname, sizeof(classname)) || StrEqual(classname[7], g_sWeapon))
			{
				SetEntDataFloat(weapon, m_flNextSecondaryAttack, GetGameTime() + 1.0);
			}
		}
	}
}

//Give back Gravity if it gone -> ladders

public Action CheckGravity(Handle timer)
{
	LoopValidClients(client,false,false)
	{
		if(GetEntityGravity(client) != 1.0)
			SetEntityGravity(client, gc_fGravValue.FloatValue);
	}
}