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

string g_pbones[] =
{
 "Bip01",
 "Bip01 Footsteps",
 "Bip01 Pelvis",
 "Bip01 L Leg",
 "Bip01 L Leg1",
 "Bip01 L Foot",
 "Bip01 L Toe0",
 "Bip01 L Toe01",
 "Bip01 L Toe02",
 "Dummy16",
 "Bip01 R Leg",
 "Bip01 R Leg1",
"Bip01 R Foot",
 "Bip01 R Toe0",
 "Bip01 R Toe01",
 "Bip01 R Toe02",
 "Dummy11",
 "Bip01 Spine",
 "Bip01 Spine1",
 "Bip01 Spine2",
 "Bip01 Spine3",
 "Bip01 Neck",
 "Bip01 Head",
 "Dummy21",
 "Dummy08",
 "Bone02",
 "Bone03",
 "Bone04",
 "Dummy05",
 "Bone09",
 "Bone10",
 "Dummy04",
 "Bone05",
 "Bone06",
 "Dummy03",
 "Bone07",
 "Bone08",
 "Dummy09",
 "Bone11",
 "Bone12",
"Dummy10",
 "Bone13",
 "Bone14",
 "Bone15",
 "Bip01 L Arm",
 "Bip01 L Arm1",
 "Bip01 L Arm2",
 "Bip01 L Hand",
 "Bip01 L Finger0",
 "Bip01 L Finger01",
 "Bip01 L Finger02",
 "Dummy06",
 "Bip01 L Finger1",
 "Bip01 L Finger11",
 "Bip01 L Finger12",
 "Dummy07",
 "Bip01 R Arm",
 "Bip01 R Arm1",
 "Bip01 R Arm2",
 "Bip01 R Hand",
 "Bip01 R Finger0",
 "Bip01 R Finger01",
 "Bip01 R Finger02",
 "Dummy01",
 "Bip01 R Finger1",
 "Bip01 R Finger11",
 "Bip01 R Finger12",
 "Dummy02",
 "Box02",
 "Bone08",
 "Bone15"
};

void
Player_HandleWeaponModel(base_player pp, float thirdperson)
{
	player pl = (player)pp;

	/* if we don't exist, create us */
	if (!pl.p_model) {
		pl.p_model = spawn();
	}

	/* only make it visible when it's a thirdperson drawcall */
	pl.p_model.drawmask = (thirdperson) ? MASK_ENGINE:0;

	/* let's not waste any time doing bone calculations then */
	if (pl.p_model.drawmask == 0)
		return;

	/* what's the current weapon model supposed to be anyway? */
	string wmodel = Weapons_GetPlayermodel(pl.activeweapon);

	/* we changed weapons, update skeletonindex */
	if (pl.p_model.model != wmodel) {
		/* free memory */
		if (pl.p_model.skeletonindex)
			skel_delete(pl.p_model.skeletonindex);

		/* set the new model and mark us updated */
		setmodel(pl.p_model, wmodel);
		pl.p_model.model = wmodel;
		
		/* set the new skeletonindex */
		pl.p_model.skeletonindex = skel_create(pl.p_model.modelindex);


		//TAGGG - change.  Pretty sure TS has nothing like hi models
		// hack this thing in here FIXME: this should be done when popping in/out of a pvs
		//if (autocvar(cl_himodels, 1, "Use high-quality player models over lower-definition ones"))
		//	setcustomskin(self, "", "geomset 0 2\n");
		//else
		//	setcustomskin(self, "", "geomset 0 1\n");
	}

	/* follow player at all times */
	setorigin(pl.p_model, pl.origin);
	pl.p_model.angles = pl.angles;
	skel_build(pl.p_model.skeletonindex, pl.p_model, pl.p_model.modelindex,0, 0, -1);

	/* we have to loop through all valid bones of the weapon model and match them
	 * to the player one */
	for (float i = 0; i < g_pbones.length; i++) {
		vector bpos;
		float pbone = gettagindex(pl, g_pbones[i]);
		float wbone = gettagindex(pl.p_model, g_pbones[i]);

		/* if the bone doesn't ignore in either skeletal mesh, ignore */
		if (wbone <= 0 || pbone <= 0)
			continue;

		bpos = gettaginfo(pl, pbone);
		
		/* the most expensive bit */
		skel_set_bone_world(pl.p_model, wbone, bpos, v_forward, v_right, v_up);
	}	
}

/* we need to call this when a player entity gets removed */
void
Player_DestroyWeaponModel(entity pp)
{
	player pl = (player)pp;
	if (pl.p_model)
		remove(pl.p_model);
}




//TAGGG - NOTE!  In case it ever matters, parameter "base_player pl" renamed to "base_player pp".
// Doubt it ever should, no idea if FTE would complain about a discrepency between prototype and
// implementation parameter names if that ever happened.
void
Player_PreDraw(base_player pp, int thirdperson)
{
	player pl = (player)pp;
	// OLD WAY.  Now called from draw.c's Custom_LatePreDraw to avoid a one-frame-lag issue
	// on lasersight/flashlight effects
	//Player_DrawViewmodelExtraEffects(pl, thirdperson);
	
	pl.Physics_SetViewParms();
	Animation_PlayerUpdate((player)pl);
	Animation_TimerUpdate((player)pl, clframetime);
	Player_HandleWeaponModel(pl, thirdperson);
}



// NEW, helper method, not called by Nuclide
// Does the same Nuclide script to draw the normal viewmodel at viewzooms between 0.5
// and 1.0, Nuclide skips drawing it on any zoom below 1.0 unlike original TS.
// Also, handles drawing the akimbo muzzle flash.
void
Player_DrawViewModelCustom(player pl){
	
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
	
}

// another helper method
// Draw the lasersight, and flashlight effects
void
Player_DrawViewModelExtraEffects(player pl, int thirdperson)
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
	
	float daDrawAlphahz = 1.0;
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
					R_PolygonVertex(gunpos + v_right * fsize[0] - v_up * fsize[1], [1,1], lasColor, daDrawAlphahz);
					R_PolygonVertex(gunpos - v_right * fsize[0] - v_up * fsize[1], [0,1], lasColor, daDrawAlphahz);
					R_PolygonVertex(trace_endpos - v_right * fsize[0] + v_up * fsize[1], [0,0], lasColor, daDrawAlphahz);
					R_PolygonVertex(trace_endpos + v_right * fsize[0] + v_up * fsize[1], [1,0], lasColor, daDrawAlphahz);
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
						R_PolygonVertex(gunpos2 + v_right * fsize[0] - v_up * fsize[1], [1,1], lasColor, daDrawAlphahz);
						R_PolygonVertex(gunpos2 - v_right * fsize[0] - v_up * fsize[1], [0,1], lasColor, daDrawAlphahz);
						R_PolygonVertex(trace_endpos - v_right * fsize[0] + v_up * fsize[1], [0,0], lasColor, daDrawAlphahz);
						R_PolygonVertex(trace_endpos + v_right * fsize[0] + v_up * fsize[1], [1,0], lasColor, daDrawAlphahz);
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






