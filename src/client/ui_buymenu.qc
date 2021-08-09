/***
*
*	Copyright (c) 2016-2019 Marco 'eukara' Hladik. All rights reserved.
*
*	See the file LICENSE attached with the sources for usage details.
*
****/

#define LABEL_OFFSET_X 1
#define LABEL_OFFSET_Y 3

#define BUTTON_TYPEID_BASIC 0
#define BUTTON_TYPEID_WEAPON 1




#define INITIALIZE_BASICBUTTON(arg_varName, arg_sName, arg_sHotkeyDisplay, arg_clr, arg_funOnClick_Custom) buymenu_btn_##arg_varName = spawn(CBuyMenu_BasicButton);\
	flDeterminedHotkey = determineHotkeyFromChar(arg_sHotkeyDisplay);\
	buymenu_btn_##arg_varName.setThisPointer(&buymenu_btn_##arg_varName);\
	buymenu_btn_##arg_varName.create(sprintf("%s %s", arg_sHotkeyDisplay, arg_sName), flDeterminedHotkey, arg_clr, arg_funOnClick_Custom);\
	buymenu_addbuttonToTotal(&buymenu_btn_##arg_varName);


#define INITIALIZE_WEAPONBUTTON(arg_varName, arg_sHotkeyDisplay, arg_clr, arg_parentName) buymenu_btn_Buy_##arg_varName = spawn(CBuyMenu_WeaponButton);\
	flDeterminedHotkey = determineHotkeyFromChar(arg_sHotkeyDisplay);\
	buymenu_btn_Buy_##arg_varName.setThisPointer(&buymenu_btn_Buy_##arg_varName);\
	tempWeapRef = *ary_weaponData[WEAPON_ID::##arg_varName];\
	buymenu_btn_Buy_##arg_varName.create_WeaponButton(sprintf("%s %s", arg_sHotkeyDisplay, tempWeapRef.sDisplayName), flDeterminedHotkey, arg_clr, NULL, tempWeapRef.sIconFilePath, tempWeapRef.iPrice, tempWeapRef.iSlots, tempWeapRef.iBitsUpgrade & ~tempWeapRef.iBitsUpgradeAuto);\
	buymenu_addbuttonToTotal(&buymenu_btn_Buy_##arg_varName);\
	buymenu_btn_Buy_##arg_varName.iWeaponPurchaseID = WEAPON_ID::##arg_varName;\
	buymenu_addbutton(&buymenu_btn_Buy_##arg_parentName, &buymenu_btn_Buy_##arg_varName);
	
	
	
// prototype'd class
class CBuyMenu_BasicButton;


var int iWeaponTempID = -1;

//What upgrades has the player purchased for the currently open weapon in the buy menu?
var int iBitsUpgradeTemp = BITS_WEAPONOPT_NONE;
//How much does the weapon's upgrades (does not consider ammo if necessary) cost?
var int iExtraPriceTemp = 0;
var int iExtraSlotsTemp = 0;
var int iPurchaseCountTemp = 1;

var int iHoveredButtonIndex = -1;
var int iActiveLayer = 0;


class CBuyMenu_BasicButton;
class CBuyMenu_WeaponButton;
class CBuyMenu_WeaponButton;
class CBuyMenu_RemoveWeaponButton;

void buymenu_cancelConfigAndClose(void);
void refreshButtons(void);
void setupRemoveButtonList(void);
void buymenu_btn_removeButton_clicked(CBuyMenu_BasicButton* arg_this);
void buymenu_btn_RemoveItem_clicked(CBuyMenu_BasicButton* arg_this);


void buymenu_backOneLayer(void);
void buymenu_btn_Back_updateText(void);
void buymenu_btn_Back_clicked(CBuyMenu_BasicButton* arg_this);

void(CBuyMenu_BasicButton* arg_someButton) setActiveLayerButton;

float determineHotkeyFromChar(string arg_sHotkeyDisplay);



// Each button ever created must be added to this list. Can be one automatically.
// struct's don't have constructors though.  Call for this at startup I suppose.
var CBuyMenu_BasicButton* ary_btnTotal[128];
var int ary_btnTotal_softLength = 0;

var CBuyMenu_BasicButton* ary_layerButtonChoice[16];  //16 layers max.  Not that nearly this many should be used.
//var int ary_layerButtonChoiceIndex[16i]; //alternative approach.

// Any buttons in the first layer must be recorded here.
var CBuyMenu_BasicButton* ary_layerFirstButton[16];
var int ary_layerFirstButton_softLength = 0;


// One button expected for each weapon in ary_myWeapons of the tempconfig at most.
// (so up to "ary_myWeapons_length" in count).
CBuyMenu_RemoveWeaponButton ary_btn_removeButton[ary_myWeapons_length];



var CBuyMenu_BasicButton buymenu_btn_WeaponOpt_Buy;
var CBuyMenu_BasicButton buymenu_btn_WeaponOpt_Silencer;
var CBuyMenu_BasicButton buymenu_btn_WeaponOpt_Lasersight;
var CBuyMenu_BasicButton buymenu_btn_WeaponOpt_Flashlight;
var CBuyMenu_BasicButton buymenu_btn_WeaponOpt_Scope;
var CBuyMenu_BasicButton buymenu_btn_WeaponOpt_Akimbo;
var CBuyMenu_BasicButton buymenu_btn_WeaponOpt_FullLoad;




// SPECIAL BUTTON - draw this wherever appropriate for the active layer. Its text is also different
// if the 1st layer is active (drawn to that one). Says "Cancel" there, but if on any deeper layer it reads "Go Back".
var CBuyMenu_BasicButton buymenu_btn_Back;
// var CBuyMenu_BasicButton buymenu_btn_Back = {0, "0 Cancel", 0,0, 48, NULL, {}, 0, NULL};

var CBuyMenu_BasicButton buymenu_btn_Recentconfig;
var CBuyMenu_BasicButton buymenu_btn_Buy;
var CBuyMenu_BasicButton buymenu_btn_RemoveItem;
var CBuyMenu_BasicButton buymenu_btn_ResetConfig;
var CBuyMenu_BasicButton buymenu_btn_SaveConfig;
var CBuyMenu_BasicButton buymenu_btn_LoadConfig;
var CBuyMenu_BasicButton buymenu_btn_BuyRandom;

var CBuyMenu_BasicButton buymenu_btn_Buy_Handguns;
var CBuyMenu_BasicButton buymenu_btn_Buy_SMGs;
var CBuyMenu_BasicButton buymenu_btn_Buy_Rifles;
var CBuyMenu_BasicButton buymenu_btn_Buy_Shotguns;
var CBuyMenu_BasicButton buymenu_btn_Buy_SpecialPurpose;

var CBuyMenu_WeaponButton buymenu_btn_Buy_GLOCK18;
var CBuyMenu_WeaponButton buymenu_btn_Buy_SOCOMMK23;
var CBuyMenu_WeaponButton buymenu_btn_Buy_DESERTEAGLE;
var CBuyMenu_WeaponButton buymenu_btn_Buy_FIVESEVEN;
var CBuyMenu_WeaponButton buymenu_btn_Buy_BERETTA;
var CBuyMenu_WeaponButton buymenu_btn_Buy_AKIMBOCOLTS;

var CBuyMenu_WeaponButton buymenu_btn_Buy_GLOCK20;

var CBuyMenu_WeaponButton buymenu_btn_Buy_RUGERMK1;
var CBuyMenu_WeaponButton buymenu_btn_Buy_RAGINGBULL;
var CBuyMenu_WeaponButton buymenu_btn_Buy_CONTENDERG2;


var CBuyMenu_WeaponButton buymenu_btn_Buy_MINIUZI;
var CBuyMenu_WeaponButton buymenu_btn_Buy_MP5SD;
var CBuyMenu_WeaponButton buymenu_btn_Buy_MP5K;
var CBuyMenu_WeaponButton buymenu_btn_Buy_STEYRTMP;

// called the MP7PDW ingame?  ts_fgd refers to it as "HK Pdw" though
var CBuyMenu_WeaponButton buymenu_btn_Buy_HKPDW;

var CBuyMenu_WeaponButton buymenu_btn_Buy_MAC10;
var CBuyMenu_WeaponButton buymenu_btn_Buy_UMP;
var CBuyMenu_WeaponButton buymenu_btn_Buy_SKORPION;

var CBuyMenu_WeaponButton buymenu_btn_Buy_M4A1;
var CBuyMenu_WeaponButton buymenu_btn_Buy_AK47;
var CBuyMenu_WeaponButton buymenu_btn_Buy_STEYRAUG;
var CBuyMenu_WeaponButton buymenu_btn_Buy_M16A4;
var CBuyMenu_WeaponButton buymenu_btn_Buy_BARRETTM82;

var CBuyMenu_WeaponButton buymenu_btn_Buy_BENELLIM3;
var CBuyMenu_WeaponButton buymenu_btn_Buy_USAS12;
var CBuyMenu_WeaponButton buymenu_btn_Buy_SPAS12;
var CBuyMenu_WeaponButton buymenu_btn_Buy_MOSSBERG500;
var CBuyMenu_WeaponButton buymenu_btn_Buy_SAWEDOFF;

var CBuyMenu_WeaponButton buymenu_btn_Buy_M61GRENADE;
var CBuyMenu_WeaponButton buymenu_btn_Buy_COMBATKNIFE;
var CBuyMenu_WeaponButton buymenu_btn_Buy_M60;
var CBuyMenu_WeaponButton buymenu_btn_Buy_KATANA;
var CBuyMenu_WeaponButton buymenu_btn_Buy_SEALKNIFE;




// Notice that the buttons do not have location/size information. They are
// drawn wherever as needed, checks for clicks need that supplied to know where
// to check.
// NOTE: any method names involving "click" also happen when the button's hotkey
// is pressed.
class CBuyMenu_BasicButton{
	
	// yes. really.  
	CBuyMenu_BasicButton* _this;
	
	int iType;  // is this a BasicButton or a WeaponButton?
	BOOL bActive;  // Effectively hides this from all logic. As in, don't skip the space this would occupy. Pretend like this button didn't exit.
	// Refreshed at a new layer / going back one.

	int iGlobalIndex;
	string sName;
	
	// -1 is the signal for "no hotkey". Numbers actually start at 48 for 0 (49 for 1... or 48+1 for clarity).
	float flHotkey;
	
	vector clr; // stored; natural color.
	vector clr_render; // for actual use.
	
	// Array of buttons that are shown when I'm clicked on. Many buttons use this.
	// The "0 Cancel" back button will be drawn if applicaple (for the active (deepest layer open) if it's not the first layer).
	// struct CBuyMenu_BasicButton* ary_btn[16i];
	int ary_btn_index[16];
	int ary_btn_softLength;
	
	
	// Special behavior for this button (optional).  Good for buttons that will interact
	// with something in the game like adding a weapon or adding an accessory (Silencer) to an existing one.
	
	virtual void(CBuyMenu_BasicButton* arg_this) funOnClick_Custom = NULL;
	//int* funOnClick_Custom;
	virtual void(CBuyMenu_BasicButton* arg_this) funOnShow_Custom = NULL;
	//int* funOnShow_Custom;
	
	void(void) CBuyMenu_BasicButton;
	
	virtual void(CBuyMenu_BasicButton* arg_this) setThisPointer;
	
	virtual void(string arg_sName, float arg_flHotkey, vector arg_clr, void(CBuyMenu_BasicButton* arg_this) arg_funOnClick_Custom ) create;
	
	virtual void(vector arg_suggestedDrawPos, int arg_iLayer, int arg_iButtonRow, BOOL arg_fIsSelected) funOnRender_Base;
	virtual void(void) funOnClick_Base;
	
	
	virtual void(void) funOnShow_Base;
	
	// This is set separately from any "create" methods or constructors since it is rarely used.
	// If set, this method will run anytime this button is shown. This lets it do a quick calculation
	// to see if the player can afford an upgrade as it is displayed.
	
	
};


class CBuyMenu_WeaponButton : CBuyMenu_BasicButton{
	
	// What weapon (by ID) will I purchase (or try to) when bought?
	// Parameter limit used up - have to set this separtely.  Ugh.
	// We're remaking buttons to use structs instead of classes later so this isn't too
	// bad of a patch for now.
	int iWeaponPurchaseID;
	
	string sWeaponImagePath;
	int iWeaponPrice;
	int iWeaponSlots;
	int iBitsWeaponOpt; //Can the player buy... a scope? lazer sight? flash light? akimbo? etc.
	
	
	void(void) CBuyMenu_WeaponButton;
	
	// after arg_clr: int arg_ary_btn_index[16]
	virtual void(string arg_sName, float arg_flHotkey, vector arg_clr, void(CBuyMenu_BasicButton* arg_this) arg_funOnClick_Custom, string arg_sWeaponImagePath, int arg_iWeaponPrice, int arg_iWeaponSlots, int arg_iBitsWeaponOpt ) create_WeaponButton;
	
	virtual void(vector arg_suggestedDrawPos, int arg_iLayer, int arg_iButtonRow, BOOL arg_fIsSelected) funOnRender_Base;
	virtual void(void) funOnClick_Base;
	
	
	virtual void(void) funOnShow_Base;
	
};


// Very slightly modified form of CBuyMenu_BasicButton that just includes
// an extra var for storing what part of the config to remove if clicked on.
// As in, the 3rd button will remove the 2nd index  (...ary_myWeapons[2]) from the player's 
// temp config.
class CBuyMenu_RemoveWeaponButton : CBuyMenu_BasicButton{
	// What element of the config do I remove if I am picked?
	int linkedConfigIndex;

	void(void) CBuyMenu_RemoveWeaponButton;
};


void
CBuyMenu_RemoveWeaponButton::CBuyMenu_RemoveWeaponButton(void)
{
	
}

// Being called implies the mouse was clicked.  Calls OnClick_Base if the mouse is
// within the button bounds.
BOOL
checkBuyMenuButtonClicked(
	CBuyMenu_BasicButton* arg_someBtn, vector vPosition, vector vSize
)
{
	CBuyMenu_BasicButton deref = *arg_someBtn;
	
	if(UI_CheckMouse(vPosition, vSize)){
		// What button is being hovered over?
		iHoveredButtonIndex = deref.iGlobalIndex;

		(*arg_someBtn).funOnClick_Base();
		
		pSeatLocal->m_inputMouseClicked = FALSE;
		return TRUE;
	}
	
	return FALSE;
}// checkBuyMenuButtonClicked

// Is the recent input key a match for this button's hotkey?
BOOL
checkBuyMenuButtonHotKeyPressed(
	CBuyMenu_BasicButton* arg_someBtn
)
{
	CBuyMenu_BasicButton deref = *arg_someBtn;
	
	// Check for the button's hotkey.
	if(deref.flHotkey != -1 && pSeatLocal->m_inputKeyDown == deref.flHotkey){
		(*arg_someBtn).funOnClick_Base();
		pSeatLocal->m_inputKeyDown = 0;
		return TRUE;
	}
	
	return FALSE;
}// checkBuyMenuButtonHotKeyPressed



void
UI_BuyMenu_OnMouseClick(void)
{
	int i2;
	// Generate the button bounds to be checked on each click call.
	vector vButtonPos = [video_mins[0] + 5, video_mins[1] + video_res[1]/2, 0];
	vector vBtnPos = [0,0,0];
	int btnToRender_index_global;
	CBuyMenu_BasicButton previousLayerButton;
	
	if(iActiveLayer == 0){
		vBtnPos.x = (int)vButtonPos.x; //default pos.
		vBtnPos.y = (int)vButtonPos.y;
		
		for(i2 = 0i; i2 < ary_layerFirstButton_softLength; i2++){			
			checkBuyMenuButtonClicked(ary_layerFirstButton[i2], vBtnPos, vButtonSizStandard);
			vBtnPos.y += (vButtonSizStandard.y + 1);
		}
		
	}else{
		vBtnPos.x = (int)vButtonPos.x + (vButtonSizStandard.x + 1) * iActiveLayer;
		vBtnPos.y = (int)vButtonPos.y;
		// All other layers only render buttons that the previous layer (selected button there) tells them to.
		
		previousLayerButton = *ary_layerButtonChoice[iActiveLayer - 1i];
		
		for(i2 = 0i; i2 < previousLayerButton.ary_btn_softLength; i2 = i2+1i){
			
			// CONCLUSION
			// So much as this local var, "btnCheck", being set to a dereferenced
			// ary_btnTotal element, and this btnCheck being used in
			// checkBuyMenubuttonClicked instead of just that ary_btnTotal element
			// (a pointer already) is enough to trigger this odd error, where the next
			// frame (or if this for loop gets so much as an extra iteration that resets
			// btnCheck... test with the "if(theThingHappened)continue;" bit above moved
			// to after these lines below too...
			// Anyways, this makes the difference between whether the real thing the
			// ary_btnTotal element links to stays consistent between at least loop
			// iterations or not even those.  Staying consistent between frames is
			// definitely out.
			// When this method ends, or really this scope (?), that thing the
			// ary_btnTotal element is pointing at blanks out.
			
			btnToRender_index_global = previousLayerButton.ary_btn_index[i2];
			
			CBuyMenu_BasicButton tempButton2 = *ary_btnTotal[btnToRender_index_global];
			if(tempButton2.bActive == FALSE){
				// let the next button be tried instead.
				continue;
			}
			
			// NOT THIS WAY (causes the odd problem):
			//if(checkBuyMenuButtonClicked(&btnCheck, vBtnPos, vButtonSizStandard)){
			if(checkBuyMenuButtonClicked(ary_btnTotal[btnToRender_index_global], vBtnPos, vButtonSizStandard)){
				// nothing special happens if so, checkBuyMenuButtonClicked handles this fine.
			}
			
			vBtnPos.y += (vButtonSizStandard.y + 1);
		}// for i2 in this layer's buttons.
	}
	
	// Check the "0. Cancel" button.
	checkBuyMenuButtonClicked(&buymenu_btn_Back, vBtnPos, vButtonSizStandard);
	// no point on bumping Y, end of method
	//vBtnPos.y += (vButtonSizStandard.y + 1);
}// UI_BuyMenu_OnMouseClick


// Check for the hotkey of any buttons in existence instead.
// No need to involve button bounds for that
void
UI_BuyMenu_OnKeyDown(void)
{
	int i2;
	int btnToRender_index_global;
	CBuyMenu_BasicButton previousLayerButton;
	
	if(iActiveLayer == 0){		
		for(i2 = 0i; i2 < ary_layerFirstButton_softLength; i2++){
			checkBuyMenuButtonHotKeyPressed(ary_layerFirstButton[i2]);
		}
	}else{
		// All other layers only render buttons that the previous layer (selected button there) tells them to.
		previousLayerButton = *ary_layerButtonChoice[iActiveLayer - 1i];
		
		for(i2 = 0i; i2 < previousLayerButton.ary_btn_softLength; i2 = i2+1i){
			btnToRender_index_global = previousLayerButton.ary_btn_index[i2];
			
			CBuyMenu_BasicButton tempButton2 = *ary_btnTotal[btnToRender_index_global];
			if(tempButton2.bActive == FALSE){
				// let the next button be tried instead.
				continue;
			}
			
			checkBuyMenuButtonHotKeyPressed(ary_btnTotal[btnToRender_index_global]);
		}// for i2 in this layer's buttons.
	}
	
	// Check the "0. Cancel" button.
	checkBuyMenuButtonHotKeyPressed(&buymenu_btn_Back);
}//UI_BuyMenu_OnKeyDown



// For "_this" button, add "arg_other" to its list of buttons (ary_btn) to be shown when this button
// is clicked.
// Also, so much as adding a button to another's list will bump the other button's "iLayer" by 1
// past the button it's being linked to.
// So NEVER add one button to two different layers, or at least set the layer manually to be correct
// (and match between the two parents, which should be parentButton+1).
// "iLayer" will be handled naturally just fine otherwise.
void
buymenu_addbutton(CBuyMenu_BasicButton* _this, CBuyMenu_BasicButton* arg_other)
{

	CBuyMenu_BasicButton _this_deref = *_this;
	CBuyMenu_BasicButton arg_other_deref = *arg_other;

	if(_this_deref.ary_btn_softLength < 16i){
		//proceed.
		int nextButtonSlot = _this_deref.ary_btn_softLength;
		
		//I am the number "i" child of the parent. Useful for telling what button from the previous layer
		//was selected.
		
		//_this.ary_btn[nextButtonSlot] = arg_other;
		_this_deref.ary_btn_index[nextButtonSlot] = arg_other_deref.iGlobalIndex;
		
		_this_deref.ary_btn_softLength += 1i;  //increase the number of buttons I link to by 1.
		// arg_other_deref.iLayer = _this_deref.iLayer + 1i;  //This "other" button is one layer deeper
		// than the parent.
		
	}
	
}//buymenu_addbutton



void
buymenu_addbuttonToTotal(CBuyMenu_BasicButton* _this)
{
	
	if(ary_btnTotal_softLength >= ary_btnTotal.length){
		//ERROR!
		print(sprintf("!!! CLIENT ERROR. Button max of %i reached, button not added! Report this!\n", ary_btnTotal.length) );
		return;
	}
	
	CBuyMenu_BasicButton _this_deref = *_this;
	
	//localcmd(sprintf("echo addButtonToTotal: IM %s AND MY ID IS %i\n", _this.sName, ary_btnTotal_softLength));
	
	_this_deref.iGlobalIndex = ary_btnTotal_softLength;
	ary_btnTotal[ary_btnTotal_softLength] = _this;
	ary_btnTotal_softLength = ary_btnTotal_softLength + 1i;
	
}//buymenu_addbutton

void
buymenu_addbuttonToFirstLayer(CBuyMenu_BasicButton* _this)
{
	
	if(ary_layerFirstButton_softLength >= ary_layerFirstButton.length){
		//ERROR!
		print(sprintf("!!! CLIENT ERROR. First layer button max of %i reached, button not added! Report this!\n", ary_layerFirstButton.length) );
		return;
	}
	
	ary_layerFirstButton[ary_layerFirstButton_softLength] = _this;
	ary_layerFirstButton_softLength = ary_layerFirstButton_softLength + 1i;
	
}//buymenu_addbuttonToFirstLayer



//!!! SEND THE iGlobalIndex.
// Method that actually draws the button.
// Made separate from button's onRender methods so that this can be called with a different color conveniently
// (red for "can't afford this" at a glance)
void
drawBuyButton(
	int arg_iGlobalIndex, string arg_text, vector arg_suggestedDrawPos, int arg_iLayer,
	int arg_iButtonRow, BOOL arg_fIsSelected, vector arg_clr
)
{
	vector arg_buttonPos = arg_suggestedDrawPos;
	
	float arg_opac;
	if(arg_fIsSelected || arg_iLayer == iActiveLayer){
		arg_opac = 0.96;
	}else{
		arg_opac = 0.71;
	}
	
	vector vLabelPos;
	BOOL mouseHovered = FALSE;
	
	// Draw the button label
	vLabelPos[0] = arg_buttonPos[0] + LABEL_OFFSET_X;
	vLabelPos[1] = arg_buttonPos[1] + LABEL_OFFSET_Y;
	
	if(arg_iGlobalIndex == iHoveredButtonIndex){
		//This button is the chosen one!!!
		mouseHovered = TRUE;
	}
	
	//iActiveLayer == iLayer && 
	if(mouseHovered){
		// Draw the background
		drawfill( arg_buttonPos, vButtonSizStandard, arg_clr * 0.93f, arg_opac - 0.60f, DRAWFLAG_NORMAL );
		
		Gfx_Text( vLabelPos, arg_text, vButtonFontSize, arg_clr * 0.98f, (1.0f-(1.0f - arg_opac)*0.88) - 0.02f, DRAWFLAG_NORMAL, FONT_ARIAL_STD );
		//return TRUE;
	}else{
		// Draw the background
		drawfill( arg_buttonPos, vButtonSizStandard, arg_clr * 0.86, arg_opac - 0.70f, DRAWFLAG_NORMAL );

		Gfx_Text( vLabelPos, arg_text, vButtonFontSize, arg_clr * 0.94f, (1.0f-(1.0f - arg_opac)*0.88) - 0.06f, DRAWFLAG_NORMAL, FONT_ARIAL_STD );
	}
	
}// drawBuyButton



void
setActiveLayerButton(CBuyMenu_BasicButton* arg_someButton)
{
	ary_layerButtonChoice[iActiveLayer] = arg_someButton;
}

void
CBuyMenu_BasicButton::CBuyMenu_BasicButton(void)
{
	iType = BUTTON_TYPEID_BASIC;
	bActive = TRUE;
	funOnClick_Custom = NULL;
	funOnShow_Custom = NULL;
}
void
CBuyMenu_BasicButton::setThisPointer(CBuyMenu_BasicButton* arg_this)
{
	_this = arg_this;
}
void
CBuyMenu_BasicButton::create(
	string arg_sName, float arg_flHotkey, vector arg_clr,
	void(CBuyMenu_BasicButton* arg_this) arg_funOnClick_Custom
){
	sName = arg_sName;
	
	flHotkey = arg_flHotkey;
	clr = arg_clr;
	clr_render = arg_clr; //good default.
	
	funOnClick_Custom = arg_funOnClick_Custom; //(int*)&arg_funOnClick_Custom;
	funOnShow_Custom = NULL;
}//create


void
CBuyMenu_BasicButton::funOnRender_Base
(
	vector arg_suggestedDrawPos, int arg_iLayer, int arg_iButtonRow, BOOL arg_fIsSelected
)
{
	drawBuyButton(this.iGlobalIndex, this.sName, arg_suggestedDrawPos, arg_iLayer, arg_iButtonRow, arg_fIsSelected, this.clr_render);
}//funOnRender_Base



void
CBuyMenu_BasicButton::funOnShow_Base(void)
{
	
	if(funOnShow_Custom != NULL){
		//void(CBuyMenu_BasicButton* arg_this)* tempRef = funOnShow_Custom;
		//(*tempRef)(_this);
		funOnShow_Custom(_this);
	}
	
}// funOnShow_Base


// When this button is clicked, what does it do?
void
CBuyMenu_BasicButton::funOnClick_Base(void)
{
	
	// basic button behavior. Only if our array has a non-zero length.
	// Buttons of zero length don't unwrap into new buttons and can do something special,
	// like go up a layer instead ("cancel"), something about configs, or buy a
	// weapon/accessory.
	if( ary_btn_softLength != 0i){
		
		// "this"... is not already a pointer??!  WHAT HERESY BEFALLS MY EYES?!!!
		// nah just kidding, makes sense for QuakeC.
		// setActiveLayerButton(&this);
		ary_layerButtonChoice[iActiveLayer] = _this;
		
		// "warning F307: type mismatch: CBuyMenu_BasicButton * _this to
		// CBuyMenu_BasicButton *[ary_layerButtonChoice]"
		// ...????? happens if using CBuyMenu_BasicButton pointers (*) in _this above
		// and the array "ary_layerButtonChoice".
		iActiveLayer = iActiveLayer + 1i;
		
		// Also: go through each button that I'm going to show and set its "bAtive" to TRUE
		// (all buttons like weapon upgrades are visible
		// unless purchased in that showing of the weapon).  And call each one's "funOnShow"
		// since there may be some logic such as
		// coloring the text red if the player can't afford that upgrade or weapon (in the
		// case of entire weapons by name buttons too).
		for(int i = 0; i < ary_btn_softLength; i++){
			int nextButtonIndex = ary_btn_index[i];
			CBuyMenu_BasicButton someButton = *ary_btnTotal[nextButtonIndex];
			if(someButton.iType == BUTTON_TYPEID_WEAPON){
				CBuyMenu_WeaponButton someButto = *((CBuyMenu_WeaponButton*)ary_btnTotal[nextButtonIndex]);
				someButto.bActive = TRUE;
				someButto.funOnShow_Base();
			}else{
				someButton.bActive = TRUE;
				someButton.funOnShow_Base();
			}
		}
		
	}// button length check
	
	if(funOnClick_Custom != NULL){
		// If we have a custom click method, do it.
		//void(CBuyMenu_BasicButton* arg_this)* tempRef = funOnClick_Custom;
		//(*tempRef)(_this);
		funOnClick_Custom(_this);
	}
	
	//Regardless, most buttons are bound to change the current layer and
	//possibly what the Cancel/Go Back button says (one of those two).
	buymenu_btn_Back_updateText();
	
}//funOnClick_Base


void
CBuyMenu_WeaponButton::CBuyMenu_WeaponButton(void)
{
	// is chaining constructors ok here? No need!  Done implicitly.
	bActive = TRUE;
	iWeaponPurchaseID = -1; //default
}
void
CBuyMenu_WeaponButton::create_WeaponButton
(
	string arg_sName, float arg_flHotkey, vector arg_clr,
	void(CBuyMenu_BasicButton* arg_this) arg_funOnClick_Custom,
	string arg_sWeaponImagePath, int arg_iWeaponPrice, int arg_iWeaponSlots,
	int arg_iBitsWeaponOpt
){
	
	//defaults.
	//_this_deref.iLayer = 0i;
	ary_btn_softLength = 0i;
	
	
	sName = arg_sName;
	
	flHotkey = arg_flHotkey;
	clr = arg_clr;
	clr_render = arg_clr; //good default.
	
	funOnClick_Custom = arg_funOnClick_Custom; //(int*)&arg_funOnClick_Custom;
	funOnShow_Custom = NULL; //paranoia?
	
	// Why do we add "_0.tga" to a .spr reference for the draw to work?
	// The world may never know.
	sWeaponImagePath = sprintf("%s_0.tga", arg_sWeaponImagePath);
	
	iWeaponPrice = arg_iWeaponPrice;
	iWeaponSlots = arg_iWeaponSlots;
	
	iBitsWeaponOpt = arg_iBitsWeaponOpt;
	
	//Use that flag to determine what butttons to give me.
	
	iType = BUTTON_TYPEID_WEAPON;
	
	//Only add subbuttons (buy, upgrades, etc.) if this lacks the INSTANT option.
	if( !(iBitsWeaponOpt & BITS_WEAPONOPT_INSTANT)){
		
		//Every weapon has at least a "Buy" button.
		buymenu_addbutton(_this, &buymenu_btn_WeaponOpt_Buy);
			
		if(iBitsWeaponOpt & BITS_WEAPONOPT_SILENCER){
			buymenu_addbutton(_this, &buymenu_btn_WeaponOpt_Silencer);
		}
		if(iBitsWeaponOpt & BITS_WEAPONOPT_LASERSIGHT){
			buymenu_addbutton(_this, &buymenu_btn_WeaponOpt_Lasersight);
		}
		if(iBitsWeaponOpt & BITS_WEAPONOPT_FLASHLIGHT){
			buymenu_addbutton(_this, &buymenu_btn_WeaponOpt_Flashlight);
		}
		if(iBitsWeaponOpt & BITS_WEAPONOPT_SCOPE){
			buymenu_addbutton(_this, &buymenu_btn_WeaponOpt_Scope);
		}
		if(iBitsWeaponOpt & BITS_WEAPONOPT_AKIMBO){
			buymenu_addbutton(_this, &buymenu_btn_WeaponOpt_Akimbo);
		}
		if(iBitsWeaponOpt & BITS_WEAPONOPT_FULLLOAD){
			buymenu_addbutton(_this, &buymenu_btn_WeaponOpt_FullLoad);
		}
	}//BITS_WEAPONOPT_INSTANT check
	
}//create_WeaponButton
	
	
void
CBuyMenu_WeaponButton::funOnRender_Base
(
	vector arg_suggestedDrawPos, int arg_iLayer, int arg_iButtonRow,
	BOOL arg_fIsSelected
)
{
	CBuyMenu_BasicButton::funOnRender_Base(
		arg_suggestedDrawPos, arg_iLayer, arg_iButtonRow, arg_fIsSelected
	); //call the parent's.
	
	// I want to draw my sWeaponImagePath above myself.
	if(arg_fIsSelected && !(iBitsWeaponOpt & BITS_WEAPONOPT_INSTANT)  ){
	
		vector arg_buttonPos = [
			video_mins[0] + 5 +
			arg_iLayer * (vButtonSizStandard.x + 1), video_mins[1] + video_res[1]/2 + arg_iButtonRow * (vButtonSizStandard.y + 1)
		];
		
		float arg_opac;
		if(arg_fIsSelected || arg_iLayer == iActiveLayer){
			arg_opac = 0.96;
		}else{
			arg_opac = 0.71;
		}
		
		vector textDrawOrigin = [arg_suggestedDrawPos.x + LABEL_OFFSET_X + 128, (video_res[1]/2) + LABEL_OFFSET_Y - (48 + 1)];
	
		// NOTICE - draw on top of all buttons on this row unconditionally. Don't use arg_suggestedDrawPos.y
		drawsubpic([arg_buttonPos.x, (video_res[1]/2) - (48 + 1)], [128,48], sWeaponImagePath, [0,0], [128/128,48/48], clrPaleBlue, 0.96, DRAWFLAG_ADDITIVE);
		
		string drawString1 = sprintf("%i Credits", iWeaponPrice);
		string drawString2 = sprintf("%i Slots", iWeaponSlots);
		
		drawfill( [arg_buttonPos.x, (video_res[1]/2) - (48 + 1)], [256-1, 48], this.clr * 0.93f, arg_opac - 0.60f, DRAWFLAG_NORMAL );
		
		Gfx_Text( textDrawOrigin, drawString1, vButtonFontSize, this.clr * 0.98f, (1.0f-(1.0f - arg_opac)*0.88) - 0.02f, DRAWFLAG_NORMAL, FONT_ARIAL_STD );
		Gfx_Text( [textDrawOrigin.x, textDrawOrigin.y + (vButtonSizStandard.y+1) ], drawString2, vButtonFontSize, this.clr * 0.98f, (1.0f-(1.0f - arg_opac)*0.88) - 0.02f, DRAWFLAG_NORMAL, FONT_ARIAL_STD );
		
	}
}//funOnRender_Base


// convenient way to reset these globals for keeping track of a purchase in progress.
// Leaving the buy screen or getting out of a weapon should reset them.
void
UI_BuyMenu_ResetTempVariables(void)
{
	iWeaponTempID = -1;
	iBitsUpgradeTemp = BITS_WEAPONOPT_NONE;
	iExtraPriceTemp = 0;
	iExtraSlotsTemp = 0;
	iPurchaseCountTemp = 1;
}// UI_BuyMenu_ResetTempVariables


void
CBuyMenu_WeaponButton::funOnShow_Base(void)
{
	CBuyMenu_BasicButton::funOnShow_Base();
	// See if this weapon can be afforded.
	if(canBuyWeapon(iWeaponPurchaseID, 0, 0, 1)){
		clr_render = clr;
	}else{
		// same, but draw it red to show we can't afford it at a glance.
		clr_render = clrRed;
	}
}//funOnShow_Base

void
CBuyMenu_WeaponButton::funOnClick_Base(void)
{
	weapondata_basic_t weaponRef;
	// Just one thing. Let's reset this to be safe (new weapon opened for seeing
	// upgrade choices)
	UI_BuyMenu_ResetTempVariables();
	// and, thie tempCost starts at the value of this weapon as stated.
	if(iWeaponPurchaseID == -1){
		return;
	}
	weaponRef = (*ary_weaponData[iWeaponPurchaseID]);
	if(!(iBitsWeaponOpt & BITS_WEAPONOPT_INSTANT)){
		// normal behavior.
		iWeaponTempID = iWeaponPurchaseID;
		CBuyMenu_BasicButton::funOnClick_Base();
	}else{
		// has the instant flag? that's it, apply it if we can.
		if(canBuyWeapon(iWeaponPurchaseID, 0, 0, 1) ){
			BOOL addSuccess = attemptAddWeaponToConfig(iWeaponPurchaseID, BITS_WEAPONOPT_NONE, 1);
			if(addSuccess){
				//and then go back.
				buymenu_backOneLayer();
				buymenu_btn_Back_updateText();
			}
		}
	}
}//funOnClick_Base


void
buymenu_btn_Back_clicked(CBuyMenu_BasicButton* arg_this)
{
	iWeaponTempID = -1;
	if(iActiveLayer == 0i){
		// This is a request to close the buy menu.
		// TODO. Support that.
		buymenu_cancelConfigAndClose();
	}else{
		buymenu_backOneLayer();
	}
}//buymenu_btn_Back_clicked


void
buymenu_backOneLayer(void)
{
	// In any other layer, this reduces iActiveLayer by 1 to stop drawing the latest
	// layer of buttons. And makes the previous layer accessible again.

	// The button on the previous layer is unselected.  No button on the current
	// active layer can be selected technically; selecting a button does so for that
	// layer and then advances the active layer.
	ary_layerButtonChoice[iActiveLayer - 1] = NULL;
	
	iActiveLayer = iActiveLayer - 1i; //drop a layer.
}//buymenu_backOneLayer


void
buymenu_btn_Back_updateText(void)
{
	if(iActiveLayer == 0i){
		// I will exit the buy menu if hit again.
		buymenu_btn_Back.sName = "0 Cancel";
	}else{
		// Still going to say, "Go Back".
		buymenu_btn_Back.sName = "0 Go Back";
	}
}//buymenu_btn_Back_updateText


// This is for the "Buy" option of any weapon/item in the buy menu, as in within its own
// details.
void
buymenu_btn_Buy_Weapon_clicked(CBuyMenu_BasicButton* arg_this)
{
	if(iWeaponTempID != -1){
		// but how do we get the player from here... oh that actually still works.
		if(canBuyWeapon(iWeaponTempID, iExtraPriceTemp, iExtraSlotsTemp, iPurchaseCountTemp)){
			BOOL addResult = attemptAddWeaponToConfig(iWeaponTempID, iBitsUpgradeTemp, iPurchaseCountTemp);
			if(addResult){
				// went ok. back out of this.
				buymenu_backOneLayer();
				buymenu_backOneLayer();
			}
		}
		refreshButtons();
	}
}//buymenu_btn_Buy_Weapon_clicked


void
setupRemoveButtonList(void)
{
	for(int i = 0; i < ary_myWeapons_length; i++){
		ary_btn_removeButton[i] = spawn(CBuyMenu_RemoveWeaponButton);
		
		// basic init without the ".create" call.  That gives the button its actual properties,
		// which will change as things are deleted or the "Remove Items" button is returned to.
		ary_btn_removeButton[i].setThisPointer(&ary_btn_removeButton[i]);
		buymenu_addbuttonToTotal(&ary_btn_removeButton[i]);
		buymenu_addbutton(&buymenu_btn_RemoveItem, &ary_btn_removeButton[i]);
	}
}// setupRemoveButtonList

	
void
buymenu_btn_removeButton_clicked(CBuyMenu_BasicButton* arg_this)
{
	CBuyMenu_RemoveWeaponButton removeWeaponButtonRef = *( (CBuyMenu_RemoveWeaponButton*)arg_this );
	removeWeaponFromConfig(removeWeaponButtonRef.linkedConfigIndex);
	//and refresh this area.
	buymenu_btn_RemoveItem_clicked(&buymenu_btn_RemoveItem);
}


void
buymenu_btn_RemoveItem_clicked(CBuyMenu_BasicButton* arg_this)
{
	int i;
	// FIRST, set each "ary_myWeapons_length" to be invisible.
	// Don't get rendered / be clickable unless actually linked to a weapon in the
	// player's inventory.
	// (well this config really)
	for(i = 0; i < ary_myWeapons_length; i++){
		ary_btn_removeButton[i].bActive = FALSE;
	}
	
	// Get the list of all items in the player's inventory.
	// Make one button active / set up to delete that item when clicked.
	for(i = 0; i < pSeatLocal->m_clientinfo.weaponconfig_temp.ary_myWeapons_softMax; i++){
		weaponconfig_weapon_t* thisWeapo = &pSeatLocal->m_clientinfo.weaponconfig_temp.ary_myWeapons[i];
		
		weapondata_basic_t* basicPointer = (weapondata_basic_t*) ary_weaponData[thisWeapo->weaponID];
		weapondata_basic_t basicRef = *(basicPointer);
		
		string buttonDisplayText;
		int hotKeyCode;
		if(i < 9)
		{
			//for i choices 0 through 8, use "i+1" to give 1-9.
			buttonDisplayText = sprintf("%i: %s", (i+1i), basicRef.sDisplayName);
			hotKeyCode = 48+(i+1);  // '0' + (i+1)
		}
		else if(i < 9+26)
		{
			//now pick letters of the alphabet for the rest.
			//uhhh. I don't know how to work with characters as a type or with ASCII values, so 
			//we'll just use this array of letters in the alphabet.
			buttonDisplayText = sprintf("%s: %s", chr2str((float)i+65), basicRef.sDisplayName);
			hotKeyCode = 97+(i-9);  // 'a' + (i-9)
		}else{
			// surpass that range?  Not possible!
			// In case it somehow is, refuse to generate any more remove buttons.
			return;
		}
		
		//INITIALIZE_BASICBUTTON(ary_btn_removeButton[i], "7 Buy Random", 48+7,clrGreen, NULL)
		ary_btn_removeButton[i].create(buttonDisplayText, hotKeyCode, clrPaleBlue, buymenu_btn_removeButton_clicked);
		ary_btn_removeButton[i].bActive = TRUE;
		
		//CBuyMenu_RemoveWeaponButton removeWeaponButtonRef2 = (CBuyMenu_RemoveWeaponButton)ary_btn_removeButton[i];
		//removeWeaponButtonRef2.linkedConfigIndex = i;
		ary_btn_removeButton[i].linkedConfigIndex = i;
			
		
	}// for everything in the player's inventory
	
}// buymenu_btn_RemoveItem_clicked



// Take all buttons and call their "funOnShow". See what we can and can't afford
// (color red when we can't).  funOnShow should handle this appropriately per button.
void
refreshButtons(void)
{
	int i;
	int i2;
	CBuyMenu_BasicButton previousLayerButton;
	CBuyMenu_BasicButton tempButton;
	
	for(i = 0; i <= iActiveLayer; i++){
		if(i == 0){
			//CBuyMenu_BasicButton tempButton = *ary_layerFirstButton[i2];
			for(i2 = 0; i2 < ary_layerFirstButton_softLength; i2++){
				tempButton = *ary_layerFirstButton[i2];
				tempButton.funOnShow_Base();
			}// for i2 in ary_layerFirstButton
				
		}else{
			previousLayerButton = *ary_layerButtonChoice[i - 1i];
			
			for(i2 = 0i; i2 < previousLayerButton.ary_btn_softLength; i2 = i2+1i){				
				//btnToRender = &previousLayerButton.ary_btn[i2];
				int btnToRender_index_global = previousLayerButton.ary_btn_index[i2];
				tempButton = *ary_btnTotal[btnToRender_index_global];
				tempButton.funOnShow_Base();
			}
		}
	}
	
}//refreshButtons




// NOTICE - assumes "Cancel" was clicked. Reverts "temp" config to the "current"
// config (one last saved / applied).
void
buymenu_cancelConfigAndClose(void)
{
	//other way around.  Copy what's at the current to the temp (forgetting any purchase changes).
	
	weaponconfig_data_t* tempWeaponConfig = &pSeatLocal->m_clientinfo.weaponconfig_temp;
	weaponconfig_data_t* currentWeaponConfig = &pSeatLocal->m_clientinfo.weaponconfig_current;
	
	//copyConfig(pSeatLocal->m_clientinfo.weaponconfig_temp, pSeatLocal->m_clientinfo.weaponconfig_current);
	copyConfig(tempWeaponConfig, currentWeaponConfig);
	
	
	if(boughtAnything){
		CSQC_Parse_CenterPrint("Buy Order Canceled.\n");
	}
	
	UI_ChangeScreen(UI_SCREEN::NONE);
}//buymenu_cancelConfigAndClose

// This is the "1 Use New Config" choice in the 1st layer. Applies the config (copies weaponconfig_temp to weapconfig_current).
// the "_current" one is read at spawn to give the player their loadout.
void
buymenu_btn_UseNewConfig_clicked(CBuyMenu_BasicButton* arg_this)
{
	//weaponconfig_data_t
	
	weaponconfig_data_t* tempWeaponConfig = &pSeatLocal->m_clientinfo.weaponconfig_temp;
	weaponconfig_data_t* currentWeaponConfig = &pSeatLocal->m_clientinfo.weaponconfig_current;
	
	//Player wants to apply everything from the currentConfig to tempConfig.
	copyConfig(currentWeaponConfig, tempWeaponConfig);
	
	// TODO - check to see whether the config we just used was empty or not, to affect this message...
	CSQC_Parse_CenterPrint("Using new config.\n");
	
	UI_ChangeScreen(UI_SCREEN::NONE);
}//buymenu_btn_UseNewConfig_clicked
	

void
buymenu_btn_Buy_onShow(CBuyMenu_BasicButton* arg_this)
{
	CBuyMenu_BasicButton thisTemp = *arg_this;
	
	// uhhh.  Why did I do this again?  Clarity?
	int arg_extraPrice = 0;
	int arg_extraSlots = 0;
	
	int finalExtraPrice = iExtraPriceTemp + arg_extraPrice;
	int finalExtraSlots = arg_extraSlots;
	
	weapondata_basic_t weaponRef = *( (weapondata_basic_t*) ary_weaponData[iWeaponTempID]);

	if(canBuyWeapon(iWeaponTempID, finalExtraPrice, finalExtraSlots, 1)){
		thisTemp.clr_render = thisTemp.clr;
	}else{
		thisTemp.clr_render = clrRed;
	}
}


void
buymenu_btn_Silencer_onShow(CBuyMenu_BasicButton* arg_this)
{
	CBuyMenu_BasicButton thisTemp = *arg_this;
	// See if this buyopt's additional cost can be afforded.
	if(canBuyWeapon(iWeaponTempID, iExtraPriceTemp + WEAPONOPT_SILENCER_COST, 0, 1)){
		thisTemp.clr_render = thisTemp.clr;
	}else{
		thisTemp.clr_render = clrRed;
	}
}

void
buymenu_btn_Lasersight_onShow(CBuyMenu_BasicButton* arg_this)
{
	CBuyMenu_BasicButton thisTemp = *arg_this;
	if(canBuyWeapon(iWeaponTempID, iExtraPriceTemp + WEAPONOPT_LASERSIGHT_COST, 0, 1)){
		thisTemp.clr_render = thisTemp.clr;
	}else{
		thisTemp.clr_render = clrRed;
	}
}

void
buymenu_btn_Flashlight_onShow(CBuyMenu_BasicButton* arg_this)
{
	CBuyMenu_BasicButton thisTemp = *arg_this;
	if(canBuyWeapon(iWeaponTempID, iExtraPriceTemp + WEAPONOPT_FLASHLIGHT_COST, 0, 1)){
		thisTemp.clr_render = thisTemp.clr;
	}else{
		thisTemp.clr_render = clrRed;
	}
}

void
buymenu_btn_Scope_onShow(CBuyMenu_BasicButton* arg_this)
{
	CBuyMenu_BasicButton thisTemp = *arg_this;
	if(canBuyWeapon(iWeaponTempID, iExtraPriceTemp + WEAPONOPT_SCOPE_COST, 0, 1)){
		thisTemp.clr_render = thisTemp.clr;
	}else{
		thisTemp.clr_render = clrRed;
	}
}

void
buymenu_btn_Akimbo_onShow(CBuyMenu_BasicButton* arg_this)
{
	CBuyMenu_BasicButton thisTemp = *arg_this;
	
	//Can we afford one more copy of this weapon?
	weapondata_basic_t weaponRef = (*ary_weaponData[iWeaponTempID]);
	
	if(canBuyWeapon(iWeaponTempID, iExtraPriceTemp + weaponRef.iPrice, iExtraSlotsTemp + weaponRef.iSlots, iPurchaseCountTemp)){
		thisTemp.clr_render = thisTemp.clr;
	}else{
		thisTemp.clr_render = clrRed;
	}
}

void
buymenu_btn_FullLoad_onShow(CBuyMenu_BasicButton* arg_this)
{
	CBuyMenu_BasicButton thisTemp = *arg_this;
	//I'm not copying and pasting this stuff all over the place.
	int buyCount = fullLoadCountToBuy(iWeaponTempID);
	if(buyCount >= 0){
		weapondata_basic_t weaponRef = (*ary_weaponData[iWeaponTempID]);
		
		int testPrice = (buyCount) * weaponRef.iPrice;
		int testSlots = (buyCount) * weaponRef.iSlots;
		if(canBuyWeapon(iWeaponTempID, iExtraPriceTemp + testPrice, iExtraSlotsTemp + testSlots, iPurchaseCountTemp)){
			thisTemp.clr_render = thisTemp.clr;
		}else{
			thisTemp.clr_render = clrRed;
		}
		
	}else{
		//assume there is nothing else to buy?
		thisTemp.clr_render = thisTemp.clr;
	}
}//buymenu_btn_FullLoad_clicked


void
buymenu_btn_Silencer_clicked(CBuyMenu_BasicButton* arg_this)
{
	if(canBuyWeapon(iWeaponTempID, iExtraPriceTemp + WEAPONOPT_SILENCER_COST, iExtraSlotsTemp, iPurchaseCountTemp)){
		CBuyMenu_BasicButton thisTemp = *arg_this;
		//allow it and hide this button.
		iBitsUpgradeTemp |= BITS_WEAPONOPT_SILENCER;
		iExtraPriceTemp += WEAPONOPT_SILENCER_COST;
		thisTemp.bActive = FALSE;
		refreshButtons();
	}
}

void
buymenu_btn_Lasersight_clicked(CBuyMenu_BasicButton* arg_this)
{
	
	if(canBuyWeapon(iWeaponTempID, iExtraPriceTemp + WEAPONOPT_LASERSIGHT_COST, iExtraSlotsTemp, iPurchaseCountTemp)){
		CBuyMenu_BasicButton thisTemp = *arg_this;
		//allow it and hide this button.
		iBitsUpgradeTemp |= BITS_WEAPONOPT_LASERSIGHT;
		iExtraPriceTemp += WEAPONOPT_LASERSIGHT_COST;
		thisTemp.bActive = FALSE;
		refreshButtons();
	}
}

void
buymenu_btn_Flashlight_clicked(CBuyMenu_BasicButton* arg_this)
{
	
	if(canBuyWeapon(iWeaponTempID, iExtraPriceTemp + WEAPONOPT_FLASHLIGHT_COST, iExtraSlotsTemp, iPurchaseCountTemp)){
		CBuyMenu_BasicButton thisTemp = *arg_this;
		// allow it and hide this button.
		iBitsUpgradeTemp |= BITS_WEAPONOPT_FLASHLIGHT;
		iExtraPriceTemp += WEAPONOPT_FLASHLIGHT_COST;
		thisTemp.bActive = FALSE;
		refreshButtons();
	}
}

void
buymenu_btn_Scope_clicked(CBuyMenu_BasicButton* arg_this)
{
	if(canBuyWeapon(iWeaponTempID, iExtraPriceTemp + WEAPONOPT_SCOPE_COST, iExtraSlotsTemp, iPurchaseCountTemp)){
		CBuyMenu_BasicButton thisTemp = *arg_this;
		// allow it and hide this button.
		iBitsUpgradeTemp |= BITS_WEAPONOPT_SCOPE;
		iExtraPriceTemp += WEAPONOPT_SCOPE_COST;
		thisTemp.bActive = FALSE;
		refreshButtons();
	}
}
void
buymenu_btn_Akimbo_clicked(CBuyMenu_BasicButton* arg_this)
{
	// Can we afford one more copy of this weapon?
	weapondata_basic_t weaponRef = (*ary_weaponData[iWeaponTempID]);
	
	if(canBuyWeapon(iWeaponTempID, iExtraPriceTemp + weaponRef.iPrice, iExtraSlotsTemp + weaponRef.iSlots, iPurchaseCountTemp)){
		CBuyMenu_BasicButton thisTemp = *arg_this;
		// allow it and hide this button.
		iBitsUpgradeTemp |= BITS_WEAPONOPT_AKIMBO;
		iExtraPriceTemp += weaponRef.iPrice;
		iExtraSlotsTemp += weaponRef.iSlots;
		thisTemp.bActive = FALSE;
		refreshButtons();
	}
}

// NOTICE
// Buying 'full load', even if we can't afford to fill this throwable to the max,
// still works if we can afford at least one more.
// This method checks to see the least that can be afforded between price, slots,
// and max count allowed for this weapon type, and uses that + closes the picked 
// weapon in the buymenu if a purchase is made.
// "Full Load" is for throwables only.  Counting grenades as that type too.
void
buymenu_btn_FullLoad_clicked(CBuyMenu_BasicButton* arg_this)
{
	// I'm not copying and pasting this stuff all over the place.
	int buyCount = fullLoadCountToBuy(iWeaponTempID);
	
	if(buyCount >= 0){
		CBuyMenu_BasicButton thisTemp;
		weapondata_basic_t weaponRef = (*ary_weaponData[iWeaponTempID]);
		
		int testPrice = (buyCount) * weaponRef.iPrice;
		int testSlots = (buyCount) * weaponRef.iSlots;
		
		int finalExtraPrice = iExtraPriceTemp + testPrice;
		int finalExtraSlots = iExtraSlotsTemp + testSlots;
		
		if(canBuyWeapon(iWeaponTempID, finalExtraPrice, finalExtraSlots, iPurchaseCountTemp)){
			thisTemp = *arg_this;
			// allow it and hide this button.
			iBitsUpgradeTemp |= BITS_WEAPONOPT_FULLLOAD;
			iExtraPriceTemp += testPrice;
			iExtraSlotsTemp += testSlots;
			thisTemp.bActive = FALSE;
			
			// Go ahead and buy this now.
			buymenu_btn_Buy_Weapon_clicked((CBuyMenu_BasicButton*)&buymenu_btn_WeaponOpt_Buy);
			
			refreshButtons();
		}else{
			// Couldn't afford the full load?
			// How many throwables can I buy, given slot and (possible) money constraints?
			int iSlotsAvailable = RULE_SLOTS_ALLOWED - (CONFIG_PLAYER_TOTALSLOTS + iExtraSlotsTemp);
			int iMoneyAvailable;
			if(RULE_MONEY_ALLOWED){
				iMoneyAvailable = CONFIG_PLAYER_MONEY - (CONFIG_PLAYER_TOTALCOST + iExtraPriceTemp);
			}else{
				// signal that money is not something to worry about
				iMoneyAvailable = -1;
			}
	
			int numberAfforded = determineThrowableBuyCount(iWeaponTempID, iSlotsAvailable, iMoneyAvailable);
			
			if(numberAfforded > 0){
				//do something!
				thisTemp = *arg_this;
				//iBitsUpgradeTemp |= BITS_WEAPONOPT_FULLLOAD;
				iPurchaseCountTemp = numberAfforded;
				// no need for extra price/slot stuff!  We'll make that from that
				// altered 'iPurchaseCountTemp'.
				// That is ever rarely anything besides '1'. Except for this case of
				// course.
				thisTemp.bActive = FALSE;
				buymenu_btn_Buy_Weapon_clicked( (CBuyMenu_BasicButton*) &buymenu_btn_WeaponOpt_Buy);
			
				refreshButtons();
			}
		}
		
	}
}//buymenu_btn_FullLoad_clicked


void
UI_BuyMenu_Show(void)
{
	// safety.
	UI_BuyMenu_ResetTempVariables();
	
	// haven't yet.
	boughtAnything = FALSE;
	
	iActiveLayer = 0i;
	buymenu_btn_Back_updateText();
	
	// just in case?
	for(int i = 0i; i < ary_layerButtonChoice.length; i+=1i){
		ary_layerButtonChoice[i] = NULL;
	}
}

void
UI_BuyMenu_Hide(void)
{
	// nothing to do
}

void
UI_BuyMenu_Init(void)
{
	// for macros below.
	float flDeterminedHotkey;
	
	ary_btnTotal_softLength = 0i;
	ary_layerFirstButton_softLength = 0i;
	
	// buymenu_btn_Back = spawn(CBuyMenu_BasicButton);
	// if the 1st layer is active (drawn to that one). Says "Cancel" there, but if on any deeper layer it reads "Go Back".
	//buymenu_btn_Back.create("0 Cancel", 48, NULL, buymenu_btn_Back_clicked);
	
	INITIALIZE_BASICBUTTON(Back, "Cancel", "0", clrPaleBluePurple, buymenu_btn_Back_clicked)
	
	//INITIALIZE_BASICBUTTON(Buy, "2 Buy", 48+2, NULL, 0, NULL)
	INITIALIZE_BASICBUTTON(Recentconfig, "Use New Config", "1", clrGreen, buymenu_btn_UseNewConfig_clicked)
	INITIALIZE_BASICBUTTON(Buy, "Buy", "2", clrPaleBlue, NULL)
	INITIALIZE_BASICBUTTON(RemoveItem, "Remove Item", "3", clrPaleBlue, buymenu_btn_RemoveItem_clicked)
	INITIALIZE_BASICBUTTON(ResetConfig, "Reset Config", "4", clrPaleBlue, NULL)
	INITIALIZE_BASICBUTTON(SaveConfig, "Save Config", "5", clrPaleBlue, NULL)
	INITIALIZE_BASICBUTTON(LoadConfig, "Load Config", "6", clrPaleBlue, NULL)
	INITIALIZE_BASICBUTTON(BuyRandom, "Buy Random", "7", clrGreen, NULL)
	INITIALIZE_BASICBUTTON(Buy_Handguns, "Handguns", "1", clrPaleBlue, NULL)
	INITIALIZE_BASICBUTTON(Buy_SMGs, "SMGs", "2", clrPaleBlue, NULL)
	INITIALIZE_BASICBUTTON(Buy_Rifles, "Rifles", "3", clrPaleBlue, NULL)
	INITIALIZE_BASICBUTTON(Buy_Shotguns, "Shotguns", "4", clrPaleBlue, NULL)
	INITIALIZE_BASICBUTTON(Buy_SpecialPurpose, "Special Purpose", "5", clrPaleBlue, NULL)
	
	
	// !!! INITIALIZE THE WEAPON-UPGRADE BUTTONS BEFORE THE WEAPONS THEMSELVES. Or else these will be missing at that point.
	INITIALIZE_BASICBUTTON(WeaponOpt_Buy, "Buy", "1", clrGreen, buymenu_btn_Buy_Weapon_clicked)
	INITIALIZE_BASICBUTTON(WeaponOpt_Silencer, sprintf("Silencer %i", WEAPONOPT_SILENCER_COST), "2", clrPaleBlue, buymenu_btn_Silencer_clicked)
	INITIALIZE_BASICBUTTON(WeaponOpt_Lasersight, sprintf("Lasersight %i", WEAPONOPT_LASERSIGHT_COST), "3", clrPaleBlue, buymenu_btn_Lasersight_clicked)
	INITIALIZE_BASICBUTTON(WeaponOpt_Flashlight, sprintf("Flashlight %i", WEAPONOPT_FLASHLIGHT_COST), "4", clrPaleBlue, buymenu_btn_Flashlight_clicked)
	INITIALIZE_BASICBUTTON(WeaponOpt_Scope, sprintf("Scope %i", WEAPONOPT_SCOPE_COST), "5", clrPaleBlue, buymenu_btn_Scope_clicked)
	
	// Yes, Akimbo and FullLoad use the same hotkey (number 6). They never appear on the same weapon,
	// since Akimbo is only meant for some guns, and FullLoad is only meant for some melee weapons.
	// TODO? And if these two were to support flexible prices (show what it costs for the currently selected weapon... akimbo & fullLoad can't be fixed to
	// one constant for all weapons), their display text + prices would have to be shown as they're shown to the user.
	INITIALIZE_BASICBUTTON(WeaponOpt_Akimbo, "Akimbo", "6", clrPaleBlue, buymenu_btn_Akimbo_clicked)
	INITIALIZE_BASICBUTTON(WeaponOpt_FullLoad, "FullLoad", "6", clrGreen, buymenu_btn_FullLoad_clicked)
	
	buymenu_btn_WeaponOpt_Buy.funOnShow_Custom = buymenu_btn_Buy_onShow;
	
	buymenu_btn_WeaponOpt_Silencer.funOnShow_Custom = buymenu_btn_Silencer_onShow;
	buymenu_btn_WeaponOpt_Lasersight.funOnShow_Custom = buymenu_btn_Lasersight_onShow;
	buymenu_btn_WeaponOpt_Flashlight.funOnShow_Custom = buymenu_btn_Flashlight_onShow;
	buymenu_btn_WeaponOpt_Scope.funOnShow_Custom = buymenu_btn_Scope_onShow;
	buymenu_btn_WeaponOpt_Akimbo.funOnShow_Custom = buymenu_btn_Akimbo_onShow;
	buymenu_btn_WeaponOpt_FullLoad.funOnShow_Custom = buymenu_btn_FullLoad_onShow;
	
	
	// TODO - ONGOING.  As more weapons are entered, use this new condensed way
	// to hook up to their info instead of using the hardcoded specifics below.
	// Any other references to the button may be deleted thereafter.
	
	// This variable is expected for the _ADV version to work or else it would need to
	// declare a new temp each time, just keep it around.
	weapondata_basic_t tempWeapRef;
	
	
	INITIALIZE_WEAPONBUTTON(GLOCK18, "1", clrPaleBlue, Handguns)
	INITIALIZE_WEAPONBUTTON(SOCOMMK23, "2", clrPaleBlue, Handguns)
	INITIALIZE_WEAPONBUTTON(DESERTEAGLE, "3", clrPaleBlue, Handguns)
	INITIALIZE_WEAPONBUTTON(FIVESEVEN, "4", clrPaleBlue, Handguns)
	INITIALIZE_WEAPONBUTTON(BERETTA, "5", clrPaleBlue, Handguns)
	INITIALIZE_WEAPONBUTTON(AKIMBOCOLTS, "6", clrPaleBlue, Handguns)
	INITIALIZE_WEAPONBUTTON(GLOCK20, "7", clrPaleBlue, Handguns)
	INITIALIZE_WEAPONBUTTON(RUGERMK1, "8", clrPaleBlue, Handguns)
	INITIALIZE_WEAPONBUTTON(RAGINGBULL, "9", clrPaleBlue, Handguns)
	INITIALIZE_WEAPONBUTTON(CONTENDERG2, "A", clrPaleBlue, Handguns)
	
	
	INITIALIZE_WEAPONBUTTON(MINIUZI, "1", clrPaleBlue, SMGs)
	INITIALIZE_WEAPONBUTTON(MP5SD, "2", clrPaleBlue, SMGs)
	INITIALIZE_WEAPONBUTTON(MP5K, "3", clrPaleBlue, SMGs)
	
	INITIALIZE_WEAPONBUTTON(STEYRTMP, "4", clrPaleBlue, SMGs)
	INITIALIZE_WEAPONBUTTON(HKPDW, "5", clrPaleBlue, SMGs)
	INITIALIZE_WEAPONBUTTON(UMP, "6", clrPaleBlue, SMGs)
	
	INITIALIZE_WEAPONBUTTON(SKORPION, "7", clrPaleBlue, SMGs)
	INITIALIZE_WEAPONBUTTON(MAC10, "8", clrPaleBlue, SMGs)
	
	
	INITIALIZE_WEAPONBUTTON(M4A1, "1", clrPaleBlue, Rifles)
	INITIALIZE_WEAPONBUTTON(AK47, "2", clrPaleBlue, Rifles)
	INITIALIZE_WEAPONBUTTON(STEYRAUG, "3", clrPaleBlue, Rifles)
	INITIALIZE_WEAPONBUTTON(M16A4, "4", clrPaleBlue, Rifles)
	INITIALIZE_WEAPONBUTTON(BARRETTM82, "5", clrPaleBlue, Rifles)
	
	
	INITIALIZE_WEAPONBUTTON(BENELLIM3, "1", clrPaleBlue, Shotguns)
	INITIALIZE_WEAPONBUTTON(USAS12, "2", clrPaleBlue, Shotguns)
	INITIALIZE_WEAPONBUTTON(SPAS12, "3", clrPaleBlue, Shotguns)
	INITIALIZE_WEAPONBUTTON(MOSSBERG500, "4", clrPaleBlue, Shotguns)
	INITIALIZE_WEAPONBUTTON(SAWEDOFF, "5", clrPaleBlue, Shotguns)


	// LATER - make purchaseable only if the gamemode is team/scenario. (mercs vs specialists)
	INITIALIZE_WEAPONBUTTON(M61GRENADE, "1", clrPaleBlue, SpecialPurpose)
	
	INITIALIZE_WEAPONBUTTON(COMBATKNIFE, "2", clrPaleBlue, SpecialPurpose)
	INITIALIZE_WEAPONBUTTON(M60, "3", clrPaleBlue, SpecialPurpose)
	INITIALIZE_WEAPONBUTTON(KATANA, "4", clrPaleBlue, SpecialPurpose)
	INITIALIZE_WEAPONBUTTON(SEALKNIFE, "5", clrPaleBlue, SpecialPurpose)

	//TODO - set these up.  items are simpler than weapons and have no default behavior.
	// in fact the kevlar just puts armor on the player at spawn, stealthshoes may as well
	// be a "yes/no" toggle on the player.
	// Last parameter is the cost instead of the buy category, since we don't have
	// any weapondata to get the cost from.
	// ...we still need the category too though.
	//INITIALIZE_ITEMBUTTON_ADV(KEVLAR, "1", 48+1, clrPaleBlue, PlayerAccessory, 1900);
	//INITIALIZE_ITEMBUTTON_ADV(STEALTHSHOES, "2", 48+2, clrPaleBlue, PlayerAccessory, 700);
	
	buymenu_btn_Back_updateText(); //just in case.
	
	buymenu_addbuttonToFirstLayer(&buymenu_btn_Recentconfig);
	buymenu_addbuttonToFirstLayer(&buymenu_btn_Buy);
	buymenu_addbuttonToFirstLayer(&buymenu_btn_RemoveItem);
	buymenu_addbuttonToFirstLayer(&buymenu_btn_ResetConfig);
	buymenu_addbuttonToFirstLayer(&buymenu_btn_SaveConfig);
	buymenu_addbuttonToFirstLayer(&buymenu_btn_LoadConfig);
	buymenu_addbuttonToFirstLayer(&buymenu_btn_BuyRandom);
	
	buymenu_addbutton(&buymenu_btn_Buy, &buymenu_btn_Buy_Handguns);
	buymenu_addbutton(&buymenu_btn_Buy, &buymenu_btn_Buy_SMGs);
	buymenu_addbutton(&buymenu_btn_Buy, &buymenu_btn_Buy_Rifles);
	buymenu_addbutton(&buymenu_btn_Buy, &buymenu_btn_Buy_Shotguns);
	buymenu_addbutton(&buymenu_btn_Buy, &buymenu_btn_Buy_SpecialPurpose);
	
	
	setupRemoveButtonList();
	
}// UI_BuyMenu_Init



//var float lastPrintoutTime = 0.0f;

void
UI_BuyMenu_Draw(void)
{
	// If we leave spectator view (spawned and walking/aiming), disallow the buy menu.
	// (could also check for "player.iState == PLAYER_STATE::SPAWNED" )
	if(getplayerkeyvalue(player_localnum, "*spec") == "0"){
		
		UI_ChangeScreen(UI_SCREEN::NONE);
		return;
	}
	
	// Reset this. If the mouse is hovering over something we'll find out.
	iHoveredButtonIndex = -1;
	
	int currentLayerSelectedIndex;
	int btnToRender_index_global;
	CBuyMenu_BasicButton someThing;
	CBuyMenu_BasicButton previousLayerButton;
	BOOL fIsSelected = FALSE;
	
	
	// Checks for clicks be done separately
	// Only check for buttons from the active layer. 
	
	vector vButtonPos = [video_mins[0] + 5, video_mins[1] + video_res[1]/2, 0];
	vector vBtnPos = [0,0,0];
	
	/*
	if(time >= lastPrintoutTime){
		lastPrintoutTime = time + 2.0f;
		
		// anything routine?
	}
	*/
	
	drawPlayerInventory(TRUE);
	
	for(int i = 0i; i <= iActiveLayer; i = i + 1i){
		//Adjust these as needed. These also show where to draw the "0 Cancel" button
		//for the active layer (after the most recent button; below).
		//vector vBtnPos;
		vBtnPos.z = 0;
		if(i == 0){
			
			if(ary_layerButtonChoice[i] == NULL){
				currentLayerSelectedIndex = -1;
			}else{
				someThing = *ary_layerButtonChoice[i];
				currentLayerSelectedIndex = someThing.iGlobalIndex;
			}
			
			vBtnPos.x = (int)vButtonPos.x; //default pos.
			vBtnPos.y = (int)vButtonPos.y;
			
			for(int i2 = 0i; i2 < ary_layerFirstButton_softLength; i2++){
				CBuyMenu_BasicButton tempButton = *ary_layerFirstButton[i2];
				fIsSelected = (tempButton.iGlobalIndex == currentLayerSelectedIndex);
				
				(*ary_layerFirstButton[i2]).funOnRender_Base(vBtnPos, i, i2, fIsSelected);
				
				vBtnPos.y += (vButtonSizStandard.y + 1);
				
			}
			
		}else{
			vBtnPos.x = (int)vButtonPos.x + (vButtonSizStandard.x + 1) * i; //slide the X-pos however far given this layer.
			vBtnPos.y = (int)vButtonPos.y;
			// All other layers only render buttons that the previous layer (selected button there) tells them to.
			
			previousLayerButton = *ary_layerButtonChoice[i - 1i];
			
			if(ary_layerButtonChoice[i] == NULL){
				currentLayerSelectedIndex = -1;
			}else{
				someThing = *ary_layerButtonChoice[i];
				currentLayerSelectedIndex = someThing.iGlobalIndex;
			}
			
			for(int i2 = 0i; i2 < previousLayerButton.ary_btn_softLength; i2 = i2+1i){
				btnToRender_index_global = previousLayerButton.ary_btn_index[i2];
				
				CBuyMenu_BasicButton tempButton2_aaa = *ary_btnTotal[btnToRender_index_global];
				
				//NOTICE - we can only check for bActive in the active layer. Any others must show
				//		 all buttons yet.
				if(i == iActiveLayer && tempButton2_aaa.bActive == FALSE){
					//skip showing this one.
					continue;
				}
				
				fIsSelected = (btnToRender_index_global == currentLayerSelectedIndex);
				
				(*ary_btnTotal[btnToRender_index_global]).funOnRender_Base(vBtnPos, i, i2, fIsSelected);
				vBtnPos.y += (vButtonSizStandard.y + 1);
				
			}// for i2 in this layer's buttons.
		}
		
		if(i == iActiveLayer){
			int backButtonRow;
			// Draw the "0. Cancel" button. Special purpose.
			// buymenu_renderButton(&buymenu_btn_Back, vBtnPos, 0.86);
			
			// Whatever the size of the latest layer is.  Since that index itself wasn't used (minus 1 is the most recently used index;
			// we're putting a button AFTER that one).
			if(iActiveLayer > 0){
				previousLayerButton = *ary_layerButtonChoice[iActiveLayer - 1i];
				backButtonRow = previousLayerButton.ary_btn_softLength;
			}else{
				backButtonRow = ary_layerFirstButton_softLength;
			}
			
			buymenu_btn_Back.funOnRender_Base(vBtnPos, i, backButtonRow, fIsSelected);
			vBtnPos.y += (vButtonSizStandard.y + 1);
		}
		
		
	}// for(i from 0 to iActiveLayer, inclusive)
	
	
	// TEST!
	// DRAWFLAG_ADDITIVE? NORMAL?  Which one?
	//drawsubpic([25,25], [128,48], "sprites/weapons/glock18.spr_0.tga", [0,0], [128/128,48/48], [1,1,1], 1, DRAWFLAG_ADDITIVE);
	//drawsubpic([16,128], [11,16], "sprites/numbers.spr_0.tga", [1/112,0], [11/112,16/16], [1,1,1], 1, DRAWFLAG_ADDITIVE);
	//drawsubpic([16,128], [127*0.1,16], "sprites/numbers.spr_0.tga", [0.5,0], [0.1,16/16], [1,1,1], 1, DRAWFLAG_ADDITIVE);
	
	drawPlayerInventory_TopBar(-1, TRUE);
	
}//UI_BuyMenu_Draw


// Given a single-character string, like "3" or "A", determine the keycode that
// should be tied to it.  For uppercase characters, force the lowercase one, as the
// user is certainly pushing that one.
float determineHotkeyFromChar(string arg_sHotkeyDisplay){
	if(strlen(arg_sHotkeyDisplay) != 0){
		float charCode = str2chr(arg_sHotkeyDisplay, 0);
		if(charCode >= 48 && charCode <= 48+9){
			// numeric?  Straightforward
			return charCode;
		}else if(charCode >= 65 && charCode <= 65+25){
			// uppercase?  Convert to lowercase for charCode.
			return charCode + 32;
		}else if(charCode >= 97 && charCode <= 97+25){
			// lowercase?  Leave it as it is
			return charCode;
		}else{
			// ???
			return -1;
		}
	}else{
		// blank string given?
		return -1;
	}
}


