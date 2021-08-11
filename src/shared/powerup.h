
// New File.
// NOTE - this is not the actual entity ingame, that is server/ts_powerup.h (which is also included 
// clientside for its rendering portion... might want to move the file to 'shared' later)


// basing the order on spawnflag order (add-ins paired with originals one-after-the-other)
enum POWERUP_ID{
	NONE = 0,
	SlowMotion,
	InfiniteClip,
	DoubleClip,
	KungFu,
	SlowPause,
	SlowPauseOld,
	DoubleFirerate,
	Grenade,
	Health,
	Armor,
	SuperJump,   //more accurate name than "Low Gravity"
	LAST_ID
};




#define POWERUPDATA_TYPEID_BASIC 0
#define POWERUPDATA_TYPEID_INSTANT 1
#define POWERUPDATA_TYPEID_USABLE 2



#define ASSIGN_POWERUPDATA(arg_constName) ary_powerupData[POWERUP_ID::##arg_constName] = (powerupdata_basic_t*) &powerup_##arg_constName;

 
typedef struct{
	// what type am I for base behavior?
	int typeID;
	// only useful for usables for telling what they are while equipped, but hey, why not for everything.
	string sDisplayName;
	// Of powerup.mdl, for the 1st (and only) bodygroup, what submodel do I use?
	// Counting starts at 1 oddly enough.
	int iSubmodelChoice;
	// What do I do when touched?
	// use 'other' to get what player touched this.
	void(void) Touch;
	
} powerupdata_basic_t;


 
typedef struct{
	int typeID;
	string sDisplayName;
	int iSubmodelChoice;
	void(void) funOnTouch;
	
	// SPECIFIC TO INSTANT EFFECT
	// ...nothing.  Think about it, it's touched and it's gone.
	// Even usables have to do something on touch though.
	// Permanent or not (super-jump versus health or armor), same as far as design goes:
	// set/adjust some flag that changes behavior, or set/adjust some stat on touch.
	// Handle this per powerup.
	
} powerupdata_instant_t;


typedef struct{
	int typeID;
	string sDisplayName;
	int iSubmodelChoice;
	void(void) funOnTouch;
	
	// SPECIFIC TO USABLE
	// How long do I last once used?
	float fActiveDuration;
	// What do I do when used?  Generally set some stat(s)/flag(s) to get the effect,
	// like telling bullets, player movement, etc. how much to be slowed down by for instance.
	void(player pl) funOnUse;
	// At the end of my duration, how do I reset the things I set to act as though nothing happened?
	// Should run on player death or disconnect (if necessary) too as to not leave lingering effects.
	void(player pl) funOnEnd;
	// Note that we have no think effect.  Nothing could be done frame-by-frame that would help
	// any of the powerups do what it needs to.  Speed modifiers of any sort (slow-mo) can't force
	// nearby stuff to move slower directly, it sets a flag on use that tells physics to move that stuff
	// slower instead and unsets that flag when it ends.
	
} powerupdata_usable_t;



powerupdata_basic_t* ary_powerupData[POWERUP_ID::LAST_ID];


#ifdef SERVER
class CTSPowerUp;
extern void powerup_linkToStruct(CTSPowerUp arg_entity, POWERUP_ID arg_id);
#endif

extern void setupPowerupData(void);



