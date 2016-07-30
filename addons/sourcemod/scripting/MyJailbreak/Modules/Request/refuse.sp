/*
 * MyJailbreak - Request - Refuse Module.
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
ConVar gc_fRefuseTime;
ConVar gc_bRefuse;
ConVar gc_bWardenAllowRefuse;
ConVar gc_iRefuseLimit;
ConVar gc_iRefuseColorRed;
ConVar gc_iRefuseColorGreen;
ConVar gc_iRefuseColorBlue;
ConVar gc_sSoundRefusePath;
ConVar gc_sSoundRefuseStopPath;
ConVar gc_sCustomCommandRefuse;
ConVar gc_sAdminFlagRefuse;


//Booleans
bool g_bRefused[MAXPLAYERS+1];
bool g_bAllowRefuse;


//Integers
int g_iRefuseCounter[MAXPLAYERS+1];
int g_iCountStopTime;


//Handles
Handle RefuseTimer[MAXPLAYERS+1];
Handle RefusePanel;
Handle AllowRefuseTimer;


//Strings
char g_sSoundRefusePath[256];
char g_sSoundRefuseStopPath[256];
char g_sCustomCommandRefuse[64];
char g_sAdminFlagRefuse[32];


//Start
public void Refuse_OnPluginStart()
{
	//Client commands
	RegConsoleCmd("sm_refuse", Command_refuse, "Allows the Warden start refusing time and Terrorist to refuse a game");
	
	
	//AutoExecConfig
	gc_bRefuse = AutoExecConfig_CreateConVar("sm_refuse_enable", "1", "0 - disabled, 1 - enable Refuse");
	gc_sCustomCommandRefuse = AutoExecConfig_CreateConVar("sm_refuse_cmd", "ref", "Set your custom chat command for Refuse. no need for sm_ or !");
	gc_bWardenAllowRefuse = AutoExecConfig_CreateConVar("sm_refuse_allow", "0", "0 - disabled, 1 - Warden must allow !refuse before T can use it");
	gc_iRefuseLimit = AutoExecConfig_CreateConVar("sm_refuse_limit", "1", "Сount how many times you can use the command");
	gc_fRefuseTime = AutoExecConfig_CreateConVar("sm_refuse_time", "5.0", "Time the player gets to refuse after warden open refuse with !refuse / colortime");
	gc_iRefuseColorRed = AutoExecConfig_CreateConVar("sm_refuse_color_red", "0","What color to turn the refusing Terror into (set R, G and B values to 255 to disable) (Rgb): x - red value", _, true, 0.0, true, 255.0);
	gc_iRefuseColorGreen = AutoExecConfig_CreateConVar("sm_refuse_color_green", "250","What color to turn the refusing Terror into (rGb): x - green value", _, true, 0.0, true, 255.0);
	gc_iRefuseColorBlue = AutoExecConfig_CreateConVar("sm_refuse_color_blue", "250","What color to turn the refusing Terror into (rgB): x - blue value", _, true, 0.0, true, 255.0);
	gc_sSoundRefusePath = AutoExecConfig_CreateConVar("sm_refuse_sound", "music/MyJailbreak/refuse.mp3", "Path to the soundfile which should be played for a refusing.");
	gc_sSoundRefuseStopPath = AutoExecConfig_CreateConVar("sm_refuse_stop_sound", "music/MyJailbreak/stop.mp3", "Path to the soundfile which should be played after a refusing.");
	gc_sAdminFlagRefuse = AutoExecConfig_CreateConVar("sm_refuse_flag", "a", "Set flag for admin/vip to get one more refuse. No flag = feature is available for all players!");
	
	
	//Hooks 
	HookEvent("round_start", Refuse_Event_RoundStart);
	HookConVarChange(gc_sSoundRefusePath, Refuse_OnSettingChanged);
	HookConVarChange(gc_sSoundRefuseStopPath, Refuse_OnSettingChanged);
	HookConVarChange(gc_sCustomCommandRefuse, Refuse_OnSettingChanged);
	HookConVarChange(gc_sAdminFlagRefuse, Refuse_OnSettingChanged);
	
	
	//FindConVar
	gc_sSoundRefusePath.GetString(g_sSoundRefusePath, sizeof(g_sSoundRefusePath));
	gc_sSoundRefuseStopPath.GetString(g_sSoundRefuseStopPath, sizeof(g_sSoundRefuseStopPath));
	gc_sCustomCommandRefuse.GetString(g_sCustomCommandRefuse , sizeof(g_sCustomCommandRefuse));
	gc_sAdminFlagRefuse.GetString(g_sAdminFlagRefuse , sizeof(g_sAdminFlagRefuse));
}


public int Refuse_OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sSoundRefusePath)
	{
		strcopy(g_sSoundRefusePath, sizeof(g_sSoundRefusePath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundRefusePath);
	}
	else if(convar == gc_sSoundRefuseStopPath)
	{
		strcopy(g_sSoundRefuseStopPath, sizeof(g_sSoundRefuseStopPath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundRefuseStopPath);
	}
	else if(convar == gc_sCustomCommandRefuse)
	{
		strcopy(g_sCustomCommandRefuse, sizeof(g_sCustomCommandRefuse), newValue);
		char sBufferCMD[64];
		Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommandRefuse);
		if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
			RegConsoleCmd(sBufferCMD, Command_refuse, "Allows the Warden start refusing time and Terrorist to refuse a game");
	}
	else if(convar == gc_sAdminFlagRefuse)
	{
		strcopy(g_sAdminFlagRefuse, sizeof(g_sAdminFlagRefuse), newValue);
	}
}


/******************************************************************************
                   COMMANDS
******************************************************************************/


public Action Command_refuse(int client, int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bRefuse.BoolValue)
		{
			if(warden_iswarden(client) && gc_bWardenAllowRefuse.BoolValue)
			{
				if(!g_bAllowRefuse)
				{
					g_bAllowRefuse = true;
					AllowRefuseTimer = CreateTimer(1.0, Timer_NoAllowRefuse, _, TIMER_REPEAT);
					CPrintToChatAll("%t %t", "request_tag", "request_openrefuse");
				}
			}
			if(!warden_iswarden(client))
			{
				if (GetClientTeam(client) == CS_TEAM_T && IsPlayerAlive(client))
				{
					if (RefuseTimer[client] == null)
					{
						if(g_bAllowRefuse || !gc_bWardenAllowRefuse.BoolValue)
						{
							if (g_iRefuseCounter[client] < gc_iRefuseLimit.IntValue)
							{
								g_iRefuseCounter[client]++;
								g_bRefused[client] = true;
								SetEntityRenderColor(client, gc_iRefuseColorRed.IntValue, gc_iRefuseColorGreen.IntValue, gc_iRefuseColorBlue.IntValue, 255);
								CPrintToChatAll("%t %t", "request_tag", "request_refusing", client);
								g_iCountStopTime = gc_fRefuseTime.IntValue;
								RefuseTimer[client] = CreateTimer(gc_fRefuseTime.FloatValue, Timer_ResetColorRefuse, client);
								if (warden_exist()) LoopClients(i) RefuseMenu(i);
								if(gc_bSounds.BoolValue)EmitSoundToAllAny(g_sSoundRefusePath);
							}
							else CPrintToChat(client, "%t %t", "request_tag", "request_refusedtimes", gc_iRefuseLimit.IntValue);
						}
						else CPrintToChat(client, "%t %t", "request_tag", "request_refuseallow");
					}
					else CPrintToChat(client, "%t %t", "request_tag", "request_alreadyrefused");
				}
				else CPrintToChat(client, "%t %t", "request_tag", "request_notalivect");
			}
		}
	}
	return Plugin_Handled;
}


/******************************************************************************
                   EVENTS
******************************************************************************/


public Action Refuse_Event_RoundStart(Handle event, char [] name, bool dontBroadcast)
{
	LoopClients(client)
	{
		delete RefuseTimer[client];
		delete AllowRefuseTimer;
		
		g_iRefuseCounter[client] = 0;
		g_bRefused[client] = false;
		g_bAllowRefuse = false;
		if(CheckVipFlag(client,g_sAdminFlagRefuse)) g_iRefuseCounter[client] = -1;
	}
	
	g_iCountStopTime = gc_fRefuseTime.IntValue;
}


/******************************************************************************
                   FORWARDS LISTENING
******************************************************************************/


public void Refuse_OnMapStart()
{
	if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundRefusePath);
	if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundRefuseStopPath);
}


public void Refuse_OnConfigsExecuted()
{
	g_iCountStopTime = gc_fRefuseTime.IntValue;
	
	char sBufferCMDRefuse[64];
	
	Format(sBufferCMDRefuse, sizeof(sBufferCMDRefuse), "sm_%s", g_sCustomCommandRefuse);
	if(GetCommandFlags(sBufferCMDRefuse) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMDRefuse, Command_refuse, "Allows the Warden start refusing time and Terrorist to refuse a game");
}

public void Refuse_OnClientPutInServer(int client)
{
	g_iRefuseCounter[client] = 0;
	if(CheckVipFlag(client,g_sAdminFlagRefuse)) g_iRefuseCounter[client] = -1;
	g_bRefused[client] = false;
}

public void Refuse_OnClientDisconnect(int client)
{
	delete RefuseTimer[client];
}


/******************************************************************************
                   MENUS
******************************************************************************/


public Action RefuseMenu(int warden)
{
	if (IsValidClient(warden, false, false) && warden_iswarden(warden))
	{
		char info1[255];
		RefusePanel = CreatePanel();
		Format(info1, sizeof(info1), "%T", "request_refuser", warden);
		SetPanelTitle(RefusePanel, info1);
		DrawPanelText(RefusePanel, "-----------------------------------");
		DrawPanelText(RefusePanel, "                                   ");
		LoopValidClients(i,true,false)
		{
			if(g_bRefused[i])
			{
				char userid[11];
				char username[MAX_NAME_LENGTH];
				IntToString(GetClientUserId(i), userid, sizeof(userid));
				Format(username, sizeof(username), "%N", i);
				DrawPanelText(RefusePanel,username);
			}
		}
		DrawPanelText(RefusePanel, "                                   ");
		DrawPanelText(RefusePanel, "-----------------------------------");
		Format(info1, sizeof(info1), "%T", "warden_close", warden);
		DrawPanelItem(RefusePanel, info1); 
		SendPanelToClient(RefusePanel, warden, Handler_NullCancel, 23);
		
	}
}


/******************************************************************************
                   TIMER
******************************************************************************/


public Action Timer_ResetColorRefuse(Handle timer, any client)
{
	if (IsClientConnected(client))
	{
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
	RefuseTimer[client] = null;
	g_bRefused[client] = false;
}


public Action Timer_NoAllowRefuse(Handle timer)
{
	if (g_iCountStopTime > 0)
	{
		if (g_iCountStopTime < 4)
		{
			LoopValidClients(client, false, true)
			{
				PrintHintText(client,"%t", "warden_stopcountdown_nc", g_iCountStopTime);
			}
			CPrintToChatAll("%t %t", "warden_tag" , "warden_stopcountdown", g_iCountStopTime);
		}
		g_iCountStopTime--;
		return Plugin_Continue;
	}
	if (g_iCountStopTime == 0)
	{
		LoopValidClients(client, false, true)
		{
			PrintHintText(client, "%t", "warden_countdownstop_nc");
			if(gc_bSounds.BoolValue)
			{
				EmitSoundToAllAny(g_sSoundRefuseStopPath);
			}
			g_bAllowRefuse = false;
			AllowRefuseTimer = null;
			g_iCountStopTime = gc_fRefuseTime.IntValue;
			return Plugin_Stop;
		}
		CPrintToChatAll("%t %t", "warden_tag" , "warden_countdownstop");
	}
	return Plugin_Continue;
}

