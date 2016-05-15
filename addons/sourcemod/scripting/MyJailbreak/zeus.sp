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

//Integers
int g_iOldRoundTime;
int g_iCoolDown;
int g_iTruceTime;
int g_iVoteCount;
int g_iRound;
int g_iMaxRound;

//Floats
float Pos[3];

//Handles
Handle TruceTimer;
Handle ZeusMenu;
Handle ClientTimer[MAXPLAYERS+1];

//Strings
char g_sHasVoted[1500];
char g_sSoundStartPath[256];

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
	
	AutoExecConfig_CreateConVar("sm_zeus_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_zeus_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
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
	
	
	//Find
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iGetRoundTime = FindConVar("mp_roundtime");
	gc_sOverlayStartPath.GetString(g_sOverlayStart , sizeof(g_sOverlayStart));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
}

//ConVar Change for Strings

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
}

//Initialize Event

public void OnMapStart()
{
	g_iVoteCount = 0;
	g_iRound = 0;
	IsZeus = false;
	StartZeus = false;
	
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
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

//Admin & Warden set Event

public Action SetZeus(int client,int args)
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
							LogMessage("Event Zeus was started by Warden %L", client);
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
								LogMessage("Event Zeus was started by Admin %L", client);
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
								LogMessage("Event zeus was started by voting");
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
	if (StartZeus || IsZeus)
	{
		char info1[255], info2[255], info3[255], info4[255], info5[255], info6[255], info7[255], info8[255];
		
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
			float Pos1[3];
			
			GetClientAbsOrigin(RandomCT, Pos);
			GetClientAbsOrigin(RandomCT, Pos1);
			
			Pos[2] = Pos[2] + 45;
			
			if (g_iRound > 0)
			{
				LoopClients(client)
				{
					ZeusMenu = CreatePanel();
					Format(info1, sizeof(info1), "%T", "zeus_info_title", client);
					SetPanelTitle(ZeusMenu, info1);
					DrawPanelText(ZeusMenu, "                                   ");
					Format(info2, sizeof(info2), "%T", "zeus_info_line1", client);
					DrawPanelText(ZeusMenu, info2);
					DrawPanelText(ZeusMenu, "-----------------------------------");
					Format(info3, sizeof(info3), "%T", "zeus_info_line2", client);
					DrawPanelText(ZeusMenu, info3);
					Format(info4, sizeof(info4), "%T", "zeus_info_line3", client);
					DrawPanelText(ZeusMenu, info4);
					Format(info5, sizeof(info5), "%T", "zeus_info_line4", client);
					DrawPanelText(ZeusMenu, info5);
					Format(info6, sizeof(info6), "%T", "zeus_info_line5", client);
					DrawPanelText(ZeusMenu, info6);
					Format(info7, sizeof(info7), "%T", "zeus_info_line6", client);
					DrawPanelText(ZeusMenu, info7);
					Format(info8, sizeof(info8), "%T", "zeus_info_line7", client);
					DrawPanelText(ZeusMenu, info8);
					DrawPanelText(ZeusMenu, "-----------------------------------");
					SendPanelToClient(ZeusMenu, client, NullHandler, 20);
					
					StripAllWeapons(client);
					GivePlayerItem(client, "weapon_knife");
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
					ClientTimer[client] = CreateTimer(0.5, Timer_GiveZeus, client);
					
					if (!gc_bSpawnCell.BoolValue)
					{
						TeleportEntity(client, Pos1, NULL_VECTOR, NULL_VECTOR);
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