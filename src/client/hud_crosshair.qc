/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
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


//it's ok for this to go here, right?
CREATE_imageFileRef_t(img_player_stuntmeter1, "sprites/player/divestept.spr", 40, 80)
CREATE_imageFileRef_t(img_player_stuntmeter2, "sprites/player/divestepc.spr", 40, 80)
CREATE_imageFileRef_t(img_player_stuntmeter3, "sprites/player/divestepb.spr", 40, 80)

CREATE_imageFileRef_raw_t(img_quadgraphic, "textures/cross2.tga", 64, 64)

/*
=================
HUD_DrawCrosshair

Draws the cursor every frame, unless spectator
=================
*/


void HUD_DrawCrosshair(void) {	
	
	player pl = (player)pSeat->m_ePlayer;
	
	weapondynamic_t dynaRef;
	weapondata_gun_t* gunPointer;
	weapondata_gun_t gunRef;
	
	vector vCenter = video_mins + [video_res[0]/2, video_res[1]/2];
	
	// only TRUE for guns, melee stuff doesn't get this.
	BOOL hasWeaponCrosshair = FALSE;
	// only TRUE if the gun has  lasersight, of course.
	BOOL hasLasersight = FALSE;
	int drawLaserDots = 0;
	
	BOOL trackLaserDots = FALSE;  //only applicable with lasersight on of course.
	
	if(pl.inventoryEquippedIndex != -1){
		//get that weapon.
		dynaRef = pl.ary_myWeapons[pl.inventoryEquippedIndex];
		
		if(dynaRef.weaponTypeID == WEAPONDATA_TYPEID_GUN || dynaRef.weaponTypeID == WEAPONDATA_TYPEID_IRONSIGHT){
			gunPointer = (weapondata_gun_t*) pl.getEquippedWeaponData();
			gunRef = *(gunPointer);
			// We probably have a "drawCrosshair" variable in our weapon struct.
			// probaly not even necessary really, since we could infer that property fine anyway from the
			// weaponTypeID.
			// One more check... we can explicitly forbid drawing the crosshair ever for a weapon too.
			// Example is the barrett sniper rifle, even hip-fire has no crosshair like other weapons.
			if(gunRef.fDrawCrosshair){
				hasWeaponCrosshair = TRUE;
			}
			
			//we could very well need the lasersight drawn without the crosshair
			// (example: barrett sniper rifle)
			int iBitsUpgradeSafe_on = dynaRef.iBitsUpgrade_on & (dynaRef.iBitsUpgrade & gunRef.iBitsUpgrade);
			
			//do we have a lasersight though?
			if(iBitsUpgradeSafe_on & BITS_WEAPONOPT_LASERSIGHT){
				// why yes, we got it
				hasLasersight = TRUE;
				
				int reloadSeq = -1;
				//what is my reload sequence?
				if(dynaRef.weaponTypeID == WEAPONDATA_TYPEID_IRONSIGHT){
					//it's from the 
					weapondata_ironsight_t* ironsightPointer = (weapondata_ironsight_t*)gunPointer;
					weapondata_ironsight_t ironsightRef = (*ironsightPointer);
					if(!dynaRef.iIronSight){
						reloadSeq = ironsightRef.iAnim_Reload_Index;
					}else{
						reloadSeq = ironsightRef.ironsightdata.iAnim_Reload_Index;
					}
				}else{
					reloadSeq = gunRef.iAnim_Reload_Index;
				}
				
				if(!pl.weaponEquippedAkimbo){
					drawLaserDots = 1;
				}else{
					drawLaserDots = 2;
				}
				
				// Is this a condition that forbids drawing the laser dot on the screen?
				if(
				  /*
				  !pl.isReloading &&
				  !(
				    pSeat->m_eViewModel.frame == gunRef.iAnim_Deploy_Index &&
				    pl.w_attack_next > 0
				   ) &&
				  !pl.lasersightUnlockTime
				  */
				  
				  !(pl.isReloading || (pl.lasersightUnlockTime && pl.w_idle_next <= 0))
				  
				){
					trackLaserDots = FALSE;  // force them to the center on the screen.
				}else{
					// Track their positions on the ingame world. Weird, I know.
					trackLaserDots = TRUE;
				}
			}//END OF lasersight check
			
			
		}
	}//END OF inventoryEquippedIndex check
	
	
	// Draw some things unconditionally.
	// (we only even reached this point if not zoomed through a scope with the overlay of course)
	/*
	 0 - 21 slots: all thirds clear.
	22 - 41 slots: top third orange.
	42 - 71 slots: top, middle thirds orange.
	72 - 81 slots: all thirds orange.
	*/

	int thirdBelongingTo = 0;
	
	float ratioNumber = getViewPitchRelativeRatio(pl.pitch);
	float newDegreeRad = (ratioNumber * (270 - 90) + 90) * (M_PI/180);
	
	//printfline("MY ANGLE? %.2f", (ratioNumber * (270 - 90) + 90) );
	
	//check for the degree, set thirdBelongingTo...
	if(ratioNumber <= 0.3333){
		thirdBelongingTo = 0;
	}else if(ratioNumber <= 0.6667){
		thirdBelongingTo = 1;
	}else{ // <= 1.0
		thirdBelongingTo = 2;
	}
	
	// we COULD make this a property (ts/main.c) to be set by the client and read by the server,
	// but this might be really inefficient.  May as well use the v_angle already available serverside to determine
	// what third we're looking at.
	
	// top = 90 degrees for safePlayerViewPitch of -31.
	// bottom = 270 degrees for safePlayerViewPitch of 30.
	
	//Max upwards: -31
	//mid: 0
	//Max downwards: 30
	
	//check for belingong to each of the thirds for which to light up, if applicable.  Above that is.
	
	float modder;
	vector clrColor;
	
	modder = 0.56f;
	if(pl.iTotalSlots <= 21){clrColor = clrPaleBlue;if(thirdBelongingTo==0){modder = 1.0f;}}else{clrColor = clrFailedSlotbarColor;}
	DRAW_IMAGE_ADDITIVE(img_player_stuntmeter1, ([vCenter[0] - 40, vCenter[1] - 40]), clrColor, modder)
	
	modder = 0.56f;
	if(pl.iTotalSlots <= 41){clrColor = clrPaleBlue;if(thirdBelongingTo==1){modder = 1.0f;}}else{clrColor = clrFailedSlotbarColor;}
	DRAW_IMAGE_ADDITIVE(img_player_stuntmeter2, ([vCenter[0] - 40, vCenter[1] - 40]), clrColor, modder)
	
	modder = 0.56f;
	if(pl.iTotalSlots <= 71){clrColor = clrPaleBlue;if(thirdBelongingTo==2){modder = 1.0f;}}else{clrColor = clrFailedSlotbarColor;}
	DRAW_IMAGE_ADDITIVE(img_player_stuntmeter3, ([vCenter[0] - 40, vCenter[1] - 40]), clrColor, modder)
	
	vector resultArcPoint = vCenter + [cos(newDegreeRad), -sin(newDegreeRad)] * 32;
	drawfill( resultArcPoint, [2, 2], clrPaleBlue, 0.7f, DRAWFLAG_NORMAL );
	
	
	if(hasWeaponCrosshair){
		
		int startCrosshairDist;
		int maxCrosshairDelta;   //how much the crosshair can move outwards at most.  0 is no change!
		int crosshairDist;
		
		if(!hasLasersight){
			startCrosshairDist = 22;
			maxCrosshairDelta = 15;
		}else{
			startCrosshairDist = 12;
			maxCrosshairDelta = 14;
		}
		//can expand up to +14 beyond.
		
		
		float facto = (bound(0, pl.fAccuracyKickback, 0.1) ) / 0.1;
		
		//scale it.
		crosshairDist = startCrosshairDist + facto * maxCrosshairDelta;
		
		//printfline("pl.fAccuracyKickback:%.4f", pl.fAccuracyKickback);
		
		clrColor = [0/255.0f, 0/255.0f, 0/255.0f];
		DRAW_IMAGE_NORMAL(img_quadgraphic, ([vCenter[0] - 32, vCenter[1] - 32]), clrColor, 1.00f)
		
		
		// * 0.86 ???
		drawfill( [vCenter[0] - crosshairDist, vCenter[1] - 1], [5, 2], clrPaleBlue, 0.70f, DRAWFLAG_NORMAL );
		drawfill( [vCenter[0] + (crosshairDist - 5), vCenter[1] - 1], [5, 2], clrPaleBlue, 0.70f, DRAWFLAG_NORMAL );

		drawfill( [vCenter[0] - 1, vCenter[1] - crosshairDist], [2, 5], clrPaleBlue, 0.7f, DRAWFLAG_NORMAL );
		drawfill( [vCenter[0] - 1, vCenter[1] + (crosshairDist - 5)], [2, 5], clrPaleBlue, 0.70f, DRAWFLAG_NORMAL );
		
		
	}//END OF ranged weapon check
	
	
	if(hasLasersight){
		
		
		if(!trackLaserDots){
			// draw it straight at the HUD center.
			// TODO - add a very slight, slow random offset from the given point.
			// Why?  BECAUSE KHORNE MUST BE PLEASED.
			// ...I mean, because original TS did it.	okay.
			vector lasDot;
			
			if(drawLaserDots == 1){
				// dot in the center and the range number fresh from the server, probably.
				// -1. 5. 2.
				lasDot = vCenter + [-1, -1];
				drawfill( lasDot, [2, 2], clrLaserHUDDot, 0.83f, DRAWFLAG_NORMAL );
			}else if(drawLaserDots == 2){
				lasDot = vCenter + [-1 + -4, -1];
				drawfill( lasDot, [2, 2], clrLaserHUDDot, 0.83f, DRAWFLAG_NORMAL );
				
				lasDot = vCenter + [-1 + 4, -1];
				drawfill( lasDot, [2, 2], clrLaserHUDDot, 0.83f, DRAWFLAG_NORMAL );
			}
		}else{
			if(pl.recentLaserHitPosSet){
				
				if(drawLaserDots == 1){
					// dot in the center and the range number fresh from the server, probably.
					// -1. 5. 2.
					
					//trust "recentLaserHit" then!
					lasDot = project(pl.recentLaserHitPos);
					drawfill( lasDot, [2, 2], clrLaserHUDDot, 0.83f, DRAWFLAG_NORMAL );
				}else if(drawLaserDots == 2){
					lasDot = project(pl.recentLaserHitPos);
					drawfill( lasDot, [2, 2], clrLaserHUDDot, 0.83f, DRAWFLAG_NORMAL );
					
					lasDot = project(pl.recentLaserHitPos2);
					drawfill( lasDot, [2, 2], clrLaserHUDDot, 0.83f, DRAWFLAG_NORMAL );
				}
				
			}
		}
		
		if(drawLaserDots != 0){
			if(hasWeaponCrosshair){
				if(pl.recentLaserHitPosSet){
					vector vDistNumberLoc = vCenter + [28, -8];
					drawSpriteNumber(ary_LCD_numberSet, vDistNumberLoc.x, vDistNumberLoc.y, pl.recentLaserDistanceDisplay, 3, BITS_DIGITOPT_NONE, clrPaleBlue, 0.91f);
				}
			}
		}//END OF flat drawLaserDots check
	
	}//END OF lasersight check
	
	
}//END OF HUD_DrawCrosshair
