/*
 * MyJailbreak - Include File.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
 *
 * This file is part of the MyJailbreak SourceMod Plugin.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */


/******************************************************************************
                   STARTUP
******************************************************************************/


//Defines
#define PLUGIN_VERSION "Beta 8.0"
#define URL_LINK "https://github.com/shanapu/MyJailbreak"


#if defined _myjailbreak_included_
	#endinput
#endif
#define _myjailbreak_included_


public SharedPlugin:__pl_myjailbreak =
{
	name = "myjailbreak", 
	file = "myjailbreak.smx", 
	#if defined REQUIRE_PLUGIN
	required = 1, 
	#else
	required = 0, 
	#endif
};


#if !defined REQUIRE_PLUGIN
public __pl_myjailbreak_SetNTVOptional()
{
	MarkNativeAsOptional("SetEventDayName");
	MarkNativeAsOptional("GetEventDayName");
	MarkNativeAsOptional("SetEventDayRunning");
	MarkNativeAsOptional("IsEventDayRunning");
	MarkNativeAsOptional("SetEventDayPlanned");
	MarkNativeAsOptional("IsEventDayPlanned");
	MarkNativeAsOptional("SetLastGuardRule");
	MarkNativeAsOptional("IsLastGuardRule");
	MarkNativeAsOptional("ActiveLogging");
	MarkNativeAsOptional("FogOn");
	MarkNativeAsOptional("FogOff");
	MarkNativeAsOptional("BeaconOn");
	MarkNativeAsOptional("BeaconOff");
}
#endif



/******************************************************************************
                   NATIVES
******************************************************************************/


/*********************************************************
 * Set the name of the planned/running Event Day
 *
 * @param name			The name of the Event Day
 * @NoReturn
 *********************************************************/
native void SetEventDayName(const char[] name);


/*********************************************************
 * Get the name of the planned/running Event Day
 *
 *
 * @Return				The name of the Event Day
 *********************************************************/
native void GetEventDayName(char[] name);


/*********************************************************
 * Set Boolean Event Day is running
 *
 * @param status		Boolean is running (true = running)
 * @NoReturn
 *********************************************************/
native void SetEventDayRunning(bool status);


/*********************************************************
 * Check bool Event Day is running
 *
 *
 * @Return			true on running, false if not
 *********************************************************/
native bool IsEventDayRunning();


/*********************************************************
 * Set Boolean Event Day is planned
 *
 * @param status		Boolean is planned (true = running)
 * @NoReturn
 *********************************************************/
native void SetEventDayPlanned(bool status);


/*********************************************************
 * Check bool Event Day is planned
 *
 *
 * @Return			true on planned, false if not
 *********************************************************/
native bool IsEventDayPlanned();


/*********************************************************
 * Set Boolean Last Guard Rule is active
 *
 * @param status		Boolean is active (true = active)
 * @NoReturn
 *********************************************************/
native void SetLastGuardRule(bool status);


/*********************************************************
 * Check bool Last Guard Rule is active
 *
 *
 * @Return			true on active, false if not
 *********************************************************/
native bool IsLastGuardRule();


/*********************************************************
 * Check bool is logging active
 *
 *
 * @Return			true on active, false if not
 *********************************************************/
native bool ActiveLogging();


/*********************************************************
 * Set map fog
 *
 *
 * @noreturn
 *********************************************************/
native void FogOn();


/*********************************************************
 * Remove a map fog
 *
 *
 * @noreturn
 *********************************************************/
native void FogOff();


/*********************************************************
 * Set client Beacon
 *
 *
 * @noreturn
 *********************************************************/
native void BeaconOn(int client, float interval);


/*********************************************************
 * Remove client Beacon (auto remove on mapend/playerdeath/roundend)
 *
 *
 * @noreturn
 *********************************************************/
native void BeaconOff(int client);