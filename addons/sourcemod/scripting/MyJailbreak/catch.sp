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
bool IsCatch;
bool StartCatch;
bool catched[MAXPLAYERS+1];

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
ConVar gc_sOverlayFreeze;
ConVar gc_bSprintUse;
ConVar gc_iSprintCooldown;
ConVar gc_bSprint;
ConVar gc_fSprintSpeed;
ConVar gc_fSprintTime;
ConVar gc_sSoundFreezePath;
ConVar gc_sSoundUnFreezePath;
ConVar g_iGetRoundTime;
ConVar gc_iRounds;
ConVar g_bNoBloodSplatter;
ConVar g_bNoBloodSplash;
ConVar g_bNoBlood;

//Integers
int g_iVoteCount;
int g_iOldRoundTime;
int g_iCoolDown;
int g_iRound;
int ClientSprintStatus[MAXPLAYERS+1];
int g_iMaxRound;

//Handles
Handle SprintTimer[MAXPLAYERS+1];
Handle CatchMenu;

//Strings
char g_sSoundUnFreezePath[256];
char g_sSoundFreezePath[256];
char g_sHasVoted[1500];
char g_sOverlayFreeze[256];

public Plugin myinfo = {
	name = "MyJailbreak - Catch & Freeze",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = PLUGIN_VERSION,
	url = URL_LINK
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.Catch.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_setcatch", SetCatch, "Allows the Admin or Warden to set catch as next round");
	RegConsoleCmd("sm_catch", VoteCatch, "Allows players to vote for a catch ");
	RegConsoleCmd("sm_sprint", Command_StartSprint, "Start sprinting!");
	
	//AutoExecConfig
	AutoExecConfig_SetFile("Catch", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_catch_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_catch_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true, 0.0, true, 1.0);
	gc_bSetW = AutoExecConfig_CreateConVar("sm_catch_warden", "1", "0 - disabled, 1 - allow warden to set catch round", _, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_catch_admin", "1", "0 - disabled, 1 - allow admin to set catch round", _, true, 0.0, true, 1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_catch_vote", "1", "0 - disabled, 1 - allow player to vote for catch", _, true, 0.0, true, 1.0);
	gc_iRounds = AutoExecConfig_CreateConVar("sm_catch_rounds", "1", "Rounds to play in a row", _, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_catch_roundtime", "5", "Round time in minutes for a single catch round", _, true, 1.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_catch_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true, 0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_catch_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true, 0.0);
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_catch_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true, 0.0, true, 1.0);
	gc_sOverlayFreeze = AutoExecConfig_CreateConVar("sm_catch_overlayfreeze_path", "overlays/MyJailbreak/freeze" , "Path to the Freeze Overlay DONT TYPE .vmt or .vft");
	gc_bStayOverlay = AutoExecConfig_CreateConVar("sm_catch_stayoverlay", "1", "0 - overlays will removed after 3sec. , 1 - overlays will stay until unfreeze", _, true, 0.0, true, 1.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_catch_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true, 0.0, true, 1.0);
	gc_sSoundFreezePath = AutoExecConfig_CreateConVar("sm_catch_sounds_freeze", "music/myjailbreak/freeze.mp3", "Path to the soundfile which should be played on freeze.");
	gc_sSoundUnFreezePath = AutoExecConfig_CreateConVar("sm_catch_sounds_unfreeze", "music/myjailbreak/unfreeze.mp3", "Path to the soundfile which should be played on unfreeze.");
	gc_bSprint = AutoExecConfig_CreateConVar("sm_catch_sprint_enable", "1", "0 - disabled, 1 - enable ShortSprint", _, true, 0.0, true, 1.0);
	gc_bSprintUse = AutoExecConfig_CreateConVar("sm_catch_sprint_button", "1", "0 - disabled, 1 - enable +use button for sprint", _, true, 0.0, true, 1.0);
	gc_iSprintCooldown= AutoExecConfig_CreateConVar("sm_catch_sprint_cooldown", "10", "Time in seconds the player must wait for the next sprint", _, true, 0.0);
	gc_fSprintSpeed = AutoExecConfig_CreateConVar("sm_catch_sprint_speed", "1.25", "Ratio for how fast the player will sprint", _, true, 1.01);
	gc_fSprintTime = AutoExecConfig_CreateConVar("sm_catch_sprint_time", "3.0", "Time in seconds the player will sprint", _, true, 1.0);
	g_bNoBlood = CreateConVar("sm_catch_noblood", "1", "Enable / Disable No Blood", _, true, 0.0, true, 1.0);
	g_bNoBloodSplatter = CreateConVar("sm_catch_noblood_splatter", "1", "Enable / Disable No Blood Splatter", _, true, 0.0, true, 1.0);
	g_bNoBloodSplash = CreateConVar("sm_catch_noblood_splash", "1", "Enable / Disable No Blood Splash", _, true, 0.0, true, 1.0);

	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("round_end", RoundEnd);
	HookEvent("player_team", EventPlayerTeam);
	HookEvent("player_death", EventPlayerTeam);
	AddTempEntHook("EffectDispatch", TE_OnEffectDispatch);
	AddTempEntHook("World Decal", TE_OnWorldDecal);
	HookConVarChange(gc_sOverlayFreeze, OnSettingChanged);
	HookConVarChange(gc_sSoundFreezePath, OnSettingChanged);
	HookConVarChange(gc_sSoundUnFreezePath, OnSettingChanged);
	
	//FindConVar
	g_iMaxRound = gc_iRounds.IntValue;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iGetRoundTime = FindConVar("mp_roundtime");
	gc_sSoundFreezePath.GetString(g_sSoundFreezePath, sizeof(g_sSoundFreezePath));
	gc_sSoundUnFreezePath.GetString(g_sSoundUnFreezePath, sizeof(g_sSoundUnFreezePath));
	gc_sOverlayFreeze.GetString(g_sOverlayFreeze , sizeof(g_sOverlayFreeze));
	
	for(int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i)) OnClientPutInServer(i);
}

//ConVar Change for Strings

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sSoundFreezePath)
	{
		strcopy(g_sSoundFreezePath, sizeof(g_sSoundFreezePath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundFreezePath);
	}
	else if(convar == gc_sSoundUnFreezePath)
	{
		strcopy(g_sSoundUnFreezePath, sizeof(g_sSoundUnFreezePath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundUnFreezePath);
	}
	else if(convar == gc_sOverlayFreeze)
	{
		strcopy(g_sOverlayFreeze, sizeof(g_sOverlayFreeze), newValue);
		if(gc_bOverlays.BoolValue) PrecacheOverlayAnyDownload(g_sOverlayFreeze);
	}
}

//Initialize Event

public void OnMapStart()
{
	g_iVoteCount = 0;
	g_iRound = 0;
	IsCatch = false;
	StartCatch = false;
	
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	
	if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundFreezePath);
	if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundUnFreezePath);
	if(gc_bOverlays.BoolValue) PrecacheOverlayAnyDownload(g_sOverlayFreeze);
	PrecacheSound("player/suit_sprint.wav", true);
}

public void OnConfigsExecuted()
{
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iMaxRound = gc_iRounds.IntValue;
}

public void OnClientPutInServer(int client)
{
	catched[client] = false;
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakedamage);
}

//Admin & Warden set Event

public Action SetCatch(int client,int args)
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
							LogMessage("Event Catch was started by Warden %L", client);
						}
						else CPrintToChat(client, "%t %t", "catch_tag" , "catch_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "catch_tag" , "catch_progress" , EventDay);
				}
				else CPrintToChat(client, "%t %t", "catch_tag" , "catch_minplayer");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "catch_setbywarden");
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
								LogMessage("Event Catch was started by Admin %L", client);
							}
							else CPrintToChat(client, "%t %t", "catch_tag" , "catch_wait", g_iCoolDown);
						}
						else CPrintToChat(client, "%t %t", "catch_tag" , "catch_progress" , EventDay);
					}
					else CPrintToChat(client, "%t %t", "catch_tag" , "catch_minplayer");
				}
				else CPrintToChat(client, "%t %t", "catch_tag" , "catch_setbyadmin");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "catch_tag" , "catch_disabled");
}

//Voting for Event

public Action VoteCatch(int client,int args)
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
								LogMessage("Event Catch was started by voting");
							}
							else CPrintToChatAll("%t %t", "catch_tag" , "catch_need", Missing, client);
						}
						else CPrintToChat(client, "%t %t", "catch_tag" , "catch_voted");
					}
					else CPrintToChat(client, "%t %t", "catch_tag" , "catch_wait", g_iCoolDown);
				}
				else CPrintToChat(client, "%t %t", "catch_tag" , "catch_progress" , EventDay);
			}
			else CPrintToChat(client, "%t %t", "catch_tag" , "catch_minplayer");
		}
		else CPrintToChat(client, "%t %t", "catch_tag" , "catch_voting");
	}
	else CPrintToChat(client, "%t %t", "catch_tag" , "catch_disabled");
}

//Prepare Event

void StartNextRound()
{
	StartCatch = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;
	
	SetEventDay("catch");
	
	CPrintToChatAll("%t %t", "catch_tag" , "catch_next");
	PrintHintTextToAll("%t", "catch_next_nc");
}

//Round start

public void RoundStart(Handle event, char[] name, bool dontBroadcast)
{

	if (StartCatch || IsCatch)
	{
		char info1[255], info2[255], info3[255], info4[255], info5[255], info6[255], info7[255], info8[255];
		
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_weapons_enable", 0);
		
		IsCatch = true;
		g_iRound++;
		StartCatch = false;
		SJD_OpenDoors();

		CatchMenu = CreatePanel();
		Format(info1, sizeof(info1), "%T", "catch_info_title", LANG_SERVER);
		SetPanelTitle(CatchMenu, info1);
		DrawPanelText(CatchMenu, "                                   ");
		Format(info2, sizeof(info2), "%T", "catch_info_line1", LANG_SERVER);
		DrawPanelText(CatchMenu, info2);
		DrawPanelText(CatchMenu, "-----------------------------------");
		Format(info3, sizeof(info3), "%T", "catch_info_line2", LANG_SERVER);
		DrawPanelText(CatchMenu, info3);
		Format(info4, sizeof(info4), "%T", "catch_info_line3", LANG_SERVER);
		DrawPanelText(CatchMenu, info4);
		Format(info5, sizeof(info5), "%T", "catch_info_line4", LANG_SERVER);
		DrawPanelText(CatchMenu, info5);
		Format(info6, sizeof(info6), "%T", "catch_info_line5", LANG_SERVER);
		DrawPanelText(CatchMenu, info6);
		Format(info7, sizeof(info7), "%T", "catch_info_line6", LANG_SERVER);
		DrawPanelText(CatchMenu, info7);
		Format(info8, sizeof(info8), "%T", "catch_info_line7", LANG_SERVER);
		DrawPanelText(CatchMenu, info8);
		DrawPanelText(CatchMenu, "-----------------------------------");
		
		if (g_iRound > 0)
			{
				for(int client=1; client <= MaxClients; client++)
				{
					if (IsClientInGame(client))
					{
						if (GetClientTeam(client) == CS_TEAM_T)
						{
							catched[client] = false;
						}
						StripAllWeapons(client);
						ClientSprintStatus[client] = 0;
						GivePlayerItem(client, "weapon_knife");
						SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
						SendPanelToClient(CatchMenu, client, NullHandler, 20);
						PrintHintText(client,"%t", "catch_start_nc");
					}
				}
				CPrintToChatAll("%t %t", "catch_tag" ,"catch_rounds", g_iRound, g_iMaxRound);
				CPrintToChatAll("%t %t", "catch_tag" , "catch_start");
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

//Round End

public void RoundEnd(Handle event, char[] name, bool dontBroadcast)
{
	int winner = GetEventInt(event, "winner");
	
	if (IsCatch)
	{
		for(int client=1; client <= MaxClients; client++)
		{
			if(IsValidClient(client, true, true))
			{
				SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
				ClientSprintStatus[client] = 0;
				CreateTimer( 0.0, DeleteOverlay, client );
				SetEntityRenderColor(client, 255, 255, 255, 0);
				catched[client] = false;
				if (GetClientTeam(client) == CS_TEAM_T)
				{
					StripAllWeapons(client);
				}
			}
		}
		
		if (winner == 2) PrintHintTextToAll("%t", "catch_twin_nc");
		if (winner == 3) PrintHintTextToAll("%t", "catch_ctwin_nc");
		if (g_iRound == g_iMaxRound)
		{
			IsCatch = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_weapons_enable", 1);
			SetCvar("sm_warden_enable", 1);
			
			g_iGetRoundTime.IntValue = g_iOldRoundTime;
			SetEventDay("none");
			CPrintToChatAll("%t %t", "catch_tag" , "catch_end");
		}
	}
	if (StartCatch)
	{
		g_iOldRoundTime = g_iGetRoundTime.IntValue;
		g_iGetRoundTime.IntValue = gc_iRoundTime.IntValue;
		
		CPrintToChatAll("%t %t", "catch_tag" , "catch_next");
		PrintHintTextToAll("%t", "catch_next_nc");
	}
}

//Terror win Round if time runs out

public Action CS_OnTerminateRound( float &delay,  CSRoundEndReason &reason)
{
	if (IsCatch)
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

//Map End

public void OnMapEnd()
{
	IsCatch = false;
	StartCatch = false;
	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0';
	SetEventDay("none");
}

//Catch & Freeze

public Action OnTakedamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(!IsValidClient(victim, true, false)|| attacker == victim || !IsValidClient(attacker, true, false)) return Plugin_Continue;
	
	if(IsCatch == false)
	{
		return Plugin_Continue;
	}
	
	if(GetClientTeam(victim) == CS_TEAM_T && GetClientTeam(attacker) == CS_TEAM_CT && !catched[victim])
	{
		CatchEm(victim, attacker);
		CheckStatus();
	}
	if(GetClientTeam(victim) == CS_TEAM_T && GetClientTeam(attacker) == CS_TEAM_T && catched[victim] && !catched[attacker])
	{
		FreeEm(victim, attacker);
	}
	return Plugin_Handled;
}

public void OnClientDisconnect_Post(int client)
{

	if(IsCatch == false)
	{
		return;
	}
	CheckStatus();
}

public Action EventPlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	if(IsCatch == false)
	{
		return;
	}
	CheckStatus();
	
	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	ResetSprint(iClient);
}

public Action CatchEm(int client, int attacker)
{
	SetEntityMoveType(client, MOVETYPE_NONE);
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
	SetEntityRenderColor(client, 0, 0, 205, 255);
	catched[client] = true;
	CreateTimer( 0.0, ShowOverlayFreeze, client );
	if(gc_bSounds.BoolValue)	
	{
	EmitSoundToAllAny(g_sSoundFreezePath);
	}
	if(!gc_bStayOverlay.BoolValue)	
	{
	CreateTimer( 3.0, DeleteOverlay, client );
	}
	CPrintToChatAll("%t %t", "catch_tag" , "catch_catch", attacker, client);
}


public Action FreeEm(int client, int attacker)
{
	SetEntityMoveType(client, MOVETYPE_WALK);
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	SetEntityRenderColor(client, 255, 255, 255, 0);
	catched[client] = false;
	CreateTimer( 0.0, DeleteOverlay, client );
	if(gc_bSounds.BoolValue)	
	{
	EmitSoundToAllAny(g_sSoundUnFreezePath);
	}
	CPrintToChatAll("%t %t", "catch_tag" , "catch_unfreeze", attacker, client);
}

public Action CheckStatus()
{
	int number = 0;
	for (int i = 1; i <= MaxClients; i++)
	if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T && !catched[i]) number++;
	if(number == 0)
	{
		CPrintToChatAll("%t %t", "catch_tag" , "catch_win");
		CS_TerminateRound(5.0, CSRoundEnd_CTWin);
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
				if(IsCatch == true)
				{
					return Plugin_Handled;
				}
			}
		}
	return Plugin_Continue;
}

//Overlays

public Action ShowOverlayFreeze( Handle timer, any client ) {
	
	if(gc_bOverlays.BoolValue && IsValidClient(client, false, true))
	{
	int iFlag = GetCommandFlags( "r_screenoverlay" ) & ( ~FCVAR_CHEAT ); 
	SetCommandFlags( "r_screenoverlay", iFlag ); 
	ClientCommand( client, "r_screenoverlay \"%s.vtf\"", g_sOverlayFreeze);
	}
	return Plugin_Continue;
}

//Sprint

public Action Command_StartSprint(int client, int args)
{
	if (IsCatch)
	{
		{
			if (catched[client] == false)
			{
				if(gc_bSprint.BoolValue && client > 0 && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) > 1 && !(ClientSprintStatus[client] & IsSprintUsing) && !(ClientSprintStatus[client] & IsSprintCoolDown))
				{
					ClientSprintStatus[client] |= IsSprintUsing | IsSprintCoolDown;
					SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", gc_fSprintSpeed.FloatValue);
					EmitSoundToClient(client, "player/suit_sprint.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.8);
					CPrintToChat(client, "%t %t", "catch_tag" ,"catch_sprint");
					SprintTimer[client] = CreateTimer(gc_fSprintTime.FloatValue, Timer_SprintEnd, client);
				}
				return(Plugin_Handled);
			}
		}
	}
	else CPrintToChat(client, "%t %t", "catch_tag" , "catch_disabled");
	return(Plugin_Handled);
}

public void OnGameFrame()
{
	if (IsCatch)
	{
		if(gc_bSprintUse.BoolValue)
		{
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && (GetClientButtons(i) & IN_USE))
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
			CPrintToChat(client, "%t %t", "catch_tag" ,"catch_sprintend", gc_iSprintCooldown.IntValue);
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
		CPrintToChat(client, "%t %t", "catch_tag" ,"catch_sprintagain", gc_iSprintCooldown.IntValue);
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

//No Blood

public Action TE_OnEffectDispatch(const char[] te_name, const Players[], int numClients, float delay)
{
	int iEffectIndex = TE_ReadNum("m_iEffectName");
	int nHitBox = TE_ReadNum("m_nHitBox");
	char sEffectName[64];

	GetEffectName(iEffectIndex, sEffectName, sizeof(sEffectName));
	
	if(g_bNoBlood.BoolValue)
	{
		if(StrEqual(sEffectName, "csblood"))
		{
			if(g_bNoBloodSplatter.BoolValue)
				return Plugin_Handled;
		}
		if(StrEqual(sEffectName, "ParticleEffect"))
		{
			if(g_bNoBloodSplash.BoolValue)
			{
				char sParticleEffectName[64];
				GetParticleEffectName(nHitBox, sParticleEffectName, sizeof(sParticleEffectName));
				
				if(StrEqual(sParticleEffectName, "impact_helmet_headshot") || StrEqual(sParticleEffectName, "impact_physics_dust"))
					return Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
}

public Action TE_OnWorldDecal(const char[] te_name, const Players[], int numClients, float delay)
{
	float vecOrigin[3];
	int nIndex = TE_ReadNum("m_nIndex");
	char sDecalName[64];

	TE_ReadVector("m_vecOrigin", vecOrigin);
	GetDecalName(nIndex, sDecalName, sizeof(sDecalName));
	
	if(g_bNoBlood.BoolValue)
	{
		if(StrContains(sDecalName, "decals/blood") == 0 && StrContains(sDecalName, "_subrect") != -1)
			if(g_bNoBloodSplash.BoolValue)
				return Plugin_Handled;
	}

	return Plugin_Continue;
}

stock int GetParticleEffectName(int index, char[] sEffectName, int maxlen)
{
	int table = INVALID_STRING_TABLE;
	
	if (table == INVALID_STRING_TABLE)
		table = FindStringTable("ParticleEffectNames");
	
	return ReadStringTable(table, index, sEffectName, maxlen);
}

stock int GetEffectName(int index, char[] sEffectName, int maxlen)
{
	int table = INVALID_STRING_TABLE;
	
	if (table == INVALID_STRING_TABLE)
		table = FindStringTable("EffectDispatch");
	
	return ReadStringTable(table, index, sEffectName, maxlen);
}

stock int GetDecalName(int index, char[] sDecalName, int maxlen)
{
	int table = INVALID_STRING_TABLE;
	
	if (table == INVALID_STRING_TABLE)
		table = FindStringTable("decalprecache");
	
	return ReadStringTable(table, index, sDecalName, maxlen);
}
