#pragma semicolon 1
#include <sdktools>
#define PVERSION "1.3.62"

new Handle:gH_Enabled = INVALID_HANDLE;
new Handle:gH_LAW = INVALID_HANDLE;
new Handle:gH_Return = INVALID_HANDLE;
new Handle:gH_Sound = INVALID_HANDLE;
new Handle:gH_SoundAll = INVALID_HANDLE;

new bool:bEnabled = true;
new bool:bLAW = true;
new bool:bRtn = false;
new bool:bSnd = false;
new bool:bSndAll = true;

new String:zsSnd[255];

public Plugin:myinfo =
{
	name = "Flashlight",
	author = "Mitch",
	description = "Replaces +lookatweapon with a toggleable flashlight. Also adds the command: sm_flashlight",
	version = PVERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=227224"
};

public OnPluginStart()
{
	gH_Enabled = CreateConVar("sm_flashlight_enabled", "1", 
					"0 = Disables flashlight; 1 = Enables flashlight", 		FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gH_LAW = CreateConVar("sm_flashlight_lookatweapon", "1", 
					"0 = Doesn't use +lookatweapon; 1 = hooks +lookatweapon", 		FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gH_Return = CreateConVar("sm_flashlight_return", "0", 
					"0 = Doesn't return blocking +look at weapon; 1 = Does return", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gH_Sound = CreateConVar("sm_flashlight_sound", "items/flashlight1.wav", 
					"Sound path to use when a player uses the flash light.", FCVAR_PLUGIN);
	gH_SoundAll = CreateConVar("sm_flashlight_sound_all", "1", 
					"Play the sound to all players, or just to the activator?", FCVAR_PLUGIN);
	UpdateSound();
	HookConVarChange(gH_Sound, ConVarChanged);
	HookConVarChange(gH_Enabled, ConVarChanged);
	HookConVarChange(gH_LAW, ConVarChanged);
	HookConVarChange(gH_Return, ConVarChanged);
	AutoExecConfig();

	CreateConVar("sm_flashlight_version", PVERSION, "CsGoFlashlight Version", FCVAR_DONTRECORD|FCVAR_NOTIFY);

	AddCommandListener(Command_LAW, "+lookatweapon");	//Hooks cs:go's flashlight replacement 'look at weapon'.
	RegConsoleCmd("sm_flashlight", Command_FlashLight); 	//Bindable Flashlight command
}

public ConVarChanged(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	if(cvar == gH_Enabled)
		bEnabled = bool:StringToInt(newVal);
	if(cvar == gH_LAW)
		bLAW = bool:StringToInt(newVal);
	if(cvar == gH_Return)
		bRtn = bool:StringToInt(newVal);
	if(cvar == gH_SoundAll)
		bSndAll = bool:StringToInt(newVal);
	if(cvar == gH_Sound) {
		UpdateSound();
	}
}

public UpdateSound() {
	decl String:formatedSound[256];
	GetConVarString(gH_Sound, formatedSound, sizeof(formatedSound));
	if(StrEqual(formatedSound, "") || StrEqual(formatedSound, "0")) {
		bSnd = false;
	} else {
		strcopy(zsSnd, sizeof(zsSnd), formatedSound);
		bSnd = true;
		PrecacheSound(zsSnd);
		if(!StrEqual(formatedSound, "items/flashlight1.wav")) {
			Format(formatedSound, sizeof(formatedSound), "sound/%s", formatedSound);
			AddFileToDownloadsTable(formatedSound);
		}
	}
}

public OnMapStart() {
	if(bSnd) {
		PrecacheSound(zsSnd, true);
	}
}

public Action:Command_LAW(client, const String:command[], argc)
{
	if(!bLAW || !bEnabled) //Enable this hook?
		return Plugin_Continue;

	if(!IsClientInGame(client)) //If player is not in-game then ignore!
		return Plugin_Continue;

	if(!IsPlayerAlive(client)) //If player is not alive then continue the command.
		return Plugin_Continue;	

	ToggleFlashlight(client);

	return (bRtn) ? Plugin_Continue : Plugin_Handled;
}

public Action:Command_FlashLight(client, args)
{
	if(!bEnabled)
		return Plugin_Handled;

	if (IsClientInGame(client) && IsPlayerAlive(client)) {
		ToggleFlashlight(client);
	}
	return Plugin_Handled;
}

ToggleFlashlight(client) {
	SetEntProp(client, Prop_Send, "m_fEffects", GetEntProp(client, Prop_Send, "m_fEffects") ^ 4);
	if(bSnd) {
		if(bSndAll) {
			EmitSoundToAll(zsSnd, client);
		} else {
			EmitSoundToClient(client, zsSnd);
		}
	}
}