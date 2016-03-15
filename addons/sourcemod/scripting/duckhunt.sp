//includes
#include <cstrike>
#include <sourcemod>
#include <sdktools>
#include <smartjaildoors>
#include <sdkhooks>

//Compiler Options
#pragma semicolon 1

#define PLUGIN_VERSION   "0.1"


new preparetime;
new roundtime;
new roundtimenormal;
new votecount;
new DuckHuntRound;
new RoundLimits;
new m_flNextSecondaryAttack;

new Handle:LimitTimer;
new Handle:DuckHuntTimer;
new Handle:WeaponTimer;
new Handle:DuckHuntMenu;
new Handle:roundtimec;
new Handle:roundtimenormalc;
new Handle:preparetimec;
new Handle:RoundLimitsc;
new Handle:g_wenabled=INVALID_HANDLE;
new Handle:g_duckhuntprefix=INVALID_HANDLE;
new Handle:g_duckhuntcmd=INVALID_HANDLE;
new Handle:cvar;

new bool:IsDuckHunt;
new bool:StartDuckHunt;

new String:voted[1500];
new String:g_wduckhuntprefix[64];
char g_wduckhuntcmd[64];


public Plugin myinfo = {
	name = "MyJailbreak - DuckHunt",
	author = "shanapu & Floody.de, fransico",
	description = "Jailbreak DuckHunt script",
	version = PLUGIN_VERSION,
	url = ""
};



public OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreakDuckHunt.phrases");
	
	RegAdminCmd("sm_setduckhunt", SetDuckHunt, ADMFLAG_GENERIC);
	
	CreateConVar("sm_duckhunt_version", "PLUGIN_VERSION", "The version of the SourceMod plugin MyJailBreak - War", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_wenabled = CreateConVar("sm_duckhunt_enable", "1", "0 - disabled, 1 - enable war");
	g_duckhuntprefix = CreateConVar("sm_duckhunt_prefix", "war", "Insert your Jailprefix. shown in braces [war]");
	g_duckhuntcmd = CreateConVar("sm_duckhunt_cmd", "!entenjagd", "Insert your 2nd chat trigger. !war still enabled");
	roundtimec = CreateConVar("sm_duckhunt_roundtime", "5", "Round time for a single war round");
	roundtimenormalc = CreateConVar("sm_noduckhunt_roundtime", "12", "set round time after a war round zour normal mp_roudntime");
	preparetimec = CreateConVar("sm_duckhunt_preparetime", "15", "Time freeze duckhunts");
	RoundLimitsc = CreateConVar("sm_duckhunt_roundsnext", "3", "Runden nach Krieg oder Mapstart bis Krieg gestartet werden kann");
	

	GetConVarString(g_duckhuntprefix, g_wduckhuntprefix, sizeof(g_wduckhuntprefix));
	GetConVarString(g_duckhuntcmd, g_wduckhuntcmd, sizeof(g_wduckhuntcmd));
	
	AutoExecConfig(true, "MyJailbreak_DuckHunt");
	
	IsDuckHunt = false;
	StartDuckHunt = false;
	votecount = 0;
	DuckHuntRound = 0;
	
	HookEvent("round_start", RoundStart);
	HookEvent("player_say", PlayerSay);
	HookEvent("round_end", RoundEnd);
	
	AddFileToDownloadsTable("materials/models/props_farm/chicken_white.vmt");
	AddFileToDownloadsTable("materials/models/props_farm/chicken_white.vtf");
	AddFileToDownloadsTable("models/chicken/chicken.dx90.vtx");
	AddFileToDownloadsTable("models/chicken/chicken.phy");
	AddFileToDownloadsTable("models/chicken/chicken.vvd");
	AddFileToDownloadsTable("models/chicken/chicken.mdl");
	PrecacheModel("models/chicken/chicken.mdl", true);
	PrecacheModel("models/player/custom_player/legacy/tm_phoenix_heavy.mdl", true);


	
	m_flNextSecondaryAttack = FindSendPropOffs("CBaseCombatWeapon", "m_flNextSecondaryAttack");
}


public OnMapStart()
{
	//new String:voted[1500];

	votecount = 0;
	DuckHuntRound = 0;
	IsDuckHunt = false;
	StartDuckHunt = false;
	RoundLimits = 0;
	
	preparetime = GetConVarInt(preparetimec);
	roundtime = GetConVarInt(roundtimec);
	roundtimenormal = GetConVarInt(roundtimenormalc);
	
}

public OnConfigsExecuted()
{
	roundtime = GetConVarInt(roundtimec);
	roundtimenormal = GetConVarInt(roundtimenormalc);
	preparetime = GetConVarInt(preparetimec);
	RoundLimits = 0;
}

public RoundEnd(Handle:event, String:name[], bool:dontBroadcast)
{
	new winner = GetEventInt(event, "winner");
	
	if (IsDuckHunt)
	{
		for(new client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client)) SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
		}
		
		if (LimitTimer != INVALID_HANDLE) KillTimer(LimitTimer);
		if (DuckHuntTimer != INVALID_HANDLE) KillTimer(DuckHuntTimer);
		if (WeaponTimer != INVALID_HANDLE) KillTimer(WeaponTimer);
		
		roundtime = GetConVarInt(roundtimec);
		roundtimenormal = GetConVarInt(roundtimenormalc);
		
		if (winner == 2) PrintCenterTextAll("%t", "duckhunt_twin");
		if (winner == 3) PrintCenterTextAll("%t", "duckhunt_ctwin");
		IsDuckHunt = false;
		StartDuckHunt = false;
		DuckHuntRound = 0;
		Format(voted, sizeof(voted), "");
		SetCvar("sm_hosties_lr", 1);
		SetCvar("sm_war_enable", 1);
		SetCvar("dice_enable", 1);
		SetCvar("sm_zombie_enable", 1);
		SetCvar("sm_hide_enable", 1);
		SetCvar("sm_warffa_enable", 1);
		SetCvar("sm_beacon_enabled", 0);
		SetCvar("sv_infinite_ammo", 0);
		SetCvar("sm_warden_enable", 1);
		SetCvar("mp_roundtime", roundtimenormal);
		SetCvar("mp_roundtime_hostage", roundtimenormal);
		SetCvar("mp_roundtime_defuse", roundtimenormal);
		PrintToChatAll("[%s] %t", g_wduckhuntprefix, "duckhunt_end");
		
	}
	if (StartDuckHunt)
	{
	SetCvar("mp_roundtime", roundtime);
	SetCvar("mp_roundtime_hostage", roundtime);
	SetCvar("mp_roundtime_defuse", roundtime);
	}
	
	for(new i = 1; i <= MaxClients; i++)
	if(IsClientInGame(i)) SDKUnhook(i, SDKHook_PreThink, OnPreThink);
}

public Action SetDuckHunt(int client,int args)
{
	if(GetConVarInt(g_wenabled) == 1)	
	{
	StartDuckHunt = true;
	RoundLimits = GetConVarInt(RoundLimitsc);
	votecount = 0;
	PrintToChatAll("[%s] %t", g_wduckhuntprefix, "duckhunt_next");
	}
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	SDKHook(client, SDKHook_PreThink, OnPreThink);
}

public Action:OnWeaponCanUse(client, weapon)
{
	if(IsDuckHunt == true)
		{

		decl String:sWeapon[32];
		GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));

		if(!StrEqual(sWeapon, "weapon_awp") && !StrEqual(sWeapon, "weapon_knife"))
		{
		
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
			return Plugin_Handled;
			}
		}

		}
		return Plugin_Continue;
}

public Action:OnPreThink(client)
{
	new iWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	SetNoScope(iWeapon);
	return Plugin_Continue;
}

stock SetNoScope(weapon)
{
	if(IsValidEdict(weapon))
	{
		decl String:classname[MAX_NAME_LENGTH];

		if (GetEdictClassname(weapon, classname, sizeof(classname))
		|| StrEqual(classname[7], "ssg08")  || StrEqual(classname[7], "aug")
		|| StrEqual(classname[7], "sg550")  || StrEqual(classname[7], "sg552")
		|| StrEqual(classname[7], "sg556")  || StrEqual(classname[7], "awp")
		|| StrEqual(classname[7], "scar20") || StrEqual(classname[7], "g3sg1"))
		{
			SetEntDataFloat(weapon, m_flNextSecondaryAttack, GetGameTime() + 1.0);
		}
	}
}

public RoundStart(Handle:event, String:name[], bool:dontBroadcast)
{
	if (StartDuckHunt)
	{
		
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_war_enable", 0);
		SetCvar("sm_zombie_enable", 0);
		SetCvar("sm_warffa_enable", 0);
		SetCvar("sm_beacon_enabled", 1);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_hide_enable", 0);
		SetCvar("dice_enable", 0);
		SetCvar("sv_infinite_ammo", 1);
		IsDuckHunt = true;
		DuckHuntRound++;
		StartDuckHunt = false;
		
		DuckHuntMenu = CreatePanel();
		DrawPanelText(DuckHuntMenu, "Wir spielen eine DuckHunt Round!");

		DrawPanelText(DuckHuntMenu, "Die Terrors sind hühnchen ");
		DrawPanelText(DuckHuntMenu, "-----------------------------------");
		DrawPanelText(DuckHuntMenu, "Die Counter haben noscope awp");
		DrawPanelText(DuckHuntMenu, "								   ");
		DrawPanelText(DuckHuntMenu, "- In der Waffenstillstandsphase darf man schon aus der Waffenkammer!");
		DrawPanelText(DuckHuntMenu, "- Alle normalen Jailregeln sind dabei aufgehoben!");
		DrawPanelText(DuckHuntMenu, "- Buchstaben-, Yard- und Waffenkammercampen ist verboten!");
		DrawPanelText(DuckHuntMenu, "- Der letzte Terrorist hat keinen Wunsch!");
		DrawPanelText(DuckHuntMenu, "- Jeder darf überall hin wo er will!");
		DrawPanelText(DuckHuntMenu, "-----------------------------------");
		
		if (DuckHuntRound > 0)
			{
				for(new client=1; client <= MaxClients; client++)
				{
					
					if (IsClientInGame(client))
					{
						if (GetClientTeam(client) == 3)
						{
						SetEntityModel(client, "models/player/custom_player/legacy/tm_phoenix_heavy.mdl");
						SetEntityHealth(client, 600);
						GivePlayerItem(client, "weapon_awp");
						}
						if (GetClientTeam(client) == 2)
						{
						SetEntityModel(client, "models/chicken/chicken.mdl");
						SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.2);
						SetEntityGravity(client, 0.3);
						GivePlayerItem(client, "weapon_hegrenade");
						}
					}
					if (IsClientInGame(client))
					{
					SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					SendPanelToClient(DuckHuntMenu, client, Pass, 15);
					SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
					}
				}
				preparetime--;
				DuckHuntTimer = CreateTimer(1.0, DuckHunt, _, TIMER_REPEAT);
			}
		for(new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i)) SDKHook(i, SDKHook_PreThink, OnPreThink);
	}
}



public Pass(Handle:menu, MenuAction:action, param1, param2)
{
}


public Action:DuckHunt(Handle:timer)
{
	if (preparetime > 1)
	{
		preparetime--;
		for (new client=1; client <= MaxClients; client++)
		if (IsClientInGame(client) && IsPlayerAlive(client))
			{
		
						PrintCenterText(client,"%i %t", preparetime, "duckhunt_timetounfreeze");
			}
		return Plugin_Continue;
	}
	
	preparetime = GetConVarInt(preparetimec);
	
	if (DuckHuntRound > 0)
	{
		for (new client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
			if (GetClientTeam(client) == 2)
				{
				SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
				SetEntityGravity(client, 0.3);
				}
			if (GetClientTeam(client) == 3)
				{
				SetEntProp(client, Prop_Data, "m_takedamage", 1, 1);
				}
			}
		}
	}
	PrintCenterTextAll("%t", "duckhunt_start");
	PrintToChatAll("[%s] %t", g_wduckhuntprefix, "duckhunt_start");
	SJD_OpenDoors();


	
	DuckHuntTimer = INVALID_HANDLE;
	
	return Plugin_Stop;
}


public PlayerSay(Handle:event, String:name[], bool:dontBroadcast)
{
	decl String:text[256];
	decl String:steamid[64];
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	GetClientAuthString(client, steamid, sizeof(steamid));
	GetEventString(event, "text", text, sizeof(text));
	
	if (StrEqual(text, g_wduckhuntcmd) || StrEqual(text, "!duckhunt"))
	{
	if(GetConVarInt(g_wenabled) == 1)
	{	
		if (GetTeamClientCount(3) > 0)
		{
			if (RoundLimits == 0)
			{
				if (!IsDuckHunt && !StartDuckHunt)
				{
					if (StrContains(voted, steamid, true) == -1)
					{
						new playercount = (GetClientCount(true) / 2);
						
						votecount++;
						
						new Missing = playercount - votecount + 1;
						
						Format(voted, sizeof(voted), "%s,%s", voted, steamid);
						
						if (votecount > playercount)
						{
							StartDuckHunt = true;
							
							RoundLimits = GetConVarInt(RoundLimitsc);
							votecount = 0;
							
							PrintToChatAll("[%s] %t", g_wduckhuntprefix, "duckhunt_next");
						}
						else PrintToChatAll("[%s] %i Votes bis Krieg beginnt", g_wduckhuntprefix, Missing);
						
					}
					else PrintToChat(client, "[%s] %t", g_wduckhuntprefix, "duckhunt_voted");
				}
				else PrintToChat(client, "[%s] %t", g_wduckhuntprefix, "duckhunt_progress");
			}
			else PrintToChat(client, "[%s] Du musst noch %i Runden warten", g_wduckhuntprefix, RoundLimits);
		}
		else PrintToChat(client, "[%s] %t", g_wduckhuntprefix, "duckhunt_minct");
	}
	else PrintToChat(client, "[%s] %t", g_wduckhuntprefix, "duckhunt_disabled");
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
	IsDuckHunt = false;
	StartDuckHunt = false;
	votecount = 0;
	DuckHuntRound = 0;
	
	voted[0] = '\0';
}