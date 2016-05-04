//includes
#include <cstrike>
#include <sourcemod>
#include <smartjaildoors>
#include <wardn>
#include <emitsoundany>
#include <colors>
#include <sdkhooks>
#include <autoexecconfig>
#include <myjailbreak>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//Booleans
bool IsEVENTNAME; 
bool StartEVENTNAME; 

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
Handle EVENTNAMEMenu;

//Strings
char g_sHasVoted[1500];
char g_sSoundStartPath[256];

public Plugin myinfo = {
	name = "MyJailbreak - EVENTNAME",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = PLUGIN_VERSION,
	url = URL_LINK
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.EVENTNAME.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_seteventname", SetEVENTNAME, "Allows the Admin or Warden to set eventname as next round");
	RegConsoleCmd("sm_eventname", VoteEVENTNAME, "Allows players to vote for a eventname");

	
	//AutoExecConfig
	AutoExecConfig_SetFile("EVENTNAME", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_eventname_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_eventname_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_bSetW = AutoExecConfig_CreateConVar("sm_eventname_warden", "1", "0 - disabled, 1 - allow warden to set eventname round", _, true,  0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_eventname_admin", "1", "0 - disabled, 1 - allow admin to set eventname round", _, true,  0.0, true, 1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_eventname_vote", "1", "0 - disabled, 1 - allow player to vote for eventname", _, true,  0.0, true, 1.0);
	gc_bSpawnCell = AutoExecConfig_CreateConVar("sm_eventname_spawn", "0", "0 - T teleport to CT spawn, 1 - cell doors auto open", _, true,  0.0, true, 1.0);
	gc_iRounds = AutoExecConfig_CreateConVar("sm_eventname_rounds", "3", "Rounds to play in a row", _, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_eventname_roundtime", "5", "Round time in minutes for a single eventname round", _, true, 1.0);
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_eventname_trucetime", "15", "Time in seconds players can't deal damage", _, true,  0.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_eventname_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true,  0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_eventname_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true, 0.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_eventname_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true, 0.1, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_eventname_sounds_start", "music/myjailbreak/start.mp3", "Path to the soundfile which should be played for a start.");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_eventname_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true,  0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_eventname_overlays_start", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("round_end", RoundEnd);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	
	
	//Find
	g_iGetRoundTime = FindConVar("mp_roundtime");
	gc_sOverlayStartPath.GetString(g_sOverlayStart , sizeof(g_sOverlayStart));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
}

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sOverlayStartPath)
	{
		strcopy(g_sOverlayStart, sizeof(g_sOverlayStart), newValue);
		if(gc_bOverlays.BoolValue) PrecacheOverlayAnyDownload(g_sOverlayStart);
	}
	else if(convar == gc_sSoundStartPath)
	{
		strcopy(g_sSoundStartPath, sizeof(g_sSoundStartPath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStartPath);
	}
}

public void OnMapStart()
{
	g_iVoteCount = 0;
	g_iRound = 0;
	IsEVENTNAME = false;
	StartEVENTNAME = false;
	
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStartPath);
	if(gc_bOverlays.BoolValue) PrecacheOverlayAnyDownload(g_sOverlayStart);
}

public void OnConfigsExecuted()
{
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iMaxRound = gc_iRounds.IntValue;
}

public Action SetEVENTNAME(int client,int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (warden_iswarden(client))
		{
			if (gc_bSetW.BoolValue)
			{
				char EventDay[64];
				GetEventDay(EventDay);
				
				if(StrEqual(EventDay, "none", false))
				{
					if (g_iCoolDown == 0)
					{
						StartNextRound();
					}
					else CPrintToChat(client, "%t %t", "eventname_tag" , "eventname_wait", g_iCoolDown);
				}
				else CPrintToChat(client, "%t %t", "eventname_tag" , "eventname_progress" , EventDay);
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "nocscope_setbywarden");
		}
		else if (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
			{
				if (gc_bSetA.BoolValue)
				{
					char EventDay[64];
					GetEventDay(EventDay);
					
					if(StrEqual(EventDay, "none", false))
					{
						if (g_iCoolDown == 0)
						{
							StartNextRound();
						}
						else CPrintToChat(client, "%t %t", "eventname_tag" , "eventname_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "eventname_tag" , "eventname_progress" , EventDay);
				}
				else CPrintToChat(client, "%t %t", "nocscope_tag" , "eventname_setbyadmin");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "eventname_tag" , "eventname_disabled");
}

public Action VoteEVENTNAME(int client,int args)
{
	char steamid[64];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	
	if (gc_bPlugin.BoolValue)
	{	
		if (gc_bVote.BoolValue)
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
						}else CPrintToChatAll("%t %t", "eventname_tag" , "eventname_need", Missing, client);
					}
					else CPrintToChat(client, "%t %t", "eventname_tag" , "eventname_voted");
				}
				else CPrintToChat(client, "%t %t", "eventname_tag" , "eventname_wait", g_iCoolDown);
			}
			else CPrintToChat(client, "%t %t", "eventname_tag" , "eventname_progress" , EventDay);
		}
		else CPrintToChat(client, "%t %t", "eventname_tag" , "eventname_voting");
	}
	else CPrintToChat(client, "%t %t", "eventname_tag" , "eventname_disabled");
}

void StartNextRound()
{

	StartEVENTNAME = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;
	
	SetEventDay("eventname");
	
	CPrintToChatAll("%t %t", "eventname_tag" , "eventname_next");
	PrintHintTextToAll("%t", "eventname_next_nc");
}

public void RoundStart(Handle event, char[] name, bool dontBroadcast)
{
	if (StartEVENTNAME || IsEVENTNAME)
	{
		char info1[255], info2[255], info3[255], info4[255], info5[255], info6[255], info7[255], info8[255];
		
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_weapons_enable", 0);
		SetCvar("sm_menu_enable", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("mp_teammates_are_enemies", 1);
		
		IsEVENTNAME = true;
		
		g_iRound++;
		StartEVENTNAME = false;
		SJD_OpenDoors();
		EVENTNAMEMenu = CreatePanel();
		Format(info1, sizeof(info1), "%T", "eventname_info_title", LANG_SERVER);
		SetPanelTitle(EVENTNAMEMenu, info1);
		DrawPanelText(EVENTNAMEMenu, "                                   ");
		Format(info2, sizeof(info2), "%T", "eventname_info_line1", LANG_SERVER);
		DrawPanelText(EVENTNAMEMenu, info2);
		DrawPanelText(EVENTNAMEMenu, "-----------------------------------");
		Format(info3, sizeof(info3), "%T", "eventname_info_line2", LANG_SERVER);
		DrawPanelText(EVENTNAMEMenu, info3);
		Format(info4, sizeof(info4), "%T", "eventname_info_line3", LANG_SERVER);
		DrawPanelText(EVENTNAMEMenu, info4);
		Format(info5, sizeof(info5), "%T", "eventname_info_line4", LANG_SERVER);
		DrawPanelText(EVENTNAMEMenu, info5);
		Format(info6, sizeof(info6), "%T", "eventname_info_line5", LANG_SERVER);
		DrawPanelText(EVENTNAMEMenu, info6);
		Format(info7, sizeof(info7), "%T", "eventname_info_line6", LANG_SERVER);
		DrawPanelText(EVENTNAMEMenu, info7);
		Format(info8, sizeof(info8), "%T", "eventname_info_line7", LANG_SERVER);
		DrawPanelText(EVENTNAMEMenu, info8);
		DrawPanelText(EVENTNAMEMenu, "-----------------------------------");
		
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
				for(int client=1; client <= MaxClients; client++)
				{
					if (IsClientInGame(client))
					{
						StripAllWeapons(client);
						
						
						
						
						
						GivePlayerItem(client, "weapon_knife");
						SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
						SendPanelToClient(EVENTNAMEMenu, client, NullHandler, 15);
						SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
						if (!gc_bSpawnCell.BoolValue)
						{
							TeleportEntity(client, Pos1, NULL_VECTOR, NULL_VECTOR);
						}
					}
				}
				g_iTruceTime--;
				TruceTimer = CreateTimer(1.0, EVENTNAMENoDamage, _, TIMER_REPEAT);
				CPrintToChatAll("%t %t", "eventname_tag" ,"eventname_rounds", g_iRound, g_iMaxRound);
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



public Action EVENTNAMENoDamage(Handle timer)
{
	if (g_iTruceTime > 1)
	{
		g_iTruceTime--;
		for (int client=1; client <= MaxClients; client++)
		if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				PrintCenterText(client,"%t", "eventname_timeuntilstart_nc", g_iTruceTime);
			}
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
				PrintCenterText(client,"%t", "eventname_start_nc");
			}
			if(gc_bOverlays.BoolValue) CreateTimer( 0.0, ShowOverlayStart, client);
			if(gc_bSounds.BoolValue)	
			{
				EmitSoundToAllAny(g_sSoundStartPath);
			}
		}
		CPrintToChatAll("%t %t", "eventname_tag" , "eventname_start");
	}
	
	
	TruceTimer = null;
	
	return Plugin_Stop;
}

public void RoundEnd(Handle event, char[] name, bool dontBroadcast)
{
	int winner = GetEventInt(event, "winner");
	
	if (IsEVENTNAME)
	{
		for(int client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client)) SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
		}
		if (TruceTimer != null) KillTimer(TruceTimer);
		if (winner == 2) PrintHintTextToAll("%t", "eventname_twin_nc");
		if (winner == 3) PrintHintTextToAll("%t", "eventname_ctwin_nc");
		if (g_iRound == g_iMaxRound)
		{
			IsEVENTNAME = false;
			StartEVENTNAME = false;
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
			CPrintToChatAll("%t %t", "eventname_tag" , "eventname_end");
		}
	}
	if (StartEVENTNAME)
	{
		g_iOldRoundTime = g_iGetRoundTime.IntValue;
		g_iGetRoundTime.IntValue = gc_iRoundTime.IntValue;
	}
}

public void OnMapEnd()
{
	IsEVENTNAME = false;
	StartEVENTNAME = false;
	if (TruceTimer != null) KillTimer(TruceTimer);
	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
	SetEventDay("none");
}