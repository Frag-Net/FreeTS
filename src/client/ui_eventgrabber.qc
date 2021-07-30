
// This file is named "vgui_late" for being compiled after the nuclide "src" project
// includes so that CUIWidget (src/vgui/ui.qc) is available.



// example of VGUI usage: see FreeCS, mention of this:
//    winChooseTeam


// Simple UIWidget to absorb mouse-click and key-press events while in
// the MoTD or the buysidemenu screens.
// Do not give me child elements!  Behavior for handling children removed.

class CUIEventGrabber:CUIWidget
{
	//void(void) CUIEventGrabber;
	virtual void(void) Draw;
	virtual void(float, float, float, float) Input;
};


void
CUIEventGrabber::Draw(void)
{
	// nothing!
}

//TODO: globals from src/client/defs.h over here now (like TS_mouseClickRef, etc.)

void
CUIEventGrabber::Input(float flEVType, float flKey, float flChar, float flDevID)
{
	
	// no need to do this.
	//g_vguiWidgetCount++;
	
	switch (flEVType) {
		
	case IE_KEYDOWN:
		//printf("CUIEventGrabber::Input %d\n", flKey); 
		if (flKey == K_MOUSE1) {
			TS_mouseClickRef = 1;
		} else {
			TS_keyRefDown = 1;
		}
		TS_keyRefUp = flKey;
		TS_keyRefTapped = flKey;  //lasts only this frame
		TS_keyRefUpASCII = flChar;
		break;
	case IE_KEYUP:
		if (flKey == K_MOUSE1) {
			TS_mouseClickRef = 0;
		} else {
			TS_keyRefDown = 0;
		}
		TS_keyRefUp = 0;
		TS_keyRefUpASCII = 0;
		break;
	}
	
}

// Could include this a lot earlier, but no point as it's useless without being
// able to call methods of it until CUIEventGrabber is defined (which requires
// UIWidget, which requires all nuclide stuff to be included, which happens late
// into the compile)
var CUIEventGrabber g_UI_EventGrabber;


void gFun_UI_EventGrabber_Initialize(void){
	g_UI_EventGrabber = spawn(CUIEventGrabber);
	g_uiDesktop.Add(g_UI_EventGrabber);
	
	// make it "visible", or rather, "active" for grabbing input events?
	// If this flag is missing it gets overlooked in ui.qc's run-through
	// of child elements for sending input events to is skipped.
	// Actually not even here, let calls to _Show or _Hide (below) handle this.
	//g_UI_EventGrabber.m_iFlags |= 1;
	//g_UI_EventGrabber.FlagAdd(1);
}

void gFun_UI_EventGrabber_Show(void){
	g_UI_EventGrabber.FlagAdd(1);
}
void gFun_UI_EventGrabber_Hide(void){
	g_UI_EventGrabber.FlagRemove(1);
}
