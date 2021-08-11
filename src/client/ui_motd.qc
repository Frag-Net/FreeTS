/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

// TODO - NEW_VGUI support should be better, need different fonts between
// the title and label text (really just different sizes of the same font)
// and support for color choices from CVar, see g_UI_Color and how it is
// formed


#ifdef MOTD_NEW_VGUI
CUIButton UI_MOTD_btnOK;
CUIWindow UI_MOTD_win;
CUILabel UI_MOTD_label;
#endif

var BOOL g_UI_MOTD_everClosed = FALSE;
var string g_MOTD_windowTitle;



void UI_MOTD_btnOK_Clicked( void ){
	if(!g_UI_MOTD_everClosed){
		UI_ChangeScreen(UI_SCREEN::BUYMENU);
	}else{
		UI_ChangeScreen(UI_SCREEN::NONE);
	}
}


void
UI_MOTD_Init(void)
{
#ifdef MOTD_NEW_VGUI
	//printfline("UI SIZE A! %.1f %.1f", g_UI_WindowSize[0], g_UI_WindowSize[1]);
	
	UI_MOTD_win = spawn(CUIWindow);
	// something absurd for now.
	UI_MOTD_win.SetMaxSize([3000, 2000]);
	
	UI_MOTD_btnOK = spawn(CUIButton);
	UI_MOTD_btnOK.SetTitle(_("VGUI_OK"));
	UI_MOTD_btnOK.SetSize([100, 30]);
	UI_MOTD_btnOK.SetFunc(UI_MOTD_btnOK_Clicked);
	
	UI_MOTD_label = spawn(CUILabel);
	//UI_MOTD_label.SetMaxSize([3000, 2000]);
	
	g_uiDesktop.Add(UI_MOTD_win);
	UI_MOTD_win.Add(UI_MOTD_btnOK);
	UI_MOTD_win.Add(UI_MOTD_label);
	
	
	UI_MOTD_win.Hide();
#endif
}

void
UI_MOTD_Show(void)
{
	
	g_MOTD_windowTitle = sprintf("%s - %s", "Free Specialists", serverkey("hostname"));
	
#ifdef MOTD_NEW_VGUI
	// For g_UI_WindowSize to be formed at least.
	// Use "vSizeEffective" instead to work with whatever size ends up
	// happening, it might be different in some cases if the min/max
	// sizes are not followed.
	// No need for the WindowPos one, all coords of in-window elements are
	// relative to the window, and centering whatever window size again
	// is easy.
	UI_determineDrawGlobals();
	
	//???.Hide();
	UI_MOTD_win.SetTitle(g_MOTD_windowTitle);
	//UI_MOTD_win.SetPos(g_UI_WindowPos);
	UI_MOTD_win.SetSize(g_UI_WindowSize);
	vector vSizeEffective = UI_MOTD_win.GetSize();
	UI_MOTD_win.SetPos((video_res / 2) - (vSizeEffective / 2));

	
	UI_MOTD_btnOK.SetPos([0 + 16, 0 + vSizeEffective.y - 30 - 16]);
	
	
	
	//UI_MOTD_label.SetTitle("abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc abc");
	string tempText = sprintf("%s%s", Colors_RGB8_to_HEX(g_UI_Color), sMOTD_total);
	UI_MOTD_label.SetTitle(tempText);
	
	vector labelSiz = [300, 300];
	UI_MOTD_label.SetSize(labelSiz);
	//UI_MOTD_label.SetPos((vSizeEffective / 2) - (labelSiz / 2));
	vector vTextPos = [16, 64];
	UI_MOTD_label.SetPos(vTextPos);
	UI_MOTD_label.SetSize(vSizeEffective - (vTextPos * 2));
	
	UI_MOTD_win.Show();
#endif
}

void
UI_MOTD_Hide(void)
{
	// be aware that this is not the first time being closed
	g_UI_MOTD_everClosed = TRUE;
#ifdef MOTD_NEW_VGUI
	// hides the window
	UI_MOTD_win.FlagRemove(1);
#endif
}

void
UI_MOTD_Draw(void)
{
	
#ifdef MOTD_NEW_VGUI
	if(!(UI_MOTD_win.m_iFlags & 1) /*&& !g_UI_MOTD_everClosed*/){
		// this means the window was hidden by closing with the X button.
		// The OK button sets that flag so that this can't be reached that way.
		// The point is, closing the MoTD the first time by any means should lead
		// to the buy menu
		// ACTUALLY, leaving that up to btnOK to determine.  Still want to solidly set
		// the current screen to NONE regardless of closing the MoTD for the first time.
		UI_MOTD_btnOK_Clicked();
	}
	
#else
	
	
	// Draw the window title
	// Also use DRAWFLAG_NORMAL to stop the transparency from not being a solid color choice.
	// ADDITIVE interprets any darker color than as bright as possible as transparency.
	// The wordwrapped text does not support this, so let them both be solid.
	// No benefit to transparent text anyway.
	//  title text font size depends on the height of the window.
	
	Gfx_Text( g_UI_WindowPos + [16, 16], g_MOTD_windowTitle, g_fontSizeMulti*32, g_UI_Color, VGUI_WINDOW_FGALPHA, DRAWFLAG_NORMAL, FONT_ARIAL_TITLE );
	
	//Gfx_TextLineWrap( vPosition + '16 16', vSize - ('16 64 0' * 2) , DRAWTEXTFIELD_ALIGN_LEFT_TOP, sTitle, FONT_ARIAL_STD );
	
	vector vTextPos = g_UI_WindowPos + [16, 64];
	
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
	string tempText = sprintf("%s%s", Colors_RGB8_to_HEX(g_UI_Color), sMOTD_total);
	
	// Oh, and no transparency it seems, so no slight show-through that the title text gets.
	// So you have to invent your own wordwrap to get that??  Let's just skip that.
	Gfx_TextLineWrap( vTextPos, g_UI_WindowSize - ([16, 64] * 2) , DRAWTEXTFIELD_ALIGN_LEFT_TOP, tempText, FONT_ARIAL );
	
	VGUI_Button( _("VGUI_OK"), [g_UI_WindowPos.x + 16, g_UI_WindowPos.y + g_UI_WindowSize.y - 30 - 16, 0], '100 30 0' );
	
#endif// else of ifdef MOTD_NEW_VGUI
}


void
UI_MOTD_OnMouseClick(void)
{
#ifndef MOTD_NEW_VGUI
	vector vPosition = [g_UI_WindowPos.x + 16, g_UI_WindowPos.y + g_UI_WindowSize.y - 30 - 16, 0]
	
	if ( UI_CheckMouse( vPosition, g_UI_WindowSize ) ) {
		UI_MOTD_btnOK_Clicked();
		pSeatLocal->m_inputMouseClicked = FALSE;
	}
#endif
}
void
UI_MOTD_OnKeyDown(void)
{
	// pressing enter here works too.
	if(pSeatLocal->m_inputKeyTapped == 13){
		UI_MOTD_btnOK_Clicked();
		pSeatLocal->m_inputKeyTapped = 0;   //why do we have to do this, no clue
	}
}


