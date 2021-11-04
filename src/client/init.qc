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


var float numclientseats_highest;

/*
=================
ClientGame_Init

Comparable to worldspawn in SSQC in that it's mostly used for precaches
=================
*/
void
ClientGame_Init(float apilevel, string enginename, float engineversion)
{
	numclientseats_highest = 0;
	
	int s;
	printfline("---ClientGame_Init---");
	printf("What is numclientseats? %d\n", numclientseats);
	
	
	// wait, numclientseats isn't even known right at startup?  Just 0 here?
	// And the RendererRestart event further down also isn't called after the
	// first client is added so it sees 0 too?
	// I GIVE UP just do this for all possible g_seats and be done with it
	
	// !!!
	// Use g_seats.length instead to fill all seats, even those not intended for use, or
	// in case of a change of numclientseats (was 1, but someone joins for multiplayer on 
	// the same machine maybe)?  I have no idea how or even if that could happen in the
	// same run.
	// src/client/view.qc's View_Init works only with the current number of numclientseats
	// at least, for reference.
	// Although it is called by CSQC_RendererRestarted, which may happen anytime
	// numclientseats is adjusted.
	// Moved to our ClientGame_RendererRestart for safety, change how this works if my
	// understanding of pSeat isn't quite there.
	
	//if(numclientseats > g_seats.length){numclientseats = g_seats.length;}
	for(s = 0; s < g_seats.length; s++){  // < numclientseats
		pSeat = &g_seats[s];
		pSeatLocal = &g_seatslocal[s];
		
		pSeatLocal_init();
		ClientInfo_init(&pSeatLocal->m_clientinfo);
	}
	numclientseats_highest = numclientseats;
	
	
	//TAGGG - NEW.
	SharedGame_Init();
	// Nope!  Not calling ClientGame_Precache here, use "ClientGame_RendererRestart"
	// where all the other precaches are now.  It is called at init as well, and
	// called later as needed, unlike here.
	
	
	Obituary_Init();
		
	// over stuff removed
	//precache_pic( sprintf( "overviews/%s.bmp", mapname ) );
	
	registercommand("getorigin");
	registercommand("getangle");
	
	registercommand("firemode");
	
	registercommand("+useitems");
	registercommand("-useitems");
	
	registercommand("usepowerup");
	registercommand("+alt1");
	registercommand("-alt1");
	registercommand("+alt2");
	registercommand("-alt2");
	
	
	registercommand("dev_testorbituary");
	registercommand("minimap");
	registercommand("overview_test");
	
	registercommand("buy");
	registercommand("motd");
	//registercommand("chooseteam");

	// NO NEED!  See CSEv_DropWeapon in nuclide's src/server/weapons.qc, that gets called.
	// I think? Might want to verify.
	registercommand("drop");
	
	
	// QUESTION - good luck with however this is supposed to varry between multiple
	// split-screen clients (g_seat[#]) across the same game client!
	// Can CVars even be per-splitscreen client, yet it feels like some are
	// begging to be.
	cvar_set("fov", ftos(autocvar_fov_default));
	
	
	// WARNING! Any font-stuff below may be rendered completley obsolete by
	// using the new VGUI approach.
	// That also includes mentions of fonts in ts/src/client/vgui.qc
	
	// Also see ts/src/client/ui.qc where UI_Draw checks to see if the screen
	// size has been changed or this is the first time drawing (some FONTs having ID -1).
	// In either case, they're loaded and sized per screen height over there.
	FONT_ARIAL = -1;  //specify me at draw startup instead, if this is safe.
	                  // This allows this to adjust for screen size.
	FONT_ARIAL_TITLE = -1;
	// ALSO, beware.  arialbd.ttf can be included in projects, (check common gfx/shell
	// directories, like within any .pk3dir folders).  
	// As of this time, the only place should be
	//     platform/menu_fonts.pk3dir/gfx/shell/arialbd.ttf
	// Even so, this reference to the file does not involve the "gfx/shell/" portion,
	// so it will only search system libraries for it instead.
	// As for how to substitute with the local copy of arialbd.ttf if it is detected
	// to be missing from the OS, no idea, because even figuring that out seems trick.
	// Any "loadfont" call returns an int that isn't -1 actually, even if it finds
	// nothing at all.  And consistently, subsequent calls to the exact same file/path
	// for "loadfont" will also return the exact same number, as a remembered "type"
	// of missing?  No idea. (missing uses the FTE default font, which is much more
	// sprite/pixel-y looking than most other fonts in lack of a better term).
	// BLABLABLA.  "arialbd.ttf" without the "gfx/shell/" in front is searching the OS,
	// not your own gamemod or platform directories (which ought to have it in gfx/shell).
	// Forget it!  I'm using our own platform supplied one, "gfx/shell/" it is.
	FONT_ARIAL_STD = loadfont( "", "gfx/shell/arialbd.ttf", "16", -1 );
	FONT_ARIAL_NUMSLASH = loadfont( "", "gfx/shell/arialbd.ttf", "17", -1 );
	FONT_ARIAL_SCOPEMAG = loadfont( "", "gfx/shell/arialbd.ttf", "18", -1 );
	
	// safe default for whatever doesn't specify it?
	// Beware that draw calls that don't set the drawfont will still rely
	// on the previously set one, although that could be intentional too.
	drawfont = Font_GetID(FONT_CON);
	//////////////////////////////////////////////////////////////////
	
	UI_Init();
	
}

void
ClientGame_InitDone(void)
{
}


// keeping this here, not called by Nuclide but to be obvious what it's mirroring.
// Sets up the akimbo muzzleflash entity as Nuclide would have:
void
Custom_ViewInit(void){
	int s;
	for (s = g_seats.length; s-- > numclientseats;) {
		pSeatLocal = &g_seatslocal[s];
		if(!pSeatLocal->m_eMuzzleflashAkimbo){
			pSeatLocal->m_eMuzzleflashAkimbo = spawn();
			pSeatLocal->m_eMuzzleflashAkimbo.classname = "mflash";
			pSeatLocal->m_eMuzzleflashAkimbo.renderflags = RF_ADDITIVE;
			pSeatLocal->m_eMuzzleflashAkimbo.effects |= EF_NOSHADOW;
			setsize(pSeatLocal->m_eMuzzleflashAkimbo, [0,0,0], [0,0,0]);
		}
	}
}


void
ClientGame_RendererRestart(string rstr)
{
	int s;
	
	printfline("---ClientGame_RendererRestart---");
	//printf("What is numclientseats? %d highest:%d\n", numclientseats, numclientseats_highest);
	
	// NEVERMIND.
	/*
	if(numclientseats > g_seats.length){numclientseats = g_seats.length;}
	// Did numclientseats change, and it's higher than the previous choice?
	// Just init the additional ones then.
	if(numclientseats > numclientseats_highest){
		printfline("---Need to init new pseats? %d vs. %d", numclientseats, numclientseats_highest);
		for(s = numclientseats-1; s >= numclientseats_highest; s--){
			pSeat = &g_seats[s];
			pSeatLocal = &g_seatslocal[s];
			
			pSeatLocal_init();
			ClientInfo_init(&pSeatLocal->m_clientinfo);
		}
		printfline("numclientseats_highest D SET TO %d", numclientseats);
		numclientseats_highest = numclientseats;
	}
	*/
	
	
	// this is ok.
	// Mainly, some things about viewmodels need to be refreshed on vid_restart,
	// like submodel choice (silencer, scope, laser/flashlight, bloodied melee weapons).
	// If anything else should be handled, in there it goes
	for(s = 0; s < numclientseats; s++){  // < numclientseats
		pSeat = &g_seats[s];
		pSeatLocal = &g_seatslocal[s];
		player pl = (player)pSeat->m_ePlayer;
		
		//pSeatLocal->m_bRecentRendererRestart = TRUE;
		
		// TODO - if this becomes a lot of lines, go to a method
		// "pSeatLocal_RendererRestart" instead
		if(pl != NULL && pl.iState == PLAYER_STATE::SPAWNED){
			pl.prev_iForceBodygroup1Submodel = 0;
			TS_View_SetViewModelFromStats();
		}
	}
	
	
	
	Custom_ViewInit();
	// Hook into precache.qc
	ClientGame_Precache();
	
}
