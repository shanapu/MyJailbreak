/**
 * Check if a player playing in a dead game.
 *
 * @param client            client index
 * 
 * @return			        True or false.
 */
native bool DeadGames_IsOnGame(client);

/**
 * Check if a player playing in DM dead game.
 *
 * @param client            client index
 * 
 * @return			        True or false.
 */
native bool DeadGames_IsOnDM(client);

/**
 * Check if a player playing in BHOP dead game.
 *
 * @param client            client index
 * 
 * @return			        True or false.
 */
native bool DeadGames_IsOnBhop(client);