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


//TAGGG - BobNEW. Unused now.
/*
struct
{
	float m_flSpeed;
	float m_flFracSin;
	float m_flTime;
	float m_flMove;
	float m_flDelta;
	int m_iCycle;
} g_camBobVars[4], *pCamBob;
*/


/* tilts the camera for a head-bob like effect when moving */
//TAGGG - BobNEW. REPLACED.
// There are some major differences between the Vavle file and this one:
// * TS does not adjust the camera angles for bob, it moves it up and down a little.
//   This method does not alter camera_angle.  It sets the model VF_ORIGIN, which
//   may conflict a bit with Nuclide but it seems to work for now.
// * This depends on vCameraBobOriginOffset set by Viewmodel_CalcBob, which has
//   already been called ahead of time.  CameraBob does not have its own persistent vars
//   like the g_camBobVars/pCamBob struct above.
//
//   This method only runs when the player movetype is WALK.  Doubt that is a problem.
void
Camera_RunBob(__inout vector camera_angle)
{
	
	//TAGGG - NEW.  TS viewbob also shifts the player camera up/down a tiny bit.
	// We'll do that here, why not.
	// AND IMPORTANT - used to refer to vPlayerOrigin here,
	// now using vPlayerOrigin.
	// See if anywhere else called here neds to do that!
	// namely View_DetermineBobOffset.

	//setproperty(VF_ORIGIN, pSeat->vPlayerOrigin + pl.view_ofs + pViewBob->m_vCam);
	
	player pl = (player)pSeat->m_ePlayer;
	
	makevectors(view_angles);
	
	vector vCameraOriginFinal;
	vCameraOriginFinal =
	  pSeat->m_vecPredictedOrigin + pl.view_ofs +
	  v_forward * (pViewBob->m_vCam[0]) +
	  v_right * (pViewBob->m_vCam[1]) +
	  v_up * (pViewBob->m_vCam[2]);
	
	setproperty(VF_ORIGIN, vCameraOriginFinal);
}

/* applies a tilt to the camera for when we're strafing left to right */
//TAGGG - BobNEW. Dummied.  Don't think anything like this was in TS. 
void
Camera_StrafeRoll(__inout vector camera_angle)
{
	
}
