// Round Time Reminder module for MyJailbreak - Warden

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
ConVar gc_bRemindTimer;

//Handles
Handle RemindTimer;

public void Reminder_OnPluginStart()
{
	//AutoExecConfig
	gc_bRemindTimer = CreateConVar("sm_warden_roundtime_reminder", "1", "0 - disabled, 1 - announce remaining round time in chat & hud 3min,2min,1min,30sec before roundend.", _, true,  0.0, true, 1.0);
	
	//Hooks
	HookEvent("round_start", Reminder_RoundStart);
	HookEvent("round_end", Reminder_RoundEnd);
	
	//FindConVar
	g_bFF = FindConVar("mp_teammates_are_enemies");
}
public void Reminder_OnMapStart()
{
	PrecacheSound("weapons/c4/c4_beep1.wav", true);
}
public void Reminder_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	delete RemindTimer;
}

public void Reminder_OnMapEnd()
{
	delete RemindTimer;
}

public void Reminder_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if(gc_bRemindTimer.BoolValue)RemindTimer = CreateTimer(1.0, Timer_RemindTimer, _, TIMER_REPEAT);
}

public Action Timer_RemindTimer(Handle timer)
{
	if(g_iRoundTime >= 1)
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

