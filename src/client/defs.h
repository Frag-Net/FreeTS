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

#include "obituary.h"
#include "particles.h"


// VERY LITTLE USES "hud_color" RIGHT NOW!
// See inventory_logic_draw.qc for places that benefit from involving it, compare to behavior
// in original TS to see what it affects.
vector g_hud_color;
vector g_hudmins;
vector g_hudres;



/*
// Do we need these?  Note the similarly named "g_hud_color" already above!
// Going to keep the latter two for compatability.
vector vHUDColor;
*/
vector g_UI_Color;

// Global var to store the current screen size. If it changes, the font should be re-loaded to fit it.
var vector g_videoResPrev;


// Replaces several cases of FONT_CON to be able to draw larger text (well).
var float FONT_ARIAL;
var float FONT_ARIAL_TITLE;
var float FONT_ARIAL_STD;  //stands for "standard" ya hooligans.
var float FONT_ARIAL_NUMSLASH;
var float FONT_ARIAL_SCOPEMAG;

// Be sure to keep this up to date with the font FONT_ARIAL_STD as it's loaded in
// ui.qc, notice this is always one less than the actual expected corresponding font.
// Except vButtonFontSize it is 2 less in width, I think it would be better to make
// the buy buttons a little wider though.
// TODO - a some things may be unused at this point, check.
const vector vButtonFontSize = [14, 15, 0];
const vector vHUDFontSize = [15, 15, 0];
const vector vFontSizeNumSlash = [17, 17, 0];
const vector vFontArialScopeMag = [18, 18, 0];

const vector vButtonSizStandard = [127, 19, 0];

const vector clrBtnDefault = [0, 0, 0];
const vector clrPaleBluePurple = [174.0f/255.0f, 152.0f/255.0f, 255.0f/255.0f];

//const vector clrFailedSlotbarColor = [240.0f/255.0f, 116.0f/255.0f, 0/255.0f];
const vector clrFailedSlotbarColor = [255.0f/255.0f, 90.0f/255.0f, 100.0f/255.0f];

const vector clrHUDWeaponEmpty = [255.0f/255.0f, 75f/255.0f, 75f/255.0f];


// wait, for the default way the GUI colors work (hud_r, hud_g, hud_b) be 150, 150, 255 then?
// TODO - test that later.
const vector clrPaleBlue = [180.0f/255.0f, 195.0f/255.0f, 255.0f/255.0f];
const vector clrMedRed = [255.0f/255.0f, 56.0f/255.0f, 56.0f/255.0f];

const vector clrGreen = [0f/255.0f, 255.0f/255.0f, 0f/255.0f];
const vector clrRed = [255.0f/255.0f, 0f/255.0f, 0f/255.0f];

const vector clrLaserHUDDot = [255.0f/255.0f, 35.0f/255.0f, 35.0f/255.0f];



// NEW.
// The "fov" CVar is set to this at startup.  This must be changed to be persistent
// bewteen games.
var float autocvar_fov_default =  80.0f;

// TODO.  Is this even used yet?
var int autocvar_sv_autoweaponswitch = TRUE;

// Probably won't last too long
var float autocvar_old_latepredraw_call = 1.0f;

// Very situational, not all debug printouts, nowhere near.
var float autocvar_cl_printoutspam = 0;


void HUD_WeaponPickupNotify(int);

// !!!
// g_seatslocal AND pSeatLocal definition moved to seatlocal.h




