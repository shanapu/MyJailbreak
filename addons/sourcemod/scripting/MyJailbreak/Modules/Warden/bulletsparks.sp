/*
 * MyJailbreak - Warden - Bullet Sparks Module.
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
ConVar gc_bBulletSparks;
ConVar gc_bBulletSparksDeputy;
ConVar gc_sAdminFlagBulletSparks;


//Booleans
bool g_bBulletSparks[MAXPLAYERS+1] = true;


//Strings
char g_sAdminFlagBulletSparks[32];


//Start
public void BulletSparks_OnPluginStart()
{
	//Client commands
	RegConsoleCmd("sm_sparks", Command_BulletSparks, "Allows Warden to toggle on/off the wardens bullet sparks");
	
	
	//AutoExecConfig
	gc_bBulletSparks = AutoExecConfig_CreateConVar("sm_warden_bulletsparks", "1", "0 - disabled, 1 - enable Warden bulletimpact sparks", _, true,  0.0, true, 1.0);
	gc_bBulletSparksDeputy = AutoExecConfig_CreateConVar("sm_warden_bulletsparks_deputy", "1", "0 - disabled, 1 - enable smaller bulletimpact sparks for deputy, too", _, true,  0.0, true, 1.0);
	gc_sAdminFlagBulletSparks = AutoExecConfig_CreateConVar("sm_warden_bulletsparks_flag", "", "Set flag for admin/vip to get warden/deputy bulletimpact sparks. No flag = feature is available for all players!");
	
	
	//Hooks 
	HookConVarChange(gc_sAdminFlagBulletSparks, BulletSparks_OnSettingChanged);
	HookEvent("bullet_impact", BulletSparks_Event_BulletImpact);
	
	
	//FindConVar
	gc_sAdminFlagBulletSparks.GetString(g_sAdminFlagBulletSparks , sizeof(g_sAdminFlagBulletSparks));
}


public int BulletSparks_OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sAdminFlagBulletSparks)
	{
		strcopy(g_sAdminFlagBulletSparks, sizeof(g_sAdminFlagBulletSparks), newValue);
	}
}


/******************************************************************************
                   COMMANDS
******************************************************************************/


public Action Command_BulletSparks(int client, int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bBulletSparks.BoolValue)
		{
			if (IsClientWarden(client) || (IsClientDeputy(client) && gc_bBulletSparksDeputy.BoolValue))
			{
				if (CheckVipFlag(client, g_sAdminFlagBulletSparks))
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


/******************************************************************************
                   EVENTS
******************************************************************************/


public Action BulletSparks_Event_BulletImpact(Event event, char [] sName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if (!gc_bPlugin.BoolValue || !gc_bBulletSparks.BoolValue || (!IsClientWarden(client) || (!IsClientDeputy(client) && gc_bBulletSparksDeputy.BoolValue)) || !g_bBulletSparks[client] || !CheckVipFlag(client, g_sAdminFlagBulletSparks))
		return Plugin_Continue;
	
	float startpos[3];
	float dir[3] = {0.0, 0.0, 0.0};
	
	startpos[0] = event.GetFloat("x");
	startpos[1] = event.GetFloat("y");
	startpos[2] = event.GetFloat("z");
	
	if (warden_iswarden(client))TE_SetupSparks(startpos, dir, 2500, 500);
	if (warden_deputy_isdeputy(client))TE_SetupSparks(startpos, dir, 1500, 300);
	
	TE_SendToAll();

	return Plugin_Continue;
}


/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/


public void BulletSparks_OnClientPutInServer(int client)
{
	g_bBulletSparks[client] = true;
}
