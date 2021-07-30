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



// Also, Nuclide offers Weapons_SetGeomset for calling "setcustomskin" too, but one string
// at a time.  Don't really know if that way or the current way (cumulative string for
// many commands delimited in one setcustomskin call) is any better, so leaving this as
// it is for now.



// NEW
void TS_SetViewModelFromStats(){
	
	player pl = (player)pSeat->m_ePlayer;
	entity vm = pSeat->m_eViewModel;
	entity mflash = pSeat->m_eMuzzleflash;
	weapondata_basic_t* basicP;
	weapondynamic_t dynaRef;
	
	printfline("TS_SetViewModelFromStats:  I happen? activeweap:%d", pl.activeweapon);
	
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
	
	if(dynaRef.forceBodygroup1Submodel > 0){
		cumulativeCommandString = sprintf("%sgeomset 0 %i\n", cumulativeCommandString, dynaRef.forceBodygroup1Submodel );
	}
	// no need to do that geomset with the same value again.
	pl.prev_forceBodygroup1Submodel = dynaRef.forceBodygroup1Submodel;
	
	setcustomskin(vm, "", cumulativeCommandString);
	
	
	// leftovers following a draw call, that likely lead here to begin with.
	SAVE_STATE(pl.w_attack_next);
	SAVE_STATE(pl.w_idle_next);
	SAVE_STATE(pl.viewzoom);
	SAVE_STATE(pl.weapontime);

	skel_delete( mflash.skeletonindex );
	mflash.skeletonindex = skel_create( vm.modelindex );
	pSeat->m_iVMBones = skel_get_numbones( mflash.skeletonindex ) + 1;
	
	// Don't let View_UpdateWeapon do this all over.
	pSeat->m_iLastWeapon = pl.activeweapon;


}//TS_SetViewModelFromStats


// On any frame, see if something about the current viewmodel needs to be changed
void View_RoutineCheck(void){
	
	
	player pl = (player)pSeat->m_ePlayer;
	entity vm = pSeat->m_eViewModel;
	weapondynamic_t dynaRef;
	
	// That can happen, apparently.
	if(pl.inventoryEquippedIndex == -1){
		return;
	}
	
	dynaRef = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	
	if(pl.prev_forceBodygroup1Submodel != dynaRef.forceBodygroup1Submodel){
		
		if(dynaRef.forceBodygroup1Submodel > 0){
			string commandString;
			commandString = sprintf("geomset 0 %i\n", dynaRef.forceBodygroup1Submodel );
			setcustomskin(vm, "", commandString);
		}
		pl.prev_forceBodygroup1Submodel = dynaRef.forceBodygroup1Submodel;
	}
	
	
	
}//View_RoutineCheck



// vm is pSeat->m_eViewModel passed along from Nuclide's View_DrawViewModel
void
View_UpdateWeapon(entity vm, entity mflash)
{
	player pl = (player)pSeat->m_ePlayer;

	/* only bother upon change */
	if (pSeat->m_iLastWeapon == pl.activeweapon) {
		
		View_RoutineCheck();
		return;
	}
	printfline("View_UpdateWeapon: change detected: %i -> %d", pSeat->m_iLastWeapon, pl.activeweapon);
	
	pSeat->m_iOldWeapon = pSeat->m_iLastWeapon;
	pSeat->m_iLastWeapon = pl.activeweapon;

	if (!pl.activeweapon /*|| pl.inventoryEquippedIndex < 0*/) {
		// can't work with this!
		resetViewModel();
		return;
	}

	
	//printfline("View_UpdateWeapon: change: %d vs %d", pSeat->m_iLastWeapon, pl.activeweapon);
	
	// Call this to do a few other things for any weapon change
	TS_Weapon_Draw_extra();
	
	/* hack, we changed the wep, move this into Game_Input/PMove */
	Weapons_Draw();
	
	//No longer a var!  Oops
	//pSeat->m_iVMEjectBone = pSeat->m_iVMBones + 1;
			
	/* we forced a weapon call outside the prediction,
	 * thus we need to update all the net variables to
	 * make sure these updates are recognized. this is
	 * vile but it'll have to do for now */
	
	SAVE_STATE(pl.w_attack_next);
	SAVE_STATE(pl.w_idle_next);
	SAVE_STATE(pl.viewzoom);
	SAVE_STATE(pl.weapontime);
	//TAGGG - NEW VAR.
	SAVE_STATE(pl.w_attack_akimbo_next);
	
	skel_delete( mflash.skeletonindex );
	mflash.skeletonindex = skel_create( vm.modelindex );
	pSeat->m_iVMBones = skel_get_numbones( mflash.skeletonindex ) + 1;
	
	
		
}





//TAGGG - NEW METHODS
void
resetViewModel(void)
{
	
	//TAGGG - CRITICAL. NOT ANYMORE!!!
	//return;
	
	
	printfline("resetViewModel called.");
	
	if(pSeat->m_ePlayer == NULL){
		printfline("resetViewModel: early end #1, client ent NULL");
		return;
	}
	if(pSeat->m_ePlayer.classname != "player"){
		printfline("resetViewModel: early end #2, client ent not player");
		return;
	}
	
	
	//was m_eViewModel and m_eMuzzleflash
	entity vm = pSeat->m_eViewModel;
	entity mflash = pSeat->m_eMuzzleflash;

	setmodel( vm, "" );
	skel_delete( mflash.skeletonindex );
	mflash.skeletonindex = 0;  //er wat. would -1 be better or not?
	pSeat->m_iVMBones = 0 + 1;
	//pSeat->m_iVMEjectBone = pSeat->m_iVMBones + 1;
	
	/*
	player pl = (player) pSeat->m_ePlayer;
	pl.setInventoryEquippedIndex(-1);  //do we have to?
	*/
	
}//END OF resetViewModel



//TAGGG - loaned from The Wastes.
void View_HandleZoom(void){
	player pl = (player)pSeat->m_ePlayer;
	
	if(pl == NULL){
		return;
	}
	
	/*
	if(getplayerkeyvalue(player_localnum, "*spec") != "0"){
		
		//TAGGG - CRITICAL.
		// WAIT!  This is a spectator, so...?  can we even trust pSeat->ePlayer to be a player?
		// Confusing.
		// That leads me to believe that either zoom-related vars should be
		// pSeat-><clienttdata> - specific, or not handled here at all.
		
		// If our FOV was anything but 1, force it so.
		// Spectator mode instantly forgets any scope-related FOV mods.
		// Nuclide might not be calling setsensitivityscaler, so doing it here.
		// No problem if the setproperty is a little redundant as that might be happening.
		if(pl.flZoomLevel < 1.0 || pl.viewzoom < 1.0){
			pl.flZoomLerp = 0;
			pl.flZoomLevel = 1;
			pl.viewzoom = 1;
			setproperty(VF_AFOV, cvar("fov") * pl.flZoomLevel);
			setsensitivityscaler(pl.flZoomLevel);
		}
		// No further zoom logic
		
		return;
	}
		*/
	
	
	//TAGGG - any references to STAT_VIEWZOOM are now garbage.
	// Rely on pl.flTargetZoom instead, it's sent to the client every frame
	// and should be handled serverside anyway.
	// flCurrentZoom is actually the "target" zoom we want to reach.
	// flOldZoom is the zoom we started at, at the time of the change.
	// flZoomLerp is how far along we are from oldZoom to currentZoom.
	// flZoomLevel is the actual zoom we are at this very moment.
	
	if (pl.flCurrentZoom != pl.flTargetZoom ) {
		pl.flOldZoom = pl.flCurrentZoom;
		pl.flCurrentZoom = pl.flTargetZoom ;
		pl.flZoomLerp = 0.0f;
	}

	if (pl.flZoomLerp < 1.0f) {
		// Slow this down for debugging purposes, this is meant to be fast.
		// 0.8 can be safe.
		// The Wastes default was 4.
		
		pl.flZoomLerp += clframetime * 8;
		
		if(pl.flZoomLerp >= 1.0){
			//enforce the cap.
			pl.flZoomLerp = 1.0;
		}
		
		//pl.flZoomLevel = getstatf(STAT_VIEWZOOM);
		pl.flZoomLevel = Math_Lerp(pl.flOldZoom, pl.flCurrentZoom, pl.flZoomLerp);
	}
	
	// Set this, since Nuclide will read it in and apply instantly.
	// So same effect without having to edit Nuclide, this pipes it over for it
	// to do the setproperty thing below to apply
	pl.viewzoom = pl.flZoomLevel;

	////setproperty(VF_AFOV, DEFAULT_FOV * pl.flZoomLevel);
	////setsensitivityscaler(pl.flZoomLevel);
	
	// here's the way old FreeCS did it
	//setproperty(VF_AFOV, cvar("fov") * pl.viewzoom);
	//setsensitivityscaler(pl.viewzoom);
}


vector
View_ShakeCalculate(vector vecInputAngles)
{
	player pl = (player)pSeat->m_ePlayer;
	if(pl == NULL)return vecInputAngles; //forget this
	
	// you might not want to force this every frame unless you like vomiting.
	//pl.flViewShake = 2;
	
	if (pl.flViewShake > 0.0f) {
		vecInputAngles[0] += (random() * pl.flViewShake) * 3;
		vecInputAngles[1] += (random() * pl.flViewShake) * 3;
		vecInputAngles[2] += (random() * pl.flViewShake) * 3;
		pl.flViewShake -= clframetime;
	}

	return vecInputAngles;
}



void
View_ShakeCreate(int iLevel)
{
	player pl = (player)pSeat->m_ePlayer;
	pl.flViewShake = iLevel / 128;
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
	// View_SetMuzzleflash
	pSeat->m_eMuzzleflash.modelindex = (float)index;
	
	// Event_ProcessModel: force it.
	pSeat->m_eMuzzleflash.alpha = 1.0f;
	pSeat->m_eMuzzleflash.scale = 0.25;
	// attachment #0 is m_iVMBones + 0.  Add for #1 to #3, I think.
	// No idea if any weapons play with attachments, #0 should always
	// be the end of the weapon for flashes
	pSeat->m_eMuzzleflash.skin = pSeat->m_iVMBones + 0;
}




