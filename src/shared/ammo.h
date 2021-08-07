
#define ASSIGN_AMMODATA(arg_constName) ary_ammoData[AMMO_ID::##arg_constName] = (ammodata_t*) &ammo_##arg_constName;
#define DECLARE_AMMODATA(arg_varName, arg_sDisplayName, arg_fPricePerBullet, arg_iMax) ammodata_t ammo_##arg_varName = {arg_sDisplayName, arg_fPricePerBullet, arg_iMax};



enum AMMO_ID{
	NONE = 0,
	_9X19MM = 1,
	_45ACP = 2,
	_P50AE = 3,
	
	_5P7X28 = 4,
	
	_10MMAUTO = 5,
	_P22LR = 6,
	_P454CASULL = 7,
	_5P56NATO = 8,
	_7P62X39MM = 9,
	_50BMG = 10,
	_SHELLS = 11,
	
	// needed for the cut weapons from TS 2.0
	_32ACP = 12,
	_7P62X51MM = 13,
	
	LAST_ID = 14
};



typedef struct{
	string sDisplayName;
	float fPricePerBullet;
	int iMax;
	// fPricePerBullet * iMax = total cost to fill (added for the first weapon of a
	// given ammo type purchased)
} ammodata_t;


