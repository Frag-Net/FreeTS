

#define VGUI_WINDOW_BGCOLOR '0.0 0.0 0.0'
#define VGUI_WINDOW_FGCOLOR '1.0 0.5 0.0'
#define VGUI_WINDOW_BGALPHA 0.76
#define VGUI_WINDOW_FGALPHA 1.0

//var int iVGUIKey;

vector vVGUIWindowPos;
vector vVGUIWindowSiz;
//vector vVGUIButtonPos;

string sMOTDString[25];
string sMapString[35];

var string sMOTD_total;

class player;


// Keep in synch with the vguiMenus array of vgui.c
enum VGUI_SCREEN{
	NONE = 0,
	MOTD,
	BUYSIDEMENU
};

typedef struct {
	string sTitle;
	// Whether to do a VGUI_Window call to draw a window.
	// Not very customizable for now, intended only for the MoTD, but adapts to different screen sizes.
	// Could have other settings added later, or even be handled per screen's draw call too for completely re-doing
	BOOLEAN fDrawMainWindowAuto;
	
	// Custom draw script for a particular screen choice
	//TAGGG - now accepts how much to change the font size (and adjust other things) by.
	// Also accepts the player for getting other info from.
	void(player arg_player, vector vPos, vector vWindowSiz, float fFontSizeMulti ) vDraw;
	// What to do the moment the screen is changed to this.
	void(void) vOnInit;
} vguiwindow_t;



void CSQC_VGUI_Init(void);
float CSQC_VGUI_Draw( player arg_player);
void VGUI_ChangeScreen(VGUI_SCREEN fNewScreenID);


