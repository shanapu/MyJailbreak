//includes
#include <cstrike>
#include <sourcemod>
#include <sdktools>
#include <smartjaildoors>

//Compiler Options
#pragma semicolon 1

#define PLUGIN_VERSION   "1.1xx"

new freezetime;
new nodamagetimer;
new roundtime;
new roundtimenormal;
new votecount;
new warffaRound;
new RoundLimits;

new Handle:LimitTimer;
new Handle:HideTimer;
new Handle:WeaponTimer;
new Handle:warffaMenu;
new Handle:roundtimec;
new Handle:roundtimenormalc;
new Handle:freezetimec;
new Handle:nodamagetimerc;
new Handle:RoundLimitsc;
new Handle:g_wenabled=INVALID_HANDLE;
new Handle:g_wspawncell=INVALID_HANDLE;
new Handle:g_warffaprefix=INVALID_HANDLE;
new Handle:g_warffacmd=INVALID_HANDLE;
new Handle:cvar;

new bool:Iswarffa;
new bool:Startwarffa;

new String:voted[1500];
new String:g_wwarffaprefix[64];
char g_wwarffacmd[64];

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
	LoadTranslations("warffa.phrases");
	
	RegAdminCmd("sm_setwarffa", Setwarffa, ADMFLAG_GENERIC);
	
	CreateConVar("sm_warffa_version", "PLUGIN_VERSION", "The version of the SourceMod plugin MyJailBreak - War", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_wenabled = CreateConVar("sm_warffa_enable", "1", "0 - disabled, 1 - enable warffa");
	g_wspawncell = CreateConVar("sm_warffa_spawn", "1", "0 - teleport to weaponroom, 1 - standart spawn - cell doors auto open");
	g_warffaprefix = CreateConVar("sm_warffa_prefix", "warffa", "Insert your Jailprefix. shown in braces [warffa]");
	g_warffacmd = CreateConVar("sm_warffa_cmd", "!krieg", "Insert your 2nd chat trigger. !warffa still enabled");
	roundtimec = CreateConVar("sm_warffa_roundtime", "5", "Round time for a single warffa round");
	roundtimenormalc = CreateConVar("sm_nowarffa_roundtime", "12", "set round time after a warffa round");
	freezetimec = CreateConVar("sm_warffa_freezetime", "30", "Time freeze T");
	nodamagetimerc = CreateConVar("sm_warffa_nodamage", "30", "Time after freezetime damage disbaled");
	RoundLimitsc = CreateConVar("sm_warffa_roundsnext", "3", "Runden nach Krieg oder Mapstart bis Krieg gestartet werden kann");

	GetConVarString(g_warffaprefix, g_wwarffaprefix, sizeof(g_wwarffaprefix));
	GetConVarString(g_warffacmd, g_wwarffacmd, sizeof(g_wwarffacmd));
	
	AutoExecConfig(true, "MyJailbreak_warffa");
	
	Iswarffa = false;
	Startwarffa = false;
	votecount = 0;
	warffaRound = 0;
	
	HookEvent("round_start", RoundStart);
	HookEvent("player_say", PlayerSay);
	HookEvent("round_end", RoundEnd);
}


public OnMapStart()
{
	//new String:voted[1500];

	votecount = 0;
	warffaRound = 0;
	Iswarffa = false;
	Startwarffa = false;
	RoundLimits = 0;
	
	
	freezetime = GetConVarInt(freezetimec);
	nodamagetimer = GetConVarInt(nodamagetimerc);
	roundtime = GetConVarInt(roundtimec);
	roundtimenormal = GetConVarInt(roundtimenormalc);

}

public OnConfigsExecuted()
{
	roundtime = GetConVarInt(roundtimec);
	roundtimenormal = GetConVarInt(roundtimenormalc);
	freezetime = GetConVarInt(freezetimec);
	nodamagetimer = GetConVarInt(nodamagetimerc);
	RoundLimits = 0;
}

public RoundEnd(Handle:event, String:name[], bool:dontBroadcast)
{
	new winner = GetEventInt(event, "winner");
	
	if (Iswarffa)
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
		
		if (winner == 2) PrintCenterTextAll("%t", "warffa_twin"); 
		if (winner == 3) PrintCenterTextAll("%t", "warffa_ctwin");

		if (warffaRound == 3)
		{
			Iswarffa = false;
			warffaRound = 0;
			Format(voted, sizeof(voted), "");
			SetCvar("sm_hosties_lr", 1);
			SetCvar("dice_enable", 1);
			SetCvar("sm_warden_enable", 1);
			SetCvar("sm_hide_enable", 1);
			SetCvar("sm_zombie_enable", 1);
			SetCvar("sm_war_enable", 1);
			SetCvar("mp_teammates_are_enemies", 0);
			SetCvar("mp_friendlyfire", 0);
			SetCvar("mp_roundtime", roundtimenormal);
			SetCvar("mp_roundtime_hostage", roundtimenormal);
			SetCvar("mp_roundtime_defuse", roundtimenormal);
			PrintToChatAll("[%s] %t", g_wwarffaprefix, "warffa_end");
		}
	}
	if (Startwarffa)
	{
	SetCvar("mp_roundtime", roundtime);
	SetCvar("mp_roundtime_hostage", roundtime);
	SetCvar("mp_roundtime_defuse", roundtime);
	}
}

public Action Setwarffa(int client,int args)
{
	if(GetConVarInt(g_wenabled) == 1)	
	{
	Startwarffa = true;
	RoundLimits = GetConVarInt(RoundLimitsc);
	votecount = 0;
	PrintToChatAll("[%s] %t", g_wwarffaprefix, "warffa_next");
	}
}

public RoundStart(Handle:event, String:name[], bool:dontBroadcast)
{
	if (Startwarffa || Iswarffa)
	{
		SetCvar("dice_enable", 0);
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_hide_enable", 0);
		SetCvar("sm_war_enable", 0);
		SetCvar("mp_teammates_are_enemies", 1);
		SetCvar("mp_friendlyfire", 1);
		SetCvar("sm_zombie_enable", 0);
		warffaRound++;
		Iswarffa = true;
		Startwarffa = false;
		if(GetConVarInt(g_wspawncell) == 1)
		{
		SJD_OpenDoors();
		freezetime = 0;
		}
		warffaMenu = CreatePanel();
		DrawPanelText(warffaMenu, "Krieg - Jeder gegen Jeden - ist aktiv");
		if (warffaRound == 1) DrawPanelText(warffaMenu, "Runde 1 von 3");
		if (warffaRound == 2) DrawPanelText(warffaMenu, "Runde 2 von 3");
		if (warffaRound == 3) DrawPanelText(warffaMenu, "Runde 3 von 3");
		if(GetConVarInt(g_wspawncell) == 0)
		{
		DrawPanelText(warffaMenu, "Nicht wundern falls ihr in der Luft hängt");
		DrawPanelText(warffaMenu, "-----------------------------------");
		DrawPanelText(warffaMenu, "In Battle Royale spielt jeder gegen jeden");
		DrawPanelText(warffaMenu, "                                   ");
		DrawPanelText(warffaMenu, "- In der Waffenstillstandsphase darf man schon aus der Waffenkammer!");
		DrawPanelText(warffaMenu, "- Alle normalen Jailregeln sind dabei aufgehoben!");
		DrawPanelText(warffaMenu, "- Buchstaben-, Yard- und Waffenkammercampen ist verboten!");
		DrawPanelText(warffaMenu, "- Der letzte Terrorist hat keinen Wunsch!");
		DrawPanelText(warffaMenu, "- Jeder darf überall hin wo er will!");
		DrawPanelText(warffaMenu, "-----------------------------------");
		}else{
		DrawPanelText(warffaMenu, "Nicht wundern warum ihr in der Zelle spawnt");
		DrawPanelText(warffaMenu, "-----------------------------------");
		DrawPanelText(warffaMenu, "In Battle Royale spielt jeder gegen jeden");
		DrawPanelText(warffaMenu, "                                   ");
		DrawPanelText(warffaMenu, "- In der Waffenstillstandsphase darf man schon aus der Waffenkammer!");
		DrawPanelText(warffaMenu, "- Alle normalen Jailregeln sind dabei aufgehoben!");
		DrawPanelText(warffaMenu, "- Buchstaben-, Yard- und Waffenkammercampen ist verboten!");
		DrawPanelText(warffaMenu, "- Der letzte Terrorist hat keinen Wunsch!");
		DrawPanelText(warffaMenu, "- Jeder darf überall hin wo er will!");
		DrawPanelText(warffaMenu, "-----------------------------------");
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

			if (warffaRound > 0)
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
				}PrintToChatAll("[%s] Runde %i von 3", g_wwarffaprefix, warffaRound);
			}
			for(new client=1; client <= MaxClients; client++)
			{
				if (IsClientInGame(client))
				{
					SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					SendPanelToClient(warffaMenu, client, Pass, 15);
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
		
		PrintCenterTextAll("%i %t", nodamagetimer, "warffa_damage");
		
		return Plugin_Continue;
	}
	
	nodamagetimer = GetConVarInt(nodamagetimerc);
	
	PrintCenterTextAll("%t", "warffa_start");
	
	for(new client=1; client <= MaxClients; client++) 
	{
		if (IsClientInGame(client) && IsPlayerAlive(client)) SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
	}

	PrintToChatAll("[%s] %t", g_wwarffaprefix, "warffa_start");
	
	WeaponTimer = INVALID_HANDLE;
	
	return Plugin_Stop;
}

public PlayerSay(Handle:event, String:name[], bool:dontBroadcast)
{
	decl String:text[256];
	decl String:steamid[64];
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	GetClientAuthString(client, steamid, sizeof(steamid));
	GetEventString(event, "text", text, sizeof(text));
	
	if (StrEqual(text, g_wwarffacmd) || StrEqual(text, "!warffa"))
	{
	if(GetConVarInt(g_wenabled) == 1)
	{	
		if (GetTeamClientCount(3) > 0)
		{
			if (RoundLimits == 0)
			{
				if (!Iswarffa && !Startwarffa)
				{
					if (StrContains(voted, steamid, true) == -1)
					{
						new playercount = (GetClientCount(true) / 2);
						
						votecount++;
						
						new Missing = playercount - votecount + 1;
						
						Format(voted, sizeof(voted), "%s,%s", voted, steamid);
						
						if (votecount > playercount)
						{
							Startwarffa = true;
							
							RoundLimits = GetConVarInt(RoundLimitsc);
							votecount = 0;
							
							PrintToChatAll("[%s] %t", g_wwarffaprefix, "warffa_next");
						}
						else PrintToChatAll("[%s] %i Votes bis Krieg beginnt", g_wwarffaprefix, Missing);
						
					}
					else PrintToChat(client, "[%s] %t", g_wwarffaprefix, "warffa_voted");
				}
				else PrintToChat(client, "[%s] %t", g_wwarffaprefix, "warffa_progress");
			}
			else PrintToChat(client, "[%s] Du musst noch %i Runden warten", g_wwarffaprefix, RoundLimits);
		}
		else PrintToChat(client, "[%s] %t", g_wwarffaprefix, "warffa_minct");
	}
	else PrintToChat(client, "[%s] %t", g_wwarffaprefix, "warffa_disabled");
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
	Iswarffa = false;
	Startwarffa = false;
	votecount = 0;
	warffaRound = 0;
	
	voted[0] = '\0';
}