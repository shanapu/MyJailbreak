//includes
#include <cstrike>
#include <sourcemod>
#include <colors>
#include <smartjaildoors>
#include <warden>
#include <emitsoundany>
#include <autoexecconfig>
#include <myjailbreak>
#include <CustomPlayerSkins>
#include <lastrequest>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//Booleans
bool IsZombie;
bool StartZombie;

//ConVars
ConVar gc_bPlugin;
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_iCooldownStart;
ConVar gc_bVote;
ConVar gc_iRoundTime;
ConVar gc_iCooldownDay;
ConVar gc_iFreezeTime;
ConVar gc_bSpawnCell;
ConVar gc_iZombieHP;
ConVar gc_iHumanHP;
ConVar gc_bDark;
ConVar gc_bVision;
ConVar gc_bGlow;
ConVar gc_sModelPath;
ConVar gc_bSounds;
ConVar gc_sSoundStartPath;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar g_iGetRoundTime;
ConVar g_sOldSkyName;
ConVar gc_iRounds;
ConVar gc_sCustomCommand;
ConVar gc_sAdminFlag;
ConVar gc_bAllowLR;

//Integers
int g_iOldRoundTime;
int g_iFreezeTime;
int g_iCoolDown;
int g_iVoteCount;
int g_iRound;
int g_iMaxRound;

//Handles
Handle FreezeTimer;
Handle GlowTimer;
Handle ZombieMenu;

//Floats
float g_fPos[3];

//Strings
char g_sZombieModel[256];
char g_sHasVoted[1500];
char g_sSoundStartPath[256];
char g_sSkyName[256];
char g_sCustomCommand[64];
char g_sEventsLogFile[PLATFORM_MAX_PATH];
char g_sAdminFlag[32];
char g_sModelPath[MAXPLAYERS+1][256];

public Plugin myinfo = {
	name = "MyJailbreak - Zombie",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = PLUGIN_VERSION,
	url = URL_LINK
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.Zombie.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_setzombie", SetZombie, "Allows the Admin or Warden to set Zombie as next round");
	RegConsoleCmd("sm_zombie", VoteZombie, "Allows players to vote for a Zombie");
	
	//AutoExecConfig
	AutoExecConfig_SetFile("Zombie", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_zombie_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_zombie_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true, 0.0, true, 1.0);
	gc_sCustomCommand = AutoExecConfig_CreateConVar("sm_zombie_cmd", "zd", "Set your custom chat command for Event voting. no need for sm_ or !");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_zombie_warden", "1", "0 - disabled, 1 - allow warden to set zombie round", _, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_zombie_admin", "1", "0 - disabled, 1 - allow admin/vip to set zombie round", _, true, 0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_zombie_flag", "g", "Set flag for admin/vip to set this Event Day.");
	gc_bVote = AutoExecConfig_CreateConVar("sm_zombie_vote", "1", "0 - disabled, 1 - allow player to vote for zombie", _, true, 0.0, true, 1.0);
	gc_bSpawnCell = AutoExecConfig_CreateConVar("sm_zombie_spawn", "0", "0 - T teleport to CT spawn, 1 - cell doors auto open", _, true,  0.0, true, 1.0);
	gc_iRounds = AutoExecConfig_CreateConVar("sm_zombie_rounds", "1", "Rounds to play in a row", _, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_zombie_roundtime", "5", "Round time in minutes for a single zombie round", _, true, 1.0);
	gc_iFreezeTime = AutoExecConfig_CreateConVar("sm_zombie_freezetime", "35", "Time in seconds the zombies freezed", _, true, 0.0);
	gc_iZombieHP = AutoExecConfig_CreateConVar("sm_zombie_zombie_hp", "8500", "HP the Zombies got on Spawn", _, true, 1.0);
	gc_iHumanHP = AutoExecConfig_CreateConVar("sm_zombie_human_hp", "65", "HP the Humans got on Spawn", _, true, 1.0);
	gc_bDark = AutoExecConfig_CreateConVar("sm_zombie_dark", "1", "0 - disabled, 1 - enable Map Darkness", _, true,  0.0, true, 1.0);
	gc_bGlow = AutoExecConfig_CreateConVar("sm_zombie_glow", "0", "0 - disabled, 1 - enable Glow effect for humans", _, true,  0.0, true, 1.0);
	gc_bVision = AutoExecConfig_CreateConVar("sm_zombie_vision", "1", "0 - disabled, 1 - enable NightVision View for Zombies", _, true,  0.0, true, 1.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_zombie_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true, 0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_zombie_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true, 0.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_zombie_sounds_enable", "1", "0 - disabled, 1 - enable sounds", _, true, 0.0, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_zombie_sounds_start", "music/MyJailbreak/zombie.mp3", "Path to the soundfile which should be played for a start.");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_zombie_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true, 0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_zombie_overlays_start", "overlays/MyJailbreak/zombie" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_sModelPath = AutoExecConfig_CreateConVar("sm_zombie_model", "models/player/custom_player/zombie/revenant/revenant_v2.mdl", "Path to the model for zombies.");
	gc_bAllowLR = AutoExecConfig_CreateConVar("sm_zombie_allow_lr", "1" , "0 - disabled, 1 - enable, LR on last round", _, true, 0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("round_end", RoundEnd);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sModelPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sCustomCommand, OnSettingChanged);
	HookConVarChange(gc_sAdminFlag, OnSettingChanged);
	
	//FindConVar
	g_iGetRoundTime = FindConVar("mp_roundtime");
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	gc_sOverlayStartPath.GetString(g_sOverlayStart , sizeof(g_sOverlayStart));
	gc_sModelPath.GetString(g_sZombieModel, sizeof(g_sZombieModel));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
	gc_sCustomCommand.GetString(g_sCustomCommand , sizeof(g_sCustomCommand));
	gc_sAdminFlag.GetString(g_sAdminFlag , sizeof(g_sAdminFlag));
	
	SetLogFile(g_sEventsLogFile, "Events");
}

//ConVarChange for Strings

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sModelPath)
	{
		strcopy(g_sZombieModel, sizeof(g_sZombieModel), newValue);
		PrecacheModel(g_sZombieModel);
	}
	else if(convar == gc_sAdminFlag)
	{
		strcopy(g_sAdminFlag, sizeof(g_sAdminFlag), newValue);
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
			RegConsoleCmd(sBufferCMD, VoteZombie, "Allows players to vote for zombie");
	}
}

//Initialize Event

public void OnMapStart()
{
	g_iVoteCount = 0;
	g_iRound = 0;
	IsZombie = false;
	StartZombie = false;
	
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_sOldSkyName = FindConVar("sv_skyname");
	g_sOldSkyName.GetString(g_sSkyName, sizeof(g_sSkyName));
	
	if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStartPath);
	if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayStart);
	PrecacheModel(g_sZombieModel);
}

public void OnConfigsExecuted()
{
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iMaxRound = gc_iRounds.IntValue;
	
	char sBufferCMD[64];
	Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
	if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMD, VoteZombie, "Allows players to vote for zombie");
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

//Admin & Warden set Event

public Action SetZombie(int client,int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if(client == 0)
		{
			StartNextRound();
			if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event zombie was started by groupvoting");
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
							if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event Zombie was started by warden %L", client);
						}
						else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_progress" , EventDay);
				}
				else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_minplayer");
		}
			else CPrintToChat(client, "%t %t", "warden_tag" , "zombie_setbywarden");
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
							if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event Zombie was started by admin %L", client);
						}
						else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_progress" , EventDay);
				}
				else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_minplayer");
			}
			else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_setbyadmin");
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_disabled");
}

//Voting for Event

public Action VoteZombie(int client,int args)
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
								if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event Zombie was started by voting");
							}
							else CPrintToChatAll("%t %t", "zombie_tag" , "zombie_need", Missing, client);
						}
						else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_voted");
					}
					else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_wait", g_iCoolDown);
				}
				else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_progress" , EventDay);
			}
			else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_minplayer");
		}
		else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_voting");
	}
	else CPrintToChat(client, "%t %t", "zombie_tag" , "zombie_disabled");
}

//Prepare Event

void StartNextRound()
{
	StartZombie = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;
	SetEventDay("zombie");
	SetEventDayPlaned(true);
	
	g_iOldRoundTime = g_iGetRoundTime.IntValue; //save original round time
	g_iGetRoundTime.IntValue = gc_iRoundTime.IntValue;//set event round time
	
	CPrintToChatAll("%t %t", "zombie_tag" , "zombie_next");
	PrintHintTextToAll("%t", "zombie_next_nc");
}

//Round start

public void RoundStart(Handle event, char[] name, bool dontBroadcast)
{
	if (StartZombie || IsZombie)
	{
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvarString("sv_skyname", "cs_baggage_skybox_");
		SetCvar("sm_weapons_t", 1);
		SetCvar("sm_weapons_ct", 0);
		SetCvar("sv_infinite_ammo", 2);
		SetCvar("sm_menu_enable", 0);
		SetEventDayPlaned(false);
		SetEventDayRunning(true);
		IsZombie = true;
		g_iRound++;
		StartZombie = false;
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
			
			g_fPos[2] = g_fPos[2] + 6;
			
			if (g_iRound > 0)
			{
				LoopClients(client)
				{
					CreateInfoPanel(client);
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
					
					if (GetClientTeam(client) == CS_TEAM_CT)
					{
						GetEntPropString(client, Prop_Data, "m_ModelName", g_sModelPath[client], sizeof(g_sModelPath[]));
						SetEntityModel(client, g_sZombieModel);
						SetEntityMoveType(client, MOVETYPE_NONE);
						SetEntityHealth(client, gc_iZombieHP.IntValue);
						StripAllWeapons(client);
						GivePlayerItem(client, "weapon_knife");
					}
					if (GetClientTeam(client) == CS_TEAM_T)
					{
						SetEntityHealth(client, gc_iHumanHP.IntValue);
						GivePlayerItem(client, "weapon_negev");
						GivePlayerItem(client, "weapon_tec9");
						GivePlayerItem(client, "weapon_hegrenade");
						GivePlayerItem(client, "weapon_molotov");
						if (gc_bGlow.BoolValue && (IsValidClient(client, false, true))) GlowTimer = CreateTimer(1.5, Glow_Timer, client, TIMER_REPEAT);
					}
					if (!gc_bSpawnCell.BoolValue)
					{
						TeleportEntity(client, g_fPos, NULL_VECTOR, NULL_VECTOR);
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
			}
			g_iFreezeTime--;
			FreezeTimer = CreateTimer(1.0, StartTimer, _, TIMER_REPEAT);
			
			CPrintToChatAll("%t %t", "zombie_tag" ,"zombie_rounds", g_iRound, g_iMaxRound);
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
	if (IsZombie && gc_bAllowLR.BoolValue)
	{
		
		LoopValidClients(client,false,true)
		{
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
			char model[PLATFORM_MAX_PATH]; 
			GetClientModel(client, model, sizeof(model)); 
			int skin = CPS_SetSkin(client, model, CPS_RENDER);
			if(skin != -1 && gc_bGlow.BoolValue)
			{
				SetEntProp(skin, Prop_Send, "m_bShouldGlow", false, true);
				SetEntProp(skin, Prop_Send, "m_nGlowStyle", 1);
				SetEntPropFloat(skin, Prop_Send, "m_flGlowMaxDist", 10000000.0);
			}
			SetEntProp(client, Prop_Send, "m_bNightVisionOn", 0);
			
			SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
			
			StripAllWeapons(client);
			if (GetClientTeam(client) == CS_TEAM_CT)
			{
				FakeClientCommand(client, "sm_guns");
				SetEntityModel(client, g_sModelPath[client]);
				SetEntityHealth(client, 100);
			}
			GivePlayerItem(client, "weapon_knife");
		}
		
		delete FreezeTimer;
		delete GlowTimer;
		if (g_iRound == g_iMaxRound)
		{
			IsZombie = false;
			StartZombie = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_weapons_t", 0);
			SetCvar("sm_weapons_ct", 1);
			SetCvarString("sv_skyname", g_sSkyName);
			SetCvar("sv_infinite_ammo", 0);
			SetCvar("sm_warden_enable", 1);
			SetCvar("sm_menu_enable", 1);
			g_iGetRoundTime.IntValue = g_iOldRoundTime;
			SetEventDay("none");
			SetEventDayRunning(false);
			FogOff();
			CPrintToChatAll("%t %t", "zombie_tag" , "zombie_end");
		}
	}

}

stock void CreateInfoPanel(int client)
{
	//Create info Panel
	char info[255];
	
	ZombieMenu = CreatePanel();
	Format(info, sizeof(info), "%T", "zombie_info_title", client);
	SetPanelTitle(ZombieMenu, info);
	DrawPanelText(ZombieMenu, "                                   ");
	Format(info, sizeof(info), "%T", "zombie_info_line1", client);
	DrawPanelText(ZombieMenu, info);
	DrawPanelText(ZombieMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "zombie_info_line2", client);
	DrawPanelText(ZombieMenu, info);
	Format(info, sizeof(info), "%T", "zombie_info_line3", client);
	DrawPanelText(ZombieMenu, info);
	Format(info, sizeof(info), "%T", "zombie_info_line4", client);
	DrawPanelText(ZombieMenu, info);
	Format(info, sizeof(info), "%T", "zombie_info_line5", client);
	DrawPanelText(ZombieMenu, info);
	Format(info, sizeof(info), "%T", "zombie_info_line6", client);
	DrawPanelText(ZombieMenu, info);
	Format(info, sizeof(info), "%T", "zombie_info_line7", client);
	DrawPanelText(ZombieMenu, info);
	DrawPanelText(ZombieMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "warden_close", client);
	DrawPanelItem(ZombieMenu, info); 
	SendPanelToClient(ZombieMenu, client, NullHandler, 20);
}
//Round End

public void RoundEnd(Handle event, char[] name, bool dontBroadcast)
{
	int winner = GetEventInt(event, "winner");
	
	if (IsZombie)
	{
		LoopValidClients(client,false,true)
		{
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
			char model[PLATFORM_MAX_PATH]; 
			GetClientModel(client, model, sizeof(model)); 
			int skin = CPS_SetSkin(client, model, CPS_RENDER);
			if(skin != -1 && gc_bGlow.BoolValue)
			{
				SetEntProp(skin, Prop_Send, "m_bShouldGlow", false, true);
				SetEntProp(skin, Prop_Send, "m_nGlowStyle", 1);
				SetEntPropFloat(skin, Prop_Send, "m_flGlowMaxDist", 10000000.0);
			}
			SetEntProp(client, Prop_Send, "m_bNightVisionOn", 0);
		}
		
		delete FreezeTimer;
		delete GlowTimer;
		
		if (winner == 2) PrintHintTextToAll("%t", "zombie_twin_nc");
		if (winner == 3) PrintHintTextToAll("%t", "zombie_ctwin_nc");
		if (g_iRound == g_iMaxRound)
		{
			IsZombie = false;
			StartZombie = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_weapons_t", 0);
			SetCvar("sm_weapons_ct", 1);
			SetCvarString("sv_skyname", g_sSkyName);
			SetCvar("sv_infinite_ammo", 0);
			SetCvar("sm_warden_enable", 1);
			SetCvar("sm_menu_enable", 1);
			g_iGetRoundTime.IntValue = g_iOldRoundTime;
			SetEventDay("none");
			SetEventDayRunning(false);
			FogOff();
			CPrintToChatAll("%t %t", "zombie_tag" , "zombie_end");
		}
	}
	if (StartZombie)
	{
		LoopClients(i) CreateInfoPanel(i);
		
		CPrintToChatAll("%t %t", "zombie_tag" , "zombie_next");
		PrintHintTextToAll("%t", "zombie_next_nc");
	}
}

//Map End

public void OnMapEnd()
{
	IsZombie = false;
	StartZombie = false;
	delete FreezeTimer;
	delete GlowTimer;
	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
}

//glow

public Action Glow_Timer(Handle timer, any client)
{
	if(IsValidClient(client, false, false))
	{
		char model[PLATFORM_MAX_PATH]; 
		GetClientModel(client, model, sizeof(model)); 
		int skin = CPS_SetSkin(client, model, CPS_RENDER); 
		SetEntProp(skin, Prop_Send, "m_bShouldGlow", true, true);
		SetEntProp(skin, Prop_Send, "m_nGlowStyle", 1);
		SetEntPropFloat(skin, Prop_Send, "m_flGlowMaxDist", 10000000.0);
	}
}

//Start Timer

public Action StartTimer(Handle timer)
{
	if (g_iFreezeTime > 1)
	{
		g_iFreezeTime--;
		LoopClients(client) if (IsPlayerAlive(client))
		{
			if (GetClientTeam(client) == CS_TEAM_CT)
			{
				PrintHintText(client,"%t", "zombie_timetounfreeze_nc", g_iFreezeTime);
			}
			else if (GetClientTeam(client) == CS_TEAM_T)
			{
				PrintHintText(client,"%t", "zombie_timeuntilzombie_nc", g_iFreezeTime);
			}
		}
		return Plugin_Continue;
	}
	
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	
	if (g_iRound > 0)
	{
		LoopClients(client) if (IsPlayerAlive(client))
		{
			if (GetClientTeam(client) == CS_TEAM_CT)
			{
				SetEntityMoveType(client, MOVETYPE_WALK);
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.4);
				if (gc_bVision.BoolValue) SetEntProp(client, Prop_Send, "m_bNightVisionOn",1); 
			}
			SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
			PrintHintText(client,"%t", "zombie_start_nc");
			if(gc_bOverlays.BoolValue) CreateTimer( 0.0, ShowOverlayStart, client);
			if(gc_bSounds.BoolValue)
			{
				EmitSoundToAllAny(g_sSoundStartPath);
			}
		}
		CPrintToChatAll("%t %t", "zombie_tag" , "zombie_start");
	}
	FreezeTimer = null;
	if(gc_bDark.BoolValue && (g_iRound = 1)) FogOn();
	
	return Plugin_Stop;
}

//Knife only for Zombies

public Action OnWeaponCanUse(int client, int weapon)
{
	char sWeapon[32];
	GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));
	
	if(!StrEqual(sWeapon, "weapon_knife"))
		{
			if(GetClientTeam(client) == CS_TEAM_CT )
			{
				if (IsClientInGame(client) && IsPlayerAlive(client))
				{
					if(IsZombie == true)
					{
						return Plugin_Handled;
					}
				}
			}
		}
	return Plugin_Continue;
}