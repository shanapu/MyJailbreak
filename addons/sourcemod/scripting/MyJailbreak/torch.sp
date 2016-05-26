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

//Booleans
bool IsTorch;
bool StartTorch;
bool OnTorch[MAXPLAYERS+1];
bool ImmuneTorch[MAXPLAYERS+1];

//ConVars
ConVar gc_bPlugin;
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_bVote;
ConVar gc_bSounds;
ConVar gc_bOverlays;
ConVar gc_bStayOverlay;
ConVar gc_iCooldownDay;
ConVar gc_iCooldownStart;
ConVar gc_iRoundTime;
ConVar gc_bSpawnCell;
ConVar gc_iTruceTime;
ConVar gc_sOverlayOnTorch;
ConVar gc_bSprintUse;
ConVar gc_iSprintCooldown;
ConVar gc_bSprint;
ConVar gc_fSprintSpeed;
ConVar gc_fSprintTime;
ConVar gc_sSoundStartPath;
ConVar gc_sOverlayStartPath;
ConVar gc_sSoundOnTorchPath;
ConVar gc_sSoundClearTorchPath;
ConVar g_iGetRoundTime;
ConVar gc_iRounds;
ConVar gc_sCustomCommand;

//Integers
int g_iVoteCount;
int g_iOldRoundTime;
int g_iCoolDown;
int g_iTruceTime;
int g_iRound;
int ClientSprintStatus[MAXPLAYERS+1];
int g_iMaxRound;
int g_iBurningZero = -1;

//Handles
Handle SprintTimer[MAXPLAYERS+1];
Handle TorchMenu;
Handle TruceTimer;

//Strings
char g_sSoundClearTorchPath[256];
char g_sSoundOnTorchPath[256];
char g_sHasVoted[1500];
char g_sOverlayOnTorch[256];
char g_sSoundStartPath[256];
char g_sCustomCommand[64];

//Floats
float g_fPos[3];

public Plugin myinfo = {
	name = "MyJailbreak - Torch & OnTorch",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = PLUGIN_VERSION,
	url = URL_LINK
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.Torch.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_settorch", SetTorch, "Allows the Admin or Warden to set torch as next round");
	RegConsoleCmd("sm_torch", VoteTorch, "Allows players to vote for a torch ");
	RegConsoleCmd("sm_sprint", Command_StartSprint, "Start sprinting!");
	
	//AutoExecConfig
	AutoExecConfig_SetFile("Torch", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_torch_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_torch_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true, 0.0, true, 1.0);
	gc_sCustomCommand = AutoExecConfig_CreateConVar("sm_torch_cmd", "torch", "Set your custom chat command for Event voting. no need for sm_ or !");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_torch_warden", "1", "0 - disabled, 1 - allow warden to set torch round", _, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_torch_admin", "1", "0 - disabled, 1 - allow admin to set torch round", _, true, 0.0, true, 1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_torch_vote", "1", "0 - disabled, 1 - allow player to vote for torch", _, true, 0.0, true, 1.0);
	gc_iRounds = AutoExecConfig_CreateConVar("sm_torch_rounds", "3", "Rounds to play in a row", _, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_torch_roundtime", "9", "Round time in minutes for a single torch round", _, true, 1.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_torch_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true, 0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_torch_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true, 0.0);
	gc_bSpawnCell = AutoExecConfig_CreateConVar("sm_torch_spawn", "0", "0 - T teleport to CT spawn, 1 - cell doors auto open", _, true,  0.0, true, 1.0);
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_torch_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true, 0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_torch_overlays_start", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_sOverlayOnTorch = AutoExecConfig_CreateConVar("sm_torch_overlaytorch_path", "overlays/MyJailbreak/fire" , "Path to the OnTorch Overlay DONT TYPE .vmt or .vft");
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_torch_trucetime", "10", "Time in seconds players can't deal damage", _, true,  0.0);
	gc_bStayOverlay = AutoExecConfig_CreateConVar("sm_torch_stayoverlay", "1", "0 - overlays will removed after 3sec. , 1 - overlays will stay until untorch", _, true, 0.0, true, 1.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_torch_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true, 0.0, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_torch_sounds_start", "music/MyJailbreak/burn.mp3", "Path to the soundfile which should be played for a start.");
	gc_sSoundOnTorchPath = AutoExecConfig_CreateConVar("sm_torch_sounds_torch", "music/MyJailbreak/fire.mp3", "Path to the soundfile which should be played on torch.");
	gc_sSoundClearTorchPath = AutoExecConfig_CreateConVar("sm_torch_sounds_untorch", "music/MyJailbreak/water.mp3", "Path to the soundfile which should be played on untorch.");
	gc_bSprint = AutoExecConfig_CreateConVar("sm_torch_sprint_enable", "1", "0 - disabled, 1 - enable ShortSprint", _, true, 0.0, true, 1.0);
	gc_bSprintUse = AutoExecConfig_CreateConVar("sm_torch_sprint_button", "1", "0 - disabled, 1 - enable +use button for sprint", _, true, 0.0, true, 1.0);
	gc_iSprintCooldown= AutoExecConfig_CreateConVar("sm_torch_sprint_cooldown", "10", "Time in seconds the player must wait for the next sprint", _, true, 0.0);
	gc_fSprintSpeed = AutoExecConfig_CreateConVar("sm_torch_sprint_speed", "1.25", "Ratio for how fast the player will sprint", _, true, 1.01);
	gc_fSprintTime = AutoExecConfig_CreateConVar("sm_torch_sprint_time", "3.0", "Time in seconds the player will sprint", _, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("round_end", RoundEnd);
	HookEvent("player_team", EventPlayerTeamDeath);
	HookEvent("player_death", EventPlayerTeamDeath);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sOverlayOnTorch, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundOnTorchPath, OnSettingChanged);
	HookConVarChange(gc_sSoundClearTorchPath, OnSettingChanged);
	HookConVarChange(gc_sCustomCommand, OnSettingChanged);
	
	//FindConVar
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iMaxRound = gc_iRounds.IntValue;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iGetRoundTime = FindConVar("mp_roundtime");
	gc_sSoundOnTorchPath.GetString(g_sSoundOnTorchPath, sizeof(g_sSoundOnTorchPath));
	gc_sSoundClearTorchPath.GetString(g_sSoundClearTorchPath, sizeof(g_sSoundClearTorchPath));
	gc_sOverlayOnTorch.GetString(g_sOverlayOnTorch , sizeof(g_sOverlayOnTorch));
	gc_sCustomCommand.GetString(g_sCustomCommand , sizeof(g_sCustomCommand));
	gc_sOverlayStartPath.GetString(g_sOverlayStart , sizeof(g_sOverlayStart));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
}

//ConVarChange for Strings

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sSoundOnTorchPath)
	{
		strcopy(g_sSoundOnTorchPath, sizeof(g_sSoundOnTorchPath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundOnTorchPath);
	}
	else if(convar == gc_sSoundClearTorchPath)
	{
		strcopy(g_sSoundClearTorchPath, sizeof(g_sSoundClearTorchPath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundClearTorchPath);
	}
	else if(convar == gc_sOverlayOnTorch)
	{
		strcopy(g_sOverlayOnTorch, sizeof(g_sOverlayOnTorch), newValue);
		if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayOnTorch);
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
			RegConsoleCmd(sBufferCMD, VoteTorch, "Allows players to vote for a torch ");
	}
}

//Initialize Event

public void OnMapStart()
{
	g_iVoteCount = 0;
	g_iRound = 0;
	IsTorch = false;
	StartTorch = false;
	
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundOnTorchPath);
	if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundClearTorchPath);
	if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStartPath);
	if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayStart);
	if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayOnTorch);
	PrecacheSound("player/suit_sprint.wav", true);
}

public void OnConfigsExecuted()
{
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iMaxRound = gc_iRounds.IntValue;
	
	char sBufferCMD[64];
	Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
	if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMD, VoteTorch, "Allows players to vote for a torch ");
}

public void OnClientPutInServer(int client)
{
	OnTorch[client] = false;
	ImmuneTorch[client] = false;
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	SDKHook(client, SDKHook_TraceAttack, OnTakedamage);
}

//Admin & Warden set Event

public Action SetTorch(int client,int args)
{
	if (gc_bPlugin.BoolValue)	
	{
		if (warden_iswarden(client))
		{
			if (gc_bSetW.BoolValue)	
			{
				if ((GetTeamClientCount(CS_TEAM_CT) > 0) && (GetTeamClientCount(CS_TEAM_T) > 0 ) && (GetClientCount() > 2))
				{
					char EventDay[64];
					GetEventDay(EventDay);
					
					if(StrEqual(EventDay, "none", false))
					{
						if (g_iCoolDown == 0)
						{
							StartNextRound();
							LogMessage("Event Torch was started by Warden %L", client);
						}
						else CPrintToChat(client, "%t %t", "torch_tag" , "torch_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "torch_tag" , "torch_progress" , EventDay);
				}
				else CPrintToChat(client, "%t %t", "torch_tag" , "torch_minplayer");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "torch_setbywarden");
		}
		else if (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
			{
				if (gc_bSetA.BoolValue)
				{
					if ((GetTeamClientCount(CS_TEAM_CT) > 0) && (GetTeamClientCount(CS_TEAM_T) > 0 ) && (GetClientCount() > 2))
					{
						char EventDay[64];
						GetEventDay(EventDay);
						
						if(StrEqual(EventDay, "none", false))
						{
							if (g_iCoolDown == 0)
							{
								StartNextRound();
								LogMessage("Event Torch was started by Admin %L", client);
							}
							else CPrintToChat(client, "%t %t", "torch_tag" , "torch_wait", g_iCoolDown);
						}
						else CPrintToChat(client, "%t %t", "torch_tag" , "torch_progress" , EventDay);
					}
					else CPrintToChat(client, "%t %t", "torch_tag" , "torch_minplayer");
				}
				else CPrintToChat(client, "%t %t", "torch_tag" , "torch_setbyadmin");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "torch_tag" , "torch_disabled");
}

//Voting for Event

public Action VoteTorch(int client,int args)
{
	char steamid[64];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bVote.BoolValue)
		{
			if ((GetTeamClientCount(CS_TEAM_CT) > 0) && (GetTeamClientCount(CS_TEAM_T) > 0 ) && (GetClientCount() > 2))
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
								LogMessage("Event Torch was started by voting");
							}
							else CPrintToChatAll("%t %t", "torch_tag" , "torch_need", Missing, client);
						}
						else CPrintToChat(client, "%t %t", "torch_tag" , "torch_voted");
					}
					else CPrintToChat(client, "%t %t", "torch_tag" , "torch_wait", g_iCoolDown);
				}
				else CPrintToChat(client, "%t %t", "torch_tag" , "torch_progress" , EventDay);
			}
			else CPrintToChat(client, "%t %t", "torch_tag" , "torch_minplayer");
		}
		else CPrintToChat(client, "%t %t", "torch_tag" , "torch_voting");
	}
	else CPrintToChat(client, "%t %t", "torch_tag" , "torch_disabled");
}

//Prepare Event

void StartNextRound()
{
	StartTorch = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;
	
	SetEventDay("torch");
	
	CPrintToChatAll("%t %t", "torch_tag" , "torch_next");
	PrintHintTextToAll("%t", "torch_next_nc");
}

//Round start

public void RoundStart(Handle event, char[] name, bool dontBroadcast)
{

	if (StartTorch || IsTorch)
	{
		char info1[255], info2[255], info3[255], info4[255], info5[255], info6[255], info7[255], info8[255];
		
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_weapons_enable", 0);
		
		IsTorch = true;
		g_iRound++;
		StartTorch = false;
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
				CPrintToChatAll("%t %t", "torch_tag" ,"torch_rounds", g_iRound, g_iMaxRound);
			}
			LoopClients(client)
			{
				TorchMenu = CreatePanel();
				Format(info1, sizeof(info1), "%T", "torch_info_title", client);
				SetPanelTitle(TorchMenu, info1);
				DrawPanelText(TorchMenu, "                                   ");
				Format(info2, sizeof(info2), "%T", "torch_info_line1", client);
				DrawPanelText(TorchMenu, info2);
				DrawPanelText(TorchMenu, "-----------------------------------");
				Format(info3, sizeof(info3), "%T", "torch_info_line2", client);
				DrawPanelText(TorchMenu, info3);
				Format(info4, sizeof(info4), "%T", "torch_info_line3", client);
				DrawPanelText(TorchMenu, info4);
				Format(info5, sizeof(info5), "%T", "torch_info_line4", client);
				DrawPanelText(TorchMenu, info5);
				Format(info6, sizeof(info6), "%T", "torch_info_line5", client);
				DrawPanelText(TorchMenu, info6);
				Format(info7, sizeof(info7), "%T", "torch_info_line6", client);
				DrawPanelText(TorchMenu, info7);
				Format(info8, sizeof(info8), "%T", "torch_info_line7", client);
				DrawPanelText(TorchMenu, info8);
				DrawPanelText(TorchMenu, "-----------------------------------");
				
				StripAllWeapons(client);
				ClientSprintStatus[client] = 0;
				GivePlayerItem(client, "weapon_knife");
				SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
				SendPanelToClient(TorchMenu, client, NullHandler, 20);
				OnTorch[client] = false;
				ImmuneTorch[client] = false;
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

public Action StartTimer(Handle timer)
{
	if (g_iTruceTime > 1)
	{
		g_iTruceTime--;
		
		PrintHintTextToAll("%t", "torch_damage_nc", g_iTruceTime);
		
		return Plugin_Continue;
	}
	
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	
	g_iBurningZero = GetRandomPlayer();
	if(g_iBurningZero > 0)
	{
		CPrintToChatAll("%t %t", "torch_tag", "torch_random", g_iBurningZero); 
		
		SetEntityRenderColor(g_iBurningZero, 255, 120, 0, 255);
		OnTorch[g_iBurningZero] = true;
		CreateTimer( 0.0, ShowOverlayOnTorch, g_iBurningZero );
		IgniteEntity(g_iBurningZero, 200.0);
		SetEntPropFloat(g_iBurningZero, Prop_Data, "m_flLaggedMovementValue", gc_fSprintSpeed.FloatValue);
		if(gc_bSounds.BoolValue)	
		{
			EmitSoundToClientAny(g_iBurningZero, g_sSoundOnTorchPath);
		}
		if(!gc_bStayOverlay.BoolValue)	
		{
			CreateTimer( 3.0, DeleteOverlay, g_iBurningZero );
		}
	}
	
	LoopClients(client)
	{
	if (IsClientInGame(client) && IsPlayerAlive(client) && (client != g_iBurningZero)) 
		{
			SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
			if(gc_bOverlays.BoolValue) CreateTimer( 0.0, ShowOverlayStart, client);
			if(gc_bSounds.BoolValue)
			{
				EmitSoundToClientAny(client, g_sSoundStartPath);
			}
			PrintHintText(client,"%t", "torch_start_nc");
		}
	}
	CPrintToChatAll("%t %t", "torch_tag" , "torch_start");
	
	TruceTimer = null;
	
	return Plugin_Stop;
}

stock int GetRandomPlayer() 
{
	int[] clients = new int[MaxClients];
	int clientCount;
	LoopClients(i)
	{
		if (IsPlayerAlive(i))
		{
			clients[clientCount++] = i;
		}
	}
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)];
}


//Round End

public void RoundEnd(Handle event, char[] name, bool dontBroadcast)
{
	if (IsTorch)
	{
		LoopValidClients(client, true, true)
		{
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
			ClientSprintStatus[client] = 0;
			CreateTimer( 0.0, DeleteOverlay, client );
			SetEntityRenderColor(client, 255, 255, 255, 0);
			OnTorch[client] = false;
			ImmuneTorch[client] = false;
			StripAllWeapons(client);
		}
		g_iBurningZero = -1;
		if (TruceTimer != null) KillTimer(TruceTimer);
		if (g_iRound == g_iMaxRound)
		{
			IsTorch = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_weapons_enable", 1);
			SetCvar("sm_warden_enable", 1);
			
			g_iGetRoundTime.IntValue = g_iOldRoundTime;
			SetEventDay("none");
			CPrintToChatAll("%t %t", "torch_tag" , "torch_end");
		}
	}
	if (StartTorch)
	{
		g_iOldRoundTime = g_iGetRoundTime.IntValue;
		g_iGetRoundTime.IntValue = gc_iRoundTime.IntValue;
		
		CPrintToChatAll("%t %t", "torch_tag" , "torch_next");
		PrintHintTextToAll("%t", "torch_next_nc");
	}
}

//Map End

public void OnMapEnd()
{
	IsTorch = false;
	StartTorch = false;
	g_iBurningZero = -1;
	if (TruceTimer != null) KillTimer(TruceTimer);
	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
	SetEventDay("none");
}

//Torch & OnTorch

public Action OnTakedamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(!IsValidClient(victim, true, false)|| attacker == victim || !IsValidClient(attacker, true, false)) return Plugin_Continue;
	
	if(IsTorch == false)
	{
		return Plugin_Continue;
	}
	if(!ImmuneTorch[victim] && OnTorch[attacker])
	{
		TorchEm(victim);
		ExtinguishEm(attacker);
	}
	return Plugin_Handled;
}

public Action TorchEm(int client)
{
	SetEntityRenderColor(client, 255, 120, 0, 255);
	OnTorch[client] = true;
	CreateTimer( 0.0, ShowOverlayOnTorch, client );
	IgniteEntity(client, 200.0);
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", gc_fSprintSpeed.FloatValue);
	if(gc_bSounds.BoolValue)	
	{
		EmitSoundToClientAny(client, g_sSoundOnTorchPath);
	}
	if(!gc_bStayOverlay.BoolValue)
	{
		CreateTimer( 3.0, DeleteOverlay, client );
	}
	
	
	CPrintToChatAll("%t %t", "torch_tag" , "torch_torchem", client);
}

public Action ExtinguishEm(int client)
{
	LoopClients(i) ImmuneTorch[i] = false;
	SetEntityRenderColor(client, 0, 0, 0, 255);
	OnTorch[client] = false;
	ImmuneTorch[client] = true;
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	CreateTimer( 0.0, DeleteOverlay, client);
	if(gc_bSounds.BoolValue)	
	{
		EmitSoundToClientAny(client, g_sSoundClearTorchPath);
	}
	int ent = GetEntPropEnt(client, Prop_Data, "m_hEffectEntity");
	if (IsValidEdict(ent))
		SetEntPropFloat(ent, Prop_Data, "m_flLifetime", 0.0);  
	
	CPrintToChatAll("%t %t", "torch_tag" , "torch_untorch", client);
}

public void OnClientDisconnect_Post(int client)
{

	if(IsTorch == false)
	{
		return;
	}
	CheckStatus();
}

public Action EventPlayerTeamDeath(Event event, const char[] name, bool dontBroadcast)
{
	if(IsTorch == false)
	{
		return;
	}
	CheckStatus();
	
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	ResetSprint(iClient);
}


public Action CheckStatus()
{
	int number = 0;
	LoopClients(i) if(IsPlayerAlive(i) && OnTorch[i]) number++;
	if(number == 0)
	{
		CPrintToChatAll("%t %t", "torch_tag", "torch_win");
		CS_TerminateRound(5.0, CSRoundEnd_Draw);
		CreateTimer( 1.0, DeleteOverlay);
	}
}

//Knife only

public Action OnWeaponCanUse(int client, int weapon)
{
	char sWeapon[32];
	GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));
	
	if(!StrEqual(sWeapon, "weapon_knife"))
		{
			if (IsValidClient(client, true, false))
			{
				if(IsTorch == true)
				{
					return Plugin_Handled;
				}
			}
		}
	return Plugin_Continue;
}

//Overlays

public Action ShowOverlayOnTorch( Handle timer, any client ) {
	
	if(gc_bOverlays.BoolValue && IsValidClient(client, false, true))
	{
	int iFlag = GetCommandFlags( "r_screenoverlay" ) & ( ~FCVAR_CHEAT ); 
	SetCommandFlags( "r_screenoverlay", iFlag ); 
	ClientCommand( client, "r_screenoverlay \"%s.vtf\"", g_sOverlayOnTorch);
	}
	return Plugin_Continue;
}

//Sprint

public Action Command_StartSprint(int client, int args)
{
	if (IsTorch)
	{
		{
			if (OnTorch[client] == false)
			{
				if(gc_bSprint.BoolValue && client > 0 && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) > 1 && !(ClientSprintStatus[client] & IsSprintUsing) && !(ClientSprintStatus[client] & IsSprintCoolDown))
				{
					ClientSprintStatus[client] |= IsSprintUsing | IsSprintCoolDown;
					SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", gc_fSprintSpeed.FloatValue);
					EmitSoundToClient(client, "player/suit_sprint.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.8);
					CPrintToChat(client, "%t %t", "torch_tag" ,"torch_sprint");
					SprintTimer[client] = CreateTimer(gc_fSprintTime.FloatValue, Timer_SprintEnd, client);
				}
				return(Plugin_Handled);
			}
		}
	}
	else CPrintToChat(client, "%t %t", "torch_tag" , "torch_disabled");
	return(Plugin_Handled);
}

public void OnGameFrame()
{
	if (IsTorch)
	{
		if(gc_bSprintUse.BoolValue)
		{
			LoopClients(i)
			{
				if(GetClientButtons(i) & IN_USE)
				{
					Command_StartSprint(i, 0);
				}
			}
		}
		return;
	}
	return;
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
			CPrintToChat(client, "%t %t", "torch_tag" ,"torch_sprintend", gc_iSprintCooldown.IntValue);
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
		CPrintToChat(client, "%t %t", "torch_tag" ,"torch_sprintagain", gc_iSprintCooldown.IntValue);
	}
	return;
}

public void Event_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	ResetSprint(iClient);
	ClientSprintStatus[iClient] &= ~ IsSprintCoolDown;
	return;
}