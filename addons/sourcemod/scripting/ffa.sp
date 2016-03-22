//includes
#include <cstrike>
#include <sourcemod>
#include <colors>
#include <sdktools>
#include <wardn>
#include <smartjaildoors>

//Compiler Options
#pragma semicolon 1

#define PLUGIN_VERSION   "0.x"
ConVar gc_bTagEnabled;
new freezetime;
new nodamagetimer;
new roundtime;
new roundtimenormal;
new votecount;
new ffaRound;
new RoundLimits;

new FogIndex = -1;
new Float:mapFogStart = 0.0;
new Float:mapFogEnd = 150.0;
new Float:mapFogDensity = 0.99;

new Handle:LimitTimer;
new Handle:HideTimer;
new Handle:WeaponTimer;
new Handle:ffaMenu;
new Handle:roundtimec;
new Handle:roundtimenormalc;
new Handle:freezetimec;
new Handle:nodamagetimerc;
new Handle:RoundLimitsc;
new Handle:g_wenabled=INVALID_HANDLE;
new Handle:g_wspawncell=INVALID_HANDLE;
new Handle:cvar;

new bool:Isffa;
new bool:Startffa;

new String:voted[1500];


new Float:Pos[3];


public Plugin myinfo = {
	name = "MyJailbreak - War FFA",
	author = "shanapu & Floody.de",
	description = "Jailbreak War FFA script",
	version = PLUGIN_VERSION,
	url = ""
};



public OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreakFfa.phrases");
	
	RegAdminCmd("sm_setffa", Setffa, ADMFLAG_GENERIC);
	
	CreateConVar("sm_ffa_version", "PLUGIN_VERSION", "The version of the SourceMod plugin MyJailBreak - War", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_wenabled = CreateConVar("sm_ffa_enable", "1", "0 - disabled, 1 - enable ffa");
	g_wspawncell = CreateConVar("sm_ffa_spawn", "1", "0 - teleport to weaponroom, 1 - standart spawn - cell doors auto open");
	roundtimec = CreateConVar("sm_ffa_roundtime", "5", "Round time for a single ffa round");
	roundtimenormalc = CreateConVar("sm_noffa_roundtime", "12", "set round time after a ffa round");
	freezetimec = CreateConVar("sm_ffa_freezetime", "30", "Time freeze T");
	nodamagetimerc = CreateConVar("sm_ffa_nodamage", "30", "Time after freezetime damage disbaled");
	RoundLimitsc = CreateConVar("sm_ffa_roundsnext", "3", "Runden nach Krieg oder Mapstart bis Krieg gestartet werden kann");
	gc_bTagEnabled = CreateConVar("sm_ffa_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch you sv_tags", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	AutoExecConfig(true, "MyJailbreak_ffa");
	
	Isffa = false;
	Startffa = false;
	votecount = 0;
	ffaRound = 0;
	
	HookEvent("round_start", RoundStart);
	HookEvent("player_say", PlayerSay);
	HookEvent("round_end", RoundEnd);
}


public OnMapStart()
{
	//new String:voted[1500];

	votecount = 0;
	ffaRound = 0;
	Isffa = false;
	Startffa = false;
	RoundLimits = 0;
	
	
	freezetime = GetConVarInt(freezetimec);
	nodamagetimer = GetConVarInt(nodamagetimerc);
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
	nodamagetimer = GetConVarInt(nodamagetimerc);
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
	
	if (Isffa)
	{
	
		for(new client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client)) SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
		}
		
		if (LimitTimer != INVALID_HANDLE) KillTimer(LimitTimer);
		if (HideTimer != INVALID_HANDLE) KillTimer(HideTimer);
		if (WeaponTimer != INVALID_HANDLE) KillTimer(WeaponTimer);
		
		roundtime = GetConVarInt(roundtimec);
		roundtimenormal = GetConVarInt(roundtimenormalc);
		
		if (winner == 2) PrintCenterTextAll("%t", "ffa_twin"); 
		if (winner == 3) PrintCenterTextAll("%t", "ffa_ctwin");

		if (ffaRound == 3)
		{
			Isffa = false;
			ffaRound = 0;
			Format(voted, sizeof(voted), "");
			SetCvar("sm_hosties_lr", 1);
			SetCvar("dice_enable", 1);
			SetCvar("sm_beacon_enabled", 0);
			SetCvar("sm_warden_enable", 1);
			SetCvar("sm_hide_enable", 1);
			SetCvar("sm_noscope_enable", 1);
			SetCvar("sm_zombie_enable", 1);
			SetCvar("sm_war_enable", 1);
			SetCvar("sm_duckhunt_enable", 1);
			SetCvar("sm_catch_enable", 1);
			SetCvar("mp_teammates_are_enemies", 0);
			SetCvar("mp_friendlyfire", 0);
			SetCvar("mp_roundtime", roundtimenormal);
			SetCvar("mp_roundtime_hostage", roundtimenormal);
			SetCvar("mp_roundtime_defuse", roundtimenormal);
			CPrintToChatAll("%t %t", "ffa_tag" , "ffa_end");
		}
	}
	if (Startffa)
	{
	SetCvar("mp_roundtime", roundtime);
	SetCvar("mp_roundtime_hostage", roundtime);
	SetCvar("mp_roundtime_defuse", roundtime);
	}
}

public Action Setffa(int client,int args)
{
	if(GetConVarInt(g_wenabled) == 1)	
	{
	if (warden_iswarden(client)) 
	{
	Startffa = true;
	RoundLimits = GetConVarInt(RoundLimitsc);
	votecount = 0;
	CPrintToChatAll("%t %t", "ffa_tag" , "ffa_next");
	}
	}
}

public RoundStart(Handle:event, String:name[], bool:dontBroadcast)
{
	if (Startffa || Isffa)
	{	{AcceptEntityInput(FogIndex, "TurnOn");}
		decl String:info1[255], String:info2[255], String:info3[255], String:info4[255], String:info5[255], String:info6[255], String:info7[255], String:info8[255];
		decl String:info9[255], String:info10[255], String:info11[255], String:info12[255];
		
		SetCvar("dice_enable", 0);
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_beacon_enabled", 1);
		SetCvar("mp_teammates_are_enemies", 1);
		SetCvar("mp_friendlyfire", 1);
		ffaRound++;
		Isffa = true;
		Startffa = false;
		if(GetConVarInt(g_wspawncell) == 1)
		{
		SJD_OpenDoors();
		freezetime = 0;
		}
		ffaMenu = CreatePanel();
		Format(info1, sizeof(info1), "%T", "ffa_info_Title", LANG_SERVER);
		SetPanelTitle(ffaMenu, info1);
		DrawPanelText(ffaMenu, "                                   ");
		Format(info10, sizeof(info10), "%T", "RoundOne", LANG_SERVER);
		if (ffaRound == 1) DrawPanelText(ffaMenu, info10);
		Format(info11, sizeof(info11), "%T", "RoundTwo", LANG_SERVER);
		if (ffaRound == 2) DrawPanelText(ffaMenu, info11);
		Format(info12, sizeof(info12), "%T", "RoundThree", LANG_SERVER);
		if (ffaRound == 3) DrawPanelText(ffaMenu, info12);
		DrawPanelText(ffaMenu, "                                   ");
		if(GetConVarInt(g_wspawncell) == 0)
		{
		Format(info2, sizeof(info2), "%T", "ffa_info_Tele", LANG_SERVER);
		DrawPanelText(ffaMenu, info2);
		DrawPanelText(ffaMenu, "-----------------------------------");
		Format(info3, sizeof(info3), "%T", "ffa_info_Line2", LANG_SERVER);
		DrawPanelText(ffaMenu, info3);
		Format(info4, sizeof(info4), "%T", "ffa_info_Line3", LANG_SERVER);
		DrawPanelText(ffaMenu, info4);
		Format(info5, sizeof(info5), "%T", "ffa_info_Line4", LANG_SERVER);
		DrawPanelText(ffaMenu, info5);
		Format(info6, sizeof(info6), "%T", "ffa_info_Line5", LANG_SERVER);
		DrawPanelText(ffaMenu, info6);
		Format(info7, sizeof(info7), "%T", "ffa_info_Line6", LANG_SERVER);
		DrawPanelText(ffaMenu, info7);
		Format(info8, sizeof(info8), "%T", "ffa_info_Line7", LANG_SERVER);
		DrawPanelText(ffaMenu, info8);
		DrawPanelText(ffaMenu, "-----------------------------------");
		}else{
		Format(info9, sizeof(info9), "%T", "ffa_info_Spawn", LANG_SERVER);
		DrawPanelText(ffaMenu, info9);
		DrawPanelText(ffaMenu, "-----------------------------------");
		Format(info3, sizeof(info3), "%T", "ffa_info_Line2", LANG_SERVER);
		DrawPanelText(ffaMenu, info3);
		Format(info4, sizeof(info4), "%T", "ffa_info_Line3", LANG_SERVER);
		DrawPanelText(ffaMenu, info4);
		Format(info5, sizeof(info5), "%T", "ffa_info_Line4", LANG_SERVER);
		DrawPanelText(ffaMenu, info5);
		Format(info6, sizeof(info6), "%T", "ffa_info_Line5", LANG_SERVER);
		DrawPanelText(ffaMenu, info6);
		Format(info7, sizeof(info7), "%T", "ffa_info_Line6", LANG_SERVER);
		DrawPanelText(ffaMenu, info7);
		Format(info8, sizeof(info8), "%T", "ffa_info_Line7", LANG_SERVER);
		DrawPanelText(ffaMenu, info8);
		DrawPanelText(ffaMenu, "-----------------------------------");
		}
		
		new RandomCT = 0;
		
		for(new client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client))
			{
				if (GetClientTeam(client) == 3)
				{
					RandomCT = client;
					break;
				}
			}
		}
		if (RandomCT)
		{	
			new Float:Pos1[3];
			
			GetClientAbsOrigin(RandomCT, Pos);
			GetClientAbsOrigin(RandomCT, Pos1);
			
			Pos[2] = Pos[2] + 45;

			if (ffaRound > 0)
			{
				for(new client=1; client <= MaxClients; client++)
				{
					if(GetConVarInt(g_wspawncell) == 1)
					{
					if (IsClientInGame(client))
					{
						if (GetClientTeam(client) == 3)
						{
							GivePlayerItem(client, "weapon_m4a1");
							GivePlayerItem(client, "weapon_deagle");
							GivePlayerItem(client, "weapon_hegrenade");
						}
						if (GetClientTeam(client) == 2)
						{
						GivePlayerItem(client, "weapon_ak47");
						GivePlayerItem(client, "weapon_deagle");
						GivePlayerItem(client, "weapon_hegrenade");
						}
					}
					}else
					{
					if (IsClientInGame(client))
					{
						if (GetClientTeam(client) == 3)
						{
							TeleportEntity(client, Pos1, NULL_VECTOR, NULL_VECTOR);
						}
						if (GetClientTeam(client) == 2)
						{
						TeleportEntity(client, Pos1, NULL_VECTOR, NULL_VECTOR);
						}
					}
					}
				}CPrintToChatAll("%t %t", "ffa_tag" ,"ffa_rounds", ffaRound);
			}
			for(new client=1; client <= MaxClients; client++)
			{
				if (IsClientInGame(client))
				{
					SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					SendPanelToClient(ffaMenu, client, Pass, 15);
					SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
				}
			}
			
			freezetime--;
			


			WeaponTimer = CreateTimer(1.0, NoWeapon, _, TIMER_REPEAT);

		}
	}
	else
	{
		if (RoundLimits > 0) RoundLimits--;
	}
}

public Pass(Handle:menu, MenuAction:action, param1, param2)
{
}


public Action:NoWeapon(Handle:timer)
{
	if (nodamagetimer > 1)
	{
		nodamagetimer--;
		
		PrintCenterTextAll("%t", "ffa_damage", nodamagetimer);
		
		return Plugin_Continue;
	}
	
	nodamagetimer = GetConVarInt(nodamagetimerc);
	
	PrintCenterTextAll("%t", "ffa_start");
	
	for(new client=1; client <= MaxClients; client++) 
	{
		if (IsClientInGame(client) && IsPlayerAlive(client)) SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
	}

	CPrintToChatAll("%t %t", "ffa_tag" , "ffa_start");
	DoFog();
	AcceptEntityInput(FogIndex, "TurnOff");
	WeaponTimer = INVALID_HANDLE;
	
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
	
	if (StrEqual(text, "!ffa") || StrEqual(text, "!ffa"))
	{
	if(GetConVarInt(g_wenabled) == 1)
	{	
		if (GetTeamClientCount(3) > 0)
		{
			if (RoundLimits == 0)
			{
				if (!Isffa && !Startffa)
				{
					if (StrContains(voted, steamid, true) == -1)
					{
						new playercount = (GetClientCount(true) / 2);
						
						votecount++;
						
						new Missing = playercount - votecount + 1;
						
						Format(voted, sizeof(voted), "%s,%s", voted, steamid);
						
						if (votecount > playercount)
						{
							Startffa = true;
							
							SetCvar("sm_hide_enable", 0);
							SetCvar("sm_war_enable", 0);
							SetCvar("sm_zombie_enable", 0);
							SetCvar("sm_duckhunt_enable", 0);
							SetCvar("sm_catch_enable", 0);
							SetCvar("sm_noscope_enable", 0);
							
							RoundLimits = GetConVarInt(RoundLimitsc);
							votecount = 0;
							
							CPrintToChatAll("%t %t", "ffa_tag" , "ffa_next");
						}
						else CPrintToChatAll("%t %t", "ffa_tag" , "ffa_need", Missing);
						
					}
					else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_voted");
				}
				else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_progress");
			}
			else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_wait", RoundLimits);
		}
		else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_minct");
	}
	else CPrintToChat(client, "%t %t", "ffa_tag" , "ffa_disabled");
	}
}



public SetCvar(String:cvarName[64], value)
{
	cvar = FindConVar(cvarName);
	if(cvar == INVALID_HANDLE) return;
	
	new flags = GetConVarFlags(cvar);
	flags &= ~FCVAR_NOTIFY;
	SetConVarFlags(cvar, flags);

	SetConVarInt(cvar, value);

	flags |= FCVAR_NOTIFY;
	SetConVarFlags(cvar, flags);
}

public SetCvarF(String:cvarName[64], Float:value)
{
	cvar = FindConVar(cvarName);
	if(cvar == INVALID_HANDLE) return;

	new flags = GetConVarFlags(cvar);
	flags &= ~FCVAR_NOTIFY;
	SetConVarFlags(cvar, flags);

	SetConVarFloat(cvar, value);

	flags |= FCVAR_NOTIFY;
	SetConVarFlags(cvar, flags);
}

public OnMapEnd()
{
	Isffa = false;
	Startffa = false;
	votecount = 0;
	ffaRound = 0;
	
	voted[0] = '\0';
}