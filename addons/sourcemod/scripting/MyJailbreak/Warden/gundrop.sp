//Gun Drop Prevention module for MyJailbreak - Warden

//Includes
#include <sourcemod>
#include <cstrike>
#include <warden>
#include <colors>
#include <autoexecconfig>
#include <myjailbreak>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//ConVars
ConVar gc_bGunPlant;
ConVar gc_bGunRemove;
ConVar gc_fGunRemoveTime;
ConVar gc_iGunSlapDamage;
ConVar gc_bGunSlap;
ConVar gc_bGunNoDrop;
ConVar gc_fAllowDropTime;

//Bools
bool g_bWeaponDropped[MAXPLAYERS+1] = false;
bool g_bAllowDrop;

public void GunDropPrevention_OnPluginStart()
{
	//AutoExecConfig
	gc_bGunPlant = AutoExecConfig_CreateConVar("sm_warden_gunplant", "1", "0 - disabled, 1 - enable Gun plant prevention", _, true,  0.0, true, 1.0);
	gc_fAllowDropTime = AutoExecConfig_CreateConVar("sm_warden_allow_time", "15.0", "Time in seconds CTs allowed to drop weapon on round beginn.", _, true,  0.1);
	gc_bGunNoDrop = AutoExecConfig_CreateConVar("sm_warden_gunnodrop", "0", "0 - disabled, 1 - disallow gun dropping for ct", _, true,  0.0, true, 1.0);
	gc_bGunRemove = AutoExecConfig_CreateConVar("sm_warden_gunremove", "1", "0 - disabled, 1 - remove planted guns", _, true,  0.0, true, 1.0);
	gc_fGunRemoveTime = AutoExecConfig_CreateConVar("sm_warden_gunremove_time", "5.0", "Time in seconds to pick up gun again before.", _, true,  0.1);
	gc_bGunSlap = AutoExecConfig_CreateConVar("sm_warden_gunslap", "1", "0 - disabled, 1 - Slap the CT for dropping a gun", _, true,  0.0, true, 1.0);
	gc_iGunSlapDamage = AutoExecConfig_CreateConVar("sm_warden_gunslap_dmg", "10", "Amoung of HP losing on slap for dropping a gun", _, true,  0.0);
	
	//Hooks
	HookEvent("round_start", GunDropPrevention_RoundStart);
}

//GunPlant

public void GunDropPrevention_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_bAllowDrop = true;
	
	CreateTimer (gc_fAllowDropTime.FloatValue, Timer_AllowDrop);
}

public Action CS_OnCSWeaponDrop(int client, int weapon)
{
	if(gc_bPlugin.BoolValue)
	{
		if(gc_bGunPlant.BoolValue)
		{
			if(GetClientTeam(client) == CS_TEAM_CT)
			{
				if(!g_bAllowDrop && !IsClientInLastRequest(client))
				{
					if (g_bWeaponDropped[client]) 
						return Plugin_Handled;
						
					if(gc_bGunNoDrop.BoolValue)
						return Plugin_Handled;
						
				//	g_iWeaponDrop[client] = weapon;
					
					Handle hData = CreateDataPack();
					WritePackCell(hData, client);
					WritePackCell(hData, weapon);
					
					
					
					if(IsValidEntity(weapon))
					{
						if (!g_bWeaponDropped[client]) CreateTimer(0.1, Timer_DroppedWeapon, hData, TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action Timer_DroppedWeapon(Handle timer, Handle hData)
{
	ResetPack(hData);
	int client = ReadPackCell(hData);
	int iWeapon = ReadPackCell(hData);
	
	if(IsValidEdict(iWeapon))
	{
		if (Entity_GetOwner(iWeapon) == -1)
		{
			if(IsValidClient(client, false, false))  // && !IsClientInLastRequest(client)
			{
				char g_sWeaponName[80];
				
				GetEntityClassname(iWeapon, g_sWeaponName, sizeof(g_sWeaponName));
				ReplaceString(g_sWeaponName, sizeof(g_sWeaponName), "weapon_", "", false); 
				g_bWeaponDropped[client] = true;
				
				Handle hData2 = CreateDataPack();
				WritePackCell(hData2, client);
				WritePackCell(hData2, iWeapon);
				
				CPrintToChat(client, "%t %t", "warden_tag" , "warden_noplant", client , g_sWeaponName);
				if(g_iWarden != -1) CPrintToChat(g_iWarden, "%t %t", "warden_tag" , "warden_gunplant", client , g_sWeaponName);
				if((g_iWarden != -1) && gc_bBetterNotes.BoolValue) PrintHintText(g_iWarden, "%t", "warden_gunplant_nc", client , g_sWeaponName);
				if(gc_bGunRemove.BoolValue) CreateTimer(gc_fGunRemoveTime.FloatValue, Timer_RemoveWeapon, hData2, TIMER_FLAG_NO_MAPCHANGE);
				if(gc_bGunSlap.BoolValue) SlapPlayer(client, gc_iGunSlapDamage.IntValue, true);
			}
		}
	}
}

public Action Timer_RemoveWeapon(Handle timer, Handle hData2)
{
	ResetPack(hData2);
	int client = ReadPackCell(hData2);
	int iWeapon = ReadPackCell(hData2);
	
	if(IsValidEdict(iWeapon))
	{
		if (Entity_GetOwner(iWeapon) == -1)
		{
			AcceptEntityInput(iWeapon, "Kill");
		}
	}
	g_bWeaponDropped[client] = false;
}

public Action Timer_AllowDrop(Handle timer)
{
	g_bAllowDrop = false;
}

public void GunDropPrevention_OnAvailableLR(int Announced)
{
	g_bAllowDrop = true;
}