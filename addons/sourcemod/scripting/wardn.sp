#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <wardn>

#define PLUGIN_VERSION   "0.1"

int Warden = -1;

Handle g_cVar_mnotes;
Handle g_fward_onBecome;
Handle g_fward_onRemove;
Handle gF_OnWardenCreatedByUser = null;
Handle gF_OnWardenCreatedByAdmin = null;
Handle gF_OnWardenDisconnected = null;
Handle gF_OnWardenDeath = null;
Handle gF_OnWardenRemovedBySelf = null;
Handle gF_OnWardenRemovedByAdmin = null;

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
	
	
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, interr_max)
{
	CreateNative("warden_exist", Native_ExistWarden);
	CreateNative("warden_iswarden", Native_IsWarden);
	CreateNative("warden_set", Native_SetWarden);
	CreateNative("warden_remove", Native_RemoveWarden);
    CreateNative("warden_get", Native_GetWarden);
    
	RegPluginLibrary("warden");
	
	return APLRes_Success;
}

public Action BecomeWarden(int client, int args) 
{
	if (Warden == -1)
	{
		if (GetClientTeam(client) == CS_TEAM_CT)
		{
			if (IsPlayerAlive(client))
				SetTheWarden(client);
				
				Call_StartForward(gF_OnWardenCreatedByUser);
				Call_PushCell(client);
				Call_Finish();
				
			else PrintToChat(client, "Warden ~ %t", "warden_playerdead");
		}
		else PrintToChat(client, "Warden ~ %t", "warden_ctsonly");
	}
	else PrintToChat(client, "Warden ~ %t", "warden_exist", Warden);
}

public Action ExitWarden(int client, int args) 
{
	if(client == Warden)
	{
		PrintToChatAll("Warden ~ %t", "warden_retire", client);
		
		if(GetConVarBool(g_cVar_mnotes))
		{
			PrintCenterTextAll("Warden ~ %t", "warden_retire", client);
			PrintHintTextToAll("Warden ~ %t", "warden_retire", client);
		}
		
		Warden = -1;
		Forward_OnWardenRemoved(client);
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
	else PrintToChat(client, "Warden ~ %t", "warden_notwarden");
}

public Action roundStart(Handle event, const char[] name, bool dontBroadcast) 
{
	Warden = -1;
}

public Action playerDeath(Handle event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(client == Warden)
	{
		PrintToChatAll("Warden ~ %t", "warden_dead", client);
		
		if(GetConVarBool(g_cVar_mnotes))
		{
			PrintCenterTextAll("Warden ~ %t", "warden_dead", client);
			PrintHintTextToAll("Warden ~ %t", "warden_dead", client);
		}
		
		RemoveTheWarden(client);
		Call_StartForward(gF_OnWardenDeath);
        Call_PushCell(client);
        Call_Finish();
	}
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
		PrintToChatAll("Warden ~ %t", "warden_disconnected");
		
		if(GetConVarBool(g_cVar_mnotes))
		{
			PrintCenterTextAll("Warden ~ %t", "warden_disconnected", client);
			PrintHintTextToAll("Warden ~ %t", "warden_disconnected", client);
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
		RemoveTheWarden(client);
		Call_StartForward(gF_OnWardenRemovedByAdmin);
        Call_PushCell(client);
        Call_Finish();
	else PrintToChatAll("Warden ~ %t", "warden_noexist");

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
			PrintToChatAll("[Warden] %N : %s", client, szText);
			return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}

void SetTheWarden(int client)
{
	PrintToChatAll("Warden ~ %t", "warden_new", client);
	
	if(GetConVarBool(g_cVar_mnotes))
	{
		PrintCenterTextAll("Warden ~ %t", "warden_new", client);
		PrintHintTextToAll("Warden ~ %t", "warden_new", client);
	}
	
	Warden = client;
	SetEntityRenderColor(client, 0, 0, 240, 255);
	SetClientListeningFlags(client, VOICE_NORMAL);
	
	Forward_OnWardenCreation(client);
}

void RemoveTheWarden(int client)
{
	PrintToChatAll("Warden ~ %t", "warden_removed", client, Warden);
	
	if(GetConVarBool(g_cVar_mnotes))
	{
		PrintCenterTextAll("Warden ~ %t", "warden_removed", client);
		PrintHintTextToAll("Warden ~ %t", "warden_removed", client);
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