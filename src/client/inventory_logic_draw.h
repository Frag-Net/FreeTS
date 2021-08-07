


//sample weapon. Fill its sFilePath with whatever weapon to draw and use.
//Better than storing 40+ copies of width/height numbers that never change?
var imageFileRef_t img_weapon = {"", 128, 48};




CREATE_imageFileRef_t(img_item_installed, "sprites/weapons/item_installed.spr", 16, 16)
  //item_not_installed.spr  ???
CREATE_imageFileRef_t(img_health, "sprites/player/health.spr", 32, 24)
CREATE_imageFileRef_t(img_kevlar, "sprites/player/kevlar.spr", 32, 24)



CREATE_imageFileRef_t(img_player_stand, "sprites/player/stand.spr", 64, 48)
CREATE_imageFileRef_t(img_player_crouch, "sprites/player/crouched.spr", 64, 48)
CREATE_imageFileRef_t(img_player_prone, "sprites/player/prone.spr", 64, 48)
CREATE_imageFileRef_t(img_player_jump, "sprites/player/movement.spr", 48, 48)

CREATE_imageFileRef_t(img_player_kungfu, "sprites/player/kungfu.spr", 48, 48)



//CREATE_imageFileRef_t(img_numbers, "sprites/numbers.spr_0.tga", 112, 16)
CREATE_imageFileRef_t(img_numbers, "sprites/numbers.spr", 112, 16)
//CREATE_imageCropBounds_t(spr_number0, img_numbers, 5, 4, 22, 7);
CREATE_imageCropBounds_t(spr_number0, img_numbers, 1, 0, 10, 16)
CREATE_imageCropBounds_t(spr_number1, img_numbers, 11, 0, 10, 16)
CREATE_imageCropBounds_t(spr_number2, img_numbers, 21, 0, 10, 16)
CREATE_imageCropBounds_t(spr_number3, img_numbers, 32, 0, 10, 16)
CREATE_imageCropBounds_t(spr_number4, img_numbers, 44, 0, 10, 16)
CREATE_imageCropBounds_t(spr_number5, img_numbers, 55, 0, 10, 16)
CREATE_imageCropBounds_t(spr_number6, img_numbers, 67, 0, 10, 16)
CREATE_imageCropBounds_t(spr_number7, img_numbers, 79, 0, 10, 16)
CREATE_imageCropBounds_t(spr_number8, img_numbers, 90, 0, 10, 16)
CREATE_imageCropBounds_t(spr_number9, img_numbers, 102, 0, 10, 16)


imageCropBounds_t ary_LCD_numberSet[] = {
	spr_number0,
	spr_number1,
	spr_number2,
	spr_number3,
	spr_number4,
	spr_number5,
	spr_number6,
	spr_number7,
	spr_number8,
	spr_number9

};



void drawWeaponOptionBar(vector arg_vDrawOrigin, string arg_sOptionName, BOOLEAN arg_fBrightLight, float arg_opac);
void drawPlayerInventory_TopBar(int arg_iSlotSelected, BOOL arg_fBuyMode);
void drawPlayerInventory(BOOL arg_fBuyMode);

void drawPlayerInventory_place(int arg_iSlot, int arg_iRow, string arg_sWeaponSpritePath, string arg_sSelectedWeaponDisplayName, BOOL arg_fBuyMode, optional int ammoCount, optional BOOL hasAnyAmmo, optional int bitsUpgradeOpts);

void drawPlayerStats(void);

void drawTimer(void);



