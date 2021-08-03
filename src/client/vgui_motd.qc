/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/


/*
====================
VGUI_MessageOfTheDay

The MOTD screen. 

TODO: Networking still needs to be done.
You can't store motds in infokey strings because
newline chars are not supported. You could hack it to use
an array of infokeys, but that'll clutter things up
====================
*/

// Cloned from src/menu-fn/w_label.qc, HACKY
string
Colors_RGB8_to_HEX(vector color)
{
	string out = "^x";
	//string out = "";

	for (int i = 0; i < 3; i++) {
		string a = "";
		float b = rint(color[i] * 15);

		switch (b) {
		case 10:
			a = "A";
			break;
		case 11:
			a = "B";
			break;
		case 12:
			a = "C";
			break;
		case 13:
			a = "D";
			break;
		case 14:
			a = "E";
			break;
		case 15:
			a = "F";
			break;
		default:
			a = ftos(b);
		}
		out = sprintf("%s%s", out, a);
	}
	return out;
}



void VGUI_MessageOfTheDay(player arg_player, vector vPos, vector vWindowSiz, float fFontSizeMulti ) {
	
	static void MessageOfTheDay_ButtonOK( void ) {
		//pSeatLocal->fVGUI_Display = VGUI_SCREEN::BUYSIDEMENU;
		
		printfline("HEY ButtonOK got CLICKED!!!");
		VGUI_ChangeScreen(VGUI_SCREEN::BUYSIDEMENU);
	}
	
	//TAGGG - start from this location instead.
	//vector vTextPos = vPos + '16 116 0';
	vector vTextPos = vPos + '16 64 0';
	
	// apply the VGUI color, since TextLineWrap (route to FTE method drawtextfield)
	// does not offer color, but in-text markup can offer this.
	// PENDING: if this is done a lot, offer it as a utility method?
	// That can take a color vector and apply this hex step for us.
	// Just beware that this applies to all text after the affected text as well,
	// markup only stops when overridden by other markup as read from left to right.
	// example:
	// ^x0F0 term1 term2
	// ...colors term1 and term2 green, even if this was not intentional for term2.
	// ^x0F0 term1 ^xF00 term2
	// ...colors term1 green, but term2 red.
	string tempText = sprintf("%s%s", Colors_RGB8_to_HEX(vVGUIColor), sMOTD_total);
	
	// Oh, and no transparency it seems, so no slight show-through that the title text gets.
	// So you have to invent your own wordwrap to get that??  Let's just skip that.
	Gfx_TextLineWrap( vTextPos, vWindowSiz - ('16 64 0' * 2) , DRAWTEXTFIELD_ALIGN_LEFT_TOP, tempText, FONT_ARIAL );
	
	if(pSeatLocal->m_inputKeyTapped == 13){
		//pressing enter here works too.
		MessageOfTheDay_ButtonOK();
		pSeatLocal->m_inputKeyTapped = 0;   //why do we have to do this, no clue
	}
	
	VGUI_Button( _("VGUI_OK"), MessageOfTheDay_ButtonOK, [vPos.x + 16, vPos.y + vWindowSiz.y - 30 - 16, 0], '100 30 0' );
}


