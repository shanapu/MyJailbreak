//includes
#include <cstrike>
#include <sourcemod>
#include <colors>
#include <warden>
#include <emitsoundany>
#include <smartjaildoors>
#include <autoexecconfig>
#include <myjailbreak>
#include <lastrequest>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//Booleans
bool IsFFA = false;
bool StartFFA = false;

//ConVars
ConVar gc_bPlugin;
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_bVote;
ConVar gc_iCooldownStart;
ConVar gc_bSpawnCell;
ConVar gc_iRoundTime;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar gc_bSounds;
ConVar gc_sSoundStartPath;
ConVar gc_iCooldownDay;
ConVar gc_iTruceTime;
ConVar gc_iRounds;
ConVar g_iGetRoundTime;
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

//Floats
float g_fPos[3];

//Handles
Handle TruceTimer;
Handle FFAMenu;

//Strings
char g_sHasVoted[1500];
char g_sSoundStartPath[256];
char g_sCustomCommand[64];
char g_sEventsLogFile[PLATFORM_MAX_PATH];
char g_sAdminFlag[32];

public Plugin myinfo = 
{
	name = "MyJailbreak - War FFA",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = PLUGIN_VERSION,
	url = URL_LINK
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.Ffa.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_setffa", Setffa, "Allows the Admin or Warden to set a ffa for next 3 rounds");
	RegConsoleCmd("sm_ffa", VoteFFA, "Allows players to vote for a FFA");

	
	//AutoExecConfig
	AutoExecConfig_SetFile("FreeForAll", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_ffa_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_ffa_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_sCustomCommand = AutoExecConfig_CreateConVar("sm_ffa_cmd", "DM", "Set your custom chat command for Event voting. no need for sm_ or !");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_ffa_warden", "1", "0 - disabled, 1 - allow warden to set ffa round", _, true,  0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_ffa_admin", "1", "0 - disabled, 1 - allow admin/vip to set ffa round", _, true,  0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_ffa_flag", "g", "Set flag for admin/vip to set this Event Day.");
	gc_bVote = AutoExecConfig_CreateConVar("sm_ffa_vote", "1", "0 - disabled, 1 - allow player to vote for ffa", _, true,  0.0, true, 1.0);
	gc_bSpawnCell = AutoExecConfig_CreateConVar("sm_ffa_spawn", "0", "0 - T teleport to CT spawn, 1 - cell doors auto open", _, true,  0.0, true, 1.0);
	gc_iRounds = AutoExecConfig_CreateConVar("sm_ffa_rounds", "1", "Rounds to play in a row", _, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_ffa_roundtime", "5", "Round time in minutes for a single ffa round", _, true, 1.0);
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_ffa_trucetime", "30", "Time in seconds players can't deal damage", _, true,  0.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_ffa_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true,  0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_ffa_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true,  0.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_ffa_sounds_enable", "1", "0 - disabled, 1 - enable sounds", _, true,  0.0, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_ffa_sounds_start", "music/MyJailbreak/start.mp3", "Path to the soundfile which should be played for a start.");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_ffa_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true,  0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_ffa_overlays_start", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_bAllowLR = AutoExecConfig_CreateConVar("sm_ffa_allow_lr", "1" , "0 - disabled, 1 - enable, LR on last round", _, true, 0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("round_end", RoundEnd);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sCustomCommand, OnSettingChanged);
	HookConVarChange(gc_sAdminFlag, OnSettingChanged);
	
	//FindConVar
	
	
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iGetRoundTime = FindConVar("mp_roundtime");
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
	gc_sOverlayStartPath.GetString(g_sOverlayStart , sizeof(g_sOverlayStart));
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
			RegConsoleCmd(sBufferCMD, VoteFFA, "Allows players to vote for a ffa");
	}
}

//Initialize Event

public void OnMapStart()
{
	g_iVoteCount = 0;
	g_iRound = 0;
	IsFFA = false;
	StartFFA = false;
	
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayStart);
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
		RegConsoleCmd(sBufferCMD, VoteFFA, "Allows players to vote for a ffa");
}

//Admin & Warden set Event

public Action Setffa(int client,int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if(client == 0)
		{
			StartNextRound();
			if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event FFA was started by groupvoting");
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
							if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event FFA was started by warden %L", client);
						}
						else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_progress" , EventDay);
				}
				else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_minplayer");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "war_setbywarden");
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
								if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event FFA was started by admin %L", client);
							}
							else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_wait", g_iCoolDown);
						}
						else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_progress" , EventDay);
					}
					else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_minplayer");
				}
				else CPrintToChat(client, "%t %t", "ffa_tag" , "war_setbyadmin");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_disabled");
}

//Voting for Event

public Action VoteFFA(int client,int args)
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
								if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event FFA was started by voting");
							}
							else CPrintToChatAll("%t %t", "ffa_tag" , "ffa_need", Missing, client);
						}
						else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_voted");
					}
					else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_wait", g_iCoolDown);
				}
				else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_progress" , EventDay);
			}
			else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_minplayer");
		}
		else CPrintToChat(client, "%t %t", "war_tag" , "war_voting");
	}
	else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_disabled");
}

//Prepare Event

void StartNextRound()
{
	StartFFA = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;
	
	SetEventDay("ffa");
	SetEventDayPlaned(true);
	
	g_iOldRoundTime = g_iGetRoundTime.IntValue; //save original round time
	g_iGetRoundTime.IntValue = gc_iRoundTime.IntValue;//set event round time
	
	CPrintToChatAll("%t %t", "ffa_tag" , "ffa_next");
	PrintHintTextToAll("%t", "ffa_next_nc");
}

//Round start

public void RoundStart(Handle event, char[] name, bool dontBroadcast)
{
	if (StartFFA || IsFFA)
	{
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_weapons_t", 1);
		SetCvar("sm_weapons_ct", 1);
		SetCvar("mp_teammates_are_enemies", 1);
		SetCvar("mp_friendlyfire", 1);
		SetCvar("sm_menu_enable", 0);
		SetEventDayPlaned(false);
		SetEventDayRunning(true);
		FogOn();
		g_iRound++;
		IsFFA = true;
		StartFFA = false;
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
					if (!gc_bSpawnCell.BoolValue)
					{
						if (IsClientInGame(client))
						{
							TeleportEntity(client, g_fPos, NULL_VECTOR, NULL_VECTOR);
						}
					}
				}
				
				//enable lr on last round
				if (gc_bAllowLR.BoolValue)
				{
					if (g_iRound == g_iMaxRound)
					{
						SetCvar("sm_hosties_lr", 1);
					}
				}
				
				CPrintToChatAll("%t %t", "ffa_tag" ,"ffa_rounds", g_iRound, g_iMaxRound);
			}
			LoopClients(client)
			{
				CreateInfoPanel(client);
				SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
				SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
			}
			TruceTimer = CreateTimer(1.0, StartTimer, _, TIMER_REPEAT);
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
	if (IsFFA && gc_bAllowLR.BoolValue)
	{
		LoopValidClients(client, false, true)
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
			IsFFA = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_warden_enable", 1);
			SetCvar("sm_weapons_t", 0);
			SetCvar("sm_weapons_ct", 1);
			SetCvar("mp_teammates_are_enemies", 0);
			SetCvar("mp_friendlyfire", 0);
			SetCvar("sm_menu_enable", 1);
			g_iGetRoundTime.IntValue = g_iOldRoundTime;
			SetEventDay("none");
			SetEventDayRunning(false);
			CPrintToChatAll("%t %t", "ffa_tag" , "ffa_end");
		}
	}

}

stock void CreateInfoPanel(int client)
{
	//Create info Panel
	char info[255];

	FFAMenu = CreatePanel();
	Format(info, sizeof(info), "%T", "ffa_info_title", client);
	SetPanelTitle(FFAMenu, info);
	DrawPanelText(FFAMenu, "                                   ");
	Format(info, sizeof(info), "%T", "ffa_info_line1", client);
	DrawPanelText(FFAMenu, info);
	DrawPanelText(FFAMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "ffa_info_line2", client);
	DrawPanelText(FFAMenu, info);
	Format(info, sizeof(info), "%T", "ffa_info_line3", client);
	DrawPanelText(FFAMenu, info);
	Format(info, sizeof(info), "%T", "ffa_info_line4", client);
	DrawPanelText(FFAMenu, info);
	Format(info, sizeof(info), "%T", "ffa_info_line5", client);
	DrawPanelText(FFAMenu, info);
	Format(info, sizeof(info), "%T", "ffa_info_line6", client);
	DrawPanelText(FFAMenu, info);
	Format(info, sizeof(info), "%T", "ffa_info_line7", client);
	DrawPanelText(FFAMenu, info);
	DrawPanelText(FFAMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "warden_close", client);
	DrawPanelItem(FFAMenu, info); 
	SendPanelToClient(FFAMenu, client, NullHandler, 20);
}
//Round End

public void RoundEnd(Handle event, char[] name, bool dontBroadcast)
{
	int winner = GetEventInt(event, "winner");
	
	if (IsFFA)
	{
		LoopValidClients(client, false, true) SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
		delete TruceTimer;
		if (winner == 2) PrintHintTextToAll("%t", "ffa_twin_nc"); 
		if (winner == 3) PrintHintTextToAll("%t", "ffa_ctwin_nc");
		if (g_iRound == g_iMaxRound)
		{
			IsFFA = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_warden_enable", 1);
			SetCvar("sm_weapons_t", 0);
			SetCvar("sm_weapons_ct", 1);
			SetCvar("mp_teammates_are_enemies", 0);
			SetCvar("mp_friendlyfire", 0);
			SetCvar("sm_menu_enable", 1);
			g_iGetRoundTime.IntValue = g_iOldRoundTime;
			SetEventDay("none");
			SetEventDayRunning(false);
			CPrintToChatAll("%t %t", "ffa_tag" , "ffa_end");
		}
	}
	if (StartFFA)
	{
		LoopClients(i) CreateInfoPanel(i);
		
		CPrintToChatAll("%t %t", "ffa_tag" , "ffa_next");
		PrintHintTextToAll("%t", "ffa_next_nc");
	}
}

//Map End

public void OnMapEnd()
{
	IsFFA = false;
	StartFFA = false;
	delete TruceTimer;
	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
}

//Start Timer

public Action StartTimer(Handle timer)
{
	if (g_iTruceTime > 1)
	{
		g_iTruceTime--;
		
		PrintHintTextToAll("%t", "ffa_damage_nc", g_iTruceTime);
		
		return Plugin_Continue;
	}
	
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	
	
	for(int client=1; client <= MaxClients; client++) 
	{
		if (IsClientInGame(client) && IsPlayerAlive(client)) 
		{
			SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
			if(gc_bOverlays.BoolValue) CreateTimer( 0.0, ShowOverlayStart, client);
			if(gc_bSounds.BoolValue)	
			{
				EmitSoundToAllAny(g_sSoundStartPath);
			}
			
			PrintHintText(client,"%t", "ffa_start_nc");
		}
	}
	CPrintToChatAll("%t %t", "ffa_tag" , "ffa_start");
	TruceTimer = null;
	FogOff();
	
	return Plugin_Stop;
}

