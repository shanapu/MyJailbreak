// © Maxim "Kailo" Telezhenko, 2015
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>

#define PLUGIN_VERSION "0.5.2-beta"

#include <sdktools>
#include <cstrike>

#pragma newdecls required
#pragma semicolon 1

//Compile defines
#define CONFIRM_MENUS
#define NEW_USE_LOGIC
#define HAND_MODE
//#define DOOR_HOOKS

public Plugin myinfo =
{
	name = "Smart Jail Doors",
	author = "Maxim 'Kailo' Telezhenko",
	description = "Core API for actions with doors on Jail Break servers. Custom jail's doors buttons.",
	version = PLUGIN_VERSION,
	url = "http://steamcommunity.com/id/kailo97/"
};

#define DATAFILE		"smartjaildoors.txt" // Path to config save. May be in future do ConVar.

#define CHAT_PATTERN	"[SJD] %t" // Pattern for all plugin's msgs in chat. If you want replace tag - edit this. (no support colors tags)

#define BUTTON_USE		80.0 // Distance before button for active
#define BUTTON_HEIGHT	52.2 // Button settings
#define USE_AREA		15.0 // Distance from button top as radius sphere where u can use button
#define BUTTON_USE_SOUND "buttons/button3.wav" // Default button use sound
#define BUTTON_GLOW_COLOR "0 150 0" // Default color for glow - green
#define BUTTON_CHOOSEN_GLOW_COLOR "255 0 0" // Defailt color for glow then choosen - red

KeyValues g_kv;

typeset DoorHandler
{
	function void (const char[] name, const char[] clsname, any data);
	
	function void (const char[] name, const char[] clsname);
}

typeset ButtonHandler
{
	function void (int buttonid, float origin[3], any data);
	
	function void (int buttonid, float origin[3]);
}

#if defined CONFIRM_MENUS
typedef ConfirmMenuHandler = function void (int client, bool result, any data);
#endif

#if defined CONFIRM_MENUS
DataPack g_MenuDataPasser[MAXPLAYERS+1];
#endif

int g_buttonindex[2048];
int g_sjdclient;
bool g_sjdlookat;
int g_glowedbutton;
Menu g_SJDMenu2;
int g_ghostbutton;
bool g_ghostbuttonsave;
float g_ghostbuttonpos[3];
int g_oldButtons[MAXPLAYERS];

ConVar cv_sjd_buttons_sound_enable;
ConVar cv_sjd_buttons_sound;
ConVar cv_sjd_buttons_glow;
ConVar cv_sjd_buttons_glow_color;
ConVar cv_sjd_buttons_filter;

//Downloadable files
char downloadablefiles[][] = {
	"models/kzmod/buttons/standing_button.dx90.vtx",
	"models/kzmod/buttons/standing_button.mdl",
	"models/kzmod/buttons/standing_button.phy",
	"models/kzmod/buttons/standing_button.vvd",
	"materials/models/kzmod/buttons/stand_button.vmt",
	"materials/models/kzmod/buttons/stand_button.vtf"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("SJD_OpenDoors", Native_SJD_OpenDoors);
	CreateNative("SJD_CloseDoors", Native_SJD_CloseDoors);
	CreateNative("SJD_ToggleDoors", Native_SJD_ToggleDoors);
	CreateNative("SJD_ToggleExDoors", Native_SJD_ToggleExDoors);
	CreateNative("SJD_IsMapConfigured", Native_SJD_IsMapConfigured);
	
	RegPluginLibrary("smartjaildoors");
	
	return APLRes_Success;
}

public void OnPluginStart()
{
	LoadTranslations("smartjaildoors.phrases");
	LoadTranslations("common.phrases");
	
	g_kv = new KeyValues("smartjaildoors");
	g_kv.ImportFromFile(DATAFILE);
	if (!FileExists(DATAFILE))
		g_kv.ExportToFile(DATAFILE);
	
	RegAdminCmd("sm_sjd", Command_SJDMenu, ADMFLAG_ROOT);
	RegAdminCmd("sm_sjddebug", Command_SJDDebug, ADMFLAG_ROOT);
	#if defined HAND_MODE
	RegAdminCmd("sm_sjdhm", Command_Handmode, ADMFLAG_ROOT);
	#endif
	
	HookEvent("round_start", OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("round_end", OnRoundEnd, EventHookMode_PostNoCopy);
	HookEvent("player_death", OnPlayerDeath);
	
	CreateTimer(0.1, ShowLookAt, _, TIMER_REPEAT);
	
	cv_sjd_buttons_sound_enable = CreateConVar("sjd_buttons_sound_enable", "1", "Sound switch", _, true, 0.0, true, 1.0);
	cv_sjd_buttons_sound = CreateConVar("sjd_buttons_sound", BUTTON_USE_SOUND, "Sound file");
	cv_sjd_buttons_glow = CreateConVar("sjd_buttons_glow", "0", "Glow switch", _, true, 0.0, true, 1.0);
	cv_sjd_buttons_glow.AddChangeHook(ConVarChanged);
	cv_sjd_buttons_glow_color = CreateConVar("sjd_buttons_glow_color", BUTTON_GLOW_COLOR, "Glow color");
	cv_sjd_buttons_glow_color.AddChangeHook(ConVarChanged);
	cv_sjd_buttons_filter = CreateConVar("sjd_buttons_filter", "0", "If 0 all can use buttons, if 1 only CT can use buttons", _, true, 0.0, true, 1.0);
	
	ExecuteButtons(SpawnButtonsOnRoundStart);
}

public void OnPluginEnd()
{
	if (g_sjdclient != 0) {
		CloseSJDMenu();
		delete g_SJDMenu2;
	}
	
	for (int i = 0; i < sizeof(g_buttonindex); i++)
		if (g_buttonindex[i])
			AcceptEntityInput(g_buttonindex[i], "Kill");
		else
			break;
	
	g_kv.ExportToFile(DATAFILE);
	delete g_kv;
}

public Action ShowLookAt(Handle timer)
{
	if (g_sjdlookat) {
		int target = GetClientAimTarget(g_sjdclient, false);
		//char buffer[128]; // devpoint2 - don't work
		//FormatEx(buffer, sizeof(buffer), "%t", "Save door"); // devpoint2
		if (target == -1) {
			//g_SJDMenu2.InsertItem(0, "save", buffer, ITEMDRAW_DISABLED); // devpoint2
			PrintHintText(g_sjdclient, "%t", "Save door denied - not found");
		} else {
			//g_SJDMenu2.InsertItem(0, "save", buffer); // devpoint2
			char clsname[64], name[128];
			GetEntityClassname(target, clsname, sizeof(clsname));
			GetEntityName(target, name, sizeof(name));
			PrintHintText(g_sjdclient, "%s (%d): %s", clsname, target, name);
		}
	}
}

public void ConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (convar == cv_sjd_buttons_glow) {
		for (int i = 0; i < sizeof(g_buttonindex); i++)
			if (g_buttonindex[i] != 0) {
				if (g_buttonindex[i] != g_glowedbutton)
					if (StringToInt(newValue)) {
						SetDefaultGlowColor(g_buttonindex[i]);
						AcceptEntityInput(g_buttonindex[i], "SetGlowEnabled");
					} else {
						AcceptEntityInput(g_buttonindex[i], "SetGlowDisabled");
						SetGlowColor(g_buttonindex[i], BUTTON_CHOOSEN_GLOW_COLOR);
					}
			} else
				break;
	} else {
		if (cv_sjd_buttons_glow.BoolValue)
			for (int i = 0; i < sizeof(g_buttonindex); i++)
				if (g_buttonindex[i] != 0) {
					if (g_buttonindex[i] != g_glowedbutton)
						SetDefaultGlowColor(g_buttonindex[i]);
				} else
					break;
	}
}

stock void GetEntityName(int entity, char[] name, int maxlen)
{
	GetEntPropString(entity, Prop_Data, "m_iName", name, maxlen);
}

bool ExecuteDoors(DoorHandler handler, any data = 0)
{
	char mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));

	if (!g_kv.JumpToKey(mapname))
		return false;
	
	if (!g_kv.JumpToKey("doors")) {
		g_kv.Rewind();
		return false;
	}
	
	if (!g_kv.GotoFirstSubKey()) {
		g_kv.Rewind();
		return false;
	}
	
	char name[64], clsname[64];
	do {
		g_kv.GetSectionName(name, sizeof(name));
		g_kv.GetString("class", clsname, sizeof(clsname));
		Call_StartFunction(null, handler);
		Call_PushString(name);
		Call_PushString(clsname);
		if (data != 0)
			Call_PushCell(data);
		Call_Finish();
	} while (g_kv.GotoNextKey());
	
	g_kv.Rewind();
	
	return true;
}

void InputToDoor(const char[] name, const char[] clsname, const char[] input)
{
	
	int doors[128], MaxEntities = GetMaxEntities(), i;
	char entclsname[64], entname[64];
	for (i = MaxClients+1; i < MaxEntities; i++) {
		if (IsValidEntity(i)) {
			GetEntityClassname(i, entclsname, sizeof(entclsname));
			if (StrEqual(clsname, entclsname)) {
				GetEntityName(i, entname, sizeof(entname));
				if (StrEqual(name, entname, false)) {
					doors[++doors[0]] = i;
				}
			}
		}
	}
	
	if (doors[0] == 0) {
		char mapname[64];
		GetCurrentMap(mapname, sizeof(mapname));
		LogError("No entity with \"%s\" name on  map.", name, mapname);
	}
	
	for (i = 1; i <= doors[0]; i++)
		AcceptEntityInput(doors[i], input);
}

void DeleteDoor(const char[] name)
{
	char mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	g_kv.JumpToKey(mapname);
	g_kv.JumpToKey("doors");
	g_kv.JumpToKey(name);
	g_kv.DeleteThis();
	if (!g_kv.GotoFirstSubKey())
		g_kv.DeleteThis();
	g_kv.Rewind();
	g_kv.ExportToFile(DATAFILE);
}

void SaveDoorByEnt(int entity)
{
	char clsname[64], name[128];
	GetEntityClassname(entity, clsname, sizeof(clsname));
	GetEntityName(entity, name, sizeof(name));
	SaveDoor(name, clsname);
}

void SaveDoor(const char[] name, const char[] clsname)
{
	char mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	
	g_kv.JumpToKey(mapname, true);
	g_kv.JumpToKey("doors", true);
	g_kv.JumpToKey(name, true);
	g_kv.SetString("class", clsname);
	g_kv.Rewind();
	g_kv.ExportToFile(DATAFILE);
}

void ToggleDoorsOnMap(bool bynative = false)
{
	DataPack Pack = new DataPack();
	Pack.WriteCell(bynative);
	if (!ExecuteDoors(ToggleDoor, Pack))
		if (!bynative)
			PrintToChat(g_sjdclient, CHAT_PATTERN, "Can not toggle", "No doors");
	delete Pack;
}

public void ToggleDoor(const char[] name, const char[] clsname, any data)
{
	DataPack Pack = view_as<DataPack>(data);
	if (StrEqual("func_movelinear", clsname)) {
		InputToDoor(name, clsname, "Open");
		InputToDoor(name, clsname, "Close");
	} else if (StrEqual("func_door", clsname) || StrEqual("func_door_rotating", clsname) || StrEqual("prop_door_rotating", clsname) || StrEqual("func_wall_toggle", clsname)) {
		InputToDoor(name, clsname, "Toggle");
	} else if (StrEqual("func_tracktrain", clsname)) {
		// Can't toggle 'func_tracktrain' entity class.
		Pack.Reset();
		if (!Pack.ReadCell())
			PrintToChat(g_sjdclient, CHAT_PATTERN, "Can not toggle", "Invalid entity class for toggle", clsname);
	} else if (StrEqual("func_breakable", clsname)) {
		// Can't toggle 'func_breakable' entity class.
		Pack.Reset();
		if (!Pack.ReadCell())
			PrintToChat(g_sjdclient, CHAT_PATTERN, "Can not toggle", "Invalid entity class for toggle", clsname);
	}
}

void ToggleExDoorsOnMap(bool bynative = false)
{
	if (!ExecuteDoors(ToggleDoorEx))
		if (!bynative)
			PrintToChat(g_sjdclient, CHAT_PATTERN, "Can not toggle", "No doors");
}

public void ToggleDoorEx(const char[] name, const char[] clsname)
{
	if (StrEqual("func_movelinear", clsname)) {
		InputToDoor(name, clsname, "Open");
		InputToDoor(name, clsname, "Close");
	} else if (StrEqual("func_door", clsname) || StrEqual("func_door_rotating", clsname) || StrEqual("prop_door_rotating", clsname) || StrEqual("func_wall_toggle", clsname)) {
		InputToDoor(name, clsname, "Toggle");
	} else if (StrEqual("func_tracktrain", clsname)) {
		InputToDoor(name, clsname, "StartForward");
	} else if (StrEqual("func_breakable", clsname)) {
		InputToDoor(name, clsname, "Break");
	}
}

public void OnMapStart()
{
	PrecacheModel("models/kzmod/buttons/standing_button.mdl");

	for (int i=0;i<sizeof(downloadablefiles);i++)
		AddFileToDownloadsTable(downloadablefiles[i]);

	if (!IsSoundPrecached(BUTTON_USE_SOUND))
		PrecacheSound(BUTTON_USE_SOUND);
	#if defined DOOR_HOOKS
	ExecuteDoors(AddDoorHooks);
	#endif
}

#if defined DOOR_HOOKS
public void AddDoorHooks(const char[] name, const char[] clsname)
{
	HookDoorAction(name, clsname);
}

public void OnMapEnd()
{
	ExecuteDoors(RemoveDoorHooks);
}

public void RemoveDoorHooks(const char[] name, const char[] clsname)
{
	UnhookDoorAction(name, clsname);
}
#endif

stock void GetAimOrigin(int client, float origin[3])
{
	float pos[3], ang[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);
	
	Handle trace = TR_TraceRayFilterEx(pos, ang, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	
	if(TR_DidHit(trace))
		TR_GetEndPosition(origin, trace);
	
	CloseHandle(trace);
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask) 
{
    return entity > GetMaxClients();
}

public Action OnPlayerRunCmd(int client, int &f_buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if (g_ghostbutton != 0 && !g_ghostbuttonsave) {
		float origin[3];
		GetAimOrigin(g_sjdclient, origin);
		if (!IsSamePosition(origin, g_ghostbuttonpos))
			TeleportEntity(g_ghostbutton, origin, NULL_VECTOR, NULL_VECTOR);
	}
	
	if (f_buttons & IN_USE == IN_USE && g_oldButtons[client] & IN_USE != IN_USE)
	{
#if defined NEW_USE_LOGIC
		if (IsPlayerAlive(client) && HaveButtonsInCfg() && (!cv_sjd_buttons_filter.BoolValue || GetClientTeam(client) == CS_TEAM_CT)) {
			char mapName[64];
			GetCurrentMap(mapName, sizeof(mapName));
			if (IsMapConfigured(mapName)) {
				g_kv.JumpToKey(mapName);
				g_kv.JumpToKey("buttons");
				g_kv.GotoFirstSubKey();
				
				int counter;
				float buttonPos[2048][3];
				do
					g_kv.GetVector("pos", buttonPos[counter++]);
				while (g_kv.GotoNextKey());
				
				g_kv.Rewind();
				
				for (int i = 0; i < counter; i++)
					buttonPos[i][2] += BUTTON_HEIGHT;
				
				float ang[3];
				GetClientEyeAngles(client, ang);
				float vec[3];
				GetAngleVectors(ang, vec, NULL_VECTOR, NULL_VECTOR);
				float eyePos[3];
				GetClientEyePosition(client, eyePos);
				
				float temp_vec[3], temp_pos[3];
				bool used;
				for (float i = 0.0; i <= BUTTON_USE; i++) {
					temp_vec = vec;
					ScaleVector(temp_vec, i);
					temp_pos = eyePos;
					for (int i2 = 0; i2 < sizeof(eyePos); i2++)
						temp_pos[i2] += temp_vec[i2];
					
					for (int i2 = 0; i2 < counter; i2++)
						if (DistanceBetweenPoints(buttonPos[i2], temp_pos) <=  USE_AREA) {
							used = true;
							ToggleExDoorsOnMap();
							if (cv_sjd_buttons_sound_enable.BoolValue)
								EmitButtonSound(buttonPos[i2]);
							break;
						}
					
					if (used)
						break;
				}
			}
		}
#else
		if (IsPlayerAlive(client) && HaveButtonsInCfg() && (!cv_sjd_buttons_filter.BoolValue || GetClientTeam(client) == CS_TEAM_CT)) {
			int target = GetClientAimTarget(client, false);
			if (target != -1) {
				char mapname[64];
				GetCurrentMap(mapname, sizeof(mapname));
				
				if (g_kv.JumpToKey(mapname)) {
					if (g_kv.JumpToKey("buttons")) {
						int buttons[2048];
						if (g_kv.GotoFirstSubKey()) {
							char buffer[8];
							g_kv.GetSectionName(buffer, sizeof(buffer));
							buttons[++buttons[0]] = StringToInt(buffer);
							while(g_kv.GotoNextKey()) {
								g_kv.GetSectionName(buffer, sizeof(buffer));
								buttons[++buttons[0]] = StringToInt(buffer);
							}
							g_kv.Rewind();
						} else
							g_kv.Rewind();
						
						bool Isbutton;
						int buttonid;
						for (int i=1;i<=buttons[0];i++)
							if (g_buttonindex[buttons[i]] == target) {
								Isbutton = true;
								buttonid = buttons[i];
								break;
							}
						
						if (Isbutton) {
							g_kv.JumpToKey(mapname);
							g_kv.JumpToKey("buttons");
							char buffer[64];
							FormatEx(buffer, sizeof(buffer), "%d", buttonid);
							g_kv.JumpToKey(buffer);
							float buttonpos[3];
							g_kv.GetVector("pos", buttonpos);
							g_kv.Rewind();
							
							buttonpos[2] = buttonpos[2] + BUTTON_HEIGHT;
							
							float origin[3];
							GetClientEyePosition(client, origin);
							if (DistanceBetweenPoints(buttonpos, origin) <= BUTTON_USE) {
								ToggleExDoorsOnMap();
								if (cv_sjd_buttons_sound_enable.BoolValue)
									EmitButtonSound(buttonpos);
							}
						}
					} else
						g_kv.Rewind();
				}
			}
		}
#endif
	}
	
	g_oldButtons[client] = f_buttons;
}

bool HaveButtonsInCfg()
{
	char mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	
	if (!g_kv.JumpToKey(mapname))
		return false;
	
	if (!g_kv.JumpToKey("buttons")) {
		g_kv.Rewind();
		return false;
	}
	
	bool result;
	
	if (g_kv.GotoFirstSubKey())
		result = true;
	
	g_kv.Rewind();
	
	return result;
}

float DistanceBetweenPoints(const float point1[3], const float point2[3])
{
	return SquareRoot(Pow(point2[0] - point1[0], 2.0) + Pow(point2[1] - point1[1], 2.0) + Pow(point2[2] - point1[2], 2.0));
}

bool IsSamePosition(float pos1[3], float pos2[3])
{
	return (pos1[0] == pos2[0] && pos1[1] == pos2[1] && pos1[2] == pos2[2]) ? true : false;
}

#if defined CONFIRM_MENUS
void ShowConfirmMenu(int client, ConfirmMenuHandler handler, any data = 0, const char[] title = "", any ...)
{
	SetGlobalTransTarget(client);
	Menu menu = new Menu(ConfirmMenu);
	if (strlen(title)) {
		char buffer[256];
		VFormat(buffer, sizeof(buffer), title, 5);
		menu.SetTitle(buffer);
	}
	char buffer[128];
	FormatEx(buffer, sizeof(buffer), "%t", "Yes");
	menu.AddItem("yes", buffer);
	FormatEx(buffer, sizeof(buffer), "%t", "No");
	menu.AddItem("no", buffer);
	g_MenuDataPasser[client] = new DataPack();
	WritePackFunction(g_MenuDataPasser[client], handler);
	if (data != 0) {
		WritePackCell(g_MenuDataPasser[client], true);
		WritePackCell(g_MenuDataPasser[client], data);
	} else
		WritePackCell(g_MenuDataPasser[client], false);
	ResetPack(g_MenuDataPasser[client]);
	menu.ExitButton = false;
	g_SJDMenu2 = menu;
	menu.Display(client, 5);
}

public int ConfirmMenu(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action) {
		case MenuAction_Select: {
			char info[16];
			menu.GetItem(param2, info, sizeof(info));
			ConfirmMenuHandler handler = view_as<ConfirmMenuHandler>(ReadPackFunction(g_MenuDataPasser[param1]));
			any data;
			if (ReadPackCell(g_MenuDataPasser[param1]))
				data = ReadPackCell(g_MenuDataPasser[param1]);
			delete g_MenuDataPasser[param1];
			if (StrEqual(info, "yes"))
				ExecuteConfirmMenuHandler(param1, handler, true, data);
			else
				ExecuteConfirmMenuHandler(param1, handler, false, data);
		}
		case MenuAction_Cancel: {
			ConfirmMenuHandler handler = view_as<ConfirmMenuHandler>(ReadPackFunction(g_MenuDataPasser[param1]));
			any data;
			if (ReadPackCell(g_MenuDataPasser[param1]))
				data = ReadPackCell(g_MenuDataPasser[param1]);
			delete g_MenuDataPasser[param1];
			ExecuteConfirmMenuHandler(param1, handler, false, data);
		}
		case MenuAction_End: delete menu;
	}
}

void ExecuteConfirmMenuHandler(int client, ConfirmMenuHandler handler, bool result, any data = 0)
{
	Call_StartFunction(null, handler);
	Call_PushCell(client);
	Call_PushCell(result);
	if (data != 0)
		Call_PushCell(data);
	Call_Finish();
}
#endif

int SaveButton(float origin[3])
{
	char mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	
	g_kv.JumpToKey(mapname, true);
	g_kv.JumpToKey("buttons", true);
	
	int buttons[2048];
	if (g_kv.GotoFirstSubKey()) {
		char buffer[8];
		g_kv.GetSectionName(buffer, sizeof(buffer));
		buttons[++buttons[0]] = StringToInt(buffer);
		while(g_kv.GotoNextKey()) {
			g_kv.GetSectionName(buffer, sizeof(buffer));
			buttons[++buttons[0]] = StringToInt(buffer);
		}
		g_kv.GoBack();
	}
	int buttonid;
	while (SaveButtonHelper(buttonid, buttons))
		buttonid++;
	
	char sectionname[8];
	FormatEx(sectionname, sizeof(sectionname), "%d", buttonid);
	g_kv.JumpToKey(sectionname, true);
	g_kv.SetVector("pos", origin);
	g_kv.Rewind();
	g_kv.ExportToFile(DATAFILE);
	
	return buttonid;
}

bool SaveButtonHelper(int &buttonid, int[] buttons)
{
	for (int i=1;i<=buttons[0];i++)
		if (buttons[i] == buttonid)
			return true;
	return false;
}

bool ExecuteButtons(ButtonHandler handler, any data = 0)
{
	char mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	
	if (!g_kv.JumpToKey(mapname))
		return false;
	
	if (!g_kv.JumpToKey("buttons")) {
		g_kv.Rewind();
		return false;
	}
	
	if (!g_kv.GotoFirstSubKey()) {
		g_kv.Rewind();
		return false;
	}
	
	char buffer[8];
	float origin[3];
	do {
		g_kv.GetSectionName(buffer, sizeof(buffer));
		g_kv.GetVector("pos", origin);
		Call_StartFunction(null, handler);
		Call_PushCell(StringToInt(buffer));
		Call_PushArray(origin, 3);
		if (data != 0)
			Call_PushCell(data);
		Call_Finish();
	} while (g_kv.GotoNextKey());
	
	g_kv.Rewind();
	
	return true;
}

void SpawnButton(int buttonid)
{
	char mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	
	g_kv.JumpToKey(mapname);
	g_kv.JumpToKey("buttons");
	
	char buffer[16];
	FormatEx(buffer, sizeof(buffer), "%d", buttonid);
	g_kv.JumpToKey(buffer);
	float origin[3];
	g_kv.GetVector("pos", origin);
	g_kv.Rewind();
	CreateButton(buttonid, origin);
}

void CreateButton(int buttonid, const float origin[3])
{
	int button = CreateEntityByName("prop_dynamic_glow");
	DispatchKeyValue(button, "model", "models/kzmod/buttons/standing_button.mdl");
	DispatchKeyValue(button, "solid", "6");
	if (cv_sjd_buttons_glow.BoolValue) {
		char color[12];
		cv_sjd_buttons_glow_color.GetString(color, sizeof(color));
		DispatchKeyValue(button, "glowcolor", color);
		DispatchKeyValue(button, "glowenabled", "1");
	} else {
		DispatchKeyValue(button, "glowcolor", "255 0 0");
		DispatchKeyValue(button, "glowenabled", "0");
	}
	DispatchSpawn(button);
	TeleportEntity(button, origin, NULL_VECTOR, NULL_VECTOR);
	g_buttonindex[buttonid] = button;
}

public void OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	ExecuteButtons(SpawnButtonsOnRoundStart);
}

public void OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (g_sjdclient != 0) {
		CloseSJDMenu();
		if (g_SJDMenu2 != null)
			delete g_SJDMenu2;
	}
}

public void OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client == g_sjdclient) {
		CloseSJDMenu();
		if (g_SJDMenu2 != null)
			delete g_SJDMenu2;
		PrintToChat(client, CHAT_PATTERN, "Can not use SJD then dead");
	}
}

public void OnClientDisconnect(int client)
{
	g_oldButtons[client] = 0;
	
	if (client == g_sjdclient) {
		CloseSJDMenu();
		if (g_SJDMenu2 != null)
			delete g_SJDMenu2;
	}
}

public void SpawnButtonsOnRoundStart(int buttonid, float origin[3])
{
	CreateButton(buttonid, origin);
}

void RemoveButton(int buttonid)
{
	AcceptEntityInput(g_buttonindex[buttonid], "Kill");
	g_buttonindex[buttonid] = 0;
	
	char mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	g_kv.JumpToKey(mapname);
	g_kv.JumpToKey("buttons");
	char buffer[16];
	FormatEx(buffer, sizeof(buffer), "%d", buttonid);
	g_kv.JumpToKey(buffer);
	g_kv.DeleteThis();
	g_kv.Rewind();
	g_kv.ExportToFile(DATAFILE);
}

void OpenDoorsOnMap(bool bynative = false)
{
	DataPack Pack = new DataPack();
	Pack.WriteCell(bynative);
	if (!ExecuteDoors(OpenDoor, Pack))
		if (!bynative)
			PrintToChat(g_sjdclient, CHAT_PATTERN, "Can not open", "No doors");
	delete Pack;
}

public void OpenDoor(const char[] name, const char[] clsname, any data)
{
	DataPack Pack = view_as<DataPack>(data);
	if (StrEqual("func_movelinear", clsname) || StrEqual("func_door", clsname) || StrEqual("func_door_rotating", clsname) || StrEqual("prop_door_rotating", clsname)) {
		InputToDoor(name, clsname, "Open");
	} else if (StrEqual("func_tracktrain", clsname)) {
		InputToDoor(name, clsname, "StartForward");
	} else if (StrEqual("func_breakable", clsname)) {
		InputToDoor(name, clsname, "Break");
	} else if (StrEqual("func_wall_toggle", clsname)) {
		// Can't open 'func_wall_toggle' entity class.
		Pack.Reset();
		if (!Pack.ReadCell())
			PrintToChat(g_sjdclient, CHAT_PATTERN, "Can not open", "Invalid entity class for open", clsname);
	}
}

void CloseDoorsOnMap(bool bynative = false)
{
	DataPack Pack = new DataPack();
	Pack.WriteCell(bynative);
	if (!ExecuteDoors(CloseDoor, Pack))
		if (!bynative)
			PrintToChat(g_sjdclient, CHAT_PATTERN, "Can not close", "No doors");
	delete Pack;
}

public void CloseDoor(const char[] name, const char[] clsname, any data)
{
	DataPack Pack = view_as<DataPack>(data);
	if (StrEqual("func_movelinear", clsname) || StrEqual("func_door", clsname) || StrEqual("func_door_rotating", clsname) || StrEqual("prop_door_rotating", clsname)) {
		InputToDoor(name, clsname, "Close");
	} else if (StrEqual("func_tracktrain", clsname)) {
		// Can't close 'func_tracktrain' entity class.
		Pack.Reset();
		if (!Pack.ReadCell())
			PrintToChat(g_sjdclient, CHAT_PATTERN, "Can not close", "Invalid entity class for close", clsname);
	} else if (StrEqual("func_breakable", clsname)) {
		// Can't close 'func_breakable' entity class.
		Pack.Reset();
		if (!Pack.ReadCell())
			PrintToChat(g_sjdclient, CHAT_PATTERN, "Can not close", "Invalid entity class for close", clsname);
	} else if (StrEqual("func_wall_toggle", clsname)) {
		// Can't close 'func_wall_toggle' entity class.
		Pack.Reset();
		if (!Pack.ReadCell())
			PrintToChat(g_sjdclient, CHAT_PATTERN, "Can not close", "Invalid entity class for close", clsname);
	}
}

bool IsMapConfigured(const char[] mapName)
{
	if (!g_kv.JumpToKey(mapName))
		return false;
	
	if (!g_kv.JumpToKey("doors")) {
		g_kv.Rewind();
		return false;
	}
	
	g_kv.Rewind();
	return true;
}

stock void EmitButtonSound(const float pos[3])
{
	char sound[256];
	cv_sjd_buttons_sound.GetString(sound, sizeof(sound));
	EmitAmbientSound(sound, pos, _, SNDLEVEL_CONVO);
}

stock void SetGlowColor(int entity, const char[] color)
{
	char colorbuffers[3][4];
	ExplodeString(color, " ", colorbuffers, sizeof(colorbuffers), sizeof(colorbuffers[]));
	int colors[4];
	for (int i = 0; i < 3; i++)
		colors[i] = StringToInt(colorbuffers[i]);
	colors[3] = 255; // Set alpha
	SetVariantColor(colors);
	AcceptEntityInput(entity, "SetGlowColor");
}

stock void SetDefaultGlowColor(int entity)
{
	char color[12];
	cv_sjd_buttons_glow_color.GetString(color, sizeof(color));
	SetGlowColor(entity, color);
}

stock bool DoorClassValidation(const char[] clsname)
{
	return (StrEqual("func_movelinear", clsname) || StrEqual("func_door", clsname) || StrEqual("func_door_rotating", clsname)
			|| StrEqual("prop_door_rotating", clsname) || StrEqual("func_tracktrain", clsname) || StrEqual("func_breakable", clsname)
			|| StrEqual("func_wall_toggle", clsname));
}

stock void DoorCmd(DoorHandler handler, const char[] name, const char[] clsname)
{
	DataPack Pack = new DataPack();
	Pack.WriteCell(false);
	Call_StartFunction(null, handler);
	Call_PushString(name);
	Call_PushString(clsname);
	Call_PushCell(Pack);
	Call_Finish();
	delete Pack;
}

stock int FindFirstNamedEntity(const char[] name)
{
	char namebuffer[64];
	int MaxEntities = GetMaxEntities();
	for (int i = MaxClients+1; i < MaxEntities; i++)
		if (IsValidEdict(i)) {
			GetEntityName(i, namebuffer, sizeof(namebuffer));
			if (StrEqual(name, namebuffer, false))
				return i;
		}

	LogError("FindFirstNamedEntity don't found entity with \"%s\" name.", name);

	return -1;
}

stock void GetClsnameByName(const char[] name, char[] clsname, int maxlength)
{
	char namebuffer[64];
	int MaxEntities = GetMaxEntities();
	for (int i = MaxClients+1; i < MaxEntities; i++)
		if (IsValidEdict(i)) {
			GetEntityName(i, namebuffer, sizeof(namebuffer));
			if (StrEqual(name, namebuffer, false)) {
				GetEntityClassname(i, clsname, maxlength);
				break;
			}
		}
}

//** Door Hook **//
#if defined DOOR_HOOKS
stock void HookDoorOutput(const char[] name, const char[] output, EntityOutput callback)
{
	int entity;
	if ((entity = FindFirstNamedEntity(name)) != -1)
		HookSingleEntityOutput(entity, output, callback);
}

stock void UnhookDoorOutput(const char[] name, const char[] output, EntityOutput callback)
{
	int entity;
	if ((entity = FindFirstNamedEntity(name)) != -1)
		UnhookSingleEntityOutput(entity, output, callback);
}

stock void HookDoorOpen(const char[] name, const char[] clsname)
{
	if (StrEqual("func_door", clsname) || StrEqual("func_door_rotating", clsname) || StrEqual("prop_door_rotating", clsname))
		HookDoorOutput(name, "OnOpen", OnDoorOpen);
	else if (StrEqual("func_movelinear", clsname))
		HookDoorOutput(name, "OnFullyOpen", OnDoorOpen);
	else if (StrEqual("func_breakable", clsname))
		HookDoorOutput(name, "OnBreak", OnDoorOpen);
	// Can't hook:
	// func_wall_toggle
	// func_tracktrain
}

public void OnDoorOpen(const char[] output, int caller, int activator, float delay)
{
	PrintToChatAll("OnDoorOpen");
}

stock void UnhookDoorOpen(const char[] name, const char[] clsname)
{
	if (StrEqual("func_door", clsname) || StrEqual("func_door_rotating", clsname) || StrEqual("prop_door_rotating", clsname))
		UnhookDoorOutput(name, "OnOpen", OnDoorOpen);
	else if (StrEqual("func_movelinear", clsname))
		UnhookDoorOutput(name, "OnFullyOpen", OnDoorOpen);
	else if (StrEqual("func_breakable", clsname))
		UnhookDoorOutput(name, "OnBreak", OnDoorOpen);
	// Can't hook:
	// func_wall_toggle
	// func_tracktrain
}

stock void HookDoorClose(const char[] name, const char[] clsname)
{
	if (StrEqual("func_door", clsname) || StrEqual("func_door_rotating", clsname) || StrEqual("prop_door_rotating", clsname))
		HookDoorOutput(name, "OnClose", OnDoorClose);
	else if (StrEqual("func_movelinear", clsname))
		HookDoorOutput(name, "OnFullyClosed", OnDoorClose);
	// Can't hook:
	// func_wall_toggle
	// func_tracktrain
	// func_breakable
}

public void OnDoorClose(const char[] output, int caller, int activator, float delay)
{
	PrintToChatAll("OnDoorClose");
}

stock void UnhookDoorClose(const char[] name, const char[] clsname)
{
	if (StrEqual("func_door", clsname) || StrEqual("func_door_rotating", clsname) || StrEqual("prop_door_rotating", clsname))
		UnhookDoorOutput(name, "OnClose", OnDoorClose);
	else if (StrEqual("func_movelinear", clsname))
		UnhookDoorOutput(name, "OnFullyClosed", OnDoorClose);
	// Can't hook:
	// func_wall_toggle
	// func_tracktrain
	// func_breakable
}

stock void HookDoorAction(const char[] name, const char[] clsname)
{
	HookDoorOpen(name, clsname);
	HookDoorClose(name, clsname);
}

stock void HookDoorActionEx(const char[] name)
{
	char clsname[64];
	GetClsnameByName(name, clsname, sizeof(clsname));
	HookDoorOpen(name, clsname);
	HookDoorClose(name, clsname);
}

stock void UnhookDoorAction(const char[] name, const char[] clsname)
{
	UnhookDoorOpen(name, clsname);
	UnhookDoorClose(name, clsname);
}

stock void UnhookDoorActionEx(const char[] name)
{
	char clsname[64];
	GetClsnameByName(name, clsname, sizeof(clsname));
	UnhookDoorOpen(name, clsname);
	UnhookDoorClose(name, clsname);
}
#endif
//** End Door Hook **//

//** Menu Section **//
public Action Command_SJDMenu(int client, int args)
{
	if (IsPlayerAlive(client))
		ShowSJDMenu2(client);
	else
		PrintToChat(client, CHAT_PATTERN, "SJD menu denied - dead");
	
	return Plugin_Handled;
}

void ShowSJDMenu2(int client)
{
	if (g_sjdclient != 0 && g_sjdclient != client) {
		PrintToChat(client, CHAT_PATTERN, "SJD menu denied - already opened");
		return;
	}
	
	g_SJDMenu2 = new Menu(SJDMenu2);
	g_SJDMenu2.SetTitle("Smart Jail Doors");
	char buffer[128];
	SetGlobalTransTarget(client);
	FormatEx(buffer, sizeof(buffer), "%t", "Doors");
	g_SJDMenu2.AddItem("doors", buffer);
	FormatEx(buffer, sizeof(buffer), "%t", "Test");
	g_SJDMenu2.AddItem("test", buffer);
	FormatEx(buffer, sizeof(buffer), "%t", "Buttons");
	g_SJDMenu2.AddItem("buttons", buffer);
	g_SJDMenu2.Display(client, MENU_TIME_FOREVER);
	g_sjdclient = client;
}

void CloseSJDMenu()
{
	DisableButtonGlow();
	DisableLookAt();
	DisableGhostButton();
	g_sjdclient = 0;
}

public int SJDMenu2(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action) {
		case MenuAction_Select: {
			switch (param2) {
				case 0:
					SJDMenu2_ShowDoorsSubMenu(param1);
				case 1:
					SJDMenu2_ShowTestSubMenu(param1);
				case 2:
					SJDMenu2_ShowButtonsSubMenu(param1);
			}
		}
		case MenuAction_Cancel: CloseSJDMenu();
		case MenuAction_End: delete menu;
	}
}

void SJDMenu2_ShowDoorsSubMenu(int client, bool late = false)
{
	SetGlobalTransTarget(client);
	g_SJDMenu2 = new Menu(SJDMenu2_DoorsSubMenu);
	g_SJDMenu2.SetTitle("%t", "Doors title");
	char buffer[128];
	FormatEx(buffer, sizeof(buffer), "%t", "Save door");
	g_SJDMenu2.AddItem("save", buffer);
	if (!ExecuteDoors(SJDMenu2_AddItemsToDoorsSubMenu)) {
		FormatEx(buffer, sizeof(buffer), "%t", "No doors");
		g_SJDMenu2.AddItem("nodoors", buffer, ITEMDRAW_DISABLED);
	}
	g_SJDMenu2.OptionFlags |= MENUFLAG_BUTTON_EXITBACK;
	g_SJDMenu2.Display(client, MENU_TIME_FOREVER);
	EnableLookAt(late);
}

public void SJDMenu2_AddItemsToDoorsSubMenu(const char[] name, const char[] clsname)
{
	g_SJDMenu2.AddItem(name, name);
}

public int SJDMenu2_DoorsSubMenu(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action) {
		case MenuAction_Select: {
			if (param2 == 0) {
				int target = GetClientAimTarget(param1, false);
				if (target == -1) {
					PrintToChat(param1, CHAT_PATTERN, "Save door denied - not found");
					SJDMenu2_ShowDoorsSubMenu(param1, true);
				} else {
					char clsname[64];
					GetEntityClassname(target, clsname, sizeof(clsname));
					if (!DoorClassValidation(clsname)) {
						PrintToChat(param1, CHAT_PATTERN, "Save door denied - unsupported");
						SJDMenu2_ShowDoorsSubMenu(param1, true);
					} else {
						char name[64];
						GetEntityName(target, name, sizeof(name));
						if (strlen(name) == 0) {
							PrintToChat(param1, CHAT_PATTERN, "Save door denied - no name");
							SJDMenu2_ShowDoorsSubMenu(param1, true);
						} else {
#if defined CONFIRM_MENUS
							ShowConfirmMenu(param1, SJDMenu2_ConfirmSaveDoor, target, "%t", "Confirm save door", name);
#else
							SaveDoorByEnt(target);
							#if defined DOOR_HOOKS
							HookDoorActionEx(name);
							#endif
							PrintToChat(param1, CHAT_PATTERN, "Door saved", name);
							SJDMenu2_ShowDoorsSubMenu(param1, true);
#endif
						}
					}
				}
			} else {
				char info[64];
				menu.GetItem(param2, info, sizeof(info));
				SJDMenu2_ShowDoorItemMenu(param1, info);
			}
		}
		case MenuAction_Cancel:
			switch (param2) {
				case MenuCancel_ExitBack:
					ShowSJDMenu2(param1);
				case MenuCancel_Exit:
					CloseSJDMenu();
			}
		case MenuAction_End: {
			DisableLookAt();
			delete menu;
		}
	}
}

#if defined CONFIRM_MENUS
public void SJDMenu2_ConfirmSaveDoor(int client, bool result, any entity)
{
	if (result) {
		SaveDoorByEnt(entity);
		char name[64];
		GetEntityName(entity, name, sizeof(name));
		#if defined DOOR_HOOKS
		HookDoorActionEx(name);
		#endif
		PrintToChat(client, CHAT_PATTERN, "Door saved", name);
	}
	
	if (IsClientInGame(client) && IsPlayerAlive(client))
		SJDMenu2_ShowDoorsSubMenu(client);
}
#endif

void SJDMenu2_ShowDoorItemMenu(int client, const char[] name)
{
	char clsname[64], mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	g_kv.JumpToKey(mapname);
	g_kv.JumpToKey("doors");
	g_kv.JumpToKey(name);
	g_kv.GetString("class", clsname, sizeof(clsname));
	g_kv.Rewind();
	
	SetGlobalTransTarget(client);
	g_SJDMenu2 = new Menu(SJDMenu2_DoorItemMenu);
	char buffer[64];
	FormatEx(buffer, sizeof(buffer), "Name: %s", name);
	g_SJDMenu2.AddItem(name, buffer, ITEMDRAW_DISABLED);
	FormatEx(buffer, sizeof(buffer), "Class name: %s", clsname);
	g_SJDMenu2.AddItem(clsname, buffer, ITEMDRAW_DISABLED);
	FormatEx(buffer, sizeof(buffer), "%t", "Delete door");
	g_SJDMenu2.AddItem("delete", buffer);
	g_SJDMenu2.OptionFlags |= MENUFLAG_BUTTON_EXITBACK;
	g_SJDMenu2.Display(client, MENU_TIME_FOREVER);
}

public int SJDMenu2_DoorItemMenu(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action) {
		case MenuAction_Select: {
			char name[64];
			menu.GetItem(0, name, sizeof(name));
#if defined CONFIRM_MENUS
			DataPack Pack = new DataPack();
			Pack.WriteString(name);
			Pack.Reset();
			ShowConfirmMenu(param1, SJDMenu2_ConfirmDeleteDoor, Pack, "%t", "Confirm delete door", name);
#else
			DeleteDoor(name);
			#if defined DOOR_HOOKS
			UnhookDoorActionEx(name);
			#endif
			PrintToChat(param1, CHAT_PATTERN, "Door deleted", name);
			SJDMenu2_ShowDoorsSubMenu(param1);
#endif
		}
		case MenuAction_Cancel: 
			switch (param2) {
				case MenuCancel_ExitBack:
					SJDMenu2_ShowDoorsSubMenu(param1);
				case MenuCancel_Exit:
					CloseSJDMenu();
			}
		case MenuAction_End: delete menu;
	}
}

#if defined CONFIRM_MENUS
public void SJDMenu2_ConfirmDeleteDoor(int client, bool result, any data)
{
	DataPack Pack = view_as<DataPack>(data);
	if (result) {
		char name[64];
		Pack.ReadString(name, sizeof(name));
		DeleteDoor(name);
		#if defined DOOR_HOOKS
		UnhookDoorActionEx(name);
		#endif
		PrintToChat(client, CHAT_PATTERN, "Door deleted", name);
	}
	
	delete Pack;
	if (IsClientInGame(client) && IsPlayerAlive(client))
		SJDMenu2_ShowDoorsSubMenu(client);
}
#endif

void SJDMenu2_ShowTestSubMenu(int client)
{
	SetGlobalTransTarget(client);
	g_SJDMenu2 = new Menu(SJDMenu2_TestSubMenu);
	g_SJDMenu2.SetTitle("%t", "Test title");
	char buffer[128];
	FormatEx(buffer, sizeof(buffer), "%t", "Test open");
	g_SJDMenu2.AddItem("open", buffer);
	FormatEx(buffer, sizeof(buffer), "%t", "Test close");
	g_SJDMenu2.AddItem("close", buffer);
	FormatEx(buffer, sizeof(buffer), "%t", "Test toggle");
	g_SJDMenu2.AddItem("toggle", buffer);
	FormatEx(buffer, sizeof(buffer), "%t", "Test toggleex");
	g_SJDMenu2.AddItem("toggleex", buffer);
	g_SJDMenu2.OptionFlags |= MENUFLAG_BUTTON_EXITBACK;
	g_SJDMenu2.Display(client, MENU_TIME_FOREVER);
}

public int SJDMenu2_TestSubMenu(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action) {
		case MenuAction_Select: {
			switch (param2) {
				case 0:
					OpenDoorsOnMap();
				case 1:
					CloseDoorsOnMap();
				case 2:
					ToggleDoorsOnMap();
				case 3:
					ToggleExDoorsOnMap();
			}
			SJDMenu2_ShowTestSubMenu(param1);
		}
		case MenuAction_Cancel:
			switch (param2) {
				case MenuCancel_ExitBack:
					ShowSJDMenu2(param1);
				case MenuCancel_Exit:
					CloseSJDMenu();
			}
		case MenuAction_End: delete menu;
	}
}

void SJDMenu2_ShowButtonsSubMenu(int client)
{
	SetGlobalTransTarget(client);
	g_SJDMenu2 = new Menu(SJDMenu2_ButtonsSubMenu);
	g_SJDMenu2.SetTitle("%t", "Buttons title");
	char buffer[128];
	FormatEx(buffer, sizeof(buffer), "%t", "Save button");
	g_SJDMenu2.AddItem("save", buffer);
	if(!ExecuteButtons(SJDMenu2_AddItemsToButtonsSubMenu)) {
		FormatEx(buffer, sizeof(buffer), "%t", "No buttons");
		g_SJDMenu2.AddItem("nobuttons", buffer, ITEMDRAW_DISABLED);
	}
	g_SJDMenu2.OptionFlags |= MENUFLAG_BUTTON_EXITBACK;
	g_SJDMenu2.Display(client, MENU_TIME_FOREVER);
	EnableGhostButton();
}

public void SJDMenu2_AddItemsToButtonsSubMenu(int buttonid, float origin[3])
{
	char info[128], display[128];
	FormatEx(info, sizeof(info), "%d", buttonid);
	FormatEx(display, sizeof(display), "%t", "Button item", buttonid);
	g_SJDMenu2.AddItem(info, display);
}

public int SJDMenu2_ButtonsSubMenu(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action) {
		case MenuAction_Select: {
			if (param2 == 0) {
				float origin[3];
				GetAimOrigin(param1, origin);
#if defined CONFIRM_MENUS
				DataPack Pack = new DataPack();
				Pack.WriteFloat(origin[0]);
				Pack.WriteFloat(origin[1]);
				Pack.WriteFloat(origin[2]);
				Pack.Reset();
				ShowConfirmMenu(param1, SJDMenu2_ConfirmSaveButton, Pack, "%t", "Confirm save button");
				g_ghostbuttonsave = true;
#else
				DisableGhostButton();
				int buttonid = SaveButton(origin);
				SpawnButton(buttonid);
				PrintToChat(param1, CHAT_PATTERN, "Button saved", buttonid);
				SJDMenu2_ShowButtonsSubMenu(param1);
#endif
			} else {
				char info[64];
				menu.GetItem(param2, info, sizeof(info));
				SJDMenu2_ShowButtonItemMenu(param1, StringToInt(info));
				DisableGhostButton();
			}
		}
		case MenuAction_Cancel:
			switch (param2) {
				case MenuCancel_ExitBack:
					ShowSJDMenu2(param1);
				case MenuCancel_Exit:
					CloseSJDMenu();
			}
		case MenuAction_End: {
			if (param1 != MenuEnd_Selected)
				DisableGhostButton();
			delete menu;
		}
	}
}

#if defined CONFIRM_MENUS
public void SJDMenu2_ConfirmSaveButton(int client, bool result, any data)
{
	DataPack Pack = view_as<DataPack>(data);
	if (result) {
		float origin[3];
		origin[0] = Pack.ReadFloat();
		origin[1] = Pack.ReadFloat();
		origin[2] = Pack.ReadFloat();
		
		int buttonid = SaveButton(origin);
		SpawnButton(buttonid);
		PrintToChat(client, CHAT_PATTERN, "Button saved", buttonid);
	}
	
	delete Pack;
	DisableGhostButton();
	if (IsClientInGame(client) && IsPlayerAlive(client))
		SJDMenu2_ShowButtonsSubMenu(client);
}
#endif

void SJDMenu2_ShowButtonItemMenu(int client, int buttonid)
{
	SetGlobalTransTarget(client);
	g_SJDMenu2 = new Menu(SJDMenu2_ButtonItemMenu);
	char info[128], display[128];
	FormatEx(info, sizeof(info), "%d", buttonid);
	FormatEx(display, sizeof(display), "%t", "Button index", buttonid);
	g_SJDMenu2.AddItem(info, display, ITEMDRAW_DISABLED);
	FormatEx(display, sizeof(display), "%t", "Delete button");
	g_SJDMenu2.AddItem("delete", display);
	g_SJDMenu2.OptionFlags |= MENUFLAG_BUTTON_EXITBACK;
	g_SJDMenu2.Display(client, MENU_TIME_FOREVER);
	EnableButtonGlow(buttonid);
}

public int SJDMenu2_ButtonItemMenu(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action) {
		case MenuAction_Select: {
			char info[64];
			menu.GetItem(0, info, sizeof(info));
			int buttonid = StringToInt(info);
#if defined CONFIRM_MENUS
			DataPack Pack = new DataPack();
			Pack.WriteCell(buttonid);
			Pack.Reset();
			ShowConfirmMenu(param1, SJDMenu2_ConfirmDeleteButton, Pack, "%t", "Confirm delete button", buttonid);
#else
			DisableButtonGlow();
			RemoveButton(buttonid);
			PrintToChat(param1, CHAT_PATTERN, "Button deleted", buttonid);
			SJDMenu2_ShowButtonsSubMenu(param1);
#endif
		}
		case MenuAction_Cancel:
			switch (param2) {
				case MenuCancel_ExitBack:
					SJDMenu2_ShowButtonsSubMenu(param1);
				case MenuCancel_Exit:
					CloseSJDMenu();
			}
		case MenuAction_End: {
			if (param1 != MenuEnd_Selected)
				DisableButtonGlow();
			delete menu;
		}
	}
}

#if defined CONFIRM_MENUS
public void SJDMenu2_ConfirmDeleteButton(int client, bool result, any data)
{
	DisableButtonGlow();
	
	DataPack Pack = view_as<DataPack>(data);
	if (result) {
		int buttonid = Pack.ReadCell();
		RemoveButton(buttonid);
		PrintToChat(client, CHAT_PATTERN, "Button deleted", buttonid);
	}
	
	delete Pack;
	if (IsClientInGame(client) && IsPlayerAlive(client))
		SJDMenu2_ShowButtonsSubMenu(client);
}
#endif
//** End Menu Section **//

//** Look at functions **//
void EnableLookAt(bool late = false)
{
	if (late)
		CreateTimer(0.0, LateEnableLookAt);
	else
		g_sjdlookat = true;
}

public Action LateEnableLookAt(Handle timer)
{
	g_sjdlookat = true;
}

void DisableLookAt()
{
	g_sjdlookat = false;
}
//** End Look at functions **//

//** Glow button functions **//
void EnableButtonGlow(int buttonid)
{
	if (g_glowedbutton != 0)
		return;
	
	if (cv_sjd_buttons_glow.BoolValue)
		SetGlowColor(g_buttonindex[buttonid], BUTTON_CHOOSEN_GLOW_COLOR);
	else 
		AcceptEntityInput(g_buttonindex[buttonid], "SetGlowEnabled");
	g_glowedbutton = g_buttonindex[buttonid];
}

void DisableButtonGlow()
{
	if (g_glowedbutton != 0) {
		if (cv_sjd_buttons_glow.BoolValue)
			SetDefaultGlowColor(g_glowedbutton);
		else
			AcceptEntityInput(g_glowedbutton, "SetGlowDisabled");
		g_glowedbutton = 0;
	}
}
//** End Glow button functions **//

//** Ghost button functions **//
void EnableGhostButton(bool save = false, bool late = false)
{
	if (late) {
		CreateTimer(0.0, EnableGhostButtonLate, save);
	} else {
		float origin[3];
		GetAimOrigin(g_sjdclient, origin);
		int button = CreateEntityByName("prop_dynamic");
		DispatchKeyValue(button, "model", "models/kzmod/buttons/standing_button.mdl");
		DispatchKeyValue(button, "renderamt", "112");
		DispatchKeyValue(button, "rendermode", "4");
		DispatchSpawn(button);
		TeleportEntity(button, origin, NULL_VECTOR, NULL_VECTOR);
		g_ghostbutton = button;
		g_ghostbuttonsave = save;
		g_ghostbuttonpos = origin;
	}
}

public Action EnableGhostButtonLate(Handle timer, any save)
{
	EnableGhostButton(save);
}

void DisableGhostButton()
{
	if (g_ghostbutton != 0) {
		AcceptEntityInput(g_ghostbutton, "Kill");
		g_ghostbutton = 0;
		g_ghostbuttonsave = false;
		g_ghostbuttonpos[0] = 0.0;
		g_ghostbuttonpos[1] = 0.0;
		g_ghostbuttonpos[2] = 0.0;
	}
}
//** End Ghost button functions **//

//** Native functions **//
public int Native_SJD_OpenDoors(Handle plugin, int numParams)
{
	OpenDoorsOnMap(true);
}

public int Native_SJD_CloseDoors(Handle plugin, int numParams)
{
	CloseDoorsOnMap(true);
}

public int Native_SJD_ToggleDoors(Handle plugin, int numParams)
{
	ToggleDoorsOnMap(true);
}

public int Native_SJD_ToggleExDoors(Handle plugin, int numParams)
{
	ToggleExDoorsOnMap(true);
}

public int Native_SJD_IsMapConfigured(Handle plugin, int numParams)
{
	int len;
	GetNativeStringLength(1, len);
	
	if (len <= 0)
		return view_as<int>(false);
	
	char[] mapName = new char[len + 1];
	GetNativeString(1, mapName, len + 1);
	
	return view_as<int>(IsMapConfigured(mapName));
}
//** End Native functions **//

//** Debug section **//
public Action Command_SJDDebug(int client, int args)
{
	PrintToChat(client, CHAT_PATTERN, "See console for output");
	
	PrintToConsole(client, "** Smart Jail Doors debug info **");
	
	if (CheckMapsWithNoDoorsCfg(client))
		PrintToConsole(client, "Debuger not found errors.");
	
	return Plugin_Handled;
}

// return false if exist maps with no doors cfg, true if all maps have doors cfg
bool CheckMapsWithNoDoorsCfg(int client)
{
	bool allconfigured = true;
	
	ArrayList MapList = new ArrayList(32);
	ReadMapList(MapList);
	
	int mapCount = MapList.Length, mapsWithNoCfg[256];
	char mapName[32];
	for (int i = 0; i < mapCount; i++)
	{
		MapList.GetString(i, mapName, sizeof(mapName));
		
		if (!IsMapConfigured(mapName)) {
			mapsWithNoCfg[++mapsWithNoCfg[0]] = i;
			allconfigured = false;
		}
	}
	
	if (!allconfigured) {
		PrintToConsole(client, "Not configured maps:");
		for (int i = 1; i <= mapsWithNoCfg[0]; i++) {
			MapList.GetString(mapsWithNoCfg[i], mapName, sizeof(mapName));
			PrintToConsole(client, "%s", mapName);
		}
	}
	
	delete MapList;
	
	return allconfigured;
}
//** End Debug section **//

//** Hand mode section **//
#if defined HAND_MODE
public Action Command_Handmode(int client, int args)
{
	switch (args) {
		case 0: {
			PrintToChat(client, CHAT_PATTERN, "See console for output");
			KeyValues kv = new KeyValues("handmode");
			int MaxEntities = GetMaxEntities();
			char clsname[64], name[64];
			for (int i = MaxClients+1; i < MaxEntities; i++)
				if (IsValidEdict(i)) {
					GetEntityClassname(i, clsname, sizeof(clsname));
					if (DoorClassValidation(clsname)) {
						GetEntityName(i, name, sizeof(name));
						if (strlen(name)) {
							if (kv.JumpToKey(name))
								kv.SetNum("amount", kv.GetNum("amount")+1);
							else {
								kv.JumpToKey(name, true);
								kv.SetString("class", clsname);
								kv.SetNum("amount", 1);
							}
							kv.Rewind();
						}
					}
				}
			if (kv.GotoFirstSubKey()) {
				PrintToConsole(client, "Enitiy list:");
				PrintToConsole(client, "name, class name, amount");
				do {
					kv.GetSectionName(name, sizeof(name));
					kv.GetString("class", clsname, sizeof(clsname));
					PrintToConsole(client, "%s, %s, %d", name, clsname, kv.GetNum("amount"));
				} while (kv.GotoNextKey());
			} else
				PrintToConsole(client, "Suitable entiies not found");
			delete kv;
		}
		case 1: {
			char name[64], clsname[64], namebuffer[64], clsbuffer[64], displayname[64];
			GetCmdArg(1, name, sizeof(name));
			int MaxEntities = GetMaxEntities(), amount;
			for (int i = MaxClients+1; i < MaxEntities; i++)
				if (IsValidEdict(i)) {
					GetEntityClassname(i, clsbuffer, sizeof(clsbuffer));
					if (DoorClassValidation(clsbuffer)) {
						GetEntityName(i, namebuffer, sizeof(namebuffer));
						if (strlen(namebuffer) && StrEqual(name, namebuffer, false)) {
							if (!strlen(displayname))
								strcopy(displayname, sizeof(displayname), namebuffer);
							if (!strlen(clsname))
								strcopy(clsname, sizeof(clsname), clsbuffer);
							amount++;
						}
						strcopy(namebuffer, sizeof(namebuffer), "");
					}
				}
			if (amount) {
				ShowHandmodeMenu(client, displayname, clsname, amount);
			} else
				ReplyToCommand(client, "No entities with %s name.", name);
		}
		default: ReplyToCommand(client, "Usage: sm_sjdhm [<name>]");
	}

	return Plugin_Handled;
}

stock void ShowHandmodeMenu(int client, const char[] name, const char[] clsname, int amount)
{
	Menu menu = new Menu(HandmodeMenu);
	SetGlobalTransTarget(client);
	char buffer[128];
	menu.SetTitle("%s (%s), amt %d", name, clsname, amount);
	menu.AddItem(name, "", ITEMDRAW_IGNORE);
	menu.AddItem(clsname, "", ITEMDRAW_IGNORE);
	FormatEx(buffer, sizeof(buffer), "%d", amount);
	menu.AddItem(buffer, "", ITEMDRAW_IGNORE);
	FormatEx(buffer, sizeof(buffer), "%t", "Test open");
	menu.AddItem("open", buffer);
	FormatEx(buffer, sizeof(buffer), "%t", "Test close");
	menu.AddItem("close", buffer);
	FormatEx(buffer, sizeof(buffer), "%t", "Test toggle");
	menu.AddItem("toggle", buffer);
	FormatEx(buffer, sizeof(buffer), "%t", "Test toggleex");
	menu.AddItem("toggleex", buffer);
	FormatEx(buffer, sizeof(buffer), "%t", "Save door");
	menu.AddItem("save", buffer);
	menu.Display(client, MENU_TIME_FOREVER);
}

public int HandmodeMenu(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action) {
		case MenuAction_Select: {
			char name[64], clsname[64], info[64];
			int amount;
			menu.GetItem(0, name, sizeof(name));
			menu.GetItem(1, clsname, sizeof(clsname));
			menu.GetItem(2, info, sizeof(info));
			amount = StringToInt(info);
			menu.GetItem(param2, info, sizeof(info));
			if (StrEqual("open", info)) {
				DoorCmd(OpenDoor, name, clsname);
				ShowHandmodeMenu(param1, name, clsname, amount);
			} else if (StrEqual("close", info)) {
				DoorCmd(CloseDoor, name, clsname);
				ShowHandmodeMenu(param1, name, clsname, amount);
			} else if (StrEqual("toggle", info)) {
				DoorCmd(ToggleDoor, name, clsname);
				ShowHandmodeMenu(param1, name, clsname, amount);
			} else if (StrEqual("toggleex", info)) {
				DoorCmd(ToggleDoorEx, name, clsname);
				ShowHandmodeMenu(param1, name, clsname, amount);
			} else if (StrEqual("save", info)) {
				#if defined CONFIRM_MENUS
				HandmodeMenu_ShowConfirmSave(param1, name, clsname, amount);
				#else
				SaveDoor(name, clsname);
				SetGlobalTransTarget(param1);
				PrintToChat(param1, CHAT_PATTERN, "Door saved", name);
				#endif
			}
		}
		//case MenuAction_Cancel:
		case MenuAction_End: 
			delete menu;
	}
}

#if defined CONFIRM_MENUS
stock void HandmodeMenu_ShowConfirmSave(int client, const char[] name, const char[] clsname, int amount)
{
	Menu menu = new Menu(HandmodeMenu_ConfirmSave);
	SetGlobalTransTarget(client);
	char buffer[128];
	menu.SetTitle("%t", "Confirm save door", name);
	menu.AddItem(name, "", ITEMDRAW_IGNORE);
	menu.AddItem(clsname, "", ITEMDRAW_IGNORE);
	FormatEx(buffer, sizeof(buffer), "%d", amount);
	menu.AddItem(buffer, "", ITEMDRAW_IGNORE);
	FormatEx(buffer, sizeof(buffer), "%t", "Yes");
	menu.AddItem("yes", buffer);
	FormatEx(buffer, sizeof(buffer), "%t", "No");
	menu.AddItem("no", buffer);
	menu.Display(client, MENU_TIME_FOREVER);
}

public int HandmodeMenu_ConfirmSave(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action) {
		case MenuAction_Select: {
			char name[64], clsname[64], info[64];
			menu.GetItem(0, name, sizeof(name));
			menu.GetItem(1, clsname, sizeof(clsname));
			menu.GetItem(param2, info, sizeof(info));
			if (StrEqual("yes", info)) {
				SaveDoor(name, clsname);
				SetGlobalTransTarget(param1);
				PrintToChat(param1, CHAT_PATTERN, "Door saved", name);
			} else {
				menu.GetItem(2, info, sizeof(info));
				ShowHandmodeMenu(param1, name, clsname, StringToInt(info));
			}
		}
		//case MenuAction_Cancel:
		case MenuAction_End: 
			delete menu;
	}
}
#endif
#endif
//** End Hand mode section **//