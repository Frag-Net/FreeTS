/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

// Menus with their window titles and draw functions

//TAGGG
// also public now so that the first MOTD element can have its sTitle modified by game
// logic.  It's a bit more than just one language key now.
// And why did the array indeces have a number like this: "[11]"?  Looks to adjust fine
// to having no number and doing the count itself.
// where does "VGUI_TITLE_MODT" or the text it produces ("Message of the day") ever occur
// in game files or script?
// ANSWERED: it comes from the language file. See one of the files near the compiled
// .dat file
// (typically in the game's data.pk3dir fodlder) like so:
//  csprogs.dat.en.po
// The identifier and value for that language will show up.
// In this case, VGUI_TITLE_MODT won't be used. This new way mimicks the original The
// Specialists initial screen a little more.



//font_s FONT_ARIAL_TITLE_EX;


// Keep in synch with ui.h's UI_SCREEN enum choices, besides the NONE choice.
// That isn't represented, not even by a dummy.
var ui_screen_t ary_UI_Screen[] = {
	{
		FALSE,
		TRUE,
		UI_MOTD_Init,
		UI_MOTD_Show,
		UI_MOTD_Hide,
		UI_MOTD_Draw,
		UI_MOTD_OnMouseClick,
		UI_MOTD_OnKeyDown
	},
	{
		FALSE,
		FALSE,
		UI_BuyMenu_Init,
		UI_BuyMenu_Show,
		UI_BuyMenu_Hide,
		UI_BuyMenu_Draw,
		UI_BuyMenu_OnMouseClick,
		UI_BuyMenu_OnKeyDown
	 }
	
};

//var float nextPrintoutTime = -1;


// Actually sees if funInit should be called (first time going to that screen),
// also calls funShow.
void
UI_InitCheck(void){
	if(
		!ary_UI_Screen[pSeatLocal->m_flUI_Display-1].bInitializedYet &&
		ary_UI_Screen[pSeatLocal->m_flUI_Display-1].funInit != NULL
	){
		ary_UI_Screen[pSeatLocal->m_flUI_Display-1].funInit();
	}
	ary_UI_Screen[pSeatLocal->m_flUI_Display-1].bInitializedYet = TRUE;
	if(
		ary_UI_Screen[pSeatLocal->m_flUI_Display-1].funShow != NULL
	){
		ary_UI_Screen[pSeatLocal->m_flUI_Display-1].funShow();
	}
	g_UI_queueInit = FALSE;
}

void
UI_ChangeScreen(UI_SCREEN arg_NewScreenID)
{
	g_UI_queueInit = FALSE;
	
	if(
		pSeatLocal->m_flUI_Display != UI_SCREEN::NONE &&
		arg_NewScreenID != pSeatLocal->m_flUI_Display
	){
		// First, check the existing m_flUI_Display.  If valid, call funHide for it
		// (does not apply to setting the screen to the same choice)
		if(
			ary_UI_Screen[pSeatLocal->m_flUI_Display-1].funHide != NULL
		){
			ary_UI_Screen[pSeatLocal->m_flUI_Display-1].funHide();
		}
	}
	
	pSeatLocal->m_flUI_Display = (float)arg_NewScreenID;
	
	printfline("UI_ChangeScreen:: arg_NewScreenID? %d", arg_NewScreenID);
	
	if(arg_NewScreenID == UI_SCREEN::NONE){
		// If at NONE or below, also do nothing. This has no "funInit" behavior.
		// Besides obligatory cleanup if we choose (which may as well be done right here)
		// And turn the cursor lock off.
		setcursormode(FALSE, "gfx/cursor", [0,0,0], 1.0f);
		// And don't let Nuclide's src/client/entry.qc try to re-lock the mouse!
		printfline("TURN SCREEN OFF.");
		gFun_UI_EventGrabber_Hide();
		
		// Don't allow the same click to spawn the player, likely not intentional.
		// Unless we want to deviate from original TS and let buymenu-closing orders
		// count as spawn requests.
		// Questionably effective but better than nothing maybe.
		player pl = (player)pSeat->m_ePlayer;
		pl.gflags |= GF_SEMI_TOGGLED;
		pSeatLocal->flBlockSpawnTime = time + 0.20;
		return;
	}
	
	// If this screen has a funInit, do it!
	// This is done for the new screen once as soon as it becomes the active one.
	// Also, turn the cursor lock on, clearly this needs user input.
	// src/client/entry.qc already has this check too for having any UI widget, but 
	// it takes one mouse-movement for it to kick-in, which causes one slight nudge of the
	// camera before the cursor appears.  Not terrible, but calling for the lock this early
	// ensures that doesn't get a chance to happen.
	setcursormode(TRUE, "gfx/cursor", [0,0,0], 1.0f);
	// And let the event grabber be shown so that entry.qc doesn't try to undo the mouse lock.
	gFun_UI_EventGrabber_Show();
	
	if(video_res[0] == 0){
		// haven't set the screen resolution vars yet?
		// STOP: handle this as soon as possible.
		g_UI_queueInit = TRUE;
		return;
	}
	
	UI_InitCheck();
	
}

// helper method to load the MoTD text from the server into this client's memory
void
UI_loadMOTD(void){
	int iMOTDLength;
	int i;
	// First load the MESSAGE OF THE DAY from the sever
	//sMOTD_total = serverkey("motd_total");
	
	sMOTD_total = "";
	
	iMOTDLength = stof( serverkey( "motdlength" ) );
	for (i = 0; i < iMOTDLength; i++ ) {
		sMOTDString[ i ] = serverkey( sprintf( "motdline%i", i ) );
		
		if ( sMOTDString[ i ] == "/" ) {
			sMOTD_total = strcat(sMOTD_total, "\n" );
		}else{
			sMOTD_total = strcat(sMOTD_total, sprintf("%s\n", sMOTDString[ i ]) );
		}
	}
	// color it
	// NOPE!  Let this be handled elsewhere in case of a different color choice!
	//sMOTD_total = strcat("^xFA0", sMOTD_total);
	
}

void
UI_Init(void)
{
	int s;
	
	UI_loadMOTD();
	
	// someVar = loadMapDescription();
	loadMapDescription();
	
	gFun_UI_EventGrabber_Initialize();
	
	////////////////////////////////////////////////////
	// FOR NOW, a lazy way of init for all seats.
	// Apply to all seats, not worrying about what numclientseats is because this is tiny.
	if (serverkeyfloat("slots") != 1) {
		// We start on the MOTD, always
		for (s = 0; s < g_seats.length; s++){
			pSeat = &g_seats[s];
			pSeatLocal = &g_seatslocal[s];
			UI_ChangeScreen(UI_SCREEN::MOTD);
		}
	}else{
		// make all pSeats start at the NONE screen instead
		for (s = 0; s < g_seats.length; s++){
			pSeat = &g_seats[s];
			pSeatLocal = &g_seatslocal[s];
			UI_ChangeScreen(UI_SCREEN::NONE);
		}
	}
}



// big ugly method
void
UI_determineDrawGlobals(void){
	
	float fontSizeMulti;
	
	// How much space to add to the left and right of the drawn windows (x) and to the top and
	// bottom (y).
	// That does mean each removes twice its value of the drawn window in that dimension.
	// ex: a window_pad_x of 60 will actually remove 120 from the drawn window. 60 from the
	// left, 60 from the right.
	float window_pad_x = video_res[0] * 0.175;
	float window_pad_y = video_res[1] * 0.166;
	float window_width_x = video_res[0] - window_pad_x*2;
	float window_height_y = video_res[1] - window_pad_y*2;
	
	
	// If the height is over 800, stay at full size. It only gets smaller as the height
	// decreases.
	if(video_res[1] >= 800){
		fontSizeMulti = 1 * 1.0; //REMOVE 1.8 later!!!;
	}else{
		//scale it to fit the screen size.
		//fontSizeMulti = 0.2 + 0.001 * video_res[1];
		//fontSizeMulti = 0.234 + 0.0007 * video_res[1];
		fontSizeMulti = 0.1429 + 0.001 * 1.0 * video_res[1];
		
		
	}// screen height check
	
	//
	if(FONT_ARIAL == -1 || g_videoResPrev != video_res){
		//Give it a font based on this screen size.
		
		//g_videoResPrev = video_res;
		g_videoResPrev[0] = video_res[0];
		g_videoResPrev[1] = video_res[1];
		
		//FONT_ARIAL = loadfont( "label", "arial", "32", -1 );
		float font_arial_size = (fontSizeMulti * 24);
		float font_arial_title_size = (fontSizeMulti * 32);
		string str_font_arial_size = ftos(font_arial_size);
		string str_font_arial_title_size = ftos(font_arial_title_size);
		
		
		FONT_ARIAL = loadfont( "game", "arial", str_font_arial_size, -1 );
		FONT_ARIAL_TITLE = loadfont( "game", "arial", str_font_arial_title_size, -1 );
		
		
		// NEW!!!
		// TODO - use Font_Load to properly fill these fields from some kind of
		// font script file most likely, see examples in other codebaes.
		//Font_Load("folder/some_file.ext", &FONT_ARIAL_TITLE_TEST);
		
		// This works, but not completely.  Want some things to have differnet fonts,
		// like the _title and normal variants of FONT_ARIAL above.
		/*
		Font_Load_Easy("arial", (int)font_arial_title_size, FONT_ARIAL_TITLE_EX);
		g_fntDefault = FONT_ARIAL_TITLE_EX;
		*/
		
		
		
		//print( sprintf("CHANGE height:%i fontm:%.2f fontref:%i match:(%i, %i) totalmatch:%i\n", (int)video_res[1], fontSizeMulti, (int)FONT_ARIAL, (int)(g_videoResPrev[0]==video_res[0]), (int)(g_videoResPrev[1]==video_res[1]), (int)(g_videoResPrev==video_res))  );
	}
	
	//little demo.
	/*
	if(nextPrintoutTime == -1 || (time >= nextPrintoutTime) ){
		nextPrintoutTime = time + 2;
		print( sprintf("timed printout. height:%i fontm:%.2f fontref:%i match:(%i, %i) totalmatch:%i\n", (int)video_res[1], fontSizeMulti, (int)FONT_ARIAL, (int)(g_videoResPrev[0]==video_res[0]), (int)(g_videoResPrev[1]==video_res[1]), (int)(g_videoResPrev==video_res))  );
	}
	*/
	
	// Oh, there is a Nuclide-provided CVar called 'vgui_color'.
	// Keep this as it is?
	g_UI_Color = autocvar_vgui_color * ( 1 / 255 );
	
	// Align the window to the center
	g_UI_WindowPos = video_mins;
	g_UI_WindowPos[0] += window_pad_x;
	g_UI_WindowPos[1] += window_pad_y;
	
	g_UI_WindowSize[0] = window_width_x;
	g_UI_WindowSize[1] = window_height_y;
	
	g_fontSizeMulti = fontSizeMulti;
}



void
UI_Draw(void)
{
	if(pSeatLocal->m_flUI_Display == UI_SCREEN::NONE ){
		// Not effective for the new version of game executable fteglqw64.exe?
		// Well that's just dandy
		// (this is supposed to let clicking after closing the buy menu without moving the
		// mouse mouse work).
		setcursormode(FALSE, "gfx/cursor", [0,0,0], 1.0f);
		return;
	}
	
	if(g_UI_queueInit){
		// do it then!
		UI_InitCheck();
	}
	
	if(!ary_UI_Screen[pSeatLocal->m_flUI_Display-1].bInitializedYet){
		// no drawing uninitialized UI.  Is this even possible?
		return;
	}
	
	UI_determineDrawGlobals();
	//printfline("UI SIZE B! %.1f %.1f", g_UI_WindowSize[0], g_UI_WindowSize[1]);

#ifndef MOTD_NEW_VGUI
	// draw the window only if this screen says to.
	if(ary_UI_Screen[pSeatLocal->m_flUI_Display-1].fDrawMainWindowAuto){
		VGUI_Window( g_UI_WindowPos, g_UI_WindowSize, [g_fontSizeMulti*32,g_fontSizeMulti*32] );
	}
#endif
	
	
	// Display the contents of whatever we have selected
	ary_UI_Screen[pSeatLocal->m_flUI_Display-1].funDraw();

	return;
}


void
UI_MouseClick(void)
{
	if(pSeatLocal->m_flUI_Display != UI_SCREEN::NONE){
		if(
			ary_UI_Screen[pSeatLocal->m_flUI_Display-1].bInitializedYet &&
			ary_UI_Screen[pSeatLocal->m_flUI_Display-1].funOnMouseClick != NULL
		){
			ary_UI_Screen[pSeatLocal->m_flUI_Display-1].funOnMouseClick();
		}
	}
}
	
void
UI_KeyDown(void)
{
	if(pSeatLocal->m_flUI_Display != UI_SCREEN::NONE){
		if(
			ary_UI_Screen[pSeatLocal->m_flUI_Display-1].bInitializedYet &&
			ary_UI_Screen[pSeatLocal->m_flUI_Display-1].funOnKeyDown != NULL)
		{
			ary_UI_Screen[pSeatLocal->m_flUI_Display-1].funOnKeyDown();
		}
	}
}



/*
====================
UI_CheckMouse

Returns whether or not our mouse cursor hovers over a region
====================
*/
BOOL
UI_CheckMouse(vector vPos, vector vReg)
{
	vector vSMins, vSMaxs;
	
	vSMins = vPos;
	vSMaxs = vPos;
	vSMins[0] = vPos[0];
	vSMaxs[1] = vPos[1] - 1;

	vSMaxs[0] = vPos[0] + vReg[0];
	vSMaxs[1] = vPos[1] + vReg[1];

	if ( mouse_pos[0] >= vSMins[0] && mouse_pos[0] <= vSMaxs[0] ) {
		if (mouse_pos[1] >= vSMins[1] && mouse_pos[1] <= vSMaxs[1] ) {
			return TRUE;
		}
	}

	return FALSE;
}



// convenience method for now.  Based off of Nuclide's src/vgui Font_Load method,
// uses its font_s type
void
Font_Load_Easy(string strFontPath, int iFontScale, font_s &fntNew)
{
	fntNew.iScale = iFontScale;
	fntNew.vecColor = [1,1,1];
	fntNew.flAlpha = 1.0f;
	fntNew.iFlags = 0;
	fntNew.iID = (int)loadfont("", strFontPath, ftos((float)fntNew.iScale), -1, 0, 0);
}
