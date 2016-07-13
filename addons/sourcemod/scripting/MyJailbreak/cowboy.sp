//includes
#include <cstrike>
#include <sourcemod>
#include <smartjaildoors>
#include <lastrequest>
#include <warden>
#include <emitsoundany>
#include <colors>
#include <autoexecconfig>
#include <myjailbreak>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//Booleans
bool IsCowBoy; 
bool StartCowBoy; 

//ConVars
ConVar gc_bPlugin;
ConVar gc_bSetW;
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
ConVar gc_bSoundsHit;
ConVar gc_sOverlayStartPath;
ConVar g_iGetRoundTime;
ConVar gc_bSounds;
ConVar gc_sSoundStartPath;
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
Handle CowBoyMenu;

//Floats
float g_fPos[3];

//Strings
char g_sHasVoted[1500];
char g_sSoundStartPath[256];
char g_sWeapon[32];
char g_sCustomCommand[64];
char g_sEventsLogFile[PLATFORM_MAX_PATH];
char g_sAdminFlag[32];

public Plugin myinfo = {
	name = "MyJailbreak - CowBoy",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = PLUGIN_VERSION,
	url = URL_LINK
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.CowBoy.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_setcowboy", SetCowBoy, "Allows the Admin or Warden to set cowboy as next round");
	RegConsoleCmd("sm_cowboy", VoteCowBoy, "Allows players to vote for a cowboy");

	
	//AutoExecConfig
	AutoExecConfig_SetFile("CowBoy", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_cowboy_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_cowboy_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_sCustomCommand = AutoExecConfig_CreateConVar("sm_cowboy_cmd", "cow", "Set your custom chat command for Event voting. no need for sm_ or !");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_cowboy_warden", "1", "0 - disabled, 1 - allow warden to set cowboy round", _, true,  0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_cowboy_admin", "1", "0 - disabled, 1 - allow admin/vip to set cowboy round", _, true,  0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_cowboy_flag", "g", "Set flag for admin/vip to set this Event Day.");
	gc_bVote = AutoExecConfig_CreateConVar("sm_cowboy_vote", "1", "0 - disabled, 1 - allow player to vote for cowboy", _, true,  0.0, true, 1.0);
	gc_bSpawnCell = AutoExecConfig_CreateConVar("sm_cowboy_spawn", "0", "0 - T teleport to CT spawn, 1 - cell doors auto open", _, true,  0.0, true, 1.0);
	gc_iRounds = AutoExecConfig_CreateConVar("sm_cowboy_rounds", "1", "Rounds to play in a row", _, true, 1.0);
	gc_iWeapon = AutoExecConfig_CreateConVar("sm_cowboy_weapon", "1", "1 - Revolver / 2 - Dual Barettas", _, true,  1.0, true, 2.0);
	gc_bRandom = AutoExecConfig_CreateConVar("sm_cowboy_random", "1", "get a random weapon (revolver,duals) ignore: sm_cowboy_weapon", _, true,  0.0, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_cowboy_roundtime", "5", "Round time in minutes for a single cowboy round", _, true, 1.0);
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_cowboy_trucetime", "15", "Time in seconds players can't deal damage", _, true,  0.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_cowboy_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true,  0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_cowboy_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true, 0.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_cowboy_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true, 0.1, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_cowboy_sounds_start", "music/MyJailbreak/Yeehaw.mp3", "Path to the soundfile which should be played for a start.");
	gc_bSoundsHit = AutoExecConfig_CreateConVar("sm_cowboy_sounds_bling", "1", "0 - disabled, 1 - enable bling - hitsound sounds ", _, true, 0.1, true, 1.0);
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_cowboy_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true,  0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_cowboy_overlays_start", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_bAllowLR = AutoExecConfig_CreateConVar("sm_cowboy_allow_lr", "1" , "0 - disabled, 1 - enable, LR on last round", _, true, 0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("round_end", RoundEnd);
	HookEvent("player_hurt", EventHurt);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sCustomCommand, OnSettingChanged);
	HookConVarChange(gc_sAdminFlag, OnSettingChanged);
	
	//Find
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iGetRoundTime = FindConVar("mp_roundtime");
	gc_sOverlayStartPath.GetString(g_sOverlayStart , sizeof(g_sOverlayStart));
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
		strcopy(g_sOverlayStart, sizeof(g_sOverlayStart), newValue);
		if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayStart);
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
			RegConsoleCmd(sBufferCMD, VoteCowBoy, "Allows players to vote for cowboy");
	}
}

//Initialize Event

public void OnMapStart()
{
	g_iVoteCount = 0;
	g_iRound = 0;
	IsCowBoy = false;
	StartCowBoy = false;
	
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
	
	if (gc_iWeapon.IntValue == 1) g_sWeapon = "weapon_revolver";
	if (gc_iWeapon.IntValue == 2) g_sWeapon = "weapon_elite";
	
	char sBufferCMD[64];    //Register the custom command 
	Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
	if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMD, VoteCowBoy, "Allows players to vote for no scope");
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

//Admin & Warden set Event

public Action SetCowBoy(int client,int args)
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
							if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event CowBoy was started by warden %L", client);
						}
						else CPrintToChat(client, "%t %t", "cowboy_tag" , "cowboy_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "cowboy_tag" , "cowboy_progress" , EventDay);
				}
				else CPrintToChat(client, "%t %t", "cowboy_tag" , "cowboy_minplayer");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "nocscope_setbywarden");
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
							if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event CowBoy was started by admin %L", client);
						}
						else CPrintToChat(client, "%t %t", "cowboy_tag" , "cowboy_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "cowboy_tag" , "cowboy_progress" , EventDay);
				}
				else CPrintToChat(client, "%t %t", "cowboy_tag" , "cowboy_minplayer");
			}
			else CPrintToChat(client, "%t %t", "nocscope_tag" , "cowboy_setbyadmin");
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
		
	}
	else CPrintToChat(client, "%t %t", "cowboy_tag" , "cowboy_disabled");
}

//Voting for Event

public Action VoteCowBoy(int client,int args)
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
								if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event CowBoy was started by voting");
							}
							else CPrintToChatAll("%t %t", "cowboy_tag" , "cowboy_need", Missing, client);
						}
						else CPrintToChat(client, "%t %t", "cowboy_tag" , "cowboy_voted");
					}
					else CPrintToChat(client, "%t %t", "cowboy_tag" , "cowboy_wait", g_iCoolDown);
				}
				else CPrintToChat(client, "%t %t", "cowboy_tag" , "cowboy_progress" , EventDay);
			}
			else CPrintToChat(client, "%t %t", "cowboy_tag" , "cowboy_minplayer");
		}
		else CPrintToChat(client, "%t %t", "cowboy_tag" , "cowboy_voting");
	}
	else CPrintToChat(client, "%t %t", "cowboy_tag" , "cowboy_disabled");
}

//Prepare Event

void StartNextRound()
{
	StartCowBoy = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;
	
	SetEventDay("cowboy");
	SetEventDayPlaned(true);
	
	g_iOldRoundTime = g_iGetRoundTime.IntValue; //save original round time
	g_iGetRoundTime.IntValue = gc_iRoundTime.IntValue;//set event round time
	
	CPrintToChatAll("%t %t", "cowboy_tag" , "cowboy_next");
	PrintHintTextToAll("%t", "cowboy_next_nc");
}

//Round start

public void RoundStart(Handle event, char[] name, bool dontBroadcast)
{
	if (StartCowBoy || IsCowBoy)
	{
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_weapons_enable", 0);
		SetCvar("sm_menu_enable", 0);
		SetCvar("sv_infinite_ammo", 2);
		SetCvar("sm_warden_enable", 0);
		SetCvar("mp_teammates_are_enemies", 1);
		SetEventDayPlaned(false);
		SetEventDayRunning(true);
		
		IsCowBoy = true;
		
		if (gc_bRandom.BoolValue)
		{
			int randomnum = GetRandomInt(0, 1);
			
			if(randomnum == 0)g_sWeapon = "weapon_revolver";
			if(randomnum == 1)g_sWeapon = "weapon_elite";
		}
		
		g_iRound++;
		StartCowBoy = false;
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
					StripAllWeapons(client);
					GivePlayerItem(client, g_sWeapon);
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
					
					if (!gc_bSpawnCell.BoolValue)
					{
						TeleportEntity(client, g_fPos, NULL_VECTOR, NULL_VECTOR);
					}
				}
				g_iTruceTime--;
				TruceTimer = CreateTimer(1.0, StartTimer, _, TIMER_REPEAT);
				
				//enable lr on last round
				if (gc_bAllowLR.BoolValue)
				{
					if (g_iRound == g_iMaxRound)
					{
						SetCvar("sm_hosties_lr", 1);
					}
				}
				
				CPrintToChatAll("%t %t", "cowboy_tag" ,"cowboy_rounds", g_iRound, g_iMaxRound);
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
	if (IsCowBoy && gc_bAllowLR.BoolValue)
	{
		LoopClients(client)
		{
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
			StripAllWeapons(client);
			if (GetClientTeam(client) == CS_TEAM_CT)
			{
				FakeClientCommand(client, "sm_guns");
			}
			GivePlayerItem(client, "weapon_knife");
		}
		
		delete TruceTimer;
		if (g_iRound == g_iMaxRound)
		{
			IsCowBoy = false;
			StartCowBoy = false;
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
			SetEventDayRunning(false);
			CPrintToChatAll("%t %t", "cowboy_tag" , "cowboy_end");
		}
	}

}

stock void CreateInfoPanel(int client)
{
	//Create info Panel
	char info[255];

	CowBoyMenu = CreatePanel();
	Format(info, sizeof(info), "%T", "cowboy_info_title", client);
	SetPanelTitle(CowBoyMenu, info);
	DrawPanelText(CowBoyMenu, "                                   ");
	Format(info, sizeof(info), "%T", "cowboy_info_line1", client);
	DrawPanelText(CowBoyMenu, info);
	DrawPanelText(CowBoyMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "cowboy_info_line2", client);
	DrawPanelText(CowBoyMenu, info);
	Format(info, sizeof(info), "%T", "cowboy_info_line3", client);
	DrawPanelText(CowBoyMenu, info);
	Format(info, sizeof(info), "%T", "cowboy_info_line4", client);
	DrawPanelText(CowBoyMenu, info);
	Format(info, sizeof(info), "%T", "cowboy_info_line5", client);
	DrawPanelText(CowBoyMenu, info);
	Format(info, sizeof(info), "%T", "cowboy_info_line6", client);
	DrawPanelText(CowBoyMenu, info);
	Format(info, sizeof(info), "%T", "cowboy_info_line7", client);
	DrawPanelText(CowBoyMenu, info);
	DrawPanelText(CowBoyMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "warden_close", client);
	DrawPanelItem(CowBoyMenu, info); 
	SendPanelToClient(CowBoyMenu, client, NullHandler, 20);
}

//Start Timer

public Action StartTimer(Handle timer)
{
	if (g_iTruceTime > 1)
	{
		g_iTruceTime--;
		LoopClients(client) if (IsPlayerAlive(client))
		{
			PrintHintText(client,"%t", "cowboy_timeuntilstart_nc", g_iTruceTime);
		}
		return Plugin_Continue;
	}
	
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	if (g_iRound > 0)
	{
		LoopClients(client) if (IsPlayerAlive(client))
		{
			SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
			PrintHintText(client,"%t", "cowboy_start_nc");
			if(gc_bOverlays.BoolValue) CreateTimer( 0.0, ShowOverlayStart, client);
			if(gc_bSounds.BoolValue)
			{
				EmitSoundToAllAny(g_sSoundStartPath);
			}
		}
		CPrintToChatAll("%t %t", "cowboy_tag" , "cowboy_start");
	}
	TruceTimer = null;
	
	return Plugin_Stop;
}

//Round End

public void RoundEnd(Handle event, char[] name, bool dontBroadcast)
{
	int winner = GetEventInt(event, "winner");
	
	if (IsCowBoy)
	{
		LoopClients(client)
		{
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
		}
		
		delete TruceTimer;
		if (winner == 2) PrintHintTextToAll("%t", "cowboy_twin_nc");
		if (winner == 3) PrintHintTextToAll("%t", "cowboy_ctwin_nc");
		if (g_iRound == g_iMaxRound)
		{
			IsCowBoy = false;
			StartCowBoy = false;
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
			SetEventDayRunning(false);
			CPrintToChatAll("%t %t", "cowboy_tag" , "cowboy_end");
		}
	}
	if (StartCowBoy)
	{
		LoopClients(i) CreateInfoPanel(i);
		
		CPrintToChatAll("%t %t", "cowboy_tag" , "cowboy_next");
		PrintHintTextToAll("%t", "cowboy_next_nc");
	}
}

//Map End

public void OnMapEnd()
{
	IsCowBoy = false;
	StartCowBoy = false;
	delete TruceTimer;
	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
}

//Scout only

public Action OnWeaponCanUse(int client, int weapon)
{
	if (IsCowBoy)
	{
		char sWeapon[32];
		GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));
		
		int index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
			
		if(index == 64 || (StrEqual(sWeapon, "weapon_elite")))return Plugin_Continue;
		else return Plugin_Handled;
	}
	return Plugin_Continue;
}

//ding sound

public Action EventHurt(Handle event, const char [] name, bool dontBroadcast)
{
	if (gc_bSoundsHit.BoolValue && IsCowBoy)
	{
		Handle data; // Delay it to a frame later. If we use IsPlayerAlive(victim) here, it would always return true.
		CreateDataTimer(0.0, Timer_Hitsound, data, TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(data, GetEventInt(event, "attacker"));
		WritePackCell(data, GetEventInt(event, "userid"));
		ResetPack(data);
	}
}
public Action Timer_Hitsound(Handle timer, Handle data)
{
	int attacker	= GetClientOfUserId(ReadPackCell(data));
	int victim		= GetClientOfUserId(ReadPackCell(data));
	if (attacker <= 0 || attacker > MaxClients || victim <= 0 || victim > MaxClients || attacker == victim) return;
	ClientCommand(attacker, "playgamesound training/bell_normal.wav");
}


