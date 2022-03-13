/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
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
 
 
// little test
//var float otherTimer = 0;
 
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




#ifdef SERVER
void CSEv_ViewAnglesR_fff(float arg_x, float arg_y, float arg_z){
	player pl = (player)self;
	pl.v_angle.x = arg_x;
	pl.v_angle.y = arg_y;
	pl.v_angle.z = arg_z;
	pl.vViewAngleOffsetTotalChangeAlt = [0,0,0];
}
void CSEv_ViewOffsetR_fff(float arg_x, float arg_y, float arg_z){
	player pl = (player)self;
	pl.vViewAngleOffsetTotalChangeAlt.x = arg_x;
	pl.vViewAngleOffsetTotalChangeAlt.y = arg_y;
	pl.vViewAngleOffsetTotalChangeAlt.z = arg_z;
	//pl.vViewAngleOffsetTotalChangeAlt = [0,0,0];
}
#endif





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
	
	
	// TODO!  Test surrounding with this
	if(!equippedWeaponWaitingForCallback){
		
	}
	
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
	
	
	if(fl & PLAYER_UNUSED2){
		
		//float flZoomTarget_temp = readfloat();
		//flZoomTarget = flZoomTarget_temp;
		
		
		int iZoomLevel_temp = readbyte();
		if(iZoomLevel_temp != iZoomLevel){
		//	printfline("!!! ZoomLevel change A.  %i -> %i (%.2f)", iZoomLevel, iZoomLevel_temp, time);
		}
		
		if(!equippedWeaponWaitingForCallback){
			iZoomLevel = iZoomLevel_temp;
		}
	}
	
	
	
	nextAkimboAttackPreference = readbyte();
	akimboDualFireToleranceTime = readfloat();
	
	grenadeFireIndex = readbyte();
	grenadeHeldDuration = readfloat();
	grenadeSpawnTime = readfloat();
	bGrenadeToss = readbyte();
	
	
	armor = readbyte();
	iTotalSlots = readbyte();
	
	
	
	//flKarateBlockCooldown
	iMeleeCycler = readbyte();
	
	
	vViewAngleOffsetTotalChange[0] = readcoord();
	vViewAngleOffsetTotalChange[1] = readcoord();
	vViewAngleOffsetTotalChange[2] = readcoord();
	
	
	//TAGGG - vital to the viewangle-modifying kickback looking right
	// with prediction!
	setproperty(VF_CL_VIEWANGLES, GET_MY_VIEW_ANGLES + vViewAngleOffsetTotalChange);
	vViewAngleOffsetTotalChange = [0,0,0];
	
	
	fAccuracyKickback = readfloat();
	fAccuracyKickbackStartCooldown = readfloat();
	
	
	
	float fMoveBlockDelay_temp = readfloat();
	float fUncrouchBlockDelay_temp = readfloat();
	
	if(!equippedWeaponWaitingForCallback){
		fMoveBlockDelay = fMoveBlockDelay_temp;
		fUncrouchBlockDelay = fUncrouchBlockDelay_temp;
	}
	
	fKarateStamina = readfloat();
	
	
	aryNextBurstShotTime_softLength = readbyte();
	for(i = 0; i < aryNextBurstShotTime_softLength; i++){
		aryNextBurstShotTime[i] = readfloat();
	}
	aryNextBurstShotTime_listenIndex = readbyte() - 1;
	
	shotgunReloadIndex = readbyte();
	shotgunAddAmmoTime = readfloat();
	shotgunAddAmmoSoundTime = readfloat();
		
	
	ary_myWeapons_softMax = readbyte();
	
	
	this.completeInventorySend = readbyte();
	
#ifdef FORCE_NETWORK_ALL_INVENTORY
	this.completeInventorySend = TRUE;
#endif
	
	if(this.completeInventorySend){
		for(i = 0; i < ary_myWeapons_softMax; i++){
			ReceiveEntity_ary_myWeapons(i);
		}
		for(i = 0; i < AMMO_ID::LAST_ID; i++){
			ary_ammoTotal[i] = readlong();
		}
	}else if(fl & PLAYER_UNUSED1){
		
		//i = inventoryEquippedIndex;
		i = readbyte() - 1;
		
		/// could this ever be -1?
		if(i != -1){
			ReceiveEntity_ary_myWeapons(i);
			
			
			//int myAmmoType = getAmmoTypeOfWeapon(this.activeweapon);
			int betterID = ary_myWeapons[inventoryEquippedIndex].weaponID;
			int myAmmoType = getAmmoTypeOfWeapon(betterID);
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
		}/*else{
			// STUPID.
			ReceiveEntity_ary_myWeapons(0);
			ary_ammoTotal[0] = readlong();
		}
		*/
	}
	/////////////////////////////////////////////////////
	
	

	// TODO! Check for any change in ammo values like this:
	// Or maybe not, looks like Weapons_AmmoUpdate isn't needed for FreeTS, HUD draw methods
	// already use the current weapon's ammo valus per weapon on the HUD without it
	//    if (fl & PLAYER_AMMO1 || fl & PLAYER_AMMO2 || fl & PLAYER_AMMO3)
	//Weapons_AmmoUpdate(this);


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
#if OTHER_PREDICTION_TEST != 1
	ary_myWeapons[i].iBitsUpgrade_on = readbyte();
#endif
	
	ary_myWeapons[i].iFireMode = readbyte();
	
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
	int i;
	//printfline("---PREDICT PRE FRAME");
	
		
	/* the generic client attributes */
	base_player::PredictPreFrame();
	
	
	// client's way of calling prethink
	preThink();

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
	//SAVE_STATE(flZoomTarget);
	SAVE_STATE(iZoomLevel);
	SAVE_STATE(nextAkimboAttackPreference);
	SAVE_STATE(akimboDualFireToleranceTime);
	
	SAVE_STATE(grenadeFireIndex);
	SAVE_STATE(grenadeHeldDuration);
	SAVE_STATE(grenadeSpawnTime);
	SAVE_STATE(bGrenadeToss);
	
	
	//flKarateBlockCooldown
	SAVE_STATE(iMeleeCycler);
	
	
	SAVE_STATE(vViewAngleOffsetTargetDir);
	SAVE_STATE(vViewAngleOffsetTotalChange);
	SAVE_STATE(flViewAngleOffsetTarget);
	
	
	SAVE_STATE(fAccuracyKickback);
	SAVE_STATE(fAccuracyKickbackStartCooldown);
	
	SAVE_STATE(fMoveBlockDelay);
	SAVE_STATE(fUncrouchBlockDelay);
	SAVE_STATE(fKarateStamina);
	
	
	SAVE_STATE(aryNextBurstShotTime_softLength);
	for(i = 0; i < aryNextBurstShotTime_softLength; i++){
		SAVE_STATE_ARY(ary_ammoTotal, i);
	}
	SAVE_STATE(aryNextBurstShotTime_listenIndex);

	
	SAVE_STATE(shotgunReloadIndex);
	
	SAVE_STATE(shotgunAddAmmoTime);
	SAVE_STATE(shotgunAddAmmoSoundTime);
		
	
	SAVE_STATE(ary_myWeapons_softMax);
	for(i = 0; i < ary_myWeapons_softMax; i++){
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
	for(i = 0; i < AMMO_ID::LAST_ID; i++){
		// See serverside equivalent, too much info was lost from some pools being over 255
		// (well I guess that's all there is to it)
		SAVE_STATE_ARY(ary_ammoTotal, i);
	}
	
	// viewzoom must be set by the end of PrePredict or else it will not
	// reach the Nuclide logic looking at it in time to be applied.
	// No need here now I think?
	//this.viewzoom = this.flZoomCurrent;
	
#if OTHER_PREDICTION_TEST == 1
	Custom_Predict_PlayerPreFrame(this);
#endif
	
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
	int i;
	//printfline("---PREDICT POST FRAME");
	
	sendevent("ViewOffsetR", "fff", vViewAngleOffsetTotalChange[0], vViewAngleOffsetTotalChange[1], vViewAngleOffsetTotalChange[2]);
	
	
	/* the generic client attributes */
	base_player::PredictPostFrame();
	
	// client's way of calling postthink
	postThink();
	
	ROLL_BACK(anim_top);
	ROLL_BACK(anim_top_delay);
	ROLL_BACK(anim_top_time);
	ROLL_BACK(anim_bottom);
	ROLL_BACK(anim_bottom_time);
	
	ROLL_BACK(iState);
	ROLL_BACK(inventoryEquippedIndex);
	ROLL_BACK(weaponEquippedAkimbo);
	ROLL_BACK(w_attack_akimbo_next);
	ROLL_BACK(isReloading);
	ROLL_BACK(isChangingIronsight);
	//ROLL_BACK(flZoomTarget);
	
	ROLL_BACK(iZoomLevel);
	
	
	
	ROLL_BACK(nextAkimboAttackPreference);
	ROLL_BACK(akimboDualFireToleranceTime);
	
	ROLL_BACK(grenadeFireIndex);
	ROLL_BACK(grenadeHeldDuration);
	ROLL_BACK(grenadeSpawnTime);
	ROLL_BACK(bGrenadeToss);
	
	//flKarateBlockCooldown
	ROLL_BACK(iMeleeCycler);
	
	
	ROLL_BACK(vViewAngleOffsetTargetDir);
	ROLL_BACK(vViewAngleOffsetTotalChange);
	ROLL_BACK(flViewAngleOffsetTarget);
	
	
	ROLL_BACK(fAccuracyKickback);
	ROLL_BACK(fAccuracyKickbackStartCooldown);
	
	ROLL_BACK(fMoveBlockDelay);
	ROLL_BACK(fUncrouchBlockDelay);
	ROLL_BACK(fKarateStamina);
	
	ROLL_BACK(aryNextBurstShotTime_softLength);
	for(i = 0; i < aryNextBurstShotTime_softLength; i++){
		ROLL_BACK_ARY(ary_ammoTotal, i);
	}
	ROLL_BACK(aryNextBurstShotTime_listenIndex);

	
	
	ROLL_BACK(shotgunReloadIndex);
	ROLL_BACK(shotgunAddAmmoTime);
	ROLL_BACK(shotgunAddAmmoSoundTime);
	
	
	ROLL_BACK(ary_myWeapons_softMax);
	for(i = 0; i < ary_myWeapons_softMax; i++){
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

	// UNNECESSARY. This array is of fixed length, so known at all times.
	//WriteByte(MSG_ENTITY, ary_ammoTotal_softMax);
	for(i = 0; i < AMMO_ID::LAST_ID; i++){
		// See serverside equivalent, too much info was lost from some pools being over 255
		// (well I guess that's all there is to it)
		ROLL_BACK_ARY(ary_ammoTotal, i);
	}
	
	
#if OTHER_PREDICTION_TEST == 1
	Custom_Predict_PlayerPostFrame(this);
#endif
	
}


#else
void
player::EvaluateEntity(void)
{
	
	/* the generic client attributes */
	base_player::EvaluateEntity();
	
	int i;
	int myAmmoType;
	int betterID;

	/* animation */
	if (ATTR_CHANGED(anim_bottom) || ATTR_CHANGED(anim_bottom_time))
		SendFlags |= PLAYER_BOTTOMFRAME;
	if (ATTR_CHANGED(anim_top) || ATTR_CHANGED(anim_top_time) || ATTR_CHANGED(anim_top_delay))
		SendFlags |= PLAYER_TOPFRAME;

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
		//myAmmoType = getAmmoTypeOfWeapon(this.activeweapon);
		betterID = ary_myWeapons[inventoryEquippedIndex].weaponID;
		myAmmoType = getAmmoTypeOfWeapon(betterID);
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
	
	// iZoomLevel or flZoomTarget ?
	if(
		//ATTR_CHANGED(flZoomTarget)
		//||
		ATTR_CHANGED(iZoomLevel)
	){
		SendFlags |= PLAYER_UNUSED2;
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
	//SAVE_STATE(flZoomTarget);
	SAVE_STATE(iZoomLevel);
	SAVE_STATE(nextAkimboAttackPreference);
	SAVE_STATE(akimboDualFireToleranceTime);
	
	SAVE_STATE(grenadeFireIndex);
	SAVE_STATE(grenadeHeldDuration);
	SAVE_STATE(grenadeSpawnTime);
	SAVE_STATE(bGrenadeToss);
	
	//flKarateBlockCooldown
	SAVE_STATE(iMeleeCycler);
	
	
	SAVE_STATE(vViewAngleOffsetTargetDir);
	SAVE_STATE(vViewAngleOffsetTotalChange);
	SAVE_STATE(flViewAngleOffsetTarget);
	
	
	SAVE_STATE(fAccuracyKickback);
	SAVE_STATE(fAccuracyKickbackStartCooldown);
	
	SAVE_STATE(fMoveBlockDelay);
	SAVE_STATE(fUncrouchBlockDelay);
	SAVE_STATE(fKarateStamina);
	
	
	SAVE_STATE(aryNextBurstShotTime_softLength);
	for(i = 0; i < aryNextBurstShotTime_softLength; i++){
		SAVE_STATE_ARY(ary_ammoTotal, i);
	}
	SAVE_STATE(aryNextBurstShotTime_listenIndex);

	
	SAVE_STATE(shotgunReloadIndex);
	
	SAVE_STATE(shotgunAddAmmoTime);
	SAVE_STATE(shotgunAddAmmoSoundTime);
		
	
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


		//myAmmoType = getAmmoTypeOfWeapon(this.activeweapon);
		betterID = ary_myWeapons[inventoryEquippedIndex].weaponID;
		myAmmoType = getAmmoTypeOfWeapon(betterID);
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
	
	
#if OTHER_PREDICTION_TEST == 1
	Custom_EvaluateEntity(this);
#endif

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
	if(fChanged & PLAYER_UNUSED2){
		//WriteFloat(MSG_ENTITY, flZoomTarget);
		WriteByte(MSG_ENTITY, iZoomLevel);
	}
	WriteByte(MSG_ENTITY, nextAkimboAttackPreference);
	WriteFloat(MSG_ENTITY, akimboDualFireToleranceTime);
	
	WriteByte(MSG_ENTITY, grenadeFireIndex);
	WriteFloat(MSG_ENTITY, grenadeHeldDuration);
	WriteFloat(MSG_ENTITY, grenadeSpawnTime);
	WriteByte(MSG_ENTITY, bGrenadeToss);
	
	WriteByte(MSG_ENTITY, armor );
	WriteByte(MSG_ENTITY, iTotalSlots );
	
	//flKarateBlockCooldown
	WriteByte(MSG_ENTITY, iMeleeCycler);
	

	WriteCoord(MSG_ENTITY, vViewAngleOffsetTotalChange[0] );
	WriteCoord(MSG_ENTITY, vViewAngleOffsetTotalChange[1] );
	WriteCoord(MSG_ENTITY, vViewAngleOffsetTotalChange[2] );
	
	vViewAngleOffsetTotalChange = [0,0,0];
	
	WriteFloat(MSG_ENTITY, fAccuracyKickback);
	WriteFloat(MSG_ENTITY, fAccuracyKickbackStartCooldown);
	
	WriteFloat(MSG_ENTITY, fMoveBlockDelay);
	WriteFloat(MSG_ENTITY, fUncrouchBlockDelay);
	WriteFloat(MSG_ENTITY, fKarateStamina);
	
	
	WriteByte(MSG_ENTITY, aryNextBurstShotTime_softLength);
	for(i = 0; i < aryNextBurstShotTime_softLength; i++){
		WriteFloat(MSG_ENTITY, aryNextBurstShotTime[i]);
	}
	WriteByte(MSG_ENTITY, aryNextBurstShotTime_listenIndex + 1);
	
	
	WriteByte(MSG_ENTITY, shotgunReloadIndex );
	WriteFloat(MSG_ENTITY, shotgunAddAmmoTime );
	WriteFloat(MSG_ENTITY, shotgunAddAmmoSoundTime );
		

	
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
		
		i = (int)inventoryEquippedIndex;
		WriteByte(MSG_ENTITY, i + 1);
		
		/// could this ever be -1?
		if(i != -1){
			SendEntity_ary_myWeapons(i);

			//int myAmmoType = getAmmoTypeOfWeapon(this.activeweapon);
			int betterID = ary_myWeapons[inventoryEquippedIndex].weaponID;
			int myAmmoType = getAmmoTypeOfWeapon(betterID);
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
#if OTHER_PREDICTION_TEST != 1
	WriteByte(MSG_ENTITY, ary_myWeapons[i].iBitsUpgrade_on );
#endif
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
	
	
}// player constructor


// use TRUE for clean respawns,
// FALSE for only resetting some weapons-related vars between weapon changes, nothing too
// significant
void 
player::reset(BOOL resetInventory){
	
	INPUT_TAP_RESET(this)
	
	// should this even make any assumptions about this?
	//iState = ?;
	
	// seem like good ideas?
#ifdef SERVER
	dmg_take = 0;
	dmg_inflictor = NULL;
#endif
	
	resetZoom();
	
	//this.flViewAngleOffsetLerp = 1.0f;
	
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
	
	flViewShake = 0;
	
	recentLaserHitPosSet = FALSE;
	lasersightUnlockTime = FALSE;
	
	forceViewModelUpdate = FALSE;
	prev_iForceBodygroup1Submodel = 0;
	
	// assuming the player is in spectator and wanting to spawn soon.
	displayMinimumRespawnTimeCountdown = TRUE;
	old_cl_thirdperson = 0;
#endif
	
#ifdef SERVER
	switchToRecentlyAddedWeapon = FALSE;
	
	deathCameraChangeTime = 0;
	minimumRespawnTime = 0;
	waitingForSpawn = FALSE;
	waitingForEarlyNoclip = FALSE;
#endif
	
	
	// Shared, but don't network!  I think?
	aryNextBurstShotTime_softLength = 0;
	aryNextBurstShotTime_listenIndex = -1;
	
	
	iMeleeCycler = 0;
	
	//shotgun stuff.
	//NOTICE - all networked now, testing.
	
	shotgunReloadIndex = 0;
	shotgunAddAmmoTime = -1;
	shotgunAddAmmoSoundTime = -1;
		
	//Grenade stuff
	grenadeFireIndex = 0;
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
		
		
#ifdef CLIENT
		//TAGGG - BobNEW.
		pViewBob = &g_viewBobVars[s];
		pViewBob_reset();
#endif

		// do this at spawn too. oh right, this 'reset' method is called from there.
		
		//vViewAngleOffsetTarget = [0, 0, 0];
		flViewAngleOffsetTarget = 0;
		
		fAccuracyKickback = 0;
		fAccuracyKickbackStartCooldown = -1;
		
		fMoveBlockDelay = 0;
		fUncrouchBlockDelay = 0;
		fMoveBlockCapSpeed = 0;
		fKarateStamina = 1.0;
		
		flBaseSpeedMulti = 1;
		flMoveSpeedMulti = 1;
		flSoundSpeedMulti = 1;
		flFireDelayMulti = 1;
		flBulletSpeedMulti = 1;
		flProjectileSpeedMulti = 1;

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





// little test
//var float input_timelengthSum = 0;

// Count down my custom timers, called by ts/src/shared/input.qc, which is called
// by Nuclide's PMove, same place that counts down w_attack_next.
// Best to put things here that involve input_timelength.
void
player::updateTimers(void){
	
	
	// good place for this?  Cloned from w_attack_next as a separate counter
	// for akimbo firing to use.
	w_attack_akimbo_next = max(0, w_attack_akimbo_next - input_timelength);	
	
	akimboDualFireToleranceTime = max(0, akimboDualFireToleranceTime - input_timelength);
	
	fMoveBlockDelay = max(0, fMoveBlockDelay - input_timelength);
	fUncrouchBlockDelay = max(0, fUncrouchBlockDelay - input_timelength);
	
	/*
	// little test.  See input_timelengthSum shoot up with packet latency.
	input_timelengthSum += input_timelength;	
	if(otherTimer >= 1.0){
		otherTimer -= 1.0;
		printfline("input_timelengthSum: %.2f", input_timelengthSum);
		input_timelengthSum = 0;
	}
	*/
	
	fAccuracyKickbackStartCooldown = max(0, fAccuracyKickbackStartCooldown - input_timelength);
	
	if(fKarateStamina < 1.0){
		//fKarateStamina = bound(0, fKarateStamina + frametime * 0.1667, 1);
		fKarateStamina = bound(0, fKarateStamina + input_timelength * 0.1667, 1);
	}
	
	//printfline("KARATE STAMINA? %.2f", fKarateStamina);
	
	if(fAccuracyKickbackStartCooldown != -1){
		if(fAccuracyKickbackStartCooldown <= 0){
			// begin reducing
			//fAccuracyKickback -= frametime * 0.1;
			fAccuracyKickback = max(0, fAccuracyKickback - input_timelength * 0.1);
			
			if(fAccuracyKickback <= 0){
				// stop!
				fAccuracyKickbackStartCooldown = -1;
			}
		}
	}//kickbackStartCooldown check
	
	
	/*
	#ifdef CLIENT
	#define my_frametime clframetime
	#else
	#define my_frametime frametime
	#endif
	*/
	
	#define my_frametime input_timelength
	
	//vector viewChange;
	float flViewChange;
	vector vViewChangeDir;
	
	
	if(flViewAngleOffsetTarget <= 0.02){
		flViewChange = this.flViewAngleOffsetTarget;
		vViewChangeDir = this.vViewAngleOffsetTargetDir;
		this.flViewAngleOffsetTarget = 0;
	}else{
		float lenOfVAOT = this.flViewAngleOffsetTarget;
		float amountToChangeBy = this.flViewAngleOffsetTarget * 36 * my_frametime;
		float amountToReduceBy = this.flViewAngleOffsetTarget * 18 * my_frametime;
		
		//printfline("COMPARISON? cb:%.2f rb:%.2f - total:%.2f", amountToChangeBy, amountToReduceBy, lenOfVAOT);
		
		// if changing the vViewOffsetTarget by this much would
		// go past the offset into pushing it past what was intended,
		// don't allow that!  Might not even be possible
		if(amountToReduceBy >= lenOfVAOT){
			flViewChange = this.flViewAngleOffsetTarget;
			vViewChangeDir = this.vViewAngleOffsetTargetDir;
			this.flViewAngleOffsetTarget = 0;
		}else{
			this.flViewAngleOffsetTarget -= amountToReduceBy;
			
			flViewChange = amountToChangeBy;
			vViewChangeDir = this.vViewAngleOffsetTargetDir;
		}
	}
	
	vector finalChange = flViewChange * vViewChangeDir;
	
	
	this.vViewAngleOffsetTotalChange += finalChange;
	
	// test?  main one
#ifndef CLIENT
	GET_MY_VIEW_ANGLES = GET_MY_VIEW_ANGLES + finalChange;
	// (this might be pointless?)
	this.vViewAngleOffsetTotalChangeAlt += finalChange;
#else
	
#endif
	
	
	
}//updateTimers




// add kickback that pushes the camera by some angle.
// Cumulative with existing kickback not yet finished being applied.
void player::addViewAngleOffset(float arg_ang, float arg_len){
	
	
	if(flViewAngleOffsetTarget == 0){
		// easy, replace completely
		flViewAngleOffsetTarget = arg_len;
		vViewAngleOffsetTargetDir = [-sin(arg_ang), cos(arg_ang), 0];
	}else{
		// Have to unpack the vector, add it, and re-do the split value/dir way.
		// Might be a smarter way to do that math-wise but this works for now
		vector tempVec = flViewAngleOffsetTarget * vViewAngleOffsetTargetDir;
		vector newVec = arg_len * [-sin(arg_ang), cos(arg_ang), 0];
		tempVec = tempVec + newVec;
		flViewAngleOffsetTarget = vlen(tempVec);
		if(flViewAngleOffsetTarget != 0){
			vViewAngleOffsetTargetDir = tempVec / flViewAngleOffsetTarget;
		}else{
			// what.
			// Nothing to do, leave flViewAngleOffsetTarget at 0 to be ignored
		}
	}
}



#ifdef CLIENT

// client only, check some other input-related CVars.
void
player::clientInputUpdate(void){
	
	//printfline("---clientInputUpdate");
	
}

void
player::clientUseItemsCallback(void){
	
	
}






// - initially from The Wastes.
void player::handleZoom(void)
{
	
	if(this.iState != PLAYER_STATE::SPAWNED){
		// zoom is only allowed for ingame.
		return;
	}
	
	// test
	/*
	this.flZoomCurrent = this.flZoomTarget;
	this.viewzoom = this.flZoomTarget;
	printfline("flZoomTarget: %.2f", this.flZoomTarget);
	return;
	*/
	
	//printfline("WHATS GOING ON %.2f %.2f %.2f %.2f %.2f", this.flZoomEnd, this.flZoomTarget, this.flZoomStart, this.flZoomLerp, this.flZoomCurrent);
	
	// - No other codebase refers to STAT_VIEWZOOM, best to replace anything
	// involving that.
	
	// in case of some unexpected change.
	// TODO: this might have an issue if the player were to change weapons and end up
	// on the same zoom level as a previous weapon, despite the two weapons having
	// different target values (like 0.4 vs. 0.6) at their own zoom level #1's.
	// A check for being a different equipped weapon type
	// (this.activeweapon vs. this.activeweapon_zoomprev, set only by setZoomLevel)
	// ought to work.  But that would be a very strange case anyway
	if(this.iZoomLevel != this.iZoomLevelPrev){
		this.setZoomLevel(this.iZoomLevel);
	}
		
	if (this.flZoomEnd != this.flZoomTarget ) {
		//printfline("NEW ZOOM DETECTED: %.2f -> %.2f (zoomlev: %i)", this.flZoomEnd, this.flZoomTarget, this.iZoomLevel);
		
		// is setting flZoomStart to flZoomEnd or flZoomCurrent a better idea?
		// at flZoomEnd means, on changing before the current lerp has finished, it jumps to beginning
		// at the end point of the lerp in progress.  But starting at flZoomCurrent might be smoother?
		// if it isn't glitchy that could be nice.  Trying that out.
		
		this.flZoomStart = this.flZoomCurrent;
		//this.flZoomStart = this.flZoomEnd;
		
		this.flZoomEnd = this.flZoomTarget;
		this.flZoomLerp = 0.0f;
	}

	if (this.flZoomLerp < 1.0f) {
		// Slow this down for debugging purposes, this is meant to be fast.
		// 0.8 can be safe.
		// The Wastes default was 4.
		
		// !!! clframetime, frametime, or input_timelength ?
		this.flZoomLerp += clframetime * 5.7;
		
		if(this.flZoomLerp >= 1.0){
			//enforce the cap.
			this.flZoomLerp = 1.0;
		}
		
		//this.flZoomCurrent = getstatf(STAT_VIEWZOOM);
		this.flZoomCurrent = Math_Lerp(this.flZoomStart, this.flZoomEnd, this.flZoomLerp);
	}
	
	// Set this, since Nuclide will read it in and apply instantly.
	// So same effect without having to edit Nuclide, this pipes it over for it
	// to do the setproperty thing below to apply
	//this.viewzoom = this.flZoomCurrent;

	////setproperty(VF_AFOV, DEFAULT_FOV * this.flZoomCurrent);
	////setsensitivityscaler(this.flZoomCurrent);
	
	// here's the way old FreeCS did it
	//setproperty(VF_AFOV, cvar("fov") * this.viewzoom);
	//setsensitivityscaler(this.viewzoom);
	
	
	
	
}// TS_View_HandleZoom



#endif








void
player::setZoomLevel(int arg_iZoomLevel){
	iZoomLevel = arg_iZoomLevel;
	
#ifdef CLIENT
	iZoomLevelPrev = iZoomLevel;
#endif
	
	weapondata_basic_t* myDat = getEquippedWeaponData();
	
	if(myDat != NULL){
		if(myDat.funOnSetZoomLevel != NULL){
			myDat.funOnSetZoomLevel(this);
		}
	}
	
}

// forget any zoom-related settings instantly.
// Unsure if a message should be sent to the client if called from the server, or assume the
// calls coincide.
void
player::resetZoom(void)
{
	iZoomLevel = 0;
	viewzoom = 1.0f;
	flZoomTarget = 1.0f;
	
#ifdef CLIENT
	// IMPORTANT!  ZoomLerp under 0 tries to involve flZoomOld, set or not
	flZoomLerp = 1.0f;
	/*
	SAVE_STATE(iZoomLevel);
	SAVE_STATE(viewzoom);
	//SAVE_STATE(flZoomTarget);
	*/
	flZoomEnd = 1.0f;
	flZoomCurrent = 1.0f;
#endif
}

// similar as above, but still go for the transition smoothness,
// not an instant change
void
player::resetZoomSoft(void)
{
	iZoomLevel = 0;
	flZoomTarget = 1.0f;
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



#ifdef SERVER
// (Comment may be out of date, verify if serverside postthink or setting think methods
// anywhere still has issues)
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
	TSMultiplayerRules rules;
	
	// no, leave that to shared/input.qc
	//updateTimers();
	
	//preThinkShared();

	// only in DEAD_RECENT.  This is the temporary third-person for looking at the recently
	// dead player (self).  After the countdown is over, goto the NOCLIP one.
	if(iState == PLAYER_STATE::DEAD_RECENT){
		
		if(deathCameraChangeTime > 0){
			deathCameraChangeTime -= frametime;
		}
		if(deathCameraChangeTime <= 0 || (waitingForEarlyNoclip && deathCameraChangeTime <= 1.5) ){
			// time's up?  Go ahead and change
			deathCameraChangeTime = 0;
			rules = (TSMultiplayerRules)g_grMode;
			rules.PlayerMakeSpectatorAndNotify(this);
			
		}
	}
	
	if(iState != PLAYER_STATE::SPAWNED){
		// Once this delay has passed, spawning is allowed.
		// If the click was very close to the end (waitingForSpawn), count it and spawn
		// as soon as possible anyway, helps with some lag perhaps.
		if(minimumRespawnTime > 0){
			minimumRespawnTime -= frametime;
			if(minimumRespawnTime <= 0){
				minimumRespawnTime = 0;
				if(waitingForSpawn){
					// do it!
					rules = (TSMultiplayerRules)g_grMode;
					rules.PlayerMakePlayableWithDefaultMoney(this);
				}else{
					// Nothing special happens, user must click to spawn.
				}
			}
		}
	}// not-SPAWNED check
	
	
}// frameThink_fromServer

#endif



// preThink & postThink are supporter client and serverside.
// They're not built-in methods per entity nor called by Nuclide.
// For clientside, preThink/postThink are called by prediction pre/post methods.
// For serverside, gamerules "Player(Pre/Post)Frame" events call these for every
// player.
// An above comment says there were problems with serverside postthink, but unsure
// if that is still the case.

#ifdef CLIENT
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
	
	
	
	// show a printout of how long until the player can click to spawn.
	// TODO - use our own system instead to use a larger font, and the same one
	// used for the buymenu buttons, most things seem to do that.
	// Also, any 'Using New Config' centerprint will be overwritten by this instantly,
	// so there should probably be a check to let that one appear independently of this
	// countdown and below if both need to be shown.
	// ALSO, making the "iState == PLAYER_STATE::NOCLIP" check less strict.
	// It is possible to stop this slightly early, but may as well send the
	// "Press fire to play" anyway, not much earlier is allowed.
	if(iState != PLAYER_STATE::DEAD_RECENT && displayMinimumRespawnTimeCountdown){
		int roundedMinimumRespawnTime = (int)ceil(getstatf(STAT_MINIMUMRESPAWNTIME));
		if(roundedMinimumRespawnTime != 0){
			CSQC_Parse_CenterPrint(sprintf("%i", roundedMinimumRespawnTime));
		}else{
			// last one.
			displayMinimumRespawnTimeCountdown = FALSE;
			CSQC_Parse_CenterPrint("Press fire to play!");
		}
	}
	
	
	
	preThinkShared();
	
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

#endif // CLIENT


#ifdef SERVER
void
player::preThink(void){
	
	if(autocvar_sv_printoutspam == 1){
		printfline("My state: %d", iState);
		printfline("STATUS: %d, %i", activeweapon, inventoryEquippedIndex);
	}
	
	//self.angles += '0 0.3 0';
	//self.v_angle = self.angles;
	
	preThinkShared();
	
	
}// preThink

void
player::postThink(void){
	
}// postThink
#endif



// timer vars modified in here should use 'frametime'.
// could/should clframetime be used for clientside intead?  Unsure.
void
player::preThinkShared(void){
	
	// Empty, for now.
	
}



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


