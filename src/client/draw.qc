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
 
// For pain arrows, see Nuclide's "Damage_Draw" method.  That's called for in HUD_Draw
// oddly enough, not these event-driven draw methods.

// Also, View_PostDraw is called even before HUD_DRAW, although a draw call early on
// in that method, above the rest should have the same effect anyway.


extern var string g_damage_spr_t;
extern var string g_damage_spr_b;
extern var string g_damage_spr_l;
extern var string g_damage_spr_r;



// WARNING: don't try drawing any 2D things on screen here, they'll be rendered
// over soon and ultimately lost, at least I think that's how it goes
void
ClientGame_PreDraw(void) 
{
	player pl = (player)pSeat->m_ePlayer;
	
	pl.handleZoom();
	
	
	pl.viewzoom = pl.flZoomCurrent;
	// PreDraw is called right after viewzoom is set by Nuclide, so this overrides
	// it.  That is fine.
	// Although, the 'setproperty' line already happened by the time this
	// method was reached, so these areas from Nuclide need to be redone.
	////////////////////////////////////////////////////////////////////
	setproperty(VF_AFOV, cvar("fov") * pl.viewzoom);
	
	if (autocvar_zoom_sensitivity && pl.viewzoom < 1.0f) {
		setsensitivityscaler(pl.viewzoom * autocvar_zoom_sensitivity);
	} else {
		setsensitivityscaler(pl.viewzoom);
	}

	if (pl.viewzoom <= 0.0f) {
		setsensitivityscaler(1.0f);
	}
	////////////////////////////////////////////////////////////////////
	
	
	// save the view_angles before adding in the predicted frame-total view kickback
	// from pl.vViewAngleOffset.
	view_angles_unmodified = view_angles;
	view_angles += pl.vViewAngleOffsetTotalChange;
	
}//ClientGame_PreDraw


// Happens right before the CSQC_RenderScene call seen in Nuclide's client/draw.qc.
// PostDraw further down is too late.
// NOT A NUCLIDE EVENT - called by the end of ViewModel_ApplyBob (viewmodel.qc) so that
// other changes to viewmodel position are already done.
void
Custom_LatePreDraw(void)
{
	player pl = (player)pSeat->m_ePlayer;
	
	TS_View_DrawCustom(pl);
	
	int thirdperson = (autocvar_cl_thirdperson == TRUE || pl.entnum != player_localentnum);
	TS_View_DrawExtraEffects(pl, thirdperson);
	
	// restore.
	view_angles = view_angles_unmodified;
}


void
ClientGame_PostDraw(void)
{
	// To replicate what Nuclide does for the normal muzzle flash entity in frame-logic:
	// reduce the alpha every frame to quickly fade away
	entity m_eMuzzleflashAkimbo = pSeatLocal->m_eMuzzleflashAkimbo;

	// Take away alpha once it has drawn fully at least once
	//printfline("View_PostDraw, muzzleflash? %.2f - %.2f", m_eMuzzleflash.alpha, clframetime);
	if (m_eMuzzleflashAkimbo.alpha > 0.0f) {
		m_eMuzzleflashAkimbo.alpha -= (clframetime * 16);
	}
}





// copied from Nuclide
void
TS_HUD_drawPainArrows(void)
{
	vector center;
	vector rel_pos;
	float fw, fw_alpha;
	float rt, rt_alpha;

	if (pSeat->m_flDamageAlpha <= 0.0) {
		return;
	}

	center = video_mins + (video_res / 2);

	/* the pos relative to the player + view_dir determines which
	 * and how bright each indicator is drawn. so first get the relative
	 * position between us and the attacker, then calculate the strength
	 * of each direction based on a dotproduct tested against our
	 * camera direction.
	 */
	rel_pos = normalize(pSeat->m_vecDamagePos - getproperty(VF_ORIGIN));
	makevectors(getproperty(VF_CL_VIEWANGLES));
	fw = dotproduct(rel_pos, v_forward);
	rt = dotproduct(rel_pos, v_right);

	fw_alpha = fabs(fw) * pSeat->m_flDamageAlpha;
	if (fw > 0.25f) {
		drawpic(center + [-64,-102], g_damage_spr_t, 
			[128,48], [1,1,1], fw_alpha, DRAWFLAG_ADDITIVE);
	} else if (fw < -0.25f) {
		drawpic(center + [-64,70], g_damage_spr_b,
			[128,48], [1,1,1], fw_alpha, DRAWFLAG_ADDITIVE);
	}

	rt_alpha = fabs(rt) * pSeat->m_flDamageAlpha;
	if (rt > 0.25f) {
		drawpic(center + [70,-64], g_damage_spr_r,
			[48,128], [1,1,1], rt_alpha, DRAWFLAG_ADDITIVE);
	} else if (rt < -0.25f) {
		drawpic(center + [-102,-64], g_damage_spr_l,
			[48,128], [1,1,1], rt_alpha, DRAWFLAG_ADDITIVE);
	}
	
}





// and now for the screen-wide pain flash.
void
TS_HUD_drawPainFlash(void)
{
	
	//drawfill( video_mins, video_res, clrRed, VGUI_WINDOW_FGALPHA );
	//drawfill( video_mins, video_res, clrRed, arg_opac - 0.60f, DRAWFLAG_NORMAL );
	
	float drawAlpha;
	float filteredAlpha = pSeat->m_flDamageAlpha * 0.49;
	
	if(filteredAlpha > 0.32){
		drawAlpha = 0.32;
	}else{
		drawAlpha = filteredAlpha;
	}
	
	drawfill( video_mins, video_res, clrRed, drawAlpha, DRAWFLAG_NORMAL);
}


void
TS_HUD_DamageDraw(void){
	
	// No alpha, or dead?  No pain drawing
	if(
		pSeat->m_flDamageAlpha <= 0.0 ||
		getplayerkeyfloat(pSeat->m_ePlayer.entnum - 1, "*dead") == 1
	){
		return;
	}

	TS_HUD_drawPainFlash();
	TS_HUD_drawPainArrows();

	// Nuclide's default had no modifier on clframetime ( * 1).
	pSeat->m_flDamageAlpha -= clframetime * 1.7;
}


