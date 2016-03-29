//Includes
#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>
#include <wardn>
#include <emitsoundany>
#include <smartjaildoors>
#include <smlib>
#include <colors>
#include <autoexecconfig>

//Compiler Options
#pragma semicolon 1

//Defines
#define LoopAliveClients(%1) for(int %1 = 1;%1 <= MaxClients;%1++) if(IsValidClient(%1, true))
#define PLUGIN_VERSION "0.1"

//ConVars
ConVar gc_bOpenTimer;
ConVar gc_bOpenTimerWarden;
ConVar gc_bPlugin;
ConVar gc_bVote;
ConVar gc_bStayWarden;
ConVar gc_bNoBlock;
ConVar gc_bColor;
ConVar gc_bOpen;
ConVar gc_bSounds;
ConVar gc_bFF;
ConVar gc_sSoundPath1;
ConVar gc_sSoundPath2;
ConVar gc_sModelPath;
ConVar gc_bModel;
ConVar gc_bTag;
ConVar gc_bBetterNotes;
ConVar g_bFF;

//Integers
int g_iVoteCount;
int Warden = -1;
int tempwarden[MAXPLAYERS+1] = -1;
int g_CollisionOffset;
int opentimer;

//Handles
Handle g_fward_onBecome;
Handle g_fward_onRemove;
Handle gF_OnWardenCreatedByUser = null;
Handle gF_OnWardenCreatedByAdmin = null;
Handle gF_OnWardenDisconnected = null;
Handle gF_OnWardenDeath = null;
Handle gF_OnWardenRemovedBySelf = null;
Handle gF_OnWardenRemovedByAdmin = null;
Handle g_hOpenTimer=null;
Handle g_iWardenColorRed;
Handle g_iWardenColorGreen;
Handle g_iWardenColorBlue;
Handle countertime = null;

//Strings
char g_sHasVoted[1500];
//char g_sModelPath[256]; // change model back on unwarden
char g_sWardenModel[256];
char g_sSoundPath2[256];
char g_sSoundPath1[256];

public Plugin myinfo = {
	name = "MyJailbreak - Warden",
	author = "shanapu, ecca, ESKO & .#zipcore",
	description = "Jailbreak Warden script",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart() 
{
	//Translation
	LoadTranslations("MyJailbreakWarden.phrases");
	
	//Client commands
	RegConsoleCmd("sm_noblockon", noblockon); 
	RegConsoleCmd("sm_noblockoff", noblockoff); 
	RegConsoleCmd("sm_w", BecomeWarden);
	RegConsoleCmd("sm_warden", BecomeWarden);
	RegConsoleCmd("sm_uw", ExitWarden);
	RegConsoleCmd("sm_unwarden", ExitWarden);
	RegConsoleCmd("sm_hg", BecomeWarden);
	RegConsoleCmd("sm_headguard", BecomeWarden);
	RegConsoleCmd("sm_uhg", ExitWarden);
	RegConsoleCmd("sm_unheadguard", ExitWarden);
	RegConsoleCmd("sm_c", BecomeWarden);
	RegConsoleCmd("sm_commander", BecomeWarden);
	RegConsoleCmd("sm_uc", ExitWarden);
	RegConsoleCmd("sm_uncommander", ExitWarden);
	RegConsoleCmd("sm_open", OpenDoors);
	RegConsoleCmd("sm_close", CloseDoors);
	RegConsoleCmd("sm_vw", VoteWarden);
	RegConsoleCmd("sm_votewarden", VoteWarden);
	RegConsoleCmd("sm_setff", ToggleFF);
	
	//Admin commands
	RegAdminCmd("sm_sw", SetWarden, ADMFLAG_GENERIC);
	RegAdminCmd("sm_setwarden", SetWarden, ADMFLAG_GENERIC);
	RegAdminCmd("sm_rw", RemoveWarden, ADMFLAG_GENERIC);
	RegAdminCmd("sm_removewarden", RemoveWarden, ADMFLAG_GENERIC);

	//Forwards
	gF_OnWardenCreatedByUser = CreateGlobalForward("Warden_OnWardenCreatedByUser", ET_Ignore, Param_Cell);
	gF_OnWardenCreatedByAdmin = CreateGlobalForward("Warden_OnWardenCreatedByAdmin", ET_Ignore, Param_Cell);
	g_fward_onBecome = CreateGlobalForward("warden_OnWardenCreated", ET_Ignore, Param_Cell);
	gF_OnWardenDisconnected = CreateGlobalForward("Warden_OnWardenDisconnected", ET_Ignore, Param_Cell);
	gF_OnWardenDeath = CreateGlobalForward("Warden_OnWardenDeath", ET_Ignore, Param_Cell);
	gF_OnWardenRemovedBySelf = CreateGlobalForward("Warden_OnWardenRemovedBySelf", ET_Ignore, Param_Cell);
	gF_OnWardenRemovedByAdmin = CreateGlobalForward("Warden_OnWardenRemovedByAdmin", ET_Ignore, Param_Cell);
	g_fward_onRemove = CreateGlobalForward("warden_OnWardenRemoved", ET_Ignore, Param_Cell);
	
	//AutoExecConfig
	AutoExecConfig_SetFile("MyJailbreak_warden");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_warden_version", PLUGIN_VERSION,	"The version of the SourceMod plugin MyJailBreak - Warden", FCVAR_REPLICATED|FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_warden_enable", "1", "0 - disabled, 1 - enable warden");	
	gc_bBetterNotes = AutoExecConfig_CreateConVar("sm_warden_better_notifications", "1", "0 - disabled, 1 - Will use hint and center text", _, true, 0.0, true, 1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_warden_vote", "1", "0 - disabled, 1 - enable player vote aginst warden");	
	gc_bStayWarden = AutoExecConfig_CreateConVar("sm_warden_stay", "1", "0 - disabled, 1 - enable warden stay after round end");	
	gc_bNoBlock = AutoExecConfig_CreateConVar("sm_warden_noblock", "1", "0 - disabled, 1 - enable setable noblock for warden");	
	gc_bFF = AutoExecConfig_CreateConVar("sm_warden_ff", "1", "0 - disabled, 1 - enable switch ff for T ");
	gc_bOpen = AutoExecConfig_CreateConVar("sm_wardenopen_enable", "1", "0 - disabled, 1 - warden can open/close cells");
	g_hOpenTimer = AutoExecConfig_CreateConVar("sm_wardenopen_time", "60", "Time in seconds for open doors on round start automaticly");
	gc_bOpenTimer = AutoExecConfig_CreateConVar("sm_wardenopen_time_enable", "1", "should doors open automatic 0- no 1 yes");	 // TODO: DONT WORK
	gc_bOpenTimerWarden = AutoExecConfig_CreateConVar("sm_wardenopen_time_warden", "1", "should doors open automatic after sm_wardenopen_time when there is a warden? needs sm_wardenopen_time_enable 1"); 
	gc_bColor = AutoExecConfig_CreateConVar("sm_wardencolor_enable", "1", "0 - disabled, 1 - enable warden colored");
	g_iWardenColorRed = AutoExecConfig_CreateConVar("sm_wardencolor_red", "0","What color to turn the warden into (set R, G and B values to 255 to disable) (Rgb): x - red value", 0, true, 0.0, true, 255.0);
	g_iWardenColorGreen = AutoExecConfig_CreateConVar("sm_wardencolor_green", "0","What color to turn the warden into (rGb): x - green value", 0, true, 0.0, true, 255.0);
	g_iWardenColorBlue = AutoExecConfig_CreateConVar("sm_wardencolor_blue", "255","What color to turn the warden into (rgB): x - blue value", 0, true, 0.0, true, 255.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_wardensounds_enable", "1", "0 - disabled, 1 - enable warden sounds");
	gc_sSoundPath1 = AutoExecConfig_CreateConVar("sm_warden_sounds_path", "music/myjailbreak/warden.mp3", "Path to the sound which should be played for a int warden.");
	gc_sSoundPath2 = AutoExecConfig_CreateConVar("sm_warden_sounds_path2", "music/myjailbreak/unwarden.mp3", "Path to the sound which should be played when there is no warden anymore.");
	gc_bModel = AutoExecConfig_CreateConVar("sm_warden_model", "1", "0 - disabled, 1 - enable warden model", 0, true, 0.0, true, 1.0);
	gc_sModelPath = AutoExecConfig_CreateConVar("sm_warden_model_path", "models/player/custom_player/legacy/security.mdl", "Path to the model for zombies.");
	gc_bTag = AutoExecConfig_CreateConVar("sm_warden_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch you sv_tags", 0, true, 0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_death", playerDeath);
	HookConVarChange(gc_sModelPath, OnSettingChanged);
	HookConVarChange(gc_sSoundPath2, OnSettingChanged);
	HookConVarChange(gc_sSoundPath1, OnSettingChanged);
	
	//FindConVar
	g_bFF = FindConVar("mp_teammates_are_enemies");
	gc_sSoundPath1.GetString(g_sSoundPath1, sizeof(g_sSoundPath1));
	gc_sSoundPath2.GetString(g_sSoundPath2, sizeof(g_sSoundPath2));
	gc_sModelPath.GetString(g_sWardenModel, sizeof(g_sWardenModel));
	
	
	AddCommandListener(HookPlayerChat, "say");
	
	g_CollisionOffset = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
	
	g_iVoteCount = 0;
}


public Action:Event_RoundStart(Handle:event, const char[] name, bool:dontBroadcast)
{
	if (countertime != null)
		KillTimer(countertime);
		
	countertime = null;
	
	if(gc_bPlugin.BoolValue)	
	{
		opentimer = GetConVarInt(g_hOpenTimer);
		countertime = CreateTimer(1.0, ccounter, _, TIMER_REPEAT);
	}
	else if(!gc_bPlugin.BoolValue)
	{
			Warden = -1;
	}
	if(!gc_bStayWarden.BoolValue)
	{
			Warden = -1;
	}

}

public void OnConfigsExecuted()
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
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, interr_max)
{
	CreateNative("warden_exist", Native_ExistWarden);
	CreateNative("warden_iswarden", Native_IsWarden);
	CreateNative("warden_set", Native_SetWarden);
	CreateNative("warden_removed", Native_RemoveWarden);
	CreateNative("warden_get", Native_GetWarden);
	
	RegPluginLibrary("warden");
	return APLRes_Success;
}

public void OnMapStart()
{
	if(gc_bSounds.BoolValue)	
	{
		PrecacheSoundAnyDownload(g_sSoundPath1);
		PrecacheSoundAnyDownload(g_sSoundPath2);
	}	
	g_iVoteCount = 0;
	PrecacheModel(g_sWardenModel);
	PrecacheModel("models/player/ctm_gsg9.mdl");

}

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sSoundPath1)
	{
		strcopy(g_sSoundPath1, sizeof(g_sSoundPath1), newValue);
		PrecacheSoundAnyDownload(g_sSoundPath1);
	}
	else if(convar == gc_sSoundPath2)
	{
		strcopy(g_sSoundPath2, sizeof(g_sSoundPath2), newValue);
		PrecacheSoundAnyDownload(g_sSoundPath2);
	}
	else if(convar == gc_sModelPath)
	{
		strcopy(g_sWardenModel, sizeof(g_sWardenModel), newValue);
	}
}

public Action:Event_RoundEnd(Handle:event, const char[] name, bool:dontbroadcast)
{
		LOOP_CLIENTS(i, CLIENTFILTER_TEAMONE)
				{
						EnableBlock(i);
				}
}

public Action BecomeWarden(int client, int args)
{
	if(gc_bPlugin.BoolValue)
	{
		if (Warden == -1)
		{
			if (GetClientTeam(client) == CS_TEAM_CT)
			{
				if (IsPlayerAlive(client))
				{
				SetTheWarden(client);
				Call_StartForward(gF_OnWardenCreatedByUser);
				Call_PushCell(client);
				Call_Finish();
				}
				else CPrintToChat(client, "%t %t", "warden_tag" , "warden_playerdead");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_ctsonly");
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_exist", Warden);
	}else CPrintToChat(client, "%t %t", "warden_tag" , "warden_disabled");
}

public Action ExitWarden(int client, int args) 
{
	if(gc_bPlugin.BoolValue)
	{
		if(client == Warden)
		{
			CPrintToChatAll("%t %t", "warden_tag" , "warden_retire", client);
			
			if(gc_bBetterNotes.BoolValue)
			{
				PrintCenterTextAll("%t", "warden_retire_nc", client);
				PrintHintTextToAll("%t", "warden_retire_nc", client);
			}
			Warden = -1;
			Forward_OnWardenRemoved(client);
			SetEntityRenderColor(client, 255, 255, 255, 255);
			SetEntityModel(client, "models/player/ctm_gsg9.mdl");
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "warden_tag" , "warden_disabled");
}

public Action VoteWarden(int client,int args)
{
	if(gc_bPlugin.BoolValue)
	{
		if(gc_bVote.BoolValue)
		{
			char steamid[64];
			GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
			if (warden_exist())
			{
				if (StrContains(g_sHasVoted, steamid, true) == -1)
				{
					int playercount = (GetClientCount(true) / 2);
					g_iVoteCount++;
					int Missing = playercount - g_iVoteCount + 1;
					Format(g_sHasVoted, sizeof(g_sHasVoted), "%s,%s", g_sHasVoted, steamid);
					
					if (g_iVoteCount > playercount)
					{
						RemoveTheWarden(client);
						g_iVoteCount = 0;
					}
					else CPrintToChatAll("%t %t", "warden_tag" , "warden_need", Missing);
				}
				else CPrintToChat(client, "%t %t", "warden_tag" , "warden_voted");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_noexist");
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_voting");
	}
	else CPrintToChat(client, "%t %t", "warden_tag" , "warden_disabled");
}

public Action:playerDeath(Handle:event, const char[] name, bool:dontBroadcast) 
{
	int client = GetClientOfUserId(GetEventInt(event, "userid")); // Get the dead clients id
	
	if(client == Warden) // Aww damn , he is the warden
	{
		if(gc_bSounds.BoolValue)
		{
			EmitSoundToAllAny(g_sSoundPath2);
		}
		CPrintToChatAll("%t %t", "warden_tag" , "warden_dead", client);
		
		if(gc_bBetterNotes.BoolValue)
		{
			PrintCenterTextAll("%t", "warden_dead_nc", client);
			PrintHintTextToAll("%t", "warden_dead_nc", client);
		}
		
		Warden = -1;
		Call_StartForward(gF_OnWardenDeath);
		Call_PushCell(client);
		Call_Finish();
	}
}

public Action SetWarden(int client,int args)
{
	if(gc_bPlugin.BoolValue)	
	{
		if(IsValidClient(client))
		{
			Menu menu = CreateMenu(m_SetWarden);
			menu.SetTitle("Select players");
			LoopAliveClients(i)
			{
				if(GetClientTeam(i) == CS_TEAM_CT && IsClientWarden(i) == false)
				{
					char userid[11];
					char username[MAX_NAME_LENGTH];
					IntToString(GetClientUserId(i), userid, sizeof(userid));
					Format(username, sizeof(username), "%N", i);
					menu.AddItem(userid,username);
				}
			}
			menu.ExitButton = true;
			menu.Display(client,MENU_TIME_FOREVER);
		}
	}
	return Plugin_Handled;
}

public int m_SetWarden(Menu menu, MenuAction action, int client, int Position)
{
	if(action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position,Item,sizeof(Item));
		LoopAliveClients(i)
		{
			if(GetClientTeam(i) == CS_TEAM_CT && IsClientWarden(i) == false)
			{
				int userid = GetClientUserId(i);
				if(userid == StringToInt(Item))
				{
					if(IsWarden() == true)
					{
						tempwarden[client] = userid;
						Menu menu1 = CreateMenu(m_WardenOverwrite);
						char buffer[64];
						Format(buffer,sizeof(buffer), "Kick warden %N?", Warden);
						menu1.SetTitle(buffer);
						menu1.AddItem("1", "Yes");
						menu1.AddItem("0", "No");
						menu1.ExitButton = false;
						menu1.Display(client,MENU_TIME_FOREVER);
					}
					else
					{
						Warden = i;
						CPrintToChatAll("%t %t", "warden_tag" , "warden_new", Warden);
						CreateTimer(0.5, Timer_WardenFixColor, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
						Call_StartForward(gF_OnWardenCreatedByAdmin);
						Call_PushCell(i);
						Call_Finish();
					}
				}
			}
		}
	}
}

public int m_WardenOverwrite(Menu menu, MenuAction action, int client, int Position)
{
	if(action == MenuAction_Select && IsClientWarden(client))
	{
		char Item[11];
		menu.GetItem(Position,Item,sizeof(Item));
		int choice = StringToInt(Item);
		if(choice == 1)
		{
			int newwarden = GetClientOfUserId(tempwarden[client]);
			CPrintToChatAll("%t %t", "warden_tag" , "warden_removed", Warden);
			CPrintToChatAll("%t %t", "warden_tag" , "warden_new", newwarden);
			Warden = newwarden;
			CreateTimer(0.5, Timer_WardenFixColor, newwarden, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			Call_StartForward(gF_OnWardenCreatedByAdmin);
			Call_PushCell(newwarden);
			Call_Finish();
		}
	}
}

public Action Timer_WardenFixColor(Handle timer,any client)
{
	if(IsValidClient(client, true))
	{
		int g_iWardenColorRedw;
		int g_iWardenColorGreenw;
		int g_iWardenColorBluew;
		g_iWardenColorRedw = GetConVarInt(g_iWardenColorRed);
		g_iWardenColorGreenw = GetConVarInt(g_iWardenColorGreen);
		g_iWardenColorBluew = GetConVarInt(g_iWardenColorBlue);

		if(IsClientWarden(client))
		{
			if(gc_bPlugin.BoolValue)	
			{ 
				if(gc_bColor.BoolValue)	
				{
					SetEntityRenderColor(client, g_iWardenColorRedw, g_iWardenColorGreenw, g_iWardenColorBluew, 255);
				}
				if(gc_bModel.BoolValue)
				{
					//GetClientModel(client, g_sModelPath, sizeof(g_sModelPath));
					//GetEntPropString(client, Prop_Data, "m_ModelName",g_sModelPath, sizeof(g_sModelPath));
					SetEntityModel(client, g_sWardenModel);
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

public Action playerTeam(Handle event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(client == Warden)
		RemoveTheWarden(client);
}

public void OnClientDisconnect(int client)
{
	if(client == Warden)
	{
		CPrintToChatAll("%t %t", "warden_tag" , "warden_disconnected");
		
		if(gc_bBetterNotes.BoolValue)
		{
			PrintCenterTextAll("%t", "warden_disconnected_nc", client);
			PrintHintTextToAll("%t", "warden_disconnected_nc", client);
		}
		
		Warden = -1;
		Forward_OnWardenRemoved(client);
		Call_StartForward(gF_OnWardenDisconnected);
		Call_PushCell(client);
		Call_Finish();
	}
}

public Action RemoveWarden(int client, int args)
{
	if(Warden != -1)
	{
		RemoveTheWarden(client);
		Call_StartForward(gF_OnWardenRemovedByAdmin);
		Call_PushCell(client);
		Call_Finish();
	}
	else CPrintToChatAll("%t %t", "warden_tag" , "warden_noexist");
	return Plugin_Handled;
	}

public Action HookPlayerChat(int client, const char[] command, int args)
{
	if(Warden == client && client)
	{
		char szText[256];
		GetCmdArg(1, szText, sizeof(szText));
		
		if(szText[0] == '/' || szText[0] == '@' || IsChatTrigger())
			return Plugin_Handled;
		if(szText[0] == '!')
			return Plugin_Continue;
		
		if(IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == CS_TEAM_CT)
		{
			CPrintToChatAll("%t {blue}%N{default}: %s", "warden_tag", client, szText);
			return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}

void SetTheWarden(int client)
{
	if(gc_bPlugin.BoolValue)	
	{
		CPrintToChatAll("%t %t", "warden_tag" , "warden_new", client);
		
		if(gc_bBetterNotes.BoolValue)
		{
			PrintCenterTextAll("%t", "warden_new_nc", client);
			PrintHintTextToAll("%t", "warden_new_nc", client);
		}
		Warden = client;
		CreateTimer(0.5, Timer_WardenFixColor, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		SetClientListeningFlags(client, VOICE_NORMAL);
		GivePlayerItem(client, "weapon_healthshot");
		GivePlayerItem(client, "weapon_healthshot");
		
		Forward_OnWardenCreation(client);
	}
	else CPrintToChat(client, "%t %t", "warden_tag" , "warden_disabled");
}

void RemoveTheWarden(int client)
{
	CPrintToChatAll("%t %t", "warden_tag" , "warden_removed", client, Warden);
	
	if(gc_bBetterNotes.BoolValue)
	{
		PrintCenterTextAll("%t", "warden_removed_nc", client, Warden);
		PrintHintTextToAll("%t", "warden_removed_nc", client, Warden);
	}
	
	if(IsClientInGame(client) && IsPlayerAlive(client))
	SetEntityRenderColor(Warden, 255, 255, 255, 255);
	SetEntityModel(client, "models/player/ctm_gsg9.mdl");
	Warden = -1;
	Call_StartForward(gF_OnWardenRemovedBySelf);
	Call_PushCell(client);
	Call_Finish();
	Forward_OnWardenRemoved(client);
}

EnableNoBlock(client)
{
	SetEntData(client, g_CollisionOffset, 2, 4, true);
}

EnableBlock(client)
{
	SetEntData(client, g_CollisionOffset, 5, 4, true);
}

public Action:noblockon(client, args)
{
	if(gc_bNoBlock.BoolValue)	
	{
		if (warden_iswarden(client))
		{
	
		LOOP_CLIENTS(i, CLIENTFILTER_TEAMONE)
				{
						
						EnableNoBlock(i);	
				}

		CPrintToChatAll("%t %t", "warden_tag" , "warden_noblockon");
		}
		else
		{
		CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
		}
	}
}

public Action:noblockoff(client, args)
{ 
	if (warden_iswarden(client))
	{
	LOOP_CLIENTS(i, CLIENTFILTER_TEAMONE)
				{
					
						EnableBlock(i);	
				}
	CPrintToChatAll("%t %t", "warden_tag" , "warden_noblockoff");	
		}
	else
	{
		CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden"); 
	}
}

public Action:ToggleFF(client, args)
{
if(gc_bFF.BoolValue) 
	{
	if (g_bFF.BoolValue) 
	{
		if (warden_iswarden(client))
		{
			g_bFF.BoolValue = false;
			CPrintToChatAll("%t %t", "warden_tag", "warden_ffisoff" );
		}else CPrintToChatAll("%t %t", "warden_tag", "warden_ffison" );
		
	}else
	{	
		if (warden_iswarden(client))
		{
			g_bFF.BoolValue = true;
			CPrintToChatAll("%t %t", "warden_tag", "warden_ffison" );
		}else CPrintToChatAll("%t %t", "warden_tag", "warden_ffisoff" );
		
	}
	}	
}

public Action:ccounter(Handle:timer, Handle:pack)
{
	--opentimer;
	if(opentimer < 1)
	{
	if(warden_exist() != 1)	
	{
		if(gc_bOpenTimer.BoolValue)	
		{
		SJD_OpenDoors(); 
		CPrintToChatAll("%t %t", "warden_tag" , "warden_openauto");
		
		if (countertime != null)
			KillTimer(countertime);
		
		countertime = null;
		}
		
	}else 
	if(gc_bOpenTimer.BoolValue)
		{
		if(gc_bOpenTimerWarden.BoolValue)
		{
		SJD_OpenDoors(); 
		CPrintToChatAll("%t %t", "warden_tag" , "warden_openauto");
		
		if (countertime != null)
			KillTimer(countertime);
		
		countertime = null;
		}else
	CPrintToChatAll("%t %t", "warden_tag" , "warden_opentime"); 
		if (countertime != null)
		KillTimer(countertime);
		countertime = null;
		} 
	}
}

public Action:OpenDoors(client, args)
{
	if(gc_bPlugin.BoolValue)	
	{
	if(gc_bOpen.BoolValue)
	{
	if (warden_iswarden(client))
	{
	CPrintToChatAll("%t %t", "warden_tag" , "warden_dooropen"); 
	SJD_OpenDoors();
	}
	else
	CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden"); 
	}
	}
}

public Action:CloseDoors(client, args)
{
	if(gc_bPlugin.BoolValue)	
	{
	if(gc_bOpen.BoolValue)
	{
		if (warden_iswarden(client))
		{
			CPrintToChatAll("%t %t", "warden_tag" , "warden_doorclose"); 
			SJD_CloseDoors();
			if (countertime != null)
			KillTimer(countertime);
			countertime = null;
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden"); 
	}
	}
}

public int Native_ExistWarden(Handle plugin, int numParams)
{
	if(Warden != -1)
		return true;
	
	return false;
}

public int Native_IsWarden(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if(!IsClientInGame(client) && !IsClientConnected(client))
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);
	
	if(client == Warden)
		return true;
	
	return false;
}

public int Native_SetWarden(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!IsClientInGame(client) && !IsClientConnected(client))
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);
	
	if(Warden == -1)
		SetTheWarden(client);
}

public int Native_RemoveWarden(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!IsClientInGame(client) && !IsClientConnected(client))
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);
	
	if(client == Warden)
		RemoveTheWarden(client);
}

public int Native_GetWarden(Handle:plugin, argc)
{	
		return Warden;
}

void Forward_OnWardenCreation(int client)
{
	Call_StartForward(g_fward_onBecome);
	Call_PushCell(client);
	Call_Finish();
}

void Forward_OnWardenRemoved(int client)
{
	Call_StartForward(g_fward_onRemove);
	Call_PushCell(client);
	Call_Finish();
}

stock bool IsWarden()
{
	if(Warden != -1)
	{
	return true;
	}
	return false;
}

stock bool IsClientWarden(int client)
{
	if(client == Warden)
	{
	return true;
	}
	return false;
}

stock bool IsValidClient(int client, bool alive = false)
{
	if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && (alive == false || IsPlayerAlive(client)))
	{
	return true;
	}
	return false;
}

public void warden_OnWardenCreated(int client)
{
	if(gc_bSounds.BoolValue)	
	{
	EmitSoundToAllAny(g_sSoundPath1);
	}
}

public void warden_OnWardenRemoved(int client)
{
	if(gc_bSounds.BoolValue)	
	{
	EmitSoundToAllAny(g_sSoundPath2);
	}
}

void PrecacheSoundAnyDownload(char[] sSound)
{
	if(gc_bSounds.BoolValue)	
	{
	PrecacheSoundAny(sSound);
	
	char sBuffer[256];
	Format(sBuffer, sizeof(sBuffer), "sound/%s", sSound);
	AddFileToDownloadsTable(sBuffer);
	}
}