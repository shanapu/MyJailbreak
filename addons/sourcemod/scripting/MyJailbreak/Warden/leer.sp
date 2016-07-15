// No Block module for MyJailbreak - Warden

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
ConVar gc_bNoBlock;
ConVar g_bNoBlockSolid;
ConVar gc_bNoBlockMode;

//Bools
bool g_bNoBlock = true;

public void NoBlock_OnPluginStart()
{
	//Client commands
	RegConsoleCmd("sm_noblock", Command_ToggleNoBlock, "Allows the Warden to toggle no block"); 
	
	//AutoExecConfig
	gc_bNoBlock = AutoExecConfig_CreateConVar("sm_warden_noblock", "1", "0 - disabled, 1 - enable noblock toggle for warden", _, true,  0.0, true, 1.0);
	gc_bNoBlockMode = AutoExecConfig_CreateConVar("sm_warden_noblock_mode", "1", "0 - collision only between CT & T, 1 - collision within a team.", _, true,  0.0, true, 1.0);
	
	//Hooks
	HookEvent("round_end", NoBlock_RoundEnd);
	
	//FindConVar
	g_bNoBlockSolid = FindConVar("mp_solid_teammates");
}

public void NoBlock_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	SetCvar("mp_solid_teammates", g_bNoBlockSolid.BoolValue);
}

public Action Command_ToggleNoBlock(int client, int args)
{
	if (gc_bNoBlock.BoolValue) 
	{
		if (client == g_iWarden)
		{
			if (!g_bNoBlock) 
			{
				g_bNoBlock = true;
				CPrintToChatAll("%t %t", "warden_tag" , "warden_noblockon");
				LoopValidClients(i, true, true)
				{
					SetEntData(i, g_iCollisionOffset, 2, 4, true);
					if(gc_bNoBlockMode.BoolValue) SetCvar("mp_solid_teammates", 0);
				}
			}
			else
			{
				g_bNoBlock = false;
				CPrintToChatAll("%t %t", "warden_tag" , "warden_noblockoff");
				LoopValidClients(i, true, true)
				{
					SetEntData(i, g_iCollisionOffset, 5, 4, true);
					if(gc_bNoBlockMode.BoolValue) SetCvar("mp_solid_teammates", 1);
				}
			}
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
}