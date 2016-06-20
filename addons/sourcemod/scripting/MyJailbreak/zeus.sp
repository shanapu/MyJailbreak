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
bool IsZeus; 
bool StartZeus; 
bool canSet;

//ConVars
ConVar gc_bPlugin;
ConVar gc_bSetW;
ConVar gc_iCooldownStart;
ConVar gc_bSetA;
ConVar gc_bSpawnCell;
ConVar gc_bVote;
ConVar gc_iCooldownDay;
ConVar gc_iRoundTime;
ConVar gc_iTruceTime;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar g_iGetRoundTime;
ConVar gc_bSounds;
ConVar gc_iRounds;
ConVar gc_sSoundStartPath;
ConVar gc_sCustomCommand;

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
Handle ZeusMenu;
Handle ClientTimer[MAXPLAYERS+1];

//Strings
char g_sHasVoted[1500];
char g_sSoundStartPath[256];
char g_sCustomCommand[64];
char g_sEventsLogFile[PLATFORM_MAX_PATH];

public Plugin myinfo = {
	name = "MyJailbreak - Zeus",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = PLUGIN_VERSION,
	url = URL_LINK
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.Zeus.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_setzeus", SetZeus, "Allows the Admin or Warden to set zeus as next round");
	RegConsoleCmd("sm_zeus", VoteZeus, "Allows players to vote for a zeus");

	
	//AutoExecConfig
	AutoExecConfig_SetFile("Zeus", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_zeus_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_zeus_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_sCustomCommand = AutoExecConfig_CreateConVar("sm_zeus_cmd", "taser", "Set your custom chat command for Event voting. no need for sm_ or !");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_zeus_warden", "1", "0 - disabled, 1 - allow warden to set zeus round", _, true,  0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_zeus_admin", "1", "0 - disabled, 1 - allow admin to set zeus round", _, true,  0.0, true, 1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_zeus_vote", "1", "0 - disabled, 1 - allow player to vote for zeus", _, true,  0.0, true, 1.0);
	gc_bSpawnCell = AutoExecConfig_CreateConVar("sm_zeus_spawn", "0", "0 - T teleport to CT spawn, 1 - cell doors auto open", _, true,  0.0, true, 1.0);
	gc_iRounds = AutoExecConfig_CreateConVar("sm_zeus_rounds", "3", "Rounds to play in a row", _, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_zeus_roundtime", "5", "Round time in minutes for a single zeus round", _, true, 1.0);
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_zeus_trucetime", "15", "Time in seconds players can't deal damage", _, true,  0.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_zeus_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true,  0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_zeus_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true, 0.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_zeus_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true, 0.1, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_zeus_sounds_start", "music/MyJailbreak/start.mp3", "Path to the soundfile which should be played for a start.");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_zeus_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true,  0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_zeus_overlays_start", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("player_death", PlayerDeath);
	HookEvent("round_end", RoundEnd);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sCustomCommand, OnSettingChanged);
	
	
	//Find
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iGetRoundTime = FindConVar("mp_roundtime");
	gc_sOverlayStartPath.GetString(g_sOverlayStart , sizeof(g_sOverlayStart));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
	gc_sCustomCommand.GetString(g_sCustomCommand , sizeof(g_sCustomCommand));
	
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
	else if(convar == gc_sCustomCommand)
	{
		strcopy(g_sCustomCommand, sizeof(g_sCustomCommand), newValue);
		char sBufferCMD[64];
		Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
		if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
			RegConsoleCmd(sBufferCMD, VoteZeus, "Allows players to vote for zeus");
	}
}

//Initialize Event

public void OnMapStart()
{
	g_iVoteCount = 0;
	g_iRound = 0;
	IsZeus = false;
	StartZeus = false;
	canSet = true;
	
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStartPath);
	if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayStart);
}

public void OnConfigsExecuted()
{
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iMaxRound = gc_iRounds.IntValue;
	
	char sBufferCMD[64];
	Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
	if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMD, VoteZeus, "Allows players to vote for zeus");
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

//Admin & Warden set Event

public Action SetZeus(int client,int args)
{
	if (gc_bPlugin.BoolValue && canSet)
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
							if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event Zeus was started by warden %L", client);
						}
						else CPrintToChat(client, "%t %t", "zeus_tag" , "zeus_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "zeus_tag" , "zeus_progress" , EventDay);
				}
				else CPrintToChat(client, "%t %t", "zeus_tag" , "zeus_minplayer");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "zeus_setbywarden");
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
								if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event Zeus was started by admin %L", client);
							}
							else CPrintToChat(client, "%t %t", "zeus_tag" , "zeus_wait", g_iCoolDown);
						}
						else CPrintToChat(client, "%t %t", "zeus_tag" , "zeus_progress" , EventDay);
					}
					else CPrintToChat(client, "%t %t", "zeus_tag" , "zeus_minplayer");
				}
				else CPrintToChat(client, "%t %t", "zeus_tag" , "zeus_setbyadmin");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "zeus_tag" , "zeus_disabled");
}

//Voting for Event

public Action VoteZeus(int client,int args)
{
	char steamid[64];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	
	if (gc_bPlugin.BoolValue && canSet)
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
								if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event zeus was started by voting");
							}
							else CPrintToChatAll("%t %t", "zeus_tag" , "zeus_need", Missing, client);
						}
						else CPrintToChat(client, "%t %t", "zeus_tag" , "zeus_voted");
					}
					else CPrintToChat(client, "%t %t", "zeus_tag" , "zeus_wait", g_iCoolDown);
				}
				else CPrintToChat(client, "%t %t", "zeus_tag" , "zeus_progress" , EventDay);
			}
			else CPrintToChat(client, "%t %t", "zeus_tag" , "zeus_minplayer");
		}
		else CPrintToChat(client, "%t %t", "zeus_tag" , "zeus_voting");
	}
	else CPrintToChat(client, "%t %t", "zeus_tag" , "zeus_disabled");
}

//Prepare Event

void StartNextRound()
{
	StartZeus = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;
	
	SetEventDay("zeus");
	
	CPrintToChatAll("%t %t", "zeus_tag" , "zeus_next");
	PrintHintTextToAll("%t", "zeus_next_nc");
}

//Round start

public void RoundStart(Handle event, char[] name, bool dontBroadcast)
{
	canSet = true;
	if (StartZeus || IsZeus)
	{
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_weapons_enable", 0);
		SetCvar("sm_menu_enable", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("mp_teammates_are_enemies", 1);
		
		IsZeus = true;
		
		g_iRound++;
		StartZeus = false;
		SJD_OpenDoors();
		
		int RandomCT = 0;
		
		for(int client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client))
			{
				if (GetClientTeam(client) == CS_TEAM_CT)
				{
					RandomCT = client;
					break;
				}
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
					GivePlayerItem(client, "weapon_knife");
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
					ClientTimer[client] = CreateTimer(0.5, Timer_GiveZeus, client);
					
					if (!gc_bSpawnCell.BoolValue)
					{
						TeleportEntity(client, g_fPos, NULL_VECTOR, NULL_VECTOR);
					}
				}
				g_iTruceTime--;
				TruceTimer = CreateTimer(1.0, StartTimer, _, TIMER_REPEAT);
				CPrintToChatAll("%t %t", "zeus_tag" ,"zeus_rounds", g_iRound, g_iMaxRound);
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

stock void CreateInfoPanel(int client)
{
	//Create info Panel
	char info[255];

	ZeusMenu = CreatePanel();
	Format(info, sizeof(info), "%T", "zeus_info_title", client);
	SetPanelTitle(ZeusMenu, info);
	DrawPanelText(ZeusMenu, "                                   ");
	Format(info, sizeof(info), "%T", "zeus_info_line1", client);
	DrawPanelText(ZeusMenu, info);
	DrawPanelText(ZeusMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "zeus_info_line2", client);
	DrawPanelText(ZeusMenu, info);
	Format(info, sizeof(info), "%T", "zeus_info_line3", client);
	DrawPanelText(ZeusMenu, info);
	Format(info, sizeof(info), "%T", "zeus_info_line4", client);
	DrawPanelText(ZeusMenu, info);
	Format(info, sizeof(info), "%T", "zeus_info_line5", client);
	DrawPanelText(ZeusMenu, info);
	Format(info, sizeof(info), "%T", "zeus_info_line6", client);
	DrawPanelText(ZeusMenu, info);
	Format(info, sizeof(info), "%T", "zeus_info_line7", client);
	DrawPanelText(ZeusMenu, info);
	DrawPanelText(ZeusMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "warden_close", client);
	DrawPanelItem(ZeusMenu, info); 
	SendPanelToClient(ZeusMenu, client, NullHandler, 20);
	
}
//Start Timer

public Action StartTimer(Handle timer)
{
	if (g_iTruceTime > 1)
	{
		g_iTruceTime--;
		LoopClients(client) if(IsPlayerAlive(client)) PrintHintText(client,"%t", "zeus_timeuntilstart_nc", g_iTruceTime);
		return Plugin_Continue;
	}
	
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	if (g_iRound > 0)
	{
		LoopClients(client) if(IsPlayerAlive(client))
		{
			SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
			PrintHintText(client,"%t", "zeus_start_nc");
			if(gc_bOverlays.BoolValue) CreateTimer( 0.0, ShowOverlayStart, client);
			if(gc_bSounds.BoolValue)	
			{
				EmitSoundToAllAny(g_sSoundStartPath);
			}
			
		}
		CPrintToChatAll("%t %t", "zeus_tag" , "zeus_start");
	}
	
	TruceTimer = null;
	
	return Plugin_Stop;
}

//Round End

public void RoundEnd(Handle event, char[] name, bool dontBroadcast)
{
	canSet = false;
	int winner = GetEventInt(event, "winner");
	
	if (IsZeus)
	{
		LoopClients(client) SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
		if (TruceTimer != null) KillTimer(TruceTimer);
		if (winner == 2) PrintHintTextToAll("%t", "zeus_twin_nc");
		if (winner == 3) PrintHintTextToAll("%t", "zeus_ctwin_nc");
		if (g_iRound == g_iMaxRound)
		{
			IsZeus = false;
			StartZeus = false;
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
			CPrintToChatAll("%t %t", "zeus_tag" , "zeus_end");
		}
	}
	if (StartZeus)
	{
		LoopClients(i) CreateInfoPanel(i);
		g_iOldRoundTime = g_iGetRoundTime.IntValue;
		g_iGetRoundTime.IntValue = gc_iRoundTime.IntValue;
		
		CPrintToChatAll("%t %t", "zeus_tag" , "zeus_next");
		PrintHintTextToAll("%t", "zeus_next_nc");
	}
}

//Map End

public void OnMapEnd()
{
	IsZeus = false;
	StartZeus = false;
	canSet = true;
	if (TruceTimer != null) KillTimer(TruceTimer);
	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
	SetEventDay("none");
}

//Knife & Taser only

public Action OnWeaponCanUse(int client, int weapon)
{
	if(IsZeus == true)
	{
		char sWeapon[32];
		GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));
		if(StrEqual(sWeapon, "weapon_knife", false) || StrEqual(sWeapon, "weapon_taser", false))
		{
			return Plugin_Continue;
		}
		else return Plugin_Handled;
	}
	else return Plugin_Continue;
}

//Give new Zeus on Kill

public void PlayerDeath(Handle event, char [] name, bool dontBroadcast)
{
	if(IsZeus == true)
	{
		int killer = GetClientOfUserId(GetEventInt(event, "attacker"));
		
		ClientTimer[killer] = CreateTimer(0.5, Timer_GiveZeus, killer);
	}
}

public Action Timer_GiveZeus(Handle timer, any client)
{
	if (IsValidClient(client, true, false))
	{
		ClientTimer[client] = INVALID_HANDLE;
		GivePlayerItem(client, "weapon_taser");
	}
}