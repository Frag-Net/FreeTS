
// NOTE - this was not a type in the original TS, just seemed convenient to make.

// This is meant to be spawned by a player throwing a knife.
// It starts with its own behavior (hurt a non-owner I touch, or stick to / bounce-off whatever
// isn't a player), and switches over to pickup behavior after it stops being dangerous.




void TSThrownProjectile::TSThrownProjectile(void){
	TSWorldGun::TSWorldGun();
	
	startAngularVelocityDelay = -1;
	//vPreviousVelocity = vecZero;
	forceBecomePickupableTime = -1;
	queuedVelocity = vecZero;
	queuedVelocityApplyTime = -1;
	switchToNormalPickupBoundsTime = -1;
	
}


TSThrownProjectile TSThrownProjectile::generate(player arg_player, int arg_weaponID){
	weapondynamic_t dynaRefPRE = arg_player.ary_myWeapons[arg_weaponID];
	return TSThrownProjectile::generate2(arg_player, dynaRefPRE);
}
	
// Static method called from elsewhere to create and initialize a
// weapon drop entity, given a player and what weapon to copy information from.
TSThrownProjectile TSThrownProjectile::generate2(player arg_player, weapondynamic_t dynaRefPRE){
	TSThrownProjectile eDrop = spawn(TSThrownProjectile);
	
	//eDrop.setup(arg_player, arg_weaponID);
	
	//weapondynamic_t dynaRefPRE = arg_player.ary_myWeapons[arg_weaponID];
	weapondata_basic_t* basicPointerPRE = (weapondata_basic_t*) ary_weaponData[dynaRefPRE.weaponID];
	weapondata_basic_t basicRefPRE = *(basicPointerPRE);
	weapondata_throwable_t throwableRef = *((weapondata_throwable_t*)basicPointerPRE);
	
	
	makevectors( arg_player.v_angle );
	
	eDrop.movetype = MOVETYPE_BOUNCE;
	eDrop.solid = SOLID_TRIGGER; //or CORPSE
	
	setorigin( eDrop, arg_player.origin + arg_player.view_ofs + v_forward * 16 );
	setmodel( eDrop, basicRefPRE.sWorldModelPath );
	
	
	//printfline("TSThrownProjectile::generate2 v_up: %.2f %.2f %.2f", v_up.x, v_up.y, v_up.z);
	vector old_v_up = v_up;
	
	//eDrop.velocity = arg_player.velocity + v_forward * 256;
	// relying on the 'makevectors' call from earlier!
	vector vDir = aim ( arg_player, 100000 );
	//eDrop.velocity = ( arg_player.velocity + vDir * throwableRef.fThrowSpeed );
	// we'll let player velocity influence the knives a little..
	eDrop.velocity = ( arg_player.velocity*0.4 + vDir * throwableRef.fThrowSpeed );
	
	
	//modify the vector we send a bit...
	//-70 ?
	//[-90, -90, 0]
	rotatevectorsbyangle([-70, 0, 0]);
	
	// or "v_dir" from later?
	eDrop.angles = vectoangles( v_forward );
	eDrop.angles.z = 90;
	
	eDrop.classname = "remove_me";
	
	// Also set m_owner
	eDrop.owner = arg_player;
	eDrop.m_owner = eDrop.owner;
	
	
	eDrop.touch = TSThrownProjectile::Touch;
	eDrop.think = TSThrownProjectile::Think;
	eDrop.nextthink = time + 0.0;  //every frame.
	
	//eDrop.PlayerUse = TSWorldGun::PlayerUse;
	// "use" does nothing to me... yet.
	eDrop.PlayerUse = NULL;
	
	eDrop.gravity = throwableRef.fThrowGravity;
	
	
	eDrop.copyFrom2(arg_player, dynaRefPRE);
	
	//uhh..  ok, sure
	eDrop.health = 1;
	
	
	// TAGGG - NOTE.
	// Somewhere above 1.4?  sticks a foot out of the wall (floating in space; none of the knife is in it)
	// Somewhere at/below 1.4?	stuck too far in the wall.
	// So we'll need a traceline to get right against the thing we collided with?
	// AND still, throwing at glass doesn't work quite perfect either way.
	// With undersized bounds, it registers as a hit on the glass but is also stopped
	// by the glass, like grenades are...
	// with oversized bounds,  the game thinks we hit the map first anyway (reported entity hit:
	// 'worldpspawn') even though destroying the glass separately and throwing again has no 
	// collision at all in that space, leading me to believe it collided with the glass but called
	// it worldspawn anyway.
	// W.  H.  A.   T.
	//TAGGG - TODO.  then. apparently.
	//setsize( eKnife, '-1.7 -1.7 -1.7', '1.7 1.7 1.7' );
	//setsize( eKnife, '-1.4 -1.4 -1.4', '1.4 1.4 1.4' );
	//setsize( eKnife, '-1 -1 -1', '1 1 1' );
	setsize( eDrop, '-1 -1 0', '1 1 1' );
	
	//setsize( eDrop, '-16 -16 0', '16 16 16' );
	

	//And lastly, assume I need to expire at some point.
	// Expires 10 seconds after becoming a pickup.  But just in case it never
	// does for some odd reason, no business existing too long anyway.
	eDrop.expireTime = time + 30;
	
	//eDrop.vPreviousVelocity = eDrop.velocity;
	
	eDrop.startAngularVelocityDelay = time + 0.008;  //0.013?
	
	eDrop.bouncefactor = 0.2;
	eDrop.friction = 0.78;
	
	return eDrop;
}//END OF generate


void TSThrownProjectile::becomePickupable(BOOL becomeStuck, optional vector dir, optional entity stuckTo, optional BOOL touchedBreakableGlass){
	
	forceBecomePickupableTime = -1;
	
	//in a short while, switch to normal bounds.
	if(switchToNormalPickupBoundsTime == -1){
		switchToNormalPickupBoundsTime = time + 0.7;
	}
	
	
	if(becomeStuck){
		/*
		makevectors( normalize(this.velocity) );
		//rotatevectorsbyangle([-70, 0, 0]);
		// or "v_dir" from later?
		this.angles = vectoangles(v_forward);
		*/
		if ( touchedBreakableGlass ) {
			//no!  Go through it.
			// this means, insta-break the breakable glass we hit.
			
			Damage_Apply( other, this.m_owner, other.health, myInfo.weaponID, DMG_SLASH);
			queuedVelocity = this.velocity;
			queuedVelocityApplyTime = time + 0.01;
			return;  //don't do the rest of this method.
		}else{
			//stuck as planned.
			this.angles = vectoangles(normalize(this.velocity));
			this.angles.z = 90;
			this.velocity = [0,0,0];
			startAngularVelocityDelay = -1;  //if we haven't reached this, certianly don't try to!
			
			// assume we can trust trace_endpos.
			this.origin = trace_endpos - dir * 5.9;
			//this.origin -= dir * 5.9;
			this.movetype = MOVETYPE_FLY;
		}
	}else{
		//safe assumption?
		//this.angles.x = 0;
		this.angles.z = 0;
		this.gravity = 0.9;
	}
	
	
	// don't make the weapon drop noises.  that is all.
	//this.touch = TSWorldGun::Touch;
	this.touch = NULL;
	
	this.PlayerUse = TSWorldGun::PlayerUse;
	
	// not yet freeman!
	//this.think = TSWorldGun::Think;
	//this.nextthink = time + 0.2f;
	
	//this.expireTime = time + autocvar_weaponstay;
	// for some reason knives always expire in X seconds.
	// probably ok in case a bunch of players throw knives in a short timespan,
	// don't want to spam it up.
	this.expireTime = time + 30;
	this.avelocity = [0,0,0];
	
}//END OF becomePickupable


void TSThrownProjectile::copyFrom(player arg_player, int arg_weaponID){
	weapondynamic_t tempRef = arg_player.ary_myWeapons[arg_weaponID];
	copyFrom2(arg_player, tempRef);
}

// From what index in the player's inventory should I copy stats from?
// Called as we're being filled to be thrown from the player.
void TSThrownProjectile::copyFrom2(player arg_player, weapondynamic_t tempRef){
	
	//weapondynamic_t tempRef = arg_player.ary_myWeapons[arg_weaponID];
	
	COPYVARFROM(weaponID)
	COPYVARFROM(weaponTypeID)
	
	//COPYVARFROM(iBitsUpgrade)
	//actually want to exclude the AKIMBO and FULLLOAD bits. They were only for the shop really.
	myInfo.iBitsUpgrade = tempRef.iBitsUpgrade & ~(BITS_WEAPONOPT_AKIMBO | BITS_WEAPONOPT_FULLLOAD);
	
	//COPYVARFROM(iCount)
	weapondata_basic_t* weaponPointer = ary_weaponData[tempRef.weaponID];
	weapondata_basic_t basicRef = *((weapondata_basic_t*) weaponPointer);
	
	// only one throwable is 'thrown' at a time ever.
	myInfo.iCount = 1;
	
	
	COPYVARFROM(iPrice)	//who cares.
	//COPYVARFROM(iSlots)
	
	//re-calculate the slots now.
	myInfo.iSlots = myInfo.iCount * basicRef.iSlots;
	
	
	//doesn't use these.  We're a throwable.
	myInfo.iClipLeft = 0;
	myInfo.iClipAkimboLeft = 0;
	
	
	COPYVARFROM(iBitsUpgrade_on)
	COPYVARFROM(iFireMode)
	COPYVARFROM(iFireModeAkimbo)
	//COPYVARFROM(iIronSight)
	
	COPYVARFROM(forceBodygroup1Submodel)
	
	myInfo.iIronSight = 0;   //default: not using it.
	
}//END OF copyFrom

// From what index in the player's inventory should I copy stats from?
// Called as we're being picked up by a player to fill one of their weapon slots.
void TSThrownProjectile::copyTo(player arg_player, int arg_weaponID){
	
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


void TSThrownProjectile::Touch( void ) {
	
	if ( other.solid == SOLID_TRIGGER ) {
		return;
	}
	if ( other == this.owner ) {
		return;
	}
	
	// func_water has "other.solid == SOLID_BSP" but is still pass-thru-able??
	// WTF DO I DO.
	// TAGGG - CRITICAL. - when done, get new findings over to the grenade too, other throwable.
	if(other.solid == SOLID_NOT || other.solid == SOLID_TRIGGER || other.classname == "func_water"){
		//ok?  don't react.
		return;
	}
	
	vector dir = normalize(this.velocity);
	// was 15 each??
	
	//HACKY TEST
	//printfline("knife vel %.2f %.2f %.2f", velocity.x, velocity.y, velocity.z);
	
	
	vector src = this.origin - this.velocity*0.06;
	vector end = this.origin + this.velocity*0.06;
	traceline(src, end, MOVE_HITMODEL, this);
	
	//printfline("TRACEFRACTO %.2f", trace_fraction);
	if(trace_fraction == 1){
		//WTF???  all we can do.
		trace_endpos = this.origin;
	}
	
	//TAGGG - TODO.  Use the trace from further below's point of intersection instead of
	// "this.origin", mabey this will help..?
	//string hitTexture = getsurfacetexture(other, getsurfacenearpoint(other, this.origin));
	string hitTexture = getsurfacetexture(other, getsurfacenearpoint(other, trace_endpos));
	
	printfline("TSThrownProjectile::Touch I TOUCHED %s solid:%d neartex:%s", other.classname, other.solid, hitTexture);
	
	if(TRUE){
		//stop on anything else.
		// TODO - delete this on hitting a player other than the owner (not that this should even cause
		// a touch event then)   and just stay stuck to any other thing, like map geometry.
		
		BOOL touchedBreakableGlass = (( other.classname == "func_breakable" ) && ( other.material == GSMATERIAL_GLASS ));
		
		
		if(other == world || other.classname == "func_wall" || touchedBreakableGlass){
			//okie, get stuck.
			//TAGGG - TODO.  Spark effect!
			
			/* FIXME: more universal check? */
			//...yea there are obvious cases where this fails.
			//TAGGG - CRITICAL.  HOW DO I FIX THIS.  knivees can just get stuck on the skybox
			// still from the nearest texture not being 'sky'.
			
			if (hitTexture == "sky") {
				//printfline("Knife: I DONE WENT OUT OF BOUNDS");
				remove(this);
				return;
			}
			
			//notice, ATTN_NORM.  Sound goes further.,
			sound( this, CHAN_WEAPON, "weapons/knife/knife_hit.wav", 1, ATTN_NORM - 0.15 );
			
			
			//printfline("trace_fraction %.2f", trace_fraction);
			
			// Do we get stuck or bounce off?
			if(trace_fraction != 1.0){
				float theProd = dotproduct(dir, trace_plane_normal);
				//printfline("WHAT THE hek IS THIS %.2f", theProd);
				
				if(theProd <= -0.73){
					//close to being opposites?  be stuck	
					becomePickupable(TRUE, dir, other, touchedBreakableGlass);
				}else{
					
					//Did we hit the ground?
					float dotIsGround = dotproduct(trace_plane_normal, '0 0 1');
					//printfline("AM I GROUND %.2f", dotIsGround);
					if(dotIsGround >= 0.91){
						
						//printfline("IM A proud TREE dandy FROG %.2f", this.velocity.z);
						if(this.velocity.z <= -260){
							//Going downards much? Get stuck in the ground.
							// Hack to look like it's more downwards into the ground.
							this.velocity.x *= 0.18;
							this.velocity.y *= 0.18;
							becomePickupable(TRUE, dir, other, touchedBreakableGlass);
						}else{
							//Bounce off the ground instead.
							becomePickupable(FALSE);
							//setsize( this, '-16 -16 0', '16 16 16' );
							
							this.angles.x = 0;  //go flat as you fall off.
							this.velocity = [this.velocity.x * 0.09, this.velocity.y * 0.09, this.velocity.z];
							this.movetype = MOVETYPE_BOUNCE;
						}
						
						//TODO - what is "bouncestop" ??
						//printfline("GIMMIE DA STATS %.2f %.2f %.2f", mass, bouncestop, bouncefactor);
						
					}else{
						this.movetype = MOVETYPE_BOUNCE;
						
						//no?  just keep going, probably.
						forceBecomePickupableTime = time + 1;
						
						// thank you w_gauss.c!
						float n = -dotproduct(trace_plane_normal, dir);
						vector reflectedVel = vlen(this.velocity) * (2 * trace_plane_normal * n + dir);
						
						// yes.  we have to do this.  Thanks, engine.
						this.origin += trace_plane_normal * 2;
						setorigin(this, this.origin);
						queuedVelocity = [reflectedVel.x * 0.8, reflectedVel.y * 0.8, reflectedVel.z];
						if(queuedVelocity.z > 0){
							//positive? reduce it a bit.
							queuedVelocity.z *= 0.85;
						}
						queuedVelocityApplyTime = time + 0.01;
						
						// hold up!  Angles?
						
						vector daAngah = vectoangles(normalize(queuedVelocity));
						
						int oldPitch = angles.x;
						
						this.angles = daAngah;
						
						this.angles.x = oldPitch;
						this.angles.z = 90;
						
					}
					
					
				}
				
			}else{
				//???  just assume sticking out this much is ok.
				// assume stuck.
				becomePickupable(TRUE, dir, other, touchedBreakableGlass);
			}
			
			
			//setsize( this, '-16 -16 0', '16 16 16' );
		}else{
			
			printfline("TSThrownProjectile::Touch HIT ENTITY? WHATS IT CALLED %s TAKEDAMAGE? %d", other.classname, other.takedamage);
			//is it something we can deal damage to?
			if(other.takedamage == DAMAGE_YES){
				
				//is it fleshy?  eh, assume it is.
				//there is always a "trace_ent.iBleeds" check though.
				sound( this, CHAN_WEAPON, "weapons/knife/knife_hitbody.wav", 1, ATTN_IDLE );
				
				weapondata_basic_t* basicPointerPRE = (weapondata_basic_t*) ary_weaponData[this.myInfo.weaponID];
				//weapondata_basic_t basicRefPRE = *(basicPointerPRE);
				weapondata_throwable_t throwableRef = *((weapondata_throwable_t*)basicPointerPRE);
				
				// tell the thing being damaged that my OWNER was what damaged it.
				Damage_Apply(other, this.m_owner, throwableRef.fThrowDamage, myInfo.weaponID, DMG_SLASH);
				
				remove(this);
				return;
			}else{
				//oh. bounce off I guess.
				//TAGGG - TODO.  Spark effect!
				//TODO - bounce the opposite direction floor-wise?
				sound( this, CHAN_WEAPON, "weapons/knife/knife_hit.wav", 1, ATTN_NORM - 0.15 );
				
				becomePickupable(FALSE);
				//setsize( this, '-16 -16 0', '16 16 16' );
				
				this.angles.x = 0;  //go flat as you fall off.
				this.velocity = [this.velocity.x * 0.24, this.velocity.y * 0.24, this.velocity.z];
				this.movetype = MOVETYPE_BOUNCE;
				
			}
		}
		//this.touch = NULL;   //no more responses.
	}
	
	
}//END OF touch method



void TSThrownProjectile::PlayerUse( void ) {
	//EMPTY.  Use TSWorldGun's PlayerUse once we dropped,
	// OR have logic that redirects to that in here when we want to make this pickup-able.
	// Whichever works.
}


void TSThrownProjectile::Think( void ) {
	
	if(this.startAngularVelocityDelay != -1 && time >= this.startAngularVelocityDelay){
		this.startAngularVelocityDelay = -1;
		this.avelocity = [360 * 2.7, 0, 0];
	}
	
	if(forceBecomePickupableTime != -1 && time >= forceBecomePickupableTime){
		//check. are we moving too slow?  keep rechecking after.
		forceBecomePickupableTime = time + 1;
		if(vlen(velocity) < 8){
			//ok.
			forceBecomePickupableTime = -1;
			becomePickupable(FALSE);
			//setsize( this, '-16 -16 0', '16 16 16' );
			
			this.angles.x = 0;  //go flat as you fall off.
			this.velocity = [this.velocity.x * 0.07, this.velocity.y * 0.07, this.velocity.z];
			this.movetype = MOVETYPE_BOUNCE;
			
		}
	}
	
	if(queuedVelocityApplyTime != -1 && time >= queuedVelocityApplyTime){
		queuedVelocityApplyTime = -1;
		this.velocity = queuedVelocity;
	}
	
	
	if(time >= expireTime){
		// that's the end.
		remove(self);
		return;
	}
	
	if(switchToNormalPickupBoundsTime >= 0 && time >= switchToNormalPickupBoundsTime){
		switchToNormalPickupBoundsTime = -2;   //to not try this again.
		// and resume the normal think method.
		setsize( this, '-16 -16 0', '16 16 16' );
		this.think = TSWorldGun::Think;
		this.nextthink = time + 0.01f;
		//printfline("OH YEAHHHHHHHHhhhhh");
		return;
	}
	
	//this.vPreviousVelocity = this.velocity;
	this.nextthink = time + 0.0;
}


