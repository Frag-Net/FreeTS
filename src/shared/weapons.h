

class player;



// Doing at least this because nuclide's src/server/weapons.qc
// still expects it to exist.
// Used with the Nuclide-provided player.activeweapon, not to be confused
// with player.inventoryEquippedIndex for the currently selected aryWeapon
// inventory element.
#define WEAPON_NONE 0


//returned by weapon_base_onPrimaryAttack_melee to tell what type of thing was hit, since some
// aspects of a hit depend on knowing this (knives & katana have different sounds for each of
// these three scenarios)
// Other specifics like sound to make on hitting a surface / metal-spark effect are already
// handled in-method.  For karate (something with its own custom effects), just do that in its
// own file instead.
enum MELEE_HIT_RESPONSE{
	NONE = 0,   //usually an air whoosh sound
	SOFT = 1,	//some surface like dirt that has no metal hit sound, not even a miss.
	METAL = 2,  //metal clink sound to go with the automatic spark effect (TODO).
	FLESH = 3   //hit something living.
	
};

//These ID's exist separately of WEAPON_ID, are not corresponding,
//and are here only to keep track of the stats for the akimbo
//version of the weapon.
//Note that weapons that come only in akimbo (golden colts) don't
//actually get an entry here.  Their "WEAPON_ID" already points
//to something that is of WEAPONDATA_TYPEID_AKIMBO type.
enum WEAPON_AKIMBO_UPGRADE_ID{
	NONE = 0,
	SOCOMMK23 = 1,
	BERETTA = 2,
	FIVESEVEN = 3,
	MINIUZI = 4,
	SKORPION = 5,
	LAST_ID = 6
	
};


//For quick reference, singular and akimbo ties:
//SOKOM_MK23 = 9, SOCOMMK23_akimbo = 10
//Beretta = 2, Beretta_akimbo = 8
//FiveSeven = 14, FiveSeven_akimbo = 30
//MiniUzi = 4, MiniUzi_akimbo = 16
//Skorpion = 37, Skorpion_akimbo = 38


//NOTICE - "LAST_WEAPON_ID" must never change.
enum WEAPON_ID{
	NONE = 0,
	GLOCK18 = 1,
	BERETTA = 2,
	//SLOT2_UNUSED = 2,
	MINIUZI = 3,
	BENELLIM3 = 4,
	M4A1 = 5,
	MP5SD = 6,
	MP5K = 7,
	
	BERETTA_AKIMBO = 8,
	// Berettas will support the singular form and be upgradable into akimbo instead.
	// ...no, keep akimbo's with their own ID's in here, spawning should know how to handle
	// this.
	//Beretta = 8,
	
	SOCOMMK23 = 9,
	SOCOMMK23_AKIMBO = 10,
	
	USAS12 = 11,
	DESERTEAGLE = 12,
	AK47 = 13,
	FIVESEVEN = 14,
	STEYRAUG = 15,
	
	MINIUZI_AKIMBO = 16,
	
	STEYRTMP = 17,
	BARRETTM82 = 18,
	HKPDW = 19,
	SPAS12 = 20,
	AKIMBOCOLTS = 21,
	GLOCK20 = 22,
	//NOTICE!!! This (below) used to be "MAC10", but we're pretty sure this ID is really for
	// the UMP. There is no Mac10 in the specialists 2.1, or whatever I've been using.
	// This weapon likely replaced what used to be the MAC10 and its ID never got updated.
	// A new ID for the Mac10 has been provided further below under "NEW WEAPONS".
	// REVERSE.  We'll keep this as Mac10, the new ID will go to the UMP instead. Requested
	// preference to fit with the first one expected of 2.0 or slightly earlier maps.
	MAC10 = 23,
	//UMP = 23,
	
	M61GRENADE = 24,  //There's the grenade!  If it's ever made purchasable.
	COMBATKNIFE = 25,
	MOSSBERG500 = 26,
	M16A4 = 27,
	RUGERMK1 = 28,
	C4 = 29,
	
	FIVESEVEN_AKIMBO = 30,
	
	RAGINGBULL = 31,
	M60 = 32,
	SAWEDOFF = 33,
	KATANA = 34,
	SEALKNIFE = 35,
	// NEW WEAPONS
	CONTENDERG2 = 36,
	SKORPION = 37,
	SKORPION_AKIMBO = 38,
	
	// could also be MAC10 ?  any order for our unofficial weapon ID's is not regulated by maps
	// made for the original The Specialists.
	UMP = 39,
	
	// SEPARATE. Contained in the same system for convenience. May not be recognized by the map.
	
	//Not pickup-able but has to be stored the same way as other weapons.
	KARATE = 40,
	
	// These are items that can be purchased in the team-based game mode in original TS
	// Not weapons, just here for spawn convenience.  Or maybe these ID's will never be used.
	KEVLAR = 41,
	STEALTHSHOES = 42,
	
	
	LAST_ID = 43
	
};


// For now, a simple way to turn WEAPON_AKIMBO_UPGRADE_ID into WEAPON_ID:
int ary_AKIMBO_UPGRADE_TO_WEAPON[] = {
	WEAPON_ID::NONE,
	WEAPON_ID::SOCOMMK23_AKIMBO,
	WEAPON_ID::BERETTA_AKIMBO,
	WEAPON_ID::FIVESEVEN_AKIMBO,
	WEAPON_ID::MINIUZI_AKIMBO,
	WEAPON_ID::SKORPION_AKIMBO
};




// What akimbo weapons are involved, if asked?
// no, let's bitmask it.
/*
enum AkimboChoice{
	NONE = 0,  //???
	LEFT = 1,
	RIGHT = 2,
	BOTH = 3
};
*/
#define BITS_AKIMBOCHOICE_NONE 0
#define BITS_AKIMBOCHOICE_LEFT 1
#define BITS_AKIMBOCHOICE_RIGHT 2
#define BITS_AKIMBOCHOICE_BOTH (BITS_AKIMBOCHOICE_LEFT | BITS_AKIMBOCHOICE_RIGHT)




// melee weapons don't really do firemode.
// Can be used for burst-fire bullets too for bypassing some requirements.
#define BITS_FIREMODE_NONE 0

#define BITS_FIREMODE_BURST 1
#define BITS_FIREMODE_FULL 2
#define BITS_FIREMODE_SEMI 4
#define BITS_FIREMODE_PUMP 8


//AKIMBO

//???
#define BITS_FIREMODE_AKIMBO_NONE 0

#define BITS_FIREMODE_AKIMBO_SEMI_AUTO 1
#define BITS_FIREMODE_AKIMBO_FREE_SEMI 2
#define BITS_FIREMODE_AKIMBO_FULL_AUTO 4
#define BITS_FIREMODE_AKIMBO_FREE_FULL 8


//string getFiremodeName(int firemodeBit);
//string getAkimboFiremodeName(int firemodeBit);

string getFiremodeName(int firemodeBit){
	if(firemodeBit == BITS_FIREMODE_SEMI){
		return "Semi-auto";
	}else if(firemodeBit == BITS_FIREMODE_FULL){
		return "Full-auto";
	}else if(firemodeBit == BITS_FIREMODE_BURST){
		return "Burst";
	}else if(firemodeBit == BITS_FIREMODE_PUMP){
		return "Pump-action";
	}else{
		return "???";
	}
}

string getAkimboFiremodeName(int firemodeBit){
	if(firemodeBit == BITS_FIREMODE_AKIMBO_SEMI_AUTO){
		return "Semi-auto";
	}else if(firemodeBit == BITS_FIREMODE_AKIMBO_FREE_SEMI){
		return "Free Semi";
	}else if(firemodeBit == BITS_FIREMODE_AKIMBO_FULL_AUTO){
		return "Full-auto";
	}else if(firemodeBit == BITS_FIREMODE_AKIMBO_FREE_FULL){
		return "Free Full";
	}else{
		return "???";
	}
}



#define BITS_WEAPONOPT_NONE 0x00
#define BITS_WEAPONOPT_SILENCER 0x01
#define BITS_WEAPONOPT_LASERSIGHT 0x02
#define BITS_WEAPONOPT_FLASHLIGHT 0x04
#define BITS_WEAPONOPT_SCOPE 0x08
#define BITS_WEAPONOPT_AKIMBO 0x10
#define BITS_WEAPONOPT_FULLLOAD 0x20

// This is a special flag to say, skip showing buyoptions altogether. The buy button goes straight to
// buying the weapon.
//good for items (stealh shoes, kevlar)
#define BITS_WEAPONOPT_INSTANT 0x80000000

// Types of weapons that, if present, can be toggled on/off by the player.  Only some can.
// A lot of other behavior about this isn't automatic though, a change here does little elsewhere.
#define BITMASK_WEAPONOPT_TOGGLEABLE BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_FLASHLIGHT
// only min/max order of bits.
#define BITMASK_WEAPONOPT_TOGGLEABLE_MIN BITS_WEAPONOPT_LASERSIGHT
#define BITMASK_WEAPONOPT_TOGGLEABLE_MAX BITS_WEAPONOPT_FLASHLIGHT


#define BUYCATEGORY_NONE 0
#define BUYCATEGORY_HANDGUNS 1
#define BUYCATEGORY_SMGS 2
#define BUYCATEGORY_RIFLES 3
#define BUYCATEGORY_SHOTGUNS 4
#define BUYCATEGORY_SPECIALPURPOSE 5



#define WEAPONDATA_TYPEID_BASIC 0
#define WEAPONDATA_TYPEID_GUN 1
#define WEAPONDATA_TYPEID_IRONSIGHT 2
//#define WEAPONDATA_TYPEID_AKIMBO 3
#define WEAPONDATA_TYPEID_MELEE 3
//Note that THROWABLE is knives, not grenades.
#define WEAPONDATA_TYPEID_THROWABLE 4



#define ASSIGN_WEAPONDATA(arg_constName, arg_weaponName) ary_weaponData[WEAPON_ID::##arg_constName] = (weapondata_basic_t*) &weapon_##arg_weaponName;

// NOTICE - the ID lacks the "_akimbo" suffix.  The actual variable name has the "_akimbo" suffix.
// Just provide the name of the weapon without the "_akimbo" suffix and it will be added as needed
// automatically.
#define ASSIGN_AKIMBOUPGRADEDATA(arg_constName, arg_weaponName) ary_akimboUpgradeData[WEAPON_AKIMBO_UPGRADE_ID::##arg_constName] = (weapondata_basic_t*) &weapon_##arg_weaponName##_akimbo;



#define ary_myWeapons_length 16



/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
//NOTE - all below used to be in weapon.c	TESTING



//NOTE FROM weapons_official.txt - read this in and fill weapon values.
// or just hardcode it, maybe no one cares.
//values are : weapon id | accuracy | view kickback | accuracy kickback.
//-IMPORTANT:dont change weapon id
//-accuracy cant go under 0.001.
//-if you put an accuracy kickback of 0 accuracy will not be scaled.

//If you want use different weapon settings use the "customweapons" cvar,
//like "customweapons weapons_custom.txt". 
//By the way, be careful to use weapons custom values :)
//===========================================

//Glock-18
//1 0.022000 1.500000 0.007000


//var weapondata_t = {0.022000, 1.500000, 0.007000, }
//1 0.022000 1.500000 0.007000

typedef struct{
	float fAccuracy;
	float fViewKickback;
	float fAccuracyKickback;
	
} weapondata_firestats_t;



// HANDLING AKIMBO.
// Since ingame treats akimbo usage as its own separate selectable
// (that is, selecting the "Akimbo" BuyOption when buying a weapon adds a new selectable choie under
// slot #5 IN ADDITION TO giving the ordinary solo version of the weapon given even if Akimbo wasn't
// bought), it might be best to still consider 


// This stores information related to a place in the inventory to keep track of things about a weapon
// that are set at buy time or may change throughout its use such as clip size, buy options purchased, 
// the delay until firing is possible again, fire mode picked, etc.
// Has a link to the weapondata_t to get information from, and its type for faster casting.

//typedef struct{

// TODO. make this a struct instead? should be feasible.
// yes this is a class... hm. fix later.
class weapondynamic_t{
	PREDICTED_INT(weaponID); //what weapon is this referring to in the array of weapon data (glock, SOCOM, SMG, M4A1, etc.)
	PREDICTED_INT(weaponTypeID);	//what type of struct does the weapon use for convenient casting in lookups (gun, ironsight, melee, throwable)?
	
	// what did the player actually buy?
	// Also set this even for forced buyopts, such as the ruger's silencer.
	PREDICTED_INT(iBitsUpgrade);

	// How many of this weapon are equipped?  The Akimbo BuyOpt makes this potentially 2.
	// Weapons that come akimbo (golden colts) will still treat this as "1".
	// This is not for whether to use iClipAkimboLeft ever, that is handled by just looking at iBitsUpgrade.
	// This is for whether the current weapon should be treated as one (golden colts drop together in one
	// model) or whether dropping just removes the akimbo version.
	// Throwing knives can also use this iCount to stack instead.
	PREDICTED_INT(iCount);
	
	//Does keeping track of these things on an actual inventory'd weapon even makes sense?
	//Ah well, lazy client-server logic compatability for now.
	PREDICTED_INT(iPrice);
	PREDICTED_INT(iSlots);
	
	
	PREDICTED_INT(iClipLeft);
	PREDICTED_INT(iClipAkimboLeft);  //ammo left of the 2nd weapon if the akimbo option is present.
	
	// Buyopts flashlight and lasersight can be toggled on/off. The rest don't need
	// to be part of this bitmask to be on at all times.
	PREDICTED_INT(iBitsUpgrade_on);
	
	
	
	// What firemode is the player using for this weapon now?
	PREDICTED_INT(iFireMode);
	PREDICTED_INT(iFireModeAkimbo);
	
	// Is the player using ironsight (right-click)?  Also include checks for scoping / drawing overlays
	// in logic later if needed.
	// This is usually a boolean (0 or 1... off or on), but weapons with multiple magnifications can use
	// this to count too, such as for 2times or 10times. 0(off), 1(2x), 2(10x).
	PREDICTED_INT(iIronSight);
	
	// Do I force the first bodygroup's submodel to a certain choice?
	// NOTE - do not set to 0 during intended use!  That is only a lazy default to say, don't do anything
	// to the submodel on drawing this weapon.  Submodels actually start at 1, even if the only one.
	// If set to 0, the change will only be noticed on undrawing/drawing the weapon as the submodel will
	// not be applied then.  Set to 1 to change in real time (likely the intention).
	PREDICTED_INT(forceBodygroup1Submodel);
	
	
	void(void) weapondynamic_t;
	
};



void weapondynamic_t::weapondynamic_t(void){
	weaponID = 0;
	weaponTypeID = -1;
}



typedef struct{
	//These indexes can also be set to -1 to suggest, "none".
	int iAnim_Change_Index;
	float fAnim_Change_Duration;
	int iAnim_ReChange_Index;
	float fAnim_ReChange_Duration;
	
	int iAnim_Idle_Index;
	//frozen too.
	
	int iAnim_Reload_Index;
	float fAnim_Reload_Duration;
	
	//can have different firestats from ordinary firing.
	weapondata_firestats_t firestats;
	
	//int iBitsScopeMagChoices;
	
	
} ironsightdata_t;


// This struct only contains the bare minimum variables a class needs. Any other behavior should be
// handled by the custom methods.
// But note that weapondata_melee_t is identical for adding absolutely nothing.
// This may change of that type of weapon (really the katana, the rest are weapondata_throwable_t)
// ever need more specifics / variables.
typedef struct{
	int typeID;
	string sDisplayName;
	string sViewModelPath;  //1st person viewmodel
	string sPlayerModelPath;  //as attached to the player from a 3rd person view (or as seen by other players).
	string sPlayerSilencerModelPath;  //Separate player model to use if the silencer is an option. Yes. Really.
	string sWorldModelPath;  //a pickup that sits in the map; separated from any players.
	string sIconFilePath;  //icon for the inventory and buy menu.
	
	void(player pl, weapondynamic_t arg_thisWeapon) funOnPrimaryAttackRelease;
	void(player pl, weapondynamic_t arg_thisWeapon) funOnSecondaryAttackRelease;
	
	// Run every frame this weapon is equipped.
	// See if two think methods, for earlier or later (preframe / postframe) are needed.
	void(player pl, weapondynamic_t arg_thisWeapon) funOnThink;
	
	// This event is for a gun's melee attack, if supported. Actual melee weapons still use PrimaryAttack.
	// To see it in The Specialists (original beta 2), use this in console to bind cold cocking to the "c" key:
	// bind "c" "+alt2"
	void(player pl, weapondynamic_t arg_thisWeapon) funOnColdCock;
	
	// We'll handle firing animations (weapon recoil mainly) in their own methods.
	// Little too much going on. Number of animations to cylce through (shoot1, shoot2)?
	// separate batch for firing in semi-auto mode (sshoot1, sshoot2)?
	// and new ones for ironsight firing sometimes?
	
	
	int iAnim_Idle_Index;
	//no idle duration, they're all frozen.
	
	int iAnim_Deploy_Index;
	float fAnim_Deploy_Duration;
	
	float fAttackDelay;
	// How much damage a basic direct hit does. How this is reduced / increased with range
	// will depend on the weapon's own attack method.
	float fAttackDamage;
	
	// Can crosshairs be custom per weapon? unsure yet.
	// I think all weapon lasersights at the same behavor though. Measure distance and
	// change the crosshair a little.
	BOOL fDrawCrosshair;
	
	
	int iBitsUpgrade;
	int iBitsUpgradeAuto;  // same choices as UpgradeOptions but this comes with the weapon
	                       // on purchase.
						   // TODO - it might be a good idea to make the buy's upgrade
						   // options convey automatic upgrades.
	//These may be overridden by a differnet buy config file later (TODO).
	//--------------------------------------------------------------------------
	int iPrice;
	int iSlots;  // same idea as "Weight". More slots slows the player down and counts toward
	             // a limit.
	// Under what category in the buy menu will a button for buying this weapon be placed?
	int iBuyCategory;
	//--------------------------------------------------------------------------
	
	// What slot (number: 1, 2, 3, 4, 5... column of things) do I want to go to in the player's
	// inventory?
	int iInventorySlot;
	
	weapondata_firestats_t firestats;
	
	// If non-negative 1, which of WEAPON_AKIMBO_UPGRADE_ID (weapon.h) will I provide if
	// Akimbo is purchased?
	// NOTICE - akimbo-only weapons (golden colts) do NOT use this. Those weapondata's are
	// already set up to refer to things for the akimbo version such as shop icon, price,
	// and worldmodel.
	int iAkimboID;
	
	
} weapondata_basic_t;



typedef struct{
	int typeID;
	string sDisplayName;
	string sViewModelPath;
	string sPlayerModelPath;
	string sPlayerSilencerModelPath;
	string sWorldModelPath;
	string sIconFilePath;
	
	void(player pl, weapondynamic_t arg_thisWeapon) funOnPrimaryAttackRelease;
	void(player pl, weapondynamic_t arg_thisWeapon) funOnSecondaryAttackRelease;

	void(player pl, weapondynamic_t arg_thisWeapon) funOnThink;
	void(player pl, weapondynamic_t arg_thisWeapon) funOnColdCock;
	
	
	int iAnim_Idle_Index;
	
	int iAnim_Deploy_Index;
	float fAnim_Deploy_Duration;
	
	float fAttackDelay;
	float fAttackDamage;
	
	BOOL fDrawCrosshair;
	
	int iBitsUpgrade;
	int iBitsUpgradeAuto;
	
	//--------------------------------------------------------------------------
	int iPrice;
	int iSlots;
	int iBuyCategory;
	//--------------------------------------------------------------------------
	
	int iInventorySlot;
	
	//yes - even melee weapons have this.
	weapondata_firestats_t firestats;
	
	int iAkimboID;
	
	//!!!GUN SPECIFIC BELOW!!!
	int iBitsFireModes;
	int iBitDefaultFireMode;
	
	int iAmmoDataID;
	int iClipMax;
	
	int fRange;
	
	int iAnim_Reload_Index;
	float fAnim_Reload_Duration;
	
	//unfortunately, we gotta provide these for all weapons..	sigh.  feels ugly but it's simple.
	// Make it -1 for things not provided.  (if a buyopt still supports that _part var and it says -1,
	// we just still don't attempt any attachment changes)
	// ALSO keep in mind some things share the exact same attachment.  That is the five_seven's
	// lasersight and flashlight use the exact same attachment, so there is no difference between buying
	// either or both of them.  But this is not the case for all weapons, so assume these can be each
	// unique. I think some rifles like the m4a1 have all of these anyway.
	int silencer_part;
	int lasersight_part;
	int flashlight_part;
	int scope_part;
	
	
} weapondata_gun_t;



//started as a clone of weapondata_gun_t. Adds a firestats struct.
//Can hold this weapon to the side by right-clicking
//Note that if a weapon both has a scope and has a "secondary fire mode",
//the scope takes precedence (secondary fire mode no longer possible; always scopes).
typedef struct{
	int typeID;
	string sDisplayName;
	string sViewModelPath;
	string sPlayerModelPath;
	string sPlayerSilencerModelPath;
	string sWorldModelPath;
	string sIconFilePath;
	
	void(player pl, weapondynamic_t arg_thisWeapon) funOnPrimaryAttackRelease;
	void(player pl, weapondynamic_t arg_thisWeapon) funOnSecondaryAttackRelease;
	
	void(player pl, weapondynamic_t arg_thisWeapon) funOnThink;
	void(player pl, weapondynamic_t arg_thisWeapon) funOnColdCock;
	
	
	int iAnim_Idle_Index;
	
	int iAnim_Deploy_Index;
	float fAnim_Deploy_Duration;
	
	float fAttackDelay;
	float fAttackDamage;
	
	BOOL fDrawCrosshair;
	
	int iBitsUpgrade;
	int iBitsUpgradeAuto;
	//--------------------------------------------------------------------------
	int iPrice;
	int iSlots;
	int iBuyCategory;
	//--------------------------------------------------------------------------
	int iInventorySlot;
	
	//yes - even melee weapons have this.
	weapondata_firestats_t firestats;
	
	int iAkimboID;
	
	//!!!GUN SPECIFIC BELOW!!!
	int iBitsFireModes;
	int iBitDefaultFireMode;
	
	int iAmmoDataID;
	int iClipMax;
	
	int fRange;
	//!!!!!!!!!!!!!!!!!!!!
	int iAnim_Reload_Index;
	float fAnim_Reload_Duration;
	
	int silencer_part;
	int lasersight_part;
	int flashlight_part;
	int scope_part;
	
	// NEW
	ironsightdata_t ironsightdata;
	
} weapondata_ironsight_t;



typedef struct{
	int typeID;
	string sDisplayName;
	string sViewModelPath;
	string sPlayerModelPath;
	string sPlayerSilencerModelPath;
	string sWorldModelPath;
	string sIconFilePath;
	
	void(player pl, weapondynamic_t arg_thisWeapon) funOnPrimaryAttackRelease;
	void(player pl, weapondynamic_t arg_thisWeapon) funOnSecondaryAttackRelease;
	
	void(player pl, weapondynamic_t arg_thisWeapon) funOnThink;
	void(player pl, weapondynamic_t arg_thisWeapon) funOnColdCock;
	
	
	int iAnim_Idle_Index;
	
	int iAnim_Deploy_Index;
	float fAnim_Deploy_Duration;
	
	float fAttackDelay;
	float fAttackDamage;
	
	BOOL fDrawCrosshair;
	
	int iBitsUpgrade;
	int iBitsUpgradeAuto;
	//--------------------------------------------------------------------------
	int iPrice;
	int iSlots;
	int iBuyCategory;
	//--------------------------------------------------------------------------
	
	int iInventorySlot;
	
	// yes - even melee weapons have this.
	weapondata_firestats_t firestats;
	
	int iAkimboID;
	
	// nothing else needed.
	// But the katana does seem to cause some sweeping animation (slow down/stop player movement) on
	// attacking while crouching.  However that's to be integrated.
	
} weapondata_melee_t;



typedef struct{
	int typeID;
	string sDisplayName;
	string sViewModelPath;
	string sPlayerModelPath;
	string sPlayerSilencerModelPath;
	string sWorldModelPath;
	string sIconFilePath;
	
	void(player pl, weapondynamic_t arg_thisWeapon) funOnPrimaryAttackRelease;
	void(player pl, weapondynamic_t arg_thisWeapon) funOnSecondaryAttackRelease;
	
	void(player pl, weapondynamic_t arg_thisWeapon) funOnThink;
	void(player pl, weapondynamic_t arg_thisWeapon) funOnColdCock;
	
	
	int iAnim_Idle_Index;
	
	int iAnim_Deploy_Index;
	float fAnim_Deploy_Duration;
	
	float fAttackDelay;
	float fAttackDamage;
	
	BOOL fDrawCrosshair;
	
	int iBitsUpgrade;
	int iBitsUpgradeAuto;
	//--------------------------------------------------------------------------
	int iPrice;
	int iSlots;
	int iBuyCategory;
	//--------------------------------------------------------------------------
	
	int iInventorySlot;
	
	//yes - even melee weapons have this.
	weapondata_firestats_t firestats;
	
	int iAkimboID;
	
	//THROWABLE INFO.
	// Really just the max count of this weapon allowed for throwing (secondary fire) to work.
	// The same iCount var in the dynamic player weapon info, weapondynamic_t, will work for counting
	// how many the player actually has at the time & unequip itself if the last knife is thrown.
	int iMaxCount;
	// ALSO, how much damage do I do when thrown?  Unsure what could change how much is dealt yet.
	float fThrowDamage;
	// How fast am I moving when thrown?
	float fThrowSpeed;
	// How fast do I fall?  1 = normal gravity, less goes further before hitting the ground.
	// 0 = no gravity (straight line movement).
	// Some things like crossbow bolts seem to go straight for so far, then start to fall.
	// Most likely not relevant here though.
	float fThrowGravity;
	
	
} weapondata_throwable_t;




// arbitrary, unreatled to weaponID's.  Assign to some var in the player
// at draw (equip) time or send along shotgun-related method calls, no idea
// what route is best.
// No need for a NONE choice, leftover choice on weapon changes doesn't matter
// if the current weapon never does anything that looks at shotgun extra info.
// Also, shotguns that have ironsight need another entry for that because ironsight has
// its own set of sequences.  
enum SHOTGUN_EXTRA_ID{
	BENELLIM3 = 0,
	MOSSBERG500,
	MOSSBERG500_IRONSIGHT,
	SPAS12,
	LAST_ID
};

// There is no 'weapondata_shotgun'.  Instead, shotguns can use some extra
// stats.  Requires its own enum as there won't be one for every single weaponID.
typedef struct{
	int shotgunReload1_seq;
	float shotgunReload1_Duration;
	
	int shotgunReload2_seq;
	float shotgunReload2_Duration;
	float shotgunReload2_ammoLoadDelay;
	
	int shotgunReload3_seq;
	float shotgunReload3_Duration;
} weapondata_shotgun_extra_t;



//TODO. Is extern'ing these earlier possible?
ammodata_t* ary_ammoData[AMMO_ID::LAST_ID];
shellejectdata_t* ary_shellEjectData[SHELLEJECT_ID::LAST_ID];

//weapondata_normal_t* ary_weaponData[WEAPON_ID::LAST_ID];
//Void pointer should be fine, right? Cast to the right weapondata_ struct above (typeID tells what that is).
//actually make it weapondata_basic_t, which at least includes the typeID and some other basic stuff
weapondata_basic_t* ary_weaponData[WEAPON_ID::LAST_ID];
weapondata_basic_t* ary_akimboUpgradeData[WEAPON_AKIMBO_UPGRADE_ID::LAST_ID];

weapondata_shotgun_extra_t* ary_shotgunExtra[SHOTGUN_EXTRA_ID::LAST_ID];





void weapon_base_setWholeAttackDelay(player pl, float amount);
void weapon_base_setLeftAttackDelay(player pl, float amount);
void weapon_base_setRightAttackDelay(player pl, float amount);
void weapon_base_setLeftAttackDelay_AtLeast(player pl, float amount);
void weapon_base_setRightAttackDelay_AtLeast(player pl, float amount);


MELEE_HIT_RESPONSE weapon_base_coldcock(player pl, weapondata_basic_t* basePRef, weapondynamic_t arg_thisWeapon, float damageToDeal, float range );


void weapon_base_onEquip(player pl, weapondata_basic_t* basePRef, weapondynamic_t arg_thisWeapon);

MELEE_HIT_RESPONSE weapon_base_onPrimaryAttack_melee(player pl, weapondata_basic_t* basePRef, weapondynamic_t arg_thisWeapon, float damageToDeal, float range);
MELEE_HIT_RESPONSE weapon_base_onPrimaryAttack_melee_fromCustomDirection(player pl, weapondata_basic_t* basePRef, weapondynamic_t arg_thisWeapon, float damageToDeal, float range, vector customAngle );

void weapon_base_onAttack(player pl, weapondata_basic_t* basePRef, weapondynamic_t arg_thisWeapon, int attackTypeUsed);
void weapon_base_onAttack_multi(player pl, weapondata_basic_t* basePRef, weapondynamic_t arg_thisWeapon, int shellCount, int attackTypeUsed);


void weapon_gun_burstFire(player pl, weapondata_gun_t* basePRef, weapondynamic_t arg_thisWeapon, int attackTypeUsed, int shotCount, float shotDelay, float attackDelay);

BOOL weapon_shotgun_onInterrupt(player pl, weapondata_basic_t* basePRef, weapondynamic_t arg_thisWeapon);
void weapon_shotgun_reload(player pl, weapondata_basic_t* basePRef, weapondynamic_t arg_thisWeapon);
void weapon_shotgun_onThink_reloadLogic(player pl, weapondata_gun_t* basePRef, weapondynamic_t arg_thisWeapon);

void weapon_gun_akimbo_semi_primaryAttack(void(player pl, weapondynamic_t arg_thisWeapon, int attackTypeUsed) arg_funAttack);
void weapon_gun_akimbo_semi_secondaryAttack(void(player pl, weapondynamic_t arg_thisWeapon, int attackTypeUsed) arg_funAttack);
void weapon_ironsight_akimbo_semi_secondaryAttack(void(player pl, weapondynamic_t arg_thisWeapon, int attackTypeUsed) arg_funAttack, int arg_weaponTypeID);

void weapon_gun_akimbo_full_primaryAttack(void(player pl, weapondynamic_t arg_thisWeapon, int attackTypeUsed) arg_funAttack);
void weapon_gun_akimbo_full_secondaryAttack(void(player pl, weapondynamic_t arg_thisWeapon, int attackTypeUsed) arg_funAttack);

BOOL weapon_akimbo_semiAttackDualHack(player pl, weapondynamic_t arg_thisWeapon, int arg_flagger, void(player pl, weapondynamic_t arg_thisWeapon, int attackTypeUsed) arg_funAttack);
BOOL weapon_akimbo_fullAttackDualHack(player pl, weapondynamic_t arg_thisWeapon, int arg_flagger, void(player pl, weapondynamic_t arg_thisWeapon, int attackTypeUsed) arg_funAttack);
BOOL weapon_akimbo_AttackDualHack(player pl, weapondynamic_t arg_thisWeapon, int arg_flagger, void(player pl, weapondynamic_t arg_thisWeapon, int attackTypeUsed) arg_funAttack);

int weapon_akimbo_semiAttackChoice(player pl, weapondata_basic_t* basePRef, weapondynamic_t arg_thisWeapon, int attackTypeUsed);
int weapon_akimbo_fullAttackChoice(player pl, weapondata_basic_t* basePRef, weapondynamic_t arg_thisWeapon, int attackTypeUsed);


void weapon_ironsight_ToggleIronsight(player pl, weapondata_ironsight_t* basePRef, weapondynamic_t arg_thisWeapon);


void weapon_gun_Reload(player pl, weapondata_gun_t* basePRef, weapondynamic_t arg_thisWeapon );
void weapon_gun_Reload_CustomSequence(player pl, weapondata_gun_t* basePRef, weapondynamic_t arg_thisWeapon, int arg_iReloadSeq, float arg_flReloadSeqTime);
void weapon_ironsight_Reload(player pl, weapondata_ironsight_t* basePRef, weapondynamic_t arg_thisWeapon );

void weapon_gun_endOfReload(player pl, weapondata_gun_t* basePRef, weapondynamic_t arg_thisWeapon );
void weapon_gun_endOfIronSight(player pl, weapondata_gun_t* basePRef, weapondynamic_t arg_thisWeapon);


void weapon_gun_onThink(player pl, weapondata_gun_t* basePRef, weapondynamic_t arg_thisWeapon );

void weapon_gun_fireBurstBullet(player pl, weapondata_gun_t* basePRef, weapondynamic_t arg_thisWeapon);

void weapon_gun_onThink_burstFireLogic(player pl, weapondata_gun_t* basePRef, weapondynamic_t arg_thisWeapon );

void weapon_gun_onDrawHUD(player pl, weapondata_gun_t* basePRef, weapondynamic_t arg_thisWeapon);
void weapon_throwable_onDrawHUD(player pl, weapondata_throwable_t* basePRef, weapondynamic_t arg_thisWeapon);
void weapon_melee_onDrawHUD(player pl, weapondata_melee_t* basePRef, weapondynamic_t arg_thisWeapon);

void weapon_ejectShell(int arg_shellEjectType);

void weapon_precache(weapondata_basic_t* basePRef);

//void weapon_gun_updateAmmo(player pl, weapondata_gun_t* basePRef, weapondynamic_t arg_thisWeapon);
void weapon_gun_updateAmmo(player pl, int weaponTypeID);

void setupWeaponData(void);



// simplified form of dynamic weapon info that only records buy upgrades purchased for a weapon.
// Note that, for akimbo-upgraded weapons, the extra akimbo version will be displayed in the inventory
// in addition to the singular version, but for removing items this still counts as a single item in the
// inventory. The akimbo version cannot be separately selected / removed to make only the singular
// version appear in the inventory like dropping can. For akimbo-only weapons, works as epxected. 

// NOTE - the "full load" upgrade for throwables isn't really a permanent option, it's just a signal
// to buy enough throwables to raise the count to the max.  If that can be affored in price/slots of
// course.
typedef struct weaponconfig_weapon_s{
//class weaponconfig_weapon_t{
	
	// what weapon is this referring to?
	int weaponID;
	
	// quick reference for struct type.
	int weaponTypeID;
	
	// what upgrades have been purchased?
	int iBitsUpgrade;
	// How many are purchased?  Can be used to tell whether an akimbo weapon was upgraded (include its
	// singular version) or akimbo-only. Also used by throwables to see how many have been purchased yet.
	// Removing an item, regardless of its existing count, removes it entirely, does not drop the count
	// by 1 and adjust.
	int iCount;
	
	// what is the total cost of this weapon yet including upgrades (excludes extra from buying ammo)
	// Also including akimbo and extra throwables of the same type.
	int iPrice;
	int iSlots;

	// No methods for the wicked
	//void(void) weaponconfig_weapon_t;
} weaponconfig_weapon_t;
//};


/*
void weaponconfig_weapon_t::weaponconfig_weapon_t(void){
	
}
*/



// This struct stores info for a single config in the buy menu. It records weapons, their purchased
// upgrades, and ammo types purchased.
typedef struct weaponconfig_data_s{
//class weaponconfig_data_t{
	
	// What weapons has the user purchased?
	// Note that purchasing the same weapon removes the existing and all upgrades not re-purchased.
	// It may be best to subtract the one to be replaced's price before deciding that the change is
	// too expensive or not.
	// That is, if there are 1800 dollars available, and a 1000 glock has been purchased,
	// going akimbo for that same glock is still affordable.  That's 2800 available excluding the
	// to-be-replaced glock, so there is enough to buy the akimbo version (2000).
	// Suspiciously other upgrades like lasersight / silencer per weapon are not doubled per akimbo
	// (verify?) but it's a good thing no one cares.
	weaponconfig_weapon_t ary_myWeapons[ary_myWeapons_length];
	int ary_myWeapons_softMax;
	
	// How much ammo of each of the pools do I store?
	// Picking a weapon that uses a type of ammo for the first time (such as the first 9x19mm-using
	// weapon) will cost extra compared to the expected buyprice, even without upgrades, because this
	// includes the cost of buying max ammunition for that ammo pool.
	// Buying any more weapons using the same type of ammunition will not incur the same extra price
	// (already have its ammo purchased).
	int ary_ammoTotal[AMMO_ID::LAST_ID];
	
	//How many slots does the current order take? Provided for quick access.
	int iTotalSlots;
	int iTotalPrice;   //ditto
	
	// No methods for the wicked
	//void(void) weaponconfig_data_t;
	
} weaponconfig_data_t;
//};


void weaponconfig_data_init(weaponconfig_data_t* arg_this);
weapondata_basic_t* getWeaponData(int arg_weaponID, BOOL arg_akimbo);
weapondata_basic_t* getWeaponData_Singular(int arg_weaponID);
int getAmmoTypeOfWeapon(int arg_weaponID);


#ifdef CLIENT
void viewEv_playShotgunInsertShellSound(void);

// TEMP DUMMY
void w_ejectshell_pistol(void){};

void viewEv_weapon_ejectShell(void);

void copyWeaponConfig(weaponconfig_weapon_t* arg_dest, weaponconfig_weapon_t* arg_src);
void copyConfig(weaponconfig_data_t* arg_dest, weaponconfig_data_t* arg_src);
#endif



