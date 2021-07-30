

enum AMMO_ID{
	NONE = 0,
	_9x19mm = 1,
	_45Acp = 2,
	_p50AE = 3,
	
	_5p7x28 = 4,
	
	_10mmAUTO = 5,
	_p22LR = 6,
	_p454Casull = 7,
	_5p56Nato = 8,
	_7p62x39mm = 9,
	_50BMG = 10,
	_SHELLS = 11,
	
	//needed for the cut weapons from TS 2.0
	_32ACP = 12,
	_7p62x51mm = 13,
	
	LAST_ID = 14
};


#define ASSIGN_AMMODATA(arg_constName) ary_ammoData[AMMO_ID::##arg_constName] = (ammodata_t*) &ammo_##arg_constName;
#define DECLARE_AMMODATA(arg_varName, arg_sDisplayName, arg_fPricePerBullet, arg_iMax) ammodata_t ammo_##arg_varName = {arg_sDisplayName, arg_fPricePerBullet, arg_iMax};



typedef struct{
	string sDisplayName;
	float fPricePerBullet;
	int iMax;
	// fPricePerBullet * iMax = total cost to fill (added for the first weapon of a given ammo type purchased)
} ammodata_t;


