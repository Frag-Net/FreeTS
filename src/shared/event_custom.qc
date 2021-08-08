

void
TS_Weapon_PrimaryAttackRelease(player pl){
	if(pl.inventoryEquippedIndex == -1){
		return;
	}
	
	weapondynamic_t dynaRef = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapondata_basic_t* basicP = pl.getEquippedWeaponData();
	
	(*basicP).funOnPrimaryAttackRelease(pl, dynaRef);
}


void
TS_Weapon_SecondaryAttackRelease(player pl){
	if(pl.inventoryEquippedIndex == -1){
		return;
	}
	
	weapondynamic_t dynaRef = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapondata_basic_t* basicP = pl.getEquippedWeaponData();
	
	(*basicP).funOnSecondaryAttackRelease(pl, dynaRef);
}



// For client and serverside to call alongside a "Weapons_Draw" call,
// even if Weapons_Draw itself is skipped in the clientside weapon-select route.
// This does get called by ts/client/view.qc calling Weapons_Draw for clientside though,
// so treat this as 'whatever I want to happen on drawing a weapon'.
void
TS_Weapon_Draw_extra(void){
	player pl = (player)self;
	
	printfline("PLAYER DREW WEAPON: invID:%i (g_weapons ID:%d)", pl.inventoryEquippedIndex, pl.activeweapon);
	
	pl.currentZoomChoice = -1;
	pl.aryNextBurstShotTime_softLength = 0;
	pl.aryNextBurstShotTime_listenIndex = -1;
	
	// Cheap, but should work?  Some things above may be redundant with this
	pl.reset(FALSE);
	
}


void
TS_Weapon_Draw(player pl, int weaponEquipped, BOOL useAkimbo ) {
	//weapondynamic_t dynaRef;
	//weapondynamic_t dynaRefPRE;
	
	// Anything equipped already?
	if(pl.inventoryEquippedIndex != -1){
		// How about Nuclide's 'Holster' instead?
		Weapons_Holster();
		pl.equippedWeaponDeleteCheck();
	}
	
	
	
	pl.setInventoryEquippedIndex_Akimbo(weaponEquipped, useAkimbo);
	// actually no, I guess we just let rendering pick up on this to know when to call draw
	// MMMMMmmmmmm sounds odd if Draw containts non-rendering-related startup script,
	// rather this happen as son as possible for now.
	
#ifdef CLIENT
	printfline("TS_Weapon_Draw (client direct call): prev:%i curr:%d", pSeat->m_iLastWeapon, pl.activeweapon);
#endif
	
	
	// This Weapons_Draw call is only for serverside, at clientside, we trust
	// <gamemod>/src/client/view.qc to notice the weapon change and call Weapons_Draw for us.
	// This is more accurate to the way seen in other Nuclide gamemods.
	
	// If Holster animations were supported (anim to play on switching weapons that must
	// finish before a switch happens, looks like putting the weapon away out of view
	// first), some delay until calling Weapons_Draw here or in ts/client/view.qc to let
	// that holster anim finish playing would be a good idea.
	
	
	// TEST!  Force the call now anyway clientside too.
//#ifdef SERVER
	TS_Weapon_Draw_extra();
	Weapons_Draw();
//#else
//	// so that any choice of weapon, same as before or even nothing, will still
//	// let client/view.qc do the whole viewmodel routine again
//	// This might not even be effective here for spawns, see EVENT_TS::SPAWN
//	pSeat->m_iLastWeapon = -2;
//#endif
	
	// Is that necessary?
#ifdef CLIENT
	TS_HUD_CloseWeaponSelect(TRUE);
#endif

}//TS_Weapon_Draw




// This will be serverside only.  Clientside should never call this.
// TODO.  Would making this shared be OK?  Seems to have worked for grenades and throwing knives
// on removing themselves on running out of ammo.
// Just remember that spawning the actual entitiy won't be happening clientside in any form.
#ifdef SERVER
void
TS_Weapon_Drop() {
	player pl = (player)self;
	if(pl.inventoryEquippedIndex == -1){
		// stop.  nothing to drop?
		return;
	}
	if(pl.inventoryEquippedIndex != -1){
		pl.dropWeapon(pl.inventoryEquippedIndex, FALSE);
	}
}//TS_Weapon_Drop
#endif



// CRITICAL!  TS_playerEquippedWeapon methods dummied out to stop conflicts with
// the new Nuclide way
void
TS_playerEquippedWeapon_Shared(player pl, int newWeaponEquipped, BOOL useAkimbo){
	/*
	if(pl.inventoryEquippedIndex == newWeaponEquipped && useAkimbo == pl.weaponEquippedAkimbo ){
		// equipping the same weapon?  Ignore this call then!
		return;
	}
	*/
	
	_TS_playerEquippedWeapon(pl, newWeaponEquipped, useAkimbo);
}



#ifdef CLIENT

// Actual clientside logic related to this action. Need to change the viewmodel
// on a change like this.
// Note that viewmodels check for "pl.inventoryEquippedIndex" being changed in ts/client/view.c.
// This is OK.  pl.inventoryEquippedIndex is updated from server to client in client & server/player.c, read/sendEntity methods.  So everything works out.
void
_TS_playerEquippedWeapon(player pl, int newWeaponEquipped, BOOL useAkimbo){
	
	TS_Weapon_Draw(pl, newWeaponEquipped, useAkimbo);
}




// The client set the equippedWeapon, and needs to tell the server to keep it in synch
// NOTICE - if we commit the change this very moment, it actually messes with
// prediction stuff.
// So don't do any real client changes from calls when the client starts them.
// The client will tell the server to do something, and THEN the server relays that to
// the client. Whatever just go with it.
void
TS_playerEquippedWeapon(player pl, int newWeaponEquipped, BOOL useAkimbo){
	//pSeat->ePlayer = self = findfloat(world, entnum, player_localentnum);
	
	//printfline("WELL??! %i %i %d %d", pl.inventoryEquippedIndex, newWeaponEquipped, useAkimbo, pl.weaponEquippedAkimbo);
	//TODO - CRITICAL!  Although - might not be that bad.
	// Note that any weapon removal (only removing the currently equipped weapon is possible) also
	// sets the current equipped weapon to -1.  So any other choice of weapon after this has to work.
	// ----------OLD COMMENT--------
	// Check for having recently deleted a weapon.  If so, forget this check.  The choice picked
	// is guaranteed to be ok.
	// Say there are 3 weapons, #0, #1, #2, and #3.  Say #2 is equipped now.
	// If #2 is deleted (shifts #3 to be the new #2), and #2 is picked to be the new weapon,
	// that would cause this check to deny picking the 'new' weapon taking up slot #2.
	if(pl.inventoryEquippedIndex == newWeaponEquipped && useAkimbo == pl.weaponEquippedAkimbo ){
		// equipping the same weapon?  Ignore this call then!
		return;
	}
	
	_TS_playerEquippedWeapon(pl, newWeaponEquipped, useAkimbo);
	sendevent("TS_playerEquippedWeapon", "ii", newWeaponEquipped, (int)useAkimbo);
}

#endif
#ifdef SERVER
// that's it really serverside.
void
_TS_playerEquippedWeapon(player pl, int newWeaponEquipped, BOOL useAkimbo){
	
	TS_Weapon_Draw(pl, newWeaponEquipped, useAkimbo);
}

//The server set the equippedWeapon, and needs to tell the client to keep it in synch
void
TS_playerEquippedWeapon(player pl, int newWeaponEquipped, BOOL useAkimbo){
	_TS_playerEquippedWeapon(pl, newWeaponEquipped, useAkimbo);
	
	// force a sendoff soon!
	pl.activeweapon_net = 255;
	pl.inventoryEquippedIndex_net = 255;
	
}

// This is a received call from the client.
// We do need to let the server update first, which then tells the client
// of the updated state.  Even though the client initiated the call in this case.
// The server can initiate the call too.
// Either side can call "TS_playerEquippedWeapon" to get the orders right.
void
CSEv_TS_playerEquippedWeapon_ii(int newWeaponEquipped, BOOL useAkimbo){
	player pl = (player)self;
	
	TS_playerEquippedWeapon(pl, newWeaponEquipped, useAkimbo);
}


#endif



// The server may want to tell the client to reset its viewmodel.
// DUMMIED - nevermind that for now, assuming the logic is called from server/client
// individually like a lot of weapon's logic.
#ifdef SERVER
void
TS_resetViewModel(player pl){
	
	/*
	//pl.lasersightUnlockTime = FALSE;  //reset
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte( MSG_MULTICAST, EVENT_TS::RESET_VIEW_MODEL );
	msg_entity = pl;
	multicast( [0,0,0], MULTICAST_ONE );
	*/
	
	// IDEA:
	// I don't think resetting w_idle_next and w_next_attack here would be very
	// helpful.  Same for in EV_TS_resetViewModel.
}
#else
//CLIENT
void
TS_resetViewModel(player pl){
	EV_TS_resetViewModel();
}
void
EV_TS_resetViewModel(void){
	player pl = (player)self;
	pSeat->m_iLastWeapon = -1;  // any weapon slot choice will refresh the view model.
	pl.lasersightUnlockTime = FALSE;
	resetViewModel();
}
#endif



// Want to reset the player between spawns?
#ifdef SERVER
void
TS_resetPlayer(player pl, BOOL resetInventory){
	if(pl == NULL){
		return;
	}
	
	//reset our inventory, serverside.
	pl.reset(resetInventory);
	
	//And tell the client to do the same.
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte( MSG_MULTICAST, EVENT_TS::RESET_PLAYER );
	WriteByte( MSG_MULTICAST, resetInventory );
	msg_entity = pl;
	multicast( [0,0,0], MULTICAST_ONE );
}
#else
//CLIENT
void
EV_TS_resetPlayer(player pl, BOOL resetInventory){
	if(pl == NULL){
		return;
	}
	
	pl.reset(resetInventory);
}
#endif


#ifdef CLIENT
// Called by the GameRules, PlayerDeath, for the client to do something as soon as
// possible.
// WHOOPS.  All vars since have been dummied or changes here are ineffective,
// keeping the event in case it has some use later.
void
EV_PlayerDeath(void){
	printfline("EV_PlayerDeath");
	
	// Require a tiny amount of time and a mouse release before a respawn, so that
	// dying with the mouse held down isn't enough to trigger a respawn request.
	//pSeatLocal->m_bNeedPrimaryRelease = TRUE;
	//pSeatLocal->m_flReleaseTime = time + 0.15;
	
	// Unfortunately not as effective as it may look. 
	// On the player using "kill" in console, a CSQC_Parse_Damage call happens shortly
	// after this PlayerDeath one, somehow.  Stopping damage-drawing on the "*dead" key
	// being 1 works.
	//pSeat->m_flDamageAlpha = 0;
}
#endif



#ifdef CLIENT
//NOTICE - clientside components removed, except for clientside being able
// to signal that the server should remove a weapon.
// This needs no clientside logic equivalent to be mirrored.
/*
void _TS_playerDropWeapon(player pl){
	
	TS_Weapon_Drop();
	
}
*/
// TODO.  Do anything clientside here too, maybe?  Unsure.
// Could call the player's DropWeapon method here, but it's hard to trust FTE with prediction
// when it comes to altering inventories it seems.
void
TS_playerDropWeapon(void){
	sendevent("TS_playerDropWeapon", "");
}// TS_playerDropWeapon
/*
//This is a received call from the server - no need to update it back
//NOTICE - this is the callback telling us to do something.  Yes do something.
void EV_TS_playerDropWeapon(player pl){
	//pSeat->ePlayer = self = findfloat(world, entnum, player_localentnum);
	
	_TS_playerDropWeapon(pl);
}
*/
#endif
#ifdef SERVER
//that's it really serverside.
void
_TS_playerDropWeapon(void){
	player pl = (player)self;
	
	TS_Weapon_Drop();
	
}//_TS_playerDropWeapon

//The server set the equippedWeapon, and needs to tell the client to keep it in synch
void
TS_playerDropWeapon(void){
	player pl = (player)self;
	//pSeat->ePlayer = self = findfloat(world, entnum, player_localentnum);
	_TS_playerDropWeapon();
	
	
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte( MSG_MULTICAST, EVENT_TS::DROP_WEAPON );
	msg_entity = pl;
	multicast( [0,0,0], MULTICAST_ONE );
}

//This is a received call from the client.
//We do need to let the server update first, which then tells the client
//of the updated state.  Even though the client initiated the call in this case.
//The server can initiate the call too.
//Either side can call "TS_playerEquippedWeapon" to get the orders right.
void
CSEv_TS_playerDropWeapon_(){
	player pl = (player)self;
	
	TS_playerDropWeapon();
	
}
#endif






#ifdef SERVER
// Server receives the message
void
CSEv_TS_playerChangeFiremode_(void){
	player pl = (player)self;
	
#ifdef FIREMODE_PREDICTION_TEST
	pl.doFiremodeChange = TRUE;
#else
	_TS_playerChangeFiremode();
#endif//FIREMODE_PREDICTION_TEST
}
#endif

// For now, only the client will expect direct calls to these.
// Client sends the input, server receives a message in response to perform things on
// its end too.
void
TS_playerChangeFiremode(void){
	player pl = (player)self;
	if(pl.inventoryEquippedIndex == -1){
		return;
	}
	
#ifdef CLIENT
		sendevent("TS_playerChangeFiremode", "");

#ifdef FIREMODE_PREDICTION_TEST
		pl.ignoreFiremodeReceiveTime = time + 0.4f;
		pl.doFiremodeChange = TRUE;
#else
		// do it for the client too?
		_TS_playerChangeFiremode();
#endif//FIREMODE_PREDICTION_TEST
		
#else
		// SHOULD NOT HAPPEN, should call the CSEv_ version instead
#endif
}


void
_TS_playerChangeFiremode(void ) {
	player pl = (player)self;
	weapondynamic_t dynaRef = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	
#if defined(CLIENT_CMD_SAFEMODE) && defined(CLIENT)
	// nope!
	return;
#endif
	
	if(dynaRef.weaponTypeID == WEAPONDATA_TYPEID_GUN || dynaRef.weaponTypeID == WEAPONDATA_TYPEID_IRONSIGHT){
		weapondata_gun_t* basicPointer = (weapondata_gun_t*) pl.getEquippedWeaponData();
		weapondata_gun_t basicRef = *(basicPointer);
		
		// If the bitmask for available firemodes for this weapon is just a flat "0" (none
		// specified?) OR our bitmask matches the current firemode exactly (only one bit present),
		// there is no point in trying to switch firemodes.
		if(basicRef.iBitsFireModes == 0){
			return;
		}
		
		int* fireModeVar;
		int* fireModeVar_net;
		if(!pl.weaponEquippedAkimbo){
			fireModeVar = &dynaRef.iFireMode;
			fireModeVar_net = &dynaRef.iFireMode_net;
		}else{
			fireModeVar = &dynaRef.iFireModeAkimbo;
			fireModeVar_net = &dynaRef.iFireModeAkimbo_net;
		}
		
		if( (*fireModeVar) == basicRef.iBitsFireModes){
			return;
		}
		
		//push the bits up until we get a match
		int originalChoice;
		int currentChoice;
		
		//little bit of filtering for safety
		if((*fireModeVar) <= 0 || (*fireModeVar) > 64){
			//Bad firemode value? Force the current to 1.
			//The original is 64, to just stop at the greatest bit possible
			//if nothing else is reached.
			originalChoice = 64;
			currentChoice = 1;
		}else{
			//safe!
			originalChoice = (*fireModeVar);
			currentChoice = originalChoice << 1;
		}
		
		while(currentChoice != originalChoice){
			if(currentChoice >= 64){ // (1 << 6)
				currentChoice = 1;  //reset from the other way.
				//This checks the bits starting from the beginning too.
			}
			
			if(basicRef.iBitsFireModes & currentChoice){
				//this power of 2 is a valid fireMode?  pick it
				(*fireModeVar) = currentChoice;
				
				#ifdef CLIENT
				// effectively SAVE_STATE on whatever choice
				(*fireModeVar_net) = currentChoice;
				#endif
				
				return;
			}
			
			currentChoice = currentChoice << 1;
		}
		
		//couldn't change? only fire mode... hopefully anyways.
	}// "is a gun" - check
	
}//_TS_playerChangeFiremode



#ifdef SERVER
// Server receives the message
void
CSEv_TS_playerUseItems_(void){
	_TS_playerUseItems();
}
#endif

// For now, only the client will expect direct calls to these.
// Client sends the input, server receives a message in response to perform things on its end too.
void
TS_playerUseItems(void){
	player pl = (player)self;
	if(pl.inventoryEquippedIndex == -1){
		return;
	}
#ifdef CLIENT
		sendevent("TS_playerUseItems", "");
		// and do it my side too?
		_TS_playerUseItems();
#else
		// SHOULD NOT HAPPEN, should call the CSEv_ version instead
#endif
}


// For making the lasersight & flashlights toggle on/off with the "n" key by default.  Cycle through the combos of
// off/on.
void
_TS_playerUseItems(void){
	player pl = (player)self;
	
	
	
	if(pl.inventoryEquippedIndex != -1){
	
		weapondynamic_t dynaRef = pl.ary_myWeapons[pl.inventoryEquippedIndex];
		
		if(dynaRef.weaponTypeID == WEAPONDATA_TYPEID_GUN || dynaRef.weaponTypeID == WEAPONDATA_TYPEID_IRONSIGHT){
			weapondata_basic_t* basicP = pl.getEquippedWeaponData();
			
			int legalBuyOpts = (dynaRef.iBitsUpgrade & (*basicP).iBitsUpgrade) & (BITMASK_WEAPONOPT_TOGGLEABLE);
			// We must have the flashlight bit on, AND support it on our weapon, AND it be a possibility according to weapon data.
			int legalBuyOpts_on = (dynaRef.iBitsUpgrade_on & legalBuyOpts);
			
			
			int bitCount = count1Bits(legalBuyOpts, BITMASK_WEAPONOPT_TOGGLEABLE_MIN, BITMASK_WEAPONOPT_TOGGLEABLE_MAX);
			int bitCount_on = count1Bits(legalBuyOpts_on, BITMASK_WEAPONOPT_TOGGLEABLE_MIN, BITMASK_WEAPONOPT_TOGGLEABLE_MAX);
			
			int firstBit;
			int firstBit_on;
			
			if(bitCount == 0){
				//no togglable buyopts at all?  I guess that's it.
			}else{
				
	
#if defined(CLIENT_CMD_SAFEMODE) && defined(CLIENT)
				// Have a much simpler version instead
				#ifdef CLIENT
					localsound("weapons/switch.wav", CHAN_AUTO, 1.0f);
				#endif
				return;
#endif
				
				
				if(bitCount == 1){
					//one bit available?  just toggle on/off then.
					if(bitCount_on){
						dynaRef.iBitsUpgrade_on = 0;
					}else{
						dynaRef.iBitsUpgrade_on = legalBuyOpts;
					}
					
					
				}else{
					//variable number of bits?  See how many bits are on right now.
					if(bitCount_on == 0){
						// No bits on?
						// Turn the first one on.
						firstBit = findFirst1Bit(legalBuyOpts, BITMASK_WEAPONOPT_TOGGLEABLE_MIN, BITMASK_WEAPONOPT_TOGGLEABLE_MAX);
						dynaRef.iBitsUpgrade_on |= firstBit;
					}else if(bitCount_on == 1){
						// If we're not the last bit, turn the next one on.
						// Start by looking at the next bit (bit << 1)
						firstBit_on = findFirst1Bit(legalBuyOpts, legalBuyOpts_on << 1, BITMASK_WEAPONOPT_TOGGLEABLE_MAX);
						
						if(firstBit_on != 0){
							//we'll take it!
							dynaRef.iBitsUpgrade_on = firstBit_on;
						}else{
							//ran out of available bits?  Take them all.
							dynaRef.iBitsUpgrade_on = legalBuyOpts;
						}
					}else{
						//more than 1?  Turn them all off then.
						dynaRef.iBitsUpgrade_on = 0;
					}
				}
				
				
				// Let's be a clientside sound only.
#ifdef CLIENT
				localsound("weapons/switch.wav", CHAN_AUTO, 1.0f);
#endif
				
				
				// (METHOD MADE SINCE: TS_Weapons_PlaySoundChannelDirect)
				
				// Any bits?  Play this sound, some change happened
				//sound(pl, CHAN_ITEM, "weapons/switch.wav", 1, ATTN_NONE, 100.0f, SOUNDFLAG_PLAYER_SHARED, 0);
				
				/*
				// unicast demo .  Why does the sound play clientside the first few times anyway?
				// It shouldn't ever, with the clientside-call here disabled.
#ifdef CLIENT
				//sound(pl, CHAN_ITEM, "weapons/switch.wav", 1, ATTN_NONE, 100.0f, SOUNDFLAG_NONE, 0);
#else
				sound(pl, CHAN_ITEM, "weapons/switch.wav", 1, ATTN_NONE, 100.0f, SOUNDFLAG_UNICAST, 0);
#endif
				*/
			}// bitcount checks
			
			
			
		}/// _GUN or _IRONSIGHT type checks
	}// weaponEquippedID check
	
	
	printfline("CSEv_TS_playerUseItems_");
}




#ifdef SERVER
// Server receives the message
void
CSEv_TS_playerUsePowerup_(void){
	_TS_playerUsePowerup();
}
#endif

// For now, only the client will expect direct calls to these.
// Client sends the input, server receives a message in response to perform things on its end too.
void
TS_playerUsePowerup(void){
	player pl = (player)self;
	if(pl.inventoryEquippedIndex == -1){
		return;
	}
#ifdef CLIENT
		sendevent("TS_playerUsePowerup", "");
		// and do it my side too?
		_TS_playerUsePowerup();
#else
		// SHOULD NOT HAPPEN, should call the CSEv_ version instead
#endif
}


// TODO.
// Applies the currently equipped player powerup if there is one.
void
_TS_playerUsePowerup(void){
	player pl = (player)self;
	
	// ...
	
	printfline("CSEv_TS_playerUsePowerup_");
}




#ifdef SERVER
// Server receives the message
void
CSEv_TS_playerCallAlt1_(void){
	_TS_playerCallAlt1();
}
#endif

// For now, only the client will expect direct calls to these.
// Client sends the input, server receives a message in response to perform things on its end too.
void
TS_playerCallAlt1(void){
	player pl = (player)self;
	if(pl.inventoryEquippedIndex == -1){
		return;
	}
#ifdef CLIENT
		sendevent("TS_playerCallAlt1", "");
		// and do it my side too?
		_TS_playerCallAlt1();
#else
		// SHOULD NOT HAPPEN, should call the CSEv_ version instead
#endif
}


// middle mouse wheel?  Use for some stunts, at least ones that don't necessarily involve being
// mid-air.
// double-tapping space does that.  I think?
void
_TS_playerCallAlt1( void ) {
	player pl = (player)self;
	
	// ...
	
	printfline("CSEv_TS_playerCallAlt1_");
}



#ifdef SERVER
// Server receives the message
void
CSEv_TS_playerCallAlt2_(void){
	_TS_playerCallAlt2();
}
#endif

// For now, only the client will expect direct calls to these.
// Client sends the input, server receives a message in response to perform things on its end too.
void
TS_playerCallAlt2(void){
	player pl = (player)self;
	if(pl.inventoryEquippedIndex == -1){
		return;
	}
#ifdef CLIENT
		sendevent("TS_playerCallAlt2", "");
		// and do it my side too?
		_TS_playerCallAlt2();
#else
		// SHOULD NOT HAPPEN, should call the CSEv_ version instead
#endif
}


// coldcock / weapon-melee?
void
_TS_playerCallAlt2(void){
	player pl = (player)self;
	printfline("CSEv_TS_playerCallAlt2_");
	
	weapondynamic_t dynaRef = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapondata_basic_t* basicP = pl.getEquippedWeaponData();
	if(basicP != NULL){
		(*basicP).funOnColdCock(pl, dynaRef);
	}else{
		// what.  how.
		printfline("WHAT.  HOW.");
	}
	
}




///////////////////////////////////////////////////////////////////////////////////////
// SERVER EVENTS ONLY BELOW HERE
#ifdef SERVER

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
// DEBUG STUFF?

void
CSEv_TS_Debug_getOrigin_(void ) {
	player pl = (player)self;
	if(pl != NULL){
		printfline("Client origin: %.1f %.1f %.1f", pl.origin.x, pl.origin.y, pl.origin.z);
	}else{
		printfline("ERROR: client null?");
	}
	
}

void
CSEv_TS_Debug_getAngle_(void ) {
	player pl = (player)self;
	if(pl != NULL){
		printfline("Client angles : %.1f %.1f %.1f", pl.angles.x, pl.angles.y, pl.angles.z);
		printfline("Client v_angle: %.1f %.1f %.1f", pl.v_angle.x, pl.v_angle.y, pl.v_angle.z);
	}else{
		printfline("ERROR: client null?");
	}
	
}



//NOTICE - these event methods are server-side only.
// anything in the "#ifdef S..." something. I dunno.
// The client sends a variety of messages at one time to the server to see if the player can really
// afford what they are requesting.  Secure... probably.


//TODO - PROTOTYPE THIS OR SET IT UP. whatever.
// Buys ammo of a certain type (ID), and ammount.
// Note that trying to exceed an ammo's max allowed ammount still caps at the ammmo's capacity.
// And if the player can't afford the ammount, the next greatest ammount to use the remaining money
// will be used instead.
void
CSEv_PlayerBuyAmmo_TS_i( int iAmmoTypeID, int iAmmoAmount ) {
	player pl = (player)self;
	
	//Using this new var for safety.
	int iActualAmmoAmount = iAmmoAmount;
	
	if(iAmmoTypeID != -1){
		ammodata_t ammoRef = *ary_ammoData[iAmmoTypeID];
		
		// iActualAmmoAmount must be between 0 and ammoRef.iMax, inclusive on both. If the player had
		// 0 ammo to begin with.
		if(pl.ary_ammoTotal[iAmmoTypeID] + iActualAmmoAmount > ammoRef.iMax){
			iActualAmmoAmount = ammoRef.iMax - pl.ary_ammoTotal[iAmmoTypeID];
		}
		if(iActualAmmoAmount <= 0){
			//iActualAmmoAmount = 0;
			//just stop, we aren't buying anything.
			return;
		}

		int ammoCost = (int)ceil(iActualAmmoAmount * ammoRef.fPricePerBullet);
		
		//11 / 16
		//want to buy 5.
		//but you have 36 dollars
		//each ammo costs 10 dollars.
		//
		//50 dollers... 
		// 36 >= 50. nope.
		//bulletsAfforded = floor(36 / 10)
		//bulletsAfforded = 3
		//11 +  3 is 14.
		//iActualAmmoAmount = 3 .
		
		//what if...
		//11 + 8 is 19.
		//11 + 8 = 19, > 16.
		//so...
		//iActualAmmoAmount = 16 - 11  (5)
		
		if(!bRule_MoneyAllowed || pl.money >= ammoCost){
			//afforded all of it. N ochange in iActualAmmoAmount.
		}else{
			//see what we can actually afford.
			int bulletsAfforded = floor(pl.money / ammoRef.fPricePerBullet);
			if(pl.ary_ammoTotal[iAmmoTypeID] + bulletsAfforded > ammoRef.iMax){
				//Even if we could afford more, we can't buy any more than the max allowed.
				//...not that this should be possible in this case.
				iActualAmmoAmount = ammoRef.iMax - pl.ary_ammoTotal[iAmmoTypeID];
			}else{
				//If buying this many bullets does not put us over the limit, go ahead.
				iActualAmmoAmount = bulletsAfforded;
			}
			//and so this is the new cost.
			ammoCost = iActualAmmoAmount * ammoRef.fPricePerBullet;
		}
		
		//At this point we are buying "iActualAmmoAmount".
		if(bRule_MoneyAllowed){
			pl.money -= ammoCost;
		}
		pl.ary_ammoTotal[iAmmoTypeID] += iActualAmmoAmount;
		
	}// iAmmoTypeID valid check
	
}// CSEv_PlayerBuyAmmo_TS_i



// This is used to signify that we're done sending weapon config over and want to pick a weapon to
// start equipped with.
// Order appears to be the highest slot number first, unless there is a weapon in slot 3 (small
// machine guns). Then it gets equipped instead.
void
CSEv_PlayerBuyWeapon_TS_end_( void ) {
	player pl = (player)self;
	
	printfline("CSEv_PlayerBuyWeapon_TS_end_");
	pl.completeInventorySend = TRUE;
	playerEquipIdeal(pl);
}

// Support upgrades, akimbo, etc. Include ammo if necessary!
// ACTUALLY... ammo will be signaled for purchase separately. The client still determines how much 
// ammo to buy though.
void
CSEv_PlayerBuyWeapon_TS_ii( int iWeaponTypeID, int iBuyOpts ) {
	player pl = (player)self;
	printf("Buying weaponTypeID:%i\n", iWeaponTypeID);
	
	attemptBuyWeapon(pl, iWeaponTypeID, iBuyOpts, 1);
}

// Version that takes a count of the weapon, since throwables stack in place.
void
CSEv_PlayerBuyWeaponThw_TS_iii( int iWeaponTypeID, int iBuyOpts, int iCount ) {
	player pl = (player)self;
	
	printf("Buying weaponTypeID (Thw):%i COUNT? %i\n", iWeaponTypeID, iCount);
	//printfline("HOW MUCH MONEY WE GOT %.2f invCount:%i", pl.money, pl.ary_myWeapons_softMax);
	//if ( Rules_BuyingPossible() == FALSE ) {
	//	return;
	//}
	
	//attemptAddWeaponToConfig(pl, iWeaponTypeID, iBuyOpts);
	attemptBuyWeapon(pl, iWeaponTypeID, iBuyOpts, iCount);
}
#endif// SERVER



// Goes through the available weapons and picks what would make sense to equip.
// SUGGESTION. Don't equip a weapon automatically if it's out of ammo,
// assuming we have an option that isn't out of ammo.
// MAJOR - check to see what place was previously selected, and then look to see where we can grab
// a new weapon if that changes things.
// That is, we have a few cases with special circumstances.
// If a singular version of an akimbo weapon was dropped, equip it's now singular version (1 of the
// two weapons left in inventory).
// I think that's it actually.
// nah, just check for that special case when dropping a weapon
void
playerEquipIdeal(player pl){
	// go through all the players weapons. whichever has the highest slot number, except for 5, gets picked
	int bestSlotYet = 0;
	weapondynamic_t weapon_DynaRef = NULL;
	int weaponDynamicID_toEquip = -1;
	int i;
	//printfline("playerEquipIdeal: invcount: %i", pl.ary_myWeapons_softMax);
	
	// work backwards, so the last item in a slot satisfies us
	for(i = pl.ary_myWeapons_softMax-1; i >= 0; i--){
		weapon_DynaRef = (weapondynamic_t) pl.ary_myWeapons[i];
		weapondata_basic_t* basicPointer = (weapondata_basic_t*) ary_weaponData[weapon_DynaRef.weaponID];
		weapondata_basic_t basicRef = *(basicPointer);

		BOOL hasAkimbo = FALSE;   //really only used if we bother to do this check.
		
		if(bestSlotYet <= 2){
			//check for akimbo...
			
			//hold on, do a few checks before we allow this.
			if((basicRef.iAkimboID > 0 && basicRef.iAkimboID < WEAPON_AKIMBO_UPGRADE_ID::LAST_ID ) && (weapon_DynaRef.iBitsUpgrade & BITS_WEAPONOPT_AKIMBO) && (basicRef.iBitsUpgrade & BITS_WEAPONOPT_AKIMBO) ){
				//yes.
				hasAkimbo = TRUE;
			}
		}

		//We also give a preference to weapons with akimbo.
		if(basicRef.iInventorySlot > bestSlotYet || (hasAkimbo) ){
			bestSlotYet = basicRef.iInventorySlot;
			weaponDynamicID_toEquip = i;
		}

	}// for loop through all inventory weapons

	// it is ok to blank the current weapon too (when _toEquip is -1)
	// The "TRUE" is for using akimbo, if the default weapon
	// we picked has it.  It's fine if not, then this does nothing.
	// Also, the shared version does not send a message to clientside to update the viewmodel,
	// this causes issues with the grenade removing itself on running out of ammo.
	// Throwing knives can use either version here though, but everything works with _shared.
	// Plus changes to what's serverside are sent to the client soon enough anyway, doing so
	// here seems unnecessary.
	// TODO, CRITICAL.  Check other places.
	// Could anywhere else benefit from TS_playerEquippedWeapon being changed to
	// TS_playerEquippedWeapon_Shared ?
	
	TS_playerEquippedWeapon_Shared(pl, weaponDynamicID_toEquip, TRUE);
	
}//playerEquipIdeal


// Call to above with a few extra lines included, commonly used so bundled into a method
void
playerEquipIdealSafe(player pl){
	TS_resetViewModel(pl);
	pl.setInventoryEquippedIndex(-1);
	playerEquipIdeal(pl);
	
	printfline("playerEquipIdealSafe: stats, activeWeap:%d invEqIndex:%i", pl.activeweapon, pl.inventoryEquippedIndex);
}

