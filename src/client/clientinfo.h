
// NEW FILE
// Handles things that need to be persistent, or at least accessible, through
// the spectator and player - class changes.
// In English please?
// Available whether the player is in Spectator mode or ingame
// (collision, interacting seen by other players, etc.)
// WARNING: included before the gamemod's client defs.h file.  Beware if anything
// important is missing from here (context) because of that.


typedef struct ClientInfo_s{
	
	// Anyways, this object will store data related to weapon purchases temporarily
	// (tempConfig).
	// When a purchase is finallized, tempConfig will replace currentConfig
	// (copy it over).
	// But if "cancel" is used from the 1st layer of shop buttons after purchases
	// (edits to tempConfig), it is all scrapped. tempConfig will be restored to
	// currentCofig instead.
	// currentConfig will be used to build the player's inventory at spawn.
	weaponconfig_data_t weaponconfig_current;
	weaponconfig_data_t weaponconfig_temp;
	
	//TAGGG - CRITICAL!
	// At some point, it may be wise to store these too, remove from the player class
	// after enabling here.
	// Also the flMoney var here is just "money" in player, for removal.
	// And this will probably mean replacing 'clientstat(... STAT_MONEY)' with something
	// that sends a message to the connected client (SVC_CGAMEPACKET) anytime a
	// persistent money value (a serverside clientdata?) is changed.  This avoids
	// saving to the player/spectator entity, which may be odd memory to use when both
	// player and spectator need to refer to how much money the 'client' has, despite
	// being different entities.
	// Or maybe it all still works somehow with 0 side-effects.
	// -----------------------------------------------------------
	/*
	// How much money does this player/spectator have?  Can't spend more than this.
	// A var for slots would be needed if this varried between players, number of slots
	// used is for after having spawned (player-only) so it doesn't need to be here.
	float flMoney;
	
	// Provided for quick reference.  How many slots does the current loadout take?
	// There is a record of how much money has been spent, similar to config, but that
	// isn't too important.
	// The attached "money" (variable) is much more important (only pay attention to it
	// serverside, fetch it from clientside: getstati(...) or something.
	int iTotalSlots;
	int iTotalPrice;
	*/
	// -----------------------------------------------------------
	
	
} ClientInfo_t;


void ClientInfo_init(ClientInfo_t* arg_this);
