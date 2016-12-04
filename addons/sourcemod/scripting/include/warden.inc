#if defined _warden_included
  #endinput
#endif
#define _warden_included


public SharedPlugin:__pl_warden =
{
	name = "warden", 
	file = "warden.smx", 
	#if defined REQUIRE_PLUGIN
	required = 1, 
	#else
	required = 0, 
	#endif
};


#if !defined REQUIRE_PLUGIN
public __pl_warden_SetNTVOptional()
{
	MarkNativeAsOptional("warden_exist");
	MarkNativeAsOptional("warden_iswarden");
	MarkNativeAsOptional("warden_set");
	MarkNativeAsOptional("warden_remove");
	MarkNativeAsOptional("warden_get");
	MarkNativeAsOptional("warden_getlast");
	
	MarkNativeAsOptional("warden_deputy_exist");
	MarkNativeAsOptional("warden_deputy_isdeputy");
	MarkNativeAsOptional("warden_deputy_set");
	MarkNativeAsOptional("warden_deputy_remove");
	MarkNativeAsOptional("warden_deputy_get");
	MarkNativeAsOptional("warden_deputy_getlast");
	
	MarkNativeAsOptional("warden_handcuffs_givepaperclip");
	MarkNativeAsOptional("warden_handcuffs_iscuffed");
	
	MarkNativeAsOptional("warden_freeday_set");
	MarkNativeAsOptional("warden_freeday_has");
}
#endif



/*********************************************************
 * Called when a new warden was created
 * By player, admin, randomchoose...
 *
 * @param client		The client who was warden
 * @NoReturn
 *********************************************************/
forward void warden_OnWardenCreated(int client);


/*********************************************************
 * Called when a client become new warden
 *
 * @param client		The client who was warden
 * @NoReturn
 *********************************************************/
forward void warden_OnWardenCreatedByUser(int client);


/*********************************************************
 * Called when a admin set a new warden
 *
 * @param client		The client who was warden
 * @NoReturn
 *********************************************************/
forward void warden_OnWardenCreatedByAdmin(int client);


/*********************************************************
 * Called everytime the warden position become free.
 * On wardens dead, disconnect, removed...
 * 
 * @param client		The client who was warden
 * @NoReturn
 *********************************************************/
forward void warden_OnWardenRemoved(int client);


/*********************************************************
 * Called when a the warden was removed by an admin
 *
 * @param client		The client who was warden
 * @NoReturn
 *********************************************************/
forward void warden_OnWardenRemovedByAdmin(int client);


/*********************************************************
 * Called when a the warden retire hisself
 *
 * @param client		The client who was warden
 * @NoReturn
 *********************************************************/
forward void warden_OnWardenRemovedBySelf(int client);


/*********************************************************
 * Called when a the warden disconnect
 *
 * @param client		The client who disconnected
 * @NoReturn
 *********************************************************/
forward void warden_OnWardenDisconnected(int client);


/*********************************************************
 * Called when a the warden dies
 *
 * @param client		The client who was warden
 * @NoReturn
 *********************************************************/
forward void warden_OnWardenDeath(int client);




/*********************************************************
 * Checks if any warden exist
 *
 *
 * @true on match , false if not
 *********************************************************/
native warden_exist();


/*********************************************************
 * returns if client is warden
 *
 * @param client		The client to run the check on
 * @true on match, false if not
 *********************************************************/
native warden_iswarden(int client);


/*********************************************************
 * Set a client as warden
 *
 * @param client		The client to set as warden
 * @NoReturn
 *********************************************************/
native warden_set(int client);


/*********************************************************
 * Removes the current warden if he exists
 *
 * @param client		The warden client to remove
 * @NoReturn
 *********************************************************/
native warden_remove(int client);


/*********************************************************
 * get the current warden if he exists
 *
 *
 * @Return				Client Index of warden
 *********************************************************/
native warden_get();


/*********************************************************
 * get the last warden if he exist
 *
 *
 * @Return				Client Index of last warden
 *********************************************************/
native warden_getlast();



/*********************************************************
 * Checks if any Deputy exist
 *
 *
 * @true on match , false if not
 *********************************************************/
native warden_deputy_exist();


/*********************************************************
 * returns if client is Deputy
 *
 * @param client		The client to run the check on
 * @true on match, false if not
 *********************************************************/
native warden_deputy_isdeputy(int client);


/*********************************************************
 * Set a client as Deputy
 *
 * @param client		The client to set as Deputy
 * @NoReturn
 *********************************************************/
native warden_deputy_set(int client);


/*********************************************************
 * Removes the current Deputy if he exists
 *
 * @param client		The Deputy client to remove
 * @NoReturn
 *********************************************************/
native warden_deputy_remove(int client);


/*********************************************************
 * get the current Deputy if he exists
 *
 *
 * @Return				Client index of deputy
 *********************************************************/
native warden_deputy_get();


/*********************************************************
 * get the last deputy if he exists
 *
 *
 * @Return				Client Index of last deputy
 *********************************************************/
native warden_deputy_getlast();




/*********************************************************
 * Give a client a amount of paperclips
 *
 * @param client		The client to give the paperclips
 * @param amount		The amount of paperclips
 * @NoReturn
 *********************************************************/
native warden_handcuffs_givepaperclip(int client, int amount);


/*********************************************************
 * returns if client is in handcuffs
 *
 * @param client		The client to run the check on
 * @true on match, false if not
 *********************************************************/
native warden_handcuffs_iscuffed(int client);




/*********************************************************
 * Set the client get a freeday
 *
 * @param client		The client to run the check on
 * @no return
 *********************************************************/
native warden_freeday_set(int client);


/*********************************************************
 * returns if client has a freeday now
 *
 * @param client		The client to run the check on
 * @true on match, false if not
 *********************************************************/
native warden_freeday_has(int client);