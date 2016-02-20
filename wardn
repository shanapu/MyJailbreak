#include <sourcemod>
#include <cstrike>
#include <multicolors>
#include <eskojbwarden>

#pragma semicolon 1;
#pragma newdecls required;

#define LoopAliveClients(%1) for(int %1 = 1;%1 <= MaxClients;%1++) if(IsValidClient(%1, true))

int warden = -1;
int tempwarden[MAXPLAYERS+1] = -1;

Handle gF_OnWardenCreatedByUser = null;
Handle gF_OnWardenCreatedByAdmin = null;
Handle gF_OnWardenDisconnected = null;
Handle gF_OnWardenDeath = null;
Handle gF_OnWardenRemovedBySelf = null;
Handle gF_OnWardenRemovedByAdmin = null;

public Plugin myinfo =
{
  name = "ESK0's JailBreak warden plugins",
  author = "ESK0",
  description = "JailBreak warden plugin",
  version = "1.0",
  url = "www.Github.com/ESK0"
};
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
  CreateNative("EJBW_IsClientWarden", Native_IsClientWarden);
  CreateNative("EJBW_WardenExist", Native_WardenExist);
  CreateNative("EJBW_SetWarden", Native_SetWarden);
  CreateNative("EJBW_RemoveWarden", Native_RemoveWarden);
  RegPluginLibrary("eskojbwarden");
  return APLRes_Success;
}
public void OnPluginStart()
{
  // Client commands
  RegConsoleCmd("sm_w", Command_Warden);
  RegConsoleCmd("sm_warden", Command_Warden);
  RegConsoleCmd("sm_uw", Command_UnWarden);
  RegConsoleCmd("sm_unwarden", Command_UnWarden);

  // Admin commands
  RegAdminCmd("sm_sw", Command_SetWarden, ADMFLAG_GENERIC);
  RegAdminCmd("sm_setwarden", Command_SetWarden, ADMFLAG_GENERIC);
  RegAdminCmd("sm_rw", Command_RemoveWarden, ADMFLAG_GENERIC);
  RegAdminCmd("sm_removewarden", Command_RemoveWarden, ADMFLAG_GENERIC);

  //Hooks
  HookEvent("round_start", Event_OnRoundStart);
  HookEvent("player_death", Event_OnPlayerDeath);

  //Forwards
  gF_OnWardenCreatedByUser = CreateGlobalForward("EJBW_OnWardenCreatedByUser", ET_Ignore, Param_Cell);
  gF_OnWardenCreatedByAdmin = CreateGlobalForward("EJBW_OnWardenCreatedByAdmin", ET_Ignore, Param_Cell);
  gF_OnWardenDisconnected = CreateGlobalForward("EJBW_OnWardenDisconnected", ET_Ignore, Param_Cell);
  gF_OnWardenDeath = CreateGlobalForward("EJBW_OnWardenDeath", ET_Ignore, Param_Cell);
  gF_OnWardenRemovedBySelf = CreateGlobalForward("EJBW_OnWardenRemovedBySelf", ET_Ignore, Param_Cell);
  gF_OnWardenRemovedByAdmin = CreateGlobalForward("EJBW_OnWardenRemovedByAdmin", ET_Ignore, Param_Cell);
}

public void OnClientDisconnect(int client)
{
  if(IsValidClient(client))
  {
    if(IsClientWarden(client))
    {
      warden = -1;
      CPrintToChatAll("[Warden] - Warden has disconnected!!");
      Call_StartForward(gF_OnWardenDisconnected);
      Call_PushCell(client);
      Call_Finish();
    }
  }
}
public Action Event_OnRoundStart(Handle event, char[] name, bool dontBroadcast)
{
  warden = -1;
}
public Action Event_OnPlayerDeath(Handle event, char[] name, bool dontBroadcast)
{
  int client = GetClientOfUserId(GetEventInt(event, "userid"));
  if(IsValidClient(client))
  {
    if(IsClientWarden(client))
    {
      warden = -1;
      Call_StartForward(gF_OnWardenDeath);
      Call_PushCell(client);
      Call_Finish();
    }
  }
}
public Action Command_Warden(int client,int args)
{
  if(IsValidClient(client))
  {
    if(IsWarden() == false)
    {
      if(GetClientTeam(client) == CS_TEAM_CT)
      {
        if(IsPlayerAlive(client))
        {
          warden = client;
          CreateTimer(0.5, Timer_WardenFixColor, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
          PrintToChatAll("[Warden] New Warden is %N!", client);

          Call_StartForward(gF_OnWardenCreatedByUser);
          Call_PushCell(client);
          Call_Finish();
        }
        else
        {
          PrintToChat(client, "[Warden] Only alive player can became Warden!");
        }
      }
      else
      {
        PrintToChat(client, "[Warden] Only CT can became Warden!");
      }
    }
    else
    {
      if(IsClientWarden(client))
      {
        PrintToChat(client, "[Warden] - You are Warden!");
      }
      else
      {
        PrintToChat(client, "[Warden] Current Warden is %N", warden);
      }
    }
  }
  return Plugin_Handled;
}
public Action Command_UnWarden(int client,int args)
{
  if(IsValidClient(client))
  {
    if(IsClientWarden(client))
    {
      warden = -1;
      PrintToChatAll("[Warden] %N retired and new Warden can became!", client);
      Call_StartForward(gF_OnWardenRemovedBySelf);
      Call_PushCell(client);
      Call_Finish();
    }
    else
    {
      PrintToChat(client, "[Warden] You are not Warden, You can not retire!");
    }
  }
  return Plugin_Handled;
}
public Action Command_SetWarden(int client,int args)
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
            Format(buffer,sizeof(buffer), "Current Warden is %N, do you want to replace him?", warden);
            menu1.SetTitle(buffer);
            menu1.AddItem("1", "Yes");
            menu1.AddItem("0", "No");
            menu1.ExitButton = false;
            menu1.Display(client,MENU_TIME_FOREVER);
          }
          else
          {
            warden = i;
            PrintToChatAll("[Warden] Admin set %N as a Warden!", i);
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
      PrintToChatAll("[Warden] Current Warden %N has been fired!", warden);
      PrintToChatAll("[Warden] Admin set %N as a Warden!", newwarden);
      warden = newwarden;
      CreateTimer(0.5, Timer_WardenFixColor, newwarden, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
      Call_StartForward(gF_OnWardenCreatedByAdmin);
      Call_PushCell(newwarden);
      Call_Finish();
    }
  }
}
public Action Command_RemoveWarden(int client,int args)
{
  if(IsValidClient(client))
  {
    if(IsWarden() == true)
    {
      PrintToChatAll("[Warden] Current Warden %N has been fired!", warden);
      Call_StartForward(gF_OnWardenRemovedByAdmin);
      Call_PushCell(warden);
      Call_Finish();
      warden = -1;
    }
    else
    {
  	  PrintToChat(client, "[SM] There is no Warden!");
    }
  }
  return Plugin_Handled;
}
public Action Timer_WardenFixColor(Handle timer,any client)
{
  if(IsValidClient(client, true))
  {
    if(IsClientWarden(client))
    {
      SetEntityRenderColor(client,0,102,204);
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
public int Native_RemoveWarden(Handle plugin, int numParams)
{
  int client = GetNativeCell(1);
  if(IsValidClient(client, true))
  {
    if(IsClientWarden(client))
    {
      warden = -1;
      Call_StartForward(gF_OnWardenRemovedByAdmin);
      Call_PushCell(warden);
      Call_Finish();
      return true;
    }
  }
  return false;
}
public int Native_SetWarden(Handle plugin, int numParams)
{
  int client = GetNativeCell(1);
  if(IsValidClient(client, true))
  {
    if(IsWarden() == false)
    {
      warden = client;
      Call_StartForward(gF_OnWardenCreatedByAdmin);
      Call_PushCell(warden);
      Call_Finish();
      return true;
    }
  }
  return false;
}
public int Native_IsClientWarden(Handle plugin, int numParams)
{
  int client = GetNativeCell(1);
  if(IsValidClient(client, true))
  {
    if(IsClientWarden(client))
    {
      return true;
    }
  }
  return false;
}
public int Native_WardenExist(Handle plugin, int numParams)
{
  if(IsWarden())
  {
    return true;
  }
  return false;
}
stock bool IsClientWarden(int client)
{
  if(client == warden)
  {
    return true;
  }
  return false;
}
stock bool IsWarden()
{
  if(warden != -1)
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