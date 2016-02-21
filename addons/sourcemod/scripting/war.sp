/*
 * Sourcemod War Plugin
 */

//includes
#include <cstrike>
#include <sourcemod>
#include <sdktools>

//Compiler Options
#pragma semicolon 1

#define PLUGIN_VERSION   "1.1xx"

new freezetime;
new nodamagetimer;
new roundtime;
new votecount;
new WarRound;
new RoundLimits;

new Handle:LimitTimer;
new Handle:HideTimer;
new Handle:WeaponTimer;
new Handle:WarMenu;
new Handle:roundtimec;
new Handle:freezetimec;
new Handle:nodamagetimerc;
new Handle:RoundLimitsc;
new Handle:g_wenabled=INVALID_HANDLE;
new Handle:g_warprefix=INVALID_HANDLE;
//new Handle:g_warcmd=INVALID_HANDLE;

new bool:IsWar;
new bool:StartWar;

new String:voted[1500];
new String:g_wwarprefix[64];
//new String:g_wwarcmd[64];

new Float:Pos[3];


public Plugin myinfo = {
	name = "MyJailbreak - War",
	author = "shanapu & Floody",
	description = "Jailbreak War script",
	version = PLUGIN_VERSION,
	url = ""
};



public OnPluginStart()
{
    // Translation
	LoadTranslations("war.phrases");
	
	RegAdminCmd("sm_setwar", SetWar, ADMFLAG_GENERIC);
	
	CreateConVar("sm_war_version", "PLUGIN_VERSION", "The version of the SourceMod plugin MyJailBreak - War", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_wenabled = CreateConVar("sm_war_enable", "1", "0 - disabled, 1 - enable war");
	g_warprefix = CreateConVar("sm_war_prefix", "war", "Insert your Jailprefix. shown in braces [war]");
	//g_warcmd = CreateConVar("sm_war_cmd", "!krieg", "Insert your 2nd chat trigger. !war still enabled");
	roundtimec = CreateConVar("sm_war_roundtime", "400", "Maximum round time for a single war round");
	freezetimec = CreateConVar("sm_war_freezetime", "45", "Time freeze T");
	nodamagetimerc = CreateConVar("sm_war_nodamage", "15", "Time after freezetime damage disbaled");
	RoundLimitsc = CreateConVar("sm_war_roundsnext", "3", "Runden nach Krieg oder Mapstart bis Krieg gestartet werden kann");
	
	AutoExecConfig(true, "MyJailbreak_War");
	
	GetConVarString(g_warprefix, g_wwarprefix, sizeof(g_wwarprefix));
	//GetConVarString(g_warcmd, g_wwarcmd, sizeof(g_wwarcmd));
	
	IsWar = false;
	StartWar = false;
	votecount = 0;
	WarRound = 0;
	
	HookEvent("round_start", RoundStart);
	HookEvent("player_say", PlayerSay);
	HookEvent("round_end", RoundEnd);
}


public OnMapStart()
{
    //new String:voted[1500];

    votecount = 0;
    WarRound = 0;
    IsWar = false;
    StartWar = false;
    RoundLimits = 0;
    
    freezetime = GetConVarInt(freezetimec);
    nodamagetimer = GetConVarInt(nodamagetimerc);
    roundtime = GetConVarInt(roundtimec);
}

public OnConfigsExecuted()
{
    roundtime = GetConVarInt(roundtimec);
    freezetime = GetConVarInt(freezetimec);
    nodamagetimer = GetConVarInt(nodamagetimerc);
    RoundLimits = 0;
}

public RoundEnd(Handle:event, String:name[], bool:dontBroadcast)
{
    new winner = GetEventInt(event, "winner");
    
    if (IsWar)
    {
        for(new client=1; client <= MaxClients; client++)
        {
            if (IsClientInGame(client)) SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
        }
        
        if (LimitTimer != INVALID_HANDLE) KillTimer(LimitTimer);
        if (HideTimer != INVALID_HANDLE) KillTimer(HideTimer);
        if (WeaponTimer != INVALID_HANDLE) KillTimer(WeaponTimer);
        
        roundtime = GetConVarInt(roundtimec);
        
        if (winner == 2) PrintCenterTextAll("%t", "war_twin"); 
        if (winner == 3) PrintCenterTextAll("%t", "war_ctwin");

        if (WarRound == 3)
        {
            IsWar = false;
            WarRound = 0;
            Format(voted, sizeof(voted), "");
            PrintToChatAll("[%s] %t", g_wwarprefix, "war_end");
        }
    }
}

public Action SetWar(int client,int args)
{
	if(GetConVarInt(g_wenabled) == 1)	
	{
	StartWar = true;
	RoundLimits = GetConVarInt(RoundLimitsc);
	votecount = 0;
	PrintToChatAll("[%s] %t", g_wwarprefix, "war_next");
	}
}

public RoundStart(Handle:event, String:name[], bool:dontBroadcast)
{
    if (StartWar || IsWar)
    {
        WarRound++;
        IsWar = true;
        StartWar = false;
        
        WarMenu = CreatePanel();
        DrawPanelText(WarMenu, "Krieg ist aktiv");
        if (WarRound == 1) DrawPanelText(WarMenu, "Runde 1 von 3");
        if (WarRound == 2) DrawPanelText(WarMenu, "Runde 2 von 3");
        if (WarRound == 3) DrawPanelText(WarMenu, "Runde 3 von 3");
        DrawPanelText(WarMenu, "Nicht wundern falls ihr in der Luft hängt");
        DrawPanelText(WarMenu, "-----------------------------------");
        DrawPanelText(WarMenu, "In Kriegrunden spielen CT's gegen T's");
        DrawPanelText(WarMenu, "                                ");
        DrawPanelText(WarMenu, "- In der Waffenstillstandsphase darf man schon aus der Waffenkammer!");
        DrawPanelText(WarMenu, "- Alle normalen Jailregeln sind dabei aufgehoben!");
        DrawPanelText(WarMenu, "- Buchstaben-, Yard- und Waffenkammercampen ist verboten!");
        DrawPanelText(WarMenu, "- Der letzte Terrorist hat keinen Wunsch!");
        DrawPanelText(WarMenu, "- Jeder darf überall hin wo er will!");
        DrawPanelText(WarMenu, "-----------------------------------");

        
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
            
            if (WarRound == 1)
            {
                for(new client=1; client <= MaxClients; client++)
                {
                    if (IsClientInGame(client))
                    {
                        if (GetClientTeam(client) == 3)
                        {
                            GivePlayerItem(client, "weapon_m4a1");
                            GivePlayerItem(client, "weapon_deagle");
                            GivePlayerItem(client, "weapon_hegrenade");
                            TeleportEntity(client, Pos1, NULL_VECTOR, NULL_VECTOR);
                        }
                        if (GetClientTeam(client) == 2)
                        {
                            SetEntityMoveType(client, MOVETYPE_NONE);
                            TeleportEntity(client, Pos, NULL_VECTOR, NULL_VECTOR);
                        }
                    }
                }
                PrintToChatAll("[%s] Runde 1 von 3", g_wwarprefix);
            }
            if (WarRound == 2)
            {
                for(new client=1; client <= MaxClients; client++)
                {
                    if (IsClientInGame(client))
                    {
                        if (GetClientTeam(client) == 2)
                        {
                            TeleportEntity(client, Pos1, NULL_VECTOR, NULL_VECTOR);
                            GivePlayerItem(client, "weapon_m4a1");
                            GivePlayerItem(client, "weapon_deagle");
                            GivePlayerItem(client, "weapon_hegrenade");
                        }
                        if (GetClientTeam(client) == 3)
                        {
                            SetEntityMoveType(client, MOVETYPE_NONE);
                            TeleportEntity(client, Pos, NULL_VECTOR, NULL_VECTOR);
                        }
                    }
                }
                PrintToChatAll("[%s] Runde 2 von 3", g_wwarprefix);
            }
            
            if (WarRound == 3)
            {
                for(new client=1; client <= MaxClients; client++)
                {
                    if (IsClientInGame(client))
                    {
                        if (GetClientTeam(client) == 3)
                        {
                            GivePlayerItem(client, "weapon_m4a1");
                            GivePlayerItem(client, "weapon_deagle");
                            GivePlayerItem(client, "weapon_hegrenade");
                            TeleportEntity(client, Pos1, NULL_VECTOR, NULL_VECTOR);
                        }
                        if (GetClientTeam(client) == 2)
                        {
                            SetEntityMoveType(client, MOVETYPE_NONE);
                            TeleportEntity(client, Pos, NULL_VECTOR, NULL_VECTOR);
                        }
                    }
                }
                PrintToChatAll("[%s] Runde 3 von 3", g_wwarprefix);
            }
            for(new client=1; client <= MaxClients; client++)
            {
                if (IsClientInGame(client)) 
                {
                    SetEntData(client, FindSendPropOffs("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
                    SendPanelToClient(WarMenu, client, Pass, 30);
                    SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
                }
            }
            
            freezetime--;
            roundtime--;
            
            LimitTimer = CreateTimer(1.0, RestTime, _, TIMER_REPEAT);
            HideTimer = CreateTimer(1.0, Hide, _, TIMER_REPEAT);
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

public Action:RestTime(Handle:timer)
{
    roundtime--;
    
    if (roundtime == 60) PrintCenterTextAll("60 Sekunden verbleiben");
    if (roundtime == 30) PrintCenterTextAll("30 Sekunden verbleiben");
    if (roundtime == 10) PrintCenterTextAll("10 Sekunden verbleiben");
    if (roundtime == 3) PrintCenterTextAll("3 Sekunden verbleiben");
    if (roundtime == 2) PrintCenterTextAll("2 Sekunden verbleiben");
    if (roundtime == 1) PrintCenterTextAll("1 Sekunde verbleibt");
    if (roundtime == 0) 
    {
        new randomnumber = GetRandomInt(2, 3);
        PrintToChatAll("[%s] %t", g_wwarprefix, "war_endkill");
        
        for(new client=1; client <= MaxClients; client++)
        {
            if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == randomnumber) SlapPlayer(client, 500, false);    
        }
    }
    
    PrintHintTextToAll("%i Sekunden verbleiben", roundtime);
    
    if (IsWar) return Plugin_Continue;
    
    roundtime = GetConVarInt(roundtimec);
    
    LimitTimer = INVALID_HANDLE;
    
    return Plugin_Stop;
}

public Action:Hide(Handle:timer)
{
    if (freezetime > 1)
    {
        freezetime--;
        
        PrintCenterTextAll("%i Sekunden Zeit zum verstecken", freezetime);
        
        return Plugin_Continue;
    }
    
    Pos[2] = Pos[2] - 45;
    
    freezetime = GetConVarInt(freezetimec);
    
    if (WarRound == 1)
    {
        for (new client=1; client <= MaxClients; client++)
        {
            if (IsClientInGame(client) && IsPlayerAlive(client))
            {
                if (GetClientTeam(client) == 2)
                {
                    SetEntityMoveType(client, MOVETYPE_WALK);
                    TeleportEntity(client, Pos, NULL_VECTOR, NULL_VECTOR);
                    GivePlayerItem(client, "weapon_m4a1");
                    GivePlayerItem(client, "weapon_deagle");
                    GivePlayerItem(client, "weapon_hegrenade");
                    GivePlayerItem(client, "weapon_knife");
                }
            }
        }
    }
    if (WarRound == 2)
    {
        for(new client=1; client <= MaxClients; client++)
        {
            if (IsClientInGame(client) && IsPlayerAlive(client))
            {
                if (GetClientTeam(client) == 3)
                {
                    SetEntityMoveType(client, MOVETYPE_WALK);
                    TeleportEntity(client, Pos, NULL_VECTOR, NULL_VECTOR);
                    GivePlayerItem(client, "weapon_m4a1");
                    GivePlayerItem(client, "weapon_deagle");
                    GivePlayerItem(client, "weapon_hegrenade");
                    GivePlayerItem(client, "weapon_knife");
                }
            }
        }
    }
    if (WarRound == 3)
    {
        for (new client=1; client <= MaxClients; client++)
        {
            if (IsClientInGame(client) && IsPlayerAlive(client))
            {
                if (GetClientTeam(client) == 2)
                {
                    SetEntityMoveType(client, MOVETYPE_WALK);
                    TeleportEntity(client, Pos, NULL_VECTOR, NULL_VECTOR);
                    GivePlayerItem(client, "weapon_m4a1");
                    GivePlayerItem(client, "weapon_deagle");
                    GivePlayerItem(client, "weapon_hegrenade");
                    GivePlayerItem(client, "weapon_knife");
                }
            }
        }
    }

    WeaponTimer = CreateTimer(1.0, NoWeapon, _, TIMER_REPEAT);
    
    HideTimer = INVALID_HANDLE;
    
    return Plugin_Stop;
}

public Action:NoWeapon(Handle:timer)
{
    if (nodamagetimer > 1)
    {
        nodamagetimer--;
        
        PrintCenterTextAll("%i Sekunden Waffenstillstand", nodamagetimer);
        
        return Plugin_Continue;
    }
    
    nodamagetimer = GetConVarInt(nodamagetimerc);
    
    PrintCenterTextAll("%t", "war_start");
    
    for(new client=1; client <= MaxClients; client++) 
    {
        if (IsClientInGame(client) && IsPlayerAlive(client)) SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
    }

    PrintToChatAll("[%s] %t", g_wwarprefix, "war_start");
    
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
    
    if (StrEqual(text, "!krieg") || StrEqual(text, "!war"))
    {
	if(GetConVarInt(g_wenabled) == 1)
	{	
        if (GetTeamClientCount(3) > 0)
        {
            if (RoundLimits == 0)
            {
                if (!IsWar && !StartWar)
                {
                    if (StrContains(voted, steamid, true) == -1)
                    {
                        new playercount = (GetClientCount(true) / 2);
                        
                        votecount++;
                        
                        new Missing = playercount - votecount + 1;
                        
                        Format(voted, sizeof(voted), "%s,%s", voted, steamid);
                        
                        if (votecount > playercount)
                        {
                            StartWar = true;
                            
                            RoundLimits = GetConVarInt(RoundLimitsc);
                            votecount = 0;
                            
                            PrintToChatAll("[%s] %t", g_wwarprefix, "war_next");
                        }
                        else PrintToChatAll("[%s] %i Votes bis Krieg beginnt", g_wwarprefix, Missing);
                        
                    }
                    else PrintToChat(client, "[%s] %t", g_wwarprefix, "war_voted");
                }
                else PrintToChat(client, "[%s] %t", g_wwarprefix, "war_progress");
            }
            else PrintToChat(client, "[%s] Du musst noch %i Runden warten", g_wwarprefix, RoundLimits);
        }
        else PrintToChat(client, "[%s] %t", g_wwarprefix, "war_minct");
    }
	else PrintToChat(client, "[%s] %t", g_wwarprefix, "war_disabled");
	}
}

public OnMapEnd()
{
    IsWar = false;
    StartWar = false;
    votecount = 0;
    WarRound = 0;
    
    voted[0] = '\0';
}