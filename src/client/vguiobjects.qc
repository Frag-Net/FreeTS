/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

/*
====================
VGUI_CheckMouse

Returns whether or not our mouse cursor hovers over a region
====================
*/
float VGUI_CheckMouse( vector vPos, vector vReg ) {
	vector vSMins, vSMaxs;
	
	vSMins = vPos;
	vSMaxs = vPos;
	vSMins[0] = vPos[0];
	vSMaxs[1] = vPos[1] - 1;

	vSMaxs[0] = vPos[0] + vReg[0];
	vSMaxs[1] = vPos[1] + vReg[1];

	if ( mouse_pos[0] >= vSMins[0] && mouse_pos[0] <= vSMaxs[0] ) {
		if (mouse_pos[1] >= vSMins[1] && mouse_pos[1] <= vSMaxs[1] ) {
			return 1;
		}
	}

	return 0;
}


/*
====================
VGUI_Window

Draws window with outline, border and title
====================
*/

/*
//TAGGG - NEW. This is the old parameters. Sends to VGUI_WINDOW to draw the string with a default font size
//		(the default font size was actually 16, it has been increased to 24)
// Order in the new overload further below also puts things in a different order.
inline void VGUI_Window( string sTitle, vector vPosition, vector vSize ) {
	VGUI_Window(vPosition, vSize, sTitle, [24, 24]);
}
*/

void VGUI_Window( vector vPosition, vector vSize, string sTitle, vector vFontSize ) {
	// Draw the background
	drawfill( vPosition, vSize, VGUI_WINDOW_BGCOLOR, VGUI_WINDOW_BGALPHA );
	
	// Sides
	drawfill( vPosition, [vSize[0], 1], vVGUIColor, VGUI_WINDOW_FGALPHA );
	drawfill( [vPosition[0], vPosition[1] + vSize[1] - 1], [vSize[0], 1], vVGUIColor, VGUI_WINDOW_FGALPHA );
	drawfill( vPosition, [1, vSize[1]], vVGUIColor, VGUI_WINDOW_FGALPHA );
	drawfill( [vPosition[0] + vSize[0] - 1, vPosition[1]], [1, vSize[1]], vVGUIColor, VGUI_WINDOW_FGALPHA );

	// Draw the window title
	//TAGGG - little bigger.
	// Also use DRAWFLAG_NORMAL to stop the transparency from not being a solid color choice.
	// ADDITIVE interprets any darker color than as bright as possible as transparency.
	// The wordwrapped text does not support this, so let them both be solid.
	// No benefit to transparent text anyway.
	//title text font size depends on the height of the window.
	//Gfx_Text( vPosition + '16 16', sTitle, '12 12', vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE, FONT_CON );
	Gfx_Text( vPosition + '16 16', sTitle, vFontSize, vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_NORMAL, FONT_ARIAL_TITLE );
	
	//Gfx_TextLineWrap( vPosition + '16 16', vSize - ('16 64 0' * 2) , DRAWTEXTFIELD_ALIGN_LEFT_TOP, sTitle, FONT_ARIAL_STD );
	
	
	drawfill( vPosition + '0 48', [vSize[0], 1], vVGUIColor, VGUI_WINDOW_FGALPHA );
}


/*
====================
VGUI_WindowSmall

Draws smaller window with outline, border and title
====================
*/
void VGUI_WindowSmall( string sTitle, vector vPosition, vector vSize ) {
	// Draw the background
	drawfill( vPosition, vSize, VGUI_WINDOW_BGCOLOR, VGUI_WINDOW_BGALPHA );
	
	// Sides
	drawfill( vPosition, [vSize[0], 1], vVGUIColor, VGUI_WINDOW_FGALPHA );
	drawfill( [vPosition[0], vPosition[1] + vSize[1] - 1], [vSize[0], 1], vVGUIColor, VGUI_WINDOW_FGALPHA );
	drawfill( vPosition, [1, vSize[1]], vVGUIColor, VGUI_WINDOW_FGALPHA );
	drawfill( [vPosition[0] + vSize[0] - 1, vPosition[1]], [1, vSize[1]], vVGUIColor, VGUI_WINDOW_FGALPHA );

	// Draw the window title
	Gfx_Text( vPosition + '8 8', sTitle, '12 12', vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE, FONT_CON );
	drawfill( vPosition + '0 24', [vSize[0], 1], vVGUIColor, VGUI_WINDOW_FGALPHA );
}

/*
====================
VGUI_Button

Draws a button, returns whether or not a mouse is hovering over it (for inheritance' sake)
====================
*/

//*** NOTE! Buysidemenu buttons don't use this!  Only the MoTD close button, at least so far.
float VGUI_Button( string sLabel, void() vFunction, vector vPosition, vector vSize) {
	vector vLabelPos;
	
	/*
	if ( iVGUIKey < 57 ) {
		iVGUIKey++;
	}
	*/
	
	drawfill( vPosition, [vSize[0], 1], vVGUIColor, VGUI_WINDOW_FGALPHA );
	drawfill( [vPosition[0], vPosition[1] + vSize[1] - 1], [vSize[0], 1], vVGUIColor, VGUI_WINDOW_FGALPHA );
	drawfill( vPosition, [1, vSize[1]], vVGUIColor, VGUI_WINDOW_FGALPHA );
	drawfill( [vPosition[0] + vSize[0] - 1, vPosition[1]], [1, vSize[1]], vVGUIColor, VGUI_WINDOW_FGALPHA );

	// Draw the button label
	vLabelPos[0] = vPosition[0] + 16;
	vLabelPos[1] = vPosition[1] + ( ( vSize[1] / 2 ) - 4 );
	
	/*
//TAGGG REPLACEMENT - "pSeatLocal->fInputKeyCode" for "TS_keyRefUp".
	if ( ( iVGUIKey == TS_keyRefUp ) ) {
		vFunction();
		TS_keyRefUp = 0;
		return TRUE;
	}
	*/
	
	
	
	if ( VGUI_CheckMouse( vPosition, vSize ) ) {
		//pSeatLocal->fVGUI_Display
	
		if ( TS_mouseClickRef == TRUE ) {
			vFunction();
			TS_mouseClickRef = FALSE;
		}
		
		Gfx_Text( vLabelPos, sLabel, vButtonFontSize, vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE, FONT_ARIAL_STD );
		drawfill( vLabelPos + '0 10 0', [ stringwidth( sLabel, TRUE, '12 12' ), 1], vVGUIColor, VGUI_WINDOW_FGALPHA );
		return TRUE;
	} else {
		Gfx_Text( vLabelPos, sLabel, vButtonFontSize, vVGUIColor * 0.8, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE, FONT_ARIAL_STD );
	}
	
	return FALSE;
}

/*
====================
VGUI_FakeButton

Looks like a button, doesn't function though. Meant for dead buttons
====================
*/
void VGUI_FakeButton( string sLabel, vector vPosition, vector vSize ) {
	vector vLabelPos;
	
	drawfill( vPosition, [vSize[0], 1], vVGUIColor, VGUI_WINDOW_FGALPHA );
	drawfill( [vPosition[0], vPosition[1] + vSize[1] - 1], [vSize[0], 1], vVGUIColor, VGUI_WINDOW_FGALPHA );
	drawfill( vPosition, [1, vSize[1]], vVGUIColor, VGUI_WINDOW_FGALPHA );
	drawfill( [vPosition[0] + vSize[0] - 1, vPosition[1]], [1, vSize[1]], vVGUIColor, VGUI_WINDOW_FGALPHA );

	// Draw the button label
	vLabelPos[0] = vPosition[0] + 16;
	vLabelPos[1] = vPosition[1] + ( ( vSize[1] / 2 ) - 4 );

	Gfx_Text( vLabelPos, sLabel, '12 12', vVGUIColor * 0.5, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE, FONT_CON );
}

/*
====================
VGUI_Text

Wrapper for simple GUI text labels
====================
*/
void VGUI_Text( string sText, vector vPos, vector vSize, float fFont ) {
	Gfx_Text( vPos, sText, vSize, vVGUIColor, VGUI_WINDOW_FGALPHA, DRAWFLAG_ADDITIVE, fFont );
}

/*
====================
VGUI_RightText

Right-aligned version of above
====================
*/
void VGUI_RightText( vector vPos, string sText, vector vSize, vector vColor, float fFont ) {
	vPos[0] -= stringwidth( sText, FALSE, vSize );
	Gfx_Text( vPos, sText, vSize, vColor, 1, 0, fFont );
}
