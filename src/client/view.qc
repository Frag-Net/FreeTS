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
View_ShowMuzzleflash(int index)
{
	pSeat->m_eMuzzleflash.modelindex = (float)index;
	// Event_ProcessModel: force it.
	pSeat->m_eMuzzleflash.alpha = 1.0f;
	pSeat->m_eMuzzleflash.scale = 0.25;
	// attachment #0 is m_iVMBones + 0.  Add for #1 to #3, I think.
	// No idea if any weapons play with attachments, #0 should always
	// be the end of the weapon for flashes
	pSeat->m_eMuzzleflash.skin = pSeat->m_iVMBones + 0;
}

void
View_ShowMuzzleflashAkimbo(int index)
{
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



void
TS_View_SetViewModelFromStats(void)
{
	player pl = (player)pSeat->m_ePlayer;
	entity vm = pSeat->m_eViewModel;
	entity mflash = pSeat->m_eMuzzleflash;
	entity mflashAkimbo = pSeatLocal->m_eMuzzleflashAkimbo;
	weapondata_basic_t* basicP;
	weapondynamic_t dynaRef;
	
	printfline("TS_View_SetViewModelFromStats:  I happen? activeweap:%d", pl.activeweapon);
	
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
	SAVE_STATE(pl.flZoomTarget);

	//TAGGG - also new line.  It is a good idea to reset the event
	// on changing models, right?
	pSeat->m_pEventCall = NULL;
	
	skel_delete( mflash.skeletonindex );
	mflash.skeletonindex = skel_create( vm.modelindex );
	pSeat->m_iVMBones = skel_get_numbones( mflash.skeletonindex ) + 1;
	
	// assuming cloning above for the akimbo muzzleflash is a good idea
	skel_delete(mflashAkimbo.skeletonindex);
	// TODO: could we just reuse the mflash.skeletonindex here?  I don't know
	mflashAkimbo.skeletonindex = skel_create(vm.modelindex);
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
	skel_delete(mflashAkimbo.skeletonindex);
	mflashAkimbo.skeletonindex = 0;
	
	
	/*
	player pl = (player) pSeat->m_ePlayer;
	pl.setInventoryEquippedIndex(-1);  //do we have to?
	*/
	
}// TS_View_ResetViewModel



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
	
	//TAGGG - any references to STAT_VIEWZOOM are now garbage.
	// Rely on pl.flZoomTarget instead, it's sent to the client every frame
	// and should be handled serverside anyway.
	// flZoomEnd is actually the "target" zoom we want to reach.
	// flZoomStart is the zoom we started at, at the time of the change.
	// flZoomLerp is how far along we are from oldZoom to currentZoom.
	// flZoomCurrent is the actual zoom we are at this very moment.
	
	if (pl.flZoomEnd != pl.flZoomTarget ) {
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
	pl.viewzoom = pl.flZoomCurrent;

	////setproperty(VF_AFOV, DEFAULT_FOV * pl.flZoomCurrent);
	////setsensitivityscaler(pl.flZoomCurrent);
	
	// here's the way old FreeCS did it
	//setproperty(VF_AFOV, cvar("fov") * pl.viewzoom);
	//setsensitivityscaler(pl.viewzoom);
}


