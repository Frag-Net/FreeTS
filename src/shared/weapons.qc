

weapon_t w_null = {};

// Populate each slot with a member of the enum early on in runtime instead.
weapon_t g_weapons[WEAPON_ID::LAST_ID];

// Not needed here anymore?
//var int g_weapon_weights[g_weapons.lengdth];


void
weaponconfig_data_init(weaponconfig_data_t* arg_this){
	arg_this->ary_myWeapons_softMax = 0;
	for(int i = 0; i < AMMO_ID::LAST_ID; i++){
		arg_this->ary_ammoTotal[i] = 0;
	}
	arg_this->iTotalSlots = 0;
	arg_this->iTotalPrice = 0;
	
	// Not a class, no need for this anymore.
	// Any need to run init-calls on each one to set things to 0?
	// That was never needed before at least.
	/*
	for(int i = 0; i < ary_myWeapons_length; i++){
		ary_myWeapons[i] = spawn(weaponconfig_weapon_t);
	}
	*/
	
}// weaponconfig_data_t constructor


void
weapon_base_setWholeAttackDelay(player pl, float amount){
	pl.w_attack_next = amount;
	pl.w_attack_akimbo_next = amount;
	
	// I think this is a good idea, right?
	// or, is only for the client better?  Turned out to be the case somewhere else...
	//#ifdef SERVER
	//SAVE_STATE(pl.w_attack_next);
	//SAVE_STATE(pl.w_attack_akimbo_next);
	//#endif
}// weapon_base_setWholeAttackDelay


// normal delay only?
void
weapon_base_setLeftAttackDelay(player pl, float amount){
	pl.w_attack_next = amount;
	//SAVE_STATE(pl.w_attack_next);
}

// akimbo secondary delay only?
void
weapon_base_setRightAttackDelay(player pl, float amount){
	pl.w_attack_akimbo_next = amount;
	//SAVE_STATE(pl.w_attack_akimbo_next);
}



// Only set the delay if it is below the given amount.
// If there are 2 seconds left until firing is allowed, ignore a request
// to set it to 0.3 seconds.
void
weapon_base_setLeftAttackDelay_AtLeast(player pl, float amount){
	if(pl.w_attack_next <= amount){
		pl.w_attack_next = amount;
		//SAVE_STATE(pl.w_attack_next);
	}
}

// akimbo secondary delay only?
void
weapon_base_setRightAttackDelay_AtLeast(player pl, float amount){
	if(pl.w_attack_akimbo_next <= amount){
		pl.w_attack_akimbo_next = amount;
		//SAVE_STATE(pl.w_attack_akimbo_next);
	}
}


MELEE_HIT_RESPONSE
weapon_base_coldcock(
	player pl, weapondata_basic_t* basePRef, weapondynamic_t arg_thisWeapon,
	float damageToDeal, float range
){
	MELEE_HIT_RESPONSE resultHit = MELEE_HIT_RESPONSE::NONE;
#ifdef SERVER
	weapondata_basic_t baseRef = *basePRef;
	makevectors( GET_VIEW_ANGLES );
	
	vector vSource = (pl.origin + pl.view_ofs);
	traceline(vSource, vSource + (v_forward * range), MOVE_HITMODEL, pl);
	
	if ( trace_fraction == 1.0 ) {
		//did not hit anything
		return MELEE_HIT_RESPONSE::NONE;
	}else{
		// ?   For what purpose now?
		//vOrigin = trace_endpos - vTraceDirection * 2;

		if ( trace_ent.takedamage ) {
			if ( trace_ent.iBleeds == TRUE ) {
				//TAGGG - TODO, CHECK.  Do FX_Impact parameters still line up with this.
				FX_Impact( IMPACT_FLESH, trace_endpos, trace_plane_normal );
				resultHit = MELEE_HIT_RESPONSE::FLESH;
			}else{
				// assume metal then?
				resultHit = MELEE_HIT_RESPONSE::METAL;
			}
			Damage_Apply( trace_ent, pl, damageToDeal, (int)pl.activeweapon, DMG_BLUNT);
		} else {
			resultHit = MELEE_HIT_RESPONSE::NONE;
		}
	}
	
#endif

	return resultHit;
}//weapon_base_coldcock


MELEE_HIT_RESPONSE
weapon_base_onPrimaryAttack_melee(
	player pl, weapondata_basic_t* basePRef, weapondynamic_t arg_thisWeapon,
	float damageToDeal, float range
){
	makevectors( GET_VIEW_ANGLES );
	return weapon_base_onPrimaryAttack_melee_fromCustomDirection(pl, basePRef, arg_thisWeapon, damageToDeal, range, v_forward);
}// weapon_base_onPrimaryAttack_melee

// After the server calls this method (possibly client later?),
// we expect trace_ent to store the thing we recently hit for playing custom sounds.
// Anything that doesn't want the general material-hit sounds / sparks on hitting metalic/generic stuff
// should not use this method, just copy it and work as needed (looking at you karate).
MELEE_HIT_RESPONSE
weapon_base_onPrimaryAttack_melee_fromCustomDirection(
	player pl, weapondata_basic_t* basePRef, weapondynamic_t arg_thisWeapon,
	float damageToDeal, float range, vector vTraceDirection
){
	MELEE_HIT_RESPONSE resultHit = MELEE_HIT_RESPONSE::NONE;
	
#ifdef SERVER
	// safe default in case this method finds nothing.
	// Might be unnecessary to do this?
	trace_ent = NULL;
	
	weapondata_basic_t baseRef = *basePRef;
	
	vector vSource;
	
	vSource = ( pl.origin + pl.view_ofs );
	traceline( vSource, vSource + ( vTraceDirection * range ), MOVE_HITMODEL, pl );
	
	// regardless of hitting, delay is set all the same
	weapon_base_setWholeAttackDelay(pl, baseRef.fAttackDelay);
	
	
	if ( trace_fraction == 1.0 ) {
		//did not hit anything
		return MELEE_HIT_RESPONSE::NONE;
	}

	// ?   For what purpose now?
	//vOrigin = trace_endpos - vTraceDirection * 2;

	if ( trace_ent.takedamage ) {
		if ( trace_ent.iBleeds == TRUE ) {
			FX_Impact( IMPACT_FLESH, trace_endpos, trace_plane_normal );
			//TAGGG - not the sound TS uses at least, this is a counterstrike leftover.
			//sound( self, CHAN_WEAPON, sprintf( "weapons/knife_hit%d.wav", floor( ( random() * 4 ) + 1 ) ), 1, ATTN_NORM );
			resultHit = MELEE_HIT_RESPONSE::FLESH;
		}else{
			//assume metal then?
			resultHit = MELEE_HIT_RESPONSE::METAL;
		}
		
		//TAGGG - other Damage_Apply examples:
		// snark hit
		//Damage_Apply(this, world, 1, 0, DMG_GENERIC);
		// crossbow bolt touch
		//Damage_Apply(other, self.owner, Skill_GetValue("plr_xbow_bolt_monster", 50), WEAPON_CROSSBOW, DMG_BLUNT);
		
		// Also calling the damage type 'SLASH' for now, all dedicated melee weapons are knife or sword-like
		Damage_Apply( trace_ent, pl, damageToDeal, (int)pl.activeweapon, DMG_SLASH);
	} else {
		// not a damage-able?  okay.
		//FX_Impact( IMPACT_MELEE, trace_endpos, trace_plane_normal );
		
		float surf;
		string tex;
		
		surf = getsurfacenearpoint(trace_ent, trace_endpos);
		tex = getsurfacetexture(trace_ent, surf);
		
		
#ifndef TEXTURE_LENGTH_LIMIT
			//nothing to do here.
#else
			//Enforce the cutoff.
			//...I know texture names above weren't enforced to be lowercase,
			// but isn't it a good idea to do it here anyway?
			tex = strtolower(substring(tex, 0, TEXTURE_LENGTH_LIMIT));
#endif
		
		//printfline("I hit: %s ::: %s", floatToChar((float)hash_get(hashMaterials, tex)), tex );
		printfline("weapon_base_onPrimaryAttack_melee_fromCustomDirection - I hit: %s", chr2str((float)hash_get(hashMaterials, tex)) );
		
		switch ((float)hash_get(hashMaterials, tex)) {
		case 'G':
		case 'V':
			FX_Impact_Melee(IMPACT_METAL, trace_endpos, trace_plane_normal);
			resultHit = MELEE_HIT_RESPONSE::METAL;
			break;
		case 'M':
			FX_Impact_Melee(IMPACT_METAL, trace_endpos, trace_plane_normal);
			resultHit = MELEE_HIT_RESPONSE::METAL;
			break;   //...why did we forget to put a break here?  no reason, right?
		//TAGGG - handling computers separately.
		case 'P':
			FX_Impact_Melee(IMPACT_COMPUTER, trace_endpos, trace_plane_normal);
			resultHit = MELEE_HIT_RESPONSE::METAL;
			break;
		//TAGGG - handle dirt separately.
		case 'D':
			FX_Impact_Melee(IMPACT_DIRT, trace_endpos, trace_plane_normal);
			resultHit = MELEE_HIT_RESPONSE::SOFT;
			break;
		case 'W':
			FX_Impact_Melee(IMPACT_WOOD, trace_endpos, trace_plane_normal);
			resultHit = MELEE_HIT_RESPONSE::SOFT;
			break;
		case 'Y':
			FX_Impact_Melee(IMPACT_GLASS, trace_endpos, trace_plane_normal);
			resultHit = MELEE_HIT_RESPONSE::METAL;
			break;
		case 'N':
			//'N' means snow apparently.
			FX_Impact_Melee(IMPACT_DEFAULT, trace_endpos, trace_plane_normal);
			resultHit = MELEE_HIT_RESPONSE::SOFT;
			break;
		case 'T':
			FX_Impact_Melee(IMPACT_DEFAULT, trace_endpos, trace_plane_normal);
			resultHit = MELEE_HIT_RESPONSE::METAL;
			break;
		default:
			FX_Impact_Melee(IMPACT_DEFAULT, trace_endpos, trace_plane_normal);
			resultHit = MELEE_HIT_RESPONSE::METAL;
			break;
		}
		
	}// trace_ent.takedamage check
#endif

	return resultHit;
}// weapon_base_onPrimaryAttack_melee


// Apparently serverside-only? ok...
void
weapon_base_onAttack(player pl, weapondata_basic_t* basePRef, weapondynamic_t arg_thisWeapon, int attackTypeUsed){
	weapon_base_onAttack_multi(pl, basePRef, arg_thisWeapon, 1, attackTypeUsed);
}// weapon_base_onAttack


// Was considering making this client-callable, buuuuut
// the fire-viewcamera-kickback thing is going a different direciton though, so never mind that.
// In short, this is effectively serverside-only, clientside script in any weapon is never expected to call this method.
// If we ever need that changed, that would need to be edited in every single weapon.. ehhhhhh.
// TODO!  Mass rename this to weapon_gun_onAttack_multi, same for above.
// Why would this ever be called for a non-gun?  Melee uses a different method completely,
// and we refer to fRange here, a weapon-only attribute.
// (effectively becomes 'max number of penetrations allowed', which is still something only for guns)
// NOTE - checks for being unable to fire yet not included!
void
weapon_base_onAttack_multi(player pl, weapondata_basic_t* basePRef, weapondynamic_t arg_thisWeapon, int shellCount, int attackTypeUsed){
	
#ifdef SERVER
	weapondata_gun_t baseRef = *((weapondata_gun_t*)basePRef);
	float randoAngFactor = randomInRange_f(0, 1);
	
	//float finalAng = (40 + randoAngFactor*( (90-40)*2 ) ) *(M_PI/180);
	
	float angleRange = 115;
	float finalAng = ( 90 - (angleRange/2) + randoAngFactor*( angleRange ) ) *(M_PI/180);
	
	// OLD LOC OF setWholeAttackDelay
	
	//TODO - factor in 'fAccuracyKickback' too.  Or a cumulative var really in this case.
	float baseAcc = baseRef.firestats.fAccuracy;
	float kickbackToApply = pl.fAccuracyKickback;
	
	if(baseAcc < 0.001){
		//minimum enforced, per notes in wepon_official.txt
		baseAcc = 0.001;
	}
	
	int legalBuyOpts = (arg_thisWeapon.iBitsUpgrade & baseRef.iBitsUpgrade);
	// The lasersight can be turned  off, so check for "_on" instead in that case.
	int legalBuyOpts_on = (arg_thisWeapon.iBitsUpgrade_on & legalBuyOpts);
	
	
	if(legalBuyOpts_on & BITS_WEAPONOPT_LASERSIGHT){
		baseAcc *= 0.72;
		kickbackToApply *= 0.87;
	}
	if(legalBuyOpts & BITS_WEAPONOPT_SILENCER){
		baseAcc *= 0.92;
		kickbackToApply *= 0.94;
	}
	
	float acc = baseAcc + kickbackToApply;
	
	
	//TODO - factor in 'fAccuracyKickback' too.
	
	vector toGo;
	float miner = 0.65 * 1;
	float maxer = 1.00 * 1;
	//float miner = 0.75/128;
	//float maxer = 1.00/128;
	
	
	//TAGGG - NOTE!
	// Nuclide does not support custom range as of now, nor how to tell how far penetration can go.
	// Old FreeTS did penetration distance by reducing range by 3 times as far as any solid object
	// in the way, so range doubles as penetration amount.
	// Now, only amount of times penetration can happen is specified.
	// Use the old TS weapon stat's range to determine that simply for now.
	// Higher = more penetrations allowed, lower = fewer allowed.
	// Not that the stats are really customized per weapon at the moment anyway, most if not all
	// are still 4096.
	int myPenetrationCount;
	if(baseRef.fRange >= 8192){
		myPenetrationCount = 3;
	}else if(baseRef.fRange >= 4096){
		myPenetrationCount = 2;
	}else if(baseRef.fRange >= 2048){
		myPenetrationCount = 1;
	}else{
		myPenetrationCount = 0;
	}
	TraceAttack_SetPenetrationPower(myPenetrationCount);
	////////////////////////////////////////////////////////////////////////////////////////////////
	
	
	//TAGGG - TODO!  The last parameter of TraceAttack_FireBullets should use the Weapon ID,
	// like "WEAPON_ID::Glock18".  Consider sending that as a parameter to be available here
	if(attackTypeUsed & BITS_AKIMBOCHOICE_LEFT){
		//left
		TraceAttack_FireBullets(shellCount, (pl.origin + pl.view_ofs), baseRef.fAttackDamage, [acc, acc], (int)pl.activeweapon);
		arg_thisWeapon.iClipLeft -= 1;
		toGo = [-sin(finalAng), cos(finalAng), 0] * baseRef.firestats.fViewKickback * randomInRange_f(miner, maxer);
		pl.vViewAngleOffsetTarget += toGo;
	}
	if(attackTypeUsed & BITS_AKIMBOCHOICE_RIGHT){
		
		//right
		TraceAttack_FireBullets(shellCount, (pl.origin + pl.view_ofs), baseRef.fAttackDamage, [acc, acc], (int)pl.activeweapon);

		arg_thisWeapon.iClipAkimboLeft -= 1;
		toGo = [-sin(finalAng), cos(finalAng), 0] * baseRef.firestats.fViewKickback * randomInRange_f(miner, maxer);
		pl.vViewAngleOffsetTarget += toGo;
	}
	
	// TODO - be better shared later?
	// Syncing view kickback would need the random-ness to be handled between server/client,
	// maybe seeded randoms?  I forget.
	// Properly predicted shotgun firing would be a good demonstration of that too,
	// so what happens instantly (client sees) and what actually happened (server sees; everyone
	// else sees) line up.
	pl.fAccuracyKickbackStartCooldown = time + 0.14;
	pl.fAccuracyKickback += baseRef.firestats.fAccuracyKickback;
	if(pl.fAccuracyKickback >= 0.1){
		//cap it.
		pl.fAccuracyKickback = 0.1;
	}
	
	// TODO - third person.
	//Animation_ShootWeapon( pl );
#else
	//CLIENTSIDE

#endif
	
}// weapon_base_onAttack


void
weapon_base_burstFire(
	player pl, weapondata_basic_t* basePRef, weapondynamic_t arg_thisWeapon,
	int attackTypeUsed, int shotCount, float shotDelay
){
	weapondata_basic_t baseRef = *basePRef;

	float thatStuff = shotDelay * (shotCount-1) + baseRef.fAttackDelay;
	weapon_base_setWholeAttackDelay(pl, thatStuff);
	
	//printfline("??? %.2f ", thatStuff);
	pl.aryNextBurstShotTime_softLength = shotCount;
	for(int i = 0; i < shotCount; i++){
		pl.aryNextBurstShotTime[i] = thatStuff - shotDelay*(i);
		//printfline("WELL #%i: %.2f", i, pl.aryNextBurstShotTime[i]);
	}
	
	//printfline("arg_thisWeapon.iFireMode %i", (arg_thisWeapon.iFireMode));
	pl.aryNextBurstShotTime_listenIndex = 0;
	
	// and fire this very first frame.
	weapon_gun_fireBurstBullet(pl, basePRef, arg_thisWeapon);
}//weapon_base_burstFire



// This method is called instead of firing when left-clicking while reloading.
// How do we handle this at different phases of the reload?
// This also returns "FALSE" if it didn't even have a reload to interrupt, conveniece feature.
BOOL
weapon_shotgun_onInterrupt(
	player pl, weapondata_basic_t* basePRef, weapondynamic_t arg_thisWeapon
){
	if(pl.shotgunReloadIndex == 0){
		// nothing to interrupt.
		return FALSE;
	}
	
	//if(pl.shotgunReloadIndexQueued != 3){
		if(pl.shotgunReloadIndex == 1){
			//still on the first?  queue the end.
			pl.shotgunReloadIndexQueued = 3;
		}else if(pl.shotgunReloadIndex == 2){
			//still really.  Do we really care about instantly interrupting this?
			//  eh, just let it put this bullet in.  why not.
			pl.shotgunReloadIndexQueued = 3;
		}
	//}
	
	return TRUE;
}// weapon_shotgun_onInterrupt


// Method assumes the player's "shotgunReload1_seq" and "_Duration" for vars Reload1, 2, and 3
// have been set correctly first, probably in the weapon's "onEquip" method.
// few others like shotgunReload2_ammoLoadDelay (serverside) too.  nah that's it.
void
weapon_shotgun_reload(
	player pl, weapondata_basic_t* basePRef, weapondynamic_t arg_thisWeapon
){
	weapondata_gun_t baseRef = *((weapondata_gun_t*)basePRef);
	
	//printfline("weapon_shotgun_reload %d %i", pl.isReloading, pl.shotgunReloadIndex);
	
	// Mostly to forbid reloading while doing a pump-mode pump followed by firing, bit jarring looking
	// to interrupt that.
	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	// do we even need this.
	if ( pl.isReloading || pl.isChangingIronsight){
		//blocked
		return;
	}
	
	if(pl.ary_ammoTotal[baseRef.iAmmoDataID] <= 0){
		//also no.  Having no ammo in the pool to take from means no reloading.
		return;
	}
	
	if(!pl.weaponEquippedAkimbo){
		 if(arg_thisWeapon.iClipLeft >= baseRef.iClipMax){
			 return;  //don't reload!
		 }
	}else{
		//akimbo, allows reloading for either being less than full
		 if(arg_thisWeapon.iClipLeft >= baseRef.iClipMax && arg_thisWeapon.iClipAkimboLeft >= baseRef.iClipMax){
			 return;  //both full? don't reload!
		 }
	}
	
	//not reloading at all or doing fire-pumps?  We can start.
	////if(pl.shotgunReloadIndex == 0 && (pl.shotgunPumpEndTime == -1 || time >= pl.shotgunPumpEndTime) ){
	////if(pl.shotgunReloadIndex == 0 && (pl.shotgunPumpEndTime == -1 || pl.w_attack_next <= 0) ){
	if(pl.shotgunReloadIndex == 0 ){
		
	
	}else{
		// no.
		return;
	}
	
	pl.isChangingIronsight = FALSE;
	SAVE_STATE(pl.isChangingIronsight);
	pl.currentZoomChoice = -1;
	pl.setZoom(1.00f);
	pl.aryNextBurstShotTime_softLength = 0;
	pl.aryNextBurstShotTime_listenIndex = -1;
	
	//weapon_base_setWholeAttackDelay(pl, baseRef.fAnim_Reload_Duration);

	//printfline("weapon_shotgun_reload %i %d", pl.shotgunReloadIndex, pl.shotgunPumpEndTime);
	pl.isReloading = TRUE;
	
	pl.shotgunReloadIndex = 1;
	
	//printfline("HERES THAT shotgunReload1_Duration %.2f", pl.shotgunReload1_Duration);
	weapon_base_setWholeAttackDelay(pl, pl.shotgunReload1_Duration);
	
	pl.shotgunReloadIndexQueued = 2;
	
	TS_Weapons_ViewAnimation(pl.shotgunReload1_seq, pl.shotgunReload1_Duration );
	
}//weapon_shotgun_reload



// NOTICE - shotguns with typical shotgun reload logic should use this method at all
// times. It includes checks for whether the shotgun is actually reloading or not
// (don't do anything if not of course)
void
weapon_shotgun_onThink_reloadLogic(player pl, weapondata_gun_t* basePRef, weapondynamic_t arg_thisWeapon){
	weapondata_gun_t baseRef = *basePRef;
	
	//printfline("FRAME att: %.2f", pl.w_attack_next);
	
	if(pl.shotgunReloadIndex > 0){
		//reloading at all only.
		
		if(pl.w_attack_next <= 0){
			//time has surpassed the time to the next phase?  Check the pl.shotgunReloadIndexQueued.
			
			pl.shotgunReloadIndex = pl.shotgunReloadIndexQueued;
			
			
			
			//printfline("ack: %i", pl.shotgunReloadIndex);
			if(pl.shotgunReloadIndex == 0){
				//little bit of cleanup, since we're done reloading.
				pl.isReloading = FALSE;
				
				
				//printfline("shotgunWaitingForPump go BYEBYE 1");
				//if we were waiting for a pump, stop now. the anim did a pump by this point.
				pl.shotgunWaitingForPump = FALSE;
				
				//NOTICE - an index of 0 should not be possible, we move away from it always.
			}else if(pl.shotgunReloadIndex == 2){
				//time to plug the bullets in
				
				
				if( arg_thisWeapon.iClipLeft >= baseRef.iClipMax || pl.ary_ammoTotal[baseRef.iAmmoDataID] <= 0 ){
					
					pl.shotgunReloadIndex = 3;
					TS_Weapons_ViewAnimation(pl.shotgunReload3_seq, pl.shotgunReload3_Duration);
					weapon_base_setWholeAttackDelay(pl, pl.shotgunReload3_Duration);

					
					pl.shotgunReloadIndexQueued = 0;
				}else{
					// if we still have ammo left in the reserve,
					// AND the clip is not full, repeat, going to reload again.
					
					TS_Weapons_ViewAnimation(pl.shotgunReload2_seq, pl.shotgunReload2_Duration);
					
					pl.shotgunReloadIndex = 2;
					weapon_base_setWholeAttackDelay(pl, pl.shotgunReload2_Duration);
					
					pl.shotgunReloadIndexQueued = 2;
					
					// 2.0 - 0.3 = 1.7
					// idea: set shotgunAddAmmoTime to the w_attack_next (total duration of the anim) minus ammoLoadDelay,
					// since w_attack_next counts down.  When w_attack_next goes below shotgunAddAmmoTime, that means
					// the "shotgunReload2_ammoLoadDelay" amount of time has passed, same thing, better for networking.
					//// pl.shotgunAddAmmoTime = time + pl.shotgunReload2_ammoLoadDelay;
					pl.shotgunAddAmmoTime = pl.w_attack_next - pl.shotgunReload2_ammoLoadDelay;
					
					
					pl.shotgunAddAmmoSoundTime = time + pl.shotgunReload2_ammoLoadDelay - 0.03f;
				}
				
				
			}else if(pl.shotgunReloadIndex == 3){
				//end anim
				
				TS_Weapons_ViewAnimation(pl.shotgunReload3_seq, pl.shotgunReload3_Duration);
				weapon_base_setWholeAttackDelay(pl, pl.shotgunReload3_Duration);
				
				pl.shotgunReloadIndexQueued = 0;
			}
			
		}// w_attack_next <= 0
		
		
		if(pl.shotgunReloadIndex == 2){
			
			////if(pl.shotgunAddAmmoTime != -1 && time >= pl.shotgunAddAmmoTime){
			if(pl.shotgunAddAmmoTime != -1 && pl.w_attack_next <= pl.shotgunAddAmmoTime){
				//add the ammo!!
				
				arg_thisWeapon.iClipLeft++;
				pl.ary_ammoTotal[baseRef.iAmmoDataID] -= 1;
				
#ifdef CLIENT
				sound(pl, CHAN_ITEM, "weapons/insert-shell.wav", 1, ATTN_NONE);
#endif
				
				pl.shotgunAddAmmoTime = -1;   //don't keep doing it.
			}
			if(pl.shotgunAddAmmoSoundTime != -1 && time >= pl.shotgunAddAmmoSoundTime){
				//TS_PlayInsertShellSound(pl);
				pl.shotgunAddAmmoSoundTime = -1;
			}
			
		}
	}
	
	if(pl.w_attack_next <= 0){
		// little copy from base think logic, since we're replacing it for shotguns.
		if(pl.isChangingIronsight){
			weapon_gun_endOfIronSight(pl, basePRef, arg_thisWeapon);
		}
	}
}//weapon_shotgun_onThink_reloadLogic



BOOL
weapon_akimbo_AttackDualHack(
	player pl, weapondynamic_t arg_thisWeapon, int arg_flagger,
	int* arg_akimboFireCallback
){
	//printfline("WELL WHAT. %.2f, %i, %i", pl.akimboDualFireToleranceTime, pl.akimboFirePrev, arg_flagger);
	if(arg_flagger == 0){
		// ???
		return FALSE;
	}
	
	//printfline("ERE I GO akprev:%i aktest:%i - flagg:%i", pl.akimboFirePrev, pl.akimboTest, arg_flagger);
	
	if(
		pl.akimboDualFireToleranceTime > 0 &&
		pl.akimboFirePrev != BITS_AKIMBOCHOICE_BOTH && 
		(pl.akimboFirePrev & arg_flagger) //&&
		//(arg_thisWeapon.iClipLeft > 0 && arg_thisWeapon.iClipAkimboLeft > 0)			
	){
		
		/*
		// Check the opposites
		if(pl.akimboFirePrev & BITS_AKIMBOCHOICE_LEFT){
			if(arg_thisWeapon.iClipAkimboLeft <= 0){
				// can't be used for this
				printfline("YOU FAIL A");
				return FALSE;
			}
		}
		if(pl.akimboFirePrev & BITS_AKIMBOCHOICE_RIGHT){
			if(arg_thisWeapon.iClipLeft <= 0){
				// can't be used for this
				printfline("YOU FAIL B");
				return FALSE;
			}
		}
		*/
		
		
		// Fired the other way very rececntly?  LETS GO
		pl.akimboTest = pl.akimboFirePrev; //pl.arg_flagger;
		weapon_base_setWholeAttackDelay(pl, 0);
		
		
		
		// unpacking the method to call at runtime out of paranoia knowing FTE.
		// Could make a table to know what to use per akimbo weapon ID, having a table
		// with one space for every single weapon in the game seems pretty wasteful.
		// Calls like weapon_SOCOM_MK23_akimbo_attack, etc.
		BOOL(player pl, weapondynamic_t arg_thisWeapon, int attackTypeUsed)* tempRef = arg_akimboFireCallback;
		(*tempRef)(pl, arg_thisWeapon, BITS_AKIMBOCHOICE_BOTH);
		
		//printfline("I WENT, akprev:%i aktest:%i - flagg:%i", pl.akimboFirePrev, pl.akimboTest, arg_flagger);
		
		// fu king what
		//weapon_base_setWholeAttackDelay(pl, 0.5);
		pl.akimboDualFireToleranceTime = 0;
		return TRUE;
	}else{
		// nothing special.
		return FALSE;
	}
}


// If the user clicks both mouse buttons (or whatever way of calling primary/secondary)
//  in very rapid succession, go ahead and quickly correct that to the dual firing
// animation, as that's otherwise hard to make work.  This gives a little tolerance
// for that, the user clearly meant to do that.
// Returns whether the conditions were met to do the dual correction.  If not, the
// default behavior should be done by the caller instead.
BOOL
weapon_akimbo_semiAttackDualHack(
	player pl, weapondynamic_t arg_thisWeapon, int arg_flagger,
	int* arg_akimboFireCallback
){
	if(arg_thisWeapon.iFireModeAkimbo == BITS_FIREMODE_AKIMBO_SEMI_AUTO){
		return FALSE;
	}
	return weapon_akimbo_AttackDualHack(pl, arg_thisWeapon, arg_flagger, arg_akimboFireCallback);
}

// WARNING!  Don't do this, full-firing akimbos really don't need this,
// original TS doesn't even allow separate fire-delays between the full-
// fire akimbo weapons.
BOOL
weapon_akimbo_fullAttackDualHack(
	player pl, weapondynamic_t arg_thisWeapon, int arg_flagger,
	int* arg_akimboFireCallback
){
	if(arg_thisWeapon.iFireModeAkimbo == BITS_FIREMODE_AKIMBO_FULL_AUTO){
		return FALSE;
	}
	return weapon_akimbo_AttackDualHack(pl, arg_thisWeapon, arg_flagger, arg_akimboFireCallback);
}


// Used for akimbo weapons with semi fire modes (all akimbo pistols I think).
// Some akimbo SMG supports hold-fire in akimbo though, that will be handled a little differnetly.
// Same method with a choice or not, unsure what's best yet.
// TAGGG - TODO, of course.
// -----------------------------
// In any case, this method returns which akimbo weapon was picked to be fired (BITS_AKIMBOCHOICE_... LEFT or RIGHT typically).
// It may return _NONE, which still means to play a click noise (no ammo).
// But if the reason it failed is because no weapon with a fire delay that allows firing (fired too soon) could be found,
// then we don't want to even do that. This method returns "-1", not linked to any constant,
// to mean "stop what you're doing, return FALSE, don't send an even to the client at all", to whatever called this.
// Also note that this may edit pl.nextAkimboAttackPreference, for which gun to check next time an ambiguous button is pressed
// (that is primary fire for semi-auto mode; free-auto lets primary/secondary fire pick the left/right weapon consistently)
int
weapon_akimbo_semiAttackChoice(
	player pl, weapondata_basic_t* basePRef, weapondynamic_t arg_thisWeapon,
	int attackTypeUsed
){
	int originalInput = attackTypeUsed;
	int finalAkimboChoice = BITS_AKIMBOCHOICE_NONE;
	weapondata_basic_t baseRef = *basePRef;
	
	//printfline("PRE - EVERYBODY GET DOWN x - next:%d", pl.nextAkimboAttackPreference);

	/*
	if(pl.akimboTest != 0){
		return BITS_AKIMBOCHOICE_BOTH;
	}
	*/

	//if(pl.akimboTest == 0)
	if(attackTypeUsed & BITS_AKIMBOCHOICE_LEFT){
		// only allow it if this is a fresh button press
		// We could also check firemode here, but both require a tap.
		if(INPUT_PRIMARY_TAP_CHECK_NOT(pl)){
			attackTypeUsed &= ~BITS_AKIMBOCHOICE_LEFT;
		}
	 
	}
	if(attackTypeUsed & BITS_AKIMBOCHOICE_RIGHT){
		if (INPUT_SECONDARY_TAP_CHECK_NOT(pl)){
			attackTypeUsed &= ~BITS_AKIMBOCHOICE_RIGHT;
		}
	}
	
	
	if(arg_thisWeapon.iFireModeAkimbo == BITS_FIREMODE_AKIMBO_SEMI_AUTO){
		//alternate. So use the preference but try whichever one has ammo too.
		
		if( !(attackTypeUsed & BITS_AKIMBOCHOICE_LEFT) ||
			(pl.w_attack_next > 0 && pl.w_attack_akimbo_next > 0) )
		{
			
			// In this fire mode, if the primary fire wasn't pressed we don't register at all.
			// Also still don't click because we're in a changing animation (ironsight or reloading)
			// or only either weapon is out of ammo.
			//return FALSE;
			return -1;
		}
		
		if(pl.nextAkimboAttackPreference == BITS_AKIMBOCHOICE_RIGHT){
			//try the right first
			if(arg_thisWeapon.iClipAkimboLeft > 0 && pl.w_attack_akimbo_next <= 0){
				finalAkimboChoice = BITS_AKIMBOCHOICE_RIGHT;
				//printfline("1a - BITS_AKIMBOCHOICE_RIGHT");
			}else if(arg_thisWeapon.iClipLeft > 0 && pl.w_attack_next <= 0){
				finalAkimboChoice = BITS_AKIMBOCHOICE_LEFT;
				//printfline("1a - BITS_AKIMBOCHOICE_LEFT");
			}else{
				//nope
			}
		}else{
			//try the left first
			if(arg_thisWeapon.iClipLeft > 0 && pl.w_attack_next <= 0){
				finalAkimboChoice = BITS_AKIMBOCHOICE_LEFT;
				//printfline("1b - BITS_AKIMBOCHOICE_LEFT");
			}else if(arg_thisWeapon.iClipAkimboLeft > 0 && pl.w_attack_akimbo_next <= 0){
				finalAkimboChoice = BITS_AKIMBOCHOICE_RIGHT;
				//printfline("1b - BITS_AKIMBOCHOICE_RIGHT");
			}else{
				//nope
			}
		}// nextAkimboattackPreference check
		
		
		if(finalAkimboChoice == BITS_AKIMBOCHOICE_NONE){
			// We should stop, but need to tell whether to play a click noise or not.
			// If either clip is not empty, we assume the reason we did not fire is
			// because whichever non-empty weapon wasn't ready to fire.
			// If they are both 0, we stopped because the weapon is empty.
			//pl.recentAttackHadAmmo = (finalAkimboChoice != BITS_AKIMBOCHOICE_NONE);
			//pl.recentAkimboAttackChoice = finalAkimboChoice;
			//return( arg_thisWeapon.iClipLeft == 0 && arg_thisWeapon.iClipAkimboLeft == 0);
			
			if(arg_thisWeapon.iClipLeft == 0 && arg_thisWeapon.iClipAkimboLeft == 0){
				// If both clips have no ammo, we assume the reason for failure is being out of ammo.
				// Since we would've picked a gun to use that had ammo otherwise.
				// No need to return here, we fall through with this finalAkimboChoice, same effect.
				//return BITS_AKIMBOCHOICE_NONE;
				
				// Just try the one opposite of this preference next time. This lets clicking
				// alternate between the weapons.
				
				if(pl.nextAkimboAttackPreference == BITS_AKIMBOCHOICE_LEFT){
					//yes, == left. As in not both, only firing left.
					pl.nextAkimboAttackPreference = BITS_AKIMBOCHOICE_RIGHT;
					//printfline("1c - BITS_AKIMBOCHOICE_RIGHT");

				}else{
					pl.nextAkimboAttackPreference = BITS_AKIMBOCHOICE_LEFT;
					//printfline("1c - BITS_AKIMBOCHOICE_LEFT");

				}
				
				
			}else{
				//apparently some fire delay was not cooperating.
				return -1;
			}
		}else{
			
			
			// Dont do it here nimrod!
			//next time try the opposite of what we actually used this time
			if(finalAkimboChoice == BITS_AKIMBOCHOICE_LEFT){
				//yes, == left. As in not both, only firing left.
				pl.nextAkimboAttackPreference = BITS_AKIMBOCHOICE_RIGHT;
				//printfline("1d - BITS_AKIMBOCHOICE_RIGHT");
			}else{
				pl.nextAkimboAttackPreference = BITS_AKIMBOCHOICE_LEFT;
				//printfline("1d - BITS_AKIMBOCHOICE_LEFT");
			}
			
		}// no choice in finalAkimboChoice
		
	}else if(arg_thisWeapon.iFireModeAkimbo == BITS_FIREMODE_AKIMBO_FREE_SEMI){
		
		if(pl.w_attack_next > 0){
			attackTypeUsed &= ~BITS_AKIMBOCHOICE_LEFT;
		}
		
		//printfline("ARE YOU %.2f", pl.w_attack_akimbo_next);
		if(pl.w_attack_akimbo_next > 0){
			attackTypeUsed &= ~BITS_AKIMBOCHOICE_RIGHT;
		}
		
		if(attackTypeUsed == BITS_AKIMBOCHOICE_NONE){
			//similar to not having the primary key tapped in a non-akimbo weapon (ordinary),
			//having neither key tapped, regardless of pressed signifies to end without playing
			//a clip sound.
			return -1;
		}
		
		if(arg_thisWeapon.iClipLeft <= 0){
			//exclude
			attackTypeUsed &= ~BITS_AKIMBOCHOICE_LEFT;
		}
		if(arg_thisWeapon.iClipAkimboLeft <= 0){
			//exclude
			attackTypeUsed &= ~BITS_AKIMBOCHOICE_RIGHT;
		}
		
		if(attackTypeUsed == BITS_AKIMBOCHOICE_BOTH){
			//special case. still valid to attack with both weapons?  ok.  Mark this.
			finalAkimboChoice = BITS_AKIMBOCHOICE_BOTH;
		}else if(attackTypeUsed & BITS_AKIMBOCHOICE_LEFT){
			finalAkimboChoice = BITS_AKIMBOCHOICE_LEFT;
		}else if(attackTypeUsed & BITS_AKIMBOCHOICE_RIGHT){
			finalAkimboChoice = BITS_AKIMBOCHOICE_RIGHT;
		}
		
		//no need to edit nextAkimboAttackPreference.
		//ehh, in case we switch back start from the left again...
		pl.nextAkimboAttackPreference = BITS_AKIMBOCHOICE_LEFT;
		
	}else{
		//no appropriate firemode....... wat
	}// firemode check
	
	if(finalAkimboChoice != -1){
		//we expect these things to be set.
		
		
		if(finalAkimboChoice != BITS_AKIMBOCHOICE_NONE && pl.waterlevel < 3){
			//we trust the finalAkimboChoice we're left with has ammo & hasn't fired too soon (attackDelay)
			pl.recentAttackHadAmmo = TRUE;
		}else{
			//If we failed, we still have to decide which of the weapons clicks.
			pl.recentAttackHadAmmo = FALSE;
			
			
			//so which one will the click noise apply a fire delay to? Depends on firemode.
			if(arg_thisWeapon.iFireModeAkimbo == BITS_FIREMODE_AKIMBO_SEMI_AUTO){
				finalAkimboChoice = pl.nextAkimboAttackPreference;
			}else{
				finalAkimboChoice = originalInput;
			}
			
		}
		
		pl.recentAkimboAttackChoice = finalAkimboChoice;
	}
		
	//printfline("EVERYBODY GET DOWN %i - next:%d", finalAkimboChoice, pl.nextAkimboAttackPreference);
	
	return finalAkimboChoice;
}// weapon_akimbo_semiAttackChoice


// A clone of semiAttackChoice for... you guessed it, akimbo full-fire weapons
// (continuously-firing weapons as the input is held).
// Which looks to be only the akimbo uzi's right now.
// Expect firemodes BITS_FIREMODE_AKIMBO_FULL_AUTO and BITS_FIREMODE_AKIMBO_FREE_FULL.
// Kindof mirror the semi fire ones, FULL_AUTO fires both weapons with holding left-click,
// FREE_FULL lets holding left & right triggers fire either weapon independently.
// Holding both down behaves exactly as though FULL_AUTO were used with left-click.
// It looks like there is no alternating fire supported, any firing of either weapon
// causes a fire delay that blocks either from firing (but holding the fire trigger for the
// non-fired one during that time will make it fire the next time the fire delay's are up).
// In other words both weapons share the same fire delay for either firing.
// This might make our job easier!
int
weapon_akimbo_fullAttackChoice(
	player pl, weapondata_basic_t* basePRef, weapondynamic_t arg_thisWeapon,
	int attackTypeUsed
){
	int originalInput = attackTypeUsed;
	int finalAkimboChoice = BITS_AKIMBOCHOICE_NONE;
	
	// DEFAULT
	pl.recentAttackHadAmmo = TRUE;

	weapondata_basic_t baseRef = *basePRef;

	//notice: never use "pl.nextAkimboAttackPreference".  We don't alternate fire
	// in any firemode for full akimbo.
	
	if(arg_thisWeapon.iFireModeAkimbo == BITS_FIREMODE_AKIMBO_FULL_AUTO){
		//Try firing both anytime we can.
		
		if( !(attackTypeUsed & BITS_AKIMBOCHOICE_LEFT) ||
			(pl.w_attack_next > 0 && pl.w_attack_akimbo_next > 0) )
		{
			// In this fire mode, if the primary fire wasn't pressed we don't register at all.
			// Also still don't click because we're in a changing animation (ironsight or reloading)
			// or only either weapon is out of ammo.
			//return FALSE;
			return -1;
		}
		
		if( !(pl.w_attack_next <= 0 && pl.w_attack_akimbo_next <= 0) ){
			//actually require both fire delays.  If either is not ready, stop.
			return -1;
		}
		
		
		
		BOOL canFireLeft = (arg_thisWeapon.iClipLeft > 0 && pl.w_attack_next <= 0);
		BOOL canFireRight = (arg_thisWeapon.iClipAkimboLeft > 0 && pl.w_attack_akimbo_next <= 0);
		
		if(canFireLeft && canFireRight){
			//splended!  Fire with both.
			finalAkimboChoice = BITS_AKIMBOCHOICE_BOTH;
		}else if(canFireLeft){
			finalAkimboChoice = BITS_AKIMBOCHOICE_LEFT;
		}else if(canFireRight){
			finalAkimboChoice = BITS_AKIMBOCHOICE_RIGHT;
		}
		
		if(finalAkimboChoice == BITS_AKIMBOCHOICE_NONE){
			// We should stop, but need to tell whether to play a click noise or not.
			// If either clip is not empty, we assume the reason we did not fire is
			// because whichever non-empty weapon wasn't ready to fire.
			// If they are both 0, we stopped because the weapon is empty.
			//pl.recentAttackHadAmmo = (finalAkimboChoice != BITS_AKIMBOCHOICE_NONE);
			//pl.recentAkimboAttackChoice = finalAkimboChoice;
			//return( arg_thisWeapon.iClipLeft == 0 && arg_thisWeapon.iClipAkimboLeft == 0);
			if(arg_thisWeapon.iClipLeft == 0 && arg_thisWeapon.iClipAkimboLeft == 0){
				// If both clips have no ammo, we assume the reason for failure is being out of ammo.
				// Since we would've picked a gun to use that had ammo otherwise.
				// No need to return here, we fall through with this finalAkimboChoice, same effect.
				//return BITS_AKIMBOCHOICE_NONE;
				
			}else{
				//apparently some fire delay was not cooperating.
				return -1;
			}
		}
		
		
		
	}else if(arg_thisWeapon.iFireModeAkimbo == BITS_FIREMODE_AKIMBO_FREE_FULL){
		
		
		if( !(pl.w_attack_next <= 0 && pl.w_attack_akimbo_next <= 0) ){
			// actually require both fire delays.  If either is not ready, stop.
			// And yes, for Free Full too.  Just go with it.
			return -1;
		}
		
		
		if(pl.w_attack_next > 0){
			attackTypeUsed &= ~BITS_AKIMBOCHOICE_LEFT;
		}
		if(pl.w_attack_akimbo_next > 0){
			attackTypeUsed &= ~BITS_AKIMBOCHOICE_RIGHT;
		}
		
		if(attackTypeUsed == BITS_AKIMBOCHOICE_NONE){
			//similar to not having the primary key tapped in a non-akimbo weapon (ordinary),
			//having neither key tapped, regardless of pressed signifies to end without playing
			//a clip sound.
			//return FALSE;
			return -1;
		}
		
		if(arg_thisWeapon.iClipLeft <= 0){
			//exclude
			attackTypeUsed &= ~BITS_AKIMBOCHOICE_LEFT;
		}
		if(arg_thisWeapon.iClipAkimboLeft <= 0){
			//exclude
			attackTypeUsed &= ~BITS_AKIMBOCHOICE_RIGHT;
		}
		
		if(attackTypeUsed == BITS_AKIMBOCHOICE_BOTH){
			//special case. still valid to attack with both weapons?  ok.  Mark this.
			finalAkimboChoice = BITS_AKIMBOCHOICE_BOTH;
		}else if(attackTypeUsed & BITS_AKIMBOCHOICE_LEFT){
			finalAkimboChoice = BITS_AKIMBOCHOICE_LEFT;
		}else if(attackTypeUsed & BITS_AKIMBOCHOICE_RIGHT){
			finalAkimboChoice = BITS_AKIMBOCHOICE_RIGHT;
		}
		
		
		// determine: do we want to play the click sound (pass through), or not (return -1)?
		if(finalAkimboChoice == BITS_AKIMBOCHOICE_NONE){
			//if(arg_thisWeapon.iClipLeft == 0 && arg_thisWeapon.iClipAkimboLeft == 0){
			
			if(
			/*
				(arg_thisWeapon.iClipLeft == 0 && originalInput == BITS_AKIMBOCHOICE_LEFT) ||
			   (arg_thisWeapon.iClipAkimboLeft == 0 && originalInput == BITS_AKIMBOCHOICE_RIGHT) ||
			   (arg_thisWeapon.iClipLeft == 0 && arg_thisWeapon.iClipAkimboLeft == 0 && originalInput == BITS_AKIMBOCHOICE_BOTH)
			   */
			   
			   ((originalInput & BITS_AKIMBOCHOICE_LEFT) && arg_thisWeapon.iClipLeft != 0) ||
			   ((originalInput & BITS_AKIMBOCHOICE_RIGHT) && arg_thisWeapon.iClipAkimboLeft != 0)
			   
			)
			{
				//apparently some fire delay was not cooperating.
				return -1;
			}else{
				
			}
		}
		
		//printfline("CLUSTER cluck: %i %i", attackTypeUsed, finalAkimboChoice);
		
	}else{
		//no appropriate firemode....... wat
	}// firemode check
	
	if(finalAkimboChoice != -1){
		//we expect these things to be set.
		
		// Sure you too, why not.  Full-auto weapons fire fast enough that we can't really tell the difference anyway,
		// and original TS requires this too.
		if( !(pl.w_attack_next <= time && pl.w_attack_akimbo_next <= time) ){
			// actually require both fire delays.  If either is not ready, stop.
			// And yes, for Free Full too.  Just go with it.
			return -1;
		}
		
		
		if(finalAkimboChoice != BITS_AKIMBOCHOICE_NONE && pl.waterlevel < 3){
			//we trust the finalAkimboChoice we're left with has ammo & hasn't fired too soon (attackDelay)
			pl.recentAttackHadAmmo = TRUE;
		}else{
			//printfline("WHAT THE heck M8");
			//If we failed, we still have to decide which of the weapons clicks.
			pl.recentAttackHadAmmo = FALSE;
			//so which one will the click noise apply a fire delay to? Depends on firemode.
			
			//uhhh.. whatever.
			finalAkimboChoice = originalInput;
			
			/*
			if(arg_thisWeapon.iFireModeAkimbo == BITS_FIREMODE_AKIMBO_FULL_AUTO){
				finalAkimboChoice = pl.nextAkimboAttackPreference;
			}else{
				finalAkimboChoice = originalInput;
			}
			*/
			
		}
		
		pl.recentAkimboAttackChoice = finalAkimboChoice;
	}

	return finalAkimboChoice;
}//weapon_akimbo_fullAttackChoice


BOOL
weapon_ironsight_ToggleIronsight(
	player pl, weapondata_ironsight_t* basePRef,
	weapondynamic_t arg_thisWeapon
){
	//weapondata_ironsight_t* basePRef = (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::SOCOM_MK23];
	weapondata_ironsight_t baseRef = *basePRef;
	
	// SEARCH ME!!!
	//arg_thisWeapon.iIronSight = 0; 

	if(pl.isReloading == FALSE && pl.isChangingIronsight == FALSE){
		
		printfline("time: %.2f weapon_ironsight_ToggleIronsight PASS.  CURRENT:%i", time, arg_thisWeapon.iIronSight);
	
		pl.isChangingIronsight = TRUE;
		SAVE_STATE(pl.isChangingIronsight);
		
		//TAGGG - QUESTION.
		// Why does only from ironSight == 0, going towards 1, use the "_EndIdle" version, but
		// the other way around doesn't?  Does this make sense for all weapons?
		if(arg_thisWeapon.iIronSight == 0){
			weapon_base_setWholeAttackDelay(pl, baseRef.ironsightdata.fAnim_Change_Duration * 0.9 );
			
			TS_Weapons_ViewAnimation_EndIdle( baseRef.ironsightdata.iAnim_Change_Index, baseRef.ironsightdata.fAnim_Change_Duration );
			
			//TS_Weapons_ViewAnimation( baseRef.ironsightdata.iAnim_Change_Index, baseRef.ironsightdata.fAnim_Change_Duration );
			
		}else{
			weapon_base_setWholeAttackDelay(pl, baseRef.ironsightdata.fAnim_ReChange_Duration * 0.9);
			TS_Weapons_ViewAnimation( baseRef.ironsightdata.iAnim_ReChange_Index, baseRef.ironsightdata.fAnim_ReChange_Duration );
		}
		
		//pl.recentAttackHadAmmo = arg_thisWeapon.iIronSight;  //haaaaaaacky sax
		
		//arg_thisWeapon.iIronSight = pl.recentAttackHadAmmo;
		//arg_thisWeapon.iIronSight = !arg_thisWeapon.iIronSight;
		
		return TRUE;
	}else{
		
		printfline("time: %.2f weapon_ironsight_ToggleIronsight FAILED (%d, %d).  current:%i", time, pl.isReloading, pl.isChangingIronsight, arg_thisWeapon.iIronSight);
	}
		
	return FALSE;
}// weapon_ironsight_ToggleIronsight


void
weapon_gun_Reload(
	player pl, weapondata_gun_t* basePRef, weapondynamic_t arg_thisWeapon
){
	weapondata_gun_t baseRef = *basePRef;
	
	if (pl.isReloading || pl.isChangingIronsight){
		return;
	}
	
	if(pl.ary_ammoTotal[baseRef.iAmmoDataID] <= 0){
		// also no.  Having no ammo in the pool to take from means no reloading.
		return;
	}
	
	if(!pl.weaponEquippedAkimbo){
		 if(arg_thisWeapon.iClipLeft >= baseRef.iClipMax){
			 return;  //don't reload!
		 }
	}else{
		// akimbo, allows reloading for either being less than full
		 if(arg_thisWeapon.iClipLeft >= baseRef.iClipMax && arg_thisWeapon.iClipAkimboLeft >= baseRef.iClipMax){
			 return;  //both full? don't reload!
		 }
	}
	
	pl.isChangingIronsight = FALSE;
	SAVE_STATE(pl.isChangingIronsight);
	pl.currentZoomChoice = -1;
	pl.setZoom(1.00f);
	pl.aryNextBurstShotTime_softLength = 0;
	pl.aryNextBurstShotTime_listenIndex = -1;
	pl.isReloading = TRUE;

	weapon_base_setWholeAttackDelay(pl, baseRef.fAnim_Reload_Duration);
	TS_Weapons_ViewAnimation(baseRef.iAnim_Reload_Index, baseRef.fAnim_Reload_Duration);
	
	//TAGGG TODO - third person model anim
	//Animation_ReloadWeapon( self );
	
}//weapon_gun_Reload


// like above, but pick a sequence/time to use instead of using config info.
void
weapon_gun_Reload_CustomSequence(
	player pl, weapondata_gun_t* basePRef, weapondynamic_t arg_thisWeapon,
	int arg_iReloadSeq, float arg_flReloadSeqTime
){
	weapondata_gun_t baseRef = *basePRef;
	
	if (pl.isReloading || pl.isChangingIronsight){
		return;
	}
	
	if(pl.ary_ammoTotal[baseRef.iAmmoDataID] <= 0){
		// also no.  Having no ammo in the pool to take from means no reloading.
		return;
	}
	
	if(!pl.weaponEquippedAkimbo){
		 if(arg_thisWeapon.iClipLeft >= baseRef.iClipMax){
			 return;  //don't reload!
		 }
	}else{
		// akimbo, allows reloading for either being less than full
		 if(arg_thisWeapon.iClipLeft >= baseRef.iClipMax && arg_thisWeapon.iClipAkimboLeft >= baseRef.iClipMax){
			 return;  //both full? don't reload!
		 }
	}
	
	pl.isChangingIronsight = FALSE;
	SAVE_STATE(pl.isChangingIronsight);
	pl.currentZoomChoice = -1;
	pl.setZoom(1.00f);
	pl.aryNextBurstShotTime_softLength = 0;
	pl.aryNextBurstShotTime_listenIndex = -1;
	pl.isReloading = TRUE;

	weapon_base_setWholeAttackDelay(pl, arg_flReloadSeqTime);
	TS_Weapons_ViewAnimation(arg_iReloadSeq, arg_flReloadSeqTime);
	
	//TAGGG TODO - third person model anim
	//Animation_ReloadWeapon( self );
	
}//weapon_gun_Reload_CustomSequence


void
weapon_ironsight_Reload(
	player pl, weapondata_ironsight_t* basePRef,
	weapondynamic_t arg_thisWeapon
){
	weapondata_ironsight_t baseRef = *basePRef;
	
	if ( pl.isReloading || pl.isChangingIronsight){
		//blocked
		return;
	}
	//if ( self.fAttackFinished > time ) {
	//	return;
	//}
	
	if(pl.ary_ammoTotal[baseRef.iAmmoDataID] <= 0){
		//also no.  Having no ammo in the pool to take from means no reloading.
		return;
	}
	
	if(!pl.weaponEquippedAkimbo){
		 if(arg_thisWeapon.iClipLeft >= baseRef.iClipMax){
			 return;  //don't reload!
		 }
	}else{
		//akimbo, allows reloading for either being less than full
		 if(arg_thisWeapon.iClipLeft >= baseRef.iClipMax && arg_thisWeapon.iClipAkimboLeft >= baseRef.iClipMax){
			 return;  //both full? don't reload!
		 }
	}
	
	pl.isChangingIronsight = FALSE;
		SAVE_STATE(pl.isChangingIronsight);
	pl.currentZoomChoice = -1;
	pl.setZoom(1.00f);
	pl.aryNextBurstShotTime_softLength = 0;
	pl.aryNextBurstShotTime_listenIndex = -1;
	pl.isReloading = TRUE;
	weapon_base_setWholeAttackDelay(pl, baseRef.fAnim_Reload_Duration);
	
	if(!arg_thisWeapon.iIronSight){
		TS_Weapons_ViewAnimation(baseRef.iAnim_Reload_Index, baseRef.fAnim_Reload_Duration );
	}else{
		TS_Weapons_ViewAnimation(baseRef.ironsightdata.iAnim_Reload_Index, baseRef.ironsightdata.fAnim_Reload_Duration );
	}
	
	//TAGGG TODO - third person model anim.
	//Animation_ReloadWeapon( self );
	
}//weapon_ironsight_Reload


void
weapon_gun_endOfReload(
	player pl, weapondata_gun_t* basePRef, weapondynamic_t arg_thisWeapon
){
	weapondata_gun_t baseRef = *basePRef;
	int ammoReserve = pl.ary_ammoTotal[baseRef.iAmmoDataID];
	
	if(!pl.weaponEquippedAkimbo){
		int ammoToFill = (baseRef.iClipMax - arg_thisWeapon.iClipLeft);
		if(ammoToFill <= ammoReserve){
			// ok
		}else{
			ammoToFill = ammoReserve;  //can't fill more than we got.
		}
		
		arg_thisWeapon.iClipLeft += ammoToFill;
		pl.ary_ammoTotal[baseRef.iAmmoDataID] -= ammoToFill;
	}else{
		// if akimbo, we have to fill baseRef.iClipLeft and iClipAkimboLeft.
		int ammoToFillClip1 = (baseRef.iClipMax - arg_thisWeapon.iClipLeft);
		int ammoToFillClip2 = (baseRef.iClipMax - arg_thisWeapon.iClipAkimboLeft);
		int totalAmmoToFill = ammoToFillClip1 + ammoToFillClip2;
		
		if(totalAmmoToFill <= ammoReserve){
			// well that was easy
		}else{
			float halfUp = ceil(ammoReserve/2);
			
			if(ammoToFillClip1 < halfUp ){
				// If we had enough ammo to fill clip1 to the top, put the remainder in clip2.
				ammoToFillClip2 = ammoReserve - ammoToFillClip1;
			}else if(ammoToFillClip2 < halfUp){
				ammoToFillClip1 = ammoReserve - ammoToFillClip2;
			}else{
				// both are above half?  Just divy it out
				ammoToFillClip1 = halfUp;  //ceil, in case an odd number is used, this one gets +1.
				ammoToFillClip2 = ammoReserve/2;
			}
		}// totalAmmoToFill <= ammoReserve compare
		
		printfline("***Akimbo ammo refill debug:  remaining before fill:%i  to fill left:%i right:%i", pl.ary_ammoTotal[baseRef.iAmmoDataID], ammoToFillClip1, ammoToFillClip2);
		
		arg_thisWeapon.iClipLeft += ammoToFillClip1;
		arg_thisWeapon.iClipAkimboLeft += ammoToFillClip2;
		pl.ary_ammoTotal[baseRef.iAmmoDataID] -= (ammoToFillClip1 + ammoToFillClip2);
	}// pl.weaponEquippedAkimbo check
	
}// weapon_gun_endOfReload


void
weapon_gun_endOfIronSight(
	player pl, weapondata_gun_t* basePRef, weapondynamic_t arg_thisWeapon
){
	printfline("weapon_ironsight_ToggleIronsight was:%i", arg_thisWeapon.iIronSight);
	if(arg_thisWeapon.iIronSight == 0){
		arg_thisWeapon.iIronSight = 1;
	}else{
		arg_thisWeapon.iIronSight = 0;
	}
	
	pl.isChangingIronsight = FALSE;
	SAVE_STATE(pl.isChangingIronsight);
}


// CRITICAL.  Good to go for Nuclide support!!!
// Given a pointer to some element of ary_weaponData or ary_akimboUpgradeData (weapon
// info), and the actual inventory space of the user, do the basic deploy behavior.
void
weapon_base_onEquip(
	player pl, weapondata_basic_t* basePRef, weapondynamic_t arg_thisWeapon
){
	weapondata_basic_t baseRef = *basePRef;
	
	printfline("weapon_base_onEquip: activeweap:%d sName:%s sName2:%s", pl.activeweapon, baseRef.sDisplayName, g_weapons[pl.activeweapon].name);
	
#ifdef CLIENT
	TS_SetViewModelFromStats();
	//sound(pl, CHAN_ITEM, "weapons/draw.wav", 1, ATTN_NORM, 100, SOUNDFLAG_PLAYER_COMMON);
	localsound("weapons/draw.wav", CHAN_AUTO, 1.0f);
	//printfline("weapon_base_onEquip: playing deploy anim");
#endif
	
	TS_Weapons_ViewAnimation(baseRef.iAnim_Deploy_Index, baseRef.fAnim_Deploy_Duration);
	
	pl.recentAkimboAttackChoice = BITS_AKIMBOCHOICE_NONE;
	pl.nextAkimboAttackPreference = BITS_AKIMBOCHOICE_LEFT;
	
	arg_thisWeapon.iIronSight = 0;   //reset ironsight each time.
	//TAGGG TODO - decision
	// If we notice any weapon keeps ironsight changes between picking different weapons / coming back,
	// this needs to stay specific to the weapon.  If it's always reset it may as well be specific
	// to the player though.
	
	weapon_base_setWholeAttackDelay(pl, baseRef.fAnim_Deploy_Duration);
}// weapon_base_onEquip


// really, just check to see if we're reloading or changing ironsight
// when w_attack_next expires.
void
weapon_gun_onThink(
	player pl, weapondata_gun_t* basePRef, weapondynamic_t arg_thisWeapon
){
	if(pl.w_attack_next <= 0){
		if(pl.isReloading){
			// end of reloading
			weapon_gun_endOfReload(pl, basePRef, arg_thisWeapon);
			pl.isReloading = FALSE;
		}
		if(pl.isChangingIronsight){
			weapon_gun_endOfIronSight(pl, basePRef, arg_thisWeapon);
		}
	}
}// weapon_gun_onThink


void
weapon_gun_fireBurstBullet(
	player pl, weapondata_gun_t* basePRef, weapondynamic_t arg_thisWeapon
){
	weapondata_gun_t basicRef = *(basePRef);
	float oldFireDelay = pl.w_attack_next;
	pl.w_attack_next = 0;
	pl.aryNextBurstShotTime_listenIndex++;
	
#ifdef CLIENT
	//printfline("What now2 %i m:%i", pl.aryNextBurstShotTime_listenIndex, pl.aryNextBurstShotTime_softLength);
#endif

	// this lets Weapons_Primary ignore 
	arg_thisWeapon.iFireMode = BITS_FIREMODE_NONE;
	
	Weapons_Primary();
	
	arg_thisWeapon.iFireMode = BITS_FIREMODE_BURST;
	
	// forget any changes to fire delay. HACKY.
	pl.w_attack_next = oldFireDelay;
	
	if(pl.aryNextBurstShotTime_listenIndex >= pl.aryNextBurstShotTime_softLength){
		// out of shots.
		pl.aryNextBurstShotTime_listenIndex = -1;
		pl.aryNextBurstShotTime_softLength = 0;
	}
}


// NOTE!  Meant to be called in addition to normal weapon_gun_onThink
// in a weapon's onThink method, do not replace that entirely
void
weapon_gun_onThink_burstFireLogic(
	player pl, weapondata_gun_t* basePRef, weapondynamic_t arg_thisWeapon
){
	weapondata_gun_t basicRef = *(basePRef);
	
	if(pl.aryNextBurstShotTime_listenIndex >= 0){
		//printfline("weapon_gun_onThink_burstFireLogic, lisenting: %.2f <= [%i]%.2f", pl.w_attack_next, pl.aryNextBurstShotTime_listenIndex, pl.aryNextBurstShotTime[pl.aryNextBurstShotTime_listenIndex]);
			
		if(pl.w_attack_next <= pl.aryNextBurstShotTime[pl.aryNextBurstShotTime_listenIndex] ){
			weapon_gun_fireBurstBullet(pl, basePRef, arg_thisWeapon);
		}
	}
}// weapon_gun_onThink


void
weapon_gun_onDrawHUD(player pl, weapondata_gun_t* basePRef, weapondynamic_t arg_thisWeapon){
#ifdef CLIENT
	weapondata_gun_t baseRef = *basePRef;
	
	//DUMMY
	vector vEquippedWeaponInfoDraw = [video_res[0] - 128 - 8, video_res[1] - 19 - 8];
	
	//int iBitsCurrentWeaponOpts = BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_FLASHLIGHT | BITS_WEAPONOPT_SCOPE;
	int iBitsCurrentWeaponOpts = arg_thisWeapon.iBitsUpgrade;
	
	int iCurrentWeaponOptsCount = 0;
	if(iBitsCurrentWeaponOpts & BITS_WEAPONOPT_SILENCER){
		//Note that if we have the silencer at all, it's alwas on.
		drawWeaponOptionBar(vEquippedWeaponInfoDraw, "Silencer", TRUE, 0.79f);
		vEquippedWeaponInfoDraw.y -= 20;
		iCurrentWeaponOptsCount++;
	}
	if(iBitsCurrentWeaponOpts & BITS_WEAPONOPT_LASERSIGHT){
		drawWeaponOptionBar(vEquippedWeaponInfoDraw, "Lasersight", (arg_thisWeapon.iBitsUpgrade_on & BITS_WEAPONOPT_LASERSIGHT), 0.79f);
		vEquippedWeaponInfoDraw.y -= 20;
		iCurrentWeaponOptsCount++;
	}
	if(iBitsCurrentWeaponOpts & BITS_WEAPONOPT_FLASHLIGHT){
		drawWeaponOptionBar(vEquippedWeaponInfoDraw, "Flashlight", (arg_thisWeapon.iBitsUpgrade_on & BITS_WEAPONOPT_FLASHLIGHT), 0.79f);
		vEquippedWeaponInfoDraw.y -= 20;
		iCurrentWeaponOptsCount++;
	}
	if(iBitsCurrentWeaponOpts & BITS_WEAPONOPT_SCOPE){
		drawWeaponOptionBar(vEquippedWeaponInfoDraw, "Scope", TRUE, 0.79f);
		vEquippedWeaponInfoDraw.y -= 20;
		iCurrentWeaponOptsCount++;
	}
	
	ammodata_t* ammoPRef = ary_ammoData[baseRef.iAmmoDataID];
	ammodata_t ammoRef = *ammoPRef;
	vector clrDraw;
	
	if(!pl.weaponEquippedAkimbo){
		// ammo:  clip count / total count (for the type of ammo)
		drawfill( vEquippedWeaponInfoDraw, [128, 19], clrPaleBlue, 0.86f - 0.60f );
		if(arg_thisWeapon.iClipLeft > 0){
			clrDraw = clrPaleBlue;
		}else{
			clrDraw = clrMedRed;
		}
		drawSpriteNumber(ary_LCD_numberSet, vEquippedWeaponInfoDraw.x + 2, vEquippedWeaponInfoDraw.y + 0, arg_thisWeapon.iClipLeft, 3, BITS_DIGITOPT_DEFAULT, clrDraw, 0.92f);
		Gfx_Text( [vEquippedWeaponInfoDraw.x + 64, vEquippedWeaponInfoDraw.y + 4], "/", vButtonFontSize, clrPaleBlue, 0.86f, DRAWFLAG_ADDITIVE, FONT_ARIAL_STD );
		if(pl.ary_ammoTotal[baseRef.iAmmoDataID] > 0){
			clrDraw = clrPaleBlue;
		}else{
			clrDraw = clrMedRed;
		}
		
		drawSpriteNumber(ary_LCD_numberSet, vEquippedWeaponInfoDraw.x + 94, vEquippedWeaponInfoDraw.y + 0, pl.ary_ammoTotal[baseRef.iAmmoDataID], 3, BITS_DIGITOPT_DEFAULT, clrDraw, 0.92f);
		vEquippedWeaponInfoDraw.y -= 20;
		
	}else{
		// TODO - Could make a CVar for the current way (drawing akimbo weapon clips
		// per weapon separately) or combined like they were one weapon (original TS
		// way). Regardless of being combined or not, that's only how they're
		// portrayed in the HUD here.  With 12-ammo-clipped weapons, combined does
		// not mean a single one can fire 24 times without reloading.
		
		// drawing from the bottom, so akimbo (right) gun comes first.
		// ammo:  clip count / total count (for the type of ammo)
		drawfill( vEquippedWeaponInfoDraw, [128, 19], clrPaleBlue, 0.86f - 0.60f );
		if(arg_thisWeapon.iClipAkimboLeft > 0){
			clrDraw = clrPaleBlue;
		}else{
			clrDraw = clrMedRed;
		}
		drawSpriteNumber(ary_LCD_numberSet, vEquippedWeaponInfoDraw.x + 2, vEquippedWeaponInfoDraw.y + 0, arg_thisWeapon.iClipAkimboLeft, 3, BITS_DIGITOPT_DEFAULT, clrDraw, 0.92f);
		Gfx_Text( [vEquippedWeaponInfoDraw.x + 64, vEquippedWeaponInfoDraw.y + 4], "/", vButtonFontSize, clrPaleBlue, 0.86f, DRAWFLAG_ADDITIVE, FONT_ARIAL_STD );
		if(pl.ary_ammoTotal[baseRef.iAmmoDataID] > 0){
			clrDraw = clrPaleBlue;
		}else{
			clrDraw = clrMedRed;
		}
		drawSpriteNumber(ary_LCD_numberSet, vEquippedWeaponInfoDraw.x + 94, vEquippedWeaponInfoDraw.y + 0, pl.ary_ammoTotal[baseRef.iAmmoDataID], 3, BITS_DIGITOPT_DEFAULT, clrDraw, 0.92f);
		vEquippedWeaponInfoDraw.y -= 20;
		
		// ammo:  clip count / total count (for the type of ammo)
		drawfill( vEquippedWeaponInfoDraw, [128, 19], clrPaleBlue, 0.86f - 0.60f );
		if(arg_thisWeapon.iClipLeft > 0){
			clrDraw = clrPaleBlue;
		}else{
			clrDraw = clrMedRed;
		}
		drawSpriteNumber(ary_LCD_numberSet, vEquippedWeaponInfoDraw.x + 2, vEquippedWeaponInfoDraw.y + 0, arg_thisWeapon.iClipLeft, 3, BITS_DIGITOPT_DEFAULT, clrDraw, 0.92f);
		Gfx_Text( [vEquippedWeaponInfoDraw.x + 64, vEquippedWeaponInfoDraw.y + 4], "/", vButtonFontSize, clrPaleBlue, 0.86f, DRAWFLAG_ADDITIVE, FONT_ARIAL_STD );
		if(pl.ary_ammoTotal[baseRef.iAmmoDataID] > 0){
			clrDraw = clrPaleBlue;
		}else{
			clrDraw = clrMedRed;
		}
		drawSpriteNumber(ary_LCD_numberSet, vEquippedWeaponInfoDraw.x + 94, vEquippedWeaponInfoDraw.y + 0, pl.ary_ammoTotal[baseRef.iAmmoDataID], 3, BITS_DIGITOPT_DEFAULT, clrDraw, 0.92f);
		vEquippedWeaponInfoDraw.y -= 20;
		
		
	}// pl.weaponEquippedAkimbo check
	
	// What firemode is the player using for this weapon now?
	int* fireModeVar;
	if(!pl.weaponEquippedAkimbo){
		fireModeVar = &arg_thisWeapon.iFireMode;
	}else{
		fireModeVar = &arg_thisWeapon.iFireModeAkimbo;
	}
	
	string fireModeName;
	
	if(!pl.weaponEquippedAkimbo){
		fireModeName = getFiremodeName((*fireModeVar));
	}else{
		fireModeName = getAkimboFiremodeName((*fireModeVar));
	}
	
	// fire mode name?
	// IMPORTANT. If this weapon is akimbo we have to use the "getAkimboFiremodeName"
	// variant!
	drawfill( vEquippedWeaponInfoDraw, [128, 19], clrPaleBlue, 0.86f - 0.60f );
	Gfx_Text( [vEquippedWeaponInfoDraw.x + 2, vEquippedWeaponInfoDraw.y + 4], fireModeName, vButtonFontSize, clrPaleBlue, 0.86f, DRAWFLAG_ADDITIVE, FONT_ARIAL_STD );
	vEquippedWeaponInfoDraw.y -= 20;
	
	// ammo type name
	drawfill( vEquippedWeaponInfoDraw, [128, 19], clrPaleBlue, 0.86f - 0.60f );
	Gfx_Text( [vEquippedWeaponInfoDraw.x + 2, vEquippedWeaponInfoDraw.y + 4], ammoRef.sDisplayName, vButtonFontSize, clrPaleBlue, 0.86f, DRAWFLAG_ADDITIVE, FONT_ARIAL_STD );
	vEquippedWeaponInfoDraw.y -= 20;
	
	// title
	drawfill( vEquippedWeaponInfoDraw, [128, 19], clrPaleBlue, 0.86f - 0.60f );
	Gfx_Text( [vEquippedWeaponInfoDraw.x + 2, vEquippedWeaponInfoDraw.y + 4], baseRef.sDisplayName, vButtonFontSize, clrPaleBlue, 0.98f, DRAWFLAG_ADDITIVE, FONT_ARIAL_STD );
	vEquippedWeaponInfoDraw.y -= 20;
#endif
}// weapon_gun_onDrawHUD


void
weapon_throwable_onDrawHUD(player pl, weapondata_throwable_t* basePRef, weapondynamic_t arg_thisWeapon){
#ifdef CLIENT
	weapondata_throwable_t baseRef = *basePRef;
	
	// DUMMY
	vector vEquippedWeaponInfoDraw = [video_res[0] - 128 - 8, video_res[1] - 19 - 8];
	
	int iBitsCurrentWeaponOpts = arg_thisWeapon.iBitsUpgrade;
	vector clrDraw;
	clrDraw = clrPaleBlue;
	
	// draw the count
	drawfill( vEquippedWeaponInfoDraw, [128, 19], clrPaleBlue, 0.86f - 0.60f );
	drawSpriteNumber(ary_LCD_numberSet, vEquippedWeaponInfoDraw.x + 128 - 2 - 11*3, vEquippedWeaponInfoDraw.y + 0, arg_thisWeapon.iCount, 3, BITS_DIGITOPT_DEFAULT, clrDraw, 0.92f);
	vEquippedWeaponInfoDraw.y -= 20;
		
	// title
	drawfill( vEquippedWeaponInfoDraw, [128, 19], clrPaleBlue, 0.86f - 0.60f );
	Gfx_Text( [vEquippedWeaponInfoDraw.x + 2, vEquippedWeaponInfoDraw.y + 4], baseRef.sDisplayName, vButtonFontSize, clrPaleBlue, 0.98f, DRAWFLAG_ADDITIVE, FONT_ARIAL_STD );
	vEquippedWeaponInfoDraw.y -= 20;
#endif
}// weapon_throwable_onDrawHUD



void
weapon_melee_onDrawHUD(player pl, weapondata_melee_t* basePRef, weapondynamic_t arg_thisWeapon){
#ifdef CLIENT
	weapondata_melee_t baseRef = *basePRef;
	
	// DUMMY
	vector vEquippedWeaponInfoDraw = [video_res[0] - 128 - 8, video_res[1] - 19 - 8];
	
	int iBitsCurrentWeaponOpts = arg_thisWeapon.iBitsUpgrade;
	vector clrDraw;
	clrDraw = clrPaleBlue;
	
	// empty box?  ok.
	drawfill( vEquippedWeaponInfoDraw, [128, 19], clrPaleBlue, 0.86f - 0.60f );
	// drawSpriteNumber(ary_LCD_numberSet, vEquippedWeaponInfoDraw.x + 128 - 2 - 11*3, vEquippedWeaponInfoDraw.y + 0, arg_thisWeapon.iCount, 3, BITS_DIGITOPT_DEFAULT, clrDraw, 0.92f);
	vEquippedWeaponInfoDraw.y -= 20;
		
	// title
	drawfill( vEquippedWeaponInfoDraw, [128, 19], clrPaleBlue, 0.86f - 0.60f );
	Gfx_Text( [vEquippedWeaponInfoDraw.x + 2, vEquippedWeaponInfoDraw.y + 4], baseRef.sDisplayName, vButtonFontSize, clrPaleBlue, 0.98f, DRAWFLAG_ADDITIVE, FONT_ARIAL_STD );
	vEquippedWeaponInfoDraw.y -= 20;
#endif
}// weapon_throwable_onDrawHUD



BOOL
dummy1(player pl, weapondynamic_t arg_thisWeapon, BOOL hasAmmo){
	return FALSE;
}
void
dummy2(player pl, weapondynamic_t arg_thisWeapon){
	
}
BOOL
dummy2b(player pl, weapondynamic_t arg_thisWeapon){
	return FALSE;
}

//blank weapon.
weapondata_basic_t weapon_NONE =
{
	WEAPONDATA_TYPEID_BASIC,
	"_NONE_",
	"",
	"",
	"",
	"",
	"",
	dummy1,
	dummy1,
	dummy1,
	dummy1,
	dummy2,
	dummy2b,
	dummy2,
	dummy2,
	dummy2,
	dummy2,
	0,
	0,
	0.0f,
	0.0f,  //fire delay. this is most certainly wrong. find something more accurate later.
	0.0f,
	FALSE,
	BITS_WEAPONOPT_NONE,
	BITS_WEAPONOPT_NONE,
	0,
	0,
	0, //BUYCATEGORY_,
	0, //inv slot. normal minimum is 1
	{0.022000, 1.500000, 0.007000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE
};


//blank weapon.
weapondata_basic_t weapon_NONE_akimbo =
{
	WEAPONDATA_TYPEID_BASIC,
	"_NONE_",
	"",
	"",
	"",
	"",
	"",
	dummy1,
	dummy1,
	dummy1,
	dummy1,
	dummy2,
	dummy2b,
	dummy2,
	dummy2,
	dummy2,
	dummy2,
	0,
	0,
	0.0f,
	0.0f,  //fire delay. this is most certainly wrong. find something more accurate later.
	0.0f,
	FALSE,
	BITS_WEAPONOPT_NONE,
	BITS_WEAPONOPT_NONE,
	0,
	0,
	0, //BUYCATEGORY_,
	0, //inv slot. normal minimum is 1
	{0.022000, 1.500000, 0.007000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE
};



//include after all weapons have been defined? (that is, compile weapon.c (here), then weapon-specific files, then a new file containing setupWeaponData)
//Or would it make sense to extern the structs here and keep this method in the same file?
//	(compile weapon-specific files first, then weapon.c)
void
setupWeaponData(void){
	
	// for reference, old way.  REDO THAT MACRO to involve g_weapons, described more below
	//#define ASSIGN_WEAPONDATA(arg_constName) ary_weaponData[WEAPON_ID::##arg_constName] = (weapondata_basic_t*) &weapon_##arg_constName;

	//TAGGG - CRITICAL
	// If there are any issues with this, make copy methods to assign the slots.
	// Or try the initializer array format  g_weapons = {w_karate, w_whatever}... etc.   w_karate is not the first weapon at all though.
	// Really just do it by ID's with a new ASSIGN_WEAWPONDATA because init lists for offsets that may skip around sounds hellish

	g_weapons[WEAPON_ID::NONE] = w_null;
	g_weapons[WEAPON_ID::Karate] = w_karate;
	
	g_weapons[WEAPON_ID::Glock18] = w_glock18;
	g_weapons[WEAPON_ID::SOCOM_MK23] = w_socom_mk23;
	g_weapons[WEAPON_ID::SOCOM_MK23_akimbo] = w_socom_mk23_akimbo;
	g_weapons[WEAPON_ID::DesertEagle] = w_deserteagle;
	
	g_weapons[WEAPON_ID::FiveSeven] = w_fiveseven;
	g_weapons[WEAPON_ID::FiveSeven_akimbo] = w_fiveseven_akimbo;
	g_weapons[WEAPON_ID::Beretta] = w_beretta;
	g_weapons[WEAPON_ID::Beretta_akimbo] = w_beretta_akimbo;
	
	g_weapons[WEAPON_ID::AkimboColts] = w_akimbocolts;
	
	g_weapons[WEAPON_ID::Glock20] = w_glock20;
	g_weapons[WEAPON_ID::RugerMK1] = w_rugermk1;
	g_weapons[WEAPON_ID::RagingBull] = w_ragingbull;
	g_weapons[WEAPON_ID::ContenderG2] = w_contenderg2;
	
	g_weapons[WEAPON_ID::MiniUzi] = w_miniuzi;
	g_weapons[WEAPON_ID::MiniUzi_akimbo] = w_miniuzi_akimbo;
	g_weapons[WEAPON_ID::MP5SD] = w_mp5sd;
	g_weapons[WEAPON_ID::MP5K] = w_mp5k;
	g_weapons[WEAPON_ID::STEYR_TMP] = w_steyr_tmp;
	g_weapons[WEAPON_ID::HK_PDW] = w_hk_pdw;  //MP7-PDW
	g_weapons[WEAPON_ID::UMP] = w_ump;
	g_weapons[WEAPON_ID::Skorpion] = w_skorpion;
	g_weapons[WEAPON_ID::Skorpion_akimbo] = w_skorpion_akimbo;
	g_weapons[WEAPON_ID::MAC10] = w_mac10;
	
	
	g_weapons[WEAPON_ID::M4A1] = w_m4a1;
	g_weapons[WEAPON_ID::AK47] = w_ak47;
	g_weapons[WEAPON_ID::STEYR_AUG] = w_steyr_aug;
	g_weapons[WEAPON_ID::M16A4] = w_m16a4;
	g_weapons[WEAPON_ID::Barrett_M82] = w_barrett_m82;
	
	g_weapons[WEAPON_ID::BenelliM3] = w_benellim3;
	g_weapons[WEAPON_ID::SPAS12] = w_spas12;
	g_weapons[WEAPON_ID::USAS12] = w_usas12;
	g_weapons[WEAPON_ID::Mossberg500] = w_mossberg500;
	g_weapons[WEAPON_ID::SawedOff] = w_sawedoff;
	
	g_weapons[WEAPON_ID::M61Grenade] = w_m61grenade;
	g_weapons[WEAPON_ID::CombatKnife] = w_combatknife;
	g_weapons[WEAPON_ID::SealKnife] = w_sealknife;
	g_weapons[WEAPON_ID::Katana] = w_katana;
	g_weapons[WEAPON_ID::M60] = w_m60;
	
	
	
/////////////////////////////////////////////////////////
	
	ASSIGN_AMMODATA(NONE)
	ASSIGN_AMMODATA(_9x19mm)
	ASSIGN_AMMODATA(_45Acp)
	ASSIGN_AMMODATA(_p50AE)

	ASSIGN_AMMODATA(_5p7x28)
	
	ASSIGN_AMMODATA(_10mmAUTO)
	ASSIGN_AMMODATA(_p22LR)
	ASSIGN_AMMODATA(_p454Casull)
	ASSIGN_AMMODATA(_5p56Nato)
	ASSIGN_AMMODATA(_7p62x39mm)
	ASSIGN_AMMODATA(_50BMG)
	ASSIGN_AMMODATA(_SHELLS)
	ASSIGN_AMMODATA(_32ACP)
	ASSIGN_AMMODATA(_7p62x51mm)
	
	//ary_weaponData[WEAPON_ID::Glock18] = (weapondata_generic_t*) &weapon_Glock18;
	
	ASSIGN_WEAPONDATA(NONE)
	ASSIGN_AKIMBOUPGRADEDATA(NONE)
	
	
	ASSIGN_WEAPONDATA(Karate)
	ASSIGN_WEAPONDATA(Glock18)
	
	ASSIGN_WEAPONDATA(SOCOM_MK23)
	ASSIGN_WEAPONDATA(SOCOM_MK23_akimbo)
	ASSIGN_AKIMBOUPGRADEDATA(SOCOM_MK23)
	
	ASSIGN_WEAPONDATA(DesertEagle)
	
	ASSIGN_WEAPONDATA(FiveSeven)
	ASSIGN_WEAPONDATA(FiveSeven_akimbo)
	ASSIGN_AKIMBOUPGRADEDATA(FiveSeven)
	ASSIGN_WEAPONDATA(Beretta)
	ASSIGN_WEAPONDATA(Beretta_akimbo)
	ASSIGN_AKIMBOUPGRADEDATA(Beretta)
	
	ASSIGN_WEAPONDATA(AkimboColts)
	
	ASSIGN_WEAPONDATA(Glock20)
	ASSIGN_WEAPONDATA(RugerMK1)
	ASSIGN_WEAPONDATA(RagingBull)
	ASSIGN_WEAPONDATA(ContenderG2)
	
	
	ASSIGN_WEAPONDATA(MiniUzi)
	ASSIGN_WEAPONDATA(MiniUzi_akimbo)
	ASSIGN_AKIMBOUPGRADEDATA(MiniUzi)
	
	ASSIGN_WEAPONDATA(MP5SD)
	ASSIGN_WEAPONDATA(MP5K)
	
	ASSIGN_WEAPONDATA(STEYR_TMP)
	ASSIGN_WEAPONDATA(HK_PDW)
	ASSIGN_WEAPONDATA(UMP)
	
	ASSIGN_WEAPONDATA(Skorpion)
	ASSIGN_WEAPONDATA(Skorpion_akimbo)
	ASSIGN_AKIMBOUPGRADEDATA(Skorpion)
	
	ASSIGN_WEAPONDATA(MAC10)
	
	ASSIGN_WEAPONDATA(M4A1)
	ASSIGN_WEAPONDATA(AK47)
	ASSIGN_WEAPONDATA(STEYR_AUG)
	ASSIGN_WEAPONDATA(M16A4)
	ASSIGN_WEAPONDATA(Barrett_M82)
	
	ASSIGN_WEAPONDATA(BenelliM3)
	ASSIGN_WEAPONDATA(USAS12)
	ASSIGN_WEAPONDATA(SPAS12)
	ASSIGN_WEAPONDATA(Mossberg500)
	ASSIGN_WEAPONDATA(SawedOff)
	
	ASSIGN_WEAPONDATA(M61Grenade)
	ASSIGN_WEAPONDATA(CombatKnife)
	ASSIGN_WEAPONDATA(M60)
	ASSIGN_WEAPONDATA(Katana)
	ASSIGN_WEAPONDATA(SealKnife)
	
}//setupWeaponData



weapondata_basic_t*
getWeaponData(int arg_weaponID, BOOL arg_akimbo){
	weapondata_basic_t* basicP;
	
	// no cap check for now
	if(arg_weaponID >= 0){
		basicP = (weapondata_basic_t*) ary_weaponData[arg_weaponID];
		
		// No need to check for this here, weapon ID's received (often pl.activeweapon) are 
		// already set to the akimbo versions if they're wanted elsewhere.
		/*
		if(!arg_akimbo){
			// that was easy.  Fall thru, leave basicP as it is.
		}else{
			// oh.
			int myAkimboUpgradeID = (*basicP).iAkimboID;
			if(myAkimboUpgradeID > 0 && myAkimboUpgradeID < WEAPON_AKIMBO_UPGRADE_ID::LAST_ID ){
				int linearAkimboID = ary_AKIMBO_UPGRADE_TO_WEAPON[myAkimboUpgradeID];
				basicP = (weapondata_basic_t*) ary_weaponData[linearAkimboID];
			}
			// otherwise, leave basicP as it is
		}
		*/
		
	}else{
		// ???
		basicP = NULL;
	}
	
	return basicP;
}

weapondata_basic_t*
getWeaponData_Singular(int arg_weaponID)
{
	// Not quite this simple.
	// See if we landed on the akimbo form of a weapon.  If so, backtrack to
	// its singular form.
	//return (weapondata_basic_t*) ary_weaponData[arg_weaponID];
	
	weapondata_basic_t* basicP;
	
	// no cap check for now
	if(arg_weaponID >= 0){
		basicP = (weapondata_basic_t*) ary_weaponData[arg_weaponID];
		
		if( (*basicP).iAkimboID >= 0){
			// None or positive (singular variant that refers to an akimbo form)?  Not interested
		}else{
			// < 0?  Negate it for the intention and use to go from akimbo -> singular.
			int mySingularUpgradeID = -(*basicP).iAkimboID;
			basicP = (weapondata_basic_t*) ary_weaponData[mySingularUpgradeID];
		}
	}else{
		// ???
		basicP = NULL;
	}
	
	return basicP;
}

// If this weapon does not use ammo, this returns -1.
int
getAmmoTypeOfWeapon(int arg_weaponID)
{
	weapondata_basic_t* basicPointer = (weapondata_basic_t*)ary_weaponData[arg_weaponID];
	weapondata_basic_t basicRef = *basicPointer;
	
	if(basicRef.typeID == WEAPONDATA_TYPEID_GUN || basicRef.typeID == WEAPONDATA_TYPEID_IRONSIGHT){
		weapondata_gun_t gunRef = *((weapondata_gun_t*)basicPointer);
		return gunRef.iAmmoDataID;
	}else{
		return -1;  // does not use ammo for all we care.
	}
	
}// getAmmoTypeOfWeapon



// check for being redundant with the events_custom.qc (whatever) ejectshell - like
// method!
// Could likely combine this better with that alternate way, but both should
// effectively do the exact same thing.
// This is based off what the HL glock does, adjust with custom shell-choices per
// different weapons that use them.
// Is HL's "w_shotgun_ejectshell" even any different from this besides shell-model
// choice? Not that this is an exact match for how TS does any shell eject logic,
// maybe, but an example of how to do it at all in FTE at least, exactly-accurate
// TS shell ejection is not a huge priority.
// In fact it isn't even supported serverside yet I think?
// Try testing FreeHL or FreeCS, do you see your own shells in thirdperson on firing
// and (multiplayer) do other players see your shells on firing?

// (based off w_glock_ejectshell)
#ifdef CLIENT
void
w_ejectshell_pistol(void)
{
	static void w_glock_ejectshell_death(void) {
		remove(self);
	}
	static void w_glock_ejectshell_touch(void) {
		if (other == world)
			Sound_Play(self, CHAN_BODY, "modelevent_shell.land");
	}
	entity eShell = spawn();
	setmodel(eShell, "models/shell.mdl");
	eShell.solid = SOLID_BBOX;
	eShell.movetype = MOVETYPE_BOUNCE;
	eShell.drawmask = MASK_ENGINE;
	eShell.angles = [pSeat->m_eViewModel.angles[0], pSeat->m_eViewModel.angles[1], 0];
	eShell.velocity = pSeat->m_vecPredictedVelocity;

	makevectors(pSeat->m_eViewModel.angles);
	eShell.velocity += (v_forward * 0);
	eShell.velocity += (v_right * 80);
	eShell.velocity += (v_up * 100);
	eShell.touch = w_glock_ejectshell_touch;

	eShell.avelocity = [0,45,900];
	eShell.think = w_glock_ejectshell_death;
	eShell.nextthink = time + 2.5f;
	setsize(eShell, [0,0,0], [0,0,0]);
	setorigin(eShell, pSeat->m_eViewModel.origin + (v_forward * 26) + (v_right * 8) + (v_up * -4));
}


// also clientside only, dealing with configs
void
copyWeaponConfig(weaponconfig_weapon_t* arg_dest, weaponconfig_weapon_t* arg_src)
{
	arg_dest->weaponID = arg_src->weaponID;
	arg_dest->weaponTypeID = arg_src->weaponTypeID;
	arg_dest->iBitsUpgrade = arg_src->iBitsUpgrade;
	arg_dest->iCount = arg_src->iCount;
	arg_dest->iPrice = arg_src->iPrice;
	arg_dest->iSlots = arg_src->iSlots;
}//copyWeaponConfig


void
copyConfig(weaponconfig_data_t* arg_dest, weaponconfig_data_t* arg_src)
{
	arg_dest->ary_myWeapons_softMax = arg_src->ary_myWeapons_softMax;
	for(int i = 0; i < arg_src->ary_myWeapons_softMax; i++){
		copyWeaponConfig(&arg_dest.ary_myWeapons[i], &arg_src.ary_myWeapons[i]);
	}
	for(int i = 0; i < AMMO_ID::LAST_ID; i++){
		arg_dest->ary_ammoTotal[i] = arg_src->ary_ammoTotal[i];
	}
	arg_dest->iTotalSlots = arg_src->iTotalSlots;
	arg_dest->iTotalPrice = arg_src->iTotalPrice;
}//copyConfig

#endif // CLIENT
