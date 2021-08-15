/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */
 
 
 
 
//#define FORCE_NETWORK_ALL_INVENTORY


/* all potential SendFlags bits we can possibly send */
enumflags
{
	PLAYER_KEEPALIVE,
	PLAYER_MODELINDEX,
	PLAYER_ORIGIN,
	PLAYER_ORIGIN_Z,
	PLAYER_ANGLES_X,
	PLAYER_ANGLES_Y,
	PLAYER_COLORMAP,
	PLAYER_VELOCITY,
	PLAYER_VELOCITY_Z,
	PLAYER_FLAGS,
	PLAYER_WEAPON,
	PLAYER_ITEMS,
	PLAYER_HEALTH,
	PLAYER_ARMOR,
	PLAYER_MOVETYPE,
	PLAYER_VIEWOFS,
	PLAYER_TOPFRAME,
	PLAYER_BOTTOMFRAME,
	PLAYER_AMMO1,
	PLAYER_AMMO2,
	PLAYER_AMMO3,
	PLAYER_UNUSED1,
	PLAYER_UNUSED2
};


// player class wuz here



//void player::dummyBufferMethod(void){}


#ifdef CLIENT
void Weapons_AmmoUpdate(entity);
/*
=================
player::ReceiveEntity
=================
*/
void
player::ReceiveEntity(float new, float fl)
{
	/* the generic client attributes */
	base_player::ReceiveEntity(new, fl);

	/* animation */
	if (fl & PLAYER_TOPFRAME) {
		anim_top = readbyte();
		anim_top_time = readfloat();
		anim_top_delay = readfloat();
	}
	if (fl & PLAYER_BOTTOMFRAME) {
		anim_bottom = readbyte();
		anim_bottom_time = readfloat();
	}
	
	int i;
	float temp_flViewModelFrame;
	
	temp_flViewModelFrame = readfloat();
	
	
	// TODO - any more sophistication needed?  laser-lock versions?  custom idle delays?  etc.?
	
	// do we need to do this here, I: forget, I don't think so
	/*
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	*/
	/*
	//pSeat->m_eViewModel.frame = (float)iSequence;
	if(pSeat->m_eViewModel.frame != temp_flViewModelFrame){
		
		// !!! Re-enable this to allow server-client viewmodel sequence corrections, in case
		// they go out-of-sync compared to what the server expects the client to be doing.
		// This still needs better support for other TS_Weapons_ViewAnimation calls
		// (Bad to assume that the plain variant was always the one called)
		
		printfline("***VIEWMODEL FRAME SYNC ISSUE CORRECTED: was:%d suggested:%d", pSeat->m_eViewModel.frame, temp_flViewModelFrame);
		// NOTE - this var has been abandoned, Nuclide's w_idle_next is used instead.
		//if(temp_nextViewModelAnimationTime <= 0 || temp_nextViewModelAnimationTime == 255){
		//	temp_nextViewModelAnimationTime = 1;  // ???
		//}else{
		//	temp_nextViewModelAnimationTime = temp_nextViewModelAnimationTime + time;
		//}
		
		TS_Weapons_ViewAnimation(temp_flViewModelFrame, w_idle_next);
	}
	*/



	//TAGGG - REPLACED.
	/*
	if (fl & PLAYER_AMMO1) {
		glock_mag = readbyte();
		mp5_mag = readbyte();
		python_mag = readbyte();
		shotgun_mag = readbyte();
		crossbow_mag = readbyte();
		rpg_mag = readbyte();
		satchel_chg = readbyte();
	}
	
	if (fl & PLAYER_AMMO2) {
		ammo_9mm = readbyte();
		ammo_357 = readbyte();
		ammo_buckshot = readbyte();
		ammo_bolt = readbyte();
		ammo_rocket = readbyte();
		ammo_uranium = readbyte();
		ammo_handgrenade = readbyte();
		ammo_satchel = readbyte();
		ammo_tripmine = readbyte();
		ammo_snark = readbyte();
		ammo_hornet = readbyte();
	}

	if (fl & PLAYER_AMMO3) {
		ammo_m203_grenade = readbyte();
		ammo_gauss_volume = readbyte();
		ammo_rpg_state = readbyte();
		mode_tempstate = readbyte();
	}

	if (fl & PLAYER_AMMO1 || fl & PLAYER_AMMO2 || fl & PLAYER_AMMO3)
		Weapons_AmmoUpdate(this);
	*/
	
	
	
	/////////////////////////////////////////////////////
	
	iState = readfloat();
	
	int inventoryEquippedIndex_temp = readbyte();
	
	// Overflow can do funny things. -1 comes as 255 because thats how bits work
	// Of course if we have over (or exactly) 255 weapons this would not be good.
	// we'd run out of room for those 255+ weapons anyway.
	if(inventoryEquippedIndex_temp == 255){
		inventoryEquippedIndex_temp = -1;
	}
	//if(oldPlayerWeapEq != inventoryEquippedIndex){
	//	printfline("WELL hey WHAT:%i new:%i", oldPlayerWeapEq, inventoryEquippedIndex);
	//}
	
	// important to keep pl.activeweapon in sync
	inventoryEquippedIndex = inventoryEquippedIndex_temp;
	//setInventoryEquippedIndex(inventoryEquippedIndex_temp);
	
	// Somehow this is atrocious.
	/*
	if(inventoryEquippedIndex_temp != inventoryEquippedIndex){
		setInventoryEquippedIndex(inventoryEquippedIndex_temp);
	}
	*/
	
	weaponEquippedAkimbo = readbyte();
	w_attack_akimbo_next = readfloat();
	isReloading = readbyte();
	isChangingIronsight = readbyte();
	
	//flZoomTarget = readfloat();
	float tempThing = readfloat();
	/*
	if(tempThing != flZoomTarget){
		printfline("flZoomTarget change! %.2f - %.2f", flZoomTarget, tempThing);
	}
	*/
	// That's a good thing, yes?
	if(!equippedWeaponWaitingForCallback){
		flZoomTarget = tempThing;
	}
	
	iZoomLevel = readbyte();
	nextAkimboAttackPreference = readbyte();
	akimboDualFireToleranceTime = readfloat();
	grenadeFireIndex = readbyte() - 1;
	bGrenadeToss = readbyte();
	
	
	armor = readbyte();
	iTotalSlots = readbyte();
	
	fAccuracyKickback = readfloat();
	
	fMoveBlockDelay = readfloat();
	fUncrouchBlockDelay = readfloat();
	fKarateStamina = readfloat();
	
	
	iMeleeCycler = readbyte();
	
	//vViewAngleOffsetTarget[0] = readcoord();
	//vViewAngleOffsetTarget[1] = readcoord();
	//vViewAngleOffsetTarget[2] = readcoord();
	
	
	
	shotgunReloadIndex = readbyte();
	shotgunAddAmmoTime = readfloat();
	shotgunAddAmmoSoundTime = readfloat();
	
	//doFiremodeChange = readbyte();
	
	
	
	ary_myWeapons_softMax = readbyte();
	
	
	this.completeInventorySend = readbyte();
	
#ifdef FORCE_NETWORK_ALL_INVENTORY
	completeInventorySend = TRUE;
#endif
	
	if(this.completeInventorySend){
		for(i = 0; i < ary_myWeapons_softMax; i++){
			ReceiveEntity_ary_myWeapons(i);
		}
		for(i = 0; i < AMMO_ID::LAST_ID; i++){
			ary_ammoTotal[i] = readlong();
		}
	}else if(fl & PLAYER_UNUSED1){
		
		i = inventoryEquippedIndex;
		/// could this ever be -1?
		if(i != -1){
			ReceiveEntity_ary_myWeapons(i);

			int myAmmoType = getAmmoTypeOfWeapon(this.activeweapon);
			if(myAmmoType != -1){
				i = myAmmoType;
				//UNNECESSARY. This array is of fixed length, so known at all times.
				//WriteByte(MSG_ENTITY, ary_ammoTotal_softMax);
				//for(i = 0; i < AMMO_ID::LAST_ID; i++){
					// See serverside equivalent, too much info was lost from some pools being over 255
					// (well I guess that's all there is to it)
					ary_ammoTotal[i] = readlong();
				//}
			}
		}
	}
	/////////////////////////////////////////////////////
	
	

	// TODO! Check for any change in ammo values like this:
	//    if (fl & PLAYER_AMMO1 || fl & PLAYER_AMMO2 || fl & PLAYER_AMMO3)
	Weapons_AmmoUpdate(this);


	setorigin(this, origin);
}

void player::ReceiveEntity_ary_myWeapons(int i){
	
	// TODO: IDEA.  Only send updates for the currently equipped weapon, maybe the previously equipped one
	// a few frames too?  Unsure.
	ary_myWeapons[i].weaponID = readbyte();
	ary_myWeapons[i].weaponTypeID = readbyte();
	ary_myWeapons[i].iBitsUpgrade = readbyte();
	ary_myWeapons[i].iCount = readbyte();
	//ary_myWeapons[i].iPrice = readbyte();
	//ary_myWeapons[i].iSlots = readbyte();
	ary_myWeapons[i].iClipLeft = readbyte();
	ary_myWeapons[i].iClipAkimboLeft = readbyte();
	ary_myWeapons[i].iBitsUpgrade_on = readbyte();
	
	int newFir = readbyte();
	
#if defined(FIREMODE_PREDICTION_TEST)
	if(i == this.inventoryEquippedIndex && ary_myWeapons[i].iFireMode != newFir){
		printfline("!!! player::ReceiveEntity, iFireMode update, changed firemode, WAS: %i NOW: %i", ary_myWeapons[i].iFireMode, newFir);
	}
	if(time >= this.ignoreFiremodeReceiveTime){
		printfline("X Change blocked, too soon");
		ary_myWeapons[i].iFireMode = newFir;
	}
#else
	ary_myWeapons[i].iFireMode = newFir;
#endif
	
	ary_myWeapons[i].iFireModeAkimbo = readbyte();
	ary_myWeapons[i].iIronSight = readbyte();
	ary_myWeapons[i].iForceBodygroup1Submodel = readbyte();
	ary_myWeapons[i].bNeedsPump = readbyte();

}





/*
=================
player::PredictPreFrame

Save the last valid server values away in the _net variants of each field
so we can roll them back later.
=================
*/
void
player::PredictPreFrame(void)
{
	/* the generic client attributes */
	base_player::PredictPreFrame();
	
	// client's way of calling prethink
	preThink();

	SAVE_STATE(anim_top);
	SAVE_STATE(anim_top_delay);
	SAVE_STATE(anim_top_time);
	SAVE_STATE(anim_bottom);
	SAVE_STATE(anim_bottom_time);
	
	
/*
	SAVE_STATE(glock_mag);
	SAVE_STATE(mp5_mag);
	SAVE_STATE(python_mag);
	SAVE_STATE(shotgun_mag);
	SAVE_STATE(crossbow_mag);
	SAVE_STATE(rpg_mag);
	SAVE_STATE(satchel_chg);
	
	SAVE_STATE(ammo_9mm);
	SAVE_STATE(ammo_357);
	SAVE_STATE(ammo_buckshot);
	SAVE_STATE(ammo_bolt);
	SAVE_STATE(ammo_rocket);
	SAVE_STATE(ammo_uranium);
	SAVE_STATE(ammo_handgrenade);
	SAVE_STATE(ammo_satchel);
	SAVE_STATE(ammo_tripmine);
	SAVE_STATE(ammo_snark);
	SAVE_STATE(ammo_hornet);

	SAVE_STATE(ammo_m203_grenade);
	SAVE_STATE(ammo_gauss_volume);
	SAVE_STATE(ammo_rpg_state);
	SAVE_STATE(mode_tempstate);
	*/
	
	SAVE_STATE(iState);
	SAVE_STATE(inventoryEquippedIndex);
	SAVE_STATE(weaponEquippedAkimbo);
	SAVE_STATE(w_attack_akimbo_next);
	SAVE_STATE(isReloading);
	SAVE_STATE(isChangingIronsight);
	SAVE_STATE(flZoomTarget);
	SAVE_STATE(iZoomLevel);
	SAVE_STATE(nextAkimboAttackPreference);
	SAVE_STATE(akimboDualFireToleranceTime);
	SAVE_STATE(grenadeFireIndex);
	SAVE_STATE(bGrenadeToss);
	
	SAVE_STATE(shotgunReloadIndex);
	
	SAVE_STATE(shotgunAddAmmoTime);
	SAVE_STATE(shotgunAddAmmoSoundTime);
	
	//SAVE_STATE(doFiremodeChange);
	
	
	SAVE_STATE(ary_myWeapons_softMax);
	for(int i = 0; i < ary_myWeapons_softMax; i++){
		SAVE_STATE(ary_myWeapons[i].weaponID);
		SAVE_STATE(ary_myWeapons[i].weaponTypeID);
		SAVE_STATE(ary_myWeapons[i].iBitsUpgrade);
		SAVE_STATE(ary_myWeapons[i].iCount);
		//SAVE_STATE(ary_myWeapons[i].iPrice);
		//SAVE_STATE(ary_myWeapons[i].iSlots);
		SAVE_STATE(ary_myWeapons[i].iClipLeft);
		SAVE_STATE(ary_myWeapons[i].iClipAkimboLeft);
		SAVE_STATE(ary_myWeapons[i].iBitsUpgrade_on);
		SAVE_STATE(ary_myWeapons[i].iFireMode);
		SAVE_STATE(ary_myWeapons[i].iFireModeAkimbo);
		SAVE_STATE(ary_myWeapons[i].iIronSight);
		SAVE_STATE(ary_myWeapons[i].iForceBodygroup1Submodel);
		SAVE_STATE(ary_myWeapons[i].bNeedsPump);
	}

	//UNNECESSARY. This array is of fixed length, so known at all times.
	//WriteByte(MSG_ENTITY, ary_ammoTotal_softMax);
	for(int i = 0; i < AMMO_ID::LAST_ID; i++){
		// See serverside equivalent, too much info was lost from some pools being over 255
		// (well I guess that's all there is to it)
		SAVE_STATE_ARY(ary_ammoTotal, i);
	}
	
}

/*
=================
player::PredictPostFrame

Where we roll back our values to the ones last sent/verified by the server.
=================
*/
void
player::PredictPostFrame(void)
{
	/* the generic client attributes */
	base_player::PredictPostFrame();

	// client's way of calling postthink
	postThink();
	
	ROLL_BACK(anim_top);
	ROLL_BACK(anim_top_delay);
	ROLL_BACK(anim_top_time);
	ROLL_BACK(anim_bottom);
	ROLL_BACK(anim_bottom_time);

	/*
	ROLL_BACK(glock_mag);
	ROLL_BACK(mp5_mag);
	ROLL_BACK(python_mag);
	ROLL_BACK(shotgun_mag);
	ROLL_BACK(crossbow_mag);
	ROLL_BACK(rpg_mag);
	ROLL_BACK(satchel_chg);

	ROLL_BACK(ammo_9mm);
	ROLL_BACK(ammo_357);
	ROLL_BACK(ammo_buckshot);
	ROLL_BACK(ammo_m203_grenade);
	ROLL_BACK(ammo_bolt);
	ROLL_BACK(ammo_rocket);
	ROLL_BACK(ammo_uranium);
	ROLL_BACK(ammo_handgrenade);
	ROLL_BACK(ammo_satchel);
	ROLL_BACK(ammo_tripmine);
	ROLL_BACK(ammo_snark);
	ROLL_BACK(ammo_hornet);

	ROLL_BACK(ammo_m203_grenade);
	ROLL_BACK(ammo_gauss_volume);
	ROLL_BACK(ammo_rpg_state);
	ROLL_BACK(mode_tempstate);
	*/
	
	ROLL_BACK(iState);
	ROLL_BACK(inventoryEquippedIndex);
	ROLL_BACK(weaponEquippedAkimbo);
	ROLL_BACK(w_attack_akimbo_next);
	ROLL_BACK(isReloading);
	ROLL_BACK(isChangingIronsight);
	ROLL_BACK(flZoomTarget);
	ROLL_BACK(iZoomLevel);
	ROLL_BACK(nextAkimboAttackPreference);
	ROLL_BACK(akimboDualFireToleranceTime);
	ROLL_BACK(grenadeFireIndex);
	ROLL_BACK(bGrenadeToss);
	
	ROLL_BACK(shotgunReloadIndex);
	
	ROLL_BACK(shotgunAddAmmoTime);
	ROLL_BACK(shotgunAddAmmoSoundTime);
	
	//ROLL_BACK(doFiremodeChange);
	
	ROLL_BACK(ary_myWeapons_softMax);
	for(int i = 0; i < ary_myWeapons_softMax; i++){
		ROLL_BACK(ary_myWeapons[i].weaponID);
		ROLL_BACK(ary_myWeapons[i].weaponTypeID);
		ROLL_BACK(ary_myWeapons[i].iBitsUpgrade);
		ROLL_BACK(ary_myWeapons[i].iCount);
		//ROLL_BACK(ary_myWeapons[i].iPrice);
		//ROLL_BACK(ary_myWeapons[i].iSlots);
		ROLL_BACK(ary_myWeapons[i].iClipLeft);
		ROLL_BACK(ary_myWeapons[i].iClipAkimboLeft);
		ROLL_BACK(ary_myWeapons[i].iBitsUpgrade_on);
		ROLL_BACK(ary_myWeapons[i].iFireMode);
		ROLL_BACK(ary_myWeapons[i].iFireModeAkimbo);
		ROLL_BACK(ary_myWeapons[i].iIronSight);
		ROLL_BACK(ary_myWeapons[i].iForceBodygroup1Submodel);
		ROLL_BACK(ary_myWeapons[i].bNeedsPump);
	}

	//UNNECESSARY. This array is of fixed length, so known at all times.
	//WriteByte(MSG_ENTITY, ary_ammoTotal_softMax);
	for(int i = 0; i < AMMO_ID::LAST_ID; i++){
		// See serverside equivalent, too much info was lost from some pools being over 255
		// (well I guess that's all there is to it)
		ROLL_BACK_ARY(ary_ammoTotal, i);
	}
	
}

#else
void
player::EvaluateEntity(void)
{
	/* the generic client attributes */
	base_player::EvaluateEntity();
	
	int i;
	int myAmmoType;

	/* animation */
	if (ATTR_CHANGED(anim_bottom) || ATTR_CHANGED(anim_bottom_time))
		SendFlags |= PLAYER_BOTTOMFRAME;
	if (ATTR_CHANGED(anim_top) || ATTR_CHANGED(anim_top_time) || ATTR_CHANGED(anim_top_delay))
		SendFlags |= PLAYER_TOPFRAME;


/*
	// ammo 1 type updates
	if (ATTR_CHANGED(glock_mag))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(mp5_mag))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(python_mag))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(shotgun_mag))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(crossbow_mag))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(rpg_mag))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(satchel_chg))
		SendFlags |= PLAYER_AMMO1;

	// ammo 2 type updates
	if (ATTR_CHANGED(ammo_9mm))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_357))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_buckshot))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_bolt))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_rocket))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_uranium))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_handgrenade))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_satchel))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_tripmine))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_snark))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_hornet))
		SendFlags |= PLAYER_AMMO2;

	if (ATTR_CHANGED(ammo_m203_grenade))
		SendFlags |= PLAYER_AMMO3;
	if (ATTR_CHANGED(ammo_gauss_volume))
		SendFlags |= PLAYER_AMMO3;
	if (ATTR_CHANGED(ammo_rpg_state))
		SendFlags |= PLAYER_AMMO3;
	if (ATTR_CHANGED(mode_tempstate))
		SendFlags |= PLAYER_AMMO3;

	SAVE_STATE(glock_mag);
	SAVE_STATE(mp5_mag);
	SAVE_STATE(python_mag);
	SAVE_STATE(shotgun_mag);
	SAVE_STATE(crossbow_mag);
	SAVE_STATE(rpg_mag);
	SAVE_STATE(satchel_chg);
	SAVE_STATE(ammo_9mm);
	SAVE_STATE(ammo_357);
	SAVE_STATE(ammo_buckshot);
	SAVE_STATE(ammo_bolt);
	SAVE_STATE(ammo_rocket);
	SAVE_STATE(ammo_uranium);
	SAVE_STATE(ammo_handgrenade);
	SAVE_STATE(ammo_satchel);
	SAVE_STATE(ammo_tripmine);
	SAVE_STATE(ammo_snark);
	SAVE_STATE(ammo_hornet);

	SAVE_STATE(ammo_m203_grenade);
	SAVE_STATE(ammo_gauss_volume);
	SAVE_STATE(ammo_rpg_state);
	SAVE_STATE(mode_tempstate);
*/


	// IDEA: do a full-send, all weapons stats on executing a buyconfig order?
	// set some flag to convey that?


	SAVE_STATE(ary_myWeapons_softMax);
	
	
	i = inventoryEquippedIndex;
	if(i != -1){
		//for(i = 0; i < ary_myWeapons_softMax; i++){
			if(ATTR_CHANGED(ary_myWeapons[i].weaponID)) SendFlags |= PLAYER_UNUSED1;
			if(ATTR_CHANGED(ary_myWeapons[i].weaponTypeID)) SendFlags |= PLAYER_UNUSED1;
			if(ATTR_CHANGED(ary_myWeapons[i].iBitsUpgrade))SendFlags |= PLAYER_UNUSED1; 
			if(ATTR_CHANGED(ary_myWeapons[i].iCount)) SendFlags |= PLAYER_UNUSED1;
			//SAVE_STATE(ary_myWeapons[i].iPrice));
			//SAVE_STATE(ary_myWeapons[i].iSlots));
			if(ATTR_CHANGED(ary_myWeapons[i].iClipLeft)) SendFlags |= PLAYER_UNUSED1;
			if(ATTR_CHANGED(ary_myWeapons[i].iClipAkimboLeft)) SendFlags |= PLAYER_UNUSED1;
			if(ATTR_CHANGED(ary_myWeapons[i].iBitsUpgrade_on)) SendFlags |= PLAYER_UNUSED1;
			if(ATTR_CHANGED(ary_myWeapons[i].iFireMode)) SendFlags |= PLAYER_UNUSED1;
			if(ATTR_CHANGED(ary_myWeapons[i].iFireModeAkimbo)) SendFlags |= PLAYER_UNUSED1;
			if(ATTR_CHANGED(ary_myWeapons[i].iIronSight)) SendFlags |= PLAYER_UNUSED1;
			if(ATTR_CHANGED(ary_myWeapons[i].iForceBodygroup1Submodel)) SendFlags |= PLAYER_UNUSED1;
			if(ATTR_CHANGED(ary_myWeapons[i].bNeedsPump)) SendFlags |= PLAYER_UNUSED1;
			
		//}
		myAmmoType = getAmmoTypeOfWeapon(this.activeweapon);
		if(myAmmoType != -1){
			i = myAmmoType;
			//UNNECESSARY. This array is of fixed length, so known at all times.
			//WriteByte(MSG_ENTITY, ary_ammoTotal_softMax);
			//for(i = 0; i < AMMO_ID::LAST_ID; i++){
				// See serverside equivalent, too much info was lost from some pools being over 255
				// (well I guess that's all there is to it)
				if(ATTR_CHANGED_ARY(ary_ammoTotal, i)) SendFlags |= PLAYER_UNUSED1;
			//}
		}
		
	}
	
	
	

	SAVE_STATE(anim_top);
	SAVE_STATE(anim_top_delay);
	SAVE_STATE(anim_top_time);
	SAVE_STATE(anim_bottom);
	SAVE_STATE(anim_bottom_time);
	
	SAVE_STATE(iState);
	SAVE_STATE(inventoryEquippedIndex);
	SAVE_STATE(weaponEquippedAkimbo);
	SAVE_STATE(w_attack_akimbo_next);
	SAVE_STATE(isReloading);
	SAVE_STATE(isChangingIronsight);
	SAVE_STATE(flZoomTarget);
	SAVE_STATE(iZoomLevel);
	SAVE_STATE(nextAkimboAttackPreference);
	SAVE_STATE(akimboDualFireToleranceTime);
	SAVE_STATE(grenadeFireIndex);
	SAVE_STATE(bGrenadeToss);
	
	
	SAVE_STATE(shotgunReloadIndex);
	
	SAVE_STATE(shotgunAddAmmoTime);
	SAVE_STATE(shotgunAddAmmoSoundTime);
	
	//SAVE_STATE(doFiremodeChange);
	
	
	SAVE_STATE(ary_myWeapons_softMax);
	
	
	i = inventoryEquippedIndex;
	if(i != -1){
		//for(i = 0; i < ary_myWeapons_softMax; i++){
			SAVE_STATE(ary_myWeapons[i].weaponID);
			SAVE_STATE(ary_myWeapons[i].weaponTypeID);
			SAVE_STATE(ary_myWeapons[i].iBitsUpgrade);
			SAVE_STATE(ary_myWeapons[i].iCount);
			//SAVE_STATE(ary_myWeapons[i].iPrice);
			//SAVE_STATE(ary_myWeapons[i].iSlots);
			SAVE_STATE(ary_myWeapons[i].iClipLeft);
			SAVE_STATE(ary_myWeapons[i].iClipAkimboLeft);
			SAVE_STATE(ary_myWeapons[i].iBitsUpgrade_on);
			SAVE_STATE(ary_myWeapons[i].iFireMode);
			SAVE_STATE(ary_myWeapons[i].iFireModeAkimbo);
			SAVE_STATE(ary_myWeapons[i].iIronSight);
			SAVE_STATE(ary_myWeapons[i].iForceBodygroup1Submodel);
			SAVE_STATE(ary_myWeapons[i].bNeedsPump);
		//}


		myAmmoType = getAmmoTypeOfWeapon(this.activeweapon);
		if(myAmmoType != -1){
			i = myAmmoType;
			//UNNECESSARY. This array is of fixed length, so known at all times.
			//WriteByte(MSG_ENTITY, ary_ammoTotal_softMax);
			//for(i = 0; i < AMMO_ID::LAST_ID; i++){
				// See serverside equivalent, too much info was lost from some pools being over 255
				// (well I guess that's all there is to it)
				SAVE_STATE_ARY(ary_ammoTotal, i);
			//}
		}
	}
	
}

/*
=================
player::SendEntity
=================
*/
float
player::SendEntity(entity ePEnt, float fChanged)
{
	/* remove our entity to other clients if we're dead */
	if (health <= 0 && ePEnt != this) {
		return (0);
	}

	/* target client isn't real, they have no client-side. abandon */
	if (clienttype(ePEnt) != CLIENTTYPE_REAL) {
		return (0);
	}

	//TAGGG - REPLACED.
	/*
	// other players don't need to know about these attributes
	if (ePEnt != self) {
		fChanged &= ~PLAYER_ITEMS;
		fChanged &= ~PLAYER_HEALTH;
		fChanged &= ~PLAYER_ARMOR;
		fChanged &= ~PLAYER_VIEWOFS;
		fChanged &= ~PLAYER_AMMO1;
		fChanged &= ~PLAYER_AMMO2;
		fChanged &= ~PLAYER_AMMO3;
	}
	*/

	WriteByte(MSG_ENTITY, ENT_PLAYER);
	WriteFloat(MSG_ENTITY, fChanged);

	/* the generic client attributes */
	base_player::SendEntity(ePEnt, fChanged);
	
	
	int i;

	if (fChanged & PLAYER_TOPFRAME) {
		WriteByte(MSG_ENTITY, anim_top);
		WriteFloat(MSG_ENTITY, anim_top_time);
		WriteFloat(MSG_ENTITY, anim_top_delay);
	}
	if (fChanged & PLAYER_BOTTOMFRAME) {
		WriteByte(MSG_ENTITY, anim_bottom);
		WriteFloat(MSG_ENTITY, anim_bottom_time);
	}
	
	WriteFloat(MSG_ENTITY, flViewModelFrame);
	
	

	//TAGGG - REPLACED.
	/*
	if (fChanged & PLAYER_AMMO1) {
		WriteByte(MSG_ENTITY, glock_mag);
		WriteByte(MSG_ENTITY, mp5_mag);
		WriteByte(MSG_ENTITY, python_mag);
		WriteByte(MSG_ENTITY, shotgun_mag);
		WriteByte(MSG_ENTITY, crossbow_mag);
		WriteByte(MSG_ENTITY, rpg_mag);
		WriteByte(MSG_ENTITY, satchel_chg);
	}

	if (fChanged & PLAYER_AMMO2) {
		WriteByte(MSG_ENTITY, ammo_9mm);
		WriteByte(MSG_ENTITY, ammo_357);
		WriteByte(MSG_ENTITY, ammo_buckshot);
		WriteByte(MSG_ENTITY, ammo_bolt);
		WriteByte(MSG_ENTITY, ammo_rocket);
		WriteByte(MSG_ENTITY, ammo_uranium);
		WriteByte(MSG_ENTITY, ammo_handgrenade);
		WriteByte(MSG_ENTITY, ammo_satchel);
		WriteByte(MSG_ENTITY, ammo_tripmine);
		WriteByte(MSG_ENTITY, ammo_snark);
		WriteByte(MSG_ENTITY, ammo_hornet);
	}

	if (fChanged & PLAYER_AMMO3) {
		WriteByte(MSG_ENTITY, ammo_m203_grenade);
		WriteByte(MSG_ENTITY, ammo_gauss_volume);
		WriteByte(MSG_ENTITY, ammo_rpg_state);
		WriteByte(MSG_ENTITY, mode_tempstate);
	}
	*/
	
	
	// TODO MAJOR!!! 
	// Only send updates if we shuffled the weapons around (update everything, all weapons),
	// OR if a particular weapon states to update its features, perhaps sending itself
	// through
	
	WriteFloat(MSG_ENTITY, iState);
	WriteByte(MSG_ENTITY, inventoryEquippedIndex );
	WriteByte(MSG_ENTITY, weaponEquippedAkimbo );
	WriteFloat(MSG_ENTITY, w_attack_akimbo_next );
	WriteByte(MSG_ENTITY, isReloading );
	WriteByte(MSG_ENTITY, isChangingIronsight );
	WriteFloat(MSG_ENTITY, flZoomTarget);
	WriteByte(MSG_ENTITY, iZoomLevel);
	WriteByte(MSG_ENTITY, nextAkimboAttackPreference);
	WriteFloat(MSG_ENTITY, akimboDualFireToleranceTime);
	WriteByte(MSG_ENTITY, grenadeFireIndex + 1);
	WriteByte(MSG_ENTITY, bGrenadeToss);
	
	WriteByte(MSG_ENTITY, armor );
	WriteByte(MSG_ENTITY, iTotalSlots );
	
	WriteFloat(MSG_ENTITY, fAccuracyKickback);
	
	
	
	WriteFloat(MSG_ENTITY, fMoveBlockDelay);
	WriteFloat(MSG_ENTITY, fUncrouchBlockDelay);
	WriteFloat(MSG_ENTITY, fKarateStamina);
	
	
	WriteByte(MSG_ENTITY, iMeleeCycler);
	
	//WriteCoord(MSG_ENTITY, vViewAngleOffsetTarget[0] );
	//WriteCoord(MSG_ENTITY, vViewAngleOffsetTarget[1] );
	//WriteCoord(MSG_ENTITY, vViewAngleOffsetTarget[2] );
	
	
	WriteByte(MSG_ENTITY, shotgunReloadIndex );
	WriteFloat(MSG_ENTITY, shotgunAddAmmoTime );
	WriteFloat(MSG_ENTITY, shotgunAddAmmoSoundTime );
	
	//WriteByte(MSG_ENTITY, doFiremodeChange);
	

	
	//weapondynamic_t ary_myWeapons[ary_myWeapons_length];
	WriteByte(MSG_ENTITY, ary_myWeapons_softMax );
	
	
	
	WriteByte(MSG_ENTITY, this.completeInventorySend );
	
#ifdef FORCE_NETWORK_ALL_INVENTORY
	completeInventorySend = TRUE;
#endif
	
	if(this.completeInventorySend){
		for(i = 0; i < ary_myWeapons_softMax; i++){
			SendEntity_ary_myWeapons(i);
		}
		for(i = 0; i < AMMO_ID::LAST_ID; i++){
			WriteLong(MSG_ENTITY, ary_ammoTotal[i] );
		}
	}else if(fChanged & PLAYER_UNUSED1){
		
		i = inventoryEquippedIndex;
		/// could this ever be -1?
		if(i != -1){
			SendEntity_ary_myWeapons(i);

			int myAmmoType = getAmmoTypeOfWeapon(this.activeweapon);
			if(myAmmoType != -1){		
				i = myAmmoType;
				//UNNECESSARY. This array is of fixed length, so known at all times.
				//WriteByte(MSG_ENTITY, ary_ammoTotal_softMax);
				//for(i = 0; i < AMMO_ID::LAST_ID; i++){
					// using 'WriteLong' instead of 'WriteByte', because SOME AMMO POOL just had to
					// exceed 255, didn't it.
					WriteLong(MSG_ENTITY, ary_ammoTotal[i] );
				//}
			}
		}
	}
	
	// no need to send again until this flag is set freshly.
	this.completeInventorySend = FALSE;
	
	

	return (1);
}

void player::SendEntity_ary_myWeapons(int i){
	WriteByte(MSG_ENTITY, ary_myWeapons[i].weaponID );
	WriteByte(MSG_ENTITY, ary_myWeapons[i].weaponTypeID );
	WriteByte(MSG_ENTITY, ary_myWeapons[i].iBitsUpgrade );
	WriteByte(MSG_ENTITY, ary_myWeapons[i].iCount );
	//WriteByte(MSG_ENTITY, ary_myWeapons[i].iPrice );
	//WriteByte(MSG_ENTITY, ary_myWeapons[i].iSlots );
	WriteByte(MSG_ENTITY, ary_myWeapons[i].iClipLeft );
	WriteByte(MSG_ENTITY, ary_myWeapons[i].iClipAkimboLeft );
	WriteByte(MSG_ENTITY, ary_myWeapons[i].iBitsUpgrade_on );
	WriteByte(MSG_ENTITY, ary_myWeapons[i].iFireMode );
	WriteByte(MSG_ENTITY, ary_myWeapons[i].iFireModeAkimbo );
	WriteByte(MSG_ENTITY, ary_myWeapons[i].iIronSight );
	WriteByte(MSG_ENTITY, ary_myWeapons[i].iForceBodygroup1Submodel);
	WriteByte(MSG_ENTITY, ary_myWeapons[i].bNeedsPump);
}

#endif





void
player::player(void){
	printfline("CONSTRUCTOR: player, called");
	
	// just in case?
	this.classname = "player";
	
	// reasonable default?
	iState = PLAYER_STATE::NOCLIP;
	completeInventorySend = FALSE;
	
#ifdef FIREMODE_PREDICTION_TEST
	ignoreFiremodeReceiveTime = -1;
#endif

#ifdef SERVER
	money = 0;  //safety?
	
	//this.think = player_frameThink;
	//this.nextthink = time + 0.0;
#endif

	ary_myWeapons_softMax = 0;
	for(int i = 0; i < ary_myWeapons_length; i++){
		ary_myWeapons[i] = spawn(weapondynamic_t);
	}
	
#ifdef CLIENT
	weaponSelectHighlightID = -1;
	weaponSelectHighlightAkimbo = FALSE;
	
	flag_lastWeaponAkimbo = FALSE;
	
#endif
	
	flKarateBlockCooldown = 0;
	
	
	// Should we?
	//setInventoryEquippedIndex(-1);
	inventoryEquippedIndex_previous = -1;
	
	weaponEquippedAkimbo = FALSE;
	
	//safe default.
	iTeam = TS_Team::TEAM_NONE;
	
	
	reset(TRUE);  //cover anything specified in here too
	
	/*
#ifdef SERVER
	
	player someThingy = this;
	printfline("***CHECKPOINT player2***");
	printfline("CBaseEntity: %i", someThingy.CBaseEntity);
	printfline("Respawn: %i", someThingy.Respawn);
	printfline("Hide: %i", someThingy.Hide);
	printfline("ParentUpdate: %i", someThingy.ParentUpdate);
	printfline("SendEntity: %i", someThingy.SendEntity);
	printfline("Pain: %i", someThingy.Pain);
	printfline("Death: %i", someThingy.Death);
	printfline("SetEffects: %i", someThingy.SetEffects);
	printfline("SetFrame: %i", someThingy.SetFrame);
	printfline("SetModel: %i", someThingy.SetModel);
	printfline("SetModelindex: %i", someThingy.SetModelindex);
	printfline("SetMovetype: %i", someThingy.SetMovetype);
	printfline("SetSkin: %i", someThingy.SetSkin);
	printfline("SetSolid: %i", someThingy.SetSolid);
	printfline("SetBody: %i", someThingy.SetBody);
	printfline("SetAngles: %i", someThingy.SetAngles);
	printfline("SetOrigin: %i", someThingy.SetOrigin);
	printfline("SetSize: %i", someThingy.SetSize);
	printfline("SetRenderFX: %i", someThingy.SetRenderFX);
	printfline("SetRenderMode: %i", someThingy.SetRenderMode);
	printfline("SetRenderAmt: %i", someThingy.SetRenderAmt);
	printfline("SetRenderColor: %i", someThingy.SetRenderColor);

	printfline("player: %i", someThingy.player);
	printfline("reset: %i", someThingy.reset);
	printfline("View_approachAngleOffsetTarget: %i", someThingy.View_approachAngleOffsetTarget);
	printfline("handleAccuracyKickback: %i", someThingy.handleAccuracyKickback);
	printfline("frameThink: %i", someThingy.frameThink);
	printfline("frameThink_fromServer: %i", someThingy.frameThink_fromServer);
	printfline("preThink: %i", someThingy.preThink);
	printfline("postThink: %i", someThingy.postThink);
	printfline("attemptAddWeaponFromPickup: %i", someThingy.attemptAddWeaponFromPickup);
	printfline("dropWeapon: %i", someThingy.dropWeapon);
	printfline("anyAmmoPoolNonEmpty: %i", someThingy.anyAmmoPoolNonEmpty);
	printfline("dropAmmo: %i", someThingy.dropAmmo);
	printfline("***END***");
	
#endif
	*/
	
	
}// player constructor


// use TRUE for clean respawns,
// FALSE for only resetting some weapons-related vars between weapon changes, nothing too
// significant
void 
player::reset(BOOL resetInventory){
	
	INPUT_TAP_RESET(this)
	
	// should this even make any assumptions about this?
	//iState = ?;
	
	resetZoom();
	
#ifdef CLIENT
	// For safety, doing this.
	// If anywhere that ever calls for this method clientside has this set
	// properly before the call to here, (whatever event-method in base files leads
	// to here most likely), this is not necessary.
	// Also, no need for pSeatLocal yet, but add in if that changes.
	int s = (float)getproperty(VF_ACTIVESEAT);
	pSeat = &g_seats[s];
	pSeat->m_flHUDWeaponSelectTime = -1;
	// we don't want damage related to the death / between spawns carrying over
	// at the start of the next spawn.
	pSeat->m_flDamageAlpha = 0;
	
	
	// doing this in reset too to avoid a little glitch.
	weaponSelectHighlightID = -1;
	
	w_freeze_idle_next = -1;
	
	flRecentGroundTime = 0;
	
	//TAGGG - BobNEW.
	// Reset the vars here? Or only on an inventory wipe?
	pViewBob = &g_viewBobVars[s];
	pViewBob->m_flBobTime = 0;
	pViewBob->m_flBob = 0;
	pViewBob->m_flBobCycle = 0;
	pViewBob->m_flSpeed = 0;
	pViewBob->m_vCam = [0,0,0];
	/////////////////////////////////////////////////////
	
	
	flViewShake = 0;
	
	recentLaserHitPosSet = FALSE;
	lasersightUnlockTime = FALSE;
	
	forceViewModelUpdate = FALSE;
	prev_iForceBodygroup1Submodel = 0;
		
#endif
	
#ifdef SERVER
	switchToRecentlyAddedWeapon = FALSE;
	nextUseCooldown = 0;
#endif
	
	
	// Shared, but don't network!  I think?
	aryNextBurstShotTime_softLength = 0;
	aryNextBurstShotTime_listenIndex = -1;
	
	
	iMeleeCycler = 0;
		
	// do this at spawn too. oh right, this 'reset' method is called from there.
	vViewAngleOffsetTarget = '0 0 0';
	fAccuracyKickback = 0;
	fAccuracyKickbackStartCooldown = -1;
	
	fMoveBlockDelay = -1;
	fUncrouchBlockDelay = -1;
	fMoveBlockCapSpeed = 0;
	fKarateStamina = 1.0;
	
	flBaseSpeedMulti = 1;
	flMoveSpeedMulti = 1;
	flSoundSpeedMulti = 1;
	flFireDelayMulti = 1;
	flBulletSpeedMulti = 1;
	flProjectileSpeedMulti = 1;


	//shotgun stuff.
	//NOTICE - all networked now, testing.
	
	shotgunReloadIndex = 0;
	shotgunAddAmmoTime = -1;
	shotgunAddAmmoSoundTime = -1;
	
	doFiremodeChange = FALSE;
	
	//Grenade stuff
	printfline("I set grenadeFireIndex to -1, D!");
	grenadeFireIndex = -1;
	grenadeHeldDuration = -1;
	grenadeSpawnTime = -1;
	bGrenadeToss = FALSE;
	
	isReloading = FALSE;
	isChangingIronsight = FALSE;
	
	
	nextAkimboAttackPreference = BITS_AKIMBOCHOICE_LEFT;
	recentAttackHadAmmo = FALSE;
	
	
	// don't reset the money. Carries between spawns. I think?
	// TODO - FIGURE THIS OUT, for gamemodes that involve money.
	
	// do a check. If we didn't die last time, we don't need to delete this stuff.
	// is this good?  See that this reliable to check at the time "reset" is called in the
	// spawning method!
	// or just send a parameter here (preserve weapons:  yes/no BOOL) to determine that
	// instead.
	
	if(resetInventory){
		
		// could this be done for resets outside of resetInventory?  unsure
		flags = 0;
		gflags = 0;
	
		// sure?  Not used for this game though.
		g_items = 0x0;
		
		printfline("setInventoryEquippedIndex: FLAG A");
		setInventoryEquippedIndex(-1);
		
#ifdef CLIENT
		equippedWeaponWaitingForCallback = FALSE;
#endif
	
#ifdef SERVER
		// other projects do that so sure?
		weapon = 0;
	
		// TODO - is doing this in here a good idea? decide.
		WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
		WriteByte( MSG_MULTICAST, EVENT_TS::RESET_VIEW_MODEL );
		msg_entity = this;
		multicast( [0,0,0], MULTICAST_ONE );
#endif
		
		// effectively says, no weapons.  Any other info in there is to be overwritten as
		// needed.
		ary_myWeapons_softMax = 0;
		
		//All ammo counters, goodbye.
		for(int i = 0; i < AMMO_ID::LAST_ID; i++){
			ary_ammoTotal[i] = 0;  //safe default
		}
		
		armor = 0;
		iTotalSlots = 0;
		iTotalPrice = 0;
		
	}
	
}//reset



vector
player::View_approachAngleOffsetTarget(vector vecInputAngles)
{
	float frametimeUse;
#ifdef CLIENT
	frametimeUse = clframetime;
#else
	frametimeUse = frametime;
#endif
	
	// !!! Not involving frametimeUse yet?  Whoops.
	
	
	// do we have an offset at all?
	if( vlen(vViewAngleOffsetTarget) != 0){
		
		//shift our view to get closer to looking in the direction suggested by it.		
		vector vecToMove;
		
		vecToMove = vViewAngleOffsetTarget * 0.22;
		float vecToMoveLen = vlen(vecToMove);
		
		if(vecToMoveLen < 0.001 || vecToMoveLen >= vlen(vViewAngleOffsetTarget)  ){
			//nah nevermind, just move to the target already.
			//printfline("View_approachAngleOffsetTarget: LAST ONE");
			vecToMove = vViewAngleOffsetTarget;
		}else{
			
		}
		
		vecInputAngles += vecToMove * 1.28;
		vViewAngleOffsetTarget -= vecToMove;
		
	}
	
	return vecInputAngles;
}//View_approachAngleOffsetTarget


// TODO - make this better shared probably?
void
player::handleAccuracyKickback(void){
	
	if(fAccuracyKickbackStartCooldown != -1){
		if(time >= fAccuracyKickbackStartCooldown){
			//begin reducing the kickback cumula.
			fAccuracyKickback -= frametime * 0.1;
			
			if(fAccuracyKickback <= 0){
				//stop!
				fAccuracyKickback = 0;
				fAccuracyKickbackStartCooldown = -1;
			}
		}
	}//kickbackStartCooldown check
	
}


void
player::setZoom(float arg_theZoom)
{
	//printfline("setZoom: %.2f", arg_theZoom);
	flZoomTarget = arg_theZoom;
}
// forget any zoom-related settings instantly.
// Unsure if a message should be sent to the client if called from the server, or assume the
// calls coincide.
void
player::resetZoom(void)
{
	iZoomLevel = 0;
	viewzoom = 1.0f;
	setZoom(1.0f);  // sets flZoomTarget
	
#ifdef CLIENT
	// IMPORTANT!  ZoomLerp under 0 tries to involve flZoomOld, set or not
	flZoomLerp = 1.0f;
	SAVE_STATE(iZoomLevel);
	SAVE_STATE(viewzoom);
	SAVE_STATE(flZoomTarget);
	flZoomEnd = 1.0f;
	flZoomCurrent = 1.0f;
#endif
}

void
player::setInventoryEquippedIndex(int arg_newIndex)
{
	setInventoryEquippedIndex_Akimbo(arg_newIndex, FALSE);
}


// Extra version supplied 'useAkimbo'.
void
player::setInventoryEquippedIndex_Akimbo(int arg_newIndex, BOOL useAkimbo)
{
	printfline("setInventoryEquippedIndex_Akimbo: %i, %d", arg_newIndex, useAkimbo);
	inventoryEquippedIndex = arg_newIndex;
	if(arg_newIndex != -1){
		// Let Nuclide be aware what element of g_weapons is relevant (set activeweapon).
		
		// all we need is dynaRef.weaponID
		weapondynamic_t dynaRef = ary_myWeapons[arg_newIndex];
		weapondata_basic_t* basicP = (weapondata_basic_t*) ary_weaponData[dynaRef.weaponID];
		//weapondata_basic_t basicRef = *(basicP);
		
		//printfline("WELL. %d", useAkimbo);
		//printfline("setInventoryEquippedIndex - newInvIndex:%i weaponID:%i\n", arg_newIndex, dynaRef.weaponID);
		
		int myAkimboUpgradeID = (*ary_weaponData[dynaRef.weaponID]).iAkimboID;
		
		// If I don't intend to use the akimbo version, the upgrade ID to get there is bad,
		// or this weapon does not support akimbo, or simply isn't right now, do singular.
		if(
			!useAkimbo ||
			myAkimboUpgradeID <= 0 ||
			!((dynaRef.iBitsUpgrade & BITS_WEAPONOPT_AKIMBO) && ((*basicP).iBitsUpgrade & BITS_WEAPONOPT_AKIMBO))
		){
			weaponEquippedAkimbo = FALSE;
			activeweapon = (float)dynaRef.weaponID;
			activeweapon_singular = (float)dynaRef.weaponID;
		}else{
			weaponEquippedAkimbo = TRUE;
			activeweapon = (float)ary_AKIMBO_UPGRADE_TO_WEAPON[myAkimboUpgradeID];
			activeweapon_singular = (float)dynaRef.weaponID;
		}
	}else{
		// it was -1?  activeweapon must be 0, the 'none' choice. 
		activeweapon = 0;
		activeweapon_singular = 0;
		weaponEquippedAkimbo = FALSE;  // I guess?
	}
	
	// - OLD COMMENT
	// NOTE, IMPORTANT.
	// Is this necessary?
	// Makes a decent example for paying attention to SAVE and ROLLBACKs in player script
	// (see activeweapon SAVE_STATE/ROLLBACK's in Nuclide's src/shared/player.qc).
	// ALSO - for this demo to work, remove the karate call in 'deployConfig',
	// so that having no weapons out leads to equipping the 'empty' weapon.
	
	// When nothing is here instead (comment out), try throwing the last throwing knife.
	// Often, you'll still hear the 'draw' noise because a rollback sets activeweapon back
	// to the previous value, even though you want it to be nothing from having nothing
	// equipped.
	// But if this is enabled all the time (client and serverside), the weapon set by the
	// server exclusively, such as player-spawn, does not get sent off..
	// This seems to be the best case scenario: setting this clientside stops the rollback
	// to undo setting the current equipped weapon to 'nothing' back to the throwing knife,
	// which would not even be equipped anymore.
	// If this is the wrong way to go thinking about this, I need to know more.
	// ALSO - see other uses of SAVE_STATE, most are for both client & server,
	// especially the w_attack_next, or w_next_attack, in ts/shared/weapons.qc.
	/////////////////////////////////////
	
	// - NEW COMMENTs
	// Looks like we at least want to do SAVE_STATE(activeweapon) to stop a rollback
	// from being undone that causes it to flicker back to what's about to be received.
	
	// and we get 'iilegible server message' on very high pings.
	// S T E L L A R .  although it's happenin without this too.
	// Although this can cause the weapon info to glich out, like a host of other stuff
	// needs to be sent / know not to change just yet too I'm guessing, a clientside SAVE_STATE
	// of all the next equipped weapon's stuff I'm guessing?
	// Make a method and test, with equippedID set to the new
	// (inventoryEquippedIndex and activeweapon as they are here)!  TODO TODO TODO
	// #ifdef CLIENT    saveWeaponState(inventoryEquippedIndex)   ...   ary_myWeapons ...  #endif
	
	// And the network-crash is from ... not sending the entire inventory every single frame.
	// ...  Marvelous.  But at least that's a completely separate issue, again with or without below.
	
	// (force a sendoff, expect it area)
	
#ifdef SERVER
	// Force a sendoff!
	SendFlags |= PLAYER_WEAPON;
#else
	SAVE_STATE(activeweapon);
	// unsure if this one's needed
	SAVE_STATE(inventoryEquippedIndex);
#endif

	

}



// get old FreeTS weapon info.
weapondata_basic_t*
player::getEquippedWeaponData(void){
	//weapondynamic_t dynaRef;
	//dynaRef = ary_myWeapons[inventoryEquippedIndex];
	//dynaRef.weaponID
	return getWeaponData((int)activeweapon, weaponEquippedAkimbo);
}

weapondata_basic_t*
player::getEquippedWeaponData_Singular(void){
	//return getWeaponData_Singular(activeweapon_singular);
	// no do this.
	return ary_weaponData[activeweapon_singular];
}

// For choices other than the equipped weapon ID
weapondata_basic_t*
player::getInventoryWeaponData(int arg_invID, BOOL arg_preferAkimbo){
	weapondynamic_t dynaRef;
	dynaRef = ary_myWeapons[arg_invID];
	return getWeaponData(dynaRef.weaponID, arg_preferAkimbo);
}

// As the akimbo versions of weapons are saved to g_weapons,
// the singular version may be desired sometimes.
weapondata_basic_t*
player::getInventoryWeaponData_Singular(int arg_invID){
	weapondynamic_t dynaRef;
	dynaRef = ary_myWeapons[arg_invID];
	return getWeaponData_Singular(dynaRef.weaponID);
}

// Call me since changing a weapon's iCount by unusual means like throwing a weapon.
// Other methods, addWeaponToInventory and player::dropWeapon, either already call this
// or handle this on their own already.
// Should this be done for price too?  I doubt there would be any benefit to preserving
// the value stored in weapons ingame.
void
player::updateSlotCountsForEquippedWeapon(void){
	//weapondynamic_t arg_thisWeapon = ary_myWeapons[inventoryEquippedIndex];
	weapondata_basic_t* basicP = getEquippedWeaponData();
	// Record the old number of slots saved to the weapon at its iCount earlier
	int iSlotsOld = ary_myWeapons[inventoryEquippedIndex].iSlots;
	// Determine the new slot count from the (modified?) weapon's iCount.
	int iSlotsNew = (*basicP).iSlots * ary_myWeapons[inventoryEquippedIndex].iCount;
	ary_myWeapons[inventoryEquippedIndex].iSlots = iSlotsNew;
	// Remove iSlotsOld, add iSlotsNew.  If they match this means no change.
	iTotalSlots = iTotalSlots - iSlotsOld + iSlotsNew;
}

// Returns whether the current weapon was removed.
// Mainly this exists to check if a weapon intended to be removed instead of dropped
// (count set to 0), but this handles deleting it from the player's inventory anyway.
BOOL
player::equippedWeaponDeleteCheck(void){
	weapondynamic_t arg_thisWeapon = this.ary_myWeapons[this.inventoryEquippedIndex];
	if(arg_thisWeapon.iCount == 0){
		printfline("!!! Auto delete check, equipping a new weapon");
		// remove this weapon, pick another one.
		removeWeaponFromInventory(this, this.inventoryEquippedIndex);
		playerEquipIdealSafe(this);
		return TRUE;
	}
	return FALSE;
}

BOOL
player::inventoryWeaponDeleteCheck(int arg_invID){
	weapondynamic_t arg_thisWeapon = this.ary_myWeapons[arg_invID];
	if(arg_thisWeapon.iCount == 0){
		// remove this weapon, pick another one.
		removeWeaponFromInventory(this, arg_invID);
		//if(arg_invID == inventoryEquippedIndex){
		//	playerEquipIdealSafe(this);
		//}
		return TRUE;
	}
	return FALSE;
}



void
player::callWeaponThink(void){
	if(inventoryEquippedIndex != -1){
		weapondynamic_t dynaRef = ary_myWeapons[inventoryEquippedIndex];
		
		weapondata_basic_t* basicPointer = (weapondata_basic_t*) this.getEquippedWeaponData();
		weapondata_basic_t basicRef = *(basicPointer);
		
		basicRef.funOnThink(this, dynaRef);
		
	}// weaponEquipped check
}


// well that didn't work.
/*
BOOL
player::shotgunAddAmmoTime_canSet(void){
	#ifdef CLIENT
		// require the cooldown
		// is cltime better?  Unsure
		return (time >= shotgunAddAmmoTime_cooldownSetTime);
	#else
		// Server? Always
		return TRUE;
	#endif
}
void
player::shotgunAddAmmoTime_setCooldownSetTime(void){
	#ifdef CLIENT
		// do it
		shotgunAddAmmoTime_cooldownSetTime = time + 0.02f;
	#else
		// Server? I don't.
	#endif
}
*/


#ifdef SERVER
// runs every frame server-side.  postthink, oddly enough, does not.
// Even cumulative 'frametime' readings do not at all add up to the real passage of time.
// Looks like we have to do this with server calling our think instead... it's own frame
// logic method does add up to something that resmebles the passage of time at least.
// The "frameThink_fromServer" further below is actually called from the server and runs
// every single logic frame of the server, as evidenced by its frametime's summing up to the
// passage of time.
// Strangely, setting the ".think" method of the player clientside, even with nextThink set,
// does nothing at all. Even though other clientside-programmed entities like the ts_powerup
// work fine with it...   I.  DONT.  KNOW.

void
player::frameThink_fromServer(void){
	
	if(autocvar_sv_printoutspam == 1){
		printfline("My state: %d", iState);
		printfline("STATUS: %d, %i", activeweapon, inventoryEquippedIndex);
	}
	
	
	if(fKarateStamina < 1.0){
		fKarateStamina = bound(0, fKarateStamina + frametime * 0.1667, 1);
	}
	
	handleAccuracyKickback();
	
}// frameThink_fromServer

#endif




#ifdef CLIENT

// Note that these pre/postThink's aren't game events, they're just called 
// before/after prediction accordingly, and every single rendered frame.
// Unlike serverside preThink / postThink, which (I think?) are called independent of any
// logic frame-rate on the server.
void 
player::preThink(void){
	weapondynamic_t dynaRef;
	
	if(autocvar_cl_printoutspam == 1){
		printfline("My state: %d", iState);
		gFun_UI_EventGrabber_DebugMethod();
	}
	
	
	if(time >= equippedWeaponWaitingForCallback_maxWaitTime){
		// stop then
		equippedWeaponWaitingForCallback = FALSE;
	}
	
	// Called before rendering, so this is an acceptable place.
	TS_View_HandleZoom();
	
	//callWeaponThink();
	
	
	//TAGGG - CRITICAL!!! 
	// Should the rest all be client-only anymore?  See if it should be shared.
	
	// TAGGG - TODO.
	// maybe rename this to "viewModelAnimationDuration"
	// and let "nextViewModelAnimationTime" be re-used if we ever support idle animations
	// like HL does? doubt that really though.
	
	// When a viewmodel's w_freeze_idle_next has expired, force to the frozen idle frame.
	if(w_freeze_idle_next == 0){
		w_freeze_idle_next = -1;
		
		
		
		if(inventoryEquippedIndex != -1){
			dynaRef = ary_myWeapons[inventoryEquippedIndex];
			weapondata_basic_t* basePRef = this.getEquippedWeaponData();
			weapondata_basic_t baseRef = *basePRef;
			
			//printfline("THE IDLE HAPPENED");
			
			if(dynaRef.weaponTypeID == WEAPONDATA_TYPEID_IRONSIGHT){
				
				weapondata_ironsight_t ironsightRef = *((weapondata_ironsight_t*) basePRef);
				BOOL usingIronSight;
				
				// Usually we can depend on iIronSight, but not always.
				// If using switch - ironsight calls, we need to be able to tell what the
				// intended iIronSight is, since it changes at the end on the server and
				// might not've reached us (the client) in time.
				
				if(pSeat->m_eViewModel.frame == ironsightRef.ironsightdata.iAnim_Change_Index){
					usingIronSight = TRUE;  //assuming the end of this.  Pick the opposite.
				}else if(pSeat->m_eViewModel.frame == ironsightRef.ironsightdata.iAnim_ReChange_Index){
					usingIronSight = FALSE;  //assuming the end of this.  Pick the opposite.
				}else{
					//neither?  We should be able to trust this.
					usingIronSight = (dynaRef.iIronSight == 1);
				}
				
				
				// idle anims don't really have any length.  Let's just say "2" seconds if
				// we ever care about some delay for this in the future.
				if(!usingIronSight){
					// use this one (plain)
					TS_Weapons_ViewAnimation(ironsightRef.iAnim_Idle_Index, 2 );
				}else{
					// use this one
					TS_Weapons_ViewAnimation(ironsightRef.ironsightdata.iAnim_Idle_Index, 2 );
				}
				
			}else{
				//baseRef = *((weapondata_basic_t*) basePRef);
				TS_Weapons_ViewAnimation(baseRef.iAnim_Idle_Index, 2 );
			}
			
		}// inventoryEquippedIndex
	}// w_freeze_idle_next check
	
}//preThink



void
player::postThink(void){
	
	float cltime_delta = cltime - clientTime_prev;
	
	clientTime_prev = cltime;
	
	// is that wise?  There is also "frametime".
	//printfline("-------postThink %.3f - %.3f------", cltime_delta, frametime);
	
	
	/*
	// if anything like this were ever needed?
	w_attack_next_nonet -= cltime_delta;
	if(w_attack_next_nonet < 0)w_attack_next_nonet = 0;
	*/
	
	// client-only, so it uses this.
	// Why does this decrease way too fast if it uses input_timelength instead?
	// Vars that are networked (see w_attack_akimbo_next in ts/src/shared/input.qc)
	// don't appear to have that problem.
	if(w_freeze_idle_next != -1){
		w_freeze_idle_next = max(0, w_freeze_idle_next - cltime_delta);
	}
	
}//postThink
#endif


// preThink & postThink are serverside only.
// Now supported clientside as separate implementations (see above)
// we have other ways for handling logic clientside.

#ifdef SERVER
void
player::preThink(void){
	
	//self.angles += '0 0.3 0';
	//self.v_angle = self.angles;
	
	// TODO - for clientside, this would need to involve the "view_angles" global
	// instead!  Unsure if the macro GET_VIEW_ANGLES is good enough
	v_angle = View_approachAngleOffsetTarget(v_angle);
	
}// preThink

void
player::postThink(void){
	
}// postThink
#endif


#ifdef SERVER

BOOL
player::attemptAddWeaponFromPickup(CTSWorldGun arg_pickup){
	
	//int existingMatchingIndex = findWeaponInConfig((player)other, (int)arg_pickup.myInfo.weaponID);
	
	// if the other player does not already have this weapon, we can take it.
	// if the other player does already have this weapon, see if we can give them
	// all our ammo.  If so, despawn.
	// If not (max pool capacity reached first), give what we can (if any) and then despawn.
	
	//This method already handles already having this weapon in the inventory.
	//...unfortunately we need a 2nd thing returned: whether we want to
	// switch to the weapon we worked with.
	// Using a temp var included with each player we assume this method sets:
	// switchToRecentlyAddedWeapon.
	int slotPlacedIn = addWeaponToInventory(this, arg_pickup);
	
	//Assumption: if the player added this weapon to the inventory,
	// it will have bumped the softMax compared to what it was before.
	// Only switch to a weapon we picked up if it is completely new,
	// OR turned an existing weapon akimbo.
	// ...not good enough, we can't determine if akimbo was recently added
	// to something that didn't use to have it.
	//newWeaponAdded = (otherPlayerRef.ary_myWeapons_softMax != oldCap);
	
	//We can equip the slot we made it to.
	
	
	if(slotPlacedIn != -1){
	
		if(switchToRecentlyAddedWeapon){
			// We assume this is a new weapon or one that upgraded into akimbo.
			// Play this sound too.
			sound(this, CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_NORM, 100, SOUNDFLAG_PLAYER_COMMON );
			TS_playerEquippedWeapon(this, slotPlacedIn, TRUE);
		}
		
		// picked up the weapon?  decide whether we delete the pickup-able.
		
		weapondata_basic_t* weaponPointer = ary_weaponData[arg_pickup.myInfo.weaponID];
		weapondata_basic_t basicRef = *((weapondata_basic_t*) weaponPointer);

		if(basicRef.typeID == WEAPONDATA_TYPEID_GUN || basicRef.typeID == WEAPONDATA_TYPEID_IRONSIGHT){
			// assume we took the weapon.  Akimbo was handled already.
			return TRUE;  //delete
		}else if(basicRef.typeID == WEAPONDATA_TYPEID_THROWABLE){
			//a throwable with all taken out of it?  It disappears.
			if(arg_pickup.myInfo.iCount == 0){
				return TRUE;  //delete
			}
		}else{
			//melee?  Just remove it.
			return TRUE;  //delete
		}
		
	}
	
	return FALSE;  //don't delete.
}// attemptAddWeaponFromPickup


// Drop this weapon (of that index).  ID is kinda the improper term.
// the "completeDrop" parameter means auto-dropping akimbo.  Player death does this
// for convenience.
void 
player::dropWeapon(int arg_weaponID, BOOL completeDrop){
	
	if(arg_weaponID == -1){
		// ???
		return;
	}
	
	// record the number of slots lost for removing from the total later,
	// typically those of the 'eDrop' entity.  Adjust for being more than one.
	int iSlotsDropped = 0;
	CTSWorldGun eDrop = NULL;
	
	// there is a "TS_playerDropWeapon" method in event_custom.c we could call if needed.
	// Looks like we never really intended for it to go anywhere though, no need for that.
	// Not even hooked up in ts/client/event.c anyway (commented out).
	// oh wait, we don't want to because the client initiates this whole thing.  That's right.
	// It sees the "drop" command called and so sends an event to the server that got to this "dropWeapon" method
	// here in player.  okay.
	
	printfline("playerDrop. weaponID:%i completeDrop:%d", arg_weaponID, completeDrop);
	
	weapondynamic_t dynaRefPRE = ary_myWeapons[arg_weaponID];
	weapondata_basic_t* basicP = getInventoryWeaponData(arg_weaponID, TRUE);
	weapondata_basic_t* basicPS = getInventoryWeaponData_Singular(arg_weaponID);
	
	//printfline("ActiveWeap:%d InvEqIndx:%i", this.activeweapon, this.inventoryEquippedIndex);
	
	// WARNING!  This is still checking the possibly akimbo variant for having a
	// worldmodel.  The drops are still the singular variant in any case, but verify that.
	if((*basicP).sWorldModelPath == ""){
		// if the world model path is empty, we can't be dropped.
		if(completeDrop){
			// But if this is a completeDrop (dead player), delete it anyway.
			removeWeaponFromInventory(this, arg_weaponID);
		}
		return;
	}
	
	BOOL deletedCurrentWeapon;
	
	if(arg_weaponID == inventoryEquippedIndex){
		// only if this is the currently equipped weapon.
		Weapons_Holster();
		if(!completeDrop){
			deletedCurrentWeapon = equippedWeaponDeleteCheck();
		}else{
			// don't bother with the equip-ideal call that equippedWeaponDeleteCheck does.
			deletedCurrentWeapon = inventoryWeaponDeleteCheck(arg_weaponID);
			//setInventoryEquippedIndex(-1);
		}
	}else{
		// Still, see if this weapon would prefer to disappear rather than
		// be dropped.  Throwables with a count of 0 (?) would prefer to be drop-less.
		deletedCurrentWeapon = inventoryWeaponDeleteCheck(arg_weaponID);
	}
	
	// back to using the singular form unless otherwise noted.
	// CRITICAL.  Should still be able to use the akimbo version for stats all the same,
	// adjust below to make usign the same basicP work.
	// Until then, something simple.
	// No, just use basicPS for below.
	//basicP = getEquippedWeaponData_Singular();
	
	printfline("-deletedCurrentWeapon? %d", deletedCurrentWeapon);
	
	if(deletedCurrentWeapon){
		// STOP.  Apparently the player deleted this weapon in the holster call above,
		// like a grenade that has 0 ammo and tried to be 'dropped'.
		return;
	}
	
	// Check again, because maybe unequip above already removed the currently equipped
	// weapon, leaving this -1 now.  But it does say to equip the next best thing.
	// it's safe.
	//if(inventoryEquippedIndex != -1){
	if((*basicPS).typeID == WEAPONDATA_TYPEID_GUN || (*basicPS).typeID == WEAPONDATA_TYPEID_IRONSIGHT){
		// This works, but hte proper way to check for always-akimbo is:
		//	 basicRefX.iAkimboID == WEAPON_AKIMBO_UPGRADE_ID::NONE
		// for linked akimbo, alongside the same dynaRef check:
		//	 basicRefX.iAkimboID > 0
		if((*basicPS).iBitsUpgradeAuto & BITS_WEAPONOPT_AKIMBO){
			// singular akimbo?  dropping removes.		
			eDrop = CTSWorldGun::generate(this, arg_weaponID);		
			removeWeaponFromInventory(this, arg_weaponID);
			if(!completeDrop){
				playerEquipIdealSafe(this);
			}
		}else if(
			((*basicPS).iBitsUpgrade & BITS_WEAPONOPT_AKIMBO) &&
			(dynaRefPRE.iBitsUpgrade & BITS_WEAPONOPT_AKIMBO)
		){
			// TODO - CRITICAL!  Does this need any special checks for akimbo-only weapons?
			// Those can't be split into two singular pickups like an area further down does.
			////////////////////////
			// supports akimbo with singular form, and we happen to be akimbo?  Don't delete the
			// weapon, just downgrade to non-akimbo.
			// WAIT NOT JUST YET.  The weapon drop will think we're dropping the weapon while it
			// didn't have akimbo.
			if(!completeDrop){
				eDrop = CTSWorldGun::generate(this, arg_weaponID);
				
				if(weaponEquippedAkimbo){
					// safety.   dynaRefPRE.iClipLeft stays as it is, just enforcing that the akimbo one was dropped.
					dynaRefPRE.iClipAkimboLeft = 0;
				}else{
					// Dropping the one used for singular?  ok.
					// Make the singular we retain's that of the akimbo clip count then.
					dynaRefPRE.iClipLeft = dynaRefPRE.iClipAkimboLeft;
					dynaRefPRE.iClipAkimboLeft = 0;
				}
			
				// playerEquipIdealSafe ?  Not quite.
				
				printfline("setInventoryEquippedIndex: FLAG B");
				TS_resetViewModel(this);
				setInventoryEquippedIndex(-1);
				weaponEquippedAkimbo = FALSE;
				//playerEquipIdeal(this);
				
				ary_myWeapons[arg_weaponID].iCount = 1; //instead of 2.
				
				// we just lost the slots worth of what was just dropped.
				// Important since dropping didn't delete this weapon, in the meantime
				// its own slot count must be accurate since losing one of the two guns.
				ary_myWeapons[arg_weaponID].iSlots = (*basicPS).iSlots * 1;
				
				// HERE WE GO.
				dynaRefPRE.iBitsUpgrade &= ~ BITS_WEAPONOPT_AKIMBO;
				
				// only FALSE on the akimbo part since we clearly just lost it.
				TS_playerEquippedWeapon(this, arg_weaponID, FALSE);
				
			}else{
				// Player is dying?  Remove this weapon and drop two copies.
				// Pretty simple.
				// ...but we need to override how they get ammo.
				eDrop = CTSWorldGun::generate(this, arg_weaponID);
				eDrop.myInfo.iClipLeft = dynaRefPRE.iClipLeft;
				eDrop.myInfo.iClipAkimboLeft = 0;
				eDrop = CTSWorldGun::generate(this, arg_weaponID);
				eDrop.myInfo.iClipLeft = dynaRefPRE.iClipAkimboLeft;
				eDrop.myInfo.iClipAkimboLeft = 0;
				
				removeWeaponFromInventory(this, arg_weaponID);
				
				// because further below assumes only one copy was dropped.
				// Add the 2nd copy's slots in this way.
				iSlotsDropped += eDrop.myInfo.iSlots;
			}
			
		}else{
			// doesn't support akimbo or not akimbo? remove.
			eDrop = CTSWorldGun::generate(this, arg_weaponID);
			removeWeaponFromInventory(this, arg_weaponID);
			if(!completeDrop){
				playerEquipIdealSafe(this);
			}
		}
	}else if((*basicPS).typeID == WEAPONDATA_TYPEID_THROWABLE){
		
		//drop away
		if(!completeDrop){
			eDrop = CTSWorldGun::generate(this, arg_weaponID);
			
			eDrop.myInfo.iCount = 1;
			eDrop.myInfo.iSlots = (*basicPS).iSlots * 1;
			
			ary_myWeapons[arg_weaponID].iCount -= 1;
			ary_myWeapons[arg_weaponID].iSlots = (*basicPS).iSlots * ary_myWeapons[arg_weaponID].iCount;
			
			if(ary_myWeapons[arg_weaponID].iCount <= 0){
				// unequip this weapon
				removeWeaponFromInventory(this, arg_weaponID);
				playerEquipIdealSafe(this);
			}else{
				// still have it?  undirty any blood effects since we dropped that.
				ary_myWeapons[arg_weaponID].iForceBodygroup1Submodel = 0;
			}
			
		}else{
			// combine them all, happens naturally.
			eDrop = CTSWorldGun::generate(this, arg_weaponID);
			removeWeaponFromInventory(this, arg_weaponID);
			playerEquipIdealSafe(this);
		}
		
		
	}else{  // if((*basicPS).typeID == WEAPONDATA_TYPEID_MELEE)
		
		eDrop = CTSWorldGun::generate(this, arg_weaponID);
		removeWeaponFromInventory(this, arg_weaponID);
		if(!completeDrop){
			playerEquipIdealSafe(this);
		}
		
	}
	
	printfline("playerDrop:  end.  Was there a drop? %d", (float)(eDrop != NULL));


	if(eDrop != NULL){
		iSlotsDropped += eDrop.myInfo.iSlots;
	}
	
	iTotalSlots -= iSlotsDropped;
	
	sound(this, CHAN_WEAPON, "weapons/weapondrop.wav", 1, ATTN_NORM );

}// dropWeapon



BOOL
player::anyAmmoPoolNonEmpty(void){
	//BOOL anyNonEmpty = FALSE;
	for(int i = 0; i < AMMO_ID::LAST_ID; i++){
		if(ary_ammoTotal[i] > 0){
			//anyNonEmpty = TRUE;
			return TRUE;
		}
	}
	//return anyNonEmpty;
	return FALSE;  //made it this far?  didn't have any.
}// anyAmmoPoolNonEmpty

// oh.. I guess that's it.
void
player::dropAmmo(void){
	//CTSAmmoPack eDrop = 
	CTSAmmoPack::generate(this);

}// dropAmmo


#endif


