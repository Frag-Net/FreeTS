


void TSWorldGun::TSWorldGun(void){
	
	accessibleCooldownTime = -1;
	myInfo = spawn(weapondynamic_t);
	
}


TSWorldGun TSWorldGun::generate(player arg_player, int arg_weaponID){
	weapondynamic_t dynaRefPRE = arg_player.ary_myWeapons[arg_weaponID];
	return TSWorldGun::generate2(arg_player, dynaRefPRE);
}
	
// Static method called from elsewhere to create and initialize a
// weapon drop entity, given a player and what weapon to copy information from.
TSWorldGun TSWorldGun::generate2(player arg_player, weapondynamic_t dynaRefPRE){
	TSWorldGun eDrop = spawn(TSWorldGun);
	
	//eDrop.setup(arg_player, arg_weaponID);
	
	//weapondynamic_t dynaRefPRE = arg_player.ary_myWeapons[arg_weaponID];
	weapondata_basic_t* basicPointerPRE = (weapondata_basic_t*) ary_weaponData[dynaRefPRE.weaponID];
	weapondata_basic_t basicRefPRE = *(basicPointerPRE);
	
	
	eDrop.movetype = MOVETYPE_TOSS;
	eDrop.solid = SOLID_TRIGGER; //or CORPSE
	
	//TSWorldGun eDrop = spawn(TSWorldGun);
	setorigin( eDrop, arg_player.origin + arg_player.view_ofs );
	setmodel( eDrop, basicRefPRE.sWorldModelPath );
	
	eDrop.angles = [0, randomInRange_f(0, 360), 0];
	eDrop.avelocity = [0, randomInRange_f(100, 500), 0];
	
	eDrop.classname = "remove_me";
	eDrop.owner = arg_player;
	//eDrop.weapon = dynaRefPRE.weaponID;
	eDrop.think = TSWorldGun::Think;
	eDrop.touch = TSWorldGun::Touch;
	eDrop.nextthink = time + 0.5f;
	
	eDrop.copyFrom2(arg_player, dynaRefPRE);
	
	//uhh..  ok, sure
	eDrop.health = 1;
	
	
	setsize( eDrop, '-16 -16 0', '16 16 16' );

//is this v_forward sometimes bad.. ?
	makevectors( arg_player.v_angle );

	eDrop.velocity = arg_player.velocity + v_forward * 320; //256?
	eDrop.gravity = 0.9;
	
	//And lastly, assume I need to expire at some point.
	eDrop.expireTime = time + autocvar_weaponstay;   //autocvar_weaponstay
	
	eDrop.PlayerUse = TSWorldGun::PlayerUse;
	
	
	return eDrop;
}//END OF generate



void TSWorldGun::copyFrom(player arg_player, int arg_weaponID){
	weapondynamic_t tempRef = arg_player.ary_myWeapons[arg_weaponID];
	copyFrom2(arg_player, tempRef);
}

// From what index in the player's inventory should I copy stats from?
// Called as we're being filled to be thrown from the player.
void TSWorldGun::copyFrom2(player arg_player, weapondynamic_t tempRef){
	
	//weapondynamic_t tempRef = arg_player.ary_myWeapons[arg_weaponID];
	
	
	COPYVARFROM(weaponID)
	COPYVARFROM(weaponTypeID)
	
	
	//COPYVARFROM(iBitsUpgrade)
	//actually want to exclude the AKIMBO and FULLLOAD bits. They were only for the shop really.
	myInfo.iBitsUpgrade = tempRef.iBitsUpgrade & ~(BITS_WEAPONOPT_AKIMBO | BITS_WEAPONOPT_FULLLOAD);
	
	//COPYVARFROM(iCount)
	weapondata_basic_t* weaponPointer = ary_weaponData[tempRef.weaponID];
	weapondata_basic_t basicRef = *((weapondata_basic_t*) weaponPointer);
	if(basicRef.typeID == WEAPONDATA_TYPEID_THROWABLE){
		//we're a throwable?  Send the count over.
		COPYVARFROM(iCount)
	}else{
		// Always a count of 1.  Any dropped weapon from akimbo is really just "one" of the two pickups needed.
		// Even weapons that only come in akimbo, like goldencolts, don't hurt by being called a count of "1".
		// They keep the same shop stats, which is really the point here.
		myInfo.iCount = 1;
	}
	
	
	
	COPYVARFROM(iPrice)	//who cares.
	//COPYVARFROM(iSlots)
	
	//re-calculate the slots now.
	myInfo.iSlots = myInfo.iCount * basicRef.iSlots;
	
	
	//Hold on... this isn't so simple.
	
	if(basicRef.typeID == WEAPONDATA_TYPEID_GUN || basicRef.typeID == WEAPONDATA_TYPEID_IRONSIGHT){
		if(basicRef.iBitsUpgradeAuto & BITS_WEAPONOPT_AKIMBO){
			//If the weapon we're spawned from is forced akimbo, the intuitive way works.
			//iClipLeft & iClipAkimboLeft can be filled, this is a singular drop to represent akimbo.
			COPYVARFROM(iClipLeft)
			COPYVARFROM(iClipAkimboLeft)
		}else if(basicRef.iBitsUpgrade & BITS_WEAPONOPT_AKIMBO && tempRef.iBitsUpgrade & BITS_WEAPONOPT_AKIMBO){
			//If the weapon supports akimbo and we have it, assume the thing dropped is the 2nd weapon. 
			//That is, the one tied to "iClipAkimboLeft".
			
			if(arg_player.weaponEquippedAkimbo){
				myInfo.iClipLeft = tempRef.iClipAkimboLeft;
				myInfo.iClipAkimboLeft = 0;
			}else{
				//oh.. drop the singular varient's ammo count then.
				myInfo.iClipLeft = tempRef.iClipLeft;
				myInfo.iClipAkimboLeft = 0;
			}
		}else{
			//not akimbo or doesn't support it?  Only this one.
			myInfo.iClipLeft = tempRef.iClipLeft;
			myInfo.iClipAkimboLeft = 0;
		}
		
	}else{
		//doesn't use these.
		myInfo.iClipLeft = 0;
		myInfo.iClipAkimboLeft = 0;
	}
	
	
	
	COPYVARFROM(iBitsUpgrade_on)
	COPYVARFROM(iFireMode)		//we can always copy both firemodes to any individual weapon, can't really hurt.
	COPYVARFROM(iFireModeAkimbo)
	//COPYVARFROM(iIronSight)
	
	COPYVARFROM(forceBodygroup1Submodel)
	
	myInfo.iIronSight = 0;   //default: not using it.
	
}//END OF copyFrom

// From what index in the player's inventory should I copy stats from?
// Called as we're being picked up by a player to fill one of their weapon slots.
void TSWorldGun::copyTo(player arg_player, int arg_weaponID){
	
	
	weapondynamic_t tempRef = arg_player.ary_myWeapons[arg_weaponID];
	
	COPYVARTO(weaponID)
	COPYVARTO(weaponTypeID)
	//COPYVARTO(iBitsUpgrade)
	//COPYVARTO(iCount)
	COPYVARTO(iPrice)  //no one cares.
	//COPYVARTO(iSlots)  //re-calculated.
	//COPYVARTO(iClipLeft)
	//COPYVARTO(iClipAkimboLeft)
	//COPYVARTO(iBitsUpgrade_on)
	//COPYVARTO(iFireMode)
	//COPYVARTO(iFireModeAkimbo)
	//COPYVARTO(iIronSight)
	COPYVARTO(forceBodygroup1Submodel)
	tempRef.iIronSight = 0;   //default: not using it.
	
}//END OF copyTo



void TSWorldGun::Touch( void ) {
	if ( other.classname != "player" ) {
		// assume it's the world.. play this sound?
		
		//printfline("the thing I touched is %s", other.classname);
		// TODO - any others we need to keep track of for making the drop?
		if(other.classname == "worldspawn" || other.classname == "func_breakable"){
			sound( this, CHAN_ITEM, "items/weapondrop1.wav", 1, ATTN_NORM, 100, SOUNDFLAG_CUSTOMCLIENT );
		}
		
		return;
	}
	
}//END OF touch method



void TSWorldGun::PlayerUse( void ) {
	
	//laziness.
	//entity other = eActivator;
	//...no, hides a global, not wise.
	other = eActivator;  //this however should be fine?
	
	// !!! IMPORTANT !!!
	// Want to be able to pick me up rapidly?  You have to remove this check too,
	// or setting the owner to "player" on generation.
	// This means the player that spawend me can't pick me up for a little while.
	// This is completely independent of accessibleCooldownTime, which prevents
	// all players from picking me up too soon instead.
	if ( other.classname != "player" ) {
		return;
	} else if ( other == this.owner ) {
		return;
	}
	
	//entity eOld = self;
	//TSWorldGun selfRef = (TSWorldGun)self;
	//self = other;
	
	player otherPlayerRef = (player)other;  //safe assumption now.
	
	
	BOOLEAN shouldDelete;
	if(time >= this.accessibleCooldownTime){
		shouldDelete = otherPlayerRef.attemptAddWeaponFromPickup(this);
		this.accessibleCooldownTime = time + 0.8;
	}else{
		shouldDelete = FALSE;
	}
	
	//self = eOld;
	if(shouldDelete){
		remove(this);
	}
}



void TSWorldGun::Think( void ) {
	//TSWorldGun selfRef = (TSWorldGun)self;
	// oh.. this makes the weapon collidable with the original dropper
	// again.
	
	if(time >= this.expireTime){
		//expire.
		remove(this);
	}else{
		this.owner = world;
		//set the next think to aim around this time then.
		this.nextthink = this.expireTime + 0.1;
	}
	
}


