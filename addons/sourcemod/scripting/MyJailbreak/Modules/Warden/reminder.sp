/*
 * MyJailbreak - Warden - Reminder Module.
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
#include <myjailbreak>


//Compiler Options
#pragma semicolon 1
#pragma newdecls required


//Console Variables
ConVar gc_bRemindTimer;


//Handles
Handle RemindTimer;


//Start
public void Reminder_OnPluginStart()
{
	//AutoExecConfig
	gc_bRemindTimer = CreateConVar("sm_warden_roundtime_reminder", "1", "0 - disabled, 1 - announce remaining round time in chat & hud 3min,2min,1min,30sec before roundend.", _, true,  0.0, true, 1.0);
	
	
	//Hooks
	HookEvent("round_start", Reminder_Event_RoundStart);
	HookEvent("round_end", Reminder_Event_RoundEnd);
	
	
	//FindConVar
	g_bFF = FindConVar("mp_teammates_are_enemies");
}


/******************************************************************************
                   EVENTS
******************************************************************************/


public void Reminder_OnMapStart()
{
	PrecacheSound("weapons/c4/c4_beep1.wav", true);
}


public void Reminder_Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	delete RemindTimer;
}


public void Reminder_Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if(gc_bRemindTimer.BoolValue)RemindTimer = CreateTimer(2.0, Timer_RemindTimer, _, TIMER_REPEAT);
}


/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/


public void Reminder_OnMapEnd()
{
	delete RemindTimer;
}


/******************************************************************************
                   TIMER
******************************************************************************/


public Action Timer_RemindTimer(Handle timer)
{
	if(g_iRoundTime >= 1 && !IsLastGuardRule())
	{
		g_iRoundTime--;
		char timeinfo[64];
		if(g_iRoundTime == 180 && (g_iWarden != -1))
		{
			EmitSoundToClient(g_iWarden, "weapons/c4/c4_beep1.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0);
			Format(timeinfo, sizeof(timeinfo), "%T %T %T", "warden_tag", g_iWarden, "warden_180", g_iWarden, "warden_remaining", g_iWarden);
			CPrintToChat(g_iWarden, timeinfo);
			Format(timeinfo, sizeof(timeinfo), "%T %T", "warden_180", g_iWarden, "warden_remaining", g_iWarden);
			PrintCenterText(g_iWarden, timeinfo);
		}
		if(g_iRoundTime == 120 && (g_iWarden != -1))
		{
			EmitSoundToClient(g_iWarden, "weapons/c4/c4_beep1.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0);
			Format(timeinfo, sizeof(timeinfo), "%T %T %T", "warden_tag", g_iWarden, "warden_120", g_iWarden, "warden_remaining", g_iWarden);
			CPrintToChat(g_iWarden, timeinfo);
			Format(timeinfo, sizeof(timeinfo), "%T %T", "warden_120", g_iWarden, "warden_remaining", g_iWarden);
			PrintCenterText(g_iWarden, timeinfo);
		}
		if(g_iRoundTime == 60 && (g_iWarden != -1))
		{
			EmitSoundToClient(g_iWarden, "weapons/c4/c4_beep1.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0);
			Format(timeinfo, sizeof(timeinfo), "%T %T %T", "warden_tag", g_iWarden, "warden_60", g_iWarden, "warden_remaining", g_iWarden);
			CPrintToChat(g_iWarden, timeinfo);
			Format(timeinfo, sizeof(timeinfo), "%T %T", "warden_60", g_iWarden, "warden_remaining", g_iWarden);
			PrintCenterText(g_iWarden, timeinfo);
		}
		if(g_iRoundTime == 30 && (g_iWarden != -1))
		{
			EmitSoundToClient(g_iWarden, "weapons/c4/c4_beep1.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0);
			Format(timeinfo, sizeof(timeinfo), "%T %T %T", "warden_tag", g_iWarden, "warden_30", g_iWarden, "warden_remaining", g_iWarden);
			CPrintToChat(g_iWarden, timeinfo);
			Format(timeinfo, sizeof(timeinfo), "%T %T", "warden_30", g_iWarden, "warden_remaining", g_iWarden);
			PrintCenterText(g_iWarden, timeinfo);
		}
		return Plugin_Continue;
	}
	RemindTimer = null;
	return Plugin_Stop;
}