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
 
// For pain arrows, see Nuclide's "Damage_Draw" method.  That's called for in HUD_Draw
// oddly enough, not these event-driven draw methods.

// Also, View_PostDraw is called even before HUD_DRAW, although a draw call early on
// in that method, above the rest should have the same effect anyway.


extern var string g_damage_spr_t;
extern var string g_damage_spr_b;
extern var string g_damage_spr_l;
extern var string g_damage_spr_r;


void drawPainArrows(void);
void drawPainFlash(void);
void ClientGame_DamageDraw(void);



void
ClientGame_PreDraw(void) 
{

}

void
ClientGame_PostDraw(void)
{
	ClientGame_DamageDraw();
}


// copied from Nuclide
void
drawPainArrows(void)
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
drawPainFlash(void)
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
ClientGame_DamageDraw(void){
	
	// No alpha, or dead?  No pain drawing
	if(
		pSeat->m_flDamageAlpha <= 0.0 ||
		getplayerkeyfloat(pSeat->m_ePlayer.entnum - 1, "*dead") == 1
	){
		return;
	}

	drawPainArrows();
	drawPainFlash();

	// Nuclide's default had no modifier on clframetime ( * 1).
	pSeat->m_flDamageAlpha -= clframetime * 1.7;
}






