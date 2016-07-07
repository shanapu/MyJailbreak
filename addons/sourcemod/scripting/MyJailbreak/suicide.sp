//includes
#include <cstrike>
#include <sourcemod>
#include <colors>
#include <smartjaildoors>
#include <warden>
#include <emitsoundany>
#include <autoexecconfig>
#include <clientprefs>
#include <myjailbreak>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//Defines
#define IsSprintUsing   (1<<0)
#define IsSprintCoolDown  (1<<1)
#define IsBombing  (1<<2)

//Booleans
bool IsSuicideBomber;
bool StartSuicideBomber;
bool BombActive;

//ConVars
ConVar gc_bPlugin;
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_bVote;
ConVar gc_iKey;
ConVar gc_bStandStill;
ConVar gc_fBombRadius;
ConVar gc_bSounds;
ConVar gc_bOverlays;
ConVar gc_iCooldownDay;
ConVar gc_iCooldownStart;
ConVar gc_iRoundTime;
ConVar gc_iFreezeTime;
ConVar gc_sOverlayStartPath;
ConVar gc_bSprintUse;
ConVar gc_iSprintCooldown;
ConVar gc_bSprint;
ConVar gc_fSprintSpeed;
ConVar gc_iSprintTime;
ConVar gc_sSoundStartPath;
ConVar gc_sSoundSuicideBomberPath;
ConVar gc_sSoundBoomPath;
ConVar g_iGetRoundTime;
ConVar gc_iRounds;
ConVar gc_sCustomCommand;
ConVar gc_sAdminFlag;

//Integers
int g_iVoteCount;
int g_iOldRoundTime;
int g_iCoolDown;
int g_iFreezeTime;
int g_iRound;
int ClientSprintStatus[MAXPLAYERS+1];
int g_iMaxRound;

//Handles
Handle SprintTimer[MAXPLAYERS+1];
Handle SuicideBomberMenu;
Handle FreezeTimer;

//Strings
char g_sSoundBoomPath[256];
char g_sSoundSuicideBomberPath[256];
char g_sHasVoted[1500];
char g_sSoundStartPath[256];
char g_sCustomCommand[64];
char g_sEventsLogFile[PLATFORM_MAX_PATH];
char g_sAdminFlag[32];

public Plugin myinfo = {
	name = "MyJailbreak - Suicide Bomber",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = PLUGIN_VERSION,
	url = URL_LINK
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.SuicideBomber.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_setsuicidebomber", SetSuicideBomber, "Allows the Admin or Warden to set Suicide Bomber as next round");
	RegConsoleCmd("sm_suicidebomber", VoteSuicideBomber, "Allows players to vote for a duckhunt");
	RegConsoleCmd("sm_sprint", Command_StartSprint, "Starts the sprint");
	RegConsoleCmd("sm_makeboom", Command_BombSuicideBomber, "Suicide with bomb");
	
	//AutoExecConfig
	AutoExecConfig_SetFile("SuicideBomber", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_suicidebomber_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_suicidebomber_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_sCustomCommand = AutoExecConfig_CreateConVar("sm_suicidebomber_cmd", "suicide", "Set your custom chat command for Event voting. no need for sm_ or !");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_suicidebomber_warden", "1", "0 - disabled, 1 - allow warden to set Suicide Bomber round", _, true,  0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_suicidebomber_admin", "1", "0 - disabled, 1 - allow admin/vip to set Suicide Bomber round", _, true,  0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_suicidebomber_flag", "g", "Set flag for admin/vip to set this Event Day.");
	gc_bVote = AutoExecConfig_CreateConVar("sm_suicidebomber_vote", "1", "0 - disabled, 1 - allow player to vote for Suicide Bomber", _, true,  0.0, true, 1.0);
	gc_iKey = AutoExecConfig_CreateConVar("sm_suicidebomber_key", "1", "1 - Inspect(look) weapon / 2 - walk / 3 - Secondary Attack", _, true,  1.0, true, 3.0);
	gc_bStandStill = AutoExecConfig_CreateConVar("sm_suicidebomber_standstill", "1", "0 - disabled, 1 - standstill(cant move) on Activate bomb", _, true,  0.0, true, 1.0);
	gc_iRounds = AutoExecConfig_CreateConVar("sm_suicidebomber_rounds", "1", "Rounds to play in a row", _, true, 1.0);
	gc_fBombRadius = AutoExecConfig_CreateConVar("sm_suicidebomber_bomb_radius", "200.0","Radius for bomb damage", _, true, 10.0, true, 999.0);
	gc_iFreezeTime = AutoExecConfig_CreateConVar("sm_suicidebomber_hidetime", "20", "Time to hide for CTs", _, true,  0.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_suicidebomber_roundtime", "5", "Round time in minutes for a single Suicide Bomber round", _, true, 1.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_suicidebomber_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true, 0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_suicidebomber_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true, 0.0);
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_suicidebomber_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true,  0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_suicidebomber_overlays_start", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_bSounds = AutoExecConfig_CreateConVar("sm_suicidebomber_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true,  0.0, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_suicidebomber_sounds_start", "music/MyJailbreak/start.mp3", "Path to the soundfile which should be played for start.");
	gc_sSoundSuicideBomberPath = AutoExecConfig_CreateConVar("sm_suicidebomber_sounds_suicidebomber", "music/MyJailbreak/suicidebomber.mp3", "Path to the soundfile which should be played on activatebomb.");
	gc_sSoundBoomPath = AutoExecConfig_CreateConVar("sm_suicidebomber_sounds_boom", "music/MyJailbreak/boom.mp3", "Path to the soundfile which should be played on detonation.");
	gc_bSprintUse = AutoExecConfig_CreateConVar("sm_suicidebomber_sprint_button", "1", "0 - disabled, 1 - enable +use button for sprint", _, true,  0.0, true, 1.0);
	gc_iSprintCooldown = AutoExecConfig_CreateConVar("sm_suicidebomber_sprint_cooldown", "7","Time in seconds the player must wait for the next sprint", _, true,  0.0);
	gc_bSprint = AutoExecConfig_CreateConVar("sm_suicidebomber_sprint_enable", "1", "0 - disabled, 1 - enable ShortSprint", _, true,  0.0, true, 1.0);
	gc_fSprintSpeed = AutoExecConfig_CreateConVar("sm_suicidebomber_sprint_speed", "1.30","Ratio for how fast the player will sprint", _, true, 1.01, true, 5.00);
	gc_iSprintTime = AutoExecConfig_CreateConVar("sm_suicidebomber_sprint_time", "2.5", "Time in seconds the player will sprint", _, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("round_end", RoundEnd);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundSuicideBomberPath, OnSettingChanged);
	HookConVarChange(gc_sSoundBoomPath, OnSettingChanged);
	HookConVarChange(gc_sCustomCommand, OnSettingChanged);
	HookConVarChange(gc_sAdminFlag, OnSettingChanged);
	
	//FindConVar
	g_iGetRoundTime = FindConVar("mp_roundtime");
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	gc_sSoundSuicideBomberPath.GetString(g_sSoundSuicideBomberPath, sizeof(g_sSoundSuicideBomberPath));
	gc_sSoundBoomPath.GetString(g_sSoundBoomPath, sizeof(g_sSoundBoomPath));
	gc_sOverlayStartPath.GetString(g_sOverlayStart , sizeof(g_sOverlayStart));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
	gc_sCustomCommand.GetString(g_sCustomCommand , sizeof(g_sCustomCommand));
	gc_sAdminFlag.GetString(g_sAdminFlag , sizeof(g_sAdminFlag));
	
	AddCommandListener(Command_LAW, "+lookatweapon");
	
	SetLogFile(g_sEventsLogFile, "Events");
}

//ConVarChange for Strings

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sSoundSuicideBomberPath)
	{
		strcopy(g_sSoundSuicideBomberPath, sizeof(g_sSoundSuicideBomberPath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundSuicideBomberPath);
	}
	else if(convar == gc_sAdminFlag)
	{
		strcopy(g_sAdminFlag, sizeof(g_sAdminFlag), newValue);
	}
	else if(convar == gc_sSoundBoomPath)
	{
		strcopy(g_sSoundBoomPath, sizeof(g_sSoundBoomPath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundBoomPath);
	}
	else if(convar == gc_sOverlayStartPath)
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
			RegConsoleCmd(sBufferCMD, VoteSuicideBomber, "Allows players to vote for a SuicideBomber ");
	}
}

//Initialize Event

public void OnMapStart()
{
	g_iVoteCount = 0;
	g_iRound = 0;
	IsSuicideBomber = false;
	StartSuicideBomber = false;
	BombActive = false;
	
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	
	if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayStart);
	if(gc_bSounds.BoolValue)	
	{
		PrecacheSoundAnyDownload(g_sSoundSuicideBomberPath);
		PrecacheSoundAnyDownload(g_sSoundBoomPath);
		PrecacheSoundAnyDownload(g_sSoundStartPath);
	}
	PrecacheSound("player/suit_sprint.wav", true);
}

public void OnConfigsExecuted()
{
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_iMaxRound = gc_iRounds.IntValue;
	
	char sBufferCMD[64];
	Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
	if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMD, VoteSuicideBomber, "Allows players to vote for a SuicideBomber");
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

//Admin & Warden set Event

public Action SetSuicideBomber(int client,int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if(client == 0)
		{
			StartNextRound();
			if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event CowBoy was started by groupvoting");
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
							if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event Suicide Bomber was started by warden %L", client);
						}
						else CPrintToChat(client, "%t %t", "suicidebomber_tag" , "suicidebomber_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "suicidebomber_tag" , "suicidebomber_progress" , EventDay);
				}
				else CPrintToChat(client, "%t %t", "suicidebomber_tag" , "suicidebomber_minplayer");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "suicidebomber_setbywarden");
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
							if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event Suicide Bomber was started by admin %L", client);
						}
						else CPrintToChat(client, "%t %t", "suicidebomber_tag" , "suicidebomber_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "suicidebomber_tag" , "suicidebomber_progress" , EventDay);
				}
				else CPrintToChat(client, "%t %t", "suicidebomber_tag" , "suicidebomber_minplayer");
			}
			else CPrintToChat(client, "%t %t", "suicidebomber_tag" , "suicidebomber_setbyadmin");
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "suicidebomber_tag" , "suicidebomber_disabled");
}

//Voting for Event

public Action VoteSuicideBomber(int client,int args)
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
		if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event Suicide Bomber was started by voting");
	}
	else CPrintToChatAll("%t %t", "suicidebomber_tag" , "suicidebomber_need", Missing, client);
						}
						else CPrintToChat(client, "%t %t", "suicidebomber_tag" , "suicidebomber_voted");
					}
					else CPrintToChat(client, "%t %t", "suicidebomber_tag" , "suicidebomber_wait", g_iCoolDown);
				}
				else CPrintToChat(client, "%t %t", "suicidebomber_tag" , "suicidebomber_progress" , EventDay);
			}
			else CPrintToChat(client, "%t %t", "suicidebomber_tag" , "suicidebomber_minplayer");
		}
		else CPrintToChat(client, "%t %t", "suicidebomber_tag" , "suicidebomber_voting");
	}
	else CPrintToChat(client, "%t %t", "suicidebomber_tag" , "suicidebomber_disabled");
}

//Prepare Event

void StartNextRound()
{
	StartSuicideBomber = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;
	SetEventDay("Suicide Bomber");
	SetEventDayPlaned(true);
	
	g_iOldRoundTime = g_iGetRoundTime.IntValue; //save original round time
	g_iGetRoundTime.IntValue = gc_iRoundTime.IntValue;//set event round time
	
	CPrintToChatAll("%t %t", "suicidebomber_tag" , "suicidebomber_next");
	PrintHintTextToAll("%t", "suicidebomber_next_nc");
}

//Round start

public void RoundStart(Handle event, char[] name, bool dontBroadcast)
{
	if (StartSuicideBomber || IsSuicideBomber)
	{
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_menu_enable", 0);
		SetCvar("sm_weapons_enable", 0);
		SetEventDayPlaned(false);
		SetEventDayRunning(true);
		
		g_iRound++;
		IsSuicideBomber = true;
		StartSuicideBomber = false;
		
		if (g_iRound > 0)
			{
				LoopClients(client) 
				{
					CreateInfoPanel(client);
					
					StripAllWeapons(client);
					ClientSprintStatus[client] = 0;
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					
					if (GetClientTeam(client) == CS_TEAM_T)
					{
						GivePlayerItem(client, "weapon_c4");
					}
					if (GetClientTeam(client) == CS_TEAM_CT)
					{
						GivePlayerItem(client, "weapon_knife");
					}
				}
				g_iFreezeTime--;
				FreezeTimer = CreateTimer(1.0, StartTimer, _, TIMER_REPEAT);
				CPrintToChatAll("%t %t", "suicidebomber_tag" ,"suicidebomber_rounds", g_iRound, g_iMaxRound);
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

stock void CreateInfoPanel(int client)
{
	//Create info Panel
	char info[255];
	
	SuicideBomberMenu = CreatePanel();
	Format(info, sizeof(info), "%T", "suicidebomber_info_title",client);
	SetPanelTitle(SuicideBomberMenu, info);
	DrawPanelText(SuicideBomberMenu, "                                   ");
	Format(info, sizeof(info), "%T", "suicidebomber_info_line1",client);
	DrawPanelText(SuicideBomberMenu, info);
	DrawPanelText(SuicideBomberMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "suicidebomber_info_line2",client);
	DrawPanelText(SuicideBomberMenu, info);
	Format(info, sizeof(info), "%T", "suicidebomber_info_line3",client);
	DrawPanelText(SuicideBomberMenu, info);
	Format(info, sizeof(info), "%T", "suicidebomber_info_line4",client);
	DrawPanelText(SuicideBomberMenu, info);
	Format(info, sizeof(info), "%T", "suicidebomber_info_line5",client);
	DrawPanelText(SuicideBomberMenu, info);
	Format(info, sizeof(info), "%T", "suicidebomber_info_line6",client);
	DrawPanelText(SuicideBomberMenu, info);
	Format(info, sizeof(info), "%T", "suicidebomber_info_line7",client);
	DrawPanelText(SuicideBomberMenu, info);
	DrawPanelText(SuicideBomberMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "warden_close", client);
	DrawPanelItem(SuicideBomberMenu, info); 
	SendPanelToClient(SuicideBomberMenu, client, NullHandler, 20);
}

//Round End

public void RoundEnd(Handle event, char[] name, bool dontBroadcast)
{
	int winner = GetEventInt(event, "winner");
	
	if (IsSuicideBomber)
	{
		LoopClients(client) 
		{
			if (IsClientInGame(client)) SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
			ClientSprintStatus[client] = 0;
		}
		delete FreezeTimer;
		if (winner == 2) PrintHintTextToAll("%t", "suicidebomber_twin_nc");
		if (winner == 3) PrintHintTextToAll("%t", "suicidebomber_ctwin_nc");
		BombActive = false;
		if (g_iRound == g_iMaxRound)
		{
			IsSuicideBomber = false;
			StartSuicideBomber = false;
			BombActive = false;
			g_iRound = 0;
			
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_weapons_enable", 1);
			SetCvar("sv_infinite_ammo", 0);
			SetCvar("sm_warden_enable", 1);
			SetCvar("sm_menu_enable", 1);
			g_iGetRoundTime.IntValue = g_iOldRoundTime;
			SetEventDay("none");
			SetEventDayRunning(false);
			CPrintToChatAll("%t %t", "suicidebomber_tag" , "suicidebomber_end");
		}
	}
	if (StartSuicideBomber)
	{
		LoopClients(i) CreateInfoPanel(i);
		
		CPrintToChatAll("%t %t", "suicidebomber_tag" , "suicidebomber_next");
		PrintHintTextToAll("%t", "suicidebomber_next_nc");
	}
}

//Counter-Terror win Round if time runs out

public Action CS_OnTerminateRound( float &delay, CSRoundEndReason &reason)
{
	if (IsSuicideBomber)   //TODO: does this trigger??
	{
		if (reason == CSRoundEnd_Draw)
		{
			reason = CSRoundEnd_CTWin;
			return Plugin_Changed;
		}
		return Plugin_Continue;
	}
	return Plugin_Continue;
}

//Map End

public void OnMapEnd()
{
	IsSuicideBomber = false;
	StartSuicideBomber = false;
	BombActive = false;
	delete FreezeTimer;
	FreezeTimer = null;
	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
}

//Start Timer

public Action StartTimer(Handle timer)
{
	if (g_iFreezeTime > 1)
	{
		g_iFreezeTime--;
		for (int client=1; client <= MaxClients; client++)
		if (IsValidClient(client, false, false))
		{
			if (GetClientTeam(client) == CS_TEAM_CT)
			{
				PrintHintText(client,"%t", "suicidebomber_timetohide_nc", g_iFreezeTime);
			}
			if (GetClientTeam(client) == CS_TEAM_T)
			{
				PrintHintText(client,"%t", "suicidebomber_timeuntilopen_nc", g_iFreezeTime);
			}
		}
		return Plugin_Continue;
	}
	
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	
	if (g_iRound > 0)
	{
		LoopClients(client) 
		{
			if (IsValidClient(client, true, true))
			{
				SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
				PrintHintText(client,"%t", "suicidebomber_start_nc");
			}
			if(gc_bOverlays.BoolValue) CreateTimer( 0.0, ShowOverlayStart, client);
			
			if(gc_bSounds.BoolValue)
			{
				EmitSoundToAllAny(g_sSoundStartPath);
			}
		}
		CPrintToChatAll("%t %t", "suicidebomber_tag" , "suicidebomber_start");
	}
	SJD_OpenDoors();
	
	
	FreezeTimer = null;
	BombActive = true;
	
	return Plugin_Stop;
}

//Set Button Suicide Bomber

public Action Command_LAW(int client, const char[] command, int argc)
{
	if(IsSuicideBomber)
	{
		if(gc_iKey.IntValue == 1)
		{
			Command_BombSuicideBomber(client, 0);
		}
	}
	
	return Plugin_Continue;
}

public void OnGameFrame()
{
	if (IsSuicideBomber)
	{
		LoopClients(i) 
		{
			if(gc_iKey.IntValue == 2)
			{
				if(IsClientInGame(i) && (GetClientButtons(i) & IN_SPEED))
				{
					Command_BombSuicideBomber(i, 0);
				}
			}
			else if(gc_iKey.IntValue == 3)
			{
				if(IsClientInGame(i) && (GetClientButtons(i) & IN_ATTACK2))
				{
					Command_BombSuicideBomber(i, 0);
				}
			}
			if(gc_bSprintUse.BoolValue)
			{
				if(IsClientInGame(i) && (GetClientButtons(i) & IN_USE))
				{
					Command_StartSprint(i, 0);
				}
			}
		}
	}
	return;
}

//Disable Bomb Drop

public Action CS_OnCSWeaponDrop(int client, int weapon)
{
	if (IsSuicideBomber && IsValidClient(client, false, false))
	{
		char g_sWeaponName[80];
		if (weapon > MaxClients && GetClientTeam(client) == CS_TEAM_T && GetEntityClassname(weapon, g_sWeaponName, sizeof(g_sWeaponName)))
		{
			if (StrEqual("weapon_c4", g_sWeaponName, false))
			{
				return Plugin_Handled;
			}
		}
	}
	return Plugin_Continue;
}

//Start Bombtimer

public Action Command_BombSuicideBomber(int client, int args)
{
	if (IsSuicideBomber && BombActive && IsValidClient(client, false, false))
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		char weaponName[64];
		
		GetEdictClassname(weapon, weaponName, sizeof(weaponName));
		
		if (GetClientTeam(client) == CS_TEAM_T)
		{
			if(StrEqual(weaponName, "weapon_c4"))
			{
				EmitSoundToAllAny(g_sSoundSuicideBomberPath);
				CreateTimer( 1.0, DoDaBomb, client);
				if (gc_bStandStill.BoolValue)
				{
					SetEntityMoveType(client, MOVETYPE_NONE);
				}
			}
			//else CPrintToChat(client, "%t %t", "suicidebomber_tag" , "suicidebomber_needc4");
		}
	}
}

//Detonate Bomb / Kill Player

public Action DoDaBomb( Handle timer, any client ) 
{
	EmitSoundToAllAny(g_sSoundBoomPath);
	
	float suicide_bomber_vec[3];
	GetClientAbsOrigin(client, suicide_bomber_vec);
	
	int iMaxClients = GetMaxClients();
	int deathList[MAXPLAYERS+1]; //store players that this bomb kills
	int numKilledPlayers = 0;
	
	for (int i = 1; i <= iMaxClients; ++i)
	
	{
		//Check that client is a real player who is alive and is a CT
		if (IsClientInGame(i) && IsPlayerAlive(i))
		{
			float ct_vec[3];
			GetClientAbsOrigin(i, ct_vec);
			
			float distance = GetVectorDistance(ct_vec, suicide_bomber_vec, false);
			
			//If CT was in explosion radius, damage or kill them
			//Formula used: damage = 200 - (d/2)
			int damage = RoundToFloor(gc_fBombRadius.FloatValue - (distance / 2.0));
			
			if (damage <= 0) //this player was not damaged 
			continue;
			
			//damage the surrounding players
			int curHP = GetClientHealth(i);
			if (curHP - damage <= 0) 
			{
				deathList[numKilledPlayers] = i;
				numKilledPlayers++;
			}
			else
			{ //Survivor
				SetEntityHealth(i, curHP - damage);
				IgniteEntity(i, 2.0);
			}

		}
	}
	if (numKilledPlayers > 0) 
	{
		for (int i = 0; i < numKilledPlayers; ++i)
		{
			ForcePlayerSuicide(deathList[i]);
		}
	}
	ForcePlayerSuicide(client);
//	int number = 0;
//	for (int i = 1; i <= MaxClients; i++)
//	if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_CT) number++;
}

//Knife & c4 only

public Action OnWeaponCanUse(int client, int weapon)
{
	char sWeapon[32];
	GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));
	
	if((GetClientTeam(client) == CS_TEAM_T && !StrEqual(sWeapon, "weapon_c4")) || (GetClientTeam(client) == CS_TEAM_CT && !StrEqual(sWeapon, "weapon_knife")))
		{
			if (IsValidClient(client, true, false))
			{
				if(IsSuicideBomber == true)
				{
					return Plugin_Handled;
				}
			}
		}
	return Plugin_Continue;
}

//Sprint

public Action Command_StartSprint(int client, int args)
{
	if (IsSuicideBomber)
	{
		if(gc_bSprint.BoolValue && client > 0 && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) > 1 && !(ClientSprintStatus[client] & IsSprintUsing) && !(ClientSprintStatus[client] & IsSprintCoolDown))
		{
			ClientSprintStatus[client] |= IsSprintUsing | IsSprintCoolDown;
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", gc_fSprintSpeed.FloatValue);
			EmitSoundToClient(client, "player/suit_sprint.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.8);
			CPrintToChat(client, "%t %t", "suicidebomber_tag" ,"suicidebomber_sprint");
			SprintTimer[client] = CreateTimer(gc_iSprintTime.FloatValue, Timer_SprintEnd, client);
		}
		return(Plugin_Handled);
	}
	else CPrintToChat(client, "%t %t", "suicidebomber_tag" , "suicidebomber_disabled");
	return(Plugin_Handled);
}

public Action ResetSprint(int client)
{
	if(SprintTimer[client] != null)
	{
		KillTimer(SprintTimer[client]);
		SprintTimer[client] = null;
	}
	if(GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue") != 1)
	{
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	}
	
	if(ClientSprintStatus[client] & IsSprintUsing)
	{
		ClientSprintStatus[client] &= ~ IsSprintUsing;
	}
	return;
}

public Action Timer_SprintEnd(Handle timer, any client)
{
	SprintTimer[client] = null;
	
	
	if(IsClientInGame(client) && (ClientSprintStatus[client] & IsSprintUsing))
	{
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
		ClientSprintStatus[client] &= ~ IsSprintUsing;
		if(IsPlayerAlive(client) && GetClientTeam(client) > 1)
		{
			SprintTimer[client] = CreateTimer(gc_iSprintCooldown.FloatValue, Timer_SprintCooldown, client);
			CPrintToChat(client, "%t %t", "suicidebomber_tag" ,"suicidebomber_sprintend", gc_iSprintCooldown.IntValue);
		}
	}
	return;
}

public Action Timer_SprintCooldown(Handle timer, any client)
{
	SprintTimer[client] = null;
	if(IsClientInGame(client) && (ClientSprintStatus[client] & IsSprintCoolDown))
	{
		ClientSprintStatus[client] &= ~ IsSprintCoolDown;
		CPrintToChat(client, "%t %t", "suicidebomber_tag" ,"suicidebomber_sprintagain", gc_iSprintCooldown.IntValue);
	}
	return;
}

public Action Event_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	ResetSprint(iClient);
	ClientSprintStatus[iClient] &= ~ IsSprintCoolDown;
	return;
}
