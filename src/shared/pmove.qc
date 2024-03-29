/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

// NOTE - Physics_WaterMove is in pmove_water.qc instead

// !!! IMPORTANT
// Any methods starting with "Game" in here are no longer called by Nuclide.
// Most methods have been changed to player-methods instead, see much further
// down.  Keeping mine as they are to be inserted as needed.
// If they're not called in here, they never get called.



// This file was the source of the "GamePMove_..." format physics methods.
// Now, the new NSClientPlayer-overridable forms are used.

// Also, some physics constants can be overridden like so:
//     #define PMOVE_STEPHEIGHT 18
// FreeHL doesn't do anything like that, so assuming original TS did nothing 
// too special in that regard, but say so if that looks to be the case.



// First something config-oriented.  If uncommented, a modified clone of Nuclide's
// NSClientPlayer::Physics_Crouch (overridden by player) is used to insert the checks for
// stopping uncrouching too soon after certain melee attacks.  Example: katana melee attack.
// Otherwise, a simpler way is done: in player::Physics_InputPreMove, force INPUT_BUTTON8
// if the uncrouch block has not expired.
//#define UNCROUCHBLOCK_FORKED


///////////////////////////////////////////////////////////////////// 

// Are these even used anywhere anymore?
/*
#define PHY_JUMP_CHAINWINDOW	0.5
#define PHY_JUMP_CHAIN		100
#define PHY_JUMP_CHAINDECAY	50
*/

/*
const vector VEC_HULL_MIN = [-16,-16,-36];
const vector VEC_HULL_MAX = [16,16,36];
const vector VEC_CHULL_MIN = [-16,-16,-18];
const vector VEC_CHULL_MAX = [16,16,18];
*/


// Simplified view of major physics method changes:
/*
	PMove_Run -> NSClientPlayer::Physics_Run
	PMove_AccelJump -> NSClientPlayer::Physics_CheckJump
	PMove_Acceleration -> PMoveCustom_Acceleration
*/


// TS does use different viewpos offsets (original: heights of 24 and 12)
#define PHY_VIEWPOS [0,0,28]
#define PHY_VIEWPOS_CROUCHED [0,0,16]

// I think these have to stay the same in goldsrc, I doubt TS could change them
#define PHY_HULL_MIN [-16,-16,-36]
#define PHY_HULL_MAX [16,16,36]
#define PHY_HULL_CROUCHED_MIN [-16,-16,-18]
#define PHY_HULL_CROUCHED_MAX [16,16,18]


// Prototype for Nuclide methods involved
bool PMove_IsStuck(entity eTarget, vector vOffset, vector vecMins, vector vecMaxs);
int PMoveCustom_Contents(vector org);

// Prototypes for new helper methods
float Game_MoveModMulti(player eTarget);
float GamePMove_MaxspeedRaw(player target);
float Game_GetFriction(player eTarget);
void TS_Physics_LedgeCheck(player pl);



// TODO!  Is this accurate to TS?  Copied from FreeHL.
// Worth comparing with FreeCS too if it does anything differently here.
// Anyway, doing this to remove the viewpunch vertical effect,
// seems TS only does roll.
void
player::Physics_Fall(float flDownforce)
{
	//NSClientPlayer::Physics_Fall(flDownforce);
	
	if (flDownforce > 580) {
#ifdef SERVER
		float fFallDamage = (flDownforce - 580) * (100 / (1024 - 580));
		Damage_Apply(this, world, fFallDamage, 0, DMG_FALL);
		Sound_Play(this, CHAN_VOICE, "player.fall");
#endif
		
		//TAGGG
		//punchangle += [15,0,(input_sequence & 1) ? 15 : -15];
		punchangle += [0,0,(input_sequence & 1) ? 15 : -15];
		
	} else if (flDownforce > 400) {
		
		//TAGGG
		//punchangle += [15,0,0];
		punchangle += [0,0,8];
		
#ifdef SERVER
		Sound_Play(this, CHAN_VOICE, "player.lightfall");
#endif
	}
}

void
player::Physics_Crouch(void)
{
#ifndef UNCROUCHBLOCK_FORKED
	// simple simple
	NSClientPlayer::Physics_Crouch();
#else
	// would this be better somewhere, in CSQC_InputFrame or Physics_InputPreMove?
	// probably the latter to make hacking less rewarding
	// Oh!  That actually worked.  No need to fork this method then.
	
	int iFixCrouch = FALSE;
	if (input_buttons & INPUT_BUTTON8) {
		flags |= FL_CROUCHING;
	} else {
		
		
		if(this.fUncrouchBlockDelay <= 0){
			if (PMove_IsStuck(this, [0,0,36], PHY_HULL_MIN, PHY_HULL_MAX) == FALSE) {
				flags &= ~FL_CROUCHING;
				iFixCrouch = TRUE;
			}
			
		}else{
			flags |= FL_CROUCHING;
		}
		
		/*
		// If we aren't holding down duck anymore and 'attempt' to stand up, prevent it
		if (flags & FL_CROUCHING) {
			//TAGGG - only allow uncrouching if uncrouchBlockDelay isn't on.
			// Surrounded with condition
			if(this.fUncrouchBlockDelay <= 0){
				//printfline("uncrouch time? %.2f", time);
			////////////////////////////////////////////////////////////////////
				if (PMove_IsStuck(this, [0,0,36], PHY_HULL_MIN, PHY_HULL_MAX) == FALSE) {
					flags &= ~FL_CROUCHING;
					iFixCrouch = TRUE;
				}
			////////////////////////////////////////////////////////////////////
			}
		} else {
			flags &= ~FL_CROUCHING;
		}
		*/
	}

	if (flags & FL_CROUCHING) {
		setsize(this, PHY_HULL_CROUCHED_MIN, PHY_HULL_CROUCHED_MAX);
		view_ofs = PHY_VIEWPOS_CROUCHED;
	} else {
		setsize(this, PHY_HULL_MIN, PHY_HULL_MAX);
		if (iFixCrouch && PMove_IsStuck(this, [0,0,0], PHY_HULL_MIN, PHY_HULL_MAX)) {
			for (int i = 0; i < 36; i++) {
				origin[2] += 1;
				if (PMove_IsStuck(this, [0,0,0], mins, maxs) == FALSE) {
					break;
				}
			}
		}
		setorigin(this, origin);
		view_ofs = PHY_VIEWPOS;
	}
#endif
}

void
player::Physics_Jump(void)
{
	//NSClientPlayer::Physics_Jump();
	
	
	if (this.waterlevel >= 2) {
		if (watertype == CONTENT_WATER) {
			velocity[2] = 100;
		} else if (watertype == CONTENT_SLIME) {
			velocity[2] = 80;
		} else {
			velocity[2] = 50;
		}
	} else {
		
		// Going to say 'nevermind' to this for now actually.
		// FreeHL no longer does this jump-velocity slowdown, FreeCS does,
		// plus makes the jump 200 instead of 240.
		// Assuming original TS modeled HL more than CS for now.
		/*
		// ---------------------
		//TAGGG - pretty sure the mechanism for preventing rapid jumps was a lot more complicated before
		// and would've replaced the line below if it were still used.
		// Involved PHY_JUMP_CHAINWINDOW maybe?
		// Also used to involve "self.jumptime".   (or this.jumptime now)
		///////////////////////////////////////////////////////////////
		// slow the player down a bit to prevent bhopping like crazy
		this.velocity *= 0.80f;
		///////////////////////////////////////////////////////////////
		*/
		
		if (this.flags & FL_ONGROUND)
			this.velocity[2] += 240;
	}
	
}


void
player::Physics_CheckJump(float premove)
{
	NSClientPlayer::Physics_CheckJump(premove);
	
	if(this.movetype == MOVETYPE_NOCLIP){
		// no ledge checks
		return;
	}
	
	// is this at all a good idea.
	if (input_buttons & INPUT_BUTTON2){
		TS_Physics_LedgeCheck(this);
	}
	
}

void
player::Physics_SetViewParms(void)
{
	NSClientPlayer::Physics_SetViewParms();
	
}

void
player::Physics_WaterJump(void)
{
	NSClientPlayer::Physics_WaterJump();
	
}

float
player::Physics_MaxSpeed(void)
{
	
	// Consider noclip.  Otherwise, moving downward is considerably slower for no
	// apparent reason (FL_CROUCHING input detected further down).
	if(this.movetype == MOVETYPE_NOCLIP){
		return serverkeyfloat("phy_maxspeed");
	}
	
	
	/*
	float parentResult = NSClientPlayer::Physics_MaxSpeed();
	return parentResult;
	*/
	
	// Default way for reference.
	// (serverkeyfloat("phy_maxspeed") is 270, so unsure why this is
	// avoiding that and using constants like that)
	//return (flags & FL_CROUCHING) ? 135 : 270;
	
	float targetSpeed;
	
	//TAGGG - CRITICAL TODO.   Check for prone, that gets set to 30% of normal speed and only 
	// allows for sideways movement, ignore input_movevalues[#]  whatever is the forward one.  probably 0.
	// TODO: does this slow down lateral movement while trying to go downard underwater?  Does it even
	// signal for that at all?  This might be a non-issue.
	if((this.flags & FL_CROUCHING) ){
		targetSpeed = serverkeyfloat("phy_maxspeed") * 1.0 * 0.33;
	} else {
		targetSpeed = serverkeyfloat("phy_maxspeed") * 1.0;
	}
	
	
	if(this.fMoveBlockDelay > 0){
		// don't move much until this has passed.  Further slowdowns need not apply.
		// !
		// "fMoveBlockCapSpeed" must be set by a weapon before it is involved.
		// Is that the best way to handle this?  Being a field in all weapon data would
		// not make sense though, not much uses this
		
		targetSpeed = min(targetSpeed, this.fMoveBlockCapSpeed);
		//targetSpeed *= 0.07;
		return targetSpeed;
	}
	
	// Sneak?
	if (input_buttons & INPUT_BUTTON7) {
		// sneak forgets slot limits.
		targetSpeed *= 0.38;
	}else{
		// speed factor of 0 means 55% speed.
		// speed factor of 1 means 100% speed (no effect)
		float speedFactor = (1 - (bound(0, this.iTotalSlots, RULE_SLOTS_ALLOWED) / RULE_SLOTS_ALLOWED));
		targetSpeed *= (0.55 + speedFactor * 0.45);
	}
	return targetSpeed;
}

void
player::Physics_InputPreMove(void)
{
	NSClientPlayer::Physics_InputPreMove();
	
	// IDEA: is changing the speed by inputmove value adjusting better than changing
	// the max speed for prediction wonkiness (the camera looks to jump around on slowing down
	// since a recent karate attack)?
	// from Nuclide's player_move.qc (holding use-key slowdown):
	//if (input_buttons & INPUT_BUTTON5) {
	//	input_movevalues *= 0.25;
	//}
	
	
	if(this.movetype == MOVETYPE_NOCLIP){
		// also, reduce the up/down noclip movement a bit, no need to be that quite that fast in
		// most cases
		if (input_buttons & INPUT_BUTTON2) {
			input_movevalues[2] *= 0.7;
		}
		if (input_buttons & INPUT_BUTTON8) {
			input_movevalues[2] *= 0.7;
		}
		
	}else{
		
#ifndef UNCROUCHBLOCK_FORKED
		if(this.fUncrouchBlockDelay > 0 && (flags & FL_CROUCHING)){
			// still crouched while the time hasn't expired?  Keep the crouch
			input_buttons |= INPUT_BUTTON8;
		}
#endif
		
	}// noclip check
	
}// Physics_InputPreMove

void
player::Physics_InputPostMove(void)
{
	NSClientPlayer::Physics_InputPostMove();
	
}

void 
player::Physics_Run(void)
{
	//maxspeed = Physics_MaxSpeed();
	//self.maxspeed = GamePMove_Maxspeed((player)self);
	
	// this setting is useless for now
	this.maxspeed_raw = GamePMove_MaxspeedRaw(this);
	
	// Cheap way to alter the friction for now, any deeper of a way without a Nuclide
	// edit isn't really possible.
	// This does not affect friction while in water, no idea if that's a problem.
	this.friction = Game_GetFriction(this);
	
	// This call is pretty damn important
	NSClientPlayer::Physics_Run();
	
	
	if(this.movetype == MOVETYPE_NOCLIP){
		// no custom logic below makes sense for noclip
		return;
	}
	
	
// !!!
// Copied from PMoveCustom_Categorize / PMove_Categorize, whatever we're calling it,
// from Nuclide.
// Any changes to what PMoveCustom_Categorize already changes would be redundant,
// this is only to do a finer check for a new var, 'bViewAboveWater', a more accurate
// check than 'pl.waterlevel < 3'.
// Or maybe this will be deemed pointless and scrapped anyway, that isn't too bad and
// it's what nearly any goldsource mod did, probably quake-based in general.

// But first some common sense checks with the existing determined pl.waterlevel.
// 0: not touching water at all
// 1: at least the bottom of the bounding box, not past the halfway point up
// 2: between the halfway point up and very close to the top
// 3: close to the very top or completely submerged
//... so we only need to be more specifc with the trace below if pl.waterlevel is 2
	if(this.waterlevel < 2){
		// definitely so (not in water at all also counts)
		this.bViewAboveWater = TRUE;
	}else if (this.waterlevel == 3){
		// submerged so no
		this.bViewAboveWater = FALSE;
	}else{
		// == 2?  Check
		int contents;
		
		contents = PMoveCustom_Contents(this.origin + this.mins + [0,0,1]);

		if (contents & CONTENTBIT_WATER) {
			contents = CONTENT_WATER;
		} else if (contents & CONTENTBIT_SLIME) {
			contents = CONTENT_SLIME;
		} else if (contents & CONTENTBIT_LAVA) {
			contents = CONTENT_LAVA;
		}

		this.bViewAboveWater = TRUE;

		// how far underwater are we?
		if (contents < CONTENT_SOLID && !(this.flags & FL_ONLADDER)) {
			//this.watertype = contents;
			
			// Let's do this check sperately instead of below.
			// Little margin of error (-5 in .z) to see if the viewmodel is probably above/below water.
			vector vTest = this.origin + this.view_ofs - [0, 0, 5];
			if(PMoveCustom_Contents(vTest) & CONTENTBITS_FLUID){
				this.bViewAboveWater = FALSE;
			}
			
		} else {
			//this.watertype = CONTENT_EMPTY;
			///this.waterlevel = 0;
		}
		/////////////////////////////////////////////////////////////////////////////
	}// bViewAboveWater check
	
	
	
	// If the player waterlevel >= 2, the "FL_ONGROUND" flag never occurs,
	// regardless of touching the floor while underwater (as seen in Nuclide pmove).
	// In original TS, being on the floor underwater DOES still do the camera/viewbob.
	// No idea how to get around this, beyond traces against the ground like pmove
	// does.
	// Open for better ideas, or maybe this is a massive "who cares" situation.
	
	if(this.waterlevel < 2){
		// Easy, trsy pl.flags having FL_ONGROUND.
		this.bOnGround = ((this.flags & FL_ONGROUND) != 0);
	}else{
		// Underwater enough?  Need to do a re-trace, FL_ONGROUND is forced off by
		// pmove.
		
		// until proven otherwise
		this.bOnGround = FALSE;
		vector vTest2 = this.origin - [0,0,0.25];
		tracebox(this.origin, this.mins, this.maxs, vTest2, FALSE, this);

		if (!trace_startsolid) {
			if ((trace_fraction < 1) && (trace_plane_normal[2] > 0.7)) {
				this.bOnGround = TRUE;
			} else {
				
			}
		}
	}
	
}// Physics_Run






// !!!
// New methods for physics to tap into, helper methods not called by Nuclide
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// WARNING: Far, far too many edits into pmove for this to be feasible yet,
// but needed for local slowdown (slow-mo / slow-pause effects) to be effective.
float Game_MoveModMulti(player eTarget){
	return autocvar_movemodmulti;
}


float GamePMove_MaxspeedRaw(player target){
	return ( serverkeyfloat("phy_maxspeed") * 1.0 );
}


// Don't involve phy_friction anymore!  This gives a divisor for that instead.
// (returning 0 means nothing happens, just like giving 1 to divide by)
// Noclip doesn't pay attention to friction so don't bother with a check for that
float Game_GetFriction(player eTarget){
	
	if(eTarget.fMoveBlockDelay > 0){
		// don't move much until this has passed.  Further slowdowns need not apply.
		//return serverkeyfloat("phy_friction") * 3.6;
		return 0.2777777778;
	}
	
	// default, nothing special
	//return serverkeyfloat("phy_friction");
	return 0;
}



// used to be called GamePMove_JumpPressed
// Check to see if the player can ascend up a nearby surface interpreted
// as a "ledge".  At least I think that's what the original TS was going for.
// This may even be a little more likely to work than in the original, I don't
// think that's too bad.
void TS_Physics_LedgeCheck(player pl){
	
	//if(pl.velocity.z != 0 && !(pl.velocity.z >= -45 && pl.velocity.z <= 50)){
	//	printfline("that VELOCITY is bad  %.2f", pl.velocity.z);
	//}
	
	//&& pl.velocity.z >= -45 && pl.velocity.z <= 50
	if(
		!(pl.flags & FL_ONGROUND) &&
		GET_VIEW_ANGLES.x >= -70 && GET_VIEW_ANGLES.x <= 80
		&& (pl.velocity.z >= -90 && pl.velocity.z <= 160)
	){
		
		makevectors(GET_VIEW_ANGLES);
		vector v_forward_proj = normalize([v_forward.x, v_forward.y, 0]);
		
		// Does a line from the bottom of the player model to a little further below
		// find anything?
		vector vBottomStart = pl.origin + [0,0,pl.mins.z + 2];
		vector vBottomDown = pl.origin + [0,0,pl.mins.z - 2];
		traceline(vBottomStart, vBottomDown, FALSE, pl);
		if(trace_fraction == 1.0){
			//printfline("tracetest A");
			// If not, proceed. Does a line from a little below the player outward
			// find something?
			vector vBottomDownForward = vBottomDown + v_forward_proj * (pl.maxs.x * 1.7);
			
			traceline(vBottomDown, vBottomDownForward, FALSE, pl);
			if(trace_fraction < 1.0){
				//ok. And does a line from the top of the model going forwards work?
				
				vector vTopStart = pl.origin + [0,0,pl.maxs.z + 1];
				vector vTopForward = vTopStart + v_forward_proj * (pl.maxs.x * 1.7);
				
				traceline(vTopStart, vTopForward, FALSE, pl);
				//printfline("tracetest B trace: %.2f", trace_fraction);
				if(trace_fraction == 1.0){
					//printfline("tracetest C");
					//ok! do it
					pl.velocity.z += 10;
				}
			}
		}
		
	}
}


