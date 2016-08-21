/*
 * MyJailbreak - Warden - Handcuffs Module.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
 *
 * This file is part of the MyJailbreak SourceMod Plugin.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */


/******************************************************************************
                   STARTUP
******************************************************************************/


//Includes
#include <myjailbreak> //... all other includes in myjailbreak.inc


//Compiler Options
#pragma semicolon 1
#pragma newdecls required


//Console Variables
ConVar gc_bHandCuff;
ConVar gc_iHandCuffsNumber;
ConVar gc_iHandCuffsDistance;
ConVar gc_bHandCuffLR;
ConVar gc_bHandCuffCT;
ConVar gc_sAdminFlagCuffs;
ConVar gc_sSoundBreakCuffsPath;
ConVar gc_sSoundUnLockCuffsPath;
ConVar gc_sSoundCuffsPath;
ConVar gc_sOverlayCuffsPath;
ConVar gc_fUnLockTimeMax;
ConVar gc_fUnLockTimeMin;
ConVar gc_iPaperClipUnLockChance;
ConVar gc_iPaperClipGetChance;


//Booleans
bool g_bCuffed[MAXPLAYERS+1] = false;


//Integers
int g_iPlayerHandCuffs[MAXPLAYERS+1];
int g_iCuffed = 0;


//Strings
char g_sSoundCuffsPath[256];
char g_sOverlayCuffsPath[256];
char g_sAdminFlagCuffs[32];
char g_sSoundBreakCuffsPath[256];
char g_sSoundUnLockCuffsPath[256];
char g_sEquipWeapon[MAXPLAYERS+1][32];


//Info
public void HandCuffs_OnPluginStart()
{
	//AutoExecConfig
	gc_bHandCuff = AutoExecConfig_CreateConVar("sm_warden_handcuffs", "1", "0 - disabled, 1 - enable handcuffs", _, true,  0.0, true, 1.0);
	gc_iHandCuffsNumber = AutoExecConfig_CreateConVar("sm_warden_handcuffs_number", "2", "How many handcuffs a warden got?", _, true,  1.0);
	gc_iHandCuffsDistance = AutoExecConfig_CreateConVar("sm_warden_handcuffs_distance", "2", "How many meters distance from warden to handcuffed T to pick up?", _, true,  1.0);
	gc_bHandCuffLR = AutoExecConfig_CreateConVar("sm_warden_handcuffs_lr", "1", "0 - disabled, 1 - free cuffed terrorists on LR", _, true,  0.0, true, 1.0);
	gc_bHandCuffCT = AutoExecConfig_CreateConVar("sm_warden_handcuffs_ct", "1", "0 - disabled, 1 - Warden can also handcuff CTs", _, true,  0.0, true, 1.0);
	gc_fUnLockTimeMax = AutoExecConfig_CreateConVar("sm_warden_handcuffs_unlock_maxtime", "35.0", "Time in seconds Ts need free themself with a paperclip.", _, true, 0.1);
	gc_iPaperClipGetChance = AutoExecConfig_CreateConVar("sm_warden_handcuffs_paperclip_chance", "5", "Set the chance (1:x) a cuffed Terroris get a paperclip to free themself", _, true,  1.0);
	gc_iPaperClipUnLockChance = AutoExecConfig_CreateConVar("sm_warden_handcuffs_unlock_chance", "3", "Set the chance (1:x) a cuffed Terroris who has a paperclip to free themself", _, true,  1.0);
	gc_fUnLockTimeMin = AutoExecConfig_CreateConVar("sm_warden_handcuffs_unlock_mintime", "15.0", "Min. Time in seconds Ts need free themself with a paperclip.", _, true,  1.0);
	gc_fUnLockTimeMax = AutoExecConfig_CreateConVar("sm_warden_handcuffs_unlock_maxtime", "35.0", "Max. Time in seconds Ts need free themself with a paperclip.", _, true,  1.0);
	gc_sAdminFlagCuffs = AutoExecConfig_CreateConVar("sm_warden_handcuffs_flag", "", "Set flag for admin/vip must have to get access to paperclip. No flag = feature is available for all players!");
	gc_sOverlayCuffsPath = AutoExecConfig_CreateConVar("sm_warden_overlays_cuffs", "overlays/MyJailbreak/cuffs" , "Path to the cuffs Overlay DONT TYPE .vmt or .vft");
	gc_sSoundCuffsPath = AutoExecConfig_CreateConVar("sm_warden_sounds_cuffs", "music/MyJailbreak/cuffs.mp3", "Path to the soundfile which should be played for cuffed player.");
	gc_sSoundBreakCuffsPath = AutoExecConfig_CreateConVar("sm_warden_sounds_breakcuffs", "music/MyJailbreak/breakcuffs.mp3", "Path to the soundfile which should be played for break cuffs.");
	gc_sSoundUnLockCuffsPath = AutoExecConfig_CreateConVar("sm_warden_sounds_unlock", "music/MyJailbreak/unlock.mp3", "Path to the soundfile which should be played for unlocking cuffs.");
	
	
	//Hooks
	HookEvent("round_start", HandCuffs_Event_RoundStart);
	HookEvent("round_end", HandCuffs_Event_RoundEnd);
	HookEvent("player_death", HandCuffs_Event_PlayerDeath);
	HookEvent("item_equip", HandCuffs_Event_ItemEquip);
	HookEvent("weapon_fire", HandCuffs_Event_WeaponFire);
	HookConVarChange(gc_sSoundCuffsPath, HandCuffs_OnSettingChanged);
	HookConVarChange(gc_sSoundBreakCuffsPath, HandCuffs_OnSettingChanged);
	HookConVarChange(gc_sSoundUnLockCuffsPath, HandCuffs_OnSettingChanged);
	HookConVarChange(gc_sOverlayCuffsPath, HandCuffs_OnSettingChanged);
	HookConVarChange(gc_sAdminFlagCuffs, HandCuffs_OnSettingChanged);
	
	
	//FindConVar
	gc_sSoundCuffsPath.GetString(g_sSoundCuffsPath, sizeof(g_sSoundCuffsPath));
	gc_sSoundBreakCuffsPath.GetString(g_sSoundBreakCuffsPath, sizeof(g_sSoundBreakCuffsPath));
	gc_sSoundUnLockCuffsPath.GetString(g_sSoundUnLockCuffsPath, sizeof(g_sSoundUnLockCuffsPath));
	gc_sOverlayCuffsPath.GetString(g_sOverlayCuffsPath , sizeof(g_sOverlayCuffsPath));
	gc_sAdminFlagCuffs.GetString(g_sAdminFlagCuffs , sizeof(g_sAdminFlagCuffs));
}


public int HandCuffs_OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sSoundCuffsPath)
	{
		strcopy(g_sSoundCuffsPath, sizeof(g_sSoundCuffsPath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundCuffsPath);
	}
	else if(convar == gc_sSoundBreakCuffsPath)
	{
		strcopy(g_sSoundBreakCuffsPath, sizeof(g_sSoundBreakCuffsPath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundBreakCuffsPath);
	}
	else if(convar == gc_sSoundUnLockCuffsPath)
	{
		strcopy(g_sSoundUnLockCuffsPath, sizeof(g_sSoundUnLockCuffsPath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundUnLockCuffsPath);
	}
	else if(convar == gc_sOverlayCuffsPath)
	{
		strcopy(g_sOverlayCuffsPath, sizeof(g_sOverlayCuffsPath), newValue);
		if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayCuffsPath);
	}
	else if(convar == gc_sAdminFlagCuffs)
	{
		strcopy(g_sAdminFlagCuffs, sizeof(g_sAdminFlagCuffs), newValue);
	}
}


/******************************************************************************
                   EVENTS
******************************************************************************/


public void HandCuffs_Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if(gc_bStayWarden.BoolValue && g_iWarden != -1)
	{
		if (gc_bHandCuff.BoolValue && !IsLR) GivePlayerItem(g_iWarden, "weapon_taser");
	}
	g_iCuffed = 0;
	
	LoopClients(i)
	{
		g_iPlayerHandCuffs[i] = gc_iHandCuffsNumber.IntValue;
		g_bCuffed[i] = false;
	}
}


public void HandCuffs_Event_ItemEquip(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	char weapon[32];
	event.GetString("item", weapon, sizeof(weapon));
	g_sEquipWeapon[client] = weapon;
	
	if (StrEqual(weapon, "taser") && warden_iswarden(client) && (g_iPlayerHandCuffs[client] != 0)) PrintCenterText(client, "%t", "warden_cuffs");
}


public void HandCuffs_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid")); // Get the dead clients id
	
	if(g_bCuffed[client])
	{
		g_iCuffed--;
		g_bCuffed[client] = false;
		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
		CreateTimer( 0.0, DeleteOverlay, client );
	}
}


public void HandCuffs_Event_WeaponFire(Event event, char [] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if(gc_bPlugin.BoolValue && gc_bHandCuff.BoolValue && warden_iswarden(client) && ((g_iPlayerHandCuffs[client] != 0) || ((g_iPlayerHandCuffs[client] == 0) && (g_iCuffed > 0))))
	{
		char sWeapon[64];
		event.GetString("weapon", sWeapon, sizeof(sWeapon));
		if (StrEqual(sWeapon, "weapon_taser"))
		{
			SetPlayerWeaponAmmo(client, Client_GetActiveWeapon(client), _, 2);
		}
	}
}


public void HandCuffs_Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	LoopClients(i) if(g_bCuffed[i]) FreeEm(i, 0);
}


/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/


public Action HandCuffs_OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if ((buttons & IN_ATTACK2) && IsClientWarden(client) && gc_bPlugin.BoolValue)
	{
		if (gc_bHandCuff.BoolValue && (StrEqual(g_sEquipWeapon[client], "taser")))
		{
			int Target = GetClientAimTarget(client, true);
			
			if (IsValidClient(Target, true, false) && (g_bCuffed[Target] == true))
			{
				float distance = Entity_GetDistance(client, Target);
				distance = Math_UnitsToMeters(distance);
				
				if((gc_iHandCuffsDistance.IntValue > distance) && !Client_IsLookingAtWall(client, Entity_GetDistance(client, Target)+40.0))
				{
					float origin[3];
					GetClientAbsOrigin(client, origin);
					float location[3];
					GetClientEyePosition(client, location);
					float ang[3];
					GetClientEyeAngles(client, ang);
					float location2[3];
					location2[0] = (location[0]+(100*((Cosine(DegToRad(ang[1]))) * (Cosine(DegToRad(ang[0]))))));
					location2[1] = (location[1]+(100*((Sine(DegToRad(ang[1]))) * (Cosine(DegToRad(ang[0]))))));
					ang[0] -= (2*ang[0]);
					location2[2] = origin[2] += 5.0;
					
					TeleportEntity(Target, location2, NULL_VECTOR, NULL_VECTOR);
				}
			}
		}
	}
}


public Action HandCuffs_OnTakedamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(!IsValidClient(victim, true, false) || attacker == victim || !IsValidClient(attacker, true, false)) return Plugin_Continue;
	
	char sWeapon[32];
	if(IsValidEntity(weapon)) GetEntityClassname(weapon, sWeapon, sizeof(sWeapon));
	
	if(g_bCuffed[attacker]) return Plugin_Handled;
	
	if(!gc_bPlugin.BoolValue || !gc_bHandCuff.BoolValue || !warden_iswarden(attacker) || !IsValidEdict(weapon) || (!gc_bHandCuffCT.BoolValue && (GetClientTeam(victim) == CS_TEAM_CT)))
	{
		return Plugin_Continue;
	}
	
	if(!StrEqual(sWeapon, "weapon_taser")) return Plugin_Continue;
	
	if((g_iPlayerHandCuffs[attacker] == 0) && (g_iCuffed == 0)) return Plugin_Continue;
		
	if(g_bCuffed[victim])
	{
		FreeEm(victim, attacker);
	}
	else CuffsEm(victim, attacker);
	
	return Plugin_Handled;
}


public void HandCuffs_OnAvailableLR(int Announced)
{
	LoopClients(i)
	{
		g_iPlayerHandCuffs[i] = 0;
		if(gc_bHandCuffLR.BoolValue && g_bCuffed[i]) FreeEm(i, 0);
	}
	StripZeus(g_iWarden);
}


public void warden_OnWardenCreated(int client)
{
	if (gc_bHandCuff.BoolValue && !IsLR) GivePlayerItem(client, "weapon_taser");
}


public void warden_OnWardenRemoved(int client)
{
	StripZeus(g_iWarden);
}


public void HandCuffs_OnMapStart()
{
	if(gc_bSounds.BoolValue)
	{
		PrecacheSoundAnyDownload(g_sSoundCuffsPath);
		PrecacheSoundAnyDownload(g_sSoundBreakCuffsPath);
		PrecacheSoundAnyDownload(g_sSoundUnLockCuffsPath);
	}
	if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayCuffsPath);
}


public void HandCuffs_OnClientDisconnect(int client)
{
	if(g_bCuffed[client]) g_iCuffed--;
}


public void HandCuffs_OnMapEnd()
{
	LoopClients(i)
	{
		if(g_bCuffed[i]) FreeEm(i, 0);
	}
}


public void HandCuffs_OnConfigsExecuted()
{
	g_iKillKind = gc_iRandomMode.IntValue;
}


public void HandCuffs_OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, HandCuffs_OnTakedamage);
}


/******************************************************************************
                   FUNCTIONS
******************************************************************************/


public Action CuffsEm(int client, int attacker)
{
	if(g_iPlayerHandCuffs[attacker] > 0)
	{
		SetEntityMoveType(client, MOVETYPE_NONE);
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
		SetEntityRenderColor(client, 0, 190, 0, 255);
		StripAllPlayerWeapons(client);
		GivePlayerItem(client, "weapon_knife");
		g_bCuffed[client] = true;
		ShowOverlay(client, g_sOverlayCuffsPath, 0.0);
		g_iPlayerHandCuffs[attacker]--;
		g_iCuffed++;
		if(gc_bSounds)EmitSoundToAllAny(g_sSoundCuffsPath);
		
		CPrintToChatAll("%t %t", "warden_tag" , "warden_cuffson", attacker, client);
		CPrintToChat(attacker, "%t %t", "warden_tag" , "warden_cuffsgot", g_iPlayerHandCuffs[attacker]);
		if(CheckVipFlag(client,g_sAdminFlagCuffs))
		{
			CreateTimer (2.5, HasPaperClip, client);
		}
	}
	
}


public Action FreeEm(int client, int attacker)
{
	SetEntityMoveType(client, MOVETYPE_WALK);
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	SetEntityRenderColor(client, 255, 255, 255, 255);
	g_bCuffed[client] = false;
	CreateTimer( 0.0, DeleteOverlay, client );
	g_iCuffed--;
	if(gc_bSounds)StopSoundAny(client,SNDCHAN_AUTO,g_sSoundUnLockCuffsPath);
	if((attacker != 0) && (g_iCuffed == 0) && (g_iPlayerHandCuffs[attacker] < 1)) SetPlayerWeaponAmmo(attacker, Client_GetActiveWeapon(attacker), _, 0);
	if(attacker != 0) CPrintToChatAll("%t %t", "warden_tag" , "warden_cuffsoff", attacker, client);
}


/******************************************************************************
                   TIMER
******************************************************************************/


public Action HasPaperClip(Handle timer, int client)
{
	if(g_bCuffed[client])
	{
		int paperclip = GetRandomInt(1,gc_iPaperClipGetChance.IntValue);
		float unlocktime = GetRandomFloat(gc_fUnLockTimeMin.FloatValue, gc_fUnLockTimeMax.FloatValue);
		if(paperclip == 1)
		{
			CPrintToChat(client, "%t", "warden_gotpaperclip");
			PrintCenterText(client, "%t", "warden_gotpaperclip");
			CreateTimer (unlocktime, BreakTheseCuffs, client);
			if(gc_bSounds)EmitSoundToClientAny(client, g_sSoundUnLockCuffsPath);
		}
	}
}


public Action BreakTheseCuffs(Handle timer, int client)
{
	if(IsValidClient(client,false,false) && g_bCuffed[client])
	{
		int unlocked = GetRandomInt(1,gc_iPaperClipUnLockChance.IntValue);
		if(unlocked == 1)
		{
			CPrintToChat(client, "%t", "warden_unlock");
			PrintCenterText(client, "%t", "warden_unlock");
			if(gc_bSounds)EmitSoundToAllAny(g_sSoundBreakCuffsPath);
			SetEntityMoveType(client, MOVETYPE_WALK);
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
			SetEntityRenderColor(client, 255, 255, 255, 255);
			g_bCuffed[client] = false;
			CreateTimer( 0.0, DeleteOverlay, client );
			g_iCuffed--;
		}
		else
		{
			CPrintToChat(client, "%t", "warden_brokepaperclip");
			PrintCenterText(client, "%t", "warden_brokepaperclip");
		}
	}
}


/******************************************************************************
                   STOCKS
******************************************************************************/


stock int StripZeus(int client)
{
	if(IsValidClient(client, true, false))
	{
		char sWeapon[64];
		FakeClientCommand(client,"use weapon_taser");
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon != -1)
		{
			GetEntityClassname(weapon, sWeapon, sizeof(sWeapon));
			if (StrEqual(sWeapon, "weapon_taser"))
			{ 
				SDKHooks_DropWeapon(client, weapon, NULL_VECTOR, NULL_VECTOR); 
				AcceptEntityInput(weapon, "Kill");
			}
		}
	}
}