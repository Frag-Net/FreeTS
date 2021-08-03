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
 
// FILE COPIED FROM FREEHL.
// Not ideal, but better than needing hack-ins to Nuclide files for now.

var float autocvar_v_bob = 0.01;
var float autocvar_v_bobcycle = 0.8;
var float autocvar_v_bobup = 0.5;

//TAGGG - BobNEW. ViewBob struct array/var moved to seatlocal.h for better
// visibility. Remove from there on using the Valve file instead.


//TAGGG - helper method.
void setVCam(void){
	pViewBob->m_vCam[0] = 0;
	pViewBob->m_vCam[1] = 0;
	pViewBob->m_vCam[2] = pViewBob->m_flBob * 1.2 * sin(pViewBob->m_flBobCycle*2 + MATH_PI/2 );
}


/* bob vars are calculated separately from application, so that if there's
 * more than one viewmodel we won't affect the speed of the bob by running
 * the math too many times */
//TAGGG - BobNEW. REPLACED.
// Also, a major difference between the Valve file and this version:
// This involves the previous frame's value of pViewBob->m_flBob, unlike Valve.
// pViewBob->m_flBobCycle involves its previous value still.
void
Viewmodel_CalcBob(void)
{
	vector vecVel;
	float flBob;
	int s = (float)getproperty(VF_ACTIVESEAT);
	pViewBob = &g_viewBobVars[s];

	float var_bob;
	float var_cycle;
	float var_up;
	
	// Multiples on these for new defaults for the same default CVar values:
	// v_bob:		0.01 -> 0.01 (unchanged)
	// v_bobcycle: 	0.8  -> 1.05
	// v_bobup: 	0.5  -> 0.525
	var_bob = autocvar_v_bob * 1;
	var_cycle = autocvar_v_bobcycle * 1.3125;
	var_up = autocvar_v_bobup * 1 * 1.05;
	
	
	
	player pl = (player)pSeat->m_ePlayer;  //clientside can do this

	int inputLen = vlen(input_movevalues);

	// do we care about "self.maxspeed" ??

	// Instead of some new bTouchingGround, using the presence of flag FL_ONGROUND.
	// If the player waterlevel >= 2, the "FL_ONGROUND" flag never occurs,
	// regardless of touching the floor in the area.
	// In original TS, being on the floor underwater DOES still do the camera/viewbob.
	// No idea how to get around this, beyond traces against the ground like pmove
	// does.
	
	BOOL bOnGround = FALSE;
	
	if(pl.waterlevel < 2){
		// Easy, trsy pl.flags having FL_ONGROUND.
		bOnGround = ((pl.flags & FL_ONGROUND) != 0);
	}else{
		// Underwater enough?  Need to do a re-trace, FL_ONGROUND is forced off by
		// pmove.
		// Open for better ideas, or maybe this is a massive "who cares" situation.
		
		tracebox(pl.origin, pl.mins, pl.maxs, pl.origin - [0,0,0.25], FALSE, pl);

		if (!trace_startsolid) {
			if ((trace_fraction < 1) && (trace_plane_normal[2] > 0.7)) {
				bOnGround = TRUE;
			} else {
				
			}
		}
	}
	
	
	if(!bOnGround){
		float timeTol;
		vector vSource = pl.origin;
		
		traceline ( vSource, vSource + ( '0 0 -1' * 5 ), TRUE, pl );
		//entity ef = findradius(trace_endpos, 40);
		
		if(trace_fraction < 1.0 || pl.velocity[2] > 50){
			//more distance from the ground?
			timeTol = 0.07;
		}else{
			timeTol = 0.17;
		}
		
		if((time-pl.flRecentGroundTime) > timeTol*(1/autocvar_movemodmulti) ){
			float reducerMulti;

			//if(inputLen <= 0.1){
			//	reducerMulti = pow(0.95, autocvar_movemodmulti);
			//}else{
				reducerMulti = pow(0.91, autocvar_movemodmulti);
			//}
				
			if(pViewBob->m_flBob > 0.02){
				pViewBob->m_flBob *= reducerMulti;
			}else{
				pViewBob->m_flBob = 0;
			}
			// adjust this per new m_flBob and frozen BobCycle.
			setVCam();
			return;
		}
	}else{
		pl.flRecentGroundTime = time;
	}

	
	float var_cycle_adj = var_cycle * (1/autocvar_movemodmulti);

	pViewBob->m_flBobTime += clframetime;
	pViewBob->m_flBobCycle = pViewBob->m_flBobTime - (int)(pViewBob->m_flBobTime / var_cycle_adj) * var_cycle_adj;
	pViewBob->m_flBobCycle /= var_cycle_adj;
	
	if (pViewBob->m_flBobCycle < var_up) {
		pViewBob->m_flBobCycle = MATH_PI * pViewBob->m_flBobCycle / var_up;
	} else {
		pViewBob->m_flBobCycle = MATH_PI + MATH_PI * (pViewBob->m_flBobCycle - var_up)/(1.0 - var_up);
	}

	vecVel = pSeat->m_vecPredictedVelocity;
	vecVel[2] = 0;
	pViewBob->m_flSpeed = vlen(vecVel);
	
	flBob = pViewBob->m_flSpeed * var_bob;
	
	// Most major differences start after here.
	// This involves the previous value of m_flBob for some smoothness when changed.
	pViewBob->m_flBob += (flBob - pViewBob->m_flBob) * 0.09 * autocvar_movemodmulti;
	
	// bounds from Valve, does it make sense here?
	//pViewBob->m_flBob = bound(-7, flBob, 4);

	// And the r_viewmodelscale from Valve.  I think this is safe.
	pViewBob->m_flBob *= autocvar_r_viewmodelscale;
	
	setVCam();
}

//TAGGG - BobNEW. REPLACED.
void
Viewmodel_ApplyBob(entity gun)
{
	player pl = (player)pSeat->m_ePlayer;
	gun.origin = pSeat->m_vecPredictedOrigin + pl.view_ofs;
	gun.origin += [0,0,-1];
	gun.origin += v_forward * (0.75 + autocvar_v_gunofs[0] + pViewBob->m_flBob * (-0.68 + -0.112 * fabs(sin(pViewBob->m_flBobCycle)) ) + 0.98 * pViewBob->m_vCam[0] );
	gun.origin += v_right * (autocvar_v_gunofs[1] + (pViewBob->m_flBob * (-0.2 + 0.308 * sin(pViewBob->m_flBobCycle)) ) + 0.98 * pViewBob->m_vCam[1] );
	gun.origin += v_up * (0.5 + autocvar_v_gunofs[2] + (pViewBob->m_flBob * (-0.48 + 0.196 * fabs(sin(pViewBob->m_flBobCycle)) )) + 0.98 * pViewBob->m_vCam[2] );

}