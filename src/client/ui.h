

#define VGUI_WINDOW_BGCOLOR '0.0 0.0 0.0'
#define VGUI_WINDOW_BGALPHA 0.76
#define VGUI_WINDOW_FGALPHA 1.0

var vector g_UI_WindowPos;
var vector g_UI_WindowSize;
var float g_fontSizeMulti;
var BOOL g_UI_queueInit = FALSE;

string sMOTDString[25];
string sMapString[35];

var string sMOTD_total;


// Keep in synch with the ary_UI_Screen array of ui.qc
enum UI_SCREEN{
	NONE = 0,
	MOTD,
	BUYMENU
};

typedef struct {
	// start at FALSE, set to TRUE if done before
	BOOL bInitializedYet;
	
	// Whether to do a VGUI_Window call to draw a window.
	// Not very customizable for now, intended only for the MoTD, but adapts to different screen sizes.
	// Could have other settings added later, or even be handled per screen's draw call too for completely re-doing
	// ---This will be removed on the move to the new VGUI.
	BOOLEAN fDrawMainWindowAuto;
	
	void(void) funInit;
	void(void) funShow;
	void(void) funHide;
	void(void) funDraw;
	void(void) funOnMouseClick;
	void(void) funOnKeyDown;
	// What to do the moment the screen is changed to this.
} ui_screen_t;



void UI_Init(void);
void UI_Draw(void);
void UI_MouseClick(void);
void UI_KeyDown(void);
void UI_ChangeScreen(UI_SCREEN fNewScreenID);
BOOL UI_CheckMouse(vector vPos, vector vReg);

void UI_determineDrawGlobals(void);

