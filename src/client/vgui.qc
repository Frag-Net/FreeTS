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
// We can't use logic stuff in a global scope like this. This (vguiMenus[0].sTitle) can
// be set in an init method instead.


// Keep in synch with vgui.h's VGUI_SCREEN enum choices, besides the NONE choice.
// That isn't represented, not even by a dummy.
var vguiwindow_t vguiMenus[] = {
	//{ _("VGUI_TITLE_MOTD"), VGUI_MessageOfTheDay },
	{ "", TRUE, VGUI_MessageOfTheDay, NULL },
	{ "", FALSE, VGUI_BuySideMenu_Update, VGUI_BuySideMenu_OnInit}
};

//var float nextPrintoutTime = -1;


void
VGUI_ChangeScreen(VGUI_SCREEN arg_NewScreenID)
{
	pSeatLocal->fVGUI_Display = (float)arg_NewScreenID;
	
	if(arg_NewScreenID <= VGUI_SCREEN::NONE){
		// If at NONE or below, also do nothing. This has no "vOnInit" behavior.
		// Besides obligatory cleanup if we choose (which may as well be done right here)
		// And turn the cursor lock off.
		setcursormode(FALSE, "gfx/cursor", [0,0,0], 1.0f);
		// And don't let Nuclide's src/client/entry.qc try to re-lock the mouse!
		gFun_UI_EventGrabber_Hide();
		return;
	}
	
	// If this screen has a vOnInit, do it!
	// This is done for the new screen once as soon as it becomes the active one.
	// Also, turn the cursor lock on, clearly this needs user input.
	// src/client/entry.qc already has this check too for having any UI widget, but 
	// it takes one mouse-movement for it to kick-in, which causes one slight nudge of the
	// camera before the cursor appears.  Not terrible, but calling for the lock this early
	// ensures that doesn't get a chance to happen.
	setcursormode(TRUE, "gfx/cursor", [0,0,0], 1.0f);
	// And let the event grabber be shown so that entry.qc doesn't try to undo the mouse lock.
	gFun_UI_EventGrabber_Show();
	
	if(vguiMenus[arg_NewScreenID - 1].vOnInit != NULL){
		vguiMenus[arg_NewScreenID - 1].vOnInit();
	}
}//changeScreen


/*
=================
CSQC_VGUI_Draw

This is the entry point for FreeTS's (cloned from FreeCS) own "VGUI" implementation
Run every frame
=================
*/
float
CSQC_VGUI_Draw( player arg_player)
{
	if ( pSeatLocal->fVGUI_Display == VGUI_SCREEN::NONE ) {
		setcursormode( FALSE );
		return FALSE;
	}
	//int geh = vguiMenus.length;
	//vTextPos[1] += 14;
	
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
		
		
	}//END OF screen height check
	
	//
	if(FONT_ARIAL == -1 || Recorded_video_res != video_res){
		//Give it a font based on this screen size.
		
		//Recorded_video_res = video_res;
		Recorded_video_res[0] = video_res[0];
		Recorded_video_res[1] = video_res[1];
		
		//FONT_ARIAL = loadfont( "label", "arial", "32", -1 );
		float font_arial_size = (fontSizeMulti * 24);
		float font_arial_title_size = (fontSizeMulti * 32);
		string str_font_arial_size = ftos(font_arial_size);
		string str_font_arial_title_size = ftos(font_arial_title_size);
		
		
		FONT_ARIAL = loadfont( "game", "arial", str_font_arial_size, -1 );
		FONT_ARIAL_TITLE = loadfont( "game", "arial", str_font_arial_title_size, -1 );
		
		//print( sprintf("CHANGE height:%i fontm:%.2f fontref:%i match:(%i, %i) totalmatch:%i\n", (int)video_res[1], fontSizeMulti, (int)FONT_ARIAL, (int)(Recorded_video_res[0]==video_res[0]), (int)(Recorded_video_res[1]==video_res[1]), (int)(Recorded_video_res==video_res))  );
	}
	
	//little demo.
	/*
	if(nextPrintoutTime == -1 || (time >= nextPrintoutTime) ){
		nextPrintoutTime = time + 2;
		print( sprintf("timed printout. height:%i fontm:%.2f fontref:%i match:(%i, %i) totalmatch:%i\n", (int)video_res[1], fontSizeMulti, (int)FONT_ARIAL, (int)(Recorded_video_res[0]==video_res[0]), (int)(Recorded_video_res[1]==video_res[1]), (int)(Recorded_video_res==video_res))  );
	}
	*/
	
	vVGUIColor = autocvar_vgui_color * ( 1 / 255 );
	
	// Align the window to the center
	vVGUIWindowPos = video_mins;
	//vVGUIWindowPos[0] += ( video_res[0] / 2 ) - 320;
	//vVGUIWindowPos[1] += ( video_res[1] / 2 ) - 240;
	vVGUIWindowPos[0] += window_pad_x;
	vVGUIWindowPos[1] += window_pad_y;
	
	
	vVGUIWindowSiz[0] = window_width_x;
	vVGUIWindowSiz[1] = window_height_y;
	
	// draw the window only if this screen says to.
	if(vguiMenus[ pSeatLocal->fVGUI_Display - 1 ].fDrawMainWindowAuto){
		VGUI_Window( vVGUIWindowPos, vVGUIWindowSiz, vguiMenus[ pSeatLocal->fVGUI_Display - 1 ].sTitle, [fontSizeMulti*32,fontSizeMulti*32] );
	}
	
	// Display the contents of whatever we have selected
	vguiMenus[ pSeatLocal->fVGUI_Display - 1 ].vDraw( arg_player, vVGUIWindowPos, vVGUIWindowSiz, fontSizeMulti );

	return TRUE;
}

/*
=================
CSQC_VGUI_Init

Initialize all there is
=================
*/
// NOTE!  Not a built-in method, manually called by client init (ClientGame_Init).
// ALSO - this means once for the entire client, so handle all pSeat choices
// individually as it does.
void
CSQC_VGUI_Init(void)
{
	string sTemp;
	int iMOTDLength;
	int i;
	int s;
	
	filestream fmMapDescr;
	
	// only the first screen choice will use its 'sTitle'
	vguiMenus[0].sTitle = sprintf("%s - %s", "Free Specialists", serverkey("hostname"));
	
	// First load the MESSAGE OF THE DAY
	// TODO: Move this to the server and put strings into infokeys

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
	// NOPE!  Let this be handled elsewhere in case of a different VGUI color!
	//sMOTD_total = strcat("^xFA0", sMOTD_total);
	
	// Now load the MAP DESCRIPTION
	fmMapDescr = fopen( sprintf( "maps/%s.txt", mapname ), FILE_READ );
	if ( fmMapDescr != -1 ) {
		for (i = 0; i < 35; i++ ) {
			sTemp = fgets( fmMapDescr );
			if not ( sTemp ) {
				break;
			} 
			sMapString[ i ] = sTemp;
		}
		fclose( fmMapDescr );
	}
	
	gFun_UI_EventGrabber_Initialize();
	
	////////////////////////////////////////////////////
	// FOR NOW, a lazy way of init for all seats.
	// Apply to all seats, not worrying about what numclientseats is because this is tiny.
	if (serverkeyfloat("slots") != 1) {
		// We start on the MOTD, always
		for (s = 0; s < g_seats.length; s++){
			pSeat = &g_seats[s];
			pSeatLocal = &g_seatslocal[s];
			VGUI_ChangeScreen(VGUI_SCREEN::MOTD);
		}
	}else{
		// make all pSeats start at the NONE screen instead
		for (s = 0; s < g_seats.length; s++){
			pSeat = &g_seats[s];
			pSeatLocal = &g_seatslocal[s];
			VGUI_ChangeScreen(VGUI_SCREEN::NONE);
		}
	}
}
