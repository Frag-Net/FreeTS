
#define ASSIGN_AMMODATA(arg_constName) ary_ammoData[AMMO_ID::##arg_constName] = (ammodata_t*) &ammo_##arg_constName;
#define DECLARE_AMMODATA(arg_varName, arg_sDisplayName, arg_fPricePerBullet, arg_iMax) ammodata_t ammo_##arg_varName = {arg_sDisplayName, arg_fPricePerBullet, arg_iMax};

#define ASSIGN_SHELLEJECTDATA(arg_constName) ary_shellEjectData[SHELLEJECT_ID::##arg_constName] = (shellejectdata_t*) &shelleject_##arg_constName;
#define DECLARE_SHELLEJECTDATA(arg_varName, arg_sModelPath, arg_sTouchSound) shellejectdata_t shelleject_##arg_varName = {arg_sModelPath, arg_sTouchSound};


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




// for shell ejection effects.
// Some are identical or near-identical, could have been intended to be unique
// models at some point but never happened?
enum SHELLEJECT_ID{
	NONE = 0,

	// Nearly identical, lighting looks to be the only difference, could even be
	// randomly picked for all I know.
	// Weapons will only use _56 of the two for now
	_56,
	_556,

	// These are identical, exact same filesize.
	// _GENERIC refers to shell.mdl
	// _22 is most likely referring to the luger's ammo, _9MM from the similarly named
	// ammo type.  Still using those first in weapons involving those
	_22,
	_9MM,
	_GENERIC,

	_SHOTGUN, // red
	_SHOTGUN_BLUE,
	_SHOTGUN_GOLD,
	LAST_ID
};


// any other info tied to shell choice?
typedef struct{
	string sModelPath;
	// script file (.sndshd) for hitting something, not a direct .wav file
	string sTouchSound;
	
} shellejectdata_t;

