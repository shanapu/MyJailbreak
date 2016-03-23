//includes
#include <cstrike>
#include <sourcemod>
#include <colors>
#include <sdktools>
#include <wardn>
#include <smartjaildoors>
#include <sdkhooks>
#include <autoexecconfig>

//Compiler Options
#pragma semicolon 1

#define PLUGIN_VERSION   "0.x"

ConVar gc_bTagEnabled;

new preparetime;
new roundtime;
new roundtimenormal;
new votecount;
new DuckHuntRound;
new RoundLimits;

new Handle:LimitTimer;
new Handle:DuckHuntTimer;
new Handle:WeaponTimer;
new Handle:DuckHuntMenu;
new Handle:roundtimec;
new Handle:roundtimenormalc;
new Handle:preparetimec;
new Handle:RoundLimitsc;
new Handle:g_wenabled=INVALID_HANDLE;
new Handle:usecvar;

new bool:IsDuckHunt;
new bool:StartDuckHunt;

new String:voted[1500];



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
	LoadTranslations("MyJailbreakWarden.phrases");
	LoadTranslations("MyJailbreakDuckHunt.phrases");
	
	RegConsoleCmd("sm_setduckhunt", SetDuckHunt);
	
	AutoExecConfig_SetFile("MyJailbreak_duckhunt");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_duckhunt_version", "PLUGIN_VERSION", "The version of the SourceMod plugin MyJailBreak - War", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_wenabled = AutoExecConfig_CreateConVar("sm_duckhunt_enable", "1", "0 - disabled, 1 - enable war");
	roundtimec = AutoExecConfig_CreateConVar("sm_duckhunt_roundtime", "5", "Round time for a single war round");
	roundtimenormalc = AutoExecConfig_CreateConVar("sm_noduckhunt_roundtime", "12", "set round time after a war round zour normal mp_roudntime");
	preparetimec = AutoExecConfig_CreateConVar("sm_duckhunt_preparetime", "15", "Time freeze duckhunts");
	RoundLimitsc = AutoExecConfig_CreateConVar("sm_duckhunt_roundsnext", "3", "Rounds until event can be started again.");
	gc_bTagEnabled = AutoExecConfig_CreateConVar("sm_duckhunt_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	AutoExecConfig_CacheConvars();
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	AutoExecConfig(true, "MyJailbreak_duckhunt");

	
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
		SetCvar("sm_noscope_enable", 1);
		SetCvar("dice_enable", 1);
		SetCvar("sm_zombie_enable", 1);
		SetCvar("sm_catch_enable", 1);
		SetCvar("sm_hide_enable", 1);
		SetCvar("sm_ffa_enable", 1);
		SetCvar("sm_beacon_enabled", 0);
		SetCvar("sv_infinite_ammo", 0);
		SetCvar("sm_warden_enable", 1);
		SetCvar("mp_roundtime", roundtimenormal);
		SetCvar("mp_roundtime_hostage", roundtimenormal);
		SetCvar("mp_roundtime_defuse", roundtimenormal);
		CPrintToChatAll("%t %t", "duckhunt_tag" , "duckhunt_end");
		
	}
	if (StartDuckHunt)
	{
	SetCvar("mp_roundtime", roundtime);
	SetCvar("mp_roundtime_hostage", roundtime);
	SetCvar("mp_roundtime_defuse", roundtime);
	}
	
}

public Action SetDuckHunt(int client,int args)
{
	if(GetConVarInt(g_wenabled) == 1)	
	{
	if (warden_iswarden(client) || CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)) 
	{
	if (RoundLimits == 0)
	{
	StartDuckHunt = true;
	RoundLimits = GetConVarInt(RoundLimitsc);
	votecount = 0;
	CPrintToChatAll("%t %t", "duckhunt_tag" , "duckhunt_next");
	}else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_wait", RoundLimits);
	}else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
}



public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

public Action:OnWeaponCanUse(client, weapon)
{
	if(IsDuckHunt == true)
		{

		decl String:sWeapon[32];
		GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));

		if(StrEqual(sWeapon, "weapon_hegrenade") || StrEqual(sWeapon, "weapon_knife") || (GetClientTeam(client) == 3 && StrEqual(sWeapon, "weapon_nova")))
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




public RoundStart(Handle:event, String:name[], bool:dontBroadcast)
{
	if (StartDuckHunt)
	{
		decl String:info1[255], String:info2[255], String:info3[255], String:info4[255], String:info5[255], String:info6[255], String:info7[255], String:info8[255];
		
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_beacon_enabled", 1);
		SetCvar("dice_enable", 0);
		SetCvar("sv_infinite_ammo", 1);
		IsDuckHunt = true;
		DuckHuntRound++;
		StartDuckHunt = false;
		
		DuckHuntMenu = CreatePanel();
		Format(info1, sizeof(info1), "%T", "duckhunt_info_Title", LANG_SERVER);
		SetPanelTitle(DuckHuntMenu, info1);
		DrawPanelText(DuckHuntMenu, "                                   ");
		Format(info2, sizeof(info2), "%T", "duckhunt_info_Line1", LANG_SERVER);
		DrawPanelText(DuckHuntMenu, info2);
		DrawPanelText(DuckHuntMenu, "-----------------------------------");
		Format(info3, sizeof(info3), "%T", "duckhunt_info_Line2", LANG_SERVER);
		DrawPanelText(DuckHuntMenu, info3);
		Format(info4, sizeof(info4), "%T", "duckhunt_info_Line3", LANG_SERVER);
		DrawPanelText(DuckHuntMenu, info4);
		Format(info5, sizeof(info5), "%T", "duckhunt_info_Line4", LANG_SERVER);
		DrawPanelText(DuckHuntMenu, info5);
		Format(info6, sizeof(info6), "%T", "duckhunt_info_Line5", LANG_SERVER);
		DrawPanelText(DuckHuntMenu, info6);
		Format(info7, sizeof(info7), "%T", "duckhunt_info_Line6", LANG_SERVER);
		DrawPanelText(DuckHuntMenu, info7);
		Format(info8, sizeof(info8), "%T", "duckhunt_info_Line7", LANG_SERVER);
		DrawPanelText(DuckHuntMenu, info8);
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
						GivePlayerItem(client, "weapon_nova");
						}
						if (GetClientTeam(client) == 2)
						{
						SetEntityModel(client, "models/chicken/chicken.mdl");
						SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.2);
						SetEntityGravity(client, 0.3);
						SetEntityHealth(client, 150);
						CS_DropWeapon(client, index, true, false);
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
		
						PrintCenterText(client,"%t", "duckhunt_timetounfreeze", preparetime);
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
				SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
				}
			}
		}
	}
	PrintCenterTextAll("%t", "duckhunt_start");
	CPrintToChatAll("%t %t", "duckhunt_tag" , "duckhunt_start");
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
	
	if (StrEqual(text, "!entenjagd") || StrEqual(text, "!duckhunt"))
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
							
							SetCvar("sm_war_enable", 0);
							SetCvar("sm_zombie_enable", 0);
							SetCvar("sm_ffa_enable", 0);
							SetCvar("sm_hide_enable", 0);
							SetCvar("sm_catch_enable", 0);
							SetCvar("sm_noscope_enable", 0);
							RoundLimits = GetConVarInt(RoundLimitsc);
							votecount = 0;
							
							CPrintToChatAll("%t %t", "duckhunt_tag" , "duckhunt_next");
						}
						else CPrintToChatAll("%t %t", "duckhunt_tag" , "duckhunt_need", Missing);
						
					}
					else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_voted");
				}
				else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_progress");
			}
			else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_wait", RoundLimits);
		}
		else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_minct");
	}
	else CPrintToChat(client, "%t %t", "duckhunt_tag" , "duckhunt_disabled");
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
	IsDuckHunt = false;
	StartDuckHunt = false;
	votecount = 0;
	DuckHuntRound = 0;
	
	voted[0] = '\0';
}