
void
CTSWorldGun::CTSWorldGun(void)
{
	accessibleCooldownTime = -1;
	myInfo = spawn(weapondynamic_t);
	
}


CTSWorldGun
CTSWorldGun::generate(player arg_player, int arg_weaponID)
{
	weapondynamic_t dynaRefPRE = arg_player.ary_myWeapons[arg_weaponID];
	return CTSWorldGun::generate2(arg_player, dynaRefPRE);
}
	
// Static method called from elsewhere to create and initialize a
// weapon drop entity, given a player and what weapon to copy information from.
CTSWorldGun
CTSWorldGun::generate2(player arg_player, weapondynamic_t dynaRefPRE)
{
	CTSWorldGun eDrop = spawn(CTSWorldGun);
	
	//eDrop.setup(arg_player, arg_weaponID);
	
	//weapondynamic_t dynaRefPRE = arg_player.ary_myWeapons[arg_weaponID];
	weapondata_basic_t* basicP = ary_weaponData[dynaRefPRE.weaponID];
		
	eDrop.movetype = MOVETYPE_TOSS;
	eDrop.solid = SOLID_TRIGGER; //or CORPSE
	
	//CTSWorldGun eDrop = spawn(CTSWorldGun);
	setorigin( eDrop, arg_player.origin + arg_player.view_ofs );
	setmodel( eDrop, basicP->sWorldModelPath );
	
	eDrop.angles = [0, randomInRange_f(0, 360), 0];
	eDrop.avelocity = [0, randomInRange_f(100, 500), 0];
	
	eDrop.classname = "remove_me";
	eDrop.owner = arg_player;
	//eDrop.weapon = dynaRefPRE.weaponID;
	eDrop.think = CTSWorldGun::Think;
	eDrop.touch = CTSWorldGun::Touch;
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
	
	eDrop.PlayerUse = CTSWorldGun::PlayerUse;
	
	
	return eDrop;
}// generate



void
CTSWorldGun::copyFrom(player arg_player, int arg_weaponID)
{
	weapondynamic_t tempRef = arg_player.ary_myWeapons[arg_weaponID];
	copyFrom2(arg_player, tempRef);
}

// From what index in the player's inventory should I copy stats from?
// Called as we're being filled to be thrown from the player.
void
CTSWorldGun::copyFrom2(player arg_player, weapondynamic_t tempRef)
{
	
	//weapondynamic_t tempRef = arg_player.ary_myWeapons[arg_weaponID];
	
	myInfo.weaponID = tempRef.weaponID;
	myInfo.weaponTypeID = tempRef.weaponTypeID;
	
	//actually want to exclude the AKIMBO and FULLLOAD bits. They were only for the shop really.
	myInfo.iBitsUpgrade = tempRef.iBitsUpgrade & ~(BITS_WEAPONOPT_AKIMBO | BITS_WEAPONOPT_FULLLOAD);
	
	weapondata_basic_t* basicP = ary_weaponData[tempRef.weaponID];
	if(basicP->typeID == WEAPONDATA_TYPEID_THROWABLE){
		//we're a throwable?  Send the count over.
		myInfo.iCount = tempRef.iCount;
	}else{
		// Always a count of 1.  Any dropped weapon from akimbo is really just "one" of the two pickups needed.
		// Even weapons that only come in akimbo, like goldencolts, don't hurt by being called a count of "1".
		// They keep the same shop stats, which is really the point here.
		myInfo.iCount = 1;
	}
	
	// Not important to really preserve through any changes as far as I know
	myInfo.iPrice = tempRef.iPrice;
	// re-calculate the slots
	myInfo.iSlots = myInfo.iCount * basicP->iSlots;
	
	//Hold on, this isn't so simple.
	if(basicP->typeID == WEAPONDATA_TYPEID_GUN || basicP->typeID == WEAPONDATA_TYPEID_IRONSIGHT){
		if(basicP->iBitsUpgradeAuto & BITS_WEAPONOPT_AKIMBO){
			//If the weapon we're spawned from is forced akimbo, the intuitive way works.
			//iClipLeft & iClipAkimboLeft can be filled, this is a singular drop to represent akimbo.
			myInfo.iClipLeft = tempRef.iClipLeft;
			myInfo.iClipAkimboLeft = tempRef.iClipAkimboLeft;
		}else if(basicP->iBitsUpgrade & BITS_WEAPONOPT_AKIMBO && tempRef.iBitsUpgrade & BITS_WEAPONOPT_AKIMBO){
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
	
	
	
	myInfo.iBitsUpgrade_on = tempRef.iBitsUpgrade_on;
	myInfo.iFireMode = tempRef.iFireMode;		//we can always copy both firemodes to any individual weapon, can't really hurt.
	myInfo.iFireModeAkimbo = tempRef.iFireModeAkimbo;
	
	myInfo.iForceBodygroup1Submodel = tempRef.iForceBodygroup1Submodel;
	myInfo.bNeedsPump = tempRef.bNeedsPump;
	
	myInfo.iIronSight = 0;   //default: not using it.
	
}// copyFrom

// From what index in the player's inventory should I copy stats from?
// Called as we're being picked up by a player to fill one of their weapon slots.
void
CTSWorldGun::copyTo(player arg_player, int arg_weaponID)
{
	
	weapondynamic_t tempRef = arg_player.ary_myWeapons[arg_weaponID];
	
	tempRef.weaponID = myInfo.weaponID;
	tempRef.weaponTypeID = myInfo.weaponTypeID;
	
	// ?
	tempRef.iPrice = myInfo.iPrice;
	
	tempRef.iForceBodygroup1Submodel = myInfo.iForceBodygroup1Submodel;
	tempRef.bNeedsPump = myInfo.bNeedsPump;
	
	tempRef.iIronSight = 0;   //default: not using it.
	
}// copyTo



void
CTSWorldGun::Touch(void)
{
	if ( other.classname != "player" ) {
		// assume it's the world.. play this sound?
		
		//printfline("the thing I touched is %s", other.classname);
		// TODO - any others we need to keep track of for making the drop?
		if(other.classname == "worldspawn" || other.classname == "func_breakable"){
			sound( this, CHAN_ITEM, "items/weapondrop1.wav", 1, ATTN_NORM, 100, SOUNDFLAG_FOLLOW );
		}
		
		return;
	}
	
}// touch method



void
CTSWorldGun::PlayerUse(void)
{
	
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
	//CTSWorldGun selfRef = (CTSWorldGun)self;
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



void
CTSWorldGun::Think(void)
{
	//CTSWorldGun selfRef = (CTSWorldGun)self;
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


