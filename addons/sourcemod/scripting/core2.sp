//includes
#include <sourcemod>
#include <cstrike>
#include <myjailbreak>
#include <autoexecconfig>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//ConVars
ConVar gc_bAutoDay;
ConVar gc_iRandomRatio;

//Integers
int IsRandomDay;
int RandomDay;

//Strings
char IsEventDay[128] = "none";

public Plugin myinfo = {
	name = "MyJailbreak - core",
	author = "shanapu",
	description = "Jailbreak",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	//AutoExecConfig
	AutoExecConfig_SetFile("MyJailbreak_randomdays");
	AutoExecConfig_SetCreateFile(true);
	
	gc_bAutoDay = AutoExecConfig_CreateConVar("sm_randomdays", "1", "0 - disabled, 1 - enable random Eventdays");
	gc_iRandomRatio = AutoExecConfig_CreateConVar("sm_randomdays_ratio", "2", "Ratio 1:x next round will be an Eventround");
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
}

public void RoundStart(Handle event, char[] name, bool dontBroadcast)
{
	if (gc_bAutoDay.BoolValue)
	{
		if(StrEqual(IsEventDay, "none", false))
		{
			IsRandomDay = GetRandomInt(1, gc_iRandomRatio.IntValue);
			
			if(IsRandomDay == 1)
			{
				RandomDay = GetRandomInt(1, 10);
				
				if(RandomDay == 1)
				{
					FakeClientCommand(0, "sm_knifefight");
				}
				else if(RandomDay == 2)
				{
					FakeClientCommand(0, "sm_duckhunt");
				}
				else if(RandomDay == 3)
				{
					FakeClientCommand(0, "sm_jihad");
				}
				else if(RandomDay == 4)
				{
					FakeClientCommand(0, "sm_catch");
				}
				else if(RandomDay == 5)
				{
					FakeClientCommand(0, "sm_dodgeball");
				}
				else if(RandomDay == 6)
				{
					FakeClientCommand(0, "sm_ffa");
				}
				else if(RandomDay == 7)
				{
					FakeClientCommand(0, "sm_hide");
				}
				else if(RandomDay == 8)
				{
					FakeClientCommand(0, "sm_noscope");
				}
				else if(RandomDay == 9)
				{
					FakeClientCommand(0, "sm_war");
				}
				else if(RandomDay == 10)
				{
					FakeClientCommand(0, "sm_zombie");
				}
			}
			else
			{
				//noc action - normal standard day
			}
		}
	}
}


public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("SetEventDay", Native_SetEventDay);
	CreateNative("GetEventDay", Native_GetEventDay);
}

public int Native_SetEventDay(Handle plugin,int argc)
{
	char buffer[64];
	GetNativeString(1, buffer, 64);
	
	Format(IsEventDay, sizeof(IsEventDay), buffer);
}

public int Native_GetEventDay(Handle plugin,int argc)
{
	SetNativeString(1, IsEventDay, sizeof(IsEventDay));
}
