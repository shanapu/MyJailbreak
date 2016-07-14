// Bullet Sparks module for MyJailbreak - Warden

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
ConVar gc_bBulletSparks;
ConVar gc_sAdminFlagBulletSparks;

//Bools
bool g_bBulletSparks[MAXPLAYERS+1] = true;

//Strings
char g_sAdminFlagBulletSparks[32];


public void BulletSparks_OnPluginStart()
{
	//Client commands
	RegConsoleCmd("sm_sparks", BulletSparks, "Allows Warden to toggle on/off the wardens bullet sparks");
	
	//AutoExecConfig
	gc_bBulletSparks = AutoExecConfig_CreateConVar("sm_warden_bulletsparks", "1", "0 - disabled, 1 - enable Warden bulletimpact sparks", _, true,  0.0, true, 1.0);
	gc_sAdminFlagBulletSparks = AutoExecConfig_CreateConVar("sm_warden_bulletsparks_flag", "", "Set flag for admin/vip to get warden bulletimpact sparks. No flag = feature is available for all players!");
	
	//Hooks 
	HookConVarChange(gc_sAdminFlagBulletSparks, BulletSparks_OnSettingChanged);
	HookEvent("bullet_impact", BulletSparks_BulletImpact);
	
	//FindConVar
	gc_sAdminFlagBulletSparks.GetString(g_sAdminFlagBulletSparks , sizeof(g_sAdminFlagBulletSparks));
}

public int BulletSparks_OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sAdminFlagBulletSparks)
	{
		strcopy(g_sAdminFlagBulletSparks, sizeof(g_sAdminFlagBulletSparks), newValue);
	}
}

public Action BulletSparks_BulletImpact(Handle hEvent, char [] sName, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	
	if (!gc_bPlugin.BoolValue || !gc_bBulletSparks.BoolValue || !warden_iswarden(iClient) || !g_bBulletSparks[iClient] || !CheckVipFlag(iClient,g_sAdminFlagBulletSparks))
		return Plugin_Continue;
	
	float startpos[3];
	float dir[3] = {0.0, 0.0, 0.0};
	
	startpos[0] = GetEventFloat(hEvent, "x");
	startpos[1] = GetEventFloat(hEvent, "y");
	startpos[2] = GetEventFloat(hEvent, "z");
	
	TE_SetupSparks(startpos, dir, 2500, 500);
	
	TE_SendToAll();

	return Plugin_Continue;
}

public Action BulletSparks(int client, int args)
{
	if(gc_bPlugin.BoolValue)
	{
		if(gc_bBulletSparks.BoolValue)
		{
			if (client == g_iWarden)
			{
				if(CheckVipFlag(client,g_sAdminFlagBulletSparks))
				{
					if (!g_bBulletSparks[client])
					{
						g_bBulletSparks[client] = true;
						CPrintToChat(client, "%t %t", "warden_tag" , "warden_bulletmarkon");
					}
					else if (g_bBulletSparks[client])
					{
						g_bBulletSparks[client] = false;
						CPrintToChat(client, "%t %t", "warden_tag" , "warden_bulletmarkoff");
					}
				}
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden"); 
		}
	}
}

public void BulletSparks_OnClientPutInServer(int client)
{
	g_bBulletSparks[client] = true;
}
