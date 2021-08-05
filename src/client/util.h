


#define BITS_DIGITOPT_NONE 0
#define BITS_DIGITOPT_FILLER0 1
//Give filler 0's in front of the largest used digit if there were leftover digits
#define BITS_DIGITOPT_FILLERPAD 2
//Give filler padding (just space) in front of the largest used digit if there were leftover digits

// *** NOTICE - FILLER0 and FILLERPAD are incompatible. Use neither or either.

#define BITS_DIGITOPT_DEFAULT BITS_DIGITOPT_FILLERPAD


// space between the quote-pairs or not, and it concatenates it.
#define CREATE_imageFileRef_t(arg_newVarName, arg_sFilePath, arg_w, arg_h) imageFileRef_t arg_newVarName = { arg_sFilePath"_0.tga" , arg_w, arg_h};

//New version that does not do the "_0.tga" addition.
// We may want to use straight .tga files sometimes, which shouldn't get this change.
#define CREATE_imageFileRef_raw_t(arg_newVarName, arg_sFilePath, arg_w, arg_h) imageFileRef_t arg_newVarName = { arg_sFilePath, arg_w, arg_h};


#define CREATE_imageCropBounds_t(arg_newVarName, arg_imageFileRef, arg_srcPos_x, arg_srcPos_y, arg_srcSiz_x, arg_srcSiz_y) imageCropBounds_t arg_newVarName = {arg_imageFileRef, [arg_srcSiz_x, arg_srcSiz_y], [arg_srcPos_x/arg_imageFileRef.w, arg_srcPos_y/arg_imageFileRef.h], [arg_srcSiz_x/arg_imageFileRef.w, arg_srcSiz_y/arg_imageFileRef.h]};

//NO arg_vDrawScale. would have come after "arg_vDrawPos".  A version that supports scaling can be done if needed.
//#define DRAW_IMAGE_BOUNDS_ADDITIVE(arg_sImageFileName, arg_imgBoundsVarName, arg_vDrawPos, arg_RGB, arg_alpha)

#define DRAW_IMAGE_CROPPED_ADDITIVE(arg_cropBoundsVarName, arg_vDrawPos, arg_RGB, arg_alpha) drawsubpic(arg_vDrawPos, arg_cropBoundsVarName.vSize, arg_cropBoundsVarName.myImageFileRef.sFilePath, arg_cropBoundsVarName.vCropStart, arg_cropBoundsVarName.vCropSize, arg_RGB, arg_alpha, DRAWFLAG_ADDITIVE);


//And a simple version
//scale not supported yet - can add that if needed.
#define DRAW_IMAGE_ADDITIVE(arg_imageFileRefVarName, arg_vDrawPos, arg_clr, arg_alpha) drawsubpic(arg_vDrawPos, [arg_imageFileRefVarName.w, arg_imageFileRefVarName.h], arg_imageFileRefVarName.sFilePath, [0, 0], [1, 1], arg_clr, arg_alpha, DRAWFLAG_ADDITIVE);

#define DRAW_IMAGE_NORMAL(arg_imageFileRefVarName, arg_vDrawPos, arg_clr, arg_alpha) drawsubpic(arg_vDrawPos, [arg_imageFileRefVarName.w, arg_imageFileRefVarName.h], arg_imageFileRefVarName.sFilePath, [0, 0], [1, 1], arg_clr, arg_alpha, DRAWFLAG_NORMAL);


#define DRAW_IMAGE_EXPER(arg_imageFileRefVarName, arg_vDrawPos, arg_vDrawPivot, flAngle, vScale, vRGB, flOpac) Gfx_RotScalePic(arg_imageFileRefVarName.sFilePath, arg_vDrawPos, arg_vDrawPivot, [arg_imageFileRefVarName.w, arg_imageFileRefVarName.h], flAngle, vScale, vRGB, flOpac)
#define DRAW_IMAGE_EXPER2(arg_imageFileRefVarName, arg_vDrawPos, vScale, vInset, vRGB, flOpac) Gfx_ScalePicPreserveBounds(arg_imageFileRefVarName.sFilePath, arg_vDrawPos, [arg_imageFileRefVarName.w, arg_imageFileRefVarName.h], vScale, vInset, vRGB, flOpac)




#if defined(CLIENT) || defined(MENU)

//TAGGG - just give those bits names
#define DRAWTEXTFIELD_ALIGN_LEFT 1
#define DRAWTEXTFIELD_ALIGN_TOP 2
#define DRAWTEXTFIELD_ALIGN_RIGHT 4
#define DRAWTEXTFIELD_ALIGN_BOTTOM 8

//Use below to get an intention in one constant.
#define DRAWTEXTFIELD_ALIGN_CENTER_CENTER 0
#define DRAWTEXTFIELD_ALIGN_LEFT_CENTER 1
#define DRAWTEXTFIELD_ALIGN_LEFT_TOP 1|2
#define DRAWTEXTFIELD_ALIGN_CENTER_TOP 2
#define DRAWTEXTFIELD_ALIGN_RIGHT_TOP 4|2
#define DRAWTEXTFIELD_ALIGN_RIGHT_CENTER 4
#define DRAWTEXTFIELD_ALIGN_RIGHT_BOTTOM 4|8
#define DRAWTEXTFIELD_ALIGN_CENTER_BOTTOM 8
#define DRAWTEXTFIELD_ALIGN_LEFT_BOTTOM 1|8

#endif



typedef struct{
	string sFilePath;
	float w;
	float h;
} imageFileRef_t;

typedef struct{
	imageFileRef_t myImageFileRef;
	vector vSize;
	
	//NOTICE - vCropStart and vCropSize are fractions (decimals, between 0 and 1) that 
	//		 show what portion of the picked image to crop from.
	//		 uhh... somewhere this decision may make sense?
	vector vCropStart;
	vector vCropSize;
	/*
	float x;
	float y;
	float w;
	float h;
	*/
} imageCropBounds_t;



int drawSpriteNumber(imageCropBounds_t* arg_ary_spriteSet, int arg_draw_x, int arg_draw_y, int arg_quantityToDraw, int arg_digits, int arg_bits, vector arg_clr, float arg_opac);
void Gfx_Text(vector vPos, string sText, vector vSize, vector vRGB, float flAlpha, float flDrawFlag, float flFont);
void Gfx_TextLineWrap( vector vPos, vector vSize, float fAlignFlags, string sText, float flFont );
void Gfx_RotScalePic( string sImage, vector arg_vDrawPos, vector arg_vDrawPivot, vector vSize, float flAngle, vector vScale, vector vRGB, float flOpac );
void Gfx_ScalePicPreserveBounds(string sImage, vector arg_vDrawPos, vector vSize, vector vScale, vector vInset, vector vRGB, float flOpac);


