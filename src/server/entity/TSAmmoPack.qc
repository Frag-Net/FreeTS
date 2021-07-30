
class TSAmmoPack{
	
	// After being recently accessed by a player but not deleted,
	// I enforce a cooldown time before any other player (including the same one)
	// can try to pick me up again. This stops spamming inventory scans every
	// single frame if a player stands over a weapon they can't pick up.
	float accessibleCooldownTime;
	// To avoid server clutter over time, a pickup will delete itself
	float expireTime;
	
	//myInfo
	int ary_ammoTotal[AMMO_ID::LAST_ID];
	
	
	void(void) TSAmmoPack;
	virtual void() Think;
	virtual void() Touch;
	virtual void() PlayerUse;
	static TSAmmoPack(player arg_player) generate;
	virtual void(player arg_player) copyFrom;
	virtual BOOLEAN(player arg_player) copyTo;
	
	
	//static Container_STR_ptr	*Event::commandList;
	
	
	/*
	// in-class constructor.
	void(void) TSAmmoPack = {
		// can do stuff here too.
	};
	*/
	/*
	// in-class method.
	virtual int (int arg1, int arg2) doMath = {
		return arg1 + arg2;
	};
	*/
	
	
};






static var int TSAmmoPack::testStaticVar = 0;



void TSAmmoPack::TSAmmoPack(void){
	
	
	accessibleCooldownTime = -1;
	
	for(int i = 0; i < AMMO_ID::LAST_ID; i++){
		ary_ammoTotal[i] = 0;  //safe default
	}
}


// Static method called from elsewhere to create and initialize a
// weapon drop entity, given a player and what weapon to copy information from.
TSAmmoPack TSAmmoPack::generate(player arg_player){
	TSAmmoPack eDrop = spawn(TSAmmoPack);
	
	
	TSAmmoPack::testStaticVar++;
	//printfline("AmmoPacks ever dropped: %i", testStaticVar);
	
	//eDrop.setup(arg_player, arg_weaponID);
	
	//TSAmmoPack eDrop = spawn(TSAmmoPack);
	setorigin( eDrop, arg_player.origin + arg_player.view_ofs );
	setmodel( eDrop, "models/ammopack.mdl");
	
	eDrop.classname = "remove_me";
	eDrop.owner = arg_player;
	eDrop.movetype = MOVETYPE_TOSS;
	eDrop.solid = SOLID_TRIGGER; //or CORPSE
	//eDrop.weapon = dynaRefPRE.weaponID;
	eDrop.think = TSAmmoPack::Think;
	eDrop.touch = TSAmmoPack::Touch;
	eDrop.nextthink = time + 0.5f;
	
	eDrop.copyFrom(arg_player);
	
	//uhh..  ok, sure
	eDrop.health = 1;
	
	setsize( eDrop, '-16 -16 0', '16 16 16' );

//is this v_forward sometimes bad.. ?
	makevectors( arg_player.v_angle );

	eDrop.velocity = arg_player.velocity + v_forward * 256;
	
	//And lastly, assume I need to expire at some point.
	eDrop.expireTime = time + autocvar_weaponstay;   //autocvar_weaponstay
	
	eDrop.PlayerUse = TSAmmoPack::PlayerUse;
	
	return eDrop;
}//END OF generate



// Pack all the player's ammo pools into me.
void TSAmmoPack::copyFrom(player arg_player){
	
	for(int i = 0; i < AMMO_ID::LAST_ID; i++){
		this.ary_ammoTotal[i] = arg_player.ary_ammoTotal[i];  //take it all.
		arg_player.ary_ammoTotal[i] = 0;
	}
	
}//END OF copyFrom

// Give this player my ammo pools, whatever will fit.
// Returns whether any ammo transaction happened (pretty likely)
BOOLEAN TSAmmoPack::copyTo(player arg_player){
	
		
	ammodata_t ammoRef;
	BOOLEAN anyAmmoTaken = FALSE;
	
	for(int i = 0; i < AMMO_ID::LAST_ID; i++){
		
		ammoRef = *ary_ammoData[i];
		//How much can I give to the player?
		
		
		//this.ary_ammoTotal[i] = arg_player.ary_ammoTotal[i];  //take it all.
		//arg_player.ary_ammoTotal[i] = 0;
		
		
		
		int amountToTake;
		int existingCount = arg_player.ary_ammoTotal[i];
		int pickupCount = this.ary_ammoTotal[i];
		
		if(existingCount + pickupCount <= ammoRef.iMax){
			//absorb it all.
			amountToTake = pickupCount;
		}else{
			//too much in the pickup?  this is ok, take as much as we can.
			amountToTake = ammoRef.iMax - existingCount;
		}
		
		if(amountToTake > 0){
			anyAmmoTaken = TRUE;
		}else{
			
		}
		
		arg_player.ary_ammoTotal[i] += amountToTake;
		//arg_pickupRef.myInfo.iCount -= amountToTake;
		
		this.ary_ammoTotal[i]-= amountToTake;
		
	}//END OF for loop through ammo types
	
	
	if(anyAmmoTaken){
		sound(arg_player, CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM, 100, SOUNDFLAG_CUSTOMCLIENT );
	}else{
		//sound( arg_player, CHAN_ITEM, "common/wpn_select.wav", 1, ATTN_NORM, 100, SOUNDFLAG_CUSTOMCLIENT );
	}
	
	return anyAmmoTaken;
}//END OF copyTo



void TSAmmoPack::Touch( void ) {
	if ( other.classname != "player" ) {
		// assume it's the world.. play this sound?
		
		//printfline("the thing I touched is %s", other.classname);
		// TODO - any others we need to keep track of for making the drop?
		if(other.classname == "worldspawn" || other.classname == "func_breakable"){
			sound( this, CHAN_ITEM, "items/weapondrop1.wav", 1, ATTN_NORM, 100, SOUNDFLAG_CUSTOMCLIENT );
		}
		
		return;
	}
	
	//entity eOld = self;
	//TSAmmoPack selfRef = (TSAmmoPack)self;
	//self = other;
	
	player otherPlayerRef = (player)other;  //safe assumption now.
	
	BOOLEAN shouldDelete;
	if(time >= this.accessibleCooldownTime){
		shouldDelete = copyTo(otherPlayerRef);
		this.accessibleCooldownTime = time + 0.8;
	}else{
		shouldDelete = FALSE;
	}
	
	//self = eOld;
	if(shouldDelete){
		remove(this);
	}
	
	
	
	
}//END OF touch method



void TSAmmoPack::PlayerUse( void ) {
	
}



void TSAmmoPack::Think( void ) {
	//TSAmmoPack selfRef = (TSAmmoPack)self;
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


