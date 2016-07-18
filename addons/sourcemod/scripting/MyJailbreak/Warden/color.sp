//Warden Color module for MyJailbreak - Warden

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
ConVar gc_bColor;
ConVar gc_iWardenColorRed;
ConVar gc_iWardenColorGreen;
ConVar gc_iWardenColorBlue;
ConVar gc_bWardenColorRandom;

public void Color_OnPluginStart()
{
	//AutoExecConfig
	gc_bColor = AutoExecConfig_CreateConVar("sm_warden_color_enable", "1", "0 - disabled, 1 - enable warden colored", _, true,  0.0, true, 1.0);
	gc_bWardenColorRandom = AutoExecConfig_CreateConVar("sm_warden_color_random", "1", "0 - disabled, 1 - enable warden rainbow colored", _, true,  0.0, true, 1.0);
	gc_iWardenColorRed = AutoExecConfig_CreateConVar("sm_warden_color_red", "0","What color to turn the warden into (set R, G and B values to 255 to disable) (Rgb): x - red value", _, true, 0.0, true, 255.0);
	gc_iWardenColorGreen = AutoExecConfig_CreateConVar("sm_warden_color_green", "0","What color to turn the warden into (rGb): x - green value", _, true, 0.0, true, 255.0);
	gc_iWardenColorBlue = AutoExecConfig_CreateConVar("sm_warden_color_blue", "255","What color to turn the warden into (rgB): x - blue value", _, true, 0.0, true, 255.0);
}

public Action Timer_WardenFixColor(Handle timer,any client)
{
	if(IsValidClient(client, false, false))
	{
		if(IsClientWarden(client))
		{
			if(gc_bPlugin.BoolValue)
			{
				if(gc_bColor.BoolValue)
				{
					if(gc_bWardenColorRandom.BoolValue)
					{
						int i = GetRandomInt(1, 7);
						SetEntityRenderColor(client, g_iColors[i][0], g_iColors[i][1], g_iColors[i][2], g_iColors[i][3]);
					}
					else SetEntityRenderColor(client, gc_iWardenColorRed.IntValue, gc_iWardenColorGreen.IntValue, gc_iWardenColorBlue.IntValue, 255);
				}
			}
		}
		else
		{
			SetEntityRenderColor(client);
			return Plugin_Stop;
		}
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public void Color_OnWardenCreation(int client)
{
	CreateTimer(1.0, Timer_WardenFixColor, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public void Color_OnWardenRemoved(int client)
{
	CreateTimer(0.1, Timer_RemoveColor, client);
}