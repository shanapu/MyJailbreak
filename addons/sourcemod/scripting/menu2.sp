#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <wardn>
#include <colors>
#include <autoexecconfig>


ConVar gc_bTag;
ConVar gc_bPlugin;
ConVar gc_bTerror;
ConVar gc_bCTerror;
ConVar gc_bWarden;
ConVar gc_bDays;
ConVar gc_bClose;
ConVar gc_bStart;
ConVar g_bFF;
ConVar g_bsetFF;
ConVar g_bWar;
ConVar g_bJiHad;
ConVar g_bFFA;
ConVar g_bZombie;
ConVar g_bNoScope;
ConVar g_bDodgeBall;
ConVar g_bHide;
ConVar g_bCatch;
ConVar g_bFreeDay;
ConVar g_bDuckHunt;
ConVar g_bCountdown;
ConVar g_bVote;
ConVar g_bGuns;
ConVar g_bGunsT;
ConVar g_bGunsCT;
ConVar g_bOpen;
ConVar g_bRandom;
ConVar g_bWarden;

#pragma semicolon 1

#define PLUGIN_VERSION   "0.x"

public Plugin myinfo = {
	name = "MyJailbreak - Menus",
	author = "shanapu, Franc1sco",
	description = "Jailbreak Menu",
	version = PLUGIN_VERSION,
	url = ""
};

public OnConfigsExecuted()
{
	if (gc_bTag.BoolValue)
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
	
	g_bWarden = FindConVar("sm_warden_enable");
	g_bWar = FindConVar("sm_war_enable");
	g_bFFA = FindConVar("sm_ffa_enable");
	g_bZombie = FindConVar("sm_zombie_enable");
	g_bNoScope = FindConVar("sm_noscope_enable");
	g_bHide = FindConVar("sm_hide_enable");
	g_bJiHad = FindConVar("sm_jihad_enable");
	g_bCatch = FindConVar("sm_catch_enable");
	g_bDodgeBall = FindConVar("sm_dodgeball_enable");
	g_bFreeDay = FindConVar("sm_freeday_enable");
	g_bDuckHunt = FindConVar("sm_duckhunt_enable");
	g_bCountdown = FindConVar("sm_warden_countdown");
	g_bVote = FindConVar("sm_warden_vote");
	g_bGunsCT = FindConVar("sm_weapons_ct");
	g_bGunsT = FindConVar("sm_weapons_t");
	g_bGuns = FindConVar("sm_weapons_enable");
	g_bOpen = FindConVar("sm_wardenopen_enable");
	g_bsetFF = FindConVar("sm_warden_ff");
	g_bRandom = FindConVar("sm_warden_random");
	g_bFF = FindConVar("mp_teammates_are_enemies");

}

public OnPluginStart()
{
	LoadTranslations("MyJailbreakWarden.phrases");
	LoadTranslations("MyJailbreakMenu.phrases");
	RegConsoleCmd("sm_menu", JbMenu);
	RegConsoleCmd("sm_menus", JbMenu);
	RegConsoleCmd("buyammo1", JbMenu);

	RegConsoleCmd("sm_days", EventDays);
	RegConsoleCmd("sm_events", EventDays);
	RegConsoleCmd("sm_event", EventDays);
	
	AutoExecConfig_SetFile("MyJailbreak_menu");
	AutoExecConfig_SetCreateFile(true);
	
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_menu_enable", "1", "0 - disabled, 1 - enable jailbrek menu");
	gc_bCTerror = AutoExecConfig_CreateConVar("sm_menu_ct", "1", "0 - disabled, 1 - enable ct jailbreak menu");
	gc_bTerror = AutoExecConfig_CreateConVar("sm_menu_t", "1", "0 - disabled, 1 - enable t jailbreak menu");
	gc_bWarden = AutoExecConfig_CreateConVar("sm_menu_warden", "1", "0 - disabled, 1 - enable warden jailbreak menu");
	gc_bDays = AutoExecConfig_CreateConVar("sm_menu_days", "1", "0 - disabled, 1 - enable eventdays menu for warden and admin");
	gc_bClose = AutoExecConfig_CreateConVar("sm_menu_close", "1", "0 - disabled, 1 - enable close menu after action");
	gc_bStart = AutoExecConfig_CreateConVar("sm_menu_start", "1", "0 - disabled, 1 - enable open menu on every roundstart");
	gc_bTag = AutoExecConfig_CreateConVar("sm_menu_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch you sv_tags", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	

	
	HookEvent("player_spawn", Event_OnPlayerSpawn);
}



public Action:Event_OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(gc_bStart.BoolValue)
	{
		JbMenu(client,0);
	}
}

public Action:JbMenu(client,args)
{
	if(gc_bPlugin.BoolValue)	
	{
		char menuinfo1[255], menuinfo2[255], menuinfo3[255], menuinfo5[255], menuinfo6[255], menuinfo7[255], menuinfo8[255];
		char menuinfo9[255], menuinfo10[255], menuinfo11[255], menuinfo13[255], menuinfo15[255], menuinfo16[255];
		char menuinfo17[255]; 
//		char menuinfo4[255], menuinfo12[255], menuinfo14[255]; 
		
		Handle menu = CreateMenu(JBMenuHandler);
		
		Format(menuinfo1, sizeof(menuinfo1), "%T", "menu_info_Title", LANG_SERVER);
		SetMenuTitle(menu, menuinfo1);
		if (warden_iswarden(client))
		{
			if(gc_bWarden.BoolValue)
			{
				if(g_bCountdown != null)
				{
					if(g_bCountdown.BoolValue)
					{
						Format(menuinfo2, sizeof(menuinfo2), "%T", "menu_countdown", LANG_SERVER);
						AddMenuItem(menu, "countdown", menuinfo2);
					}
				}
				if(g_bOpen != null)
				{
					if(g_bOpen.BoolValue)
					{
						Format(menuinfo3, sizeof(menuinfo3), "%T", "menu_opencell", LANG_SERVER);
						AddMenuItem(menu, "cellopen", menuinfo3);
					}
				}
				if(gc_bDays.BoolValue)
				{
					Format(menuinfo5, sizeof(menuinfo5), "%T", "menu_eventdays", LANG_SERVER);
					AddMenuItem(menu, "days", menuinfo5);
				}
				if(g_bGuns != null)
				{
					if(g_bGuns.BoolValue)
					{
						if(g_bGunsCT.BoolValue)
						{
							Format(menuinfo6, sizeof(menuinfo6), "%T", "menu_guns", LANG_SERVER);
							AddMenuItem(menu, "guns", menuinfo6);
						}
					}
				}
				if(g_bsetFF != null)
				{
					if(g_bsetFF.BoolValue)
					{
						if(!g_bFF.BoolValue)
						{
							Format(menuinfo7, sizeof(menuinfo7), "%T", "menu_ffon", LANG_SERVER);
							AddMenuItem(menu, "setff", menuinfo7);
						}
						else
						{
							Format(menuinfo8, sizeof(menuinfo8), "%T", "menu_ffoff", LANG_SERVER);
							AddMenuItem(menu, "setff", menuinfo8);
						}
					}
				}
				if(g_bRandom != null)
				{
					if(g_bRandom.BoolValue)
					{
						Format(menuinfo9, sizeof(menuinfo9), "%T", "menu_randomdead", LANG_SERVER);
						AddMenuItem(menu, "kill", menuinfo9);
					}
					
					Format(menuinfo10, sizeof(menuinfo10), "%T", "menu_unwarden", LANG_SERVER);
					AddMenuItem(menu, "unwarden", menuinfo10);
				}
			}
		}
		else if(GetClientTeam(client) == CS_TEAM_CT) 
			{
				if(gc_bCTerror.BoolValue)	
				{
					if(g_bGuns != null)
					{
						if(g_bGuns.BoolValue)
						{
							if(g_bGunsCT.BoolValue)
							{
								Format(menuinfo6, sizeof(menuinfo6), "%T", "menu_guns", LANG_SERVER);
								AddMenuItem(menu, "guns", menuinfo6);
							}
						}
					}
					if(g_bWarden != null)
					{
						if(!warden_exist())
						{
							if(g_bWarden.BoolValue)
							{
								Format(menuinfo11, sizeof(menuinfo11), "%T", "menu_getwarden", LANG_SERVER);
								AddMenuItem(menu, "getwarden", menuinfo11);
							}
						}
					}
					Format(menuinfo13, sizeof(menuinfo13), "%T", "menu_joint", LANG_SERVER);
					AddMenuItem(menu, "joinT", menuinfo13);
				}
			}	
			else if(GetClientTeam(client) == CS_TEAM_T) 
			{
				if(gc_bTerror.BoolValue)	
				{
					if(g_bGuns != null)
					{
						if(g_bGuns.BoolValue)
						{
							if(g_bGunsT.BoolValue)
							{
								Format(menuinfo6, sizeof(menuinfo6), "%T", "menu_guns", LANG_SERVER);
								AddMenuItem(menu, "guns", menuinfo6);
							}
						}
					}
					Format(menuinfo15, sizeof(menuinfo15), "%T", "menu_joinct", LANG_SERVER);
					AddMenuItem(menu, "joinCT", menuinfo15);
					if(g_bWarden != null)
					{
						if(!warden_exist())
						{
							if(g_bWarden.BoolValue)
							{
								if(g_bVote.BoolValue)
								{
									Format(menuinfo16, sizeof(menuinfo16), "%T", "menu_votewarden", LANG_SERVER);
									AddMenuItem(menu, "votewarden", menuinfo16);
								}
							}
						}
					}
				}
			}
		if (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
		{
			Format(menuinfo17, sizeof(menuinfo17), "%T", "menu_admin", LANG_SERVER);
			AddMenuItem(menu, "admin", menuinfo17);
		}
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}
}


public Action:EventDays(client, args)
{
	if(gc_bDays.BoolValue)
	{
		if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
		{
			Handle menu = CreateMenu(EventMenuHandler);
			
			char menuinfo18[255], menuinfo19[255], menuinfo20[255], menuinfo21[255], menuinfo22[255], menuinfo23[255], menuinfo24[255], menuinfo25[255], menuinfo26[255], menuinfo27[255];
			
			Format(menuinfo18, sizeof(menuinfo18), "%T", "menu_event_Title", LANG_SERVER);
			SetMenuTitle(menu, menuinfo18);
			
			if(g_bWar != null)
			{
				if(g_bWar.BoolValue)
				{
					Format(menuinfo19, sizeof(menuinfo19), "%T", "menu_war", LANG_SERVER);
					AddMenuItem(menu, "war", menuinfo19);
				}
			}
			if(g_bFFA != null)
			{
				if(g_bFFA.BoolValue)
				{
					Format(menuinfo20, sizeof(menuinfo20), "%T", "menu_ffa", LANG_SERVER);
					AddMenuItem(menu, "ffa", menuinfo20);
				}
			}
			if(g_bZombie != null)
			{
				if(g_bZombie.BoolValue)
				{
					Format(menuinfo21, sizeof(menuinfo21), "%T", "menu_zombie", LANG_SERVER);
					AddMenuItem(menu, "zombie", menuinfo21);
				}
			}
			if(g_bHide != null)
			{
				if(g_bHide.BoolValue)
				{
					Format(menuinfo22, sizeof(menuinfo22), "%T", "menu_hide", LANG_SERVER);
					AddMenuItem(menu, "hide", menuinfo22);
				}
			}
			if(g_bCatch != null)
			{
				if(g_bCatch.BoolValue)
				{
					Format(menuinfo23, sizeof(menuinfo23), "%T", "menu_catch", LANG_SERVER);
					AddMenuItem(menu, "catch", menuinfo23);
				}
			}
			if(g_bJiHad != null)
			{
				if(g_bJiHad.BoolValue)
				{
					Format(menuinfo23, sizeof(menuinfo23), "%T", "menu_jihad", LANG_SERVER);
					AddMenuItem(menu, "jihad", menuinfo23);
				}
			}
			if(g_bDodgeBall != null)
			{
				if(g_bDodgeBall.BoolValue)
				{
					Format(menuinfo27, sizeof(menuinfo27), "%T", "menu_dodgeball", LANG_SERVER);
					AddMenuItem(menu, "dodgeball", menuinfo27);
				}
			}
			if(g_bNoScope != null)
			{
				if(g_bNoScope.BoolValue)
				{
					Format(menuinfo24, sizeof(menuinfo24), "%T", "menu_noscope", LANG_SERVER);
					AddMenuItem(menu, "noscope", menuinfo24);
				}
			}
			if(g_bDuckHunt != null)
			{
				if(g_bDuckHunt.BoolValue)
				{
					Format(menuinfo25, sizeof(menuinfo25), "%T", "menu_duckhunt", LANG_SERVER);
					AddMenuItem(menu, "duckhunt", menuinfo25);
				}
			}
			if(g_bFreeDay != null)
			{
				if(g_bFreeDay.BoolValue)
				{
					Format(menuinfo26, sizeof(menuinfo26), "%T", "menu_freeday", LANG_SERVER);
					AddMenuItem(menu, "freeday", menuinfo26);
				}
			}
			SetMenuExitButton(menu, true);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);
		}
		else CPrintToChat(client, "%t %t", "warden_tag", "warden_notwarden" );
	}
}



public JBMenuHandler(Handle:menu, MenuAction:action, client, itemNum) 
{
	if ( action == MenuAction_Select ) 
	{
		char info[32];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		if ( strcmp(info,"joinT") == 0 ) 
		{
			ClientCommand(client, "jointeam %i", CS_TEAM_T);
			CloseHandle(menu);
			
		}
		else if ( strcmp(info,"joinCT") == 0 ) 
		{
			ClientCommand(client, "jointeam %i", CS_TEAM_CT);
			CloseHandle(menu);
		} 
		else if ( strcmp(info,"votewarden") == 0 ) 
		{
			FakeClientCommand(client, "sm_votewarden");
			if(gc_bClose.BoolValue)
			{
				CloseHandle(menu);
			}else JbMenu(client,0);
		} 
		else if ( strcmp(info,"guns") == 0 ) 
		{
			FakeClientCommand(client, "sm_guns");
		}
		else if ( strcmp(info,"days") == 0 ) 
		{
			FakeClientCommand(client, "sm_events");
		}
		else if ( strcmp(info,"admin") == 0 ) 
		{
			FakeClientCommand(client, "sm_admin");
		}
		else if ( strcmp(info,"countdown") == 0 ) 
		{
			FakeClientCommand(client, "sm_startcountdown");
			if(gc_bClose.BoolValue)
			{
				CloseHandle(menu);
			}else JbMenu(client,0);
		}
		else if ( strcmp(info,"getwarden") == 0 ) 
		{
			FakeClientCommand(client, "sm_warden");
			JbMenu(client,0);
		}
		else if ( strcmp(info,"unwarden") == 0 ) 
		{
			FakeClientCommand(client, "sm_unwarden");
			JbMenu(client,0);
		}
		else if ( strcmp(info,"cellopen") == 0 ) 
		{
			FakeClientCommand(client, "sm_open");
			if(gc_bClose.BoolValue)
			{
				CloseHandle(menu);
			}else JbMenu(client,0);
		}
		else if ( strcmp(info,"setff") == 0 ) 
		{
			FakeClientCommand(client, "sm_setff");
			if(gc_bClose.BoolValue)
			{
				CloseHandle(menu);
			}else JbMenu(client,0);
		}
		else if ( strcmp(info,"kill") == 0 ) 
		{
			FakeClientCommand(client, "sm_killrandom");
			if(gc_bClose.BoolValue)
			{
				CloseHandle(menu);
			}else JbMenu(client,0);
		}
		else if (action == MenuAction_End)
		{
			CloseHandle(menu);
		}
}
}

public EventMenuHandler(Handle:menu, MenuAction:action, client, itemNum) 
{
	if ( action == MenuAction_Select ) 
	{
		char info[32];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		if ( strcmp(info,"war") == 0 ) 
		{
			FakeClientCommand(client, "sm_setwar");
			if(gc_bClose.BoolValue)
			{
				CloseHandle(menu);
			}else JbMenu(client,0);
		} 
		else if ( strcmp(info,"ffa") == 0 ) 
		{
			FakeClientCommand(client, "sm_setffa");
			if(gc_bClose.BoolValue)
			{
				CloseHandle(menu);
			}else JbMenu(client,0);
		} 
		else if ( strcmp(info,"zombie") == 0 ) 
		{
			FakeClientCommand(client, "sm_setzombie");
			if(gc_bClose.BoolValue)
			{
				CloseHandle(menu);
			}else JbMenu(client,0);
		} 
		else if ( strcmp(info,"catch") == 0 )
		{
			FakeClientCommand(client, "sm_setcatch");
			if(gc_bClose.BoolValue)
			{
				CloseHandle(menu);
			}else JbMenu(client,0);
		}
		else if ( strcmp(info,"jihad") == 0 )
		{
			FakeClientCommand(client, "sm_setjihad");
			if(gc_bClose.BoolValue)
			{
				CloseHandle(menu);
			}else JbMenu(client,0);
		}
		else if ( strcmp(info,"noscope") == 0 )
		{
			FakeClientCommand(client, "sm_setnoscope");
			if(gc_bClose.BoolValue)
			{
				CloseHandle(menu);
			}else JbMenu(client,0);
		}
		else if ( strcmp(info,"dodgeball") == 0 )
		{
			FakeClientCommand(client, "sm_setdodgeball");
			if(gc_bClose.BoolValue)
			{
				CloseHandle(menu);
			}else JbMenu(client,0);
		}
		else if ( strcmp(info,"duckhunt") == 0 )
		{
			FakeClientCommand(client, "sm_setduckhunt");
			if(gc_bClose.BoolValue)
			{
				CloseHandle(menu);
			}else JbMenu(client,0);
		}
		else if ( strcmp(info,"hide") == 0 )
		{
			FakeClientCommand(client, "sm_sethide");
			if(gc_bClose.BoolValue)
			{
				CloseHandle(menu);
			}else JbMenu(client,0);
		}
		else if ( strcmp(info,"freeday") == 0 )
		{
			FakeClientCommand(client, "sm_setfreeday");
			if(gc_bClose.BoolValue)
			{
				CloseHandle(menu);
			}else JbMenu(client,0);
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);       //todo: Displaying call stack trace for plugin "MyJailbreak/menu2.smx": L 04/06/2016 - 01:13:24: [SM]   [0]  Line 548, menu2.sp::EventMenuHandler()

	}
}