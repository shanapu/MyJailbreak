//includes
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <wardn>
#include <colors>
#include <autoexecconfig>
#include <myjailbreak>
#include <lastrequest>


//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//ConVars
ConVar gc_bPlugin;
ConVar gc_bTerror;
ConVar gc_bCTerror;
ConVar gc_bWarden;
ConVar gc_bDays;
ConVar g_bMath;
ConVar g_bCheck;
ConVar gc_bClose;
ConVar gc_bStart;
ConVar gc_bWelcome;
ConVar g_bFF;
ConVar g_bZeus;
ConVar g_bRules;
ConVar g_bsetFF;
ConVar g_bWar;
ConVar g_bJiHad;
ConVar g_bKnife;
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

public Plugin myinfo = {
	name = "MyJailbreak - Menus",
	author = "shanapu, Franc1sco",
	description = "Jailbreak Menu",
	version = PLUGIN_VERSION,
	url = "shanapu.de"
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.Menu.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_menu", JbMenu, "opens the menu depends on players team/rank");
	RegConsoleCmd("sm_menus", JbMenu, "opens the menu depends on players team/rank");
	RegConsoleCmd("buyammo1", JbMenu, "opens the menu depends on players team/rank");
	RegConsoleCmd("sm_days", EventDays, "open a Set EventDays menu for Warden/Admin & vote EventDays menu for player");
	RegConsoleCmd("sm_events", EventDays, "open a Set EventDays menu for Warden/Admin & vote EventDays menu for player");
	RegConsoleCmd("sm_event", EventDays, "open a Set EventDays menu for Warden/Admin & vote EventDays menu for player");
	
	//AutoExecConfig
	AutoExecConfig_SetFile("MyJailbreak_menu");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_menu_version", PLUGIN_VERSION, "The version of the SourceMod plugin MyJailBreak - Menu", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_menu_enable", "1", "0 - disabled, 1 - enable jailbrek menu");
	gc_bCTerror = AutoExecConfig_CreateConVar("sm_menu_ct", "1", "0 - disabled, 1 - enable ct jailbreak menu");
	gc_bTerror = AutoExecConfig_CreateConVar("sm_menu_t", "1", "0 - disabled, 1 - enable t jailbreak menu");
	gc_bWarden = AutoExecConfig_CreateConVar("sm_menu_warden", "1", "0 - disabled, 1 - enable warden jailbreak menu");
	gc_bDays = AutoExecConfig_CreateConVar("sm_menu_days", "1", "0 - disabled, 1 - enable vote/set eventdays menu");
	gc_bClose = AutoExecConfig_CreateConVar("sm_menu_close", "1", "0 - disabled, 1 - enable close menu after action");
	gc_bStart = AutoExecConfig_CreateConVar("sm_menu_start", "1", "0 - disabled, 1 - enable open menu on every roundstart");
	gc_bWelcome = AutoExecConfig_CreateConVar("sm_menu_welcome", "1", "Show welcome message to newly connected users.");
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("player_spawn", Event_OnPlayerSpawn);
}

public void OnConfigsExecuted()
{
	g_bWarden = FindConVar("sm_warden_enable");
	g_bRules = FindConVar("sm_hosties_rules_enable");
	g_bCheck = FindConVar("sm_hosties_checkplayers_enable");
	g_bMath = FindConVar("sm_warden_math");
	g_bWar = FindConVar("sm_war_enable");
	g_bZeus = FindConVar("sm_zeus_enable");
	g_bFFA = FindConVar("sm_ffa_enable");
	g_bZombie = FindConVar("sm_zombie_enable");
	g_bNoScope = FindConVar("sm_noscope_enable");
	g_bHide = FindConVar("sm_hide_enable");
	g_bKnife = FindConVar("sm_knifefight_enable");
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
	g_bOpen = FindConVar("sm_warden_open_enable");
	g_bsetFF = FindConVar("sm_warden_ff");
	g_bRandom = FindConVar("sm_warden_random");
	g_bFF = FindConVar("mp_teammates_are_enemies");
}

public void OnClientPutInServer(int client)
{
	if (gc_bWelcome.BoolValue)
	{
		CreateTimer(30.0, Timer_WelcomeMessage, client);
	}
}

public Action Timer_WelcomeMessage(Handle timer, any client)
{	
	if (gc_bWelcome.BoolValue && IsValidClient(client, false, true))
	{	
		CPrintToChat(client, "%t", "menu_info");
	}
}

public Action Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(gc_bStart.BoolValue)
	{
		JbMenu(client,0);
	}
}

public Action JbMenu(int client, int args)
{
	if(gc_bPlugin.BoolValue)	
	{
		char menuinfo1[255], menuinfo2[255], menuinfo3[255], menuinfo5[255], menuinfo6[255], menuinfo7[255], menuinfo8[255];
		char menuinfo9[255], menuinfo10[255], menuinfo11[255], menuinfo13[255], menuinfo15[255], menuinfo16[255];
		char menuinfo17[255], menuinfo14[255], menuinfo4[255];
		//, menuinfo12[255]
		
		
		
		Format(menuinfo1, sizeof(menuinfo1), "%T", "menu_info_Title", LANG_SERVER);
		
		Menu mainmenu = new Menu(JBMenuHandler);
		mainmenu.SetTitle(menuinfo1);
		if (warden_iswarden(client) && IsPlayerAlive(client))
		{
			if(gc_bWarden.BoolValue)
			{
				if(g_bGuns != null)
				{
					if(g_bGuns.BoolValue)
					{
						if(g_bGunsCT.BoolValue)
						{
							Format(menuinfo6, sizeof(menuinfo6), "%T", "menu_guns", LANG_SERVER);
							mainmenu.AddItem("guns", menuinfo6);
						}
					}
				}
				if(g_bOpen != null)
				{
					if(g_bOpen.BoolValue)
					{
						Format(menuinfo3, sizeof(menuinfo3), "%T", "menu_opencell", LANG_SERVER);
						mainmenu.AddItem("cellopen", menuinfo3);
					}
				}
				if(g_bCountdown != null)
				{
					if(g_bCountdown.BoolValue)
					{
						Format(menuinfo2, sizeof(menuinfo2), "%T", "menu_countdown", LANG_SERVER);
						mainmenu.AddItem("countdown", menuinfo2);
					}
				}
				if(g_bMath != null)
				{
					if(g_bMath.BoolValue)
					{
						Format(menuinfo3, sizeof(menuinfo3), "%T", "menu_math", LANG_SERVER);
						mainmenu.AddItem("math", menuinfo3);
					}
				}
				if(gc_bDays.BoolValue)
				{
					Format(menuinfo5, sizeof(menuinfo5), "%T", "menu_eventdays", LANG_SERVER);
					mainmenu.AddItem("days", menuinfo5);
				}
				if(g_bCheck != null)
				{
					if(g_bCheck.BoolValue)
					{
						Format(menuinfo4, sizeof(menuinfo4), "%T", "menu_check", LANG_SERVER);
						mainmenu.AddItem("check", menuinfo4);
					}
				}
				if(g_bsetFF != null)
				{
					if(g_bsetFF.BoolValue)
					{
						if(!g_bFF.BoolValue)
						{
							Format(menuinfo7, sizeof(menuinfo7), "%T", "menu_ffon", LANG_SERVER);
							mainmenu.AddItem("setff", menuinfo7);
						}
						else
						{
							Format(menuinfo8, sizeof(menuinfo8), "%T", "menu_ffoff", LANG_SERVER);
							mainmenu.AddItem("setff", menuinfo8);
						}
					}
				}
				if(g_bRandom != null)
				{
					if(g_bRandom.BoolValue)
					{
						Format(menuinfo9, sizeof(menuinfo9), "%T", "menu_randomdead", LANG_SERVER);
						mainmenu.AddItem("kill", menuinfo9);
					}
					
					Format(menuinfo10, sizeof(menuinfo10), "%T", "menu_unwarden", LANG_SERVER);
					mainmenu.AddItem("unwarden", menuinfo10);
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
							mainmenu.AddItem("guns", menuinfo6);
						}
					}
				}
				if(g_bWarden != null)
				{
					if(!warden_exist() && IsPlayerAlive(client))
					{
						if(g_bWarden.BoolValue)
						{
							Format(menuinfo11, sizeof(menuinfo11), "%T", "menu_getwarden", LANG_SERVER);
							mainmenu.AddItem("getwarden", menuinfo11);
						}
					}
				}
				if(gc_bDays.BoolValue)
				{
					Format(menuinfo5, sizeof(menuinfo5), "%T", "menu_eventdays", LANG_SERVER);
					mainmenu.AddItem("days", menuinfo5);
				}
				if(g_bCheck != null)
				{
					if(g_bCheck.BoolValue)
					{
						Format(menuinfo4, sizeof(menuinfo4), "%T", "menu_check", LANG_SERVER);
						mainmenu.AddItem("check", menuinfo4);
					}
				}
				Format(menuinfo13, sizeof(menuinfo13), "%T", "menu_joint", LANG_SERVER);
				mainmenu.AddItem("joinT", menuinfo13);
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
							mainmenu.AddItem("guns", menuinfo6);
						}
					}
				}
				if(g_bWarden != null)
				{
					if(warden_exist())
					{
						if(g_bWarden.BoolValue)
						{
							if(g_bVote.BoolValue)
							{
								Format(menuinfo16, sizeof(menuinfo16), "%T", "menu_votewarden", LANG_SERVER);
								mainmenu.AddItem("votewarden", menuinfo16);
							}
						}
					}
				}
				if(gc_bDays.BoolValue)
				{
					Format(menuinfo5, sizeof(menuinfo5), "%T", "menu_eventdays", LANG_SERVER);
					mainmenu.AddItem("days", menuinfo5);
				}
				Format(menuinfo15, sizeof(menuinfo15), "%T", "menu_joinct", LANG_SERVER);
				mainmenu.AddItem("joinCT", menuinfo15);
			}
		}
		if(g_bRules != null)
		{
			if(g_bRules.BoolValue)
			{
				Format(menuinfo14, sizeof(menuinfo14), "%T", "menu_rules", LANG_SERVER);
				mainmenu.AddItem("rules", menuinfo14);
			}
		}
		if (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
		{
			Format(menuinfo17, sizeof(menuinfo17), "%T", "menu_admin", LANG_SERVER);
			mainmenu.AddItem("admin", menuinfo17);
		}
		mainmenu.ExitButton = true;
		mainmenu.Display(client, MENU_TIME_FOREVER);
	}
}


public Action EventDays(int client, int args)
{
	if(gc_bDays.BoolValue)
	{
			Menu daysmenu = new Menu(EventMenuHandler);
			
			char menuinfo18[255], menuinfo19[255], menuinfo20[255], menuinfo21[255], menuinfo22[255], menuinfo23[255], menuinfo24[255], menuinfo25[255], menuinfo26[255], menuinfo27[255], menuinfo28[255], menuinfo29[255];
			char menuinfo17[255];
			
			if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
			{
			Format(menuinfo18, sizeof(menuinfo18), "%T", "menu_event_Titlestart", LANG_SERVER);
			daysmenu.SetTitle(menuinfo18);
			}
			else
			{
			Format(menuinfo29, sizeof(menuinfo29), "%T", "menu_event_Titlevote", LANG_SERVER);
			daysmenu.SetTitle(menuinfo29);
			}
			
			if(g_bWar != null)
			{
				if(g_bWar.BoolValue)
				{
					Format(menuinfo19, sizeof(menuinfo19), "%T", "menu_war", LANG_SERVER);
					daysmenu.AddItem("war", menuinfo19);
				}
			}
			if(g_bFFA != null)
			{
				if(g_bFFA.BoolValue)
				{
					Format(menuinfo20, sizeof(menuinfo20), "%T", "menu_ffa", LANG_SERVER);
					daysmenu.AddItem("ffa", menuinfo20);
				}
			}
			if(g_bZombie != null)
			{
				if(g_bZombie.BoolValue)
				{
					Format(menuinfo21, sizeof(menuinfo21), "%T", "menu_zombie", LANG_SERVER);
					daysmenu.AddItem("zombie", menuinfo21);
				}
			}
			if(g_bHide != null)
			{
				if(g_bHide.BoolValue)
				{
					Format(menuinfo22, sizeof(menuinfo22), "%T", "menu_hide", LANG_SERVER);
					daysmenu.AddItem("hide", menuinfo22);
				}
			}
			if(g_bCatch != null)
			{
				if(g_bCatch.BoolValue)
				{
					Format(menuinfo23, sizeof(menuinfo23), "%T", "menu_catch", LANG_SERVER);
					daysmenu.AddItem("catch", menuinfo23);
				}
			}
			if(g_bJiHad != null)
			{
				if(g_bJiHad.BoolValue)
				{
					Format(menuinfo23, sizeof(menuinfo23), "%T", "menu_jihad", LANG_SERVER);
					daysmenu.AddItem("jihad", menuinfo23);
				}
			}
			if(g_bDodgeBall != null)
			{
				if(g_bDodgeBall.BoolValue)
				{
					Format(menuinfo27, sizeof(menuinfo27), "%T", "menu_dodgeball", LANG_SERVER);
					daysmenu.AddItem("dodgeball", menuinfo27);
				}
			}
			if(g_bNoScope != null)
			{
				if(g_bNoScope.BoolValue)
				{
					Format(menuinfo24, sizeof(menuinfo24), "%T", "menu_noscope", LANG_SERVER);
					daysmenu.AddItem("noscope", menuinfo24);
				}
			}
			if(g_bDuckHunt != null)
			{
				if(g_bDuckHunt.BoolValue)
				{
					Format(menuinfo25, sizeof(menuinfo25), "%T", "menu_duckhunt", LANG_SERVER);
					daysmenu.AddItem("duckhunt", menuinfo25);
				}
			}
			if(g_bZeus != null)
			{
				if(g_bZeus.BoolValue)
				{
					Format(menuinfo17, sizeof(menuinfo17), "%T", "menu_zeus", LANG_SERVER);
					daysmenu.AddItem("knife", menuinfo17);
				}
			}
			if(g_bKnife != null)
			{
				if(g_bKnife.BoolValue)
				{
					Format(menuinfo28, sizeof(menuinfo28), "%T", "menu_knifefight", LANG_SERVER);
					daysmenu.AddItem("knife", menuinfo28);
				}
			}
			if(g_bFreeDay != null)
			{
				if(g_bFreeDay.BoolValue)
				{
					Format(menuinfo26, sizeof(menuinfo26), "%T", "menu_freeday", LANG_SERVER);
					daysmenu.AddItem("freeday", menuinfo26);
				}
			}
			daysmenu.ExitButton = true;
			daysmenu.Display(client, MENU_TIME_FOREVER);

	}
}



public int JBMenuHandler(Menu mainmenu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		mainmenu.GetItem(selection, info, sizeof(info));
		
		if ( strcmp(info,"joinT") == 0 ) 
		{
			ChangeTeam(client,0);
		}
		else if ( strcmp(info,"lastR") == 0 ) 
		{
			FakeClientCommand(client, "sm_lr");
		}
		else if ( strcmp(info,"check") == 0 ) 
		{
			FakeClientCommand(client, "sm_checkplayers");
		}
		else if ( strcmp(info,"rules") == 0 ) 
		{
			FakeClientCommand(client, "sm_rules");
		}
		else if ( strcmp(info,"votewarden") == 0 ) 
		{
			FakeClientCommand(client, "sm_votewarden");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		} 
		else if ( strcmp(info,"guns") == 0 ) 
		{
			FakeClientCommand(client, "sm_guns");
		}
		else if ( strcmp(info,"days") == 0 ) 
		{
			FakeClientCommand(client, "sm_events");
		}
		else if ( strcmp(info,"math") == 0 ) 
		{
			FakeClientCommand(client, "sm_math");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"admin") == 0 ) 
		{
			FakeClientCommand(client, "sm_admin");
		}
		else if ( strcmp(info,"countdown") == 0 ) 
		{
			FakeClientCommand(client, "sm_cdmenu");

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
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"setff") == 0 ) 
		{
			FakeClientCommand(client, "sm_setff");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"kill") == 0 ) 
		{
			FakeClientCommand(client, "sm_killrandom");
		}
		else if (action == MenuAction_End)
		{
		delete mainmenu;
		}
	}
}

public int EventMenuHandler(Menu daysmenu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		
		daysmenu.GetItem(selection, info, sizeof(info));
		
		if ( strcmp(info,"war") == 0 ) 
		{
			if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
			{
				FakeClientCommand(client, "sm_setwar");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
			else
			{
				FakeClientCommand(client, "sm_war");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
		} 
		else if ( strcmp(info,"ffa") == 0 ) 
		{
			if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
			{
				FakeClientCommand(client, "sm_setffa");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
			else
			{
				FakeClientCommand(client, "sm_ffa");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
		} 
		else if ( strcmp(info,"zombie") == 0 ) 
		{
			if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
			{
				FakeClientCommand(client, "sm_setzombie");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
			else
			{
				FakeClientCommand(client, "sm_zombie");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
		} 
		else if ( strcmp(info,"zeus") == 0 ) 
		{
			if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
			{
				FakeClientCommand(client, "sm_setzeus");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
			else
			{
				FakeClientCommand(client, "sm_zeus");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
		} 
		else if ( strcmp(info,"catch") == 0 )
		{
			if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
			{
				FakeClientCommand(client, "sm_setcatch");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
			else
			{
				FakeClientCommand(client, "sm_catch");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
		}
		else if ( strcmp(info,"jihad") == 0 )
		{
			if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
			{
				FakeClientCommand(client, "sm_setjihad");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
			else
			{
				FakeClientCommand(client, "sm_jihad");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
		}
		else if ( strcmp(info,"noscope") == 0 )
		{
			
			if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
			{
				FakeClientCommand(client, "sm_setnoscope");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
			else
			{
				FakeClientCommand(client, "sm_noscope");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
		
		}
		else if ( strcmp(info,"dodgeball") == 0 )
		{
			if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
			{
				FakeClientCommand(client, "sm_setdodgeball");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
			else
			{
				FakeClientCommand(client, "sm_dodgeball");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
		}
		else if ( strcmp(info,"duckhunt") == 0 )
		{
			if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
			{
				FakeClientCommand(client, "sm_setduckhunht");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
			else
			{
				FakeClientCommand(client, "sm_duckhunt");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
		}
		else if ( strcmp(info,"hide") == 0 )
		{
			if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
			{
				FakeClientCommand(client, "sm_sethide");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
			else
			{
				FakeClientCommand(client, "sm_hide");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
		}
		else if ( strcmp(info,"knife") == 0 )
		{
			if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
			{
				FakeClientCommand(client, "sm_setknifefight");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
			else
			{
				FakeClientCommand(client, "sm_knifefight");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
		}
		else if ( strcmp(info,"freeday") == 0 )
		{
			if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
			{
				FakeClientCommand(client, "sm_setfreeday");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
			else
			{
				FakeClientCommand(client, "sm_freeday");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
		}
	}
	else if (action == MenuAction_End)
	{
		delete daysmenu;
	}
}

public Action ChangeTeam(int client, int args)
{
			char info5[255], info6[255], info7[255];
			Menu menu1 = CreateMenu(changemenu);
			Format(info5, sizeof(info5), "%T", "warden_sure", LANG_SERVER);
			menu1.SetTitle(info5);
			Format(info6, sizeof(info6), "%T", "warden_yes", LANG_SERVER);
			Format(info7, sizeof(info7), "%T", "warden_no", LANG_SERVER);
			menu1.AddItem("1", info6);
			menu1.AddItem("0", info7);
			menu1.ExitButton = false;
			menu1.Display(client,MENU_TIME_FOREVER);
}

public int changemenu(Menu menu, MenuAction action, int client, int Position)
{
	if(action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position,Item,sizeof(Item));
		int choice = StringToInt(Item);
		if(choice == 1)
		{
			if (GetClientTeam(client) == CS_TEAM_T)
			{
			ClientCommand(client, "jointeam %i", CS_TEAM_CT);
			}
			if (GetClientTeam(client) == CS_TEAM_CT)
			{
			ClientCommand(client, "jointeam %i", CS_TEAM_T);
			}
		}
	}
}