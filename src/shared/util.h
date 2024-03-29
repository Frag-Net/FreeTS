
// GENERAL FTE NOTE!
// Don't use 'extern' on method prototypes, it makes no difference and the compiler prints
// a spammy warning "Only global functions may be defined as external (yet)" without a line
// number when it sees it.
// Or it happens anyway and I have no clue what I'm going on about.
// Maybe even externing var's does it.


// also, FTE needs a space after a preprocessor macro name for a slash to drop-down to the
// rest of the definition, like "#define thing \".

///////////////////////////////////////////////////////////////////////////






#define NULL __NULL__

#define BOOL float
#define BOOLEAN float

// plain printouts, no client/server tagging
//#define printf(...) print(sprintf(__VA_ARGS__))
//#define printfline(s1, ...) print(sprintf(s1"\n" __VA_ARGS__))
//#define printlinef(s1, ...) print(sprintf(s1"\n" __VA_ARGS__))


////////////////////////////////////////////////////////
// TODO - let some easy constant, or even just "debug", specify whether to include
// the CL or SV in front.  But we don't know how many re-updates from modern files
// will happen between now and then.

// ALSO - Nuclide now provides printf, but without the ellipses parameter.
// That means Nuclide's printf is only a shortener of print + sprintf for calls
// without any other fill-ins (%d, etc.).
// Undoing that here for now, compatible with original calls anytime.

// And do we care about bprint (broadcast-print)?  Example:
//    	bprint(PRINT_HIGH, sprintf("SSQC: %s", sWow) );
// Probably not for debugging as printf is working fine for the typical rapid-fire
// single player debug.

#ifdef printf
#undef printf
#endif


#ifdef CLIENT
#define printf_starter print("CL")
#define printf(s1, ...) print(sprintf(s1, ##__VA_ARGS__))
#define printfline(s1, ...) print(sprintf("CL: "s1"\n", ##__VA_ARGS__))
#define printlinef(s1, ...) print(sprintf("CL: "s1"\n", ##__VA_ARGS__))
#else
#define printf_starter print("SV")
#define printf(s1, ...) print(sprintf(s1, ##__VA_ARGS__))
#define printfline(s1, ...) print(sprintf("SV: "s1"\n", ##__VA_ARGS__))
#define printlinef(s1, ...) print(sprintf("SV: "s1"\n", ##__VA_ARGS__))
#endif

// could dummy printouts by enabling this block instead of the above
/*
#define printf_starter
#define printf(s1, ...)
#define printfline(s1, ...)
#define printlinef(s1, ...)
*/

// Safe way to declare an entity seen in FreeHL.  Think of it as:
//     arg_dest = spawnfunc_ClassNameHere;
// This lets the constructor invoked by 'spawnfunc_' have a 'self' set
// to the place it will end up going to, and restores 'self' after the
// call is over.
// NOTE!  Requires an entity to be declared called 'eold' first, like so:
//     entity eold;
// Doing that in case of subsequent SPAWN_ENTITY_SAFE calls.
// Would declaring 'eold' globally be okay for the entire game?  Hard to say.
// NOTE - if you do indeed want the current entity to become of the new type,
// then moving around 'self' like this is unnecessary, just call the 'pawnfunc_'
// as usual.
// I'm fuzzy on the details between 'spawn(CLASSNAME)' and 'spawnfunc_CLASSNAME'.
// If you don't know what you're doing just spawn a clean entity like the former
// approach, this is actually for changing something already spawened into another
// type.  Parse functions may do this to turn a default entity they receive into
// whatever their custom type is, as seen in ts_powerup
#define SPAWN_ENTITY_SAFE(arg_dest, arg_class) \
    eold = self;\
    self = arg_dest;\
    spawnfunc_##arg_class();\
    self = eold;



// will anywhere shared ever need this?
#ifdef CLIENT
#define GET_GAME_STATE getstatf(STAT_GAMESTATE)
#else
#define GET_GAME_STATE g_ts_gamestate
#endif


// !!! Other weapons-related macros
////////////////////////////////////////////////////////

// OLD INPUT WAY
// is setting gflags_net too a good idea?  That applies to a whole host of other
// things too.

// use 1 for the closest to Nuclide defaults, 2 for a little extra frame tolerance for
// clientside.
#define INPUT_TAP_DETECT_CHOICE 1



#if INPUT_TAP_DETECT_CHOICE == 1
///////////////////////////////////////////////////////////////////////////////////////////
// Standard way.
#define INPUT_PRIMARY_TAP_GATE \
	if (pl.gflags & GF_SEMI_TOGGLED)\
		return;
#define INPUT_SECONDARY_TAP_GATE \
	if (pl.gflags & GF_SEMI_SECONDARY_TOGGLED)\
		return;
#define INPUT_PRIMARY_TAP_CHECK(arg_pl) (!(pl.gflags & GF_SEMI_TOGGLED))
#define INPUT_SECONDARY_TAP_CHECK(arg_pl) (!(pl.gflags & GF_SEMI_SECONDARY_TOGGLED))
#define INPUT_PRIMARY_TAP_CHECK_NOT(arg_pl) (pl.gflags & GF_SEMI_TOGGLED)
#define INPUT_SECONDARY_TAP_CHECK_NOT(arg_pl) (pl.gflags & GF_SEMI_SECONDARY_TOGGLED)
#define INPUT_TAP_RESET(arg_pl) \
	arg_pl.gflags |= GF_SEMI_TOGGLED; \
	arg_pl.gflags |= GF_SEMI_SECONDARY_TOGGLED;

#else
///////////////////////////////////////////////////////////////////////////////////////////
// ALTERNATE WAY: check pl.inputTapFrameCount for primary/secondary.
// Lets setting an extra frame for a little more tolerance work, these are
// set to 1 on a fresh key press to work exactly like above or over 1 for
// extra frames to let count as a tap.
// ALSO - these assume the current player is available as a var called 'pl'.
#define INPUT_PRIMARY_TAP_GATE \
if (pl.inputPrimaryTapFrameCount == 0)\
	return;
	
#define INPUT_SECONDARY_TAP_GATE \
if (pl.inputSecondaryTapFrameCount == 0)\
	return;
	
#define INPUT_PRIMARY_TAP_CHECK(arg_pl) (pl.inputPrimaryTapFrameCount > 0)
#define INPUT_SECONDARY_TAP_CHECK(arg_pl) (pl.inputSecondaryTapFrameCount > 0)
#define INPUT_PRIMARY_TAP_CHECK_NOT(arg_pl) (pl.inputPrimaryTapFrameCount == 0)
#define INPUT_SECONDARY_TAP_CHECK_NOT(arg_pl) (pl.inputSecondaryTapFrameCount == 0)
	
#define INPUT_TAP_RESET(arg_pl)\
	arg_pl.inputPrimaryTapFrameCount = 0;\
	arg_pl.inputSecondaryTapFrameCount = 0;\
	arg_pl.inputPrimaryReleasedQueue = FALSE;\
	arg_pl.inputSecondaryReleasedQueue = FALSE;

///////////////////////////////////////////////////////////////////////////////////////////
#endif// INPUT_TAP_DETECT_CHOICE


// OLD WAY TO DO CLICK SOUNDS
/*
// Let's make click sounds clientside-only for now
#ifdef CLIENT
	#define PLAY_CLICK_SOUND \
		sound(pl, CHAN_ITEM, "weapons/pistol-empty.wav", 1, ATTN_NONE);\
		weapon_base_setWholeAttackDelay(pl, 0.22);
		
	#define PLAY_CLICK_SOUND_LEFT \
		sound(pl, CHAN_ITEM, "weapons/pistol-empty.wav", 1, ATTN_NONE);\
		weapon_base_setLeftAttackDelay(pl, 0.22);
			
	#define PLAY_CLICK_SOUND_RIGHT \
		sound(pl, CHAN_ITEM, "weapons/pistol-empty.wav", 1, ATTN_NONE);\
		weapon_base_setRightAttackDelay(pl, 0.22);
		
#else
	
	// SERVER
	// (no sounds, just set delays)
	#define PLAY_CLICK_SOUND \
		weapon_base_setWholeAttackDelay(pl, 0.22);
		
	#define PLAY_CLICK_SOUND_LEFT \
		weapon_base_setLeftAttackDelay(pl, 0.22);
			
	#define PLAY_CLICK_SOUND_RIGHT \
		weapon_base_setRightAttackDelay(pl, 0.22);
	

#endif
*/


#define PLAY_CLICK_SOUND \
	TS_Weapons_PlaySoundChannelDirect(pl, "weapons/pistol-empty.wav", CHAN_ITEM);\
	weapon_base_setWholeAttackDelay(pl, 0.22);
	
#define PLAY_CLICK_SOUND_LEFT \
	TS_Weapons_PlaySoundChannelDirect(pl, "weapons/pistol-empty.wav", CHAN_ITEM);\
	weapon_base_setLeftAttackDelay(pl, 0.22);
		
#define PLAY_CLICK_SOUND_RIGHT \
	TS_Weapons_PlaySoundChannelDirect(pl, "weapons/pistol-empty.wav", CHAN_ITEM);\
	weapon_base_setRightAttackDelay(pl, 0.22);
	
	

// For serverside, assumes the local player is a var named "pl"!
#ifdef CLIENT
#define GET_VIEW_ANGLES view_angles
#else
#define GET_VIEW_ANGLES pl.v_angle
#endif
	
#ifdef CLIENT
#define GET_MY_VIEW_ANGLES view_angles
#else
#define GET_MY_VIEW_ANGLES this.v_angle
#endif

	
// OLD UNDERWATER CHECK.  Using a new var for more accuracy.
//#define WEAPON_UNDERWATER_CHECK pl.waterlevel >= 3
//#define WEAPON_UNDERWATER_CHECK_NOT pl.waterlevel < 3
#define WEAPON_UNDERWATER_CHECK !pl.bViewAboveWater
#define WEAPON_UNDERWATER_CHECK_NOT pl.bViewAboveWater



// be aware of the player
class player;

// extern?
const vector g_vZero = [0,0,0];




#ifdef SERVER
void centerprintToAll(string strSend);
#endif

int floor_proper(float arg);
int ceil_proper(float arg);
int round(float arg);
float randomInRange_raw_f(float min, float max);
float randomInRange_f(float min, float max);
int randomInRange_raw_i(int min, int max);
int randomInRange_i(int min, int max);
float safeRandom(void);


#ifdef SERVER
void removeSelfDelayed(entity entTarget);
#endif
void entity_removeSelf(void);

string floatToChar(float someFloat);



// Unfortunately I don't know if default optional parameters (equals-sign in prototypes like this)
// works reliably.  I think so... kindof?  sometimes?  for integers maybe?  It's weeeeird.
//int count1Bits(int bitmask, optional int bitStart = 0x1, optional int bitEnd = 0x80000000);
//int findFirst1Bit(int bitmask, optional int bitStart = 0x1, optional int bitEnd = 0x80000000‬);
int count1Bits(int bitmask, optional int bitStart = 0x1i, optional int bitEnd = -2147483648i);
int findFirst1Bit(int bitmask, optional int bitStart = 0x1i, optional int bitEnd = -2147483648i);

void stopSound(entity e, float chan);



void entity_beginCorpseFadeOut(void);
void entity_corpseFadeOut(void);

float getViewPitchRelativeRatio(float playerPitch);

float getViewModelAnimExtraDuration(void);

#ifdef SERVER
class CBaseEntity;
void entityRemoveRespawnFlag(CBaseEntity arg_this);
#endif


void TS_Weapons_ViewAnimation(player pl, int i, float fDuration);
void TS_Weapons_ViewAnimation_noLaserLock(player pl, int i, float fDuration);
void TS_Weapons_ViewAnimation_EndIdle(player pl, int i, float fDuration);
void TS_Weapons_ViewAnimation_EndIdle_custom(player pl, int i, float fDuration, float fIdleEndOffset);

#ifdef CLIENT
void TS_View_PlayAnimation(player pl, int iSequence, float fDuration);
void TS_View_PlayAnimation_noLaserLock(player pl, int iSequence, float fDuration);
void TS_View_PlayAnimation_EndIdle(player pl, int iSequence, float fDuration);
void TS_View_PlayAnimation_EndIdle_custom(player pl, int iSequence, float fDuration, float fIdleEndOffset);
#endif


void TS_Weapons_PlaySoundDirect(player pl, string samp);
void TS_Weapons_PlaySoundChannelDirect(player pl, string samp, int chann);

