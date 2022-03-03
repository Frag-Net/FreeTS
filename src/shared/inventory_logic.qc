

// for dealing with config:
//	_playerRef.weaponconfig_temp.ary_myWeapons_softMax
//	_playerRef.weaponconfig_temp.ary_myWeapons
// for dealing with inventory:
//	_playerRef.ary_myWeapons_softMax
//	_playerRef.ary_myWeapons




#ifdef CLIENT

//Can I buy a weapon of this ID, and with this extra amount of money (can be 0), same for slots (akimbo + stacked throwables)?  Used as a convenient way to see if buying an upgrade tips the budget.
BOOL canBuyWeapon(int arg_weaponID, int arg_extraPrice, int arg_extraSlots, int iPurchaseCount){
	if(arg_weaponID == -1){
		//never mind then.
		return FALSE;
	}
	
	int moneyToExclude = 0;
	int slotsToExclude = 0;
	int indexInConfig = findWeaponInConfig(arg_weaponID);
	if(indexInConfig != -1){
		moneyToExclude = CONFIG_PLAYER_INVENTORY_GENERIC[indexInConfig].iPrice;
		slotsToExclude = CONFIG_PLAYER_INVENTORY_GENERIC[indexInConfig].iSlots;
		int ammoTypeIndex = getAmmoTypeOfWeapon(CONFIG_PLAYER_INVENTORY_GENERIC[indexInConfig].weaponID);
		if(ammoTypeIndex != -1){
			ammodata_t ammoRef = *ary_ammoData[ammoTypeIndex];
			moneyToExclude += ceil(CONFIG_PLAYER_AMMO[ammoTypeIndex] * ammoRef.fPricePerBullet );
		}
	}
	
	//weapondata_basic_t weaponRef = (*ary_weaponData[arg_weaponID]);
	weapondata_basic_t weaponRef = *( (weapondata_basic_t*) ary_weaponData[arg_weaponID]);
	
	if(weaponRef.typeID == WEAPONDATA_TYPEID_THROWABLE){
		// actually don't exclude anything in the consideration.
		// Buying adds 1 to what's already been purchased, need to know if we can't afford more!
		moneyToExclude = 0;
		slotsToExclude = 0;
		
		if(indexInConfig != -1){
			weapondata_throwable_t throwableRef = *( (weapondata_throwable_t*) ary_weaponData[arg_weaponID]);
			if(CONFIG_PLAYER_INVENTORY_GENERIC[indexInConfig].iCount + iPurchaseCount > throwableRef.iMaxCount){
				//if we're already at max capacity for this type, don't allow more.
				return FALSE;
			}
		}
	}
	
	
	int testPrice = (CONFIG_PLAYER_TOTALCOST + weaponRef.iPrice*iPurchaseCount + arg_extraPrice - moneyToExclude);
	int testSlots = (CONFIG_PLAYER_TOTALSLOTS + weaponRef.iSlots*iPurchaseCount + arg_extraSlots - slotsToExclude);
	
	if( (!RULE_MONEY_ALLOWED || (testPrice <= CONFIG_PLAYER_MONEY) ) && testSlots <= RULE_SLOTS_ALLOWED) {
		//it is allowed.
		//...wait. What about the type of ammo this weapon uses?  Add its price to the estimate for a full fill if not.
		//...nevermind, won't handle it with this simple check.  Will fill the ammo as much as possible until money runs out if that happens.
		return TRUE;
	}else{
		return FALSE;
	}
}//END OF canBuyWeapon


	
int fullLoadCountToBuy(int arg_weaponID){
	
	if(arg_weaponID == -1){
		return -1;
	}
	
	
	weapondata_basic_t* weaponPointer = ary_weaponData[arg_weaponID];
	weapondata_basic_t basicRef = *((weapondata_basic_t*) weaponPointer);
	
	int myWeaponTypeID = basicRef.typeID;
	
	
	if(myWeaponTypeID == WEAPONDATA_TYPEID_THROWABLE){
		int buyCount;
		weapondata_throwable_t throwableRef = *((weapondata_throwable_t*)weaponPointer);
		
		int indexInConfig = findWeaponInConfig(arg_weaponID);
		if(indexInConfig == -1){
			//buying up to the max (minus 1 to include this one already)
			buyCount = throwableRef.iMaxCount - 1;
		}else{
			//How many there already are is subtracted.
			buyCount = throwableRef.iMaxCount - CONFIG_PLAYER_INVENTORY_GENERIC[indexInConfig].iCount;
		}
		return buyCount;
	}
	return -1; //you fail.
}//END OF fullLoadCountToBuy



// Called when the full-load couldn't be afforded to see what number of throwables could
// be afforded.
int determineThrowableBuyCount(int arg_weaponID, int arg_iSlotsAvailable, int arg_iMoneyAvailable){
	
	weapondata_basic_t weaponRef = (*ary_weaponData[arg_weaponID]);
		
	weapondata_throwable_t throwableRef = (*((weapondata_throwable_t*)ary_weaponData[arg_weaponID]));
	//couldn't buy "buyCount" weapons?  Let's see what we can afford...
	int countAfforded_money;
	
	
	if(arg_iMoneyAvailable != -1){
		// trust it is a value that makes sense.
		countAfforded_money = arg_iMoneyAvailable / weaponRef.iPrice;
	}else{
		// -1?  Means, 'no money'.
		// we can afford anything in terms of money, money is exempt from this game by gamerules
		countAfforded_money = throwableRef.iMaxCount;
	}
	
	int countAfforded_slots = arg_iSlotsAvailable / weaponRef.iSlots;
	int countAfforded_possible = min(countAfforded_money, countAfforded_slots);
	
	int existingMatchingIndex = findWeaponInConfig(arg_weaponID);
	int existingCount = 0;
	if(existingMatchingIndex != -1){
		existingCount = CONFIG_PLAYER_INVENTORY_GENERIC[existingMatchingIndex].iCount;
	}
	
	// What we can afford must not go past the maximum carriable of this type.
	if(existingCount + countAfforded_possible > throwableRef.iMaxCount){
		countAfforded_possible = throwableRef.iMaxCount - existingCount;
	}
	return countAfforded_possible;
}


// Does this weapon exist in the player's temp config? Returns "-1" if not, otherwise which index contains it.
int findWeaponInConfig(int arg_searchWeaponID){
	for(int i = 0; i < CONFIG_PLAYER_INVENTORY_GENERIC_MAX; i++){
		if(CONFIG_PLAYER_INVENTORY_GENERIC[i].weaponID == arg_searchWeaponID){
			return i;
		}
	}
	return -1;
}//END OF findWeaponInConfig




BOOL CON_anyWeaponUsingAmmoType(int arg_ammoType, int arg_excludedWeaponID){
	
	for(int i = 0; i < CONFIG_PLAYER_INVENTORY_GENERIC_MAX; i++){
		//for each weapon we have, see if it uses the same ammo type as what we're about to delete.
		//A single one using that ammotype means the ammo pool stays.
		if(i == arg_excludedWeaponID){
			//no sense in allowing a weapon to be its own example of using this type of ammo. it's going to be deleted anyways.
			continue;
		}
		int otherWeaponTypeID = CONFIG_PLAYER_INVENTORY_GENERIC[i].weaponTypeID;
		if(otherWeaponTypeID == WEAPONDATA_TYPEID_GUN || otherWeaponTypeID == WEAPONDATA_TYPEID_IRONSIGHT){
			//in the clear. do the check.
			weapondata_basic_t* otherWeaponPointer = ary_weaponData[CONFIG_PLAYER_INVENTORY_GENERIC[i].weaponID];
			weapondata_gun_t* otherGunP = ((weapondata_gun_t*) otherWeaponPointer);
			if(otherGunP->iAmmoDataID == arg_ammoType){
				//valid match - still using this ammo pool. confirm and stop.
				//ammoStillUsed = TRUE;
				//break;
				return TRUE;
			}
		}
	}//END OF for loop through all other weapons
	
	//made it here? no weapon is using this type of ammo.
	return FALSE;
}//END OF CON_anyWeaponUsingAmmoType


#endif


// Does this weapon exist in the player's temp config? Returns "-1" if not, otherwise which index contains it.
int findWeaponInInventory(player pl, int arg_searchWeaponID){
	for(int i = 0; i < PLAYER_INVENTORY_GENERIC_MAX; i++){
		if(PLAYER_INVENTORY_GENERIC[i].weaponID == arg_searchWeaponID){
			return i;
		}
	}
	return -1;
}//END OF findWeaponInConfig



BOOL INV_anyWeaponUsingAmmoType(player pl, int arg_ammoType, int arg_excludedWeaponID){
	
	for(int i = 0; i < PLAYER_INVENTORY_GENERIC_MAX; i++){
		//for each weapon we have, see if it uses the same ammo type as what we're about to delete.
		//A single one using that ammotype means the ammo pool stays.
		if(i == arg_excludedWeaponID){
			//no sense in allowing a weapon to be its own example of using this type of ammo. it's going to be deleted anyways.
			continue;
		}
		int otherWeaponTypeID = PLAYER_INVENTORY_GENERIC[i].weaponTypeID;
		if(otherWeaponTypeID == WEAPONDATA_TYPEID_GUN || otherWeaponTypeID == WEAPONDATA_TYPEID_IRONSIGHT){
			//in the clear. do the check.
			weapondata_basic_t* otherWeaponPointer = ary_weaponData[PLAYER_INVENTORY_GENERIC[i].weaponID];
			weapondata_gun_t otherGunRef = *((weapondata_gun_t*) otherWeaponPointer);
			if(otherGunRef.iAmmoDataID == arg_ammoType){
				//valid match - still using this ammo pool. confirm and stop.
				//ammoStillUsed = TRUE;
				//break;
				return TRUE;
			}
		}
	}//END OF for loop through all other weapons
	
	//made it here? no weapon is using this type of ammo.
	return FALSE;
}//END OF INV_anyWeaponUsingAmmoType





#ifdef CLIENT


void swapConfigElements(int arg_index1, int arg_index2){
	
	if(arg_index1 == arg_index2){
		//swapping an element with itself... doesn't do anything.
		return;
	}
	
	int weaponID = CONFIG_PLAYER_INVENTORY_GENERIC[arg_index2].weaponID;
	int weaponTypeID = CONFIG_PLAYER_INVENTORY_GENERIC[arg_index2].weaponTypeID;
	int iBitsUpgrade = CONFIG_PLAYER_INVENTORY_GENERIC[arg_index2].iBitsUpgrade;
	int iCount = CONFIG_PLAYER_INVENTORY_GENERIC[arg_index2].iCount;
	int iPrice = CONFIG_PLAYER_INVENTORY_GENERIC[arg_index2].iPrice;
	int iSlots = CONFIG_PLAYER_INVENTORY_GENERIC[arg_index2].iSlots;
	
	CONFIG_PLAYER_INVENTORY_GENERIC[arg_index2].weaponID = CONFIG_PLAYER_INVENTORY_GENERIC[arg_index1].weaponID;
	CONFIG_PLAYER_INVENTORY_GENERIC[arg_index2].weaponTypeID = CONFIG_PLAYER_INVENTORY_GENERIC[arg_index1].weaponTypeID;
	CONFIG_PLAYER_INVENTORY_GENERIC[arg_index2].iBitsUpgrade = CONFIG_PLAYER_INVENTORY_GENERIC[arg_index1].iBitsUpgrade;
	CONFIG_PLAYER_INVENTORY_GENERIC[arg_index2].iCount = CONFIG_PLAYER_INVENTORY_GENERIC[arg_index1].iCount;
	CONFIG_PLAYER_INVENTORY_GENERIC[arg_index2].iPrice = CONFIG_PLAYER_INVENTORY_GENERIC[arg_index1].iPrice;
	CONFIG_PLAYER_INVENTORY_GENERIC[arg_index2].iSlots = CONFIG_PLAYER_INVENTORY_GENERIC[arg_index1].iSlots;
	
	CONFIG_PLAYER_INVENTORY_GENERIC[arg_index1].weaponID = weaponID;
	CONFIG_PLAYER_INVENTORY_GENERIC[arg_index1].weaponTypeID = weaponTypeID;
	CONFIG_PLAYER_INVENTORY_GENERIC[arg_index1].iBitsUpgrade = iBitsUpgrade;
	CONFIG_PLAYER_INVENTORY_GENERIC[arg_index1].iCount = iCount;
	CONFIG_PLAYER_INVENTORY_GENERIC[arg_index1].iPrice = iPrice;
	CONFIG_PLAYER_INVENTORY_GENERIC[arg_index1].iSlots = iSlots;
	
}//END OF swapConfigElements

#else


#endif




void swapInventoryElements(player pl, int arg_index1, int arg_index2){
	
	if(arg_index1 == arg_index2){
		//swapping an element with itself... doesn't do anything.
		return;
	}
	
	int weaponID = PLAYER_INVENTORY_GENERIC[arg_index2].weaponID;
	int weaponTypeID = PLAYER_INVENTORY_GENERIC[arg_index2].weaponTypeID;
	int iClipLeft = PLAYER_INVENTORY_GENERIC[arg_index2].iClipLeft;
	int iClipAkimboLeft = PLAYER_INVENTORY_GENERIC[arg_index2].iClipAkimboLeft;
	int iBitsUpgrade = PLAYER_INVENTORY_GENERIC[arg_index2].iBitsUpgrade;
	int iBitsUpgrade_on = PLAYER_INVENTORY_GENERIC[arg_index2].iBitsUpgrade_on;
	int iCount = PLAYER_INVENTORY_GENERIC[arg_index2].iCount;
	
	int iPrice = PLAYER_INVENTORY_GENERIC[arg_index2].iPrice;
	int iSlots = PLAYER_INVENTORY_GENERIC[arg_index2].iSlots;
	
	int iFireMode = PLAYER_INVENTORY_GENERIC[arg_index2].iFireMode;
	int iFireModeAkimbo = PLAYER_INVENTORY_GENERIC[arg_index2].iFireModeAkimbo;
	int iIronSight = PLAYER_INVENTORY_GENERIC[arg_index2].iIronSight;
	int iForceBodygroup1Submodel = PLAYER_INVENTORY_GENERIC[arg_index2].iForceBodygroup1Submodel;
	int bNeedsPump = PLAYER_INVENTORY_GENERIC[arg_index2].bNeedsPump;
	
	
	PLAYER_INVENTORY_GENERIC[arg_index2].weaponID = PLAYER_INVENTORY_GENERIC[arg_index1].weaponID;
	PLAYER_INVENTORY_GENERIC[arg_index2].weaponTypeID = PLAYER_INVENTORY_GENERIC[arg_index1].weaponTypeID;
	PLAYER_INVENTORY_GENERIC[arg_index2].iClipLeft = PLAYER_INVENTORY_GENERIC[arg_index1].iClipLeft;
	PLAYER_INVENTORY_GENERIC[arg_index2].iClipAkimboLeft = PLAYER_INVENTORY_GENERIC[arg_index1].iClipAkimboLeft;
	PLAYER_INVENTORY_GENERIC[arg_index2].iBitsUpgrade = PLAYER_INVENTORY_GENERIC[arg_index1].iBitsUpgrade;
	PLAYER_INVENTORY_GENERIC[arg_index2].iBitsUpgrade_on = PLAYER_INVENTORY_GENERIC[arg_index1].iBitsUpgrade_on;
	PLAYER_INVENTORY_GENERIC[arg_index2].iCount = PLAYER_INVENTORY_GENERIC[arg_index1].iCount;
	
	PLAYER_INVENTORY_GENERIC[arg_index2].iPrice = PLAYER_INVENTORY_GENERIC[arg_index1].iPrice;
	PLAYER_INVENTORY_GENERIC[arg_index2].iSlots = PLAYER_INVENTORY_GENERIC[arg_index1].iSlots;
	
	PLAYER_INVENTORY_GENERIC[arg_index2].iFireMode = PLAYER_INVENTORY_GENERIC[arg_index1].iFireMode;
	PLAYER_INVENTORY_GENERIC[arg_index2].iFireModeAkimbo = PLAYER_INVENTORY_GENERIC[arg_index1].iFireModeAkimbo;
	PLAYER_INVENTORY_GENERIC[arg_index2].iIronSight = PLAYER_INVENTORY_GENERIC[arg_index1].iIronSight;
	PLAYER_INVENTORY_GENERIC[arg_index2].iForceBodygroup1Submodel = PLAYER_INVENTORY_GENERIC[arg_index1].iForceBodygroup1Submodel;
	PLAYER_INVENTORY_GENERIC[arg_index2].bNeedsPump = PLAYER_INVENTORY_GENERIC[arg_index1].bNeedsPump;
	
	
	
	PLAYER_INVENTORY_GENERIC[arg_index1].weaponID = weaponID;
	PLAYER_INVENTORY_GENERIC[arg_index1].weaponTypeID = weaponTypeID;
	PLAYER_INVENTORY_GENERIC[arg_index1].iClipLeft = iClipLeft;
	PLAYER_INVENTORY_GENERIC[arg_index1].iClipAkimboLeft = iClipAkimboLeft;
	PLAYER_INVENTORY_GENERIC[arg_index1].iBitsUpgrade = iBitsUpgrade;
	PLAYER_INVENTORY_GENERIC[arg_index1].iBitsUpgrade_on = iBitsUpgrade_on;
	PLAYER_INVENTORY_GENERIC[arg_index1].iCount = iCount;
	
	PLAYER_INVENTORY_GENERIC[arg_index1].iPrice = iPrice;
	PLAYER_INVENTORY_GENERIC[arg_index1].iSlots = iSlots;
	
	PLAYER_INVENTORY_GENERIC[arg_index1].iFireMode = iFireMode;
	PLAYER_INVENTORY_GENERIC[arg_index1].iFireModeAkimbo = iFireModeAkimbo;
	PLAYER_INVENTORY_GENERIC[arg_index1].iIronSight = iIronSight;
	PLAYER_INVENTORY_GENERIC[arg_index1].iForceBodygroup1Submodel = iForceBodygroup1Submodel;
	PLAYER_INVENTORY_GENERIC[arg_index1].bNeedsPump = bNeedsPump;
	
	
}//END OF swapConfigElements








#ifdef CLIENT
//TAGGG - TODO, CRITICAL!!!
// Have another version, removeWeaponFromInventory, for ingame clientside usage too.
// This is for spectator managing the config when called clientside, but a lot of script is now
// more shared.
// Also, see what can be taken out of #ifdef SERVER/SERVER places to be shared.
// So much as the swapConfigElements may need a shared-version that's identical between client/server too!
// As of now, removeWeaponFromConfig does not have an effect for ingame clientside.  See weapon_combatknife,
// on throwing the last knife, look at printouts REMOVED, PRE / REMOVED, POST.
// This is why the 'draw' sound plays even if karate were removed from spawn, so that 'no' weapon is left to
// be picked: clientside *thinks* the knife is still there in that moment, no time for a server sendback that
// it isn't there yet.  Bound to be a bit funky looking with any sort of ping, knife deploys then disappears
// on getting a signal.
void removeWeaponFromConfig(int arg_removeIndex){
	
	if(arg_removeIndex >= CONFIG_PLAYER_INVENTORY_GENERIC_MAX){
		//how can this be?! can't match or surpass the current softMax.
		return;
	}
	
	weapondata_basic_t* weaponPointer = ary_weaponData[CONFIG_PLAYER_INVENTORY_GENERIC[arg_removeIndex].weaponID];
	weapondata_basic_t basicRef = *((weapondata_basic_t*) weaponPointer);
		
	int myWeaponTypeID = CONFIG_PLAYER_INVENTORY_GENERIC[arg_removeIndex].weaponTypeID;
	
	
//NOTICE - only the config does refunding.
//#ifdef CLIENT
	if(myWeaponTypeID == WEAPONDATA_TYPEID_GUN || myWeaponTypeID == WEAPONDATA_TYPEID_IRONSIGHT){
		//this weapon has ammo.
		//before we remove this, refund its cost. And see if any other weapons refer to the same ammo pool anymore
		//(if no weapons refer to the same ammo pool, that ammo gets removed from the config's ammo pool, and and cost amount also gets refunded).
		weapondata_gun_t gunRef = *((weapondata_gun_t*) weaponPointer);
		int ammoIndexToTest = gunRef.iAmmoDataID;
		BOOL ammoStillUsed = FALSE;  //prove me wrong!
		
		ammoStillUsed = CON_anyWeaponUsingAmmoType(ammoIndexToTest, arg_removeIndex);
		
		if(!ammoStillUsed){
			//remove/refund that ammo completely from this config.
			ammodata_t ammoRef = *ary_ammoData[ammoIndexToTest];
			int toRefund = ceil(CONFIG_PLAYER_AMMO[ammoIndexToTest] * ammoRef.fPricePerBullet);
			
			CONFIG_CHANGE_PLAYER_MONEY(-toRefund)
			
			CONFIG_SET_PLAYER_AMMO(ammoIndexToTest, 0)
		}
		
	}else if(myWeaponTypeID == WEAPONDATA_TYPEID_THROWABLE){
		//this weapon is stackable (1, 2, 3, 4...).
		//Refund all of it purchased too.
		//...actually the weapon's total cost is already considered in that, nevermind, nothing special.
	}

	// Refund the deleted weapon's price / slots.
	CONFIG_CHANGE_PLAYER_MONEY(-CONFIG_PLAYER_INVENTORY_GENERIC[arg_removeIndex].iPrice)
	CONFIG_CHANGE_PLAYER_SLOTS(-CONFIG_PLAYER_INVENTORY_GENERIC[arg_removeIndex].iSlots)
	
//#endif
	
	
	for(int i = arg_removeIndex; i < CONFIG_PLAYER_INVENTORY_GENERIC_MAX-1; i++){
		//swap em' backwards.
		swapConfigElements(i, i+1);
	}
	
	
	//reduced.
	CONFIG_PLAYER_INVENTORY_GENERIC_MAX--;
	
}//END OF removeWeaponFromConfig
#endif








// For ingame use!
void removeWeaponFromInventory(player pl, int arg_removeIndex){
	
	if(arg_removeIndex >= PLAYER_INVENTORY_GENERIC_MAX){
		//how can this be?! can't match or surpass the current softMax.
		return;
	}
	
	weapondata_basic_t* weaponPointer = ary_weaponData[PLAYER_INVENTORY_GENERIC[arg_removeIndex].weaponID];
	weapondata_basic_t basicRef = *((weapondata_basic_t*) weaponPointer);
		
	int myWeaponTypeID = PLAYER_INVENTORY_GENERIC[arg_removeIndex].weaponTypeID;
	
	for(int i = arg_removeIndex; i < PLAYER_INVENTORY_GENERIC_MAX-1; i++){
		//swap em' backwards.
		swapInventoryElements(pl, i, i+1);
	}
	
	// NOTE!  No need to think about shifting the player's inventoryEquippedIndex,
	// if this were called on the currently equipped weapon, the method for picking
	// the best weapon starting from nothing is already done.
	// The only other case, clearing all weapons on death, does not need to worry
	// about inventoryEquippedIndex either.
	
	//reduced.
	PLAYER_INVENTORY_GENERIC_MAX--;
	
	pl.completeInventorySend = TRUE;
}//removeWeaponFromInventory






//TAGGG - CRITICAL.
// FOR taking a buy order from the client!
// Redo "attemptAddWeaponToConfig" this with that!!!
//     attemptBuyWeapon !!!
// DITTO!!!  this one is done maybe?  I forget
//removeWeaponFromConfig
//removeWeaponFromInventory

// !!! ORIGINAL!  Organize better later, lots of duplicated script from cloning this for
// the config-only version and shared one for inventory (attemptBuyWeapon)
/*
// TODO... eh. - melee throwables and player accessories (stealth shoes, kevlar... INSTANT's in buy opts?)
// don't alter their position in the buy order (pl.weaponconfig_temp.ary_myWeapons) when bought twice in a row,
// particularly for melee throwable's buying another (since they stack for a count).  Why?  truly unknown.
// Is this worth mimicking in particular?  Also probably not.
// ALSO - we're gonna do some lazy re-use here.  This method will add a weapon to the temp config clientside,
// but it will add a weapon to the player's inventory serverside.
// Easy way to think of it:  clientside, this handles the config, and doesn't actually buy anything yet.
// Use the config's money to keep track of how much the player would have left given the cost of the order yet.
// Serverside, we assume this is the player spawning and requesting something from their config already.
// Use their real money.
BOOL attemptAddWeaponToConfig(player pl, int arg_weaponID, int arg_iBitsUpgrade, int iCount){
	
	
	// IGNORE WARNINGS ABOUT ME!  Only used if the weapon type ID suggests this is a gun or ironsight - type.
	weapondata_gun_t gunRef;
	
	weapondata_throwable_t throwableRef;
	int existingMatchingIndex = -1;  //not found until proven otherwise.
	ammodata_t ammoRef;
	
	if(arg_weaponID == -1){
		return FALSE;
	}
	
	existingMatchingIndex = findWeaponInConfig(pl, arg_weaponID);
	
	if(existingMatchingIndex == -1 && PLAYER_INVENTORY_GENERIC_MAX >= ary_myWeapons_length){
		// If this weapon is going to be a completely new addition and we don't have a dynamic weapon
		// info element available
		// to represent it, we can't move on.
		return FALSE;
	}
	
	int newPrice = 0;
	int oldPrice = 0;  //price of the existing weapon, if it exists. Can buy the same weapon to change its upgrades.
	int newSlots = 0;
	int oldSlots = 0;
	// this assignment should not be needed.  Stops a warning.
	int ammoType = 0;
	//How much will it cost to buy the new weapon/upgrades?  Does not consider if the
	//weapon was already purchased with different upgrades.
	weapondata_basic_t* weaponPointer = ary_weaponData[arg_weaponID];
	weapondata_basic_t basicRef = *((weapondata_basic_t*) weaponPointer);
	
	int myWeaponTypeID = basicRef.typeID;
	
	//In case the user hacks the client to suggest upgrades a weapon does not actually support,
	//force options not allowed by the weapon's info to be stripped away.
	int iBitsUpgradeSafe = (arg_iBitsUpgrade & basicRef.iBitsUpgrade);
	
	//count each upgrade.
//Silencer: 900
//Lasersight: 800
//Flashlight: 500
//Scope: 1500
//Buy Akimbo: 2 times buy price (does not double upgrade other costs)
//Full Load: X times the buy price, where "X" is max capacity (throwing knives or other stackables if supported)

	
	
	//NOTE - any forced options, including akimbo, don't influence the buy price. Forced options are free and come
	//	   with the weapon. That is, iBitsUpgradeAuto in this case.
	//But any buyOpts not automatic that have been purchased do affect the buy price.
	//And in the case of akimbo, manually buying akimbo raises the iCount of the dynamic weapon info to 2 to
	//show it was upgraded into akimbo (auto-akimbo weapons are still treated as "1" weapon for dropping;
	//singular does not exist).
	//Prices are hardcoded for now.
	//TODO - upgrade prices can come from a shop config file maybe?
	
	
	//int newCount = 1;  //assumption.
	//...actually the user may give us a specific count in the case of throwables
	// in case 
	int newCount = iCount;
	
	//Forbidding anything in iBitsUpgradeAuto just since this is what to charge money for.
	//Anything in auto will be applied at the end free of charge, the user need not request it.
	int manualBuyOpts = (~basicRef.iBitsUpgradeAuto) & iBitsUpgradeSafe;
	if(manualBuyOpts & BITS_WEAPONOPT_SILENCER){
		newPrice += WEAPONOPT_SILENCER_COST;
	}
	if(manualBuyOpts & BITS_WEAPONOPT_LASERSIGHT){
		newPrice += WEAPONOPT_LASERSIGHT_COST;
	}
	if(manualBuyOpts & BITS_WEAPONOPT_FLASHLIGHT){
		newPrice += WEAPONOPT_FLASHLIGHT_COST;
	}
	if(manualBuyOpts & BITS_WEAPONOPT_SCOPE){
		newPrice += WEAPONOPT_SCOPE_COST;
	}
	if(manualBuyOpts & BITS_WEAPONOPT_AKIMBO){
		newCount = 2;  //price adjustment will follow below.
	}
	
	//This buyOpt is only allowed for throwables for now.
	//TODO - support buying up to the max countables allowed if we go over the price / slot limit at full?
	//	   might not be worth it.
	if(myWeaponTypeID == WEAPONDATA_TYPEID_THROWABLE){
		
		throwableRef = *((weapondata_throwable_t*) weaponPointer);
		
		if(manualBuyOpts & BITS_WEAPONOPT_FULLLOAD){
			//remember, this is as though the weapon has never been purchased before yet, so this is maxCount times base price.
			//(not that throwables really have upgrades anyways).
			//And "iMaxCount - 1" because we already spent the buy price once. For a max of 5 knives, actually add 4 times the cost.
#ifdef CLIENT
			//This is only necessary clientside (config), because serverside
			//we received the count already from having picked FULLLOAD.
			newCount = throwableRef.iMaxCount;
#endif
		}else if(existingMatchingIndex != -1){
			//could also be buying another to stack on top of the existing by 1. See if we can.
			int newCountTest = PLAYER_INVENTORY_GENERIC[existingMatchingIndex].iCount + 1;
			if(newCountTest <= throwableRef.iMaxCount){
				//allowed.
				newCount = newCountTest;
			}else{
				//keep it to the same as before.
				newCount = PLAYER_INVENTORY_GENERIC[existingMatchingIndex].iCount;
			}
		}
	}
	
	//Be it a single weapon or akimbo guns or stacked throwables, the logic for altering iPrice / islots is the same.
	newPrice += (newCount) * basicRef.iPrice;
	newSlots += (newCount) * basicRef.iSlots;

	
	if(existingMatchingIndex != -1){
		//remove that weapon first.
		//...usually. There are some exceptions (or just one?)
		oldPrice = PLAYER_INVENTORY_GENERIC[existingMatchingIndex].iPrice;
		oldSlots = PLAYER_INVENTORY_GENERIC[existingMatchingIndex].iSlots;
	}
	
	//If this is the 2nd time buying the weapon, subtract out its old price too see if we can still afford it with
	//the change brought about by more expensive upgrades.  Or maybe that isn't even the case.
	int finalPrice = newPrice - oldPrice;
	int finalSlots = newSlots - oldSlots;
	
	//BOOL queueAmmoFill = FALSE;
	int bulletsToBuy = 0;
	int existingAmmoCost = 0;   //what is the value of the ammo the player already has?
	//Another check for guns only. Is this weapon the first to use a type of ammo?
	
	if(myWeaponTypeID == WEAPONDATA_TYPEID_GUN || myWeaponTypeID == WEAPONDATA_TYPEID_IRONSIGHT){
		
		//And if this weapon's ammo type hasn't been filled by another weapon purchased before, do so (and add its cost).
		//(gun & ironsight only)
		gunRef = *((weapondata_gun_t*) weaponPointer);
		ammoType = gunRef.iAmmoDataID;
		ammoRef = *ary_ammoData[ammoType];
	
		//do the ammo purchase. at least, a hypothetical:
		
		//Regardless of money allowed or not, we're still keeping track of the value.
		existingAmmoCost = ceil(PLAYER_AMMO[ammoType] * ammoRef.fPricePerBullet);
	
		if(RULE_MONEY_ALLOWED){
			//how much of the player's money is left after the current estimated cost (and existing config cost)?
			//And remove the existingAmmoCost.  There are rounding issues if we keep that in and try to buy bullets on top of it toward the max.
			//This way, just pretend like we're starting at 0 bullets and buying toward the max.
			
			
			// !!! Different between versions
#ifdef CLIENT
//client needs to consider the total left
			int remainingPlayerMoney = PLAYER_MONEY - (PLAYER_TOTALCOST + finalPrice) + existingAmmoCost;
#else
//
			int remainingPlayerMoney = PLAYER_MONEY - (finalPrice) + existingAmmoCost;
#endif
			////////////////////////////////////////////////////////////////////////

			if(remainingPlayerMoney > 0){
				//hopefully it is above 0 or this weapon is flat-out unpurchasable anyways.
				//Divide the remainingPlayerMoney by the cost of a bullet (round it down... can't go over)
				float f_remainingPlayerMoney = (float)remainingPlayerMoney;
				int bulletsAfforded = floor(f_remainingPlayerMoney / ammoRef.fPricePerBullet);
				if(bulletsAfforded > ammoRef.iMax){
					//Even if we could afford more, we can't buy any more than the max allowed.
					bulletsToBuy = ammoRef.iMax;
				}else{
					bulletsToBuy = bulletsAfforded;
				}
			}
		}else{
			//no money?  ammo doesn't cost slots so that's all. Just fill the ammo to max.
			bulletsToBuy = ammoRef.iMax;
		}
	
	}//END OF gun OR ironsight weapon type checks
	
	
#ifdef CLIENT
	//totalCost only for client - for the server, we're only concerned with how much the player physically has left
	if( !RULE_MONEY_ALLOWED || (PLAYER_TOTALCOST + finalPrice - existingAmmoCost <= PLAYER_MONEY) ){
#else
	if( !RULE_MONEY_ALLOWED || (finalPrice - existingAmmoCost <= PLAYER_MONEY) ){
#endif
		//If this still falls under our budget, we may proceed.
	}else{
		//Puts us overbudget? No changes allowed!
		return FALSE;
	}
	
	//2nd check for slots, same as above.
	if(PLAYER_TOTALSLOTS + finalSlots <= RULE_SLOTS_ALLOWED){
		//valid.
	}else{
		return FALSE;
	}
	
	if(bulletsToBuy > 0){
		//Give the bullets.
		ammoRef = *ary_ammoData[ammoType];
		
		//PLAYER_AMMO[ammoType] = bulletsToBuy;
		SET_PLAYER_AMMO(ammoType, bulletsToBuy)
		//and remove the existing ammo cost.
		float f_bulletsToBuy = (float)bulletsToBuy;
		CHANGE_PLAYER_MONEY(-existingAmmoCost + ceil(f_bulletsToBuy * ammoRef.fPricePerBullet))
	}
	
	
	int finalWeaponIndex = 0;
	int matchStart;
	
	if(existingMatchingIndex != -1){
		matchStart = existingMatchingIndex;
	}else{
		matchStart = PLAYER_INVENTORY_GENERIC_MAX;
	}//END OF existingMatchingIndex check
	
	
#ifdef CLIENT
	//finalWeaponIndex ?
	PLAYER_INVENTORY_GENERIC[matchStart].weaponID = arg_weaponID;
	PLAYER_INVENTORY_GENERIC[matchStart].weaponTypeID = basicRef.typeID;
	PLAYER_INVENTORY_GENERIC[matchStart].iBitsUpgrade = iBitsUpgradeSafe | basicRef.iBitsUpgradeAuto;
	PLAYER_INVENTORY_GENERIC[matchStart].iCount = newCount;
	PLAYER_INVENTORY_GENERIC[matchStart].iPrice = newPrice;
	PLAYER_INVENTORY_GENERIC[matchStart].iSlots = newSlots;
	//and adjust this config's total price.
	

	//made it this far? looks like we bought something.
	boughtAnything = TRUE;
	
#else

	PLAYER_INVENTORY_GENERIC[matchStart].weaponID = arg_weaponID;
	PLAYER_INVENTORY_GENERIC[matchStart].weaponTypeID = basicRef.typeID;
	
	if(myWeaponTypeID == WEAPONDATA_TYPEID_GUN || myWeaponTypeID == WEAPONDATA_TYPEID_IRONSIGHT){
		PLAYER_INVENTORY_GENERIC[matchStart].iClipLeft = gunRef.iClipMax;
		
		//If our weapon supports akimbo, and we actually have it this time...
		if((basicRef.iBitsUpgrade & BITS_WEAPONOPT_AKIMBO) && (iBitsUpgradeSafe & BITS_WEAPONOPT_AKIMBO) ){
			//you'll be needing this then.
			PLAYER_INVENTORY_GENERIC[matchStart].iClipAkimboLeft = gunRef.iClipMax;
		}
		else{
			//nothing
			PLAYER_INVENTORY_GENERIC[matchStart].iClipAkimboLeft = 0;
		}
		
	}//END OF gun check
	else{
		//not a gun? doesn't use either of these.
		PLAYER_INVENTORY_GENERIC[matchStart].iClipLeft = 0;
		PLAYER_INVENTORY_GENERIC[matchStart].iClipAkimboLeft = 0;
	}
	
	//BITMASK_WEAPONOPT_TOGGLEABLE BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_FLASHLIGHT
	//Include 
	PLAYER_INVENTORY_GENERIC[matchStart].iBitsUpgrade = iBitsUpgradeSafe | basicRef.iBitsUpgradeAuto;
	PLAYER_INVENTORY_GENERIC[matchStart].iBitsUpgrade_on = (iBitsUpgradeSafe | basicRef.iBitsUpgradeAuto) & (BITMASK_WEAPONOPT_TOGGLEABLE);
	PLAYER_INVENTORY_GENERIC[matchStart].iCount = newCount;
	
	
	printfline("attemptAddWeaponToConfig - newCount: %i", newCount);
	
	
	PLAYER_INVENTORY_GENERIC[matchStart].iPrice = newPrice;
	PLAYER_INVENTORY_GENERIC[matchStart].iSlots = newSlots;
	
	
	if(myWeaponTypeID == WEAPONDATA_TYPEID_GUN || myWeaponTypeID == WEAPONDATA_TYPEID_IRONSIGHT){
		
		if(gunRef.iBitDefaultFireMode != 0){
			//well that was easy.
			
			if(!(iBitsUpgradeSafe & BITS_WEAPONOPT_AKIMBO)){
				//well that was easy.
				PLAYER_INVENTORY_GENERIC[matchStart].iFireMode = gunRef.iBitDefaultFireMode;
			}else{
				
				if(gunRef.iAkimboID > 0 && gunRef.iAkimboID < WEAPON_AKIMBO_UPGRADE_ID::LAST_ID ){
					
					//set this too.  and iFireModeAkimbo.
					PLAYER_INVENTORY_GENERIC[matchStart].iFireMode = gunRef.iBitDefaultFireMode;
					
					//Get the akimbo information then
					weapondata_gun_t* basicAkimboGunPointer = (weapondata_gun_t*) ary_akimboUpgradeData[gunRef.iAkimboID];
					weapondata_gun_t basicAkimboGunRef = *(basicAkimboGunPointer);
					
					PLAYER_INVENTORY_GENERIC[matchStart].iFireModeAkimbo = basicAkimboGunRef.iBitDefaultFireMode;
				}else{
					//No akimbo ref?  Then I am the akimbo ref.  But I'm using "iFireModeAkimbo".
					PLAYER_INVENTORY_GENERIC[matchStart].iFireModeAkimbo = gunRef.iBitDefaultFireMode;
				}
			
			}
			
		}else{
			// AAGH.  Just find the first provided firemode then.
			PLAYER_INVENTORY_GENERIC[matchStart].iFireMode = 0;
			PLAYER_INVENTORY_GENERIC[matchStart].iFireModeAkimbo = 0;
		}
		
	}else{
		//doesn't use the concept of "iFireMode".
		PLAYER_INVENTORY_GENERIC[matchStart].iFireMode = 0;
		PLAYER_INVENTORY_GENERIC[matchStart].iFireModeAkimbo = 0;
		
	}
	
	PLAYER_INVENTORY_GENERIC[matchStart].iIronSight = 0;  //default: no use / magnification.
	
	PLAYER_INVENTORY_GENERIC[matchStart].iForceBodygroup1Submodel = 0;
	PLAYER_INVENTORY_GENERIC[matchStart].bNeedsPump = FALSE;
	
	//PLAYER_INVENTORY_GENERIC[matchStart].iPrice = newPrice;
	//PLAYER_INVENTORY_GENERIC[matchStart].iSlots = newSlots;
	
	
	//TAGGG - CRITICAL NOTICE.
	// If we want some custom init for a weapon the moment it is created period
	// (in this case at the same time as buying), we could call it here.
	// For weapons spawned into a level, those would have to handle that call on their own though at spawn.
	// And know not to re-trigger that on being picked up by a player.
	
#endif

	
	CHANGE_PLAYER_MONEY(finalPrice)
	CHANGE_PLAYER_SLOTS(finalSlots)
	
	
	//TODO MAJOR - is this pass by value? extremely important.
	//TODO - check.  should throwables skip the reordering step?
	//	   That should change what "finalWeaponIndex" is. not always 0.
	//TAGGG - QUESTION. Why did I do this? Why should any added
	//weapon start at index 0 and not just stay at the end of the array?
	// No idea what I was thinking. oh well.
	
	//swapConfigElements(pl, 0, matchStart);
	//
	//for(int i = matchStart; i > 1; i++){
	//	//swap em' backwards.
	//	swapConfigElements(pl, i, i-1);
	//}
	
	
	if(existingMatchingIndex == -1){
		//no element was overwritten? we added a new one. up goes the count.
		PLAYER_INVENTORY_GENERIC_MAX++;
	}
	
	//printouts
	//for(int i = 0; i < PLAYER_INVENTORY_GENERIC_MAX; i++){
	//	printfline("WEAPON %i - %i", i, PLAYER_INVENTORY_GENERIC[i].weaponID);
	//}
	
	
	return TRUE;
}//END OF attemptAddWeaponToConfig
*/


#ifdef CLIENT
BOOL attemptAddWeaponToConfig(int arg_weaponID, int arg_iBitsUpgrade, int iCount){
	
	
	// IGNORE WARNINGS ABOUT ME!  Only used if the weapon type ID suggests this is a gun or ironsight - type.
	weapondata_gun_t gunRef;
	
	weapondata_throwable_t throwableRef;
	int existingMatchingIndex = -1;  //not found until proven otherwise.
	ammodata_t ammoRef;
	
	if(arg_weaponID == -1){
		return FALSE;
	}
	
	existingMatchingIndex = findWeaponInConfig(arg_weaponID);
	
	if(existingMatchingIndex == -1 && CONFIG_PLAYER_INVENTORY_GENERIC_MAX >= ary_myWeapons_length){
		// If this weapon is going to be a completely new addition and we don't have a dynamic weapon
		// info element available
		// to represent it, we can't move on.
		return FALSE;
	}
	
	int newPrice = 0;
	int oldPrice = 0;  //price of the existing weapon, if it exists. Can buy the same weapon to change its upgrades.
	int newSlots = 0;
	int oldSlots = 0;
	// this assignment should not be needed.  Stops a warning.
	int ammoType = 0;
	//How much will it cost to buy the new weapon/upgrades?  Does not consider if the
	//weapon was already purchased with different upgrades.
	weapondata_basic_t* weaponPointer = ary_weaponData[arg_weaponID];
	weapondata_basic_t basicRef = *((weapondata_basic_t*) weaponPointer);
	
	int myWeaponTypeID = basicRef.typeID;
	
	//In case the user hacks the client to suggest upgrades a weapon does not actually support,
	//force options not allowed by the weapon's info to be stripped away.
	int iBitsUpgradeSafe = (arg_iBitsUpgrade & basicRef.iBitsUpgrade);
	
	//count each upgrade.
//Silencer: 900
//Lasersight: 800
//Flashlight: 500
//Scope: 1500
//Buy Akimbo: 2 times buy price (does not double upgrade other costs)
//Full Load: X times the buy price, where "X" is max capacity (throwing knives or other stackables if supported)

	
	
	//NOTE - any forced options, including akimbo, don't influence the buy price. Forced options are free and come
	//	   with the weapon. That is, iBitsUpgradeAuto in this case.
	//But any buyOpts not automatic that have been purchased do affect the buy price.
	//And in the case of akimbo, manually buying akimbo raises the iCount of the dynamic weapon info to 2 to
	//show it was upgraded into akimbo (auto-akimbo weapons are still treated as "1" weapon for dropping;
	//singular does not exist).
	//Prices are hardcoded for now.
	//TODO - upgrade prices can come from a shop config file maybe?
	
	
	//int newCount = 1;  //assumption.
	//...actually the user may give us a specific count in the case of throwables
	// in case 
	int newCount = iCount;
	
	//Forbidding anything in iBitsUpgradeAuto just since this is what to charge money for.
	//Anything in auto will be applied at the end free of charge, the user need not request it.
	int manualBuyOpts = (~basicRef.iBitsUpgradeAuto) & iBitsUpgradeSafe;
	if(manualBuyOpts & BITS_WEAPONOPT_SILENCER){
		newPrice += WEAPONOPT_SILENCER_COST;
	}
	if(manualBuyOpts & BITS_WEAPONOPT_LASERSIGHT){
		newPrice += WEAPONOPT_LASERSIGHT_COST;
	}
	if(manualBuyOpts & BITS_WEAPONOPT_FLASHLIGHT){
		newPrice += WEAPONOPT_FLASHLIGHT_COST;
	}
	if(manualBuyOpts & BITS_WEAPONOPT_SCOPE){
		newPrice += WEAPONOPT_SCOPE_COST;
	}
	if(manualBuyOpts & BITS_WEAPONOPT_AKIMBO){
		newCount = 2;  //price adjustment will follow below.
	}
	
	//This buyOpt is only allowed for throwables for now.
	//TODO - support buying up to the max countables allowed if we go over the price / slot limit at full?
	//	   might not be worth it.
	if(myWeaponTypeID == WEAPONDATA_TYPEID_THROWABLE){
		
		throwableRef = *((weapondata_throwable_t*) weaponPointer);
		
		if(manualBuyOpts & BITS_WEAPONOPT_FULLLOAD){
			//remember, this is as though the weapon has never been purchased before yet, so this is maxCount times base price.
			//(not that throwables really have upgrades anyways).
			//And "iMaxCount - 1" because we already spent the buy price once. For a max of 5 knives, actually add 4 times the cost.
#ifdef CLIENT
			//This is only necessary clientside (config), because serverside
			//we received the count already from having picked FULLLOAD.
			newCount = throwableRef.iMaxCount;
#endif
		}else if(existingMatchingIndex != -1){
			//could also be buying another to stack on top of the existing by 1. See if we can.
			int newCountTest = CONFIG_PLAYER_INVENTORY_GENERIC[existingMatchingIndex].iCount + 1;
			if(newCountTest <= throwableRef.iMaxCount){
				//allowed.
				newCount = newCountTest;
			}else{
				//keep it to the same as before.
				newCount = CONFIG_PLAYER_INVENTORY_GENERIC[existingMatchingIndex].iCount;
			}
		}
	}
	
	//Be it a single weapon or akimbo guns or stacked throwables, the logic for altering iPrice / islots is the same.
	newPrice += (newCount) * basicRef.iPrice;
	newSlots += (newCount) * basicRef.iSlots;

	
	if(existingMatchingIndex != -1){
		//remove that weapon first.
		//...usually. There are some exceptions (or just one?)
		oldPrice = CONFIG_PLAYER_INVENTORY_GENERIC[existingMatchingIndex].iPrice;
		oldSlots = CONFIG_PLAYER_INVENTORY_GENERIC[existingMatchingIndex].iSlots;
	}
	
	//If this is the 2nd time buying the weapon, subtract out its old price too see if we can still afford it with
	//the change brought about by more expensive upgrades.  Or maybe that isn't even the case.
	int finalPrice = newPrice - oldPrice;
	int finalSlots = newSlots - oldSlots;
	
	//BOOL queueAmmoFill = FALSE;
	int bulletsToBuy = 0;
	int existingAmmoCost = 0;   //what is the value of the ammo the player already has?
	//Another check for guns only. Is this weapon the first to use a type of ammo?
	
	if(myWeaponTypeID == WEAPONDATA_TYPEID_GUN || myWeaponTypeID == WEAPONDATA_TYPEID_IRONSIGHT){
		
		//And if this weapon's ammo type hasn't been filled by another weapon purchased before, do so (and add its cost).
		//(gun & ironsight only)
		gunRef = *((weapondata_gun_t*) weaponPointer);
		ammoType = gunRef.iAmmoDataID;
		ammoRef = *ary_ammoData[ammoType];
	
		//do the ammo purchase. at least, a hypothetical:
		
		//Regardless of money allowed or not, we're still keeping track of the value.
		existingAmmoCost = ceil(CONFIG_PLAYER_AMMO[ammoType] * ammoRef.fPricePerBullet);
	
		if(RULE_MONEY_ALLOWED){
			//how much of the player's money is left after the current estimated cost (and existing config cost)?
			//And remove the existingAmmoCost.  There are rounding issues if we keep that in and try to buy bullets on top of it toward the max.
			//This way, just pretend like we're starting at 0 bullets and buying toward the max.
			
			
			// !!! Different between versions
			int remainingPlayerMoney = CONFIG_PLAYER_MONEY - (CONFIG_PLAYER_TOTALCOST + finalPrice) + existingAmmoCost;
			////////////////////////////////////////////////////////////////////////

			if(remainingPlayerMoney > 0){
				//hopefully it is above 0 or this weapon is flat-out unpurchasable anyways.
				//Divide the remainingPlayerMoney by the cost of a bullet (round it down... can't go over)
				float f_remainingPlayerMoney = (float)remainingPlayerMoney;
				int bulletsAfforded = floor(f_remainingPlayerMoney / ammoRef.fPricePerBullet);
				if(bulletsAfforded > ammoRef.iMax){
					//Even if we could afford more, we can't buy any more than the max allowed.
					bulletsToBuy = ammoRef.iMax;
				}else{
					bulletsToBuy = bulletsAfforded;
				}
			}
		}else{
			//no money?  ammo doesn't cost slots so that's all. Just fill the ammo to max.
			bulletsToBuy = ammoRef.iMax;
		}
	
	}//END OF gun OR ironsight weapon type checks
	
	
	// !!! Different between versions
	// totalCost only for client - for the server, we're only concerned with how much the player physically has left
	if( !RULE_MONEY_ALLOWED || (CONFIG_PLAYER_TOTALCOST + finalPrice - existingAmmoCost <= CONFIG_PLAYER_MONEY) ){
		//If this still falls under our budget, we may proceed.
	}else{
		//Puts us overbudget? No changes allowed!
		return FALSE;
	}
	
	//2nd check for slots, same as above.
	if(CONFIG_PLAYER_TOTALSLOTS + finalSlots <= RULE_SLOTS_ALLOWED){
		//valid.
	}else{
		return FALSE;
	}
	
	if(bulletsToBuy > 0){
		//Give the bullets.
		ammoRef = *ary_ammoData[ammoType];
		
		//CONFIG_PLAYER_AMMO[ammoType] = bulletsToBuy;
		CONFIG_SET_PLAYER_AMMO(ammoType, bulletsToBuy)
		//and remove the existing ammo cost.
		float f_bulletsToBuy = (float)bulletsToBuy;
		CONFIG_CHANGE_PLAYER_MONEY(-existingAmmoCost + ceil(f_bulletsToBuy * ammoRef.fPricePerBullet))
	}
	
	
	int finalWeaponIndex = 0;
	int matchStart;
	
	if(existingMatchingIndex != -1){
		matchStart = existingMatchingIndex;
	}else{
		matchStart = CONFIG_PLAYER_INVENTORY_GENERIC_MAX;
	}//END OF existingMatchingIndex check
	
	
	// !!! Different between versions
	///////////////////////////////////////////////////////////////////////
	//finalWeaponIndex ?
	CONFIG_PLAYER_INVENTORY_GENERIC[matchStart].weaponID = arg_weaponID;
	CONFIG_PLAYER_INVENTORY_GENERIC[matchStart].weaponTypeID = basicRef.typeID;
	CONFIG_PLAYER_INVENTORY_GENERIC[matchStart].iBitsUpgrade = iBitsUpgradeSafe | basicRef.iBitsUpgradeAuto;
	CONFIG_PLAYER_INVENTORY_GENERIC[matchStart].iCount = newCount;
	CONFIG_PLAYER_INVENTORY_GENERIC[matchStart].iPrice = newPrice;
	CONFIG_PLAYER_INVENTORY_GENERIC[matchStart].iSlots = newSlots;
	//and adjust this config's total price.
	

	//made it this far? looks like we bought something.
	boughtAnything = TRUE;
	///////////////////////////////////////////////////////////////////////

	
	CONFIG_CHANGE_PLAYER_MONEY(finalPrice)
	CONFIG_CHANGE_PLAYER_SLOTS(finalSlots)
	
	
	//TODO MAJOR - is this pass by value? extremely important.
	//TODO - check.  should throwables skip the reordering step?
	//	   That should change what "finalWeaponIndex" is. not always 0.
	//TAGGG - QUESTION. Why did I do this? Why should any added
	//weapon start at index 0 and not just stay at the end of the array?
	// No idea what I was thinking. oh well.
	
	//swapConfigElements(0, matchStart);
	//
	//for(int i = matchStart; i > 1; i++){
	//	//swap em' backwards.
	//	swapConfigElements(i, i-1);
	//}
	
	
	if(existingMatchingIndex == -1){
		//no element was overwritten? we added a new one. up goes the count.
		CONFIG_PLAYER_INVENTORY_GENERIC_MAX++;
	}
	
	//printouts
	//for(int i = 0; i < CONFIG_PLAYER_INVENTORY_GENERIC_MAX; i++){
	//	printfline("WEAPON %i - %i", i, CONFIG_PLAYER_INVENTORY_GENERIC[i].weaponID);
	//}
	
	
	return TRUE;
}//END OF attemptAddWeaponToConfig
#endif




#ifdef SERVER
BOOL attemptBuyWeapon(player pl, int arg_weaponID, int arg_iBitsUpgrade, int iCount){
	
	
	// IGNORE WARNINGS ABOUT ME!  Only used if the weapon type ID suggests this is a gun or ironsight - type.
	weapondata_gun_t* gunP = NULL;
	
	weapondata_throwable_t throwableRef;
	int existingMatchingIndex = -1;  //not found until proven otherwise.
	ammodata_t ammoRef;
	
	if(arg_weaponID == -1){
		return FALSE;
	}
	
	existingMatchingIndex = findWeaponInInventory(pl, arg_weaponID);
	
	if(existingMatchingIndex == -1 && PLAYER_INVENTORY_GENERIC_MAX >= ary_myWeapons_length){
		// If this weapon is going to be a completely new addition and we don't have a dynamic weapon
		// info element available
		// to represent it, we can't move on.
		return FALSE;
	}
	
	int newPrice = 0;
	int oldPrice = 0;  //price of the existing weapon, if it exists. Can buy the same weapon to change its upgrades.
	int newSlots = 0;
	int oldSlots = 0;
	// this assignment should not be needed.  Stops a warning.
	int ammoType = 0;
	//How much will it cost to buy the new weapon/upgrades?  Does not consider if the
	//weapon was already purchased with different upgrades.
	weapondata_basic_t* weaponPointer = ary_weaponData[arg_weaponID];
	weapondata_basic_t basicRef = *((weapondata_basic_t*) weaponPointer);
	
	int myWeaponTypeID = basicRef.typeID;
	
	//In case the user hacks the client to suggest upgrades a weapon does not actually support,
	//force options not allowed by the weapon's info to be stripped away.
	int iBitsUpgradeSafe = (arg_iBitsUpgrade & basicRef.iBitsUpgrade);
	
	//count each upgrade.
//Silencer: 900
//Lasersight: 800
//Flashlight: 500
//Scope: 1500
//Buy Akimbo: 2 times buy price (does not double upgrade other costs)
//Full Load: X times the buy price, where "X" is max capacity (throwing knives or other stackables if supported)

	
	
	//NOTE - any forced options, including akimbo, don't influence the buy price. Forced options are free and come
	//	   with the weapon. That is, iBitsUpgradeAuto in this case.
	//But any buyOpts not automatic that have been purchased do affect the buy price.
	//And in the case of akimbo, manually buying akimbo raises the iCount of the dynamic weapon info to 2 to
	//show it was upgraded into akimbo (auto-akimbo weapons are still treated as "1" weapon for dropping;
	//singular does not exist).
	//Prices are hardcoded for now.
	//TODO - upgrade prices can come from a shop config file maybe?
	
	
	//int newCount = 1;  //assumption.
	//...actually the user may give us a specific count in the case of throwables
	// in case 
	int newCount = iCount;
	
	//Forbidding anything in iBitsUpgradeAuto just since this is what to charge money for.
	//Anything in auto will be applied at the end free of charge, the user need not request it.
	int manualBuyOpts = (~basicRef.iBitsUpgradeAuto) & iBitsUpgradeSafe;
	if(manualBuyOpts & BITS_WEAPONOPT_SILENCER){
		newPrice += WEAPONOPT_SILENCER_COST;
	}
	if(manualBuyOpts & BITS_WEAPONOPT_LASERSIGHT){
		newPrice += WEAPONOPT_LASERSIGHT_COST;
	}
	if(manualBuyOpts & BITS_WEAPONOPT_FLASHLIGHT){
		newPrice += WEAPONOPT_FLASHLIGHT_COST;
	}
	if(manualBuyOpts & BITS_WEAPONOPT_SCOPE){
		newPrice += WEAPONOPT_SCOPE_COST;
	}
	if(manualBuyOpts & BITS_WEAPONOPT_AKIMBO){
		newCount = 2;  //price adjustment will follow below.
	}
	
	//This buyOpt is only allowed for throwables for now.
	//TODO - support buying up to the max countables allowed if we go over the price / slot limit at full?
	//	   might not be worth it.
	if(myWeaponTypeID == WEAPONDATA_TYPEID_THROWABLE){
		
		throwableRef = *((weapondata_throwable_t*) weaponPointer);
		
		if(manualBuyOpts & BITS_WEAPONOPT_FULLLOAD){
			//remember, this is as though the weapon has never been purchased before yet, so this is maxCount times base price.
			//(not that throwables really have upgrades anyways).
			//And "iMaxCount - 1" because we already spent the buy price once. For a max of 5 knives, actually add 4 times the cost.
#ifdef CLIENT
			//This is only necessary clientside (config), because serverside
			//we received the count already from having picked FULLLOAD.
			newCount = throwableRef.iMaxCount;
#endif
		}else if(existingMatchingIndex != -1){
			//could also be buying another to stack on top of the existing by 1. See if we can.
			int newCountTest = PLAYER_INVENTORY_GENERIC[existingMatchingIndex].iCount + 1;
			if(newCountTest <= throwableRef.iMaxCount){
				//allowed.
				newCount = newCountTest;
			}else{
				//keep it to the same as before.
				newCount = PLAYER_INVENTORY_GENERIC[existingMatchingIndex].iCount;
			}
		}
	}
	
	//Be it a single weapon or akimbo guns or stacked throwables, the logic for altering iPrice / islots is the same.
	newPrice += (newCount) * basicRef.iPrice;
	newSlots += (newCount) * basicRef.iSlots;

	
	if(existingMatchingIndex != -1){
		//remove that weapon first.
		//...usually. There are some exceptions (or just one?)
		oldPrice = PLAYER_INVENTORY_GENERIC[existingMatchingIndex].iPrice;
		oldSlots = PLAYER_INVENTORY_GENERIC[existingMatchingIndex].iSlots;
	}
	
	//If this is the 2nd time buying the weapon, subtract out its old price too see if we can still afford it with
	//the change brought about by more expensive upgrades.  Or maybe that isn't even the case.
	int finalPrice = newPrice - oldPrice;
	int finalSlots = newSlots - oldSlots;
	
	//BOOL queueAmmoFill = FALSE;
	int bulletsToBuy = 0;
	int existingAmmoCost = 0;   //what is the value of the ammo the player already has?
	//Another check for guns only. Is this weapon the first to use a type of ammo?
	
	if(myWeaponTypeID == WEAPONDATA_TYPEID_GUN || myWeaponTypeID == WEAPONDATA_TYPEID_IRONSIGHT){
		
		//And if this weapon's ammo type hasn't been filled by another weapon purchased before, do so (and add its cost).
		//(gun & ironsight only)
		gunP = ((weapondata_gun_t*) weaponPointer);
		ammoType = gunP->iAmmoDataID;
		ammoRef = *ary_ammoData[ammoType];
	
		//do the ammo purchase. at least, a hypothetical:
		
		//Regardless of money allowed or not, we're still keeping track of the value.
		existingAmmoCost = ceil(PLAYER_AMMO[ammoType] * ammoRef.fPricePerBullet);
	
		if(RULE_MONEY_ALLOWED){
			//how much of the player's money is left after the current estimated cost (and existing config cost)?
			//And remove the existingAmmoCost.  There are rounding issues if we keep that in and try to buy bullets on top of it toward the max.
			//This way, just pretend like we're starting at 0 bullets and buying toward the max.
			
			
			// !!! Different between versions
			int remainingPlayerMoney = PLAYER_MONEY - (finalPrice) + existingAmmoCost;
			////////////////////////////////////////////////////////////////////////

			if(remainingPlayerMoney > 0){
				//hopefully it is above 0 or this weapon is flat-out unpurchasable anyways.
				//Divide the remainingPlayerMoney by the cost of a bullet (round it down... can't go over)
				float f_remainingPlayerMoney = (float)remainingPlayerMoney;
				int bulletsAfforded = floor(f_remainingPlayerMoney / ammoRef.fPricePerBullet);
				if(bulletsAfforded > ammoRef.iMax){
					//Even if we could afford more, we can't buy any more than the max allowed.
					bulletsToBuy = ammoRef.iMax;
				}else{
					bulletsToBuy = bulletsAfforded;
				}
			}
		}else{
			//no money?  ammo doesn't cost slots so that's all. Just fill the ammo to max.
			bulletsToBuy = ammoRef.iMax;
		}
	
	}//END OF gun OR ironsight weapon type checks
	
	
	// !!! Different between versions
	//totalCost only for client - for the server, we're only concerned with how much the player physically has left
	if( !RULE_MONEY_ALLOWED || (finalPrice - existingAmmoCost <= PLAYER_MONEY) ){
		//If this still falls under our budget, we may proceed.
	}else{
		//Puts us overbudget? No changes allowed!
		return FALSE;
	}
	
	//2nd check for slots, same as above.
	if(PLAYER_TOTALSLOTS + finalSlots <= RULE_SLOTS_ALLOWED){
		//valid.
	}else{
		return FALSE;
	}
	
	if(bulletsToBuy > 0){
		//Give the bullets.
		ammoRef = *ary_ammoData[ammoType];
		
		//PLAYER_AMMO[ammoType] = bulletsToBuy;
		SET_PLAYER_AMMO(ammoType, bulletsToBuy)
		//and remove the existing ammo cost.
		float f_bulletsToBuy = (float)bulletsToBuy;
		CHANGE_PLAYER_MONEY(-existingAmmoCost + ceil(f_bulletsToBuy * ammoRef.fPricePerBullet))
	}
	
	
	int finalWeaponIndex = 0;
	int matchStart;
	
	if(existingMatchingIndex != -1){
		matchStart = existingMatchingIndex;
	}else{
		matchStart = PLAYER_INVENTORY_GENERIC_MAX;
	}//END OF existingMatchingIndex check
	
	
	// !!! Different between versions
	//////////////////////////////////////////////////////////////////////////////

	PLAYER_INVENTORY_GENERIC[matchStart].weaponID = arg_weaponID;
	PLAYER_INVENTORY_GENERIC[matchStart].weaponTypeID = basicRef.typeID;
	
	if(myWeaponTypeID == WEAPONDATA_TYPEID_GUN || myWeaponTypeID == WEAPONDATA_TYPEID_IRONSIGHT){
		PLAYER_INVENTORY_GENERIC[matchStart].iClipLeft = gunP->iClipMax;
		
		//If our weapon supports akimbo, and we actually have it this time...
		if((basicRef.iBitsUpgrade & BITS_WEAPONOPT_AKIMBO) && (iBitsUpgradeSafe & BITS_WEAPONOPT_AKIMBO) ){
			//you'll be needing this then.
			PLAYER_INVENTORY_GENERIC[matchStart].iClipAkimboLeft = gunP->iClipMax;
		}
		else{
			//nothing
			PLAYER_INVENTORY_GENERIC[matchStart].iClipAkimboLeft = 0;
		}
		
	}//END OF gun check
	else{
		//not a gun? doesn't use either of these.
		PLAYER_INVENTORY_GENERIC[matchStart].iClipLeft = 0;
		PLAYER_INVENTORY_GENERIC[matchStart].iClipAkimboLeft = 0;
	}
	
	//BITMASK_WEAPONOPT_TOGGLEABLE BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_FLASHLIGHT
	//Include 
	PLAYER_INVENTORY_GENERIC[matchStart].iBitsUpgrade = iBitsUpgradeSafe | basicRef.iBitsUpgradeAuto;
	PLAYER_INVENTORY_GENERIC[matchStart].iBitsUpgrade_on = (iBitsUpgradeSafe | basicRef.iBitsUpgradeAuto) & (BITMASK_WEAPONOPT_TOGGLEABLE);
	PLAYER_INVENTORY_GENERIC[matchStart].iCount = newCount;
	
	
	printfline("attemptAddWeaponToConfig - newCount: %i", newCount);
	
	
	PLAYER_INVENTORY_GENERIC[matchStart].iPrice = newPrice;
	PLAYER_INVENTORY_GENERIC[matchStart].iSlots = newSlots;
	
	
	if(myWeaponTypeID == WEAPONDATA_TYPEID_GUN || myWeaponTypeID == WEAPONDATA_TYPEID_IRONSIGHT){
		
		if(gunP->iBitDefaultFireMode != 0){
			//well that was easy.
			
			if(!(iBitsUpgradeSafe & BITS_WEAPONOPT_AKIMBO)){
				//well that was easy.
				PLAYER_INVENTORY_GENERIC[matchStart].iFireMode = gunP->iBitDefaultFireMode;
			}else{
				
				if(gunP->iAkimboID > 0 && gunP->iAkimboID < WEAPON_AKIMBO_UPGRADE_ID::LAST_ID ){
					
					//set this too.  and iFireModeAkimbo.
					PLAYER_INVENTORY_GENERIC[matchStart].iFireMode = gunP->iBitDefaultFireMode;
					
					//Get the akimbo information then
					weapondata_gun_t* basicAkimboGunP = (weapondata_gun_t*) ary_akimboUpgradeData[gunP->iAkimboID];
					
					PLAYER_INVENTORY_GENERIC[matchStart].iFireModeAkimbo = basicAkimboGunP->iBitDefaultFireMode;
				}else{
					//No akimbo ref?  Then I am the akimbo ref.  But I'm using "iFireModeAkimbo".
					PLAYER_INVENTORY_GENERIC[matchStart].iFireModeAkimbo = gunP->iBitDefaultFireMode;
				}
			
			}
			
		}else{
			// AAGH.  Just find the first provided firemode then.
			PLAYER_INVENTORY_GENERIC[matchStart].iFireMode = 0;
			PLAYER_INVENTORY_GENERIC[matchStart].iFireModeAkimbo = 0;
		}
		
	}else{
		//doesn't use the concept of "iFireMode".
		PLAYER_INVENTORY_GENERIC[matchStart].iFireMode = 0;
		PLAYER_INVENTORY_GENERIC[matchStart].iFireModeAkimbo = 0;
		
	}
	
	PLAYER_INVENTORY_GENERIC[matchStart].iIronSight = 0;  //default: no use / magnification.
	
	PLAYER_INVENTORY_GENERIC[matchStart].iForceBodygroup1Submodel = 0;
	PLAYER_INVENTORY_GENERIC[matchStart].bNeedsPump = FALSE;
	
	//PLAYER_INVENTORY_GENERIC[matchStart].iPrice = newPrice;
	//PLAYER_INVENTORY_GENERIC[matchStart].iSlots = newSlots;
	
	
	//TAGGG - CRITICAL NOTICE.
	// If we want some custom init for a weapon the moment it is created period
	// (in this case at the same time as buying), we could call it here.
	// For weapons spawned into a level, those would have to handle that call on their own though at spawn.
	// And know not to re-trigger that on being picked up by a player.
	
	//////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////


	
	CHANGE_PLAYER_MONEY(finalPrice)
	CHANGE_PLAYER_SLOTS(finalSlots)
	
	
	//TODO MAJOR - is this pass by value? extremely important.
	//TODO - check.  should throwables skip the reordering step?
	//	   That should change what "finalWeaponIndex" is. not always 0.
	//TAGGG - QUESTION. Why did I do this? Why should any added
	//weapon start at index 0 and not just stay at the end of the array?
	// No idea what I was thinking. oh well.
	
	//swapConfigElements(pl, 0, matchStart);
	//
	//for(int i = matchStart; i > 1; i++){
	//	//swap em' backwards.
	//	swapConfigElements(pl, i, i-1);
	//}
	
	
	if(existingMatchingIndex == -1){
		//no element was overwritten? we added a new one. up goes the count.
		PLAYER_INVENTORY_GENERIC_MAX++;
	}
	
	//printouts
	//for(int i = 0; i < PLAYER_INVENTORY_GENERIC_MAX; i++){
	//	printfline("WEAPON %i - %i", i, PLAYER_INVENTORY_GENERIC[i].weaponID);
	//}
	
	pl.completeInventorySend = TRUE;
	return TRUE;
}//END OF attemptBuyWeapon
#endif







//TAGGG - TODO.  Could this even be shared?
// It is only called by the player picking up weapons ingame, which only happens serverside.
// The client does not even receive the implementation details of CTSWorldGun.

#ifdef SERVER
// This method may only be used by the server ingame, not at all buy-related.
// This will add a weapon of the given weaponID to an available slot in the player inventory,
// with all blank info (fire mode, clip size, buyopts).
// This method returns the index in the inventory this default-property'd weapon went to.
// Use this to specify any other details needed in case the ones sent along in this method are not enough.
// Obviously picking up an existing weapon does not cost anything, nor does it affect existing ammo pools.
// (the exception being picking up a weapon the player already has, which puts its ammo into some pool
// if there is room for it... this should not call this method at all)
// Picking up the new weapon cannot put the player overbudget for slots (default 81).  If so, we deny the pickup.
//int addWeaponToInventory(player pl, int arg_weaponID, int arg_iClip, int arg_iClipAkimbo, int arg_iBitsUpgrade, int iCount){
int addWeaponToInventory(player pl, CTSWorldGun arg_pickupRef){
	
	//safe assumption... for now.
	//NOTICE that this doesn't mean anything if we return -1,
	// since that means  we don't want to commit anything.
	pl.switchToRecentlyAddedWeapon = FALSE;
	
	int arg_weaponID = arg_pickupRef.myInfo.weaponID;
	
	
	weapondata_gun_t* gunP = NULL;
	weapondata_throwable_t throwableRef;
	int existingMatchingIndex = -1;  //not found until proven otherwise.
	ammodata_t ammoRef;
	
	if(arg_weaponID == -1){
		return -1;
	}
	
	existingMatchingIndex = findWeaponInInventory(pl, arg_weaponID);
	
	
	
	if(existingMatchingIndex == -1 && PLAYER_INVENTORY_GENERIC_MAX >= ary_myWeapons_length){
		//If this weapon is going to be a completely new addition and we don't have a dynamic weapon info element available
		//to represent it, we can't move on.
		return -1;
	}
	
	int newSlots = 0;
	int oldSlots = 0;
	int ammoType;
	//How much will it cost to buy the new weapon/upgrades?  Does not consider if the
	//weapon was already purchased with different upgrades.
	weapondata_basic_t* weaponPointer = ary_weaponData[arg_weaponID];
	weapondata_basic_t basicRef = *((weapondata_basic_t*) weaponPointer);
	
	int myWeaponTypeID = basicRef.typeID;
	
	//In case the user hacks the client to suggest upgrades a weapon does not actually support,
	//force options not allowed by the weapon's info to be stripped away.
	int iBitsUpgradeSafe = (arg_pickupRef.myInfo.iBitsUpgrade & basicRef.iBitsUpgrade);
	int iBitsUpgradeSafe_on = (arg_pickupRef.myInfo.iBitsUpgrade_on & basicRef.iBitsUpgrade) & (BITMASK_WEAPONOPT_TOGGLEABLE);
	
	
	//count each upgrade.
	/*
Silencer: 900
Lasersight: 800
Flashlight: 500
Scope: 1500
Buy Akimbo: 2 times buy price (does not double upgrade other costs)
Full Load: X times the buy price, where "X" is max capacity (throwing knives or other stackables if supported)
	*/
	
	
	//NOTE - any forced options, including akimbo, don't influence the buy price. Forced options are free and come
	//	   with the weapon. That is, iBitsUpgradeAuto in this case.
	//But any buyOpts not automatic that have been purchased do affect the buy price.
	//And in the case of akimbo, manually buying akimbo raises the iCount of the dynamic weapon info to 2 to
	//show it was upgraded into akimbo (auto-akimbo weapons are still treated as "1" weapon for dropping;
	//singular does not exist).
	//Prices are hardcoded for now.
	//TODO - upgrade prices can come from a shop config file maybe?
	
	
	
	//int newCount = 1;  //assumption.
	//...actually the user may give us a specific count in the case of throwables
	// in case 
	// For pickups this is only relevant for throwables.  Any akimbo pickup's count is not useful.
	
	int newCount = arg_pickupRef.myInfo.iCount;
	int pickupCountSubtract = newCount;   //safe starting assumption.
	
	//how much ammo to take from what we're looking at. If applicable.
	int iClipLeftMod = 0;
	int iClipAkimboLeftMod = 0;
	
	//Forbidding anything in iBitsUpgradeAuto just since this is what to charge money for.
	//Anything in auto will be applied at the end free of charge, the user need not request it.
	//int manualBuyOpts = (~basicRef.iBitsUpgradeAuto) & iBitsUpgradeSafe;
	
	
	int matchStart;
	int amountToTake = 0;
	
	if(existingMatchingIndex != -1){
		matchStart = existingMatchingIndex;
	}else{
		//brand new weapon?  Very likely to switch to it.
		pl.switchToRecentlyAddedWeapon = TRUE;
		
		matchStart = PLAYER_INVENTORY_GENERIC_MAX;
		//PLAYER_INVENTORY_GENERIC[matchStart].iCount = 0;  //safety... unused slot anyways.
	}//END OF existingMatchingIndex check
	
	
	//This buyOpt is only allowed for throwables for now.
	//TODO - support buying up to the max countables allowed if we go over the price / slot limit at full?
	//	   might not be worth it.
	if(myWeaponTypeID == WEAPONDATA_TYPEID_THROWABLE){
		
		throwableRef = *((weapondata_throwable_t*) weaponPointer);
		
		
		if(existingMatchingIndex != -1){
			
			//Try to absorb the count from the pickup into our current weapon, as much as we can of it.
			int existingCount = PLAYER_INVENTORY_GENERIC[matchStart].iCount;
			int pickupCount = arg_pickupRef.myInfo.iCount;
			
			if(existingCount + pickupCount <= throwableRef.iMaxCount){
				//absorb it all.
				amountToTake = pickupCount;
			}else{
				//too much in the pickup?  this is ok, take as much as we can.
				amountToTake = throwableRef.iMaxCount - existingCount;
			}
			
			if(amountToTake > 0){
				TS_Weapons_PlaySoundChannelDirect(pl, "items/9mmclip1.wav", CHAN_ITEM);
			}else{
				TS_Weapons_PlaySoundChannelDirect(pl, "common/wpn_select.wav", CHAN_ITEM);
			}
			
			newCount = existingCount + amountToTake;
			//arg_pickupRef.myInfo.iCount -= amountToTake;
			pickupCountSubtract = amountToTake;  //remove this much from the count later.
		}
	}else if(myWeaponTypeID == WEAPONDATA_TYPEID_GUN || myWeaponTypeID == WEAPONDATA_TYPEID_IRONSIGHT){
		
		// if set to TRUE, we aren't going to pick up this weapon.
		// Just search any of its clips to see what we can add to our own
		// primary ammo instead.
		BOOLEAN harvestAmmo = FALSE;
		
		gunP = ((weapondata_gun_t*) weaponPointer);
		//gun? ironsight?  We can go akimbo, maybe.
		// Have it already?
		if(existingMatchingIndex == -1){
			//first copy?  Check if AKIMBO was auto.
			if(basicRef.iBitsUpgradeAuto & BITS_WEAPONOPT_AKIMBO){
				//it is?  We need to put it back in for this singular copy to work right.
				iBitsUpgradeSafe |= BITS_WEAPONOPT_AKIMBO;
			}
			
		}else{   //if(existingMatchingIndex != -1
			ammoType = gunP->iAmmoDataID;
			ammoRef = *ary_ammoData[ammoType];
			
			//we are seeing if we have akimbo...
			if(basicRef.iBitsUpgradeAuto & BITS_WEAPONOPT_AKIMBO){
				//singular form supports akimbo?  Reject this, can't have more than one.  Already have akimbo then.
				
				harvestAmmo = TRUE;
				
			}else if(basicRef.iBitsUpgrade & BITS_WEAPONOPT_AKIMBO){
				// We support akimbo.  ok.
				// But do we actually have it in this case?
				
				if(!(PLAYER_INVENTORY_GENERIC[existingMatchingIndex].iBitsUpgrade & BITS_WEAPONOPT_AKIMBO)){					
					//If our weapon stats supports akimbo, yet we do not have it, we can use this weapon to turn into akimbo.
					iBitsUpgradeSafe |= BITS_WEAPONOPT_AKIMBO;
					newCount = 2;  //I require double the slots, since I'm the 2nd copy.
					// HOWEVER don't touch pickupCountSubtract.  Only one came,
					// but our count changed to 2. Still just subtract the one that came.
					
					//oh and switch to this now.
					pl.switchToRecentlyAddedWeapon = TRUE;
					
					//...also, go ahead and take any buyopts from the weapon we're picking up, they get absorbed into akimbo.
					// So yes, if you have one SOCOM without the silencer and another with the silencer, pick both up to get
					// akimbo and drop them, they both have silencers.  Good luck figuring that one out.
					iBitsUpgradeSafe = iBitsUpgradeSafe | PLAYER_INVENTORY_GENERIC[existingMatchingIndex].iBitsUpgrade;
					iBitsUpgradeSafe_on = iBitsUpgradeSafe_on | PLAYER_INVENTORY_GENERIC[existingMatchingIndex].iBitsUpgrade_on;

				}else{
					// We support akimbo but already have it?
					// See if we can suck ammo out of this gun then.
					harvestAmmo = TRUE;
				}
				
			}else{
				//don't support akimbo at all.   ok, easy enough to suck ammo.
				
				harvestAmmo = TRUE;
			}
			
			
			if(harvestAmmo){
				if(PLAYER_AMMO[ammoType] + arg_pickupRef.myInfo.iClipAkimboLeft <= ammoRef.iMax){
					//absorb it all.
					iClipAkimboLeftMod = arg_pickupRef.myInfo.iClipAkimboLeft;
				}else{
					//too much in the pickup?  this is ok, take as much as we can.
					iClipAkimboLeftMod = ammoRef.iMax - PLAYER_AMMO[ammoType];
				}
				SET_PLAYER_AMMO(ammoType, PLAYER_AMMO[ammoType] + iClipAkimboLeftMod)
				arg_pickupRef.myInfo.iClipAkimboLeft -= iClipAkimboLeftMod;
				
				if(PLAYER_AMMO[ammoType] + arg_pickupRef.myInfo.iClipLeft <= ammoRef.iMax){
					//absorb it all.
					iClipLeftMod = arg_pickupRef.myInfo.iClipLeft;
				}else{
					//too much in the pickup?  this is ok, take as much as we can.
					iClipLeftMod = ammoRef.iMax - PLAYER_AMMO[ammoType];
				}
				SET_PLAYER_AMMO(ammoType, PLAYER_AMMO[ammoType] + iClipLeftMod)
				arg_pickupRef.myInfo.iClipLeft -= iClipLeftMod;
				
				if(iClipAkimboLeftMod != 0 || iClipLeftMod != 0){
					//actually got some ammo?  play this sound.
					TS_Weapons_PlaySoundChannelDirect(pl, "items/9mmclip1.wav", CHAN_ITEM);
				}else{
					//nothing? play this.
					TS_Weapons_PlaySoundChannelDirect(pl, "common/wpn_select.wav", CHAN_ITEM);
				}
				
				//nothing left to do here.
				return -1;
			}//END OF harvestAmmo check
			
		}
	}else{
		//melee?  only 1 allowed for now.
		if(existingMatchingIndex != -1){
			TS_Weapons_PlaySoundChannelDirect(pl, "common/wpn_select.wav", CHAN_ITEM);
			return -1;
		}
	}
	
	
	newSlots += (newCount) * basicRef.iSlots;
	
	if(existingMatchingIndex != -1){
		//remove that weapon first.
		//...usually. There are some exceptions (or just one?)
		oldSlots = PLAYER_INVENTORY_GENERIC[existingMatchingIndex].iSlots;
	}
	
	//If this is the 2nd time buying the weapon, subtract out its old price too see if we can still afford it with
	//the change brought about by more expensive upgrades.  Or maybe that isn't even the case.
	int finalSlots = newSlots - oldSlots;
	
	
	
	// check for slots, same as above.
	if(PLAYER_TOTALSLOTS + finalSlots <= RULE_SLOTS_ALLOWED){
		//valid.
	}else{
		return -1;  //can not add, not enough slots.
	}
	
	int finalWeaponIndex = 0;
	
	
	PLAYER_INVENTORY_GENERIC[matchStart].weaponID = arg_weaponID;
	PLAYER_INVENTORY_GENERIC[matchStart].weaponTypeID = basicRef.typeID;
	
	if(myWeaponTypeID == WEAPONDATA_TYPEID_GUN || myWeaponTypeID == WEAPONDATA_TYPEID_IRONSIGHT){
		
		//Hold on now!  We need to handle this a little differently.
		
		//First off, does this weapon automatically come with akimbo?
		if(basicRef.iBitsUpgradeAuto & BITS_WEAPONOPT_AKIMBO){
			//it does?  Expect the single pickup to use both iClip and iClipAkimbo.
			PLAYER_INVENTORY_GENERIC[matchStart].iClipLeft = arg_pickupRef.myInfo.iClipLeft;
			PLAYER_INVENTORY_GENERIC[matchStart].iClipAkimboLeft = arg_pickupRef.myInfo.iClipAkimboLeft;
			PLAYER_INVENTORY_GENERIC[matchStart].iFireMode = arg_pickupRef.myInfo.iFireMode;
			PLAYER_INVENTORY_GENERIC[matchStart].iFireModeAkimbo = arg_pickupRef.myInfo.iFireModeAkimbo;
			
			//Perhaps the weapon supports akimbo, and the current weapon here indeed as it set from earlier.
		}else if(basicRef.iBitsUpgrade & BITS_WEAPONOPT_AKIMBO && iBitsUpgradeSafe & BITS_WEAPONOPT_AKIMBO){
			//Send the weapon's clip to iClipAkimboLeft actually.
			//printfline("addWeaponToInventory - iFireModeAkimbo:%i ammo in akimbo1:%i akimbo2:%i", arg_pickupRef.myInfo.iFireModeAkimbo, arg_pickupRef.myInfo.iClipLeft, arg_pickupRef.myInfo.iClipAkimboLeft);
			PLAYER_INVENTORY_GENERIC[matchStart].iClipAkimboLeft = arg_pickupRef.myInfo.iClipLeft;
			PLAYER_INVENTORY_GENERIC[matchStart].iFireModeAkimbo = arg_pickupRef.myInfo.iFireModeAkimbo;
			if(PLAYER_INVENTORY_GENERIC[matchStart].iFireModeAkimbo == 0){
				//give me a default fire mode for akimbo!  Happens if we were only in singular and dropped.
				weapondata_gun_t* basicAkimboGunP = (weapondata_gun_t*) ary_akimboUpgradeData[gunP->iAkimboID];
				
				PLAYER_INVENTORY_GENERIC[matchStart].iFireModeAkimbo = basicAkimboGunP->iBitDefaultFireMode;
			}
		}else{
			//this isn't akimbo or we don't support it?  To the first clip only, blank the akimbo for safety.
			PLAYER_INVENTORY_GENERIC[matchStart].iClipLeft = arg_pickupRef.myInfo.iClipLeft;
			PLAYER_INVENTORY_GENERIC[matchStart].iClipAkimboLeft = 0;
			PLAYER_INVENTORY_GENERIC[matchStart].iFireMode = arg_pickupRef.myInfo.iFireMode;
			//PLAYER_INVENTORY_GENERIC[matchStart].iFireModeAkimbo = 0;
		}
		
	}//END OF gun check
	else{
		//not a gun? doesn't use either of these.
		PLAYER_INVENTORY_GENERIC[matchStart].iClipLeft = 0;
		PLAYER_INVENTORY_GENERIC[matchStart].iClipAkimboLeft = 0;
		PLAYER_INVENTORY_GENERIC[matchStart].iFireMode = 0;
		PLAYER_INVENTORY_GENERIC[matchStart].iFireModeAkimbo = 0;
	}
	
	// do these copies really have a point now?
	PLAYER_INVENTORY_GENERIC[matchStart].iBitsUpgrade = iBitsUpgradeSafe;
	PLAYER_INVENTORY_GENERIC[matchStart].iBitsUpgrade_on = iBitsUpgradeSafe_on;
	PLAYER_INVENTORY_GENERIC[matchStart].iCount = newCount;
	arg_pickupRef.myInfo.iCount -= pickupCountSubtract;
	
	//printfline("pickup iForceBodygroup1Submodel: %i", arg_pickupRef.myInfo.iForceBodygroup1Submodel);
	
	//PLAYER_INVENTORY_GENERIC[matchStart].iPrice = newPrice;
	PLAYER_INVENTORY_GENERIC[matchStart].iSlots = newSlots;
	PLAYER_INVENTORY_GENERIC[matchStart].iIronSight = 0;  //default: no use / magnification.
	
	
	//TAGGG - CRITICAL NOTICE.
	// If we want some custom init for a weapon the moment it is created period
	// (in this case at the same time as buying), we could call it here.
	// For weapons spawned into a level, those would have to handle that call on their own though at spawn.
	// And know not to re-trigger that on being picked up by a player.
	
	CHANGE_PLAYER_SLOTS(finalSlots)
	
	
	//TODO MAJOR - is this pass by value? extremely important.
	//TODO - check.  should throwables skip the reordering step?
	//	   That should change what "finalWeaponIndex" is. not always 0.
	//TAGGG - QUESTION. Why did I do this? Why should any added
	//weapon start at index 0 and not just stay at the end of the array?
	// No idea what I was thinking. oh well.
	/*
	swapConfigElements(pl, 0, matchStart);
	
	for(int i = matchStart; i > 1; i++){
		//swap em' backwards.
		swapConfigElements(pl, i, i-1);
	}
	*/
	
	if(existingMatchingIndex == -1){
		//no element was overwritten? we added a new one. up goes the count.
		PLAYER_INVENTORY_GENERIC_MAX++;
	}
	
	// copy stuff
	arg_pickupRef.copyTo(pl, matchStart);
	
	
	// some printouts?
	/*
	for(int i = 0; i < PLAYER_INVENTORY_GENERIC_MAX; i++){
		printfline("WEAPON %i - %i", i, PLAYER_INVENTORY_GENERIC[i].weaponID);
	}
	*/
	
	pl.completeInventorySend = TRUE;
	return matchStart;  // we need to tell the caller what spot we put the weapon in, in the player's inventory.
}//END OF addWeaponToInventory
#endif





// Client only!
// Give the server "PlayerBuyWeapon" and similar messsages to send the config
// order through for equipping the soon-to-be-spawned player.
// Is there a better way than sending as messages one-after-the-other like this?
// It ends in "PlayerBuyWeapon_TS_end" to let the player know the messages are over.
// If messsages can appear on the receiver's (serveR) end a different order,
// this may have issues, but I haven't run into any issues with this yet.
#ifdef CLIENT

//TAGGG - TODO MAJOR!!! Forbid this call if we are unable to buy stuff. When that is, I forget.
//		SAME for serverside especially, so hacking the client isn't an option
//Call this method when the player spawns to spend their money as per the config (current config):
void deployConfig(void){
	
	
	printfline("deployConfig CALLED !!!  Money? %i", CONFIG_PLAYER_MONEY);
	
	// the player always gets karate at a bare minimum
	sendevent("PlayerBuyWeapon_TS", "ii", (int)WEAPON_ID::KARATE, (int)BITS_WEAPONOPT_NONE);
		
	
	for(int i = 0; i < pSeatLocal->m_clientinfo.weaponconfig_current.ary_myWeapons_softMax; i++){
		weaponconfig_weapon_t* thisWeapo = &pSeatLocal->m_clientinfo.weaponconfig_current.ary_myWeapons[i];
		
		printfline("deployConfig weaponTypeID:%i iCount:%i", thisWeapo->weaponTypeID, thisWeapo->iCount);
		
		if(thisWeapo->weaponTypeID == WEAPONDATA_TYPEID_THROWABLE){
			//need to send over the weapon count too.
			sendevent("PlayerBuyWeaponThw_TS", "iii", thisWeapo->weaponID, thisWeapo->iBitsUpgrade, thisWeapo->iCount);
		}else{
			//any specific info we need is in the upgrades.
			//sendevent("PlayerBuyWeapon_TS", "ii", selectedWeaponButton.iWeaponPurchaseID, iBitsUpgradeTemp);
			sendevent("PlayerBuyWeapon_TS", "ii", thisWeapo->weaponID, thisWeapo->iBitsUpgrade);
		}
		
	}//END OF for loop THROUGH config
	
	//send a signal that we're done ordering weapons
	sendevent("PlayerBuyWeapon_TS_end", "");
	
}//END OF deployConfig

#endif


