#if defined _eskojbwarden_included_
  #endinput
#endif
#define _eskojbwarden_included_

/**
 * Check if client is Warden
 *
 * @param client
 * @return        True if client is warden.
 */
native bool EJBW_IsClientWarden(int client);

/**
 * Check if warden exists
 *
 * @return        True if yes
 */
native bool EJBW_WardenExist();

/**
 * Check if warden exists
 *
 * @param client
 * @return        True if successfully
 */
native bool EJBW_SetWarden(int client);

/**
 * Check if warden exists
 *
 * @param client
 * @return        True if successfully
 */
native bool EJBW_RemoveWarden(int client);