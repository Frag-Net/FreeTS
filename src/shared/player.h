//TAGGG - NEW.  Header file for gamemod player

class CTSWorldGun;


// NOTE-
// even on the "Press Fire To Play!" text, that shows up after the spawn countdown
// finishes (shown on trying to spawn too early), there is actually 1 second left
// until clicking to spawn does anything.  Kindof odd, probably an oversight.

// State of the player for whether they're ingame, thirdperson recently on death,
// or in fake-spectator (buy menu).
// Players enter the server in the NOCLIP state.
enum PLAYER_STATE{
	// Nothing special. Collision, gravity, equips things.
	SPAWNED = 0,
	// Like a third-person view of the player's most recent position, unsure
	// if it follows the corpse, try dying while moving in TS to see, my guess
	// is yes because it appears to behave like third-person.
	// Slowly zooms out to a point.  I doubt wonkiness in dying in third-person
	// (already) was intentional.
	// Changes to NOCLIP (aka "Fake Spectator") on clicking between 1
	// and 2.5 seconds, or waiting out the 2.5 seconds (happens anyway)
	DEAD_RECENT,
	// Starts at the exact point where the dead player was.
	// Would probably be better to just leave the camera where it is insead of
	// jumping to the player's old point, unnecessary to do that and kinda jarring.
	NOCLIP
};



#define ATTR_CHANGED_ARY(ary, i) (ary ##_net[i] != ary[i])

#define PREDICTED_ARY_INT(ary, size) int ary[size]; int ary ##_net[size]
#define PREDICTED_ARY_FLOAT(ary, size) float ary[size]; float ary ##_net[size]

#define ROLL_BACK_ARY(ary, i) ary[i] = ary ##_net[i]
#define SAVE_STATE_ARY(ary, i) ary ##_net[i] = ary[i]

#define PREDICTED_CUSTOM(arg_t, x) arg_t x; arg_t x ##_net
/*
#define ROLL_BACK_ARRAY_MEMBER(ary, i, sub) ary[i].sub = ary ##_net[i].sub
#define SAVE_STATE_ARRAY_MEMBER(ary, i, sub) x ##_net = x    // did not do
*/

class player:NSClientPlayer
{
	
#ifdef CLIENT
	int custom_sequence;
#endif
	
	// On death, the player cannot change the camera to fake-specator until at least 1 second
	// has passed.
	// On death, set this to 2.5.  If it is less than 1.5, allow clicking to reach 
#ifdef CLIENT
	BOOL displayMinimumRespawnTimeCountdown;
	int old_cl_thirdperson;
#else
	// SERVER
	float deathCameraChangeTime;
	float minimumRespawnTime;
	BOOL waitingForSpawn;
	BOOL waitingForEarlyNoclip;
	
#endif
	
	// Send everything in the inventory to the client this frame?
	// If not, only the one of the currently equipped weapon gets updated.
	BOOL completeInventorySend;

	
	
	//TAGGG - I'm not messing around with that memory issue from last time.
	// But try again with this removed whenever it turns out ok, see if this is needed
	// anymore.
	//virtual void (void)dummyBufferMethod;
	
	
	/* animation */
	PREDICTED_INT(anim_top);
	PREDICTED_FLOAT(anim_top_time);
	PREDICTED_FLOAT(anim_top_delay);
	PREDICTED_INT(anim_bottom);
	PREDICTED_FLOAT(anim_bottom_time);

	
	////////////////////////////////////////////////////////////////////
	//TAGGG - tons of new vars.
	
	//TAGGG - TODO! Put the PREDICTED_INT/FLOAT/whatever stuff on what needs it.
	
	PREDICTED_CUSTOM(PLAYER_STATE, iState);
	
	
#ifdef SERVER
	
	int money;
	//int voted;
	//int ingame;
	
	// Keep a record of the most recently seen viewmodel frame for this player for sendoffs.
	// That way, if the server/client go out-of-synch in the middle of an animation, or
	// something that should have started playing according to the server doesn't at
	// clientside, clientside can receive the frame (really sequence, or animation choice)
	// it should be and correct that.
	// UNUSED FOR NOW, just an idea.
	int flViewModelFrame;
	
#endif
	
	
	// who's team am I on?  may not matter depending on gamemode.
	TS_Team iTeam;

	
	// Should this be predicted?  Unsure, I doubt it.
	float maxspeed_raw;
	
	

// ZOOM VARS
////////////////////////////////	
	// Don't use viewzoom, that's used by Nucldie to enforce the real zoom.
	// The closest thing is flZoomCurrent further down, the raw value even after the current
	// state of lerp to be given to viewzoom.
	
	// The current choice of zoom of some incremental number offered by the current weapon.
	// 0 is the default (no zoom).  There is no standard for what zoom value there is for each
	// zoom level in general, that is up to the equipped weapon's secondaryfire method to fill
	// on right-clicking to change the zoom level.
	PREDICTED_INT(iZoomLevel);
	// Set this (or the setZoom method) to tap into the lerp system properly.
	// When noticed (client/view.qc), the current zoom value goes to flZoomStart and 
	// flZoomTarget goes to flZoomEnd.  The lerp goes from Start to End for a smooth transition.
	// TODO - soon, no longer serverside, not even involved there anymore at all.
	// This can still be on server and clientside, since determining it from iZoomLevel
	// given a weapon is possible (ak47's zoom #1 is this, barrett's zoom #1 is that, etc.)
	//PREDICTED_FLOAT(flZoomTarget);
	float flZoomTarget;
	
#ifdef CLIENT
	float flZoomEnd;
	float flZoomStart;
	float flZoomLerp;
	float flZoomCurrent;
	float flZoomTarget;
	float iZoomLevelPrev;  // for clientside to detect a change
#endif
////////////////////////////////
	
	
#ifdef CLIENT
	BOOL equippedWeaponWaitingForCallback;
	int equippedWeaponWaitingForCallback_ID;
	float equippedWeaponWaitingForCallback_maxWaitTime;
	
	// For telling how long it's been since I've been on the ground.
	// Don't oscillate the view model bob on going down short steps.
	float flRecentGroundTime;
	
	BOOL recentLaserHitPosSet;
	vector recentLaserHitPos;
	vector recentLaserHitPos2;
	
	int recentLaserDistanceDisplay;
	
	// does anything use this?
	BOOL forceViewModelUpdate;
	
	// NOTICE - individual dynamic weapons have "iForceBodygroup1Submodel".
	// "prev_iForceBodygroup1Submodel" is player-wide (here) instead because we only need to
	// keep track of changes in a weapon's iForceBodygroup1Submodel while that weapon is
	// equipped.  Not that it could ever change while not equipped anyway.
	int prev_iForceBodygroup1Submodel;
	
	// same as below for muzzleflash.
	int iMuzzleFlashType;
	// and akimbo support
	int iMuzzleFlashAkimboChoice;
	
	
	// During a shell-eject event, what member of aryShellEjectData do I use for the model
	// and hitsound script file to use?  Set on setting up the event so that it is only
	// called once, clientside weapons can be strange.
	// Must be stored as a var to be preserved for the event (which does not take any params,
	// and is called very shortly after being set in a separate stream of execution).
	int iShellEjectType;
	// And, for which weapon?  Default is LEFT (attachment #0)
	int iShellEjectAkimboChoice;
	// Not involved in setting up the shell-eject event.  Rather, it is set BY the shell-eject
	// event to ensure this only happens once per fire animation.
	// When seen TRUE in TS_View_DrawCustom, the shell ejection actually happens for the
	// most accurate position.
	BOOL bShellEjectScheduled;
	
	
	// WEAPON KICKBACK STUFF.
	// Way it works is a little different from the average (Half-Life and Counterstrike).
	// We do have a crosshair that can grow with repeated fire to show increased inaccuracy
	// with firing too often (this is not related to the offset of the camera from firing
	// recently, but often just happens at the same time)
	// ANYWAY.  Base (HL / CS) kickback behavior for firing is to throw the player camera
	// off seemingly by a small angle in any direction quickly (slightly upward-biased?,
	// unsure), but it will return to the default position on its own over time, more quickly
	// the further away it is from the intended aim angle.
	// In TS, it's similar but instead lerps quickly to a new position somewhere between
	// +- 45 degrees (maybe more?) from the very top.  Continuous firing likely adds to the
	// new angle to lerp to.
	// So you over time get closer to looking at the very top with continuous firing without
	// moving the mouse, and then further firing will just start rotating left/right a tiny
	// bit once it's at the very top.
	//
	// Way this works is, it's vector(0,0,0) by default, and on firing, it gets a constant
	// amount added, like (-0.1, 0.1, 0).  Next frame we will move the view angle by 40% of
	// what's left: (-0.04, 0.04, 0) and subtract that from the OffsetTarget, leaving it
	// (-0.06, 0.06, 0).
	// Repeat until OffsetTarget gets so low we just 0 it out.
	// Firing further only adds to OffsetTarget as it is, so we approach the 0 point in
	// neglibly more time / the angle moves faster during that time to reach the increased
	// offset.
	// ...also, this variable will be shared.  Serverside since it must be presistent 
	// (not just something to step away from after it happens the first frame), and
	// clientside to keep track of how to behave in case the connection is broken since.
	
#else
	
#endif

	// should be better networked when it's better understood what the block feature
	// (reload with karate out, I assume?) is supposed to do.
	float flKarateBlockCooldown;
	
	PREDICTED_INT(iMeleeCycler);

	PREDICTED_FLOAT(flViewAngleOffsetTarget);
	PREDICTED_VECTOR(vViewAngleOffsetTargetDir);
	
	PREDICTED_VECTOR(vViewAngleOffsetTotalChange);
#ifdef SERVER
	vector vViewAngleOffsetTotalChangeAlt;
#endif
	
	
	PREDICTED_FLOAT(fAccuracyKickback);
	PREDICTED_FLOAT(fAccuracyKickbackStartCooldown);
	
	// The client can keep its own in mind as prediction between frames if needed.  Server
	// time and client time aren't really compatible to send like this.
	
	PREDICTED_FLOAT(fMoveBlockDelay);
	PREDICTED_FLOAT(fUncrouchBlockDelay);
	// not networked, set by the player individually client and serverside on picking
	// the weapon.  Might not even be necessary to do this.
	float fMoveBlockCapSpeed;
	PREDICTED_FLOAT(fKarateStamina);


	// These will be shared and help with slowdown logic.
	// They are all 0 to 1.0 (normal) unless there are further restrictions.
	float flBaseSpeedMulti;  //How should miscelaneous things be affected (client animation)?
	float flMoveSpeedMulti;  //how is move speed affected?
	float flSoundSpeedMulti;   //can range from 0.5 to 1.
	float flFireDelayMulti;  //How is fire delay impacted?
							 // Will be taken to the -1 power, so that a fireDelay of 0.5
							 // actually doubles the time between firing.
	float flBulletSpeedMulti;  //how is bullet speed affected?
	float flProjectileSpeedMulti;  //how are non-projectiles (grenades, knives, etc.) affected?


	//TODO - see how to handle saving / loadig these on the client's end.
	//Server probably dosen't need to store config stuff at all.
#ifdef CLIENT
	
	// record the time of the previous frame.
	// TODO - could this be done once globally clientside for all players?
	// Significance: split-screen?  Why re-compute for 4 splitscreen players.
	// Come to think of it this might bring up a lot of other questions.
	float clientTime_prev;
	
	
	// IDEA: should lasersightUnlockTime be networked?  No idea,
	// same for w_freeze_idle_next.
	BOOL lasersightUnlockTime;
	// When should the viewmodel anim switch to the frozen idle anim?
	float w_freeze_idle_next;

	//In the weapon select menu, what is currently being highlighted & picked if fire is
	// pressed? Also used as a base for finding the "previous" or "next" weapon while mouse
	// wheeling through
	int weaponSelectHighlightID;
	//This var gets a chance to turn on after the player goes through all weapons in slots
	// 1-4 to see if any weapons have akimbo.  If so, weaponSelectHighlightID goes to that
	// weapon (the first with akimbo) and this variable turns on. Going to the next/previous
	// weapon goes through all weapons to see the next akimbo one until there are no other
	// choices in that direction (like last akimb weapon --> next goes back to akimbo-less
	// slot 1's first weapon... and so on if empty). Note that slot 5 is imaginary; it is
	// only made of weapons from slots 1-4 with akimbo choices.
	//Then, selecting a next weapon looks for the next
	BOOL weaponSelectHighlightAkimbo;
	
	// used for telling what the most recently equipped weapon's akimbo status was - no or
	// yes.
	BOOL flag_lastWeaponAkimbo;
	
	float flViewShake;
	
#else
	
#endif

	// Should this even be networked?  Seems to work on a very short timeframe
	BOOL switchToRecentlyAddedWeapon;
	
	
	// TODO - reset in server and client respawn calls/notices.
	int inputPrimaryTapFrameCount;
	int inputSecondaryTapFrameCount;
	BOOL inputPrimaryReleasedQueue;
	BOOL inputSecondaryReleasedQueue;


	// Shared, but don't network!  I think?
	// apparently we do need to do this, at least network somewhat.
	// Unsure how much, maybe the 'aryNextBurstShotTime' every single frame
	// is a bit overkill, should only need to be set at the start of a burst-fire.
	// So no need for networking as the client/server should set those to the same
	// values independently, but no idea of the prediction-rollbacks on clientside
	// would complicate that, maybe still do the SAVE/ROLL_BACK stuff?
	// aryNextBurstShotTime_listenIndex depends on the time and updates a lot,
	// that one most likely has to stay networked and predicted.
	PREDICTED_INT(aryNextBurstShotTime_softLength);
	PREDICTED_ARY_FLOAT(aryNextBurstShotTime, 5);
	PREDICTED_INT(aryNextBurstShotTime_listenIndex);
	
	PREDICTED_ARY_INT(ary_ammoTotal, AMMO_ID::LAST_ID);

//shotgun stuff
//////////////////////////////////////////////////////////////////////////////

//NOTICE - all networked now, testing.

	// serverside 
	// What animation is the shotgun in?
	// -1 = not reloading
	// 0 = doing reload1 (start)
	// 1 = doing reload2 (intermediate; ammo loading)
	// 2 = doing reload3 (end)
	// ALSO!  Call Byte vars 'floats' because FTE makes 'readbyte' give a float.
	PREDICTED_FLOAT(shotgunReloadIndex);
	
	// do these even need to be networked in the end?  Works now as it is,
	// anything involving networking in even the most remote sense do be a finicky beast at times
	PREDICTED_FLOAT(shotgunAddAmmoTime);
	PREDICTED_FLOAT(shotgunAddAmmoSoundTime);

#ifdef CLIENT
	// This time must pass before re-setting the shotgunAddAmmoTime/shotgunAddAmmoSoundTime counters is allowed.
	// Why do we need to do this?  Ask FTE.
	// NEVERMIND.  Canned
	//float shotgunAddAmmoTime_cooldownSetTime;
#endif
	
	// What ary_shotgunExtra element to use for extra reload-reloated information in
	// the shotgun. Not networked, set on draw or right before a reload in the case
	// of ironsight weapons.  Might be better ways of handling this but this is better
	// than setting seven vars every time.
	int iShotgunExtraDataID;
	
	
	
//////////////////////////////////////////////////////////////////////////////

//Grenade stuff
//////////////////////////////////////////////////////////////////////////////
	
	
	//  0 = nothing special, holding grenade normally.  Pressing primary/secondary
	//      starts the next phase.
	//  1 = pull-pin animation, and stays this way until the animation finishes and
	//      neither input is held down.  Then the next phase starts.
	//  2 = throw or throw-slide anim picked, based on primary or secondary being 
	//      pressed the most recently.  Jumps to phase 2.
	//  3 = throw/slide anim playing.  Grenade spawns very soon.  After the anim
	//      finishes, decide whether to bring another grenade up (has ammo), other-
	//      wise, discard the weapon and pick another.
	
	PREDICTED_INT(grenadeFireIndex);
	// at what time do I throw the grenade after starting the throw/toss anim?
	//TAGGG - should these be predicted too?  Unsure.  Possibly not.
	PREDICTED_FLOAT(grenadeSpawnTime);
	PREDICTED_FLOAT(grenadeHeldDuration);
	// Same for this, but it has been for a while
	PREDICTED_FLOAT(bGrenadeToss);   //set to FALSE if it's a typical throw instead.
	
	
	// shared
	
	//////////////////////////////////////////////////////////////////////////////
	// for custom pmove to set
	// TODO: these should probably be gflags constants as bitflags instead
	BOOL bOnGround;
	BOOL bViewAboveWater;

	//TODO - could this just be an entity flag just as well?  Unfortunately I don't know for
	// sure what flags are guaranteed open / nonconflicting with anything else.
	
	// was BOOL
	PREDICTED_FLOAT(isReloading);
	// was BOOL
	PREDICTED_FLOAT(isChangingIronsight);


	PREDICTED_FLOAT(w_attack_akimbo_next);
	
	int akimboTest;
	int akimboFirePrev;
	PREDICTED_FLOAT(akimboDualFireToleranceTime);
	
	
	// What is the next way I want to try firing if only primary is supposed to be used?
	// Only used for certain firemode(s).
	PREDICTED_FLOAT(nextAkimboAttackPreference);
	
	// Only used by akimbo to tell something about a recently chosen attack.
	// Pending a rename to make that more clear
	BOOL recentAttackHadAmmo;
	
	
	//What particular choice of "ary_myWeapons" is equipped?
	// NOPE!  Rely on the nuclide-provided activeweapon "float".
	// ...not quite though, use a new var in its place instead.
	// 'activeweapon' is used by Nuclide to access info about a weapon in g_weapons (list of
	// weapons in the Nuclide weapon_t format). It can't be used to access inventory places
	// in our own system, so just use another var for that completely. On changing the
	// currently equipped weapon, set 'activeweapon' to the type of weapon in that inventory
	// space to let Nuclide tap into weapon info as needed, best of both worlds.
	//int activeweapon;
	PREDICTED_INT(inventoryEquippedIndex);
	// for akimbo weapons, the ID of the singular version for easy reference.
	float activeweapon_singular;
	
	// which one was equipped previously?  For easily swapping back/forth weapons by some
	// hotkey or console handle linked to a key, I forget.
	// I think this is redundant with pSeat->m_iOldWeapon or something similar to that,
	// try using that instead.  Remove this if so.
	int inventoryEquippedIndex_previous;
	
	
	//This will tell us whether we intend to equip the akimbo version of hte currently
	// equipped weapon. This is done since akimso variants, although selected separately in222222222222
	// weapon select, are still tied to the exact same element in ary_myWeapons.
	
	// was BOOL.
	PREDICTED_FLOAT(weaponEquippedAkimbo);

	weapondynamic_t ary_myWeapons[ary_myWeapons_length];
	PREDICTED_INT(ary_myWeapons_softMax);
	
	// Have one space for each type of ammo available.
	// If there were a large number of ammunitions and a low likelihood that all/most were
	// going to be used in most loadouts, this could similarly store a list of the max number
	// of ammunitions expected and keep track of which one an index (0, 1, 2, 3, etc.) refers
	// to. Sounds like a lot of extra work for a single ammo counter per type of ammo which
	// is all this is.
	//int ary_ammoTotal[AMMO_ID::LAST_ID];
	PREDICTED_ARY_INT(ary_ammoTotal, AMMO_ID::LAST_ID);
	
	// Provided for quick reference.  How many slots does the current loadout take?
	// There is a record of how much money has been spent, similar to config, but that isn't
	// too important.
	// The attached "money" (variable) is much more important (only pay attention to it serverside, fetch it from clientside: GetStatF(...) or something.
	int iTotalSlots;
	int iTotalPrice;
	
	///////////////////////////////////////////////////////////////////////////////////////////
	
	
	
	// from FreeHL, probaby good to use here too then?
	//TAGGG - TODO.  See if these need other lines to be supported & actually used, remove
	// if not needed at all for what TS does.
#ifdef CLIENT
#endif
	
	void(void) player;
	
	virtual void(void) preThink;
	virtual void(void) postThink;
	virtual void(void) preThinkShared;
	
		
	////////////////////////////////////////////////////////////
		
	virtual void(BOOL resetInventory) reset;

	virtual void (void)updateTimers;
	virtual void (float arg_ang, float arg_len)addViewAngleOffset;

	virtual void(int arg_iZoomLevel) setZoomLevel;
	virtual void(void) resetZoom;
	virtual void(void) resetZoomSoft;
	
	
	virtual void(int arg_newIndex) setInventoryEquippedIndex;
	virtual void(int arg_newIndex, BOOL useAkimbo) setInventoryEquippedIndex_Akimbo;
	
	virtual weapondata_basic_t*(void) getEquippedWeaponData;
	virtual weapondata_basic_t*(void) getEquippedWeaponData_Singular;
	virtual weapondata_basic_t*(int arg_invID, BOOL arg_preferAkimbo) getInventoryWeaponData;
	
	virtual void(void) updateSlotCountsForEquippedWeapon;
	virtual BOOL(void) equippedWeaponDeleteCheck;
	virtual BOOL(int arg_invID) inventoryWeaponDeleteCheck;
	
	virtual void(void) callWeaponThink;
	
	//TAGGG - CRITICAL.
	// overriding Nuclide player physics method!
	// If any ever get renamed, this needs to be kept up-to-date with that!
	// At least the ones actually beying used beyond straight-redirects.
	virtual void(float flDownforce) Physics_Fall;
	virtual void(void) Physics_Crouch;
	virtual void(void) Physics_Jump;
	virtual void(float premove) Physics_CheckJump;
	virtual void(void) Physics_SetViewParms;
	virtual void(void) Physics_WaterJump;
	virtual void(void) Physics_WaterMove;
	virtual float(void) Physics_MaxSpeed;
	virtual void(void) Physics_InputPreMove;
	virtual void(void) Physics_InputPostMove;
	virtual void(void) Physics_Run;
	
	

#ifdef SERVER
	// !!! SPECIAL CASE?  not built-in but is what the "think" method is set to early on.
	// (REMOVED: the ".think" pointer will likely be set by other stuff like so much as a
	// reload delay, let's not expect this to stay as it's set)
	//virtual void () frameThink;
	//TAGGG - QUESTION.  Does this need to be separate from postThink at all?  Same for above,
	// forget what these are for
	virtual void(void) frameThink_fromServer;

	virtual BOOL(CTSWorldGun arg_pickup) attemptAddWeaponFromPickup;
	virtual void(int arg_weaponID, BOOL completeDrop) dropWeapon;
	virtual BOOL(void) anyAmmoPoolNonEmpty;
	virtual void(void) dropAmmo;
#else
	
	virtual void(void) clientInputUpdate;
	virtual void(void) clientUseItemsCallback;
	virtual void(void) handleZoom;
#endif
	
	
	////////////////////////////////////////////////////////////
		
	
	// FeeHL clones
#ifdef CLIENT
	virtual void(void) draw;
	virtual float() predraw;
	virtual void(void) postdraw;
	virtual void(float,float) ReceiveEntity;
	// NEW
	virtual void(int i) ReceiveEntity_ary_myWeapons;
	virtual void(void) PredictPreFrame;
	virtual void(void) PredictPostFrame;
#else
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;
	// NEW
	virtual void(int i) SendEntity_ary_myWeapons;
#endif

};

