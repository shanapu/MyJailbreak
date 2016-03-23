#pragma semicolon 1

// ====[ INCLUDES ]============================================================
#include <sourcemod>
#include <sdktools>
#include <warden>

// ====[ DEFINES ]=============================================================
#define PLUGIN_VERSION			"1.1"

// ====[ CVARS | HANDLES ]=====================================================

// ====[ VARIABLES ]===========================================================
new g_iOverlayCount;
new bool:g_bOverlayed;
new String:g_sOverlayName[255][32];
new String:g_sOverlayFile[255][PLATFORM_MAX_PATH];
new String:g_sOverlaySound[255][PLATFORM_MAX_PATH];
new String:g_sOverlayTime[255][4];
new String:g_sOverlayIdentity[255][4];
new String:g_sConfigFile[PLATFORM_MAX_PATH];
new String:g_strCurrentSound[PLATFORM_MAX_PATH];

// ====[ PLUGIN ]==============================================================
public Plugin:myinfo =
{
	name = "Jailbreak Overlays",
	author = "shanapu, ReFlexPoison",
	description = "Allows warden to broadcast custom screen overlays to players",
	version = PLUGIN_VERSION,
	url = "http://www.sourcemod.net/"
}

// ====[ EVENTS ]==============================================================
public OnPluginStart()
{
	CreateConVar("sm_jboverlays_version", PLUGIN_VERSION, "showns plugin version", FCVAR_PLUGIN | FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);

	RegConsoleCmd("sm_jboverlays", Command_ScreenOverlays, "Open Jailbreak overlays menu");
	RegAdminCmd("sm_reloadoverlays", Command_ReloadScreenOverlays, ADMFLAG_ROOT, "Reloads screen overlays from config");

	BuildPath(Path_SM, g_sConfigFile, sizeof(g_sConfigFile), "configs/jboverlays.cfg");

	LoadTranslations("common.phrases.txt");
}

public OnConfigsExecuted()
{
	g_bOverlayed = false;
	strcopy(g_strCurrentSound, sizeof(g_strCurrentSound), "");

	new Handle:hKv = CreateKeyValues("Screen Overlays");
	FileToKeyValues(hKv, g_sConfigFile);
	if(!KvGotoFirstSubKey(hKv))
	{
		SetFailState("Can't find config file %s!", g_sConfigFile);
		return;
	}

	new iCount;
	decl String:sName[32];
	decl String:sFile[PLATFORM_MAX_PATH];
	decl String:sSound[PLATFORM_MAX_PATH];
	decl String:sTime[4];
	decl String:sIdentity[4];
	do
	{
		KvGetString(hKv, "name", sName, sizeof(sName));
		if(sName[0])
			strcopy(g_sOverlayName[iCount], sizeof(g_sOverlayName[]), sName);
		else
			strcopy(g_sOverlayName[iCount], sizeof(g_sOverlayName[]), "No Name");

		KvGetString(hKv, "file", sFile, sizeof(sFile));
		PrecacheDecal(sFile, true);
		strcopy(g_sOverlayFile[iCount], sizeof(g_sOverlayFile[]), sFile);

		KvGetString(hKv, "sound", sSound, sizeof(sSound));
		if(sSound[0])
		{
			strcopy(g_sOverlaySound[iCount], sizeof(g_sOverlaySound[]), sSound);
			PrecacheSound(sSound, true);
		}

		KvGetString(hKv, "time", sTime, sizeof(sTime));
		if(sTime[0])
			strcopy(g_sOverlayTime[iCount], sizeof(g_sOverlayTime[]), sTime);
		else
			strcopy(g_sOverlayTime[iCount], sizeof(g_sOverlayTime[]), "5");

		IntToString(iCount, sIdentity, sizeof(sIdentity));
		strcopy(g_sOverlayIdentity[iCount], sizeof(g_sOverlayIdentity[]), sIdentity);

		iCount++;
	}
	while(KvGotoNextKey(hKv));
	CloseHandle(hKv);

	g_iOverlayCount = iCount;
}
// ====[ COMMANDS ]============================================================
public Action:Command_ScreenOverlays(iClient, iArgs)
{
	if(!IsValidClient(iClient))
	{
		ReplyToCommand(iClient, "[\x04goo\x01] %t", "Command is in-game only");
		return Plugin_Handled;
	}

	if(g_bOverlayed)
	{
		ReplyToCommand(iClient, "[\x04goo.governor\x01] Es ist noch ein Ansage am Start. Versuche es gleich nochmal!");
		return Plugin_Handled;
	}
 	if (warden_iswarden(iClient)) 
	{
	Menu_ScreenOverlays(iClient);
	
	}
	return Plugin_Handled;
}

public Action:Command_ReloadScreenOverlays(iClient, iArgs)
{
	ClearScreenOverlay();

	if(g_strCurrentSound[0])
	{
		for(new i = 1; i <= MaxClients; i++) if(IsClientInGame(i))
			StopSound(i, SNDCHAN_AUTO, g_strCurrentSound);
	}

	OnConfigsExecuted();

	ReplyToCommand(iClient, "[\x04goo.governor\x01] Overlays reloaded.");
	return Plugin_Handled;
}

// ====[ MENUS ]===============================================================
public Menu_ScreenOverlays(iClient)
{
	new Handle:hMenu = CreateMenu(MenuHandler_ScreenOverlays);
	SetMenuTitle(hMenu, "[goo] Jailbreak Ansagen");

	for(new i = 0; i < g_iOverlayCount; i++)
		AddMenuItem(hMenu, g_sOverlayIdentity[i], g_sOverlayName[i]);

	DisplayMenu(hMenu, iClient, MENU_TIME_FOREVER);
}

public MenuHandler_ScreenOverlays(Handle:hMenu, MenuAction:iAction, iParam1, iParam2)
{
	if(iAction == MenuAction_End)
	{
		CloseHandle(hMenu);
		return;
	}

	if(iAction == MenuAction_Select)
	{
		if(g_bOverlayed)
		{
			ReplyToCommand(iParam1, "[\x04goo.governor\x01] Es ist noch ein Ansage am Start. Versuche es gleich nochmal!");
			return;
		}

		decl String:sBuffer[PLATFORM_MAX_PATH];
		GetMenuItem(hMenu, iParam2, sBuffer, sizeof(sBuffer));

		new iIdentity = StringToInt(sBuffer);

		decl String:sFile[PLATFORM_MAX_PATH];
		strcopy(sFile, sizeof(sFile), g_sOverlayFile[iIdentity]);

		decl String:sSound[PLATFORM_MAX_PATH];
		strcopy(sSound, sizeof(sSound), g_sOverlaySound[iIdentity]);

		new Float:fTime = StringToFloat(g_sOverlayTime[iIdentity]);

		DisplayScreenOverlay(sFile, sSound, fTime);
	}
}

// ====[ FUNCTIONS ]===========================================================
public DisplayScreenOverlay(const String:sFile[], const String:sSound[], const Float:fTime)
{
	new iFlags = GetCommandFlags("r_screenoverlay");
	SetCommandFlags("r_screenoverlay", iFlags &~ FCVAR_CHEAT);

	for(new i = 1; i <= MaxClients; i++) if(IsClientInGame(i))
		ClientCommand(i, "r_screenoverlay \"%s\"", sFile);

	SetCommandFlags("r_screenoverlay", iFlags);

	if(sSound[0])
	{
		EmitSoundToAll(sSound);
		strcopy(g_strCurrentSound, sizeof(g_strCurrentSound), sSound);
	}

	g_bOverlayed = true;
	CreateTimer(fTime, Timer_RemoveOverlay, _, TIMER_FLAG_NO_MAPCHANGE);
}

public ClearScreenOverlay()
{
	new iFlags = GetCommandFlags("r_screenoverlay");
	SetCommandFlags("r_screenoverlay", iFlags &~ FCVAR_CHEAT);

	for(new i = 1; i <= MaxClients; i++) if(IsClientInGame(i))
		ClientCommand(i, "r_screenoverlay \"\"");

	SetCommandFlags("r_screenoverlay", iFlags);
}

// ====[ TIMERS ]==============================================================
public Action:Timer_RemoveOverlay(Handle:hTimer)
{
	g_bOverlayed = false;
	ClearScreenOverlay();

	if(g_strCurrentSound[0])
	{
		for(new i = 1; i <= MaxClients; i++) if(IsClientInGame(i))
			StopSound(i, SNDCHAN_AUTO, g_strCurrentSound);
	}

	strcopy(g_strCurrentSound, sizeof(g_strCurrentSound), "");
}

// ====[ STOCKS ]==============================================================
stock bool:IsValidClient(iClient)
{
	if(iClient <= 0 || iClient > MaxClients || !IsClientInGame(iClient))
		return false;
	return true;
}