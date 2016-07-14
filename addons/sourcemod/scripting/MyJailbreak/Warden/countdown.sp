// Countdown module for MyJailbreak - Warden

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
ConVar gc_bCountDown;
ConVar gc_bCountdownOverlays;
ConVar gc_sCountdownOverlayStartPath;
ConVar gc_sCountdownOverlayStopPath;
ConVar gc_bCountdownSounds;
ConVar gc_sCountdownSoundStartPath;
ConVar gc_sCountdownSoundStopPath;

//Bools
bool g_bIsCountDown = false;

//Strings
char g_sCountdownSoundStartPath[256];
char g_sCountdownSoundStopPath[256];
char g_sCountdownOverlayStopPath[256];
char g_sCountdownOverlayStartPath[256];

//Handles
Handle g_hStartTimer = null;
Handle g_hStopTimer = null;
Handle g_hStartStopTimer = null;


public void Countdown_OnPluginStart()
{
	//Client commands
	RegConsoleCmd("sm_cdstart", SetStartCountDown, "Allows the Warden to start a START Countdown! (start after 10sec.) - start without menu");
	RegConsoleCmd("sm_cdmenu", CDMenu, "Allows the Warden to open the Countdown Menu");
	RegConsoleCmd("sm_cdstartstop", StartStopCDMenu, "Allows the Warden to start a START/STOP Countdown! (start after 10sec./stop after 20sec.) - start without menu");
	RegConsoleCmd("sm_cdstop", SetStopCountDown, "Allows the Warden to start a STOP Countdown! (stop after 20sec.) - start without menu");
//	RegConsoleCmd("sm_cdcancel", CancelCountDown, "Allows the Warden to cancel a running Countdown");
	
	//AutoExecConfig
	gc_bCountDown = AutoExecConfig_CreateConVar("sm_warden_countdown", "1", "0 - disabled, 1 - enable countdown for warden", _, true,  0.0, true, 1.0);
	gc_bCountdownOverlays = AutoExecConfig_CreateConVar("sm_warden_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true,  0.0, true, 1.0);
	gc_sCountdownOverlayStartPath = AutoExecConfig_CreateConVar("sm_warden_overlays_start", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_sCountdownOverlayStopPath = AutoExecConfig_CreateConVar("sm_warden_overlays_stop", "overlays/MyJailbreak/stop" , "Path to the stop Overlay DONT TYPE .vmt or .vft");
	gc_bCountdownSounds = AutoExecConfig_CreateConVar("sm_warden_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true,  0.0, true, 1.0);
	gc_sCountdownSoundStartPath = AutoExecConfig_CreateConVar("sm_warden_sounds_start", "music/MyJailbreak/start.mp3", "Path to the soundfile which should be played for a start countdown.");
	gc_sCountdownSoundStopPath = AutoExecConfig_CreateConVar("sm_warden_sounds_stop", "music/MyJailbreak/stop.mp3", "Path to the soundfile which should be played for stop countdown.");
	
	//Hooks 
	HookEvent("round_end", Countdown_RoundEnd);
	HookConVarChange(gc_sCountdownSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sCountdownSoundStopPath, OnSettingChanged);
	HookConVarChange(gc_sCountdownOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sCountdownOverlayStopPath, OnSettingChanged);
	
	//FindConVar
	gc_sCountdownSoundStartPath.GetString(g_sCountdownSoundStartPath, sizeof(g_sCountdownSoundStartPath));
	gc_sCountdownSoundStopPath.GetString(g_sCountdownSoundStopPath, sizeof(g_sCountdownSoundStopPath));
	gc_sCountdownOverlayStartPath.GetString(g_sCountdownOverlayStartPath , sizeof(g_sCountdownOverlayStartPath));
	gc_sCountdownOverlayStopPath.GetString(g_sCountdownOverlayStopPath , sizeof(g_sCountdownOverlayStopPath));
}

public int Countdown_OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sCountdownSoundStartPath)
	{
		strcopy(g_sCountdownSoundStartPath, sizeof(g_sCountdownSoundStartPath), newValue);
		if(gc_bCountdownSounds.BoolValue) PrecacheSoundAnyDownload(g_sCountdownSoundStartPath);
	}
	else if(convar == gc_sCountdownSoundStopPath)
	{
		strcopy(g_sCountdownSoundStopPath, sizeof(g_sCountdownSoundStopPath), newValue);
		if(gc_bCountdownSounds.BoolValue) PrecacheSoundAnyDownload(g_sCountdownSoundStopPath);
	}
	else if(convar == gc_sCountdownOverlayStartPath)
	{
		strcopy(g_sCountdownOverlayStartPath, sizeof(g_sCountdownOverlayStartPath), newValue);
		if(gc_bCountdownOverlays.BoolValue) PrecacheDecalAnyDownload(g_sCountdownOverlayStartPath);
	}
	else if(convar == gc_sCountdownOverlayStopPath)
	{
		strcopy(g_sCountdownOverlayStopPath, sizeof(g_sCountdownOverlayStopPath), newValue);
		if(gc_bCountdownOverlays.BoolValue) PrecacheDecalAnyDownload(g_sCountdownOverlayStopPath);
	}
}

public void Countdown_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (g_hStopTimer != null) KillTimer(g_hStopTimer);
	if (g_hStartTimer != null) KillTimer(g_hStartTimer);
	if (g_hStartStopTimer != null) KillTimer(g_hStartStopTimer);
	
	LoopClients(i)
	{
		CancelCountDown(i, 0);
	}
}

public void Countdown_OnMapEnd()
{
	LoopClients(i) CancelCountDown(i, 0);
}

public Action CDMenu(int client, int args)
{
	if(gc_bCountDown.BoolValue)
	{
		if (client == g_iWarden)
		{
			char menuinfo[255];
			
			Menu menu = new Menu(CDHandler);
			Format(menuinfo, sizeof(menuinfo), "%T", "warden_cdmenu_title", client);
			menu.SetTitle(menuinfo);
			Format(menuinfo, sizeof(menuinfo), "%T", "warden_cdmenu_start", client);
			menu.AddItem("start", menuinfo);
			Format(menuinfo, sizeof(menuinfo), "%T", "warden_cdmenu_stop", client);
			menu.AddItem("stop", menuinfo);
			Format(menuinfo, sizeof(menuinfo), "%T", "warden_cdmenu_startstop", client);
			menu.AddItem("startstop", menuinfo);
			menu.ExitButton = true;
			menu.ExitBackButton = true;
			menu.Display(client, 20);
		}
		else CPrintToChat(client, "%t %t", "warden_tag", "warden_notwarden" );
	}
	return Plugin_Handled;
}

public int CDHandler(Menu menu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(selection, info, sizeof(info));
		
		if ( strcmp(info,"start") == 0 ) 
		{
			FakeClientCommand(client, "sm_cdstart");
			
			if(g_bMenuClose != null)
			{
				if(!g_bMenuClose)
				{
					FakeClientCommand(client, "sm_menu");
				}
			}
		}
		else if ( strcmp(info,"stop") == 0 ) 
		{
			FakeClientCommand(client, "sm_cdstop");
			
			if(g_bMenuClose != null)
			{
				if(!g_bMenuClose)
				{
					FakeClientCommand(client, "sm_menu");
				}
			}
		}
		else if ( strcmp(info,"startstop") == 0 ) 
		{
		FakeClientCommand(client, "sm_cdstartstop");
		}
	}
	else if(selection == MenuCancel_ExitBack) 
	{
		FakeClientCommand(client, "sm_menu");
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action CancelCountDown(int client, int args)
{
	if (g_bIsCountDown)
	{
		g_iCountStopTime = -1;
		g_iCountStartTime = -1;
		g_hStartTimer = null;
		g_hStartStopTimer = null;
		g_hStopTimer = null;
		g_bIsCountDown = false;
		CPrintToChatAll("%t %t", "warden_tag", "warden_countdowncanceled" );
	}
}

public Action StartStopCDMenu(int client, int args)
{
	if(gc_bCountDown.BoolValue)
	{
		if (client == g_iWarden)
		{
			char menuinfo[255];
			
			Menu menu = new Menu(StartStopCDHandler);
			Format(menuinfo, sizeof(menuinfo), "%T", "warden_cdmenu_title2", client);
			menu.SetTitle(menuinfo);
			Format(menuinfo, sizeof(menuinfo), "%T", "warden_15", client);
			menu.AddItem("15", menuinfo);
			Format(menuinfo, sizeof(menuinfo), "%T", "warden_30", client);
			menu.AddItem("30", menuinfo);
			Format(menuinfo, sizeof(menuinfo), "%T", "warden_45", client);
			menu.AddItem("45", menuinfo);
			Format(menuinfo, sizeof(menuinfo), "%T", "warden_60", client);
			menu.AddItem("60", menuinfo);
			Format(menuinfo, sizeof(menuinfo), "%T", "warden_90", client);
			menu.AddItem("90", menuinfo);
			Format(menuinfo, sizeof(menuinfo), "%T", "warden_120", client);
			menu.AddItem("120", menuinfo);
			Format(menuinfo, sizeof(menuinfo), "%T", "warden_180", client);
			menu.AddItem("180", menuinfo);
			Format(menuinfo, sizeof(menuinfo), "%T", "warden_300", client);
			menu.AddItem("300", menuinfo);
			
			menu.ExitBackButton = true;
			menu.ExitButton = true;
			menu.Display(client, 20);
		}
		else CPrintToChat(client, "%t %t", "warden_tag", "warden_notwarden" );
	}
	return Plugin_Handled;
}

public int StartStopCDHandler(Menu menu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(selection, info, sizeof(info));
		
		if ( strcmp(info,"15") == 0 ) 
		{
			g_iSetCountStartStopTime = 25;
			SetStartStopCountDown(client, 0);
		}
		else if ( strcmp(info,"30") == 0 ) 
		{
			g_iSetCountStartStopTime = 40;
			SetStartStopCountDown(client, 0);
		}
		else if ( strcmp(info,"45") == 0 ) 
		{
			g_iSetCountStartStopTime = 55;
			SetStartStopCountDown(client, 0);
		}
		else if ( strcmp(info,"60") == 0 ) 
		{
			g_iSetCountStartStopTime = 70;
			SetStartStopCountDown(client, 0);
		}
		else if ( strcmp(info,"90") == 0 ) 
		{
			g_iSetCountStartStopTime = 100;
			SetStartStopCountDown(client, 0);
		}
		else if ( strcmp(info,"120") == 0 ) 
		{
			g_iSetCountStartStopTime = 130;
			SetStartStopCountDown(client, 0);
		}
		else if ( strcmp(info,"180") == 0 ) 
		{
			g_iSetCountStartStopTime = 190;
			SetStartStopCountDown(client, 0);
		}
		else if ( strcmp(info,"300") == 0 ) 
		{
			g_iSetCountStartStopTime = 310;
			SetStartStopCountDown(client, 0);
		}
		if(g_bMenuClose != null)
		{
			if(!g_bMenuClose)
			{
				FakeClientCommand(client, "sm_menu");
			}
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(selection == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_cdmenu");
		}
	}
	else if(action == MenuAction_End)
	{
		delete menu;
	}
}

public Action SetStartCountDown(int client, int args)
{
	if(gc_bCountDown.BoolValue)
	{
		if (client == g_iWarden)
		{
			if (!g_bIsCountDown)
			{
				g_iCountStopTime = 9;
				g_hStartTimer = CreateTimer( 1.0, StartCountdown, client, TIMER_REPEAT);
				
				CPrintToChatAll("%t %t", "warden_tag" , "warden_startcountdownhint");
		
				if(gc_bBetterNotes.BoolValue)
				{
					PrintHintTextToAll("%t", "warden_startcountdownhint_nc");
				}
	
			
				g_bIsCountDown = true;
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_countdownrunning");
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
}

public Action SetStopCountDown(int client, int args)
{
	if(gc_bCountDown.BoolValue)
	{
		if (client == g_iWarden)
		{
			if (!g_bIsCountDown)
			{
				g_iCountStopTime = 20;
				g_hStopTimer = CreateTimer( 1.0, StopCountdown, client, TIMER_REPEAT);
				
				
				CPrintToChatAll("%t %t", "warden_tag" , "warden_stopcountdownhint");
		
				if(gc_bBetterNotes.BoolValue)
				{
					PrintHintTextToAll("%t", "warden_stopcountdownhint_nc");
				}
												
				g_bIsCountDown = true;
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_countdownrunning");
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
}

public Action SetStartStopCountDown(int client, int args)
{
	if(gc_bCountDown.BoolValue)
	{
		if (client == g_iWarden)
		{
			if (!g_bIsCountDown)
			{
				g_iCountStartTime = 9;
				g_hStartTimer = CreateTimer( 1.0, StartCountdown, client, TIMER_REPEAT);
				g_hStartStopTimer = CreateTimer( 1.0, StopStartStopCountdown, client, TIMER_REPEAT);
				
				CPrintToChatAll("%t %t", "warden_tag" , "warden_startstopcountdownhint");
				
				if(gc_bBetterNotes.BoolValue)
				{
					PrintHintTextToAll("%t", "warden_startstopcountdownhint_nc");
				}
				g_bIsCountDown = true;
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_countdownrunning");
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
}

public Action StartCountdown( Handle timer, any client ) 
{
	if (g_iCountStartTime > 0)
	{
		if (IsClientInGame(client) && IsPlayerAlive(client))
		{
			if (g_iCountStartTime < 6) 
			{
				PrintHintText(client,"%t", "warden_startcountdown_nc", g_iCountStartTime);
				CPrintToChatAll("%t %t", "warden_tag" , "warden_startcountdown", g_iCountStartTime);
			}
		}
		g_iCountStartTime--;
		return Plugin_Continue;
	}
	if (g_iCountStartTime == 0)
	{
		if(IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client))
		{
			PrintHintText(client, "%t", "warden_countdownstart_nc");
			CPrintToChatAll("%t %t", "warden_tag" , "warden_countdownstart");
			
			if(gc_bCountdownOverlays.BoolValue)
			{
				ShowOverlay(client, g_sCountdownOverlayStartPath, 2.0);
			}
			if(gc_bCountdownSounds.BoolValue)	
			{
				EmitSoundToAllAny(g_sCountdownSoundStartPath);
			}
			g_hStartTimer = null;
			g_bIsCountDown = false;
			g_iCountStopTime = 20;
			g_iCountStartTime = 9;
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

public Action StopCountdown( Handle timer, any client ) 
{
	if (g_iCountStopTime > 0)
	{
		if (IsClientInGame(client) && IsPlayerAlive(client))
		{
			if (g_iCountStopTime < 16) 
			{
				PrintHintText(client,"%t", "warden_stopcountdown_nc", g_iCountStopTime);
				CPrintToChatAll("%t %t", "warden_tag" , "warden_stopcountdown", g_iCountStopTime);
			}
		}
		g_iCountStopTime--;
		return Plugin_Continue;
	}
	if (g_iCountStopTime == 0)
	{
		if(IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client))
		{
			PrintHintText(client, "%t", "warden_countdownstop_nc");
			CPrintToChatAll("%t %t", "warden_tag" , "warden_countdownstop");
			
			if(gc_bCountdownOverlays.BoolValue)
			{
				ShowOverlay(client, g_sCountdownOverlayStopPath, 2.0);
			}
			if(gc_bCountdownSounds.BoolValue)	
			{
				EmitSoundToAllAny(g_sCountdownSoundStopPath);
			}
			g_hStopTimer = null;
			g_bIsCountDown = false;
			g_iCountStopTime = 20;
			g_iCountStartTime = 9;
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

public Action StopStartStopCountdown( Handle timer, any client ) 
{
	if ( g_iSetCountStartStopTime > 0)
	{
		if (IsClientInGame(client) && IsPlayerAlive(client))
		{
			if ( g_iSetCountStartStopTime < 11) 
			{
				PrintHintText(client,"%t", "warden_stopcountdown_nc", g_iSetCountStartStopTime);
				CPrintToChatAll("%t %t", "warden_tag" , "warden_stopcountdown", g_iSetCountStartStopTime);
			}
		}
		g_iSetCountStartStopTime--;
		g_bIsCountDown = true;
		return Plugin_Continue;
	}
	if ( g_iSetCountStartStopTime == 0)
	{
		if(IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client))
		{
			PrintHintText(client, "%t", "warden_countdownstop_nc");
			CPrintToChatAll("%t %t", "warden_tag" , "warden_countdownstop");
			
			if(gc_bCountdownOverlays.BoolValue)
			{
				ShowOverlay(client, g_sCountdownOverlayStopPath, 2.0);
			}
			if(gc_bCountdownSounds.BoolValue)	
			{
				EmitSoundToAllAny(g_sCountdownSoundStopPath);
			}
			g_hStartStopTimer = null;
			g_bIsCountDown = false;
			g_iCountStopTime = 20;
			g_iCountStartTime = 9;
			return Plugin_Stop;
		}
	}
	
	return Plugin_Continue;
}