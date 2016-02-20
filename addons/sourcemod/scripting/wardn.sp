#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <warden>
#include <multicolors>
#include <emitsoundany>

#define LoopAliveClients(%1) for(int %1 = 1;%1 <= MaxClients;%1++) if(IsValidClient(%1, true))

#define PLUGIN_VERSION   "0.1"

int Warden = -1;
int tempwarden[MAXPLAYERS+1] = -1;

ConVar cvSndWarden;
char sSndWarden[256];

ConVar cvSndWardenDied;
char sSndWardenDied[256];

Handle g_cVar_mnotes;
Handle g_fward_onBecome;
Handle g_fward_onRemove;
Handle gF_OnWardenCreatedByUser = null;
Handle gF_OnWardenCreatedByAdmin = null;
Handle gF_OnWardenDisconnected = null;
Handle gF_OnWardenDeath = null;
Handle gF_OnWardenRemovedBySelf = null;
Handle gF_OnWardenRemovedByAdmin = null;

new Handle:g_enabled=INVALID_HANDLE;
new Handle:g_prefix=INVALID_HANDLE;
new Handle:g_colorenabled=INVALID_HANDLE;
new Handle:g_sounds=INVALID_HANDLE;

new String:g_wprefix[64];

public Plugin myinfo = {
	name = "MyJailbreak - Warden",
	author = "shanapu, ecca & .#zipcore",
	description = "Jailbreak Warden script",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart() 
{
    // Translation
	LoadTranslations("warden.phrases");
	// Client commands
	RegConsoleCmd("sm_w", BecomeWarden);
	RegConsoleCmd("sm_warden", BecomeWarden);
	RegConsoleCmd("sm_uw", ExitWarden);
	RegConsoleCmd("sm_unwarden", ExitWarden);
	RegConsoleCmd("sm_c", BecomeWarden);
	RegConsoleCmd("sm_commander", BecomeWarden);
	RegConsoleCmd("sm_uc", ExitWarden);
	RegConsoleCmd("sm_uncommander", ExitWarden);
	
	// Admin commands
	
	RegAdminCmd("sm_sw", SetWarden, ADMFLAG_GENERIC);
	RegAdminCmd("sm_setwarden", SetWarden, ADMFLAG_GENERIC);
	RegAdminCmd("sm_rw", RemoveWarden, ADMFLAG_GENERIC);
	RegAdminCmd("sm_removewarden", RemoveWarden, ADMFLAG_GENERIC);
    //Hooks
	HookEvent("round_start", roundStart);
	HookEvent("player_death", playerDeath);
	HookEvent("player_team", playerTeam);
	//Forwards
	gF_OnWardenCreatedByUser = CreateGlobalForward("Warden_OnWardenCreatedByUser", ET_Ignore, Param_Cell);
	gF_OnWardenCreatedByAdmin = CreateGlobalForward("Warden_OnWardenCreatedByAdmin", ET_Ignore, Param_Cell);
	g_fward_onBecome = CreateGlobalForward("warden_OnWardenCreated", ET_Ignore, Param_Cell);
	gF_OnWardenDisconnected = CreateGlobalForward("Warden_OnWardenDisconnected", ET_Ignore, Param_Cell);
	gF_OnWardenDeath = CreateGlobalForward("Warden_OnWardenDeath", ET_Ignore, Param_Cell);
	gF_OnWardenRemovedBySelf = CreateGlobalForward("Warden_OnWardenRemovedBySelf", ET_Ignore, Param_Cell);
	gF_OnWardenRemovedByAdmin = CreateGlobalForward("Warden_OnWardenRemovedByAdmin", ET_Ignore, Param_Cell);
	g_fward_onRemove = CreateGlobalForward("warden_OnWardenRemoved", ET_Ignore, Param_Cell);
	
	
	AddCommandListener(HookPlayerChat, "say");
	
	
	//ConVars
	CreateConVar("sm_warden_version", PLUGIN_VERSION,  "The version of the SourceMod plugin MyJailBreak - Warden", FCVAR_REPLICATED|FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_cVar_mnotes = CreateConVar("sm_warden_better_notifications", "0", "0 - disabled, 1 - Will use hint and center text", _, true, 0.0, true, 1.0);
	g_enabled = CreateConVar("sm_warden_enable", "1", "0 - disabled, 1 - enable warden");	
	g_prefix = CreateConVar("sm_warden_prefix", "[warden]", "Insert your Jailprefix. default:warden - [warden]");
	g_colorenabled = CreateConVar("sm_wardencolor_enable", "1", "0 - disabled, 1 - enable warden colored");
	
	g_sounds = CreateConVar("sm_wardensounds_enable", "1", "0 - disabled, 1 - enable warden");
	cvSndWarden = CreateConVar("warden_sounds_path", "MyJailbreak/warden.mp3", "Path to the sound which should be played for a new warden.");
	GetConVarString(cvSndWarden, sSndWarden, sizeof(sSndWarden));
	HookConVarChange(cvSndWarden, OnSettingChanged);
	cvSndWardenDied = CreateConVar("warden_sounds_path2", "MyJailbreak/unwarden.mp3", "Path to the sound which should be played when there is no warden anymore.");
	GetConVarString(cvSndWardenDied, sSndWardenDied, sizeof(sSndWardenDied));
	HookConVarChange(cvSndWardenDied, OnSettingChanged);
	
	
	AutoExecConfig(true, "MyJailbreak_warden");
	
	GetConVarString(g_prefix, g_wprefix, sizeof(g_wprefix));
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
	if(GetConVarInt(g_sounds) == 1)	
	{
		PrecacheSoundAnyDownload(sSndWarden);
		PrecacheSoundAnyDownload(sSndWardenDied);
	}	
}

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == cvSndWarden)
	{
		strcopy(sSndWarden, sizeof(sSndWarden), newValue);
		PrecacheSoundAnyDownload(sSndWarden);
	}
	else if(convar == cvSndWardenDied)
	{
		strcopy(sSndWardenDied, sizeof(sSndWardenDied), newValue);
		PrecacheSoundAnyDownload(sSndWardenDied);
	}
}

public Action BecomeWarden(int client, int args) 
{
	if(GetConVarInt(g_enabled) == 1)	
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
				else PrintToChat(client, "%s %t", g_wprefix, "warden_playerdead");
			}
			else PrintToChat(client, "%s %t", g_wprefix, "warden_ctsonly");
		}
		else PrintToChat(client, "%s %t", g_wprefix, "warden_exist", Warden);
	}else PrintToChat(client, "%s %t", g_wprefix, "warden_disabled");
}

public Action ExitWarden(int client, int args) 
{
	if(GetConVarInt(g_enabled) == 1)	
	{
	if(client == Warden)
	{
		PrintToChatAll("%s %t", g_wprefix, "warden_retire", client);
		
		if(GetConVarBool(g_cVar_mnotes))
		{
			PrintCenterTextAll("%s %t", g_wprefix, "warden_retire", client);
			PrintHintTextToAll("%s %t", g_wprefix, "warden_retire", client);
		}
		
		Warden = -1;
		Forward_OnWardenRemoved(client);
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
	else PrintToChat(client, "%s %t", g_wprefix, "warden_notwarden");
	}else PrintToChat(client, "%s %t", g_wprefix, "warden_disabled");
}

public Action roundStart(Handle event, const char[] name, bool dontBroadcast) 
{
if(GetConVarInt(g_enabled) == 0)	
	{
		Warden = -1;
	}
}
public Action playerDeath(Handle event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(client == Warden)
	{
		PrintToChatAll("%s %t", g_wprefix, "warden_dead", client);
		
		if(GetConVarBool(g_cVar_mnotes))
		{
			PrintCenterTextAll("%s %t", g_wprefix, "warden_dead", client);
			PrintHintTextToAll("%s %t", g_wprefix, "warden_dead", client);
		}
		
		RemoveTheWarden(client);
		Call_StartForward(gF_OnWardenDeath);
		Call_PushCell(client);
		Call_Finish();
    }
	if(GetConVarInt(g_enabled) == 1)	
	{
		if(warden_iswarden(client))
		EmitSoundToAllAny(sSndWardenDied);
	}
}
public Action SetWarden(int client,int args)
{
  if(GetConVarInt(g_enabled) == 1)	
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
            PrintToChatAll("%s %t", g_wprefix, "warden_new", Warden);
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
      PrintToChatAll("%s %t", g_wprefix, "warden_removed", Warden);
      PrintToChatAll("%s %t", g_wprefix, "warden_new", newwarden);
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
    if(IsClientWarden(client))
    {
		if(GetConVarInt(g_enabled) == 1)	
		{ if(GetConVarInt(g_colorenabled) == 1)	
			{
			SetEntityRenderColor(client,0,102,204);
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
		PrintToChatAll("%s %t", g_wprefix, "warden_disconnected");
		
		if(GetConVarBool(g_cVar_mnotes))
		{
			PrintCenterTextAll("%s %t", g_wprefix, "warden_disconnected", client);
			PrintHintTextToAll("%s %t", g_wprefix, "warden_disconnected", client);
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
	else PrintToChatAll("%s %t", g_wprefix, "warden_noexist");
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
		
		if(IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == CS_TEAM_CT)
		{
			PrintToChatAll("%s %N : %s", g_wprefix, client, szText);
			return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}

void SetTheWarden(int client)
{
	if(GetConVarInt(g_enabled) == 1)	
	{
	PrintToChatAll("%s %t", g_wprefix, "warden_new", client);
	
	if(GetConVarBool(g_cVar_mnotes))
	{
		PrintCenterTextAll("%s %t", g_wprefix, "warden_new", client);
		PrintHintTextToAll("%s %t", g_wprefix, "warden_new", client);
	}
	
	Warden = client;
	CreateTimer(0.5, Timer_WardenFixColor, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	SetClientListeningFlags(client, VOICE_NORMAL);
	
	Forward_OnWardenCreation(client);
	}else PrintToChat(client, "%s %t", g_wprefix, "warden_disabled");
}

void RemoveTheWarden(int client)
{
	PrintToChatAll("%s %t", g_wprefix, "warden_removed", client, Warden);
	
	if(GetConVarBool(g_cVar_mnotes))
	{
		PrintCenterTextAll("%s %t", g_wprefix, "warden_removed", client, Warden);
		PrintHintTextToAll("%s %t", g_wprefix, "warden_removed", client, Warden);
	}
	
	if(IsClientInGame(client) && IsPlayerAlive(client))
		SetEntityRenderColor(Warden, 255, 255, 255, 255);
		
	Warden = -1;
	Call_StartForward(gF_OnWardenRemovedBySelf);
	Call_PushCell(client);
	Call_Finish();
	Forward_OnWardenRemoved(client);
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
	if(GetConVarInt(g_sounds) == 1)	
	{
	EmitSoundToAllAny(sSndWarden);
	}
}

public void warden_OnWardenRemoved(int client)
{
	if(GetConVarInt(g_sounds) == 1)	
	{
	EmitSoundToAllAny(sSndWardenDied);
	}
}

void PrecacheSoundAnyDownload(char[] sSound)
{
	if(GetConVarInt(g_sounds) == 1)	
	{
	PrecacheSoundAny(sSound);
	
	char sBuffer[256];
	Format(sBuffer, sizeof(sBuffer), "sound/%s", sSound);
	AddFileToDownloadsTable(sBuffer);
	}
}

