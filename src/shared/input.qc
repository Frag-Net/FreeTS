/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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
 
 

void processInputs(void);


// WARNING!  This is only called by PMove_Run, which is only called
// for spawned players.  This is not called for players in spectator,
// so if script to check for clicking while in spectator with no menu 
// to spawn is here, prepare to be disappointed.

// Also, this is called by pmove.qc (Nuclide), and it trusts "self" regardless
// of being client or serverside, so going to here too. 

// ALSO, no need for "is spectator" checks here.  Only being a player allows
// pmove to be called to begin with.
void
Game_Input(void)
{
	// We can trust "self" here, right?
	// If not, grab pSeat->m_ePlayer instead!
	player pl = (player)self;
	
	//TAGGG - good place for this?  Cloned from w_attack_next as a separate counter
	// for akimbo firing to use.
	// This method, Game_Input, is called by Nuclide's pmove.qc in the same place
	// w_attack_next is adjusted by the current frame time.
	pl.w_attack_akimbo_next = max(0, pl.w_attack_akimbo_next - input_timelength);
	
	pl.akimboDualFireToleranceTime = max(0, pl.akimboDualFireToleranceTime - input_timelength);

#ifdef SERVER
	CGameRules rules = (CGameRules)g_grMode;

//TAGGG - why leave this up to any player?  If all are in spectator this leaves the game stuck
	if (rules.m_iIntermission) {
		rules.IntermissionEnd();
		return;
	}

	if (input_buttons & INPUT_BUTTON5)
		Player_UseDown(); 
	else
		Player_UseUp();

	self.impulse = 0;
	
#endif

	// better TS way, weapon thinks happen alongside checking inputs
	pl.callWeaponThink();


	/*
	if(pl.w_attack_next > 0){
		printfline("w_attack_next > 0  at:%.2f - t:%.2f", pl.w_attack_next, time);
	}
	*/
	
	// HACK: If, this frame, w_attack_next was 0, for most weapons to allow firing,
	// make that a signal to reset inputPrimaryTapFrameCount.
	// This way, only the first frame to set w_attack_next benefits from inputPrimaryTapFrameCount.
	// Running a weapon's _primary several times for the same tap is not wanted, this is only
	// to give some tolerance to ease some slight frame desyncs between the client/server.
	BOOL wasPassingFrame = (pl.w_attack_next <= 0);
	


	if (input_buttons & INPUT_BUTTON0){
		// Fresh touch?  Set inputPrimaryTapFrameCount.
		// The client gets an extra frame to count.  This makes an issue where giving a semi input
		// at a fringe time (like the immediate end of a weapon draw, reload, or ironsight-change
		// anim) causes the anim to appear to repeat.
		// This is because the client receives the semi-tap at a time when w_attack_next isn't 
		// ready, yet the complementary server frame passes.  Typically, the very next client frame
		// passes the w_attack_next check, but, being another frame while held-down, this is not
		// a fresh semi-tap and so it does not count.
		// In a primary attack method, if everything else goes right, it calls the view animation
		// method, which does something a bit differnet client and serverside.
		// Both set w_attack_next, but only clientside changes the sequence played.
		// So only serverside being called resets the anim to re-play the previously picked sequence
		// (becuase w_attack_next is networked, so it reaches the client from there anyway).
		// So, giving the client an extra frame to count a semi-press one frame late (so long as the
		// first does not pass w_attack_next) seems to make the issue much less likely in the very least.
		// It may also suffice to only set the GF_SEMI_TOGGLED flag on running primary (that is, only on
		// passing anything else like w_attack_next and clip checks, not just unconditionally on all frames
		// like it is now).  But this means holding down fire in an obviously non-fireable state
		// (draw/reload/etc) lets it fire once the moment that ends.  Not terrible but up to taste.
		// And yes, this has been tested in FreeHL.
		// To be far more likely to happen, enable semi-press detection on the glock and set the player's
		// w_attack_next to 31.0f/30.0f in the _draw method.  Why is that more likely to make the issue
		// occur?  Absolutely mystifying, being a clean 0.5 or 1.0 seconds makes it much less likely to
		// occur.  I can only thing some oddness in cumulative subtractions in bringing the w_attack_next
		// to 0 getting very close to 0 without passing it, so much so that a tiny variance like client/server
		// differences, even on the same machine, are enough to make one ready in the same perceived frame
		// but the other not.  Server or client-exclusive lag may also make the issue more likely even in
		// clean delays for FreeHL, particularly spamming printouts.
		if(!(pl.gflags & GF_SEMI_TOGGLED)){
			#ifdef CLIENT
			pl.inputPrimaryTapFrameCount = 2;
			//pl.inputPrimaryTapFrameCount = 1;
			#else
			pl.inputPrimaryTapFrameCount = 1;
			#endif
		}
		pl.gflags |= GF_SEMI_TOGGLED;
		pl.gflags_net |= GF_SEMI_TOGGLED;
	}else{
		// Not pressed?  See if this is a release
		if(pl.gflags & GF_SEMI_TOGGLED){
			// Held the previous frame?  Mark this
			pl.inputPrimaryReleasedQueue = TRUE;
		}
		// mark as not held down (for the next time held down to be a fresh press)
		pl.gflags &= ~GF_SEMI_TOGGLED;
		pl.gflags_net &= ~GF_SEMI_TOGGLED;
	}
	
	// Same for secondary.
	if (input_buttons & INPUT_BUTTON3){
		if(!(pl.gflags & GF_SEMI_SECONDARY_TOGGLED)){
			#ifdef CLIENT
			pl.inputSecondaryTapFrameCount = 2;
			#else
			pl.inputSecondaryTapFrameCount = 1;
			#endif
		}
		pl.gflags |= GF_SEMI_SECONDARY_TOGGLED;
		pl.gflags_net |= GF_SEMI_SECONDARY_TOGGLED;
	}else{
		// Not pressed?  See if this is a release
		if(pl.gflags & GF_SEMI_SECONDARY_TOGGLED){
			// Held the previous frame?  Mark this
			pl.inputSecondaryReleasedQueue = TRUE;
		}
		// mark as not held down (for the next time held down to be a fresh press)
		pl.gflags &= ~GF_SEMI_SECONDARY_TOGGLED;
		pl.gflags_net &= ~GF_SEMI_SECONDARY_TOGGLED;
	}
	
	// This way, what's below the script in this method returning early doesn't skip what comes after.
	processInputs();
	
	if(wasPassingFrame){
		pl.inputPrimaryTapFrameCount = 0;
		pl.inputSecondaryTapFrameCount = 0;
	}
	if(pl.inputPrimaryTapFrameCount > 0){
		pl.inputPrimaryTapFrameCount--;
	}
	if(pl.inputSecondaryTapFrameCount > 0){
		pl.inputSecondaryTapFrameCount--;
	}
	
	// End of the time to count a fresh tap, and there was a recent release?  Act on it.
	// Unsure if the FrameCount check should be done at all here.
	if(pl.inputPrimaryReleasedQueue && pl.inputPrimaryTapFrameCount == 0){
		pl.inputPrimaryReleasedQueue = FALSE;
		// TODO - remove 2nd parameter from that!
		TS_Weapon_PrimaryAttackRelease(pl, TRUE);
	}
	if(pl.inputSecondaryReleasedQueue && pl.inputSecondaryTapFrameCount == 0){
		pl.inputSecondaryReleasedQueue = FALSE;
		// TODO - remove 2nd parameter from that!
		TS_Weapon_SecondaryAttackRelease(pl, TRUE);
	}
	
	//pl.callWeaponThink();
	
	/*
	// primary fire.
	if (input_buttons & INPUT_BUTTON0){
		// mark as held down for future frames.
		pl.gflags |= GF_SEMI_TOGGLED;
		pl.gflags_net |= GF_SEMI_TOGGLED;
	}else{
		// mark as not held down (for the next time held down to be a fresh press)
		pl.gflags &= ~GF_SEMI_TOGGLED;
		pl.gflags_net &= ~GF_SEMI_TOGGLED;
	}
		
	// And for secondary fire.
	if (input_buttons & INPUT_BUTTON3){
		pl.gflags |= GF_SEMI_SECONDARY_TOGGLED;
		pl.gflags_net |= GF_SEMI_SECONDARY_TOGGLED;
	}else{
		pl.gflags &= ~GF_SEMI_SECONDARY_TOGGLED;
		pl.gflags_net &= ~GF_SEMI_SECONDARY_TOGGLED;
	}
	*/
	
	
}//Game_Input


void processInputs(void){
	player pl = (player)self;
	
	if (input_buttons & INPUT_BUTTON0){
		//printfline("!!! PRIMA !!! (%d %d)", ((input_buttons & INPUT_BUTTON0)!=0), ((input_buttons & INPUT_BUTTON3)!=0));
		Weapons_Primary();
		
		//TAGGG - CRITICAL.
		// Is setting the _net version of gflags ok?
		// This is like SAVE_STATE but only for this bitflag.
		// Doing this causes the issue of client being called many times for a short while as
		// though SEMI_TOGGLED weren't touched to happen.
		// In other words, checks for being out of clip and playing a click sound can play
		// several clicks one frame after the other even though one was intended every 0.22 seconds.
		// If this is the wrong way to go about fixing that, or this has some nasty side-effects
		// in realistic pings, need to know to fix that some other way.
		// Could even check for having recently seen the button not pressed and reject out-of-date
		// server messages explicitly too?
		// (This all applies to "GF_SEMI_SECONDARY_TOGGLED" further down)
		
		/*
		// BEST YET
		pl.gflags |= GF_SEMI_TOGGLED;
		pl.gflags_net |= GF_SEMI_TOGGLED;
		
		// FIX: for holding both inputs to behave properly
		if(input_buttons & INPUT_BUTTON3){
			pl.gflags |= GF_SEMI_SECONDARY_TOGGLED;
			pl.gflags_net |= GF_SEMI_SECONDARY_TOGGLED;
		}
		*/
		
		
		// Primary was picked, so turn off the flag for secondary
		//pl.gflags &= ~GF_SEMI_SECONDARY_TOGGLED;
		
		return;
	}
	
	
	if (input_buttons & INPUT_BUTTON3){
		//printfline("!!! SECO !!! (%d %d)", ((input_buttons & INPUT_BUTTON0)!=0), ((input_buttons & INPUT_BUTTON3)!=0));
		// TAGGG - CRITICAL.
		// Would be nice to be able to do secondary input ignored if weapon select is open
		// like primary, see a similar place involving "HUD_DrawWeaponSelect_Trigger" in
		// Nuclide's src/client/entry.qc.  Can we get that CSQC_Input_Frame event to pipe 
		// a call over to gamemod script for custom behavior like this, perhaps?
		/*
		#if CLIENT
		if ((pSeat->m_iHUDWeaponSelected) ) {
			HUD_DrawWeaponSelect_Trigger();
			input_buttons = 0;
			pSeat->m_flInputBlockTime = time + 0.2;
		}

		// prevent accidental input packets
		if (pSeat->m_flInputBlockTime > time) {
			input_impulse = 0;
			input_buttons = 0;
			return;
		}
		#endif
		*/
		
		Weapons_Secondary();
		
		// BEST YET
		/*
		pl.gflags |= GF_SEMI_SECONDARY_TOGGLED;
		pl.gflags_net |= GF_SEMI_SECONDARY_TOGGLED;
		*/
		
		// Secondary was picked, so turn off the flag for primary
		//pl.gflags &= ~GF_SEMI_TOGGLED;
		
		
		return;
	}
	
	
	
	// why did the reload check come before Secondary-fire checks before??
	if (input_buttons & INPUT_BUTTON4){
		Weapons_Reload();
		
		// Picked reload?  Turn the flags for both fire types off
		//pl.gflags &= ~(GF_SEMI_TOGGLED | GF_SEMI_SECONDARY_TOGGLED);
		return;
	}
	
	
	// Below's changes to pl.gFlags for GF_SEMI_TOGGLED (Weapons_Release) and SECONDARY
	// might be a little redundant at this point, but that is ok.
	
	// reached here?
	Weapons_Release();
	
	// These SEMI flag removals only happen if this area is reached
	// (note the 'return' statements above with button presses)
	// Nuclide already does that first one
	//pl.gflags &= ~GF_SEMI_TOGGLED;
	pl.gflags &= ~GF_SEMI_SECONDARY_TOGGLED;
	
}//processInputs

