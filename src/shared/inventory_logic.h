
#define INVENTORY_SLOT_COUNT 5

//TODO - Define in some buy menu config file later?
#define WEAPONOPT_SILENCER_COST 900i
#define WEAPONOPT_LASERSIGHT_COST 800i
#define WEAPONOPT_FLASHLIGHT_COST 500i
#define WEAPONOPT_SCOPE_COST 1500i


#define PLAYER_INVENTORY_GENERIC pl.ary_myWeapons
#define PLAYER_INVENTORY_GENERIC_MAX pl.ary_myWeapons_softMax
//The server has the player's physical money for use anytime.
//Can make changes to it as needed. Just use the usual "ifdef SERVER" check first.
//...actually, we're using CHANGE_PLAYER_MONEY instead. It includes instructions for changing the player's own memory of total amount
//spent (useless for the server?), and actually changes the money count.
#define PLAYER_MONEY pl.money


#define PLAYER_TOTALCOST pl.iTotalPrice
#define PLAYER_TOTALSLOTS pl.iTotalSlots

//For the server, changes the player's total amount spent and actual money left.
#define CHANGE_PLAYER_MONEY(arg_delta) pl.iTotalPrice += arg_delta;\
									   pl.money -= arg_delta;
									   
#define CHANGE_PLAYER_SLOTS(arg_delta) pl.iTotalSlots += arg_delta;


#define PLAYER_AMMO pl.ary_ammoTotal
#define SET_PLAYER_AMMO(arg_ammoIndex, arg_quantity) pl.ary_ammoTotal[arg_ammoIndex] = arg_quantity;



#ifdef CLIENT
	// has the player purchased anything? Used to tell whether to print "order canceled" on exiting.
	var BOOL boughtAnything;
	
// These mirror the macros from earlier, but are for methods dealing with the local player config instead.

	#define CONFIG_PLAYER_INVENTORY_GENERIC pSeatLocal->m_clientinfo.weaponconfig_temp.ary_myWeapons
	#define CONFIG_PLAYER_INVENTORY_GENERIC_MAX pSeatLocal->m_clientinfo.weaponconfig_temp.ary_myWeapons_softMax
	//The client wants to fetch how much money the player has from the server,
	//and can only set the amount of money in the temp config.
	//WARNING - for the client this is read-only. But still, use "CHANGE_PLAYER_MONEY" to affect the temp config's price at least.
	#define CONFIG_PLAYER_MONEY getstati(STAT_MONEY)
	//Don't have to get how many slots the player (in particular) has available - this is dictated by the rules and never changes from that. So just fetch that.
	
	#define CONFIG_PLAYER_TOTALCOST pSeatLocal->m_clientinfo.weaponconfig_temp.iTotalPrice
	#define CONFIG_PLAYER_TOTALSLOTS pSeatLocal->m_clientinfo.weaponconfig_temp.iTotalSlots
	
	//For the client, this method only changes the temp config's price.
	#define CONFIG_CHANGE_PLAYER_MONEY(arg_delta) pSeatLocal->m_clientinfo.weaponconfig_temp.iTotalPrice += arg_delta;
	
	#define CONFIG_CHANGE_PLAYER_SLOTS(arg_delta) pSeatLocal->m_clientinfo.weaponconfig_temp.iTotalSlots += arg_delta;
	
	
	#define CONFIG_PLAYER_AMMO pSeatLocal->m_clientinfo.weaponconfig_temp.ary_ammoTotal
	#define CONFIG_SET_PLAYER_AMMO(arg_ammoIndex, arg_quantity) pSeatLocal->m_clientinfo.weaponconfig_temp.ary_ammoTotal[arg_ammoIndex] = arg_quantity;
	
	#define RULE_SLOTS_ALLOWED getstati(STAT_RULE_MAXWEIGHTSLOTS)
	#define RULE_MONEY_ALLOWED getstati(STAT_RULE_MONEYALLOWED)
	
#else

	#define RULE_SLOTS_ALLOWED iRule_MaxWeightSlots
	#define RULE_MONEY_ALLOWED bRule_MoneyAllowed
	
#endif	



#ifdef CLIENT
BOOL canBuyWeapon(int arg_weaponID, int arg_extraPrice, int arg_extraSlots, int iPurchaseCount);
int fullLoadCountToBuy(int arg_weaponID);
int determineThrowableBuyCount(int arg_weaponID, int arg_iSlotsAvailable, int arg_iMoneyAvailable);
int findWeaponInConfig(int arg_searchWeaponID);
BOOL CON_anyWeaponUsingAmmoType(int arg_ammoType, int arg_excludedWeaponID);
#endif

int findWeaponInInventory(player pl, int arg_searchWeaponID);
BOOL INV_anyWeaponUsingAmmoType(player pl, int arg_ammoType, int arg_excludedWeaponID);


#ifdef CLIENT
void swapConfigElements(int arg_index1, int arg_index2);
void removeWeaponFromConfig(int arg_removeIndex);
BOOL attemptAddWeaponToConfig(int arg_weaponID, int arg_iBitsUpgrade, int iCount);
#endif
void swapInventoryElements(player pl, int arg_index1, int arg_index2);

void removeWeaponFromInventory(player pl, int arg_removeIndex);

#ifdef SERVER
BOOL attemptBuyWeapon(player pl, int arg_weaponID, int arg_iBitsUpgrade, int iCount);
#endif 

#ifdef SERVER
int addWeaponToInventory(player pl, CTSWorldGun arg_pickupRef);
#endif

#ifdef CLIENT
void deployConfig(void);
#endif
