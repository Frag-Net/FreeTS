/*
 * Copyright (c) 2016-2019 Marco Hladik <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

float fSBOffset;
float fSBScale;

//var vector g_vecLightColor;


CREATE_imageFileRef_raw_t(img_scope_quad, "textures/quarterscope.tga", 256, 256)
CREATE_imageFileRef_raw_t(img_scope_cross_plus, "textures/scope_cross_plus_odd.tga", 19, 19)  //was 20, 20.. shoulda been 19,19 tho
//CREATE_imageFileRef_t(img_???, "sprites/player/stand.spr", 64, 48)


/*
=================
HUD_DrawScope_Pic

The scope borders are split up into multiple parts.
We want to fill the screen, so we gotta do some hacking.
=================
*/
void HUD_DrawScope_Pic( vector vPos, vector vSize, string sSprite ) {
	drawpic( ( vPos * fSBScale ) + [ fSBOffset, 0 ], sSprite, vSize * fSBScale, '1 1 1', 1.0f );
}

/*
=================
HUD_DrawScope

Tries to draw a scope whenever viewzoom < 1.0f
=================
*/
void HUD_DrawScope( void ) {
	
	player pl = (player)pSeat->m_ePlayer;
	
	if(pl == NULL){
		return;
	}
	
	// NOTICE - rest of the logic doesn't refer to vCenter except for the lasersight,
	// copied from hudcrosshair.
	vector vCenter = video_mins + [video_res[0]/2, video_res[1]/2];
	
	// PREDICTION call??
	/*
	if (self != world) {
		//Player_Predict();
		//viewClient.vecPlayerOrigin = self.origin;
		//viewClient.vecPlayerVelocity = self.velocity;
		//viewClient.flMoveFlags = self.pmove_flags;
		//viewClient.flGameFlags = self.gflags;
		
		//TAGGG - we get this apparently.
		//g_vecLightColor = getlight(viewClient.vecPlayerOrigin) / 255;
		
		//... pSeat->m_vecPredictedOrigin = pl.origin;
		
		g_vecLightColor = getlight(pSeat->m_vecPredictedOrigin) / 255;
	}
	*/
	
	BOOL hasLasersight = FALSE;
	
	if(pl.inventoryEquippedIndex != -1){
		//get that weapon.
		weapondynamic_t dynaRef = pl.ary_myWeapons[pl.inventoryEquippedIndex];
		weapondata_basic_t* basicPointer = (weapondata_basic_t*) ary_weaponData[dynaRef.weaponID];
		weapondata_basic_t basicRef = *(basicPointer);
		
		int myWeaponTypeID = basicRef.typeID;
		if(myWeaponTypeID == WEAPONDATA_TYPEID_GUN || myWeaponTypeID == WEAPONDATA_TYPEID_IRONSIGHT){
			weapondata_gun_t gunRef = *((weapondata_gun_t*)(basicPointer));
			// We probably have a "drawCrosshair" variable in our weapon struct.
			// probaly not even necessary really, since we could infer that property fine anyway from the
			// typeID.
			// One more check... we can explicitly forbid drawing the crosshair ever for a weapon too.
			// Example is the barrett sniper rifle, even hip-fire has no crosshair like other weapons.
			
			//if(basicRef.fDrawCrosshair){
				//hasWeaponCrosshair = TRUE;
				int iBitsUpgradeSafe_on = dynaRef.iBitsUpgrade_on & (dynaRef.iBitsUpgrade & basicRef.iBitsUpgrade);
				
				//do we have a lasersight though?
				if(iBitsUpgradeSafe_on & BITS_WEAPONOPT_LASERSIGHT){
					// why yes, we got it
					hasLasersight = TRUE;
				}
			//}//END OF fDrawCrosshair check.
		}
	}//END OF inventoryEquippedIndex check
	
	

	//How many times does our scope graphic fit half the height of the screen?
	float flScopeGraphicScale = (video_res[1]/2) / img_scope_quad.h * 1.6;
	
	vector screenMid = [video_res[0]/2 - flScopeGraphicScale*img_scope_quad.w/2, video_res[1]/2 - flScopeGraphicScale*img_scope_quad.h/2];
	
	const vector vecSca = [flScopeGraphicScale,flScopeGraphicScale];
	
	//Determine whether we need to fill any of the left/right parts of the screen,
	//in case the user is using an ultra-wide screen.
	float anticipatedSize = flScopeGraphicScale*img_scope_quad.h;
	
	float crosshairX_Offset = 0;
	
	
	// the "-5" is in case of some overlap with transparent pixels from scaling.
	if(anticipatedSize-5 >= video_res[0]/2){
		//the graphic will exceed half the screen's width.  no need to do anything else.
	}else{
		float toFillWidth = (video_res[0]/2) - (anticipatedSize);
		crosshairX_Offset = toFillWidth;
		drawfill( [0,0], [ toFillWidth+5, video_res[1] ], [0,0,0], 1.0f );
		drawfill( [ video_res[0]/2 + anticipatedSize-5, 0 ], [video_res[0]/2 + -(anticipatedSize-5-1), video_res[1] ], [0,0,0], 1.0f );
	}
	
	if(anticipatedSize-5 >= video_res[1]/2){
		//the graphic will exceed half the screen's width.  no need to do anything else.
	}else{
		float toFillHeight = (video_res[1]/2) - (anticipatedSize);
		drawfill( [crosshairX_Offset-1,0], [ video_res[0] - (crosshairX_Offset-1)*2, toFillHeight+5 ], [0,0,0], 1.0f );
		drawfill( [crosshairX_Offset-1, video_res[1]/2 + anticipatedSize-5 ], [video_res[0] - (crosshairX_Offset-1)*2, video_res[1]/2 + -(anticipatedSize-5-1) ], [0,0,0], 1.0f );
	}
	
	
	
	float centerCrosshairOpac;
	if(video_res[1] < 300){
		centerCrosshairOpac = 0;  //don't draw
	}else{
		centerCrosshairOpac = max(0.27f, min(1, (video_res[1] - 300) / (1200 - 300) )* 0.45  ) ;
	}
	
	vector vecInset = [0,0];
	
	vector directCenter = [video_res[0]/2, video_res[1]/2];
	//DRAW_IMAGE_EXPER(img_scope_cross_plus, directCenter, '0 0', 0, vecSca*0.6, '0 0 0', centerCrosshairOpac );
	DRAW_IMAGE_EXPER2(img_scope_cross_plus, directCenter, vecSca, vecInset, '0 0 0', centerCrosshairOpac );
	
	//NOTICE - the drawoption choice of 1 like The Wastes uses only works because the raw color of the
	// graphic is expected.  But in our case, we actually still want even a black color to be solid.
	// The drawoption choice of 1 makes blackness get interpreted as transparency.
	// Anything else, just say 0, at least lets us color the white parts black.
	// Had to make the black parts still in the image transparent through Gimp, since we changed to a .tga format.
	// (the specialists original quarterscope.spr asset just doesn't work)
	
	DRAW_IMAGE_EXPER(img_scope_quad, screenMid, '128 128', 0, vecSca, '0 0 0', 1.0f );
	DRAW_IMAGE_EXPER(img_scope_quad, screenMid, '128 128', 90, vecSca, '0 0 0', 1.0f );
	DRAW_IMAGE_EXPER(img_scope_quad, screenMid, '128 128', 180, vecSca, '0 0 0', 1.0f );
	DRAW_IMAGE_EXPER(img_scope_quad, screenMid, '128 128', 270, vecSca, '0 0 0', 1.0f );
	
	
	
	int magAmount = (int)(1.0f / (pl.flZoomLevel ));
	//int xOffset = drawSpriteNumber(ary_LCD_numberSet, 24, 24, magAmount, 3, BITS_DIGITOPT_NONE, clrPaleBlue, 0.88f);
			//[24 + xOffset + 1, 24 + 4]
	Gfx_Text( [24, 27], sprintf("%ix", magAmount), vFontArialScopeMag, clrPaleBlue, 0.95f, DRAWFLAG_ADDITIVE, FONT_ARIAL_SCOPEMAG );
			
	
	if(hasLasersight){
		vector lasDot;
		//draw em if ya gottem
		lasDot = vCenter + [-1, -1];
		drawfill( lasDot, [2, 2], clrRed, 0.70f, DRAWFLAG_NORMAL );
		
		
		if(pl.recentLaserHitPosSet){
			vector vDistNumberLoc = vCenter + [28, -8 - 8];
			drawSpriteNumber(ary_LCD_numberSet, vDistNumberLoc.x, vDistNumberLoc.y, pl.recentLaserDistanceDisplay, 3, BITS_DIGITOPT_NONE, clrPaleBlue, 0.91f);
		}
	}//END OF hasLasersight check
	
	
}
