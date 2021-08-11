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


void
HUD_Init(void)
{
	// leftover HL precache that's used in scoreboard.qc it seems,
	// haven't looked into what TS does for that yet.
	g_hud1_spr = spriteframe("sprites/640hud1.spr", 0, 0.0f);
	
	precache_model("sprites/player/crouched.spr");
	precache_model("sprites/player/divestepb.spr");
	precache_model("sprites/player/divestepc.spr");
	precache_model("sprites/player/divestept.spr");
	precache_model("sprites/player/health.spr");
	precache_model("sprites/player/kevlar.spr");
	precache_model("sprites/player/kungfu.spr");
	precache_model("sprites/player/movement.spr");
	precache_model("sprites/player/prone.spr");
	precache_model("sprites/player/run.spr");
	precache_model("sprites/player/stand.spr");
	
	precache_model("sprites/weapons/item_installed.spr");
	precache_model("sprites/weapons/item_not_installed.spr");
}


/* weapon/ammo pickup notifications */
void
HUD_DrawNotify(void)
{
	// Nope, pretty sure TS had nothing like that.
	/*
	vector pos;
	
	if (pSeatLocal->m_flPickupAlpha <= 0.0f) {
		return;
	}

	pos = g_hudmins + [g_hudres[0] - 192, g_hudres[1] - 128];
	Weapons_HUDPic(pSeatLocal->m_iPickupWeapon, 1, pos, pSeatLocal->m_flPickupAlpha);
	pSeatLocal->m_flPickupAlpha -= clframetime;
	*/
}

void
HUD_WeaponPickupNotify(int w)
{
	//pSeatLocal->m_iPickupWeapon = w;
	//pSeatLocal->m_flPickupAlpha = 1.0f;
}

/* main entry */
void
HUD_Draw(void)
{
	player pl = (player)pSeat->m_ePlayer;
	
	
	if(pl.iState == PLAYER_STATE::SPAWNED){
		// A player
		
		g_hud_color = autocvar_con_color * (1 / 255);

		/* little point in not drawing these, even if you don't have a suit */
		Weapons_DrawCrosshair();
		TS_HUD_DrawWeaponSelect();
		Obituary_Draw();
		Textmenu_Draw();
		
		//TAGGG - NEw
		//////////////////////////////////////////////////////////////
		//View_HandleZoom();
		
		//printfline("SCOPE LEVEL %.2f", pl.flZoomCurrent);
		if(pl.flZoomCurrent < 0.5){   //is this < 40?	yes.
			HUD_DrawScope();
		}else{
			// We'll leave details like extra details for the lasersight and the
			// weight bars at a bare minimum (should be drawn at all times, oversight
			// in TS 2.1 that they're missing from melee views like with knives,
			// katana, corrected in 3.0 of all things)
			HUD_DrawCrosshair();
		}
		//////////////////////////////////////////////////////////////
		
		//TAGGG - new
		//////////////////////////////////////////////////////////////
		drawTimer();
		drawPlayerStats();  
		
		// ---OLD LOCATION for weapon stats drawing (Weapons_DrawCrosshair)
		//////////////////////////////////////////////////////////////
		
		
		// Just for nuclide, doesn't matter what m_iHUDWeaponSelected is exactly,
		// just 0 or non-zero has significance in it for denying game-related inputs
		// in Nuclide, which is all we need.
		pSeat->m_iHUDWeaponSelected = (pl.weaponSelectHighlightID != -1);
		
		
		pSeatLocal->m_inputKeyTapped = 0;  //reset.
		
		HUD_DrawNotify();
		// Nuclide provided method, draws the HL pain arrows
		// Nope!  Replaced with a completely new version that does that and more for
		// more control. And not even calling from here, leaving that to PostDraw
		// (draw.qc) instead. Might stop the pain flash from affecting the color of
		// HUD draw's.
		//Damage_Draw();
		//ClientGame_DamageDraw();
		
	}else{
		// Fake spectator, or the temporary forced third-person on death (not yet implemented).
		
		drawfont = FONT_20;
		// TAGGG - could have some message from server-to-client on changing from
		// player to spectator to call this only then, but I think doing this every
		// frame for spectator is harmless anyway. Changing the FOV isn't necessary,
		// that already comes with the spec/player change, some things are nicely
		// defaulted for us in FTE.
		setsensitivityscaler(1.0f);
		
		pSeat->m_iHUDWeaponSelected = 0;
		
		
		drawTimer();
		
		// Links to drawing the MoTD and buymenu when appropriate
		UI_Draw();
		
	}// pl.iState check
	

}



string g_specmodes[] = {
	"Free Camera",
	"Third Person",
	"First Person"
};

// specatator main entry (method cloned from FreeHL)
// -NOTE!  This is for the real, Nuclide-provided spectator. The fake spectator is a
// normal player entity with iState set to PLAYER_STATE::NOCLIP.
// HUD_DRAW above is still called in that case.  That needs the MoTD and buymenu.
void
HUD_DrawSpectator(void)
{
	Textmenu_Draw();

	spectator spec = (spectator)pSeat->m_ePlayer;

	drawfont = FONT_20;
	vector vecPos;
	string strText;

	strText = sprintf("Tracking: %s", getplayerkeyvalue(spec.spec_ent - 1, "name"));
	vecPos[0] = g_hudmins[0] + (g_hudres[0] / 2) - (stringwidth(strText, TRUE, [20,20]) / 2);
	vecPos[1] = g_hudmins[1] + g_hudres[1] - 60;
	drawstring(vecPos, strText, [20,20], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);

	strText = sprintf("Mode: %s", g_specmodes[spec.spec_mode]);
	vecPos[0] = g_hudmins[0] + (g_hudres[0] / 2) - (stringwidth(strText, TRUE, [20,20]) / 2);
	vecPos[1] = g_hudmins[1] + g_hudres[1] - 40;
	drawstring(vecPos, strText, [20,20], [1,1,1], 1.0f, DRAWFLAG_ADDITIVE);
	
}
