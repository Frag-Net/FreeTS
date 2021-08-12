

// Use a set of sprites representing digits to draw a number.
// Has bits for other options like handling drawing leading 0's
// (like if 16 is drawn with 3 digits expected: 016).
int
drawSpriteNumber(
	imageCropBounds_t* arg_ary_spriteSet, int arg_draw_x, int arg_draw_y,
	int arg_quantityToDraw, int arg_digits, int arg_bits, vector arg_clr, float arg_opac
)
{
	// The "arg_bits" can give extra options about drawing. "0" means straight defaults.
	// NONE SUPPORTED YET.  If so, give enum like 
	
	//currently looking at leading 0's (whether they are drawn or not). The first non-zero digit stops this.
	BOOL leadingZeros = TRUE;
	
	int spriteWidth = arg_ary_spriteSet[0].vSize.x;
	int sprigeHeight = arg_ary_spriteSet[0].vSize.y;
	int quantityYet = arg_quantityToDraw;
	
	//if(arg_digits != -1){
		int maxPossible = pow(10, arg_digits) - 1;  //...9999, 999, 99, 9
		
		if(quantityYet < 0){
			// negatives not allowed, no need seen yet.
			// To support negatives, we could draw a negative sign left of the highest digit place possible or 
			// of the drawn digit (subjective) and force "quantityYet" positive to draw it as expected.
			quantityYet = 0;
		}else if(quantityYet > maxPossible){
			// force it to the max, that's all we can display
			//quantityYet = maxPossible;
			// ACTUALLY, go ahead and show this larger number anyway.
			// Just take each additional digit necessary and push everything to the right.
			// That is, if we planned on drawing 3 digits, but have to render the number 3600,
			// and are told to draw it at draw_x = 300, we may start drawing it at x=280 instead to
			// reach the same right point
			string tempString = itos(quantityYet);
			int digitsNeeded = (int)strlen(tempString);
			if(digitsNeeded > arg_digits){
				arg_draw_x -= (digitsNeeded - arg_digits)*spriteWidth;
				arg_digits = digitsNeeded;
			}
			
		}
	//}else{
	//	//no max constraint, but still no negatives yet.
	//	if(quantityYet < 0){
	//		quantityYet = 0;
	//	}
	//}
		
	int leftChange = 0;
	int digitCount = 0;
	int totalDrawWidth = 0;
	
	vector vDrawPosYet;
	for(int i = arg_digits; i >= 1; i--){
		vDrawPosYet.x = arg_draw_x + (arg_digits - i) * spriteWidth + leftChange;
		vDrawPosYet.y = arg_draw_y + 0;
		
		//pow(10, i) - 1;  //...9999, 999, 99, 9
		//pow(10, i-1);	//...1000, 100, 10, 1
		//pow(10, -(i-1));   //...0.001, 0.01, 0.1, 1
		
		float multi = pow(10, -(i - 1));
		float bigMulti = pow(10, (i - 1));
		int digitAtPlace = (int)(quantityYet * multi);
		
		if(leadingZeros == TRUE && digitAtPlace == 0 && i > 1){
			//another leading 0? this is a 0? Not the 1st digit?
			
			if(arg_bits & BITS_DIGITOPT_FILLER0){
				//still draw it here.
				//example, for drawing a value of 872 with 5 digits allowed:
				// 00872
				DRAW_IMAGE_CROPPED_ADDITIVE(arg_ary_spriteSet[digitAtPlace], vDrawPosYet, arg_clr, arg_opac)
				totalDrawWidth += spriteWidth;
			}else if(arg_bits & BITS_DIGITOPT_FILLERPAD){
				//this means, still skip over this space as though a filler digit were here.
				//example from above (5 digits):
				//   872  (two spaces for the unused 2 digits)
				//(this behavior is natural; nothing special happens)
			}else{
				//no filler0, no fillerPad?  Then skip over the space for unused digits.
				leftChange -= spriteWidth;
				//example from above:
				// 872
			}
			
		}else{
			// First non-zero digit makes leadingZeros FALSE for the first time.
			// Also, the very first digit must be drawn unconditionally. Even if 0.
			// All digits after this will be drawn.
			leadingZeros = FALSE;
			//draw digitAtPlace.
			DRAW_IMAGE_CROPPED_ADDITIVE(arg_ary_spriteSet[digitAtPlace], vDrawPosYet, arg_clr, arg_opac)
			totalDrawWidth += spriteWidth;
		}
		
		quantityYet = quantityYet - digitAtPlace*bigMulti;
	}
	
	//Not functional, but "quantityYet" should end up as "0" all the time.
	
	return totalDrawWidth;
}// drawSpriteNumber



// Convenience methods for drawing without any font-related struct, just some font's
// load ID. Otherwise close to the engine-provided drawstring and drawtextfield
// methods. "drawfont" is a global provided by the engine (fteextensions.qc).
// Compare with src/vgui/font.cpp's "Font_DrawText" and "Font_DrawField" which take a
// font struct.
void
Gfx_Text(vector vPos, string sText, vector vSize, vector vRGB, float flAlpha, float flDrawFlag, float flFont)
{
	drawfont = flFont;
	drawstring(vPos, sText, vSize, vRGB, flAlpha, flDrawFlag);
}

void
Gfx_TextLineWrap( vector vPos, vector vSize, float fAlignFlags, string sText, float flFont )
{
	drawfont = flFont;
	drawtextfield( vPos, vSize, fAlignFlags, sText );	
}


// Made from a blend of methods found in The Wastes.
void
Gfx_RotScalePic( string sImage, vector arg_vDrawPos, vector arg_vDrawPivot, vector vSize, float flAngle, vector vScale, vector vRGB, float flOpac )
{
	//vector mins = [0, 0];
	vector mins =
	[
	(-arg_vDrawPivot[0] + -vSize[0]/2) * vScale[0],
	(-arg_vDrawPivot[1] + -vSize[1]/2) * vScale[1]
	];
	vector maxs =
	[
	(-arg_vDrawPivot[0] + vSize[0]/2) * vScale[0],
	(-arg_vDrawPivot[1] + vSize[1]/2) * vScale[1]
	];
	
	//printfline("Gfx_RotScalePic - %.0f %.0f, %.0f %.0f", mins[0], mins[1], maxs[0], maxs[1]);
	vector vBaseSize = vSize;
	
	//Gfx_Pic( vPos + vScalePos, sImage, vScaleSize, vRGB, flAlpha, 0 );
	drawrotpic(arg_vDrawPos + [arg_vDrawPivot[0]*vScale[0], arg_vDrawPivot[1]*vScale[1]], mins, maxs, sImage, vRGB, flOpac, flAngle);
	// (time * 40) % 360
}


void
Gfx_ScalePicPreserveBounds(string sImage, vector arg_vDrawPos, vector vSize, vector vScale, vector vInset, vector vRGB, float flOpac)
{
	vector srcpos = [vInset[0], vInset[1]];
	vector srcsz;
	vector sz;
	
	//srcsz = vSize;
	srcsz[0] = 1.0 - (vInset[0]*2) ;
	srcsz[1] = 1.0 - (vInset[1]*2);
	
	sz[0] = vSize[0] * vScale[0];
	sz[1] = vSize[1] * vScale[1];
	
	vector vecOff;// = [0,0];
	vecOff[0] = -sz[0]/2;
	vecOff[1] = -sz[1]/2;
	
	//	drawsubpic(pos, sz, pic, srcpos, srcsz, rgb, alpha, 0);
	drawsubpic(arg_vDrawPos + vecOff, sz, sImage, srcpos, srcsz, vRGB, flOpac);  //, 0
}



// Cloned from src/menu-fn/w_label.qc
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




// Load the map description
// Do we have any use for this though?  Check original TS, the "Select Team"
// screen does (press enter to close or after closing the MoTD, probably)
string 
loadMapDescription(void)
{
	int i;
	filestream fmMapDescr;
	string sTemp;
	string sMapString_total = "";
	
	
	// If the mapname ends in .bsp, remove that portion, that causes
	// the appended ".txt" to work wrongly, "mymap.bsp.txt" instead of "mymap.txt".
	// This check for ending in ".bsp" adjusts for that if so
	string mapname_filtered = mapname;
	float mapname_len = strlen(mapname);
	// name is at least 5 characters (...X.bsp)
	if(mapname_len >= 5){
		string lastChars = substring(mapname, mapname_len - 4, 4);
		if(lastChars == ".bsp"){
			// change _filtered!
			mapname_filtered = substring(mapname, 0, mapname_len - 4);
		}
	}
	
	//printfline("loadMapDescription: mapname:%s mapname_filtered: %s", mapname, mapname_filtered);
	
	fmMapDescr = fopen( sprintf( "maps/%s.txt", mapname_filtered ), FILE_READ );
	if ( fmMapDescr != -1 ) {
		for (i = 0; i < 35; i++ ) {
			sTemp = fgets( fmMapDescr );
			if not ( sTemp ) {
				break;
			}
			sMapString[ i ] = sTemp;
			
			/*
			if (sMapString[ i ] == "/" ) {
				sMapString_total = strcat(sMOTD_total, "\n" );
			}else{
				sMapString_total = strcat(sMapString_total, sprintf("%s\n", sMapString[ i ]) );
			}
			*/
			sMapString_total = strcat(sMapString_total, sprintf("%s\n", sMapString[ i ]) );

		}
		fclose( fmMapDescr );
	}else{
		// No mapname.txt?  Could set sMapString_total to "No description found."
	}
	
	//printfline("map descriptor: %s", sMapString_total);
	return sMapString_total;
}//loadMapDescription

