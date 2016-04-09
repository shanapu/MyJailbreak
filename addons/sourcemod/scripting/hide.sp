//includes
#include <cstrike>
#include <sourcemod>
#include <colors>
#include <sdktools>
#include <wardn>
#include <smartjaildoors>
#include <autoexecconfig>
#include <myjailbreak>

//Compiler Options
#pragma semicolon 1

//Defines
#define PLUGIN_VERSION "0.2"

//Booleans
bool IsHide = false; 
bool StartHide = false; 

//ConVars
ConVar gc_bPlugin;
ConVar gc_bTag;
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_bVote;
ConVar gc_bOverlays;
ConVar gc_bFreezeHider;
ConVar gc_iRoundTime;
ConVar gc_iCooldownDay;
ConVar gc_iCooldownStart;
ConVar gc_iFreezeTime;
ConVar g_iSetRoundTime;
ConVar gc_sOverlayStartPath;

//Integers
int g_iOldRoundTime;
int g_iFreezeTime;
int g_iCoolDown;
int g_iVoteCount = 0;
int HideRound = 0;
int FogIndex = -1;

//Handles
Handle FreezeTimer;
Handle HideMenu;

//Strings
char g_sHasVoted[1500];

//Float
float mapFogStart = 0.0;
float mapFogEnd = 150.0;
float mapFogDensity = 0.99;

public Plugin myinfo = {
	name = "MyJailbreak - HideInTheDark",
	author = "shanapu & Floody.de, Franc1sco",
	description = "Jailbreak Hide script",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreakWarden.phrases");
	LoadTranslations("MyJailbreakHide.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_sethide", SetHide);
	RegConsoleCmd("sm_hide", VoteHide);
	RegConsoleCmd("sm_hideindark", VoteHide);
	
	//AutoExecConfig
	AutoExecConfig_SetFile("MyJailbreak_hide");
	AutoExecConfig_SetCreateFile(true);
	AutoExecConfig_CreateConVar("sm_hide_version", PLUGIN_VERSION, "The version of the SourceMod plugin MyJailBreak - War", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_hide_enable", "1", "0 - disabled, 1 - enable war");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_hide_warden", "1", "0 - disabled, 1 - allow warden to set hide round", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_hide_admin", "1", "0 - disabled, 1 - allow admin to set hide round", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_hide_vote", "1", "0 - disabled, 1 - allow player to vote for hide round", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bFreezeHider = AutoExecConfig_CreateConVar("sm_hide_freezehider", "1", "0 - disabled, 1 - enable freeze hider when hidetime gone");
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_hide_roundtime", "5", "Round time for a single war round");
	gc_iFreezeTime = AutoExecConfig_CreateConVar("sm_hide_hidetime", "30", "Hide freeze T");
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_hide_cooldown_day", "3", "Rounds cooldown after a event until this event can startet");
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_hide_cooldown_start", "3", "Rounds until event can be started after mapchange.", FCVAR_NOTIFY, true, 0.0, true, 255.0);
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_hide_overlays", "1", "0 - disabled, 1 - enable overlays", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_hide_overlaystart_path", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_bTag = AutoExecConfig_CreateConVar("sm_hide_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("round_end", RoundEnd);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	
	//FindConVar
	g_iSetRoundTime = FindConVar("mp_roundtime");
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	gc_sOverlayStartPath.GetString(g_sOverlayStart , sizeof(g_sOverlayStart));
	
	IsHide = false;
	StartHide = false;
	g_iVoteCount = 0;
	HideRound = 0;
}

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sOverlayStartPath)
	{
		strcopy(g_sOverlayStart, sizeof(g_sOverlayStart), newValue);
		if(gc_bOverlays.BoolValue) PrecacheOverlayAnyDownload(g_sOverlayStart);
	}
}

public void OnMapStart()
{
	if(gc_bOverlays.BoolValue) PrecacheOverlayAnyDownload(g_sOverlayStart);
	g_iVoteCount = 0;
	HideRound = 0;
	IsHide = false;
	StartHide = false;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	
	int ent; 
	ent = FindEntityByClassname(-1, "env_fog_controller");
	if (ent != -1) 
	{
		FogIndex = ent;
	}
	else
	{
		FogIndex = CreateEntityByName("env_fog_controller");
		DispatchSpawn(FogIndex);
	}
	DoFog();
	AcceptEntityInput(FogIndex, "TurnOff");
}

public void OnConfigsExecuted()
{
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	
	if (gc_bTag.BoolValue)
	{
		ConVar hTags = FindConVar("sv_tags");
		char sTags[128];
		hTags.GetString(sTags, sizeof(sTags));
		if (StrContains(sTags, "MyJailbreak", false) == -1)
		{
			StrCat(sTags, sizeof(sTags), ", MyJailbreak");
			hTags.SetString(sTags);
		}
	}
}

public Action SetHide(int client,int args)
{
	if (gc_bPlugin.BoolValue)	
		{
			if (warden_iswarden(client))
			{
				if (gc_bSetW.BoolValue)	
				{
					decl String:EventDay[64];
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
						decl String:EventDay[64];
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
				decl String:EventDay[64];
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

public void RoundStart(Handle:event, char[] name, bool:dontBroadcast)
{
	if (StartHide)
	{
		char info1[255], info2[255], info3[255], info4[255], info5[255], info6[255], info7[255], info8[255];
		
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_weapons_t", 0);
		SetCvar("sm_weapons_ct", 1);
		IsHide = true;
		HideRound++;
		StartHide = false;
		SJD_OpenDoors();
		ServerCommand("sm_removewarden");
		HideMenu = CreatePanel();
		Format(info1, sizeof(info1), "%T", "hide_info_Title", LANG_SERVER);
		SetPanelTitle(HideMenu, info1);
		DrawPanelText(HideMenu, "                                   ");
		Format(info2, sizeof(info2), "%T", "hide_info_Line1", LANG_SERVER);
		DrawPanelText(HideMenu, info2);
		DrawPanelText(HideMenu, "-----------------------------------");
		Format(info3, sizeof(info3), "%T", "hide_info_Line2", LANG_SERVER);
		DrawPanelText(HideMenu, info3);
		Format(info4, sizeof(info4), "%T", "hide_info_Line3", LANG_SERVER);
		DrawPanelText(HideMenu, info4);
		Format(info5, sizeof(info5), "%T", "hide_info_Line4", LANG_SERVER);
		DrawPanelText(HideMenu, info5);
		Format(info6, sizeof(info6), "%T", "hide_info_Line5", LANG_SERVER);
		DrawPanelText(HideMenu, info6);
		Format(info7, sizeof(info7), "%T", "hide_info_Line6", LANG_SERVER);
		DrawPanelText(HideMenu, info7);
		Format(info8, sizeof(info8), "%T", "hide_info_Line7", LANG_SERVER);
		DrawPanelText(HideMenu, info8);
		DrawPanelText(HideMenu, "-----------------------------------");
		
		if (HideRound > 0)
			{
				for(int client=1; client <= MaxClients; client++)
				{
					if (IsClientInGame(client))
					{
						StripAllWeapons(client);
						if (GetClientTeam(client) == CS_TEAM_CT)
						{
							SetEntityMoveType(client, MOVETYPE_NONE);
							GivePlayerItem(client, "weapon_tagrenade");
							SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
						}
						if (GetClientTeam(client) == CS_TEAM_T)
						{
							SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
							SendPanelToClient(HideMenu, client, Pass, 15);
							
						}
						GivePlayerItem(client, "weapon_knife");
					}
				}
				g_iFreezeTime--;
				FreezeTimer = CreateTimer(1.0, Freezed, _, TIMER_REPEAT);
			}
		{AcceptEntityInput(FogIndex, "TurnOn");}
	}
	else
	{
		decl String:EventDay[64];
		GetEventDay(EventDay);
		
		if(!StrEqual(EventDay, "none", false))
		{
			g_iCoolDown = gc_iCooldownDay.IntValue + 1;
		}
		else if (g_iCoolDown > 0) g_iCoolDown--;
	}
}

public Action:Freezed(Handle:timer)
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
	
	if (HideRound > 0)
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
						SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.5);
					}
				}
			}
			CreateTimer( 0.0, ShowOverlayStart, client);
		}
	}
	PrintHintTextToAll("%t", "hide_start_nc");
	CPrintToChatAll("%t %t", "hide_tag" , "hide_start");
	FreezeTimer = null;
	return Plugin_Stop;
}

public Action:OnWeaponCanUse(client, weapon)
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

public Action:CS_OnTerminateRound(&Float:delay, &CSRoundEndReason:reason)
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

public void RoundEnd(Handle:event, char[] name, bool:dontBroadcast)
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
		IsHide = false;
		StartHide = false;
		HideRound = 0;
		Format(g_sHasVoted, sizeof(g_sHasVoted), "");
		SetCvar("sm_hosties_lr", 1);
		SetCvar("sm_weapons_t", 0);
		SetCvar("sm_weapons_ct", 1);
		SetCvar("sm_warden_enable", 1);
		SetEventDay("none");
		
		g_iSetRoundTime.IntValue = g_iOldRoundTime;
		CPrintToChatAll("%t %t", "hide_tag" , "hide_end");
		DoFog();
		AcceptEntityInput(FogIndex, "TurnOff");
	}
	if (StartHide)
	{
		g_iOldRoundTime = g_iSetRoundTime.IntValue;
		g_iSetRoundTime.IntValue = gc_iRoundTime.IntValue;
	}
}

DoFog()
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
	HideRound = 0;
	g_sHasVoted[0] = '\0';
}