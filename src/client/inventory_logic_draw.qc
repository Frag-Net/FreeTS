

// at the bottom-right. Used to show which of the silencer, lasersight, scope, or flashlight was purchased.
void
drawWeaponOptionBar(
	vector arg_vDrawOrigin, string arg_sOptionName, BOOLEAN arg_fBrightLight,
	float arg_opac
)
{
	drawfill( arg_vDrawOrigin, [128, 19], clrPaleBlue, arg_opac - 0.55f );
	Gfx_Text( [arg_vDrawOrigin.x + 2, arg_vDrawOrigin.y + 4], arg_sOptionName, vHUDFontSize, clrPaleBlue, 0.90f, DRAWFLAG_ADDITIVE, FONT_ARIAL_STD );
	
	vector tempVec = [arg_vDrawOrigin.x + 112, arg_vDrawOrigin.y + 1];
	
	if(arg_fBrightLight){
		DRAW_IMAGE_ADDITIVE(img_item_installed, tempVec, clrPaleBlue, arg_opac + 0.15f)
	}else{
		DRAW_IMAGE_ADDITIVE(img_item_installed, tempVec, clrPaleBlue, arg_opac - 0.50f)
	}
}// drawWeaponOptionBar


void
drawPlayerInventory_TopBar(int arg_iSlotSelected, BOOL arg_fBuyMode)
{
	vector vWeaponsBar_drawLoc = g_vec_null;
	vector vWeaponsBar_drawBase = g_vec_null;
	
	if(arg_fBuyMode){
		// draw the pre-bar
		drawfill( [8, 8], [640, 19], clrPaleBlue, 0.96f - 0.60f );
		vWeaponsBar_drawBase = [8, 28];
		
		// TODO - fetch these globally
		if(!getstati(STAT_RULE_MONEYALLOWED)){
			Gfx_Text( [8, 8 + 2], sprintf("Order Value: %i", pSeatLocal->m_clientinfo.weaponconfig_temp.iTotalPrice), vHUDFontSize, clrPaleBlue, 0.93f, DRAWFLAG_ADDITIVE, FONT_ARIAL_STD );
		}else{
			Gfx_Text( [8, 8 + 2], sprintf("Cash: %i (Order Cost: %i)", getstati(STAT_MONEY), pSeatLocal->m_clientinfo.weaponconfig_temp.iTotalPrice), vHUDFontSize, clrPaleBlue, 0.93f, DRAWFLAG_ADDITIVE, FONT_ARIAL_STD );
			
		}
		Gfx_Text( [8 + 128*2, 8 + 2], sprintf("Weight Slots: %i / %i", pSeatLocal->m_clientinfo.weaponconfig_temp.iTotalSlots, getstati(STAT_RULE_MAXWEIGHTSLOTS)), vHUDFontSize, clrPaleBlue, 0.93f, DRAWFLAG_ADDITIVE, FONT_ARIAL_STD );
	}else{
		vWeaponsBar_drawBase = [8, 8];
	}
	
	
	drawfill( vWeaponsBar_drawBase, [640, 20], clrPaleBlue, 0.96f - 0.60f );
	
	vWeaponsBar_drawLoc.x = vWeaponsBar_drawBase.x + 11 + 128*0;
	vWeaponsBar_drawLoc.y = vWeaponsBar_drawBase.y + 0;
	DRAW_IMAGE_CROPPED_ADDITIVE(spr_number1, vWeaponsBar_drawLoc, clrPaleBlue, 0.89f)
	
	vWeaponsBar_drawLoc.x = vWeaponsBar_drawBase.x + 11 + 128*1;
	vWeaponsBar_drawLoc.y = vWeaponsBar_drawBase.y + 0;
	DRAW_IMAGE_CROPPED_ADDITIVE(spr_number2, vWeaponsBar_drawLoc, clrPaleBlue, 0.89f)
	
	vWeaponsBar_drawLoc.x = vWeaponsBar_drawBase.x + 11 + 128*2;
	vWeaponsBar_drawLoc.y = vWeaponsBar_drawBase.y + 0;
	DRAW_IMAGE_CROPPED_ADDITIVE(spr_number3, vWeaponsBar_drawLoc, clrPaleBlue, 0.89f)
	
	vWeaponsBar_drawLoc.x = vWeaponsBar_drawBase.x + 11 + 128*3;
	vWeaponsBar_drawLoc.y = vWeaponsBar_drawBase.y + 0;
	DRAW_IMAGE_CROPPED_ADDITIVE(spr_number4, vWeaponsBar_drawLoc, clrPaleBlue, 0.89f)
	
	vWeaponsBar_drawLoc.x = vWeaponsBar_drawBase.x + 11 + 128*4;
	vWeaponsBar_drawLoc.y = vWeaponsBar_drawBase.y + 0;
	DRAW_IMAGE_CROPPED_ADDITIVE(spr_number5, vWeaponsBar_drawLoc, clrPaleBlue, 0.89f)
	
}// drawPlayerInventory_TopBar


// While in the buy screen, draw each slot according to the current temp config.
// This includes using the #1 slot for the text.
// For buymode, we're displaying the tempconfig (what things to buy at spawntime).
// Otherwise, this is the player's ingame inventory being drawn.
void
drawPlayerInventory(BOOL arg_fBuyMode)
{
	player pl = (player)pSeat->m_ePlayer;
	
	// Basic version (has things common to both cases). To be set soon for buy menu and
	// ingame (spawned - inventory).
	// !!! - No longer the case!
	// Don't do casting a ary_myWeapons[i] to weapondynamic_t.  weaponconfic_weapon_t is
	// now a struct so they aren't so easily transferrable.
	// Get the info you need from the weapondynamic_t or weaponconfig_weapon_t by the
	// same fBuyMode check, don't trust anything else.
	weaponconfig_weapon_t* weapon_configRef;
	int currentWeaponID;
	int currentWeaponCount;
	int bitsUpgradeOpts;
	int listMax;
	BOOL hasAnyAmmo;
	
	// 1 through 5. there is no slot 0.
	//
	// TODO CRITICAL - check the compile warning here. Why does this happen??
	// What row has been drawn yet for each of the player inventory slots? Use to know
	// where to draw the next weapon in that slow (below the previously drawn one...
	// next row).
	int ary_slotRowYet[INVENTORY_SLOT_COUNT];
	//ary_slotRowYet = (int) memalloc(INVENTORY_SLOT_COUNT-1);
	for(int i = 0; i < INVENTORY_SLOT_COUNT; i++){
		ary_slotRowYet[i] = 0;
	}
	//memfree(ary_slotRowYet);
	
	
	// Not set for the Buy Menu (data related to clip, which buyOpts are toggled on, etc.
	// is not available). The idea is, we can use "weapon_dynamicRef" to get more info
	// about the weapon for displaying too in the inventory as needed that the buy menu
	// just doesn't have.  Example: ingame inv has clip left, but the buy menu does not.
	weapondynamic_t weapon_dynamicRef = NULL;
	weapondata_gun_t tempGunRef;
	
	if(arg_fBuyMode){
		listMax = pSeatLocal->m_clientinfo.weaponconfig_temp.ary_myWeapons_softMax;
	}else{
		listMax = pl.ary_myWeapons_softMax;
	}
	
	for(int i = 0; i < listMax; i++){
		
		if(arg_fBuyMode){
			weapon_configRef = (weaponconfig_weapon_t*) &pSeatLocal->m_clientinfo.weaponconfig_temp.ary_myWeapons[i];
			currentWeaponID = weapon_configRef->weaponID;
			currentWeaponCount = weapon_configRef->iCount;
			bitsUpgradeOpts = weapon_configRef->iBitsUpgrade;
		}else{
			weapon_dynamicRef = (weapondynamic_t) pl.ary_myWeapons[i];
			currentWeaponID = weapon_dynamicRef.weaponID;
			currentWeaponCount = weapon_dynamicRef.iCount;
			bitsUpgradeOpts = weapon_dynamicRef.iBitsUpgrade;
		}
				
		weapondata_basic_t* basicPointer = (weapondata_basic_t*) ary_weaponData[currentWeaponID];
		weapondata_basic_t basicRef = *(basicPointer);
		
		// If there isn't any type of count (throwables stacked, ammo), this default of
		// -1 stays to mean, don't draw any number.
		int ammoCount = -1;
		
		if(basicRef.typeID == WEAPONDATA_TYPEID_GUN || basicRef.typeID == WEAPONDATA_TYPEID_IRONSIGHT){
			//and the type of ammo is?
			weapondata_gun_t gunRef = *((weapondata_gun_t*)basicPointer);
			
			if(arg_fBuyMode){
				ammoCount = pSeatLocal->m_clientinfo.weaponconfig_temp.ary_ammoTotal[gunRef.iAmmoDataID];
			}else{
				ammoCount = pl.ary_ammoTotal[gunRef.iAmmoDataID];
			}
			
		}else if(basicRef.typeID == WEAPONDATA_TYPEID_THROWABLE){
			weapondata_throwable_t throwableRef = *((weapondata_throwable_t*)basicPointer);
			//throwableRef.iMaxCount
			ammoCount = currentWeaponCount;
		}
		
		// Note that this remains blank if the weapon is not selected. And for ingame (not buy menu) only.
		string sWeaponDisplayName = "";
		
		if(!arg_fBuyMode && pl.weaponSelectHighlightID == i){
			if(!pl.weaponSelectHighlightAkimbo || basicRef.iAkimboID <= 0){
				// Lacking an akimbo link means we ARE the weapon to be selected.
				sWeaponDisplayName = basicRef.sDisplayName;
			}
		}
		
		if(!arg_fBuyMode){
			// only a possible consideration ingame, whether to color the weapon icon
			// red or not.
			if(basicRef.typeID == WEAPONDATA_TYPEID_GUN || basicRef.typeID == WEAPONDATA_TYPEID_IRONSIGHT){
				tempGunRef = *((weapondata_gun_t*)basicPointer);
				if(bitsUpgradeOpts & BITS_WEAPONOPT_AKIMBO && basicRef.iAkimboID == WEAPON_AKIMBO_UPGRADE_ID::NONE){
					// is akimbo, BUT not a separate choice (see below if that is the
					// case)?  "iClipAkimboLeft" can count too.
					hasAnyAmmo = (weapon_dynamicRef.iClipLeft > 0 || weapon_dynamicRef.iClipAkimboLeft > 0 || pl.ary_ammoTotal[tempGunRef.iAmmoDataID] > 0);
				}else{
					// not akimbo or it's linked as a separate choice?  singular clip
					// only.
					hasAnyAmmo = (weapon_dynamicRef.iClipLeft > 0 || pl.ary_ammoTotal[tempGunRef.iAmmoDataID] > 0);
				}
			}else{
				// not a gun?  ok, assume usable.
				hasAnyAmmo = TRUE;
			}
		}else{
			// always normal color, can't be 'out of ammo'.
			hasAnyAmmo = TRUE;
		}
		
		drawPlayerInventory_place(basicRef.iInventorySlot-1, ary_slotRowYet[basicRef.iInventorySlot-1], basicRef.sIconFilePath, sWeaponDisplayName, arg_fBuyMode, ammoCount, hasAnyAmmo, bitsUpgradeOpts );
		ary_slotRowYet[basicRef.iInventorySlot-1]++;   //next row for the next weapon that gets that same slot.
		
		// NOTICE - "basicRef.iBitsUpgrade" is whether this weapon supports akimbo or
		// not (as an upgrade at least).
		// TODO - the ingame inventory will just go ahead and make akimbo its own
		// separate dynamic weapon data to enter the list.  Or will it??
		// of player weapons. Much less expensive than re-checking all weapons to see
		// what has akimbo or not every time we move up or down a weapon's choice.
		// In short, we won't be doing the automatic akimbo-version generation here
		// ingame.  It will happen naturally because akimbo will be its own weapon.
		
		weapondata_basic_t* akimboPointer = NULL;
		
		if(bitsUpgradeOpts & BITS_WEAPONOPT_AKIMBO && basicRef.iAkimboID > 0){
			// draw the akimbo variant.basicRef.iAkimboID
			akimboPointer = (weapondata_basic_t*) ary_akimboUpgradeData[basicRef.iAkimboID];
		}

		// We have akimbo data? show it.
		if(akimboPointer != NULL){
			weapondata_basic_t akimboRef = *(akimboPointer);
			
			if(!arg_fBuyMode && pl.weaponSelectHighlightID == i && pl.weaponSelectHighlightAkimbo){
				sWeaponDisplayName = akimboRef.sDisplayName;
			}else{
				sWeaponDisplayName = "";
			}
			
			if(!arg_fBuyMode){
				// only a possible consideration ingame, whether to color the weapon
				// icon red or not.
				if(
					basicRef.typeID == WEAPONDATA_TYPEID_GUN ||
					basicRef.typeID == WEAPONDATA_TYPEID_IRONSIGHT
				){
					// probably had to be a gun to get here, but eh.
					// Clearly must be akimbo by link (has a singular form that says
					// to render this separately)
					tempGunRef = *((weapondata_gun_t*)basicPointer);
					hasAnyAmmo = (weapon_dynamicRef.iClipLeft > 0 || weapon_dynamicRef.iClipAkimboLeft > 0 || pl.ary_ammoTotal[tempGunRef.iAmmoDataID] > 0);
				}else{
					// not a gun?  ok, assume usable.
					hasAnyAmmo = TRUE;
				}
			}else{
				// always normal color, can't be 'out of ammo'.
				hasAnyAmmo = TRUE;
			}
			
			// akimbo version always goes to slot #5.
			// whatever just leave it up to what the weapondata says. Should refer to
			// slot #5 regardless.
			drawPlayerInventory_place(akimboRef.iInventorySlot-1, ary_slotRowYet[akimboRef.iInventorySlot-1], akimboRef.sIconFilePath, sWeaponDisplayName, arg_fBuyMode, ammoCount, hasAnyAmmo, bitsUpgradeOpts );
			ary_slotRowYet[akimboRef.iInventorySlot-1]++;  //ditto for the akimbo slot.
		}
	}// for all ary_myWeapons (within softMax)
}// drawPlayerInveotry_buy


// "hasAnyAmmo" is, whether this weapon has any ammo in the clip or the ammo pool.
// Original TS behavior is to color red at a clip of 0, even if ammo is in the pool
// but this seems more like an oversight.
// For non-gun/ironsight weapons (knives, etc.) just force this to TRUE to always be
// colored normally.
void
drawPlayerInventory_place
(
	int arg_iSlot, int arg_iRow, string arg_sWeaponSpritePath,
	string arg_sSelectedWeaponDisplayName, BOOL arg_fBuyMode,
	optional int ammoCount, optional BOOL hasAnyAmmo, optional int bitsUpgradeOpts
){
	// Where do I start drawing weapons from? Below the top-most bar that's expected
	// to be in place.
	// In buymode, there are two top-bars. Account for this by drawing an extra 20
	// pixels below.
	vector vDrawOrigin;
	if(!arg_fBuyMode){
		vDrawOrigin = [8, 8+20];
	}else{
		vDrawOrigin = [8, 8+40];
	}
	
	vector vDrawPos = [vDrawOrigin.x + arg_iSlot*128, vDrawOrigin.y + arg_iRow*48 ];
	
	float fOpac;
	if(arg_sSelectedWeaponDisplayName != ""){
		// If the SelectedWeaponDisplayName was provided, this is the selected weapon.
		// This text will be drawn to the right of the weapon drawn.
		// TODO - this can also just be done separately outside of all inventory item
		// weapon icon drawing.
		// Then just make arg_sSelectedWeaponDisplayName into arg_fIsSelected.
		fOpac = 1.00f;
		
		Gfx_Text( [vDrawPos.x + 128, vDrawPos.y + 4], arg_sSelectedWeaponDisplayName, vHUDFontSize, clrPaleBlue, 0.95f, DRAWFLAG_ADDITIVE, FONT_ARIAL_STD );
	}else{
		if(arg_fBuyMode){
			// always bright?
			fOpac = 0.94f;
		}else{
			fOpac = 0.82f;
		}
	}
	
	if(arg_fBuyMode && ammoCount != -1){
		// draw how much ammo it has (ammo pool only, not the clip... could add it
		// first if wanted though but it's not part of the price)
		drawSpriteNumber(ary_LCD_numberSet, vDrawPos.x + 3, vDrawPos.y + 3, ammoCount, 3, BITS_DIGITOPT_DEFAULT, clrPaleBlue, 0.88f);
	}
	if(arg_fBuyMode){
		//draw some buy upgrades as three letters each.
		string upgradeString = "";
		if(bitsUpgradeOpts & BITS_WEAPONOPT_SILENCER){
			if(upgradeString == ""){
				upgradeString = sprintf("%s", "Sil");
			}else{
				upgradeString = sprintf("%s,%s", upgradeString, "Sil");
			}
		}
		if(bitsUpgradeOpts & BITS_WEAPONOPT_LASERSIGHT){
			if(upgradeString == ""){
				upgradeString = sprintf("%s", "Las");
			}else{
				upgradeString = sprintf("%s,%s", upgradeString, "Las");
			}
		}
		if(bitsUpgradeOpts & BITS_WEAPONOPT_FLASHLIGHT){
			if(upgradeString == ""){
				upgradeString = sprintf("%s", "Fla");
			}else{
				upgradeString = sprintf("%s,%s", upgradeString, "Fla");
			}
		}
		if(bitsUpgradeOpts & BITS_WEAPONOPT_SCOPE){
			if(upgradeString == ""){
				upgradeString = sprintf("%s", "Sco");
			}else{
				upgradeString = sprintf("%s,%s", upgradeString, "Sco");
			}
		}
		
		if(upgradeString != ""){
			//if there is anything to draw...
			Gfx_Text( [vDrawPos.x + 3, vDrawPos.y + 3 + 16], sprintf("(%s)", upgradeString), vHUDFontSize, clrPaleBlue, 0.96f, DRAWFLAG_ADDITIVE, FONT_ARIAL_STD );
		}
		
	}//buymodecheck FOR drawing the upgrade options short-hand near the weapon.
	
	img_weapon.sFilePath = sprintf("%s%s", arg_sWeaponSpritePath, "_0.tga");
	
	if(hasAnyAmmo){
		DRAW_IMAGE_ADDITIVE(img_weapon, vDrawPos, clrPaleBlue, fOpac)
	}else{
		// Still selectable unlike in HL (original TS behavior), but just a warning not
		// to pick me.
		DRAW_IMAGE_ADDITIVE(img_weapon, vDrawPos, clrHUDWeaponEmpty, fOpac)
	}
	
}// drawPlayerInventory_place




// See screenshots for what the bottom-left corner of the HUD ingame should look like.
// The text on the very top is the name of the team you're in.  It may often coincide
// with player model though.  TEAM_PLAY makes it obvious that it's not necessarily that
// always though.

// Draw the player-specific info that always shows up when spawned.
// Team name (if applicable), health, standing/crouch/prone icon, money/slots, etc.
void
drawPlayerStats(void)
{
	player pl = (player)pSeat->m_ePlayer;

	int drawerX = 8;
	int drawerY = video_res[1] - 48;

	// TODO intermediate - fetch whether the player is on a team before doing this
	// we'll need some sort of "getstati(STAT_RULE_...)" to go through game rules to see
	// if we even support teams someplace, but maybe not here.
	// We can always let being a member of team "-1" suggest this gamemode has no teams
	// too.
	// Healthy compromise could be using a getstati to fetch "sRule_TeamNames".  If it's
	// 0, this gamemode has no teams. Easy peasy.
	//if(player.iTeam != TS_Team::TEAM_NONE){
		//string myTeamName = ...   //can we even fetch from an array using getstati?
		string myTeamName = "team name here";
		// like pointer vars setup in server/main.c to refer to each index? It might just work.
		drawfill( [drawerX, drawerY - 20], [127, 19], clrPaleBlue, 0.96f - 0.60f );
		Gfx_Text( [drawerX + 2, drawerY - 20 + 4], myTeamName, vHUDFontSize, clrPaleBlue, 0.96f, DRAWFLAG_ADDITIVE, FONT_ARIAL_STD );
	//}
	
	
	
	// TODO - heart symbol to the right, color red instead of the health is under 50
	// (or at 50 too?  unconfirmed yet)
	drawfill( [drawerX, drawerY], [127, 39], clrPaleBlue, 0.96f - 0.60f );
	
	vector clrHealth;
	if(pl.health >= 50){
		clrHealth = clrPaleBlue;
	}else{
		clrHealth = clrMedRed;
	}
	drawSpriteNumber(ary_LCD_numberSet, drawerX + 67 - 6, drawerY + 4 - 2, pl.health, 3, BITS_DIGITOPT_DEFAULT, clrHealth, 0.92f);
	DRAW_IMAGE_ADDITIVE(img_health, ([drawerX + 96, drawerY - 2]), clrHealth, 0.96f)
		
	
	// don't render if it's 0.
	if(pl.armor > 0){
		drawSpriteNumber(ary_LCD_numberSet, drawerX + 67 - 6, drawerY + 24 - 2, pl.armor, 3, BITS_DIGITOPT_DEFAULT, clrPaleBlue, 0.92f);
		DRAW_IMAGE_ADDITIVE(img_kevlar, ([drawerX + 96, drawerY + 20 - 1]), clrPaleBlue, 0.96f)
	}
	
	
	// Player status icon (as in standing, crouched, prone, etc.)
	// the animated running one looks to be unused.  Though I would've seen it by now.
	// Regardless...
	// TODO. This needs to be synched up to the state of the player, particularly during stunts.
	// For now it's static.
	
	// CRITICAL TODO.   Support prone / mid-air graphics!
	if(self.flags & FL_CROUCHING){
		DRAW_IMAGE_ADDITIVE(img_player_crouch, ([drawerX, drawerY - 4]), clrPaleBlue, 0.8f)
	}else{
		DRAW_IMAGE_ADDITIVE(img_player_stand, ([drawerX, drawerY - 4]), clrPaleBlue, 0.8f)
	}
	
	//////////////////////////////////////////////////////////////////////
	drawerX = 136;
	drawerY = video_res[1] - 48;
	int offsetRight = 0;
	
	if(getstati(STAT_RULE_MONEYALLOWED)){
		drawfill( [drawerX, drawerY], [127, 19], clrPaleBlue, 0.96f - 0.60f );
		offsetRight = drawSpriteNumber(ary_LCD_numberSet, drawerX + 8, drawerY + 2, getstati(STAT_MONEY), 8, BITS_DIGITOPT_NONE, clrPaleBlue, 0.92f);
		Gfx_Text( [drawerX + 8 + offsetRight + 6, drawerY + 4], "Credits", vHUDFontSize, clrPaleBlue, 0.96f, DRAWFLAG_ADDITIVE, FONT_ARIAL_STD );
	}//money allowed check
	
	drawfill( [drawerX, drawerY + 20], [127, 19], clrPaleBlue, 0.96f - 0.60f );
	offsetRight = drawSpriteNumber(ary_LCD_numberSet, drawerX + 8, drawerY + 20 + 2, getstati(STAT_RULE_MAXWEIGHTSLOTS) - pl.iTotalSlots, 8, BITS_DIGITOPT_NONE, clrPaleBlue, 0.92f);
	Gfx_Text( [drawerX + 8 + offsetRight + 6, drawerY + 20 + 4], "free slots", vHUDFontSize, clrPaleBlue, 0.96f, DRAWFLAG_ADDITIVE, FONT_ARIAL_STD );

}// drawPlayerStats


void
drawTimer(void)
{
	int iMinutes;
	int iSeconds;
	
	//video_mins ?
	int drawerX = video_res[0] - (60 + 22);
	int drawerY = 14 - 2;

	if (getstatf(STAT_GAMETIME) == -1) {
		return;
	}

	float gameTime = getstatf(STAT_GAMETIME);

	iMinutes = gameTime / 60;
	iSeconds = gameTime - 60 * iMinutes;
	
	vector clrDraw;
	float fOpac;
	float numberFontWidth = ary_LCD_numberSet[0].vSize.x;
	
	if(gameTime < 30){
		clrDraw = clrMedRed;
		fOpac = 0.98f;
	}else{
		clrDraw = clrPaleBlue;
		fOpac = 0.92f;
	}
	
	drawSpriteNumber(ary_LCD_numberSet, drawerX, drawerY, iMinutes, 3, BITS_DIGITOPT_DEFAULT, clrDraw, fOpac);
	Gfx_Text( [drawerX + numberFontWidth*3 + 3, drawerY + 0], ":", vFontSizeNumSlash, clrDraw, fOpac, DRAWFLAG_ADDITIVE, FONT_ARIAL_NUMSLASH );
	drawSpriteNumber(ary_LCD_numberSet, drawerX + numberFontWidth*4, drawerY, iSeconds, 2, BITS_DIGITOPT_FILLER0, clrDraw, fOpac);
	
}// drawTimer


