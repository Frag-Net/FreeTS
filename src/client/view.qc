/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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


// Nuclide offers Weapons_SetGeomset for calling "setcustomskin" too, but one string
// at a time.  Don't really know if that way or the current way (cumulative string for
// many commands delimited in one setcustomskin call) is any better, so leaving this as
// it is for now.


// vm is pSeat->m_eViewModel passed along from Nuclide's View_DrawViewModel
void
View_UpdateWeapon(entity vm, entity mflash)
{
	player pl = (player)pSeat->m_ePlayer;
	
	if(autocvar_cl_printoutspam == 1){
		printfline("STATUS: %i==%d - %i", pSeat->m_iLastWeapon, pl.activeweapon, pl.inventoryEquippedIndex);
	}
	
	/* only bother upon change */
	if (pSeat->m_iLastWeapon == pl.activeweapon) {
		
		/*
		if(pl.activeweapon == 0 && pl.inventoryEquippedIndex != -1){
			// what??
			pl.setInventoryEquippedIndex(pl.inventoryEquippedIndex);
		}else{
			TS_View_RoutineCheck();
			return;
		}
		*/
		TS_View_RoutineCheck();
		return;
	}
	printfline("View_UpdateWeapon: change detected: %i -> %d", pSeat->m_iLastWeapon, pl.activeweapon);
	printfline("and how about the others %d %i", pl.activeweapon, pl.inventoryEquippedIndex);
	
	
	pSeat->m_iOldWeapon = pSeat->m_iLastWeapon;
	pSeat->m_iLastWeapon = pl.activeweapon;

	if (!pl.activeweapon /*|| pl.inventoryEquippedIndex < 0*/) {
		// can't work with this!
		TS_View_ResetViewModel();
		return;
	}

	//printfline("View_UpdateWeapon: change: %d vs %d", pSeat->m_iLastWeapon, pl.activeweapon);
	
	// Call this to do a few other things for any weapon change
	TS_Weapon_Draw_extra();
	
	// hack, we changed the wep, move this into Game_Input/PMove
	// ... And yes, it seems this bound check is indeed needed, zany sync issues.
	if(pl.inventoryEquippedIndex != -1){
		Weapons_Draw();
	}
	
	TS_View_ChangeViewModelPost();
}



void
TS_View_SetViewModelFromStats(void)
{
	player pl = (player)pSeat->m_ePlayer;
	entity vm = pSeat->m_eViewModel;
	entity mflash = pSeat->m_eMuzzleflash;
	entity mflashAkimbo = pSeatLocal->m_eMuzzleflashAkimbo;
	weapondata_basic_t* basicP;
	weapondynamic_t dynaRef;
	
	if(pl.inventoryEquippedIndex == -1){
		// what.
		return;
	}
	
	//printfline("TS_View_SetViewModelFromStats:  I happen? activeweap:%d", pl.activeweapon);
	
	basicP = pl.getEquippedWeaponData();
	dynaRef = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	//TAGGG NOTE - we're not supporting skins apparently
	//if (autocvar_skins_dir != "") {
	//	wm = sprintf("skins/%s/%s", autocvar_skins_dir, sViewModels[ aw - 1 ]);
	//} else {
	//	wm = sprintf("models/%s", sViewModels[ aw - 1 ]);
	//}
	//TAGGG NOTE - we're not using that "sViewModels" string either.
	// Grab the currently equipped weapon, its weapon info, and from there pull the viewmodel to use
	weapondata_basic_t* basicPointer = (weapondata_basic_t*) ary_weaponData[dynaRef.weaponID];
	weapondata_basic_t basicRef = *(basicPointer);
	
	
	
	Weapons_SetModel((*basicP).sViewModelPath);
	
	string cumulativeCommandString = "";
	
	// If this weapon is a Gun (or ironsight-able), check for the presence of attachment-giving
	// buyopts.
	if(basicRef.typeID == WEAPONDATA_TYPEID_GUN || basicRef.typeID == WEAPONDATA_TYPEID_IRONSIGHT){
		weapondata_gun_t gunRef = *((weapondata_gun_t*)basicPointer);
		
		if(dynaRef.iBitsUpgrade & BITS_WEAPONOPT_SILENCER){
			// has the silencer? and an attachment?
			if(gunRef.silencer_part != -1){
				cumulativeCommandString = sprintf("%sgeomset %i 2\n", cumulativeCommandString, gunRef.silencer_part );
			}
		}
		if(dynaRef.iBitsUpgrade & BITS_WEAPONOPT_LASERSIGHT){
			// has the silencer? and an attachment?
			if(gunRef.lasersight_part != -1){
				cumulativeCommandString = sprintf("%sgeomset %i 2\n", cumulativeCommandString, gunRef.lasersight_part );
			}
		}
		if(dynaRef.iBitsUpgrade & BITS_WEAPONOPT_FLASHLIGHT){
			// has the silencer? and an attachment?
			if(gunRef.flashlight_part != -1){
				cumulativeCommandString = sprintf("%sgeomset %i 2\n", cumulativeCommandString, gunRef.flashlight_part );
			}
		}
		if(dynaRef.iBitsUpgrade & BITS_WEAPONOPT_SCOPE){
			// has the silencer? and an attachment?
			if(gunRef.scope_part != -1){
				cumulativeCommandString = sprintf("%sgeomset %i 2\n", cumulativeCommandString, gunRef.scope_part );
			}
		}
	}//END OF gun type check (is a gun of some sort)
	
	if(dynaRef.iForceBodygroup1Submodel > 0){
		cumulativeCommandString = sprintf("%sgeomset 0 %i\n", cumulativeCommandString, dynaRef.iForceBodygroup1Submodel );
	}
	// no need to do that geomset with the same value again.
	pl.prev_iForceBodygroup1Submodel = dynaRef.iForceBodygroup1Submodel;
	
	setcustomskin(vm, "", cumulativeCommandString);
	
	TS_View_ChangeViewModelPost();
	
	// Don't let View_UpdateWeapon do this all over.
	pSeat->m_iLastWeapon = pl.activeweapon;

}//TS_View_SetViewModelFromStats




// On any frame, see if something about the current viewmodel needs to be changed
void
TS_View_RoutineCheck(void)
{
	player pl = (player)pSeat->m_ePlayer;
	entity vm = pSeat->m_eViewModel;
	weapondynamic_t dynaRef;
	
	// That can happen, apparently.
	if(pl.inventoryEquippedIndex == -1){
		return;
	}
	
	dynaRef = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	if(pl.prev_iForceBodygroup1Submodel != dynaRef.iForceBodygroup1Submodel){
		
		if(dynaRef.iForceBodygroup1Submodel > 0){
			string commandString;
			commandString = sprintf("geomset 0 %i\n", dynaRef.iForceBodygroup1Submodel );
			setcustomskin(vm, "", commandString);
		}
		pl.prev_iForceBodygroup1Submodel = dynaRef.iForceBodygroup1Submodel;
	}
	
}//TS_View_RoutineCheck



// Used to be in View_UpdateWeapon, now also called for manual changes clientside too
// (TS_View_SetViewModelFromStats above).
void
TS_View_ChangeViewModelPost(void)
{
	player pl = (player)pSeat->m_ePlayer;
	entity vm = pSeat->m_eViewModel;
	entity mflash = pSeat->m_eMuzzleflash;
	entity mflashAkimbo = pSeatLocal->m_eMuzzleflashAkimbo;
	
	/* we forced a weapon call outside the prediction,
	 * thus we need to update all the net variables to
	 * make sure these updates are recognized. this is
	 * vile but it'll have to do for now */
	SAVE_STATE(pl.w_attack_next);
	SAVE_STATE(pl.w_idle_next);
	SAVE_STATE(pl.viewzoom);
	SAVE_STATE(pl.weapontime);
	//TAGGG - NEW VAR
	SAVE_STATE(pl.w_attack_akimbo_next);
	SAVE_STATE(pl.iZoomLevel);
	//SAVE_STATE(pl.flZoomTarget);

	//TAGGG - also new line.  It is a good idea to reset the event
	// on changing models, right?
	pSeat->m_pEventCall = NULL;
	
	
	skel_delete( mflash.skeletonindex );
	mflash.skeletonindex = skel_create( vm.modelindex );
	pSeat->m_iVMBones = skel_get_numbones( mflash.skeletonindex ) + 1;
	
	
	///skel_delete(mflashAkimbo.skeletonindex);
	
	// could we just reuse the mflash.skeletonindex here?
	//mflashAkimbo.skeletonindex = skel_create(vm.modelindex);
	mflashAkimbo.skeletonindex = mflash.skeletonindex;
	
	// no need to set m_iVMBones again, nor have a separate copy.  How could it
	// be any different for the akimbo one (clone of mflash)
	
}//TS_View_ChangeViewModelPost


void
TS_View_ResetViewModel(void)
{
	printfline("TS_View_ResetViewModel called.");
	
	if(pSeat->m_ePlayer == NULL){
		printfline("TS_View_ResetViewModel: early end #1, client ent NULL");
		return;
	}
	
	// was m_eViewModel and m_eMuzzleflash
	entity vm = pSeat->m_eViewModel;
	entity mflash = pSeat->m_eMuzzleflash;
	entity mflashAkimbo = pSeatLocal->m_eMuzzleflashAkimbo;

	setmodel( vm, "" );
	
	skel_delete( mflash.skeletonindex );
	mflash.skeletonindex = 0;
	
	pSeat->m_iVMBones = 0 + 1;
	
	// ! If the skeletonindex becomes shared, skel_delete for each will not be necessary
	//skel_delete(mflashAkimbo.skeletonindex);
	mflashAkimbo.skeletonindex = 0;
	
	
	/*
	player pl = (player) pSeat->m_ePlayer;
	pl.setInventoryEquippedIndex(-1);  //do we have to?
	*/
	
}// TS_View_ResetViewModel



// NEW, helper method, not called by Nuclide
// Does the same Nuclide script to draw the normal viewmodel at viewzooms between 0.5
// and 1.0, Nuclide skips drawing it on any zoom below 1.0 unlike original TS.
// Also, handles drawing the akimbo muzzle flash.
// Do not call from View_UpdateWeapon.  Calling from LatePreDraw (new TS pseudo-event)
// is best.
// Also this is "Draw" as in render, not equip a weapon
void
TS_View_DrawCustom(player pl){
	
	// Same forbidding conditions from Nuclide's src/client/view.qc
	if (pl.health <= 0) {
		return;
	}
	if (cvar("r_drawviewmodel") == 0 || autocvar_cl_thirdperson == TRUE) {
		return;
	}
	
	// Nuclide does not draw the viewmodel at any zoom other than 1.0 (unmodified).
	// So, this draws the viewmodel the othertimes TS did, in lower zoom choices.
	// At viewzoom 0.5 and above, the scope graphic is not drawn so it is safe to
	// do this.
	if(pl.viewzoom >= 0.5){
		entity m_eViewModel = pSeat->m_eViewModel;
		entity m_eMuzzleflash = pSeat->m_eMuzzleflash;
		entity m_eMuzzleflashAkimbo = pSeatLocal->m_eMuzzleflashAkimbo;
		
		// (only re-do the default Nuclide viewmodel + normal muzzleflash script if we have reason
		// to believe Nuclide didn't, i.e., a zoom under 1.0)
		if(pl.viewzoom < 1.0){
			// CLONE OF NUCLIDE SCRIPT
			/////////////////////////////////////////////////////////////////////////////
			if (m_eMuzzleflash.alpha > 0.0f) {
				makevectors(getproperty(VF_ANGLES));
				m_eMuzzleflash.origin = gettaginfo(m_eViewModel, m_eMuzzleflash.skin);
				m_eMuzzleflash.angles = m_eViewModel.angles;
				m_eMuzzleflash.angles[2] += (random() * 10) - 5;

				/*dynamiclight_add(pSeat->m_vecPredictedOrigin + (v_forward * 32), 400 * m_eMuzzleflash.alpha, [1,0.45,0]);*/

				setorigin(m_eMuzzleflash, m_eMuzzleflash.origin);
				addentity(m_eMuzzleflash);
			}
			setorigin(m_eViewModel, m_eViewModel.origin);
			addentity(m_eViewModel);
			/////////////////////////////////////////////////////////////////////////////
		}
		
		// Regardless of being 1.0 or not (Nuclide certainly isn't doing this),
		// handle the other muzzleflash too
		if (m_eMuzzleflashAkimbo.alpha > 0.0f) {
			makevectors(getproperty(VF_ANGLES));
			m_eMuzzleflashAkimbo.origin = gettaginfo(m_eViewModel, m_eMuzzleflashAkimbo.skin);
			m_eMuzzleflashAkimbo.angles = m_eViewModel.angles;
			m_eMuzzleflashAkimbo.angles[2] += (random() * 10) - 5;

			/*dynamiclight_add(pSeat->m_vecPredictedOrigin + (v_forward * 32), 400 * m_eMuzzleflashAkimbo.alpha, [1,0.45,0]);*/

			setorigin(m_eMuzzleflashAkimbo, m_eMuzzleflashAkimbo.origin);
			addentity(m_eMuzzleflashAkimbo);
		}
	}
	
	if(pl.bShellEjectScheduled){
		pl.bShellEjectScheduled = FALSE;
		
		// TODO - how about a first-person check?  Doesn't make sense if in thirdperson.
		// Although that might've been needed earlier unless this event-thing works fine for being
		// a playermodel too.  Players other than the local one being rendered and needing to drop
		// shells, that sounds like a whole other story
		if(pl.iShellEjectType != SHELLEJECT_ID::NONE){
			CTSShellEject::generateForViewModelAkimbo(pl.iShellEjectType, pl.iShellEjectAkimboChoice);
		}
	}
	
}


// another helper method
// Draw the lasersight, and flashlight effects

// IDEA: any way to give the effect of RF_DEPTHHACK (always draw on top of the map
// so that flashlight muzzle glow-effects don't clip through the map), or the RF_ADDITIVE
// that muzzle flashes use for being an effect in general?  Probably unnecessary anyway.
// Flashlight glow effects do clip through the map in original TS so not a huge priority anyway,
// and showing up in front of the weapon would not be amazing.
// Effects like muzzleflashes don't even do anything special with depth-hackery so, eh.
void
TS_View_DrawExtraEffects(player pl, int thirdperson)
{
	//int thirdperson = (autocvar_cl_thirdperson == TRUE || this.entnum != player_localentnum);
	//base_player pp = (base_player)this;

	BOOL canRenderFlashlight = FALSE;
	BOOL canRenderLaserSight = FALSE;
	
	//player pl = (player)pp;
	//we're going to use the buyopts of our current weapon + the one actually turned on, yah?
	
	// DEBUG: printouts about the other player.
	// Start a server with over 1 max players allowed in one window, 
	// connect to it in another window.  Boom, read printouts.
	/*
	if(entnum != player_localentnum){
		// so other player's "pl.weaponEquippedID" are not sent over to our clientside copies of them... I guess?
		// At least that's not confusing.
		printfline("It is I, the other player!  What do I have? %i weapon count: %i", pl.weaponEquippedID, pl.ary_myWeapons_softMax);
	}
	*/
	
	
	if(pl.inventoryEquippedIndex != -1){
		
		weapondynamic_t dynaRef = pl.ary_myWeapons[pl.inventoryEquippedIndex];
		
		if(dynaRef.weaponTypeID == WEAPONDATA_TYPEID_GUN || dynaRef.weaponTypeID == WEAPONDATA_TYPEID_IRONSIGHT){
			weapondata_basic_t* basePRef = pl.getEquippedWeaponData();
			weapondata_basic_t baseRef = *basePRef;
			
			
			// We must have the flashlight bit on, AND support it on our weapon, AND it be a possibility according to weapon data.
			int legalBuyOpts_on = (dynaRef.iBitsUpgrade_on & (dynaRef.iBitsUpgrade & baseRef.iBitsUpgrade));
			
			if(legalBuyOpts_on & BITS_WEAPONOPT_FLASHLIGHT){
				canRenderFlashlight = TRUE;
			}
			if(legalBuyOpts_on & BITS_WEAPONOPT_LASERSIGHT){
				canRenderLaserSight = TRUE;
			}
		}///END OF _GUN or _IRONSIGHT type checks
	}//END OF weaponEquippedID check
	
	
	
	vector posView;
	vector angView;
	
	//for glock it is 40.
	//vector gunpos = gettaginfo(pSeat->eViewModel, 33);
	
	float drawAlpha = 1.0;
	const vector lasColor = [1.0, 0, 0];
	const vector fsize = [2,2];
	const vector fsizeDot = [18,18];
	const vector fsizeFlashlightMuzzleGlow = [3, 3];
	
	vector flashPos;
	vector gunpos;
	vector gunpos2 = [0,0,0];
	vector gunpos_tempEnd;
	
	
	vector dirGun = [0,0,0];
	vector dirGun2 = [0,0,0];
	vector angGun = [0,0,0];
	vector angGun2 = [0,0,0];
	
	//TAGGG - IMPORTANT NOTE!!!
	// BEWARE "view_angles", it is a client global (what a confusing term), meaning it pertains only to THIS
	// client (local player), no matter what player is being rendered by this call.
	// wait... shouldn't we do the third-person check for the flash-light check above too?
	
	BOOL canDrawAkimboLaser = FALSE;
	pl.recentLaserHitPosSet = TRUE;
	
	
	
	// TAGGG - QUESTION:  Is it better to use the bool "thirdperson"
	// (see check below involving cl_thirdperson)
	// OR a raw "pl.entnum != player_localentnum" check?
	// The former is a more concrete check for, "Am I the local player
	// looking in 1st person, yes or no?".
	// The latter will still treat the player being the local player the
	// same as firstperson, even if the local player is forcing themselves
	// to be viewed in third person.
	// I am inclined to think the former is the better choice, but
	// valve/src/client/flashlight.qc uses the latter way.  Why?
	
	// thirdperson
	// True IF (autocvar_cl_thirdperson == TRUE || this.entnum != player_localentnum)
	// False IF (autocvar_cl_thirdperson == FALSE && this.entnum == player_localentnum)
	if(!thirdperson){
		
		//TAGGG - Old way!
		//posView = getproperty(VF_ORIGIN) + [0,0,-8];
		//angView = getproperty(VF_CL_VIEWANGLES);
		
		posView = pSeat->m_vecPredictedOrigin + [0,0,-8];
		angView = view_angles;
		
		// CHECK: is "getproperty(VF_CL_VIEWANGLES)" always the same as "view_angles"?
		
		if(!pl.weaponEquippedAkimbo){
			// first-person and this is the local player?
			// We can get more specific info from the visible viewmodel, do so!
			gunpos = gettaginfo(pSeat->m_eViewModel, pSeat->m_iVMBones + 0i);
			gunpos_tempEnd = gettaginfo(pSeat->m_eViewModel, pSeat->m_iVMBones + 3i);
			// should shell casings come from a bit behind the firing point here when needed?
			//gunpos += v_right * 0.8;  //why is this 'up'??
			// not this one maybe... what the hell is this direction at all.
			//gunpos += v_forward * -1.8;
			
			dirGun = normalize(gunpos_tempEnd - gunpos);
			angGun = vectoangles(dirGun);
			
		
		}else{
			canDrawAkimboLaser = TRUE;
			
			gunpos = gettaginfo(pSeat->m_eViewModel, pSeat->m_iVMBones + 0i);
			gunpos_tempEnd = gettaginfo(pSeat->m_eViewModel, pSeat->m_iVMBones + 1i);
			dirGun = normalize(gunpos_tempEnd - gunpos);
			angGun = vectoangles(dirGun);
			
			gunpos2 = gettaginfo(pSeat->m_eViewModel, pSeat->m_iVMBones + 2i);
			gunpos_tempEnd = gettaginfo(pSeat->m_eViewModel, pSeat->m_iVMBones + 3i);
			dirGun2 = normalize(gunpos_tempEnd - gunpos2);
			angGun2 = vectoangles(dirGun2);
		}
		
	}else{
		
		posView = pl.origin + pl.view_ofs;
		angView = [pl.pitch, pl.angles[1], pl.angles[2]];
		gunpos = posView;
		angGun = angView;
	}



	if(canRenderLaserSight && pl.entnum == player_localentnum){
		// The lasersight displays a number of distance to show how long the laser goes.
		//makevectors(view_angles);
		makevectors(angView);
		traceline(posView, posView + v_forward * 2048*4, MOVE_HITMODEL, pl);
		pl.recentLaserDistanceDisplay = (int)(vlen(trace_endpos - posView) / 40 );
	}
	
	
	// DEBUG!!!
	//canRenderLaserSight = TRUE;
	//canRenderFlashlight = TRUE;
	
	if(canRenderFlashlight){
		//TAGGG - FLASHLIGHT STUFF HERE..
		// oh wait a comment above already said that
		// HOWEVER... in TS flashlights have a range limit.  Up to so far they have max brightness,
		// then it lowers with a bit of range, then it's nothing.
		
		
		////////////////////////////////////////////////////////////////////////////////////
		int flashlightRangeMax = 1070;
		float flashlightBrightnessFactor = 1.0;
		float rangeDimPriorStart = 170;   //rangeMax minus this is where I start dimming.
		
		makevectors(angView);
		
		traceline(posView, posView + (v_forward * flashlightRangeMax), MOVE_NORMAL, pl);
		int traceDist = trace_fraction * flashlightRangeMax;
		
		//printfline("%.2f %d",, trace_fraction, trace_inopen);
		
		//TODO - not here but elsewhere, draw the muzzle flashlight effect, some sprite on that gun attachment where am uzzleflash would go should do it.
		// ALSO, go ahead and use this line trace to tell the lasersight how far the laser went.
		// And just draw the lasersight (and dot if necessary), IF this render is for the local player.
		// If not the local player, a slightly larger red dot (actual sprite) goes at the point the 
		// player is looking, likely not influenced by animations / view-model stuff.
		
		
		if(trace_fraction == 1.0){
			//uh-oh.
			flashlightBrightnessFactor = 0;
		}if(traceDist >= flashlightRangeMax - rangeDimPriorStart){
			//the flashlight gets dimmer the further it is at this point.
			// rangeDimPriorStart from the end: max bright still.
			// very end: 0% bright.
			flashlightBrightnessFactor = (-flashlightRangeMax * (trace_fraction + -1)) / rangeDimPriorStart;
		}
		
		if(flashlightBrightnessFactor > 0){
			if (serverkeyfloat("*bspversion") == BSPVER_HL) {
				dynamiclight_add(trace_endpos + (v_forward * -2), 128 * flashlightBrightnessFactor, [1,1,1]);
			} else {
				float p = dynamiclight_add(posView, 512 * flashlightBrightnessFactor, [1,1,1], 0, "textures/flashlight");
				dynamiclight_set(p, LFIELD_ANGLES, angView);
				dynamiclight_set(p, LFIELD_FLAGS, 3);
			}
		}//END OF brightness check
		
		
	}//END OF "flashlight is on" criteria


	if(canRenderLaserSight || canRenderFlashlight){
		// TRY IT SOMEHOW?	RF_DEPTHHACK
		//pSeat->m_eViewModel.renderflags = RF_DEPTHHACK;
		//if (alpha <= 0.0f) {
		//	return;
		//}
		
		makevectors(angGun);
		
		//rotatevectorsbyangle( [-0.42, 0.75, 0] );
		//rotatevectorsbyangle( [-0.52, 0.85, 0] );
		rotatevectorsbyangle( [-0.45, 0.27, 0] );
		
		
		flashPos = gunpos + v_up * -0.08 + v_right * 0.06;
		
		
		vector shortForwardEnd = gunpos;
		shortForwardEnd += v_forward * -1;
		shortForwardEnd += v_up * (0.22);  //why is this 'up'??
		shortForwardEnd += v_right * (0.35);  //why is this 'up'??
		
		//makevectors(m_vecAngle);   really now
		//makevectors(input_angles);   //maybe this if we need to do this.
		
		// v_up * 2.  or.. 1.6, for size [3,3] at least.
		//   for size [5,5],   we need v_up*3, v_right*2.  I DONT KNOW.
		// for size [2, 2], we want v_up*5, v_right*5.  Go figure that one out.
		
		// Keep in mind, the global vectors (v_up, etc.) are set to the orientation of the recently received
		// viewmodel attachment (gettaginfo above). Don't 'makevectors' at all to simply rely on that.
		// ...unfortunately the orientation we get back is not great either.   oh well.
		
		// NEW TEST.  Can we even get a straight line from the player's center to the gunpos?
		
		traceline(posView, shortForwardEnd, FALSE, pl);
		if(trace_fraction >= 1.0){
			//woohoo!
			
			traceline(shortForwardEnd, shortForwardEnd + v_forward * 1024, MOVE_HITMODEL, pl);
			
			// other places care about this.
			if (pl.entnum == player_localentnum) {
				pl.recentLaserHitPos = trace_endpos;
			}
			
			if(canRenderLaserSight){ 
			
				// In original TS, the 'laster' does not render for the local player if they are
				// in thirdperson to see their own playermodel.  I... don't really understand that,
				// feels like a mistake.  The lasers from other players are visible.
				
				// TAGGG - TODO - SUPER LOW PRIORITY
				// Lasers only for not in 3rd person and local player.
				// Could work for the third-person model or other players if there were a way to determine
				// the muzzle-end point for player models.  Unsure if that is possible.
				// To see it in third-person anyway, just change the "!thirdperson" condition below
				// to "TRUE"; always do it.  There is no separate place that does only first-person lasers
				// to worry about being redundant with.
				// Note the laser will try to face the direction the player model is, which may not
				// necessarily be where the player is looking, although that same issue would come up
				// with firing anyway; you would look like you're firing sideways anyway, this would be
				// just as "off".
				if (!thirdperson) {
					//makevectors(view_angles);  //???   it seems we do not need this perhaps...
					// IN SHORT, we're riding the prior "makevectors(angGun);".
					R_BeginPolygon("sprites/laserbeam.spr_0.tga", 1, 0);
					R_PolygonVertex(gunpos + v_right * fsize[0] - v_up * fsize[1], [1,1], lasColor, drawAlpha);
					R_PolygonVertex(gunpos - v_right * fsize[0] - v_up * fsize[1], [0,1], lasColor, drawAlpha);
					R_PolygonVertex(trace_endpos - v_right * fsize[0] + v_up * fsize[1], [0,0], lasColor, drawAlpha);
					R_PolygonVertex(trace_endpos + v_right * fsize[0] + v_up * fsize[1], [1,0], lasColor, drawAlpha);
					R_EndPolygon();
				}
				
				// Draw the laser sprite effect at where the laser is hitting, but ONLY for every other player
				// except this one.  That's because, for the local player, we already are drawing the laserdot
				// projected onto the screen in the HUD logic.
				
				if (pl.entnum != player_localentnum) {
					makevectors(angView);
				
					trace_endpos += trace_plane_normal * fsizeDot[0]/6;
					R_BeginPolygon("sprites/laserdot.spr_0.tga", 1, 0);
					R_PolygonVertex(trace_endpos + v_right * fsizeDot[0] - v_up * fsizeDot[1], [1,1], lasColor, 0.80f);
					R_PolygonVertex(trace_endpos - v_right * fsizeDot[0] - v_up * fsizeDot[1], [0,1], lasColor, 0.80f);
					R_PolygonVertex(trace_endpos - v_right * fsizeDot[0] + v_up * fsizeDot[1], [0,0], lasColor, 0.80f);
					R_PolygonVertex(trace_endpos + v_right * fsizeDot[0] + v_up * fsizeDot[1], [1,0], lasColor, 0.80f);
					R_EndPolygon();
				}
				
			}//END OF canRenderLaserSight
			
			
			// glow effect on top of the gun muzzle while the flashlight is on?
			if(canRenderFlashlight){
				if(!thirdperson){
					makevectors(angView);
					
					//trace_endpos += trace_plane_normal * fsizeDot[0]/6;
					R_BeginPolygon("sprites/glow02.spr_0.tga", 1, 0);
					R_PolygonVertex(flashPos + v_right * fsizeFlashlightMuzzleGlow[0] - v_up * fsizeFlashlightMuzzleGlow[1], [1,1], [1,1,1], 0.45f);
					R_PolygonVertex(flashPos - v_right * fsizeFlashlightMuzzleGlow[0] - v_up * fsizeFlashlightMuzzleGlow[1], [0,1], [1,1,1], 0.45f);
					R_PolygonVertex(flashPos - v_right * fsizeFlashlightMuzzleGlow[0] + v_up * fsizeFlashlightMuzzleGlow[1], [0,0], [1,1,1], 0.45f);
					R_PolygonVertex(flashPos + v_right * fsizeFlashlightMuzzleGlow[0] + v_up * fsizeFlashlightMuzzleGlow[1], [1,0], [1,1,1], 0.45f);
					R_EndPolygon();
				}
			}
		}//END OF trace pre-check
		
		
		// This requires the current weapon to be akimbo, player is in first person,
		// and the local player is being rendered.
		if(canDrawAkimboLaser){
			// test for the 2nd gun's laser too then.
			// makevectors(theDir);
			makevectors(angGun2);
			rotatevectorsbyangle( [-0.45, 0.27, 0] );
			
			//gunpos2 += v_forward * -18;
			
			flashPos = gunpos2 + v_up * -0.08 + v_right * 0.06;
			
			shortForwardEnd = gunpos2;
			shortForwardEnd += v_forward * -1;
			shortForwardEnd += v_up * (0.22);  //why is this 'up'??
			shortForwardEnd += -v_right * (0.35);  //why is this 'up'??
			
			
			traceline(posView, shortForwardEnd, FALSE, pl);
			if(trace_fraction >= 1.0){
				
				traceline(shortForwardEnd, shortForwardEnd + v_forward * 1024, MOVE_HITMODEL, pl);
				
				// other places care about this.
				if (pl.entnum == player_localentnum) {
					pl.recentLaserHitPos2 = trace_endpos;
				}
				
				if(canRenderLaserSight){
					if (!thirdperson) {
						// ONLY render the polygon
						// makevectors(view_angles);  //???   it seems we do not need this perhaps...
						// IN SHORT, we're riding the prior "makevectors(angGun2);".
						
						R_BeginPolygon("sprites/laserbeam.spr_0.tga", 1, 0);
						R_PolygonVertex(gunpos2 + v_right * fsize[0] - v_up * fsize[1], [1,1], lasColor, drawAlpha);
						R_PolygonVertex(gunpos2 - v_right * fsize[0] - v_up * fsize[1], [0,1], lasColor, drawAlpha);
						R_PolygonVertex(trace_endpos - v_right * fsize[0] + v_up * fsize[1], [0,0], lasColor, drawAlpha);
						R_PolygonVertex(trace_endpos + v_right * fsize[0] + v_up * fsize[1], [1,0], lasColor, drawAlpha);
						R_EndPolygon();
					}
					
					if (pl.entnum != player_localentnum) {
						//makevectors(view_angles);
						makevectors(angView);
						
						trace_endpos += trace_plane_normal * fsizeDot[0]/6;
						R_BeginPolygon("sprites/laserdot.spr_0.tga", 1, 0);
						R_PolygonVertex(trace_endpos + v_right * fsizeDot[0] - v_up * fsizeDot[1], [1,1], lasColor, 0.80f);
						R_PolygonVertex(trace_endpos - v_right * fsizeDot[0] - v_up * fsizeDot[1], [0,1], lasColor, 0.80f);
						R_PolygonVertex(trace_endpos - v_right * fsizeDot[0] + v_up * fsizeDot[1], [0,0], lasColor, 0.80f);
						R_PolygonVertex(trace_endpos + v_right * fsizeDot[0] + v_up * fsizeDot[1], [1,0], lasColor, 0.80f);
						R_EndPolygon();
					}
				}
				
				
				if(canRenderFlashlight){
					if(!thirdperson){
						//makevectors(view_angles);
						makevectors(angView);
						
						//trace_endpos += trace_plane_normal * fsizeDot[0]/6;
						R_BeginPolygon("sprites/glow02.spr_0.tga", 1, 0);
						R_PolygonVertex(flashPos + v_right * fsizeFlashlightMuzzleGlow[0] - v_up * fsizeFlashlightMuzzleGlow[1], [1,1], [1,1,1], 0.45f);
						R_PolygonVertex(flashPos - v_right * fsizeFlashlightMuzzleGlow[0] - v_up * fsizeFlashlightMuzzleGlow[1], [0,1], [1,1,1], 0.45f);
						R_PolygonVertex(flashPos - v_right * fsizeFlashlightMuzzleGlow[0] + v_up * fsizeFlashlightMuzzleGlow[1], [0,0], [1,1,1], 0.45f);
						R_PolygonVertex(flashPos + v_right * fsizeFlashlightMuzzleGlow[0] + v_up * fsizeFlashlightMuzzleGlow[1], [1,0], [1,1,1], 0.45f);
						R_EndPolygon();
					}
				}
				
			}//END OF trace pre-check
		}//END OF akimbo check
		
		/*
		if (m_iBeams == 0) {
			alpha -= clframetime * 3;
			return;
		}
		*/
		
		
	}else{
		pl.recentLaserHitPosSet = FALSE;
	}//END OF canRenderLaserSight || canRenderFlashlight
	
}


//TAGGG - NEW.  Similar to Nuclide's provided "View_SetMuzzleflash", but also acts
// as though the first frame were an event by doing the same lines as a 5000-ish
// event.  This is because TS weapons don't have events for the muzzle flash
// unlike HL ones, must be hardcoded to show up.
// Figuring out what muzzle flash for what weapon will come another time.
// For now using the same HL set, but TS comes with some muzzle-flash looking sprites.
// ALSO - for now, always assuming attachment #0.
// For the model event in case that changes, see Nuclide's src/client/modelevent.qc,
// Event_ProcessModel.
void
TS_View_ShowMuzzleflash(int index, int akimboChoice)
{
	// use the akimbo choice to tell which one to show, or both
	// (NONE means this is a singular weapon)
	if(akimboChoice == BITS_AKIMBOCHOICE_NONE || (akimboChoice & BITS_AKIMBOCHOICE_RIGHT)){
		pSeat->m_eMuzzleflash.modelindex = (float)index;
		// Event_ProcessModel: force it.
		pSeat->m_eMuzzleflash.alpha = 1.0f;
		pSeat->m_eMuzzleflash.scale = 0.25;
		// attachment #0 is m_iVMBones + 0.  Add for #1 to #3, I think.
		// No idea if any weapons play with attachments, #0 should always
		// be the end of the weapon for flashes
		pSeat->m_eMuzzleflash.skin = pSeat->m_iVMBones + 0;
	}
	if(akimboChoice & BITS_AKIMBOCHOICE_LEFT){
		pSeatLocal->m_eMuzzleflashAkimbo.modelindex = (float)index;
		// Event_ProcessModel: force it.
		pSeatLocal->m_eMuzzleflashAkimbo.alpha = 1.0f;
		pSeatLocal->m_eMuzzleflashAkimbo.scale = 0.25;
		// akimbo attachments are in pairs: 
		// 0 on one weapon, 1 further out along that weapon's direction,
		// 2 on the other weapon, 3 further along the other weapon's direction.
		// ALSO: on akimbo weapons, attachments 0 and 1 are for the right weapon,
		// 1 and 2 for the left.
		pSeatLocal->m_eMuzzleflashAkimbo.skin = pSeat->m_iVMBones + 2;
	}
}



//var int oldZoomLevel = 0;

//TAGGG - loaned from The Wastes.
void TS_View_HandleZoom(void)
{
	player pl = (player)pSeat->m_ePlayer;
	
	if(pl == NULL){
		return;
	}
	
	// test
	/*
	pl.flZoomCurrent = pl.flZoomTarget;
	pl.viewzoom = pl.flZoomTarget;
	printfline("flZoomTarget: %.2f", pl.flZoomTarget);
	return;
	*/
	
	//printfline("WHATS GOING ON %.2f %.2f %.2f %.2f %.2f", pl.flZoomEnd, pl.flZoomTarget, pl.flZoomStart, pl.flZoomLerp, pl.flZoomCurrent);
	
	//TAGGG - no other codebase refers to STAT_VIEWZOOM, best to replace anything
	// involving that.
	
	// in case of some unexpected change.
	// TODO: this might have an issue if the player were to change weapons and end up
	// on the same zoom level as a previous weapon, despite the two weapons having
	// different target values (like 0.4 vs. 0.6) at their own zoom level #1's.
	// A check for being a different equipped weapon type
	// (pl.activeweapon vs. pl.activeweapon_zoomprev, set only by setZoomLevel)
	// ought to work.  But that would be a very strange case anyway
	if(pl.iZoomLevel != pl.iZoomLevelPrev){
		pl.setZoomLevel(pl.iZoomLevel);
	}
		
	if (pl.flZoomEnd != pl.flZoomTarget ) {
		//printfline("NEW ZOOM DETECTED: %.2f -> %.2f (zoomlev: %i)", pl.flZoomEnd, pl.flZoomTarget, pl.iZoomLevel);
		
		// is setting flZoomStart to flZoomEnd or flZoomCurrent a better idea?
		// at flZoomEnd means, on changing before the current lerp has finished, it jumps to beginning
		// at the end point of the lerp in progress.  But starting at flZoomCurrent might be smoother?
		// if it isn't glitchy that could be nice.  Trying that out.
		
		pl.flZoomStart = pl.flZoomCurrent;
		//pl.flZoomStart = pl.flZoomEnd;
		
		pl.flZoomEnd = pl.flZoomTarget;
		pl.flZoomLerp = 0.0f;
	}

	if (pl.flZoomLerp < 1.0f) {
		// Slow this down for debugging purposes, this is meant to be fast.
		// 0.8 can be safe.
		// The Wastes default was 4.
		
		// !!! clframetime, frametime, or input_timelength ?
		pl.flZoomLerp += clframetime * 5.7;
		
		if(pl.flZoomLerp >= 1.0){
			//enforce the cap.
			pl.flZoomLerp = 1.0;
		}
		
		//pl.flZoomCurrent = getstatf(STAT_VIEWZOOM);
		pl.flZoomCurrent = Math_Lerp(pl.flZoomStart, pl.flZoomEnd, pl.flZoomLerp);
	}
	
	// Set this, since Nuclide will read it in and apply instantly.
	// So same effect without having to edit Nuclide, this pipes it over for it
	// to do the setproperty thing below to apply
	//pl.viewzoom = pl.flZoomCurrent;

	////setproperty(VF_AFOV, DEFAULT_FOV * pl.flZoomCurrent);
	////setsensitivityscaler(pl.flZoomCurrent);
	
	// here's the way old FreeCS did it
	//setproperty(VF_AFOV, cvar("fov") * pl.viewzoom);
	//setsensitivityscaler(pl.viewzoom);
}


