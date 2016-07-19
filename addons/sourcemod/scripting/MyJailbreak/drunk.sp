//includes
#include <cstrike>
#include <sourcemod>
#include <smartjaildoors>
#include <warden>
#include <emitsoundany>
#include <colors>
#include <autoexecconfig>
#include <myjailbreak>
#include <lastrequest>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//Booleans
bool IsDrunk;
bool StartDrunk;

//ConVars    gc_i = global convar integer / gc_i = global convar bool ...
ConVar gc_bPlugin;
ConVar gc_bSetW;
ConVar gc_iCooldownStart;
ConVar gc_bSetA;
ConVar gc_bSpawnCell;
ConVar gc_bVote;
ConVar gc_iCooldownDay;
ConVar gc_iRoundTime;
ConVar gc_iTruceTime;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar gc_bSounds;
ConVar gc_iRounds;
ConVar gc_sSoundStartPath;
ConVar gc_sCustomCommand;
ConVar g_iGetRoundTime;
//ConVar gc_bInvertX;
//ConVar gc_bInvertY;
ConVar gc_bWiggle;
ConVar gc_sAdminFlag;
ConVar gc_bAllowLR;


//Integers    g_i = global integer
int g_iOldRoundTime;
int g_iCoolDown;
int g_iTruceTime;
int g_iVoteCount;
int g_iRound;
int g_iMaxRound;

//Floats    g_i = global float
float g_fPos[3];
float g_DrunkAngles[20] = {0.0, 5.0, 10.0, 15.0, 20.0, 25.0, 20.0, 15.0, 10.0, 5.0, 0.0, -5.0, -10.0, -15.0, -20.0, -25.0, -20.0, -15.0, -10.0, -5.0};


//Handles
Handle TruceTimer;
Handle DrunkMenu;
Handle DrunkTimer;

//Strings    g_s = global string
char g_sHasVoted[1500];
char g_sSoundStartPath[256];
char g_sCustomCommand[64];
char g_sEventsLogFile[PLATFORM_MAX_PATH];
char g_sAdminFlag[32];
char g_sOverlayStartPath[256];

public Plugin myinfo = {
	name = "MyJailbreak - Drunk",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = PLUGIN_VERSION,
	url = URL_LINK
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.Drunk.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_setdrunk", SetDrunk, "Allows the Admin or Warden to set drunk as next round");
	RegConsoleCmd("sm_drunk", VoteDrunk, "Allows players to vote for a drunk");
	
	//AutoExecConfig
	AutoExecConfig_SetFile("Drunk", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_drunk_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_drunk_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_sCustomCommand = AutoExecConfig_CreateConVar("sm_drunk_cmd", "!curse", "Set your custom chat command for Event voting. no need for sm_ or !");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_drunk_warden", "1", "0 - disabled, 1 - allow warden to set drunk round", _, true,  0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_drunk_admin", "1", "0 - disabled, 1 - allow admin/vip to set drunk round", _, true,  0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_zombie_flag", "g", "Set flag for admin/vip to set this Event Day.");
	gc_bVote = AutoExecConfig_CreateConVar("sm_drunk_vote", "1", "0 - disabled, 1 - allow player to vote for drunk", _, true,  0.0, true, 1.0);
	gc_bSpawnCell = AutoExecConfig_CreateConVar("sm_drunk_spawn", "0", "0 - T teleport to CT spawn, 1 - cell doors auto open", _, true,  0.0, true, 1.0);
//	gc_bInvertX = AutoExecConfig_CreateConVar("sm_drunk_invert_x", "1", "Invert movement on the x-axis (left & right)", _, true, 0.0, true, 1.0);
//	gc_bInvertY = AutoExecConfig_CreateConVar("sm_drunk_invert_y", "1", "Invert movement on the y-axis (forward & back)", _, true, 0.0, true, 1.0);
	gc_bWiggle = AutoExecConfig_CreateConVar("sm_drunk_wiggle", "1", "Wiggle with the screen", _, true, 0.0, true, 1.0);
	gc_iRounds = AutoExecConfig_CreateConVar("sm_drunk_rounds", "1", "Rounds to play in a row", _, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_drunk_roundtime", "5", "Round time in minutes for a single drunk round", _, true, 1.0);
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_drunk_trucetime", "15", "Time in seconds players can't deal damage", _, true,  0.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_drunk_cooldown_day", "3", "Rounds cooldown after a event until event can be start again", _, true,  0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_drunk_cooldown_start", "3", "Rounds until event can be start after mapchange.", _, true, 0.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_drunk_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true, 0.1, true, 1.0);
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_drunk_sounds_start", "music/MyJailbreak/drunk.mp3", "Path to the soundfile which should be played for a start.");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_drunk_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true,  0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_drunk_overlays_start", "overlays/MyJailbreak/drunk" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_bAllowLR = AutoExecConfig_CreateConVar("sm_drunk_allow_lr", "0" , "0 - disabled, 1 - enable LR for last round and end eventday", _, true, 0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("round_end", RoundEnd);
	HookEvent("player_death", playerDeath);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sCustomCommand, OnSettingChanged);
	HookConVarChange(gc_sAdminFlag, OnSettingChanged);
	
	//Find
	g_iGetRoundTime = FindConVar("mp_roundtime");
	gc_sOverlayStartPath.GetString(g_sOverlayStartPath , sizeof(g_sOverlayStartPath));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
	gc_sCustomCommand.GetString(g_sCustomCommand , sizeof(g_sCustomCommand));
	gc_sAdminFlag.GetString(g_sAdminFlag , sizeof(g_sAdminFlag));
	
	SetLogFile(g_sEventsLogFile, "Events");
}

//ConVarChange for Strings

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sOverlayStartPath)    //Add overlay to download and precache table if changed
	{
		strcopy(g_sOverlayStartPath, sizeof(g_sOverlayStartPath), newValue);
		if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayStartPath);
	}
	else if(convar == gc_sSoundStartPath)    //Add sound to download and precache table if changed
	{
		strcopy(g_sSoundStartPath, sizeof(g_sSoundStartPath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStartPath);
	}
	else if(convar == gc_sAdminFlag)
	{
		strcopy(g_sAdminFlag, sizeof(g_sAdminFlag), newValue);
	}
	else if(convar == gc_sCustomCommand)    //Register the custom command if changed
	{
		strcopy(g_sCustomCommand, sizeof(g_sCustomCommand), newValue);
		char sBufferCMD[64];
		Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
		if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
			RegConsoleCmd(sBufferCMD, VoteDrunk, "Allows players to vote for Drunk");
	}
}

//Initialize Event

public void OnMapStart()
{
	//set default start values
	g_iVoteCount = 0; //how many player voted for the event
	g_iRound = 0;
	IsDrunk = false;
	StartDrunk = false;
	
	//Precache Sound & Overlay
	if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStartPath);
	if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayStartPath);
}

public void OnConfigsExecuted()
{
	//Find Convar Times
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iMaxRound = gc_iRounds.IntValue;
	
	//Register the custom command
	char sBufferCMD[64];
	Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
	if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMD, VoteDrunk, "Allows players to vote for Drunk");
}

//Admin & Warden set Event

public Action SetDrunk(int client,int args)
{
	if (gc_bPlugin.BoolValue) //is plugin enabled?
	{
		if(client == 0)
		{
			StartNextRound();
			if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event Drunk was started by groupvoting");
		}
		else if (warden_iswarden(client)) //is player warden?
		{
			if (gc_bSetW.BoolValue) //is warden allowed to set?
			{
				char EventDay[64];
				GetEventDay(EventDay);
				
				if(StrEqual(EventDay, "none", false)) //is an other event running or set?
				{
					if (g_iCoolDown == 0) //is event cooled down?
					{
						StartNextRound(); //prepare Event for next round
						if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event drunken was started by warden %L", client);
					}
					else CPrintToChat(client, "%t %t", "drunk_tag" , "drunk_wait", g_iCoolDown);
				}
				else CPrintToChat(client, "%t %t", "drunk_tag" , "drunk_progress" , EventDay);
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "nocscope_setbywarden");
		}
		else if (CheckVipFlag(client,g_sAdminFlag))
		{
			if (gc_bSetA.BoolValue) //is admin allowed to set?
			{
				char EventDay[64];
				GetEventDay(EventDay);
				
				if(StrEqual(EventDay, "none", false)) //is an other event running or set?
				{
					if (g_iCoolDown == 0) //is event cooled down?
					{
						StartNextRound(); //prepare Event for next round;
						if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event drunken was started by admin %L", client);
					}
					else CPrintToChat(client, "%t %t", "drunk_tag" , "drunk_wait", g_iCoolDown);
				}
				else CPrintToChat(client, "%t %t", "drunk_tag" , "drunk_progress" , EventDay);
			}
			else CPrintToChat(client, "%t %t", "nocscope_tag" , "drunk_setbyadmin");
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "drunk_tag" , "drunk_disabled");
}

//Voting for Event

public Action VoteDrunk(int client,int args)
{
	char steamid[64];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	
	if (gc_bPlugin.BoolValue) //is plugin enabled?
	{	
		if (gc_bVote.BoolValue) //is voting enabled?
		{	
			char EventDay[64];
			GetEventDay(EventDay);
			
			if(StrEqual(EventDay, "none", false)) //is an other event running or set?
			{
				if (g_iCoolDown == 0) //is event cooled down?
				{
					if (StrContains(g_sHasVoted, steamid, true) == -1) //has player already voted
					{
						int playercount = (GetClientCount(true) / 2);
						g_iVoteCount++;
						int Missing = playercount - g_iVoteCount + 1;
						Format(g_sHasVoted, sizeof(g_sHasVoted), "%s,%s", g_sHasVoted, steamid);
						
						if (g_iVoteCount > playercount) 
						{
							StartNextRound(); //prepare Event for next round
							if(MyJBLogging(true)) LogToFileEx(g_sEventsLogFile, "Event drunken was started by voting");
						}
						else CPrintToChatAll("%t %t", "drunk_tag" , "drunk_need", Missing, client);
					}
					else CPrintToChat(client, "%t %t", "drunk_tag" , "drunk_voted");
				}
				else CPrintToChat(client, "%t %t", "drunk_tag" , "drunk_wait", g_iCoolDown);
			}
			else CPrintToChat(client, "%t %t", "drunk_tag" , "drunk_progress" , EventDay);
		}
		else CPrintToChat(client, "%t %t", "drunk_tag" , "drunk_voting");
	}
	else CPrintToChat(client, "%t %t", "drunk_tag" , "drunk_disabled");
}

//Prepare Event

void StartNextRound()
{
	StartDrunk = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;
	
	SetEventDay("drunk"); //tell myjailbreak new event is set
	SetEventDayPlaned(true);
	g_iOldRoundTime = g_iGetRoundTime.IntValue; //save original round time
	g_iGetRoundTime.IntValue = gc_iRoundTime.IntValue;//set event round time
	
	CPrintToChatAll("%t %t", "drunk_tag" , "drunk_next");
	PrintHintTextToAll("%t", "drunk_next_nc");
}

//Round start

public void RoundStart(Handle event, char[] name, bool dontBroadcast)
{
	if (StartDrunk || IsDrunk)
	{
		//disable other plugins
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_weapons_enable", 0);
		SetCvar("sm_menu_enable", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("mp_teammates_are_enemies", 1);
		SetEventDayPlaned(false);
		SetEventDayRunning(true);
		IsDrunk = true;
		
		g_iRound++; //Add Round number
		StartDrunk = false;
		SJD_OpenDoors(); //open Jail
		
		
		//Find Position in CT Spawn
		
		int RandomCT = 0;
		
		LoopClients(client)
		{
			if (IsClientInGame(client))
			{
				if (GetClientTeam(client) == CS_TEAM_CT)
				{
					RandomCT = client;
					break;
				}
			}
		}
		if (RandomCT)
		{	
			GetClientAbsOrigin(RandomCT, g_fPos);
			
			g_fPos[2] = g_fPos[2] + 5;
			
			if (g_iRound > 0)
			{
				LoopClients(client)
				{
					//Give Players Start Equiptment & parameters
					
					if (IsClientInGame(client))
					{
						StripAllWeapons(client);
						
						if (GetClientTeam(client) == CS_TEAM_CT && IsValidClient(client, false, false))
						{
							//here start Equiptment & parameters
						}
						if (GetClientTeam(client) == CS_TEAM_T && IsValidClient(client, false, false))
						{
							//here start Equiptment & parameters
						}
						CreateInfoPanel(client);
						GivePlayerItem(client, "weapon_knife"); //give Knife
						SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true); //NoBlock
						SendPanelToClient(DrunkMenu, client, NullHandler, 20); //open info Panel
						SetEntProp(client, Prop_Data, "m_takedamage", 0, 1); //disable damage
						if (!gc_bSpawnCell.BoolValue || (gc_bSpawnCell.BoolValue && !SJD_IsCurrentMapConfigured)) //spawn Terrors to CT Spawn  //spawn Terrors to CT Spawn
						{
							TeleportEntity(client, g_fPos, NULL_VECTOR, NULL_VECTOR);
						}
						if(gc_bWiggle.BoolValue) DrunkTimer = CreateTimer(1.0, Timer_Drunk, client, TIMER_REPEAT);
					}
				}
				//Set Start Timer
				g_iTruceTime--;
				TruceTimer = CreateTimer(1.0, StartTimer, _, TIMER_REPEAT);
				
				//enable lr on last round
				if (gc_bAllowLR.BoolValue)
				{
					if (g_iRound == g_iMaxRound)
					{
						SetCvar("sm_hosties_lr", 1);
					}
				}
				
				CPrintToChatAll("%t %t", "drunk_tag" ,"drunk_rounds", g_iRound, g_iMaxRound);
			}
		}
	}
	else
	{
		//If Event isnt running - subtract cooldown round
		
		char EventDay[64];
		GetEventDay(EventDay);
		
		if(!StrEqual(EventDay, "none", false))
		{
			g_iCoolDown = gc_iCooldownDay.IntValue + 1;
		}
		else if (g_iCoolDown > 0) g_iCoolDown--;
	}
}

public int OnAvailableLR(int Announced)
{
	if (IsDrunk && gc_bAllowLR.BoolValue)
	{
		LoopClients(client)
		{
			if (IsClientInGame(client)) SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true); //disbale noblock
			KillDrunk(client);
			StripAllWeapons(client);
			if (GetClientTeam(client) == CS_TEAM_CT)
			{
				FakeClientCommand(client, "sm_guns");
			}
			GivePlayerItem(client, "weapon_knife");
		}
		delete DrunkTimer; 
		delete TruceTimer; //kill start time if still running
		if (g_iRound == g_iMaxRound) //if this was the last round
		{
			//return to default start values
			IsDrunk = false;
			StartDrunk = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			
			//enable other pluigns
			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_weapons_enable", 1);
			SetCvar("sv_infinite_ammo", 0);
			SetCvar("mp_teammates_are_enemies", 0);
			SetCvar("sm_menu_enable", 1);
			SetCvar("sm_warden_enable", 1);
			
			g_iGetRoundTime.IntValue = g_iOldRoundTime; //return to original round time
			SetEventDay("none"); //tell myjailbreak event is ended
			SetEventDayRunning(false);
			
			CPrintToChatAll("%t %t", "drunk_tag" , "drunk_end");
		}
	}

}

stock void CreateInfoPanel(int client)
{
	//Create info Panel
	char info[255];

	DrunkMenu = CreatePanel();
	Format(info, sizeof(info), "%T", "drunk_info_title", client);
	SetPanelTitle(DrunkMenu, info);
	DrawPanelText(DrunkMenu, "                                   ");
	Format(info, sizeof(info), "%T", "drunk_info_line1", client);
	DrawPanelText(DrunkMenu, info);
	DrawPanelText(DrunkMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "drunk_info_line2", client);
	DrawPanelText(DrunkMenu, info);
	Format(info, sizeof(info), "%T", "drunk_info_line3", client);
	DrawPanelText(DrunkMenu, info);
	Format(info, sizeof(info), "%T", "drunk_info_line4", client);
	DrawPanelText(DrunkMenu, info);
	Format(info, sizeof(info), "%T", "drunk_info_line5", client);
	DrawPanelText(DrunkMenu, info);
	Format(info, sizeof(info), "%T", "drunk_info_line6", client);
	DrawPanelText(DrunkMenu, info);
	Format(info, sizeof(info), "%T", "drunk_info_line7", client);
	DrawPanelText(DrunkMenu, info);
	DrawPanelText(DrunkMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "warden_close", client);
	DrawPanelItem(DrunkMenu, info); 
	SendPanelToClient(DrunkMenu, client, NullHandler, 20); //open info Panel
}

//Round End

public void RoundEnd(Handle event, char[] name, bool dontBroadcast)
{
	DrunkTimer = null;
	delete DrunkTimer;
	int winner = GetEventInt(event, "winner");
	
	if (IsDrunk) //if event was running this round
	{
		LoopClients(client)
		{
			if (IsClientInGame(client)) SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true); //disbale noblock
			KillDrunk(client);
		}
		delete DrunkTimer; 
		delete TruceTimer; //kill start time if still running
		if (winner == 2) PrintHintTextToAll("%t", "drunk_twin_nc");
		if (winner == 3) PrintHintTextToAll("%t", "drunk_ctwin_nc");
		if (g_iRound == g_iMaxRound && !gc_bAllowLR.BoolValue) //if this was the last round
		{
			//return to default start values
			IsDrunk = false;
			StartDrunk = false;
			g_iRound = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			
			//enable other pluigns
			SetCvar("sm_hosties_lr", 1);
			SetCvar("sm_weapons_enable", 1);
			SetCvar("sv_infinite_ammo", 0);
			SetCvar("mp_teammates_are_enemies", 0);
			SetCvar("sm_menu_enable", 1);
			SetCvar("sm_warden_enable", 1);
			
			g_iGetRoundTime.IntValue = g_iOldRoundTime; //return to original round time
			SetEventDay("none"); //tell myjailbreak event is ended
			SetEventDayRunning(false);
			
			CPrintToChatAll("%t %t", "drunk_tag" , "drunk_end");
		}
	}
	if (StartDrunk)
	{
		LoopClients(i) CreateInfoPanel(i);
		
		CPrintToChatAll("%t %t", "drunk_tag" , "drunk_next");
		PrintHintTextToAll("%t", "drunk_next_nc");
	}
}

//Map End

public void OnMapEnd()
{
	//return to default start values
	IsDrunk = false;
	StartDrunk = false;
	delete TruceTimer; //kill start time if still running
	delete DrunkTimer; //kill start time if still running
	g_iVoteCount = 0;
	g_iRound = 0;
	g_sHasVoted[0] = '\0'; 
}

//Start Timer

public Action StartTimer(Handle timer)
{
	if (g_iTruceTime > 1) //countdown to start
	{
		g_iTruceTime--;
		LoopClients(client)
		if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				PrintCenterText(client,"%t", "drunk_timeuntilstart_nc", g_iTruceTime);
			}
		return Plugin_Continue;
	}
	
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	if (g_iRound > 0)
	{
		LoopClients(client)
		{
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
				PrintCenterText(client,"%t", "drunk_start_nc");
			}
			if(gc_bOverlays.BoolValue) ShowOverlay(client, g_sOverlayStartPath, 5.0);
			if(gc_bSounds.BoolValue)
			{
				EmitSoundToAllAny(g_sSoundStartPath);
			}
		}
		CPrintToChatAll("%t %t", "drunk_tag" , "drunk_start");
	}
	
	TruceTimer = null;
	
	return Plugin_Stop;
}

public Action playerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(GetEventInt(event, "userid")); // Get the dead clients id
	
	KillDrunk(client);
}

//Switch WSAD
/*
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon) 
{
	if(IsDrunk)
	{
		if(gc_bInvertX.BoolValue) 
		{
			vel[1] = -vel[1]; //Will always equal to the opposite value, according to rules of arithmetic.
			
			if(buttons & IN_MOVELEFT) //Fixes walking animations for CS:GO.
			{
				buttons &= ~IN_MOVELEFT;
				buttons |= IN_MOVERIGHT;
			}
			else if(buttons & IN_MOVERIGHT)
			{
				buttons &= ~IN_MOVERIGHT;
				buttons |= IN_MOVELEFT;
			}
		}
		if(gc_bInvertY.BoolValue)
		{
			vel[0] = -vel[0];
			
			if(buttons & IN_FORWARD)
			{
				buttons &= ~IN_FORWARD;
				buttons |= IN_BACK;
			}
			else if(buttons & IN_BACK)
			{
				buttons &= ~IN_BACK;
				buttons |= IN_FORWARD;
			}
		}
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
*/
// drunk

public Action Timer_Drunk(Handle timer, any client)
{
	if(IsDrunk && IsValidClient(client,false,false))
	{
		float angs[3];
		GetClientEyeAngles(client, angs);
		
		angs[2] = g_DrunkAngles[GetRandomInt(0,100) % 20];
		
		TeleportEntity(client, NULL_VECTOR, angs, NULL_VECTOR);
		
	}
	return Plugin_Handled;
}

void KillDrunk(int client)
{
	float angs[3];
	GetClientEyeAngles(client, angs);
	
	angs[2] = 0.0;
	
	TeleportEntity(client, NULL_VECTOR, angs, NULL_VECTOR);	
}
