//includes
#include <cstrike>
#include <sourcemod>
#include <colors>

#include <wardn>
#include <emitsoundany>
#include <smartjaildoors>
#include <autoexecconfig>
#include <myjailbreak>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//Booleans
bool IsHide; 
bool StartHide; 

//ConVars
ConVar gc_bPlugin;
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_bVote;
ConVar gc_bOverlays;
ConVar gc_bFreezeHider;
ConVar gc_iRoundTime;
ConVar gc_iCooldownDay;
ConVar gc_iCooldownStart;
ConVar gc_iFreezeTime;
ConVar g_iGetRoundTime;
ConVar gc_sOverlayStartPath;
ConVar gc_bSounds;
ConVar gc_sSoundStartPath;
ConVar gc_iRounds;

//Integers
int g_iOldRoundTime;
int g_iFreezeTime;
int g_iCoolDown;
int g_iVoteCount;
int g_iRound;
int FogIndex = -1;
int g_iMaxRound;

//Handles
Handle FreezeTimer;
Handle HideMenu;

//Strings
char g_sHasVoted[1500];
char g_sSoundStartPath[256];

//Float
float mapFogStart = 0.0;
float mapFogEnd = 150.0;
float mapFogDensity = 0.99;

public Plugin myinfo = {
	name = "MyJailbreak - HideInTheDark",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = PLUGIN_VERSION,
	url = URL_LINK
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.Hide.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_sethide", SetHide, "Allows the Admin or Warden to set hide as next round");
	RegConsoleCmd("sm_hide", VoteHide, "Allows players to vote for a hide");
	
	//AutoExecConfig
	AutoExecConfig_SetFile("MyJailbreak.Hide");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_hide_version", PLUGIN_VERSION, "The version of this MyJailBreak SourceMod plugin", FCVAR_SPONLY|FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_hide_enable", "1", "0 - disabled, 1 - enable this MyJailBreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_bSetW = AutoExecConfig_CreateConVar("sm_hide_warden", "1", "0 - disabled, 1 - allow warden to set hide round", _, true,  0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_hide_admin", "1", "0 - disabled, 1 - allow admin to set hide round", _, true,  0.0, true, 1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_hide_vote", "1", "0 - disabled, 1 - allow player to vote for hide round", _, true,  0.0, true, 1.0);
	gc_bFreezeHider = AutoExecConfig_CreateConVar("sm_hide_freezehider", "1", "0 - disabled, 1 - enable freeze hider when hidetime gone", _, true,  0.0, true, 1.0);
	gc_iRounds = AutoExecConfig_CreateConVar("sm_hide_rounds", "1", "Rounds to play in a row", _, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_hide_roundtime", "5", "Round time in minutes for a single war round", _, true, 1.0);
	gc_iFreezeTime = AutoExecConfig_CreateConVar("sm_hide_hidetime", "30", "Time in seconds to hide / CT freezed", _, true,  0.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_hide_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true,  0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_hide_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true,  0.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_hide_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true,  0.0, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_hide_sounds_start", "music/myjailbreak/start.mp3", "Path to the soundfile which should be played for start");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_hide_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true,  0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_hide_overlays_start", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("round_end", RoundEnd);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	
	//FindConVar
	g_iGetRoundTime = FindConVar("mp_roundtime");
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
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
	IsHide = false;
	StartHide = false;
	
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	
	if(gc_bOverlays.BoolValue) PrecacheOverlayAnyDownload(g_sOverlayStart);
	if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStartPath);
	
	int ent; 
	ent = FindEntityByClassname(-1, "env_fog_controller");
	if (ent != -1) 
	{
		FogIndex = ent;
	}
	else
	{
		FogIndex += CreateEntityByName("env_fog_controller");
		DispatchSpawn(FogIndex);
	}
	DoFog();
	AcceptEntityInput(FogIndex, "TurnOff");
}

public void OnConfigsExecuted()
{
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iMaxRound = gc_iRounds.IntValue;
}

public Action SetHide(int client,int args)
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
						else CPrintToChat(client, "%t %t", "hide_tag" , "hide_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "hide_tag" , "hide_progress" , EventDay);
				}
				else CPrintToChat(client, "%t %t", "hide_tag" , "hide_setbywarden");
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
							else CPrintToChat(client, "%t %t", "hide_tag" , "hide_wait", g_iCoolDown);
						}
						else CPrintToChat(client, "%t %t", "hide_tag" , "hide_progress" , EventDay);
					}
					else CPrintToChat(client, "%t %t", "hide_tag" , "hide_setbyadmin");
				}
				else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
		}
		else CPrintToChat(client, "%t %t", "hide_tag" , "hide_disabled");
}

public Action VoteHide(int client,int args)
{
	char steamid[64];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bVote.BoolValue)
		{
			if (GetTeamClientCount(CS_TEAM_CT) > 0)
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
							}
							else CPrintToChatAll("%t %t", "hide_tag" , "hide_need", Missing, client);
						}
						else CPrintToChat(client, "%t %t", "hide_tag" , "hide_voted");
					}
					else CPrintToChat(client, "%t %t", "hide_tag" , "hide_wait", g_iCoolDown);
				}
				else CPrintToChat(client, "%t %t", "hide_tag" , "hide_progress" , EventDay);
			}
			else CPrintToChat(client, "%t %t", "hide_tag" , "hide_minct");
		}
		else CPrintToChat(client, "%t %t", "hide_tag" , "hide_voting");
	}
	else CPrintToChat(client, "%t %t", "hide_tag" , "hide_disabled");
}

void StartNextRound()
{
	StartHide = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	
	SetEventDay("hide");
	
	g_iVoteCount = 0;
	CPrintToChatAll("%t %t", "hide_tag" , "hide_next");
	PrintHintTextToAll("%t", "hide_next_nc");
}

public void RoundStart(Handle event, char[] name, bool dontBroadcast)
{
	if (StartHide || IsHide)
	{
		char info1[255], info2[255], info3[255], info4[255], info5[255], info6[255], info7[255], info8[255];
		
		
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_weapons_t", 0);
		SetCvar("sm_weapons_ct", 0);
		SetCvar("sm_menu_enable", 0);
		IsHide = true;
		g_iRound++;
		StartHide = false;
		SJD_OpenDoors();
		
		HideMenu = CreatePanel();
		Format(info1, sizeof(info1), "%T", "hide_info_title", LANG_SERVER);
		SetPanelTitle(HideMenu, info1);
		DrawPanelText(HideMenu, "                                   ");
		Format(info2, sizeof(info2), "%T", "hide_info_line1", LANG_SERVER);
		DrawPanelText(HideMenu, info2);
		DrawPanelText(HideMenu, "-----------------------------------");
		Format(info3, sizeof(info3), "%T", "hide_info_line2", LANG_SERVER);
		DrawPanelText(HideMenu, info3);
		Format(info4, sizeof(info4), "%T", "hide_info_line3", LANG_SERVER);
		DrawPanelText(HideMenu, info4);
		Format(info5, sizeof(info5), "%T", "hide_info_line4", LANG_SERVER);
		DrawPanelText(HideMenu, info5);
		Format(info6, sizeof(info6), "%T", "hide_info_line5", LANG_SERVER);
		DrawPanelText(HideMenu, info6);
		Format(info7, sizeof(info7), "%T", "hide_info_line6", LANG_SERVER);
		DrawPanelText(HideMenu, info7);
		Format(info8, sizeof(info8), "%T", "hide_info_line7", LANG_SERVER);
		DrawPanelText(HideMenu, info8);
		DrawPanelText(HideMenu, "-----------------------------------");
		
		if (g_iRound > 0)
			{
				for(int client=1; client <= MaxClients; client++)
				{
					if (IsClientInGame(client))
					{
						
						if (GetClientTeam(client) == CS_TEAM_CT)
						{
							StripAllWeapons(client);
							SetEntityMoveType(client, MOVETYPE_NONE);
							GivePlayerItem(client, "weapon_tagrenade");
							GivePlayerItem(client, "weapon_tagrenade");
							SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
							GivePlayerItem(client, "weapon_knife");
						}
						if (GetClientTeam(client) == CS_TEAM_T)
						{
							StripAllWeapons(client);
							SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
							SendPanelToClient(HideMenu, client, NullHandler, 15);
							GivePlayerItem(client, "weapon_knife");
						}
						
					}
				}
				g_iFreezeTime--;
				FreezeTimer = CreateTimer(1.0, Freezed, _, TIMER_REPEAT);
			}
		{AcceptEntityInput(FogIndex, "TurnOn");}
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

public Action Freezed(Handle timer)
{
	if (g_iFreezeTime > 1)
	{
		g_iFreezeTime--;
		for (int client=1; client <= MaxClients; client++)
		if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				if (GetClientTeam(client) == CS_TEAM_CT)
				{
					PrintCenterText(client,"%t", "hide_timetounfreeze_nc", g_iFreezeTime);
				}
				if (GetClientTeam(client) == CS_TEAM_T)
				{
				PrintCenterText(client,"%t", "hide_timetohide_nc", g_iFreezeTime);
				}
			}
		return Plugin_Continue;
	}
	
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	
	if (g_iRound > 0)
	{
		for (int client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				if (GetClientTeam(client) == CS_TEAM_CT)
				{
					SetEntityMoveType(client, MOVETYPE_WALK);
					SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.4);
				}
				if (GetClientTeam(client) == CS_TEAM_T)
				{
					if (gc_bFreezeHider)
					{
						SetEntityMoveType(client, MOVETYPE_NONE);
					}
					else
					{
						SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.9);
					}
				}
				if(gc_bSounds.BoolValue)	
				{
					EmitSoundToAllAny(g_sSoundStartPath);
				}
			}
			if(gc_bOverlays.BoolValue) CreateTimer( 0.0, ShowOverlayStart, client);
		}
	}
	PrintHintTextToAll("%t", "hide_start_nc");
	CPrintToChatAll("%t %t", "hide_tag" , "hide_start");
	FreezeTimer = null;
	return Plugin_Stop;
}

public Action OnWeaponCanUse(int client, int weapon)
{
	if(IsHide == true)
	{
		char sWeapon[32];
		GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));
		if((GetClientTeam(client) == CS_TEAM_T && StrEqual(sWeapon, "weapon_knife")) || (GetClientTeam(client) == CS_TEAM_CT))
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

public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason)
{
	if (IsHide)
	{
		if (reason == CSRoundEnd_Draw)
		{
			reason = CSRoundEnd_TerroristWin;
			return Plugin_Changed;
		}
		return Plugin_Continue;
	}
	return Plugin_Continue;
}

public void RoundEnd(Handle event, char[] name, bool dontBroadcast)
{
	
	int winner = GetEventInt(event, "winner");
	
	if (IsHide)
	{
		for(int client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client)) 
			{
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
			}
		}
		
		if (FreezeTimer != null) KillTimer(FreezeTimer);
		
		if (winner == 2) PrintHintTextToAll("%t", "hide_twin_nc");
		if (winner == 3) PrintHintTextToAll("%t", "hide_ctwin_nc");
		if (g_iRound == g_iMaxRound)
		{
			IsHide = false;
			StartHide = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_weapons_t", 0);
			SetCvar("sm_weapons_ct", 1);
			SetCvar("sm_warden_enable", 1);
			SetCvar("sm_menu_enable", 1);
			g_iGetRoundTime.IntValue = g_iOldRoundTime;
			SetEventDay("none");
			CPrintToChatAll("%t %t", "hide_tag" , "hide_end");
			DoFog();
			AcceptEntityInput(FogIndex, "TurnOff");
		}
	}
	if (StartHide)
	{
		g_iOldRoundTime = g_iGetRoundTime.IntValue;
		g_iGetRoundTime.IntValue = gc_iRoundTime.IntValue;
	}
}

public Action DoFog()
{
	if(FogIndex != -1)
	{
		DispatchKeyValue(FogIndex, "fogblend", "0");
		DispatchKeyValue(FogIndex, "fogcolor", "0 0 0");
		DispatchKeyValue(FogIndex, "fogcolor2", "0 0 0");
		DispatchKeyValueFloat(FogIndex, "fogstart", mapFogStart);
		DispatchKeyValueFloat(FogIndex, "fogend", mapFogEnd);
		DispatchKeyValueFloat(FogIndex, "fogmaxdensity", mapFogDensity);
	}
}

public void OnMapEnd()
{
	IsHide = false;
	StartHide = false;
	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
	SetEventDay("none");
}