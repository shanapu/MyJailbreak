//includes
#include <cstrike>
#include <sourcemod>
#include <colors>
#include <sdktools>
#include <wardn>
#include <smartjaildoors>
#include <autoexecconfig>

//Compiler Options
#pragma semicolon 1

#define PLUGIN_VERSION   "0.x"
ConVar gc_bTagEnabled;
new freezetime;
new roundtime;
new roundtimenormal;
new votecount;
new HideRound;
new RoundLimits;

new FogIndex = -1;
new Float:mapFogStart = 0.0;
new Float:mapFogEnd = 150.0;
new Float:mapFogDensity = 0.99;

new Handle:LimitTimer;
new Handle:HideTimer;
new Handle:WeaponTimer;
new Handle:HideMenu;
new Handle:roundtimec;
new Handle:roundtimenormalc;
new Handle:freezetimec;
new Handle:RoundLimitsc;
new Handle:g_wenabled=INVALID_HANDLE;
new Handle:usecvar;

new bool:IsHide;
new bool:StartHide;

new String:voted[1500];


public Plugin myinfo = {
	name = "MyJailbreak - HideInTheDark",
	author = "shanapu & Floody.de, fransico",
	description = "Jailbreak Hide script",
	version = PLUGIN_VERSION,
	url = ""
};



public OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreakWarden.phrases");
	LoadTranslations("MyJailbreakHide.phrases");
	
	RegConsoleCmd("sm_sethide", SetHide);
	
	AutoExecConfig_SetFile("MyJailbreak_hide");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_hide_version", "PLUGIN_VERSION", "The version of the SourceMod plugin MyJailBreak - War", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_wenabled = AutoExecConfig_CreateConVar("sm_hide_enable", "1", "0 - disabled, 1 - enable war");
	roundtimec = AutoExecConfig_CreateConVar("sm_hide_roundtime", "8", "Round time for a single war round");
	roundtimenormalc = AutoExecConfig_CreateConVar("sm_nohide_roundtime", "12", "set round time after a war round zour normal mp_roudntime");
	freezetimec = AutoExecConfig_CreateConVar("sm_hide_freezetime", "30", "Time freeze T");
	RoundLimitsc = AutoExecConfig_CreateConVar("sm_hide_roundsnext", "3", "Rounds until event can be started again.");
	gc_bTagEnabled = AutoExecConfig_CreateConVar("sm_hide_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	
	AutoExecConfig_CacheConvars();
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	AutoExecConfig(true, "MyJailbreak_Hide");
	
	IsHide = false;
	StartHide = false;
	votecount = 0;
	HideRound = 0;
	
	HookEvent("round_start", RoundStart);
	HookEvent("player_say", PlayerSay);
	HookEvent("round_end", RoundEnd);
}


public OnMapStart()
{
	//new String:voted[1500];

	votecount = 0;
	HideRound = 0;
	IsHide = false;
	StartHide = false;
	RoundLimits = 0;
	
	
	freezetime = GetConVarInt(freezetimec);
	roundtime = GetConVarInt(roundtimec);
	roundtimenormal = GetConVarInt(roundtimenormalc);
	
	new ent; 
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

public OnConfigsExecuted()
{
	roundtime = GetConVarInt(roundtimec);
	roundtimenormal = GetConVarInt(roundtimenormalc);
	freezetime = GetConVarInt(freezetimec);
	RoundLimits = 0;
	
	if (gc_bTagEnabled.BoolValue)
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

public RoundEnd(Handle:event, String:name[], bool:dontBroadcast)
{
	new winner = GetEventInt(event, "winner");
	
	if (IsHide)
	{
		for(new client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client)) 
			{
			SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
			}
		}
		
		if (LimitTimer != INVALID_HANDLE) KillTimer(LimitTimer);
		if (HideTimer != INVALID_HANDLE) KillTimer(HideTimer);
		if (WeaponTimer != INVALID_HANDLE) KillTimer(WeaponTimer);
		
		roundtime = GetConVarInt(roundtimec);
		roundtimenormal = GetConVarInt(roundtimenormalc);
		
		if (winner == 2) PrintCenterTextAll("%t", "hide_twin");
		if (winner == 3) PrintCenterTextAll("%t", "hide_ctwin");
		IsHide = false;
		StartHide = false;
		HideRound = 0;
		Format(voted, sizeof(voted), "");
		SetCvar("sm_hosties_lr", 1);
		SetCvar("sm_war_enable", 1);
		SetCvar("sm_zombie_enable", 1);
		SetCvar("sm_ffa_enable", 1);
		SetCvar("sm_noscope_enable", 1);
		SetCvar("sm_duckhunt_enable", 1);
		SetCvar("sm_catch_enable", 1);
		SetCvar("sm_warden_enable", 1);
		SetCvar("dice_enable", 1);
		SetCvar("mp_roundtime", roundtimenormal);
		SetCvar("mp_roundtime_hostage", roundtimenormal);
		SetCvar("mp_roundtime_defuse", roundtimenormal);
		CPrintToChatAll("%t %t", "hide_tag" , "hide_end");
		DoFog();
		AcceptEntityInput(FogIndex, "TurnOff");
		
	}
	if (StartHide)
	{
	SetCvar("mp_roundtime", roundtime);
	SetCvar("mp_roundtime_hostage", roundtime);
	SetCvar("mp_roundtime_defuse", roundtime);
	}
}

public Action SetHide(int client,int args)
{
	if(GetConVarInt(g_wenabled) == 1)	
	{
	if (warden_iswarden(client) || CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
	{
	if (RoundLimits == 0)
	{
	StartHide = true;
	RoundLimits = GetConVarInt(RoundLimitsc);
	votecount = 0;
	CPrintToChatAll("%t %t", "hide_tag" , "hide_next");
	}else CPrintToChat(client, "%t %t", "hide_tag" , "hide_wait", RoundLimits);
	}else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
}

public RoundStart(Handle:event, String:name[], bool:dontBroadcast)
{
	if (StartHide)
	{
		decl String:info1[255], String:info2[255], String:info3[255], String:info4[255], String:info5[255], String:info6[255], String:info7[255], String:info8[255];
		
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("dice_enable", 0);
		IsHide = true;
		HideRound++;
		StartHide = false;
		SJD_OpenDoors();

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
				for(new client=1; client <= MaxClients; client++)
				{
					
					if (IsClientInGame(client))
					{
						if (GetClientTeam(client) == 3)
						{
						SetEntityMoveType(client, MOVETYPE_NONE);
						GivePlayerItem(client, "weapon_tagrenade");
						}
					}
					if (IsClientInGame(client))
					{
					SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					SendPanelToClient(HideMenu, client, Pass, 15);
					SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
					}
				}
				freezetime--;
				HideTimer = CreateTimer(1.0, Hide, _, TIMER_REPEAT);
			}
		{AcceptEntityInput(FogIndex, "TurnOn");}
	}else
	{
		if (RoundLimits > 0) RoundLimits--;
	}
}

public Pass(Handle:menu, MenuAction:action, param1, param2)
{
}


public Action:Hide(Handle:timer)
{
	if (freezetime > 1)
	{
		freezetime--;
		for (new client=1; client <= MaxClients; client++)
		if (IsClientInGame(client) && IsPlayerAlive(client))
			{
		if (GetClientTeam(client) == 3)
						{
						PrintCenterText(client,"%t", "hide_timetounfreeze", freezetime);
						}
		if (GetClientTeam(client) == 2)
						{
						PrintCenterText(client,"%t", "hide_timetohide", freezetime);
						}
		}
		return Plugin_Continue;
	}
	
	freezetime = GetConVarInt(freezetimec);
	
	if (HideRound > 0)
	{
		for (new client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				if (GetClientTeam(client) == 3)
				{
				SetEntityMoveType(client, MOVETYPE_WALK);
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.4);
				}
				if (GetClientTeam(client) == 2)
				{
				SetEntityMoveType(client, MOVETYPE_NONE);
				SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.4);
				}
			}
		}
	}
	PrintCenterTextAll("%t", "hide_start");
	CPrintToChatAll("%t %t", "hide_tag" , "hide_start");


	
	HideTimer = INVALID_HANDLE;
	
	return Plugin_Stop;
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

public PlayerSay(Handle:event, String:name[], bool:dontBroadcast)
{
	decl String:text[256];
	decl String:steamid[64];
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	GetClientAuthString(client, steamid, sizeof(steamid));
	GetEventString(event, "text", text, sizeof(text));
	
	if (StrEqual(text, "!verstecken") || StrEqual(text, "!hide"))
	{
	if(GetConVarInt(g_wenabled) == 1)
	{	
		if (GetTeamClientCount(3) > 0)
		{
			if (RoundLimits == 0)
			{
				if (!IsHide && !StartHide)
				{
					if (StrContains(voted, steamid, true) == -1)
					{
						new playercount = (GetClientCount(true) / 2);
						
						votecount++;
						
						new Missing = playercount - votecount + 1;
						
						Format(voted, sizeof(voted), "%s,%s", voted, steamid);
						
						if (votecount > playercount)
						{
							StartHide = true;
							
							SetCvar("sm_war_enable", 0);
							SetCvar("sm_ffa_enable", 0);
							SetCvar("sm_zombie_enable", 0);
							SetCvar("sm_duckhunt_enable", 0);
							SetCvar("sm_catch_enable", 0);
							SetCvar("sm_noscope_enable", 0);
							
							RoundLimits = GetConVarInt(RoundLimitsc);
							votecount = 0;
							
							CPrintToChatAll("%t %t", "hide_tag" , "hide_next");
						}
						else CPrintToChatAll("%t %t", "hide_tag" , "hide_need", Missing);
						
					}
					else CPrintToChat(client, "%t %t", "hide_tag" , "hide_voted");
				}
				else CPrintToChat(client, "%t %t", "hide_tag" , "hide_progress");
			}
			else CPrintToChat(client, "%t %t", "hide_tag" , "hide_wait", RoundLimits);
		}
		else CPrintToChat(client, "%t %t", "hide_tag" , "hide_minct");
	}
	else CPrintToChat(client, "%t %t", "hide_tag" , "hide_disabled");
	}
}



public SetCvar(String:cvarName[64], value)
{
	usecvar = FindConVar(cvarName);
	if(usecvar == INVALID_HANDLE) return;
	
	new flags = GetConVarFlags(usecvar);
	flags &= ~FCVAR_NOTIFY;
	SetConVarFlags(usecvar, flags);

	SetConVarInt(usecvar, value);

	flags |= FCVAR_NOTIFY;
	SetConVarFlags(usecvar, flags);
}

public SetCvarF(String:cvarName[64], Float:value)
{
	usecvar = FindConVar(cvarName);
	if(usecvar == INVALID_HANDLE) return;

	new flags = GetConVarFlags(usecvar);
	flags &= ~FCVAR_NOTIFY;
	SetConVarFlags(usecvar, flags);

	SetConVarFloat(usecvar, value);

	flags |= FCVAR_NOTIFY;
	SetConVarFlags(usecvar, flags);
}

public OnMapEnd()
{
	IsHide = false;
	StartHide = false;
	votecount = 0;
	HideRound = 0;
	
	voted[0] = '\0';
}