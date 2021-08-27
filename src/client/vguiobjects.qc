/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

// PENDING DELETION - these are only used for the old pseudo VGUI


#ifndef MOTD_NEW_VGUI
/*
====================
VGUI_Window

Draws window with outline, border and title
====================
*/

void VGUI_Window( vector vPosition, vector vSize, vector vFontSize ) {
	// Draw the background
	drawfill( vPosition, vSize, VGUI_WINDOW_BGCOLOR, VGUI_WINDOW_BGALPHA );
	
	// Sides
	drawfill( vPosition, [vSize[0], 1], g_UI_Color, VGUI_WINDOW_FGALPHA );
	drawfill( [vPosition[0], vPosition[1] + vSize[1] - 1], [vSize[0], 1], g_UI_Color, VGUI_WINDOW_FGALPHA );
	drawfill( vPosition, [1, vSize[1]], g_UI_Color, VGUI_WINDOW_FGALPHA );
	drawfill( [vPosition[0] + vSize[0] - 1, vPosition[1]], [1, vSize[1]], g_UI_Color, VGUI_WINDOW_FGALPHA );

	
	drawfill( vPosition + '0 48', [vSize[0], 1], g_UI_Color, VGUI_WINDOW_FGALPHA );
}


/*
====================
VGUI_Button

Draws a button, returns whether or not a mouse is hovering over it (for inheritance' sake)
====================
*/

//*** NOTE! BuyMenu buttons don't use this!  Only the MoTD close button, at least so far.
float VGUI_Button( string sLabel, vector vPosition, vector vSize) {
	vector vLabelPos;
	
	
	drawfill( vPosition, [vSize[0], 1], g_UI_Color, VGUI_WINDOW_FGALPHA );
	drawfill( [vPosition[0], vPosition[1] + vSize[1] - 1], [vSize[0], 1], g_UI_Color, VGUI_WINDOW_FGALPHA );
	drawfill( vPosition, [1, vSize[1]], g_UI_Color, VGUI_WINDOW_FGALPHA );
	drawfill( [vPosition[0] + vSize[0] - 1, vPosition[1]], [1, vSize[1]], g_UI_Color, VGUI_WINDOW_FGALPHA );

	// Draw the button label
	vLabelPos[0] = vPosition[0] + 16;
	vLabelPos[1] = vPosition[1] + ( ( vSize[1] / 2 ) - 4 );
	
	
	
	if ( UI_CheckMouse( vPosition, vSize ) ) {
		Gfx_Text( vLabelPos, sLabel, vHUDFontSize, g_UI_Color, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE, FONT_ARIAL_STD );
		drawfill( vLabelPos + '0 10 0', [ stringwidth( sLabel, TRUE, '12 12' ), 1], g_UI_Color, VGUI_WINDOW_FGALPHA );
		return TRUE;
	} else {
		Gfx_Text( vLabelPos, sLabel, vHUDFontSize, g_UI_Color * 0.8, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE, FONT_ARIAL_STD );
	}
	
	return FALSE;
}
#endif
