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
#ifdef CLIENT
void PreSpawn_Input(void);
// externs
void HUD_DrawWeaponSelect_Trigger(void);
BOOL TS_HUD_CloseWeaponSelect(BOOL);
#endif







#if OTHER_PREDICTION_TEST == 1
float custom_input_buttons;
float ary_custom_input_buttons[512];
BOOL ary_custom_input_sentYet[512];

void Custom_Game_Input(void);
#endif



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
	player pl = (player)self;
	
	//
	// TODO: in the CSQC_Input_Frame event might be better when supported
	// (but still do a 'return' on not being spawned here regardless)
	//
	if(pl.iState != PLAYER_STATE::SPAWNED){
		// not ingame (fake spectator)?  Do another check instead: spawning.
#ifdef CLIENT
		PreSpawn_Input();
#endif
		// client or server, don't pay attention to the rest of this file if not spawned
		return;
	}
#ifdef CLIENT
	else{
		// not spawned?  Some notes on possible things to involve, all dummied for now
		
		
		// This was removed?  Legacy VGUI
		// If we are inside a UI, don't let the client do stuff outside
		// (looks like this is no longer necessary)
		/*
		if (pl.iState != PLAYER_STATE::SPAWNED && pSeatLocal->m_flUI_Display != UI_SCREEN::NONE){
			pSeat->m_flInputBlockTime = time + 0.2;
		}
		*/
		
		// No need to check for calling TS_HUD_DrawWeaponSelect_CheckClick or
		// HUD_DrawWeaponSelect_Trigger here, Nuclide calls the latter which works
		// fine.
		
	}// pi.iState checks
#endif
	
	
	// Must be ingame to reach beyond here
	///////////////////////////////////////////////////////////
	
	// Anything special with my own vars for networking to work right here?
#ifdef CLIENT
	pl.clientInputUpdate();
#endif
	
	
	// This method, Game_Input, is called by Nuclide's pmove.qc in the same place
	// w_attack_next is adjusted by the current frame time.
	pl.updateTimers();
	
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



/*
// FreeHL's way

	if (input_buttons & INPUT_BUTTON0)
		Weapons_Primary();
	else if (input_buttons & INPUT_BUTTON4)
		Weapons_Reload();
	else if (input_buttons & INPUT_BUTTON3)
		Weapons_Secondary();
	//else
		pl.callWeaponThink();  //Weapons_Release();

// Added portion to that.
	if(input_buttons & INPUT_BUTTON0){
		pl.gflags |= GF_SEMI_TOGGLED;
	}else{
		// held down the previous frame, but not now?  That's a release.
		if(pl.gflags & GF_SEMI_TOGGLED){
			TS_Weapon_PrimaryAttackRelease(pl);
			pl.gflags &= ~GF_SEMI_TOGGLED;
		}
	}
	if(input_buttons & INPUT_BUTTON3){
		pl.gflags |= GF_SEMI_SECONDARY_TOGGLED;
	}else{
		if(pl.gflags & GF_SEMI_SECONDARY_TOGGLED){
			TS_Weapon_SecondaryAttackRelease(pl);
			pl.gflags &= ~GF_SEMI_SECONDARY_TOGGLED;
		}
	}
	// it's this way or the much more modified way further down
	return;
*/


	// TS way, weapon thinks happen alongside checking inputs
	pl.callWeaponThink();


	
	// HACK: If, this frame, w_attack_next was 0, for most weapons to allow firing,
	// make that a signal to reset inputPrimaryTapFrameCount.
	// This way, only the first frame to set w_attack_next benefits from inputPrimaryTapFrameCount.
	// Running a weapon's _primary several times for the same tap is not wanted, this is only
	// to give some tolerance to ease some slight frame desyncs between the client/server.
	BOOL wasPassingFrame = (pl.w_attack_next <= 0);
	
#if INPUT_TAP_DETECT_CHOICE == 1
		
	processInputs();
	
	// !!!
	// Should SEMI flags be handled here for anytime an input has been pressed
	// (even if not involved due to the other being picked, like primary fire
	// taking precedence when both are pressed so secondary is registered as 
	// held down the next frame, even when primary is let go but sec is not),
	// or only on PRIMARY / SECONDARY being handled?  Decisions decisions
	
	if(input_buttons & INPUT_BUTTON0){
		//pl.gflags |= GF_SEMI_TOGGLED;
	}else{
		// held down the previous frame, but not now?  That's a release.
		if(pl.gflags & GF_SEMI_TOGGLED){
			TS_Weapon_PrimaryAttackRelease(pl);
			pl.gflags &= ~GF_SEMI_TOGGLED;
		}
	}
	if(input_buttons & INPUT_BUTTON3){
		//pl.gflags |= GF_SEMI_SECONDARY_TOGGLED;
	}else{
		if(pl.gflags & GF_SEMI_SECONDARY_TOGGLED){
			TS_Weapon_SecondaryAttackRelease(pl);
			pl.gflags &= ~GF_SEMI_SECONDARY_TOGGLED;
		}
	}
	
	
#else
	//////////////////////////////////////////////
	//INPUT_TAP_DETECT_CHOICE == 2
	
	
	
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
		// method, which does something a bit different client and serverside.
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
		TS_Weapon_PrimaryAttackRelease(pl);
	}
	if(pl.inputSecondaryReleasedQueue && pl.inputSecondaryTapFrameCount == 0){
		pl.inputSecondaryReleasedQueue = FALSE;
		// TODO - remove 2nd parameter from that!
		TS_Weapon_SecondaryAttackRelease(pl);
	}
	
#endif// INPUT_TAP_DETECT_CHOICE
	
	//pl.callWeaponThink();
	
	
#if OTHER_PREDICTION_TEST == 2
	
	/*
	if(input_impulse == 115){
		TS_playerUseItems();
	}
	*/
	if(input_impulse == 115){
		if( !(pl.gflags & GF_UNUSED4)){
			TS_playerUseItems();
		}
		pl.gflags |= GF_UNUSED4;
	}else{
		pl.gflags &= ~GF_UNUSED4;
	}
#endif
	if(input_impulse == 116){
		if( !(pl.gflags & GF_UNUSED5)){
			TS_playerChangeFiremode();
		}
		pl.gflags |= GF_UNUSED5;
	}else{
		pl.gflags &= ~GF_UNUSED5;
	}
	
}//Game_Input



void processInputs(void){
	player pl = (player)self;
	
	if (input_buttons & INPUT_BUTTON0){
		//printfline("!!! PRIMA !!! (%d %d)", ((input_buttons & INPUT_BUTTON0)!=0), ((input_buttons & INPUT_BUTTON3)!=0));
		Weapons_Primary();
		
		pl.gflags |= GF_SEMI_TOGGLED;
		return;
	}
	
	
	if (input_buttons & INPUT_BUTTON3){
		//printfline("!!! SECO !!! (%d %d)", ((input_buttons & INPUT_BUTTON0)!=0), ((input_buttons & INPUT_BUTTON3)!=0));
		Weapons_Secondary();
		
		// TEST!
		//if(!(pl.gflags & GF_SEMI_SECONDARY_TOGGLED)){
		//	TS_playerUseItems();
		//}
		
		pl.gflags |= GF_SEMI_SECONDARY_TOGGLED;
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
	
	
	// No need for this now
	/*
	// These SEMI flag removals only happen if this area is reached
	// (note the 'return' statements above with button presses)
	// Nuclide already does that first one (only if Weapons_Release is called!)
	//pl.gflags &= ~GF_SEMI_TOGGLED;
	pl.gflags &= ~GF_SEMI_SECONDARY_TOGGLED;
	*/
	
}//processInputs





#ifdef CLIENT

// called when not ingame for sending a spawn request.
void PreSpawn_Input(void){
	player pl = (player)self;
	
	if(
		pSeatLocal->m_flUI_Display == UI_SCREEN::NONE &&
		(input_buttons & INPUT_BUTTON0) &&
		!(pl.gflags & GF_SEMI_TOGGLED) &&
		pSeatLocal->m_flBlockSpawnInputTime <= time
	){
		sendevent( "GamePlayerSpawn", "");
	}
	
	/*
	if(
		((input_buttons & INPUT_BUTTON0) && pSeatLocal->m_flBlockSpawnInputTime > time) ||
		pSeat->m_flInputBlockTime > time
	)
	{
		pSeatLocal->m_flBlockSpawnInputTime = time + 0.20f;
		pl.gflags |= GF_SEMI_TOGGLED;
		return;
	}
	*/
	
	// since the rest of this method is about to be skipped.
	if(input_buttons & INPUT_BUTTON0){
		pl.gflags |= GF_SEMI_TOGGLED;
	}else{
		pl.gflags &= ~GF_SEMI_TOGGLED;
	}
}//PreSpawn_Input







#ifdef CLIENT

// redirects from cmd.qc to be less of a mess over there.
void Input_useItems_press(void){
	player pl = (player)pSeat->m_ePlayer;
	
#if OTHER_PREDICTION_TEST == 0
	if( !(pl.gflags & GF_UNUSED3)){
		TS_playerUseItems();
	}
	pl.gflags |= GF_UNUSED3;
#elif OTHER_PREDICTION_TEST == 1
	pSeatLocal->m_bUseItems = TRUE;
#elif OTHER_PREDICTION_TEST == 2

	if( !(pl.gflags & GF_UNUSED3)){
		canPlaySwitchSound = TRUE;
	}else{
		pl.gflags |= GF_UNUSED3;
	}

	pSeatLocal->m_bUseItems = TRUE;
#endif
}//Input_useItems_press


void Input_useItems_release(void){
	player pl = (player)pSeat->m_ePlayer;
	
#if OTHER_PREDICTION_TEST == 0
	pl.gflags &= ~GF_UNUSED3;
#elif OTHER_PREDICTION_TEST == 1
	pSeatLocal->m_bUseItems = FALSE;
#elif OTHER_PREDICTION_TEST == 2
	pSeatLocal->m_bUseItems = FALSE;
	
	pl.gflags &= ~GF_UNUSED3;
#endif
}//Input_useItems_release

#endif




void Input_firemode_press(void){
	pSeatLocal->m_bChangeFiremode = TRUE;
}

void Input_firemode_release(void){
	pSeatLocal->m_bChangeFiremode = FALSE;
}






// Not yet called by Nuclide!  A series of notes for now
// (move to clientside files then)
//TODO: if spawning from seemingly the same click as "use new config" is still a problem, this is 
// definitely the place to try something
void ClientGame_Input_Frame(void){
	
	// This is trying to close weaponselect on detecting a right-click, but it 
	// has issues.
	// Idea is, this needs to *absorb* the right-click, and stop it from reaching
	// the rest of the client and server to work with weapons, like a change-ironsight
	// order.
	// This might stop the client weapon logic from seeing the right click, but not
	// the server.
	// It appears there is no way to stop that without the FTE built-in event method 
	// CSQC_Input_Frame (defined by Nuclide) letting the gamemod block right-click
	// inputs per some condition, like weapon-select being up.
	
	// TODO - changing what m_flInputBlockTime affects might be a good idea,
	// affecting other inputs like crouch is unnecessary, that causes the player to
	// uncrouch if changing weapons while crouched.
	
	player pl = (player)pSeat->m_ePlayer;
	
	if(pl == NULL)return;  // ???
	
	
	
	/*
	// does... funky things, not cumulative, only an offset forced this frame.
	// Don't do that.
	input_angles[0] += 36;
	input_angles[1] += 36;
	input_angles[2] += 36;
	*/
	
	
	if(pl.iState != PLAYER_STATE::SPAWNED && pSeatLocal->m_flUI_Display != UI_SCREEN::NONE){
		// If buying, don't allow any movement inputs.
		// The above is a similar check as "g_vguiWidgetCount > 0", but the buymenu does not
		// use VGUI.
		input_movevalues = [0,0,0];
		// does not stop rotation from left/right arrows, not that this was very important.
		//input_angles = [0,0,0];
	}
	
	if(pSeat->m_iHUDWeaponSelected && pSeat->m_iInputAttack2){   //input_buttons & INPUT_BUTTON3
		if(TS_HUD_CloseWeaponSelect(TRUE)){
			// might not even need this much, but verify.
			// might change going to weapons that have an immediate secondary fire
			//pSeat->m_flInputBlockTime = time + 0.2;
			input_impulse = 0;
			//input_buttons = 0;   no need for the whole buttons reset
			input_buttons &= ~INPUT_BUTTON3;
			pSeat->m_iInputAttack2 = FALSE;
		}else{
			//pSeat->m_iInputAttack2 = TRUE;
		}
	}
	
	// !!!
	// An override for this to go in CSQC_Input_Frame would be very nice I think,
	// unless there is some other way that I'm missing.
	
	if (pSeatLocal->m_iInputSpeed == TRUE) {
		input_buttons |= INPUT_BUTTON7;
		//self.flags |= FL_SNEAK;
		
	}else{
		//self.flags &= ~FL_SNEAK;
	}
	//printfline("input_buttons: %d", (INPUT_BUTTON7 & input_buttons) );
	
	
#if OTHER_PREDICTION_TEST == 2

	if(pSeatLocal->m_bUseItems){
		input_impulse = 115;
	}

/*
	if(pSeatLocal->m_bUseItems){
		if( !(pl.gflags & GF_UNUSED4)){
			input_impulse = 115;
		}
		pl.gflags |= GF_UNUSED4;
	}else{
		pl.gflags &= ~GF_UNUSED4;
	}
	*/
#endif


	if(pSeatLocal->m_bChangeFiremode){
		input_impulse = 116;
	}



}// ClientGame_InputFrame


#endif // CLIENT








//TAGGG - most of the alternate prediction demo.
// Replicates what's seen in Nuclide's src/predict.qc to make
// the toggle-options feature predicted without involving FTE's
// input_buttons.
//////////////////////////////////////////////////////////////////////////////////
#if OTHER_PREDICTION_TEST == 1

// Shared
void Custom_Game_Input(void){
	player pl = (player)self;
	
	if(custom_input_buttons == TRUE){
		if( !(pl.gflags & GF_UNUSED3)){
			//printfline("---CLICK---");
			TS_playerUseItems();
		}
		pl.gflags |= GF_UNUSED3;
	}else{
		pl.gflags &= ~GF_UNUSED3;

	}
}//Custom_Game_Input



#ifdef CLIENT

void Custom_ClientGame_Input_Frame(void){
	
	if(pSeatLocal->m_bUseItems){
		//pSeatLocal->m_bUseItems = FALSE;
		//input_buttons |= INPUT_BUTTON6;
		ary_custom_input_buttons[custom_clientcommandframe % 512] = TRUE;
	}
	
	if(!ary_custom_input_sentYet[custom_clientcommandframe % 512]){
		sendevent("GSVRCC", "ff", custom_clientcommandframe, ary_custom_input_buttons[custom_clientcommandframe % 512]);
		ary_custom_input_sentYet[custom_clientcommandframe % 512] = TRUE;
	}
	//printfline("CURRENT CLIENTCOMMAND FRAME: %d", custom_clientcommandframe);
	
	// And refresh the entry in the queue somewhere before this point, so that
	// loop-arounds don't cause issues from running into leftover/out-of-date
	// memory being set but not being worth paying attention to.
	float subtr = custom_clientcommandframe - 256;
	if(subtr < 0){subtr += 512;}
	float modulo = subtr % 512;
	ary_custom_input_buttons[modulo] = 0;
	ary_custom_input_sentYet[modulo] = FALSE;
}


void Custom_Predict_EntityUpdate(player pl){
	
	if (pl.entnum == player_localentnum) {
		/* run the player physics from the last approved servercommandframe to the current one */
		for (int i = pl.custom_sequence+1; i <= custom_servercommandframe; i++) {
			/* ...maybe the input state is too old? */
			//if (!getinputstate(i)) {
			//	break;
			//}
			custom_input_sequence = i;
			//pl.Physics_Run();
			
			custom_input_buttons = ary_custom_input_buttons[custom_input_sequence % 512];
			Custom_Game_Input();
		}
	}
	
	pl.custom_sequence = custom_servercommandframe;
}

void Custom_Predict_PlayerPreFrame(player pl){
	
	//printfline("---PREFRAME---");
	
	for (int i = pl.custom_sequence + 1; i <= custom_clientcommandframe; i++) {
		
		//float flSuccess = getinputstate(i);
		//if (flSuccess == FALSE) {
		//	continue;
		//}

		if (i==custom_clientcommandframe){
			//CSQC_Input_Frame();
			Custom_ClientGame_Input_Frame();
		}

		/* don't do partial frames, aka incomplete input packets */
		//if (input_timelength == 0) {
		//	break;
		//}

		/* this global is for our shared random number seed */
		custom_input_sequence = i;

		/* run our custom physics */
		//pl.Physics_Run();
		
		custom_input_buttons = ary_custom_input_buttons[custom_input_sequence % 512];
		Custom_Game_Input();
	}
	custom_clientcommandframe++;
}

void Custom_Predict_PlayerPostFrame(player pl){
	//printfline("---ROLLBACK---");
}


// called by server
void Custom_Prediction_Server_Callback(player pl){
	
	float received_servercommandframe = readfloat();
	custom_servercommandframe = received_servercommandframe;
	
	if(pl != NULL){
		Custom_Predict_EntityUpdate(pl);
	}
	
	if(pl != NULL){
		int EXTRA = readint();
		if(EXTRA > -1){
			pl.ary_myWeapons[pl.inventoryEquippedIndex].iBitsUpgrade_on = EXTRA;
			//pl.ary_myWeapons[pl.inventoryEquippedIndex].iBitsUpgrade_on_net = pl.ary_myWeapons[pl.inventoryEquippedIndex].iBitsUpgrade_on;
		}
	}
	
}

#else
	
	// SERVER

// short for GameServer_RunClientCommand.
void
CSEv_GSVRCC_ff(float arg_scf, float arg_ibc){
	//TS_playerUseItems();
	
	custom_servercommandframe = arg_scf;
	custom_input_buttons = arg_ibc;
	Custom_Game_Input();
	
	// send a message back!
	player pl = (player)self;
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte( MSG_MULTICAST, EVENT_TS::CUSTOM_PREDICTION_CALLBACK );
	WriteFloat( MSG_MULTICAST, custom_servercommandframe );
	
	if(pl.inventoryEquippedIndex > -1){
		WriteInt( MSG_MULTICAST, pl.ary_myWeapons[pl.inventoryEquippedIndex].iBitsUpgrade_on );
	}else{
		WriteInt( MSG_MULTICAST, -1 );
	}
	
	msg_entity = pl;
	multicast( [0,0,0], MULTICAST_ONE );
	
}

void Custom_EvaluateEntity(player pl){

	// SAVE_STATE
	//if(pl.inventoryEquippedIndex > -1){
	//	pl.ary_myWeapons[pl.inventoryEquippedIndex].iBitsUpgrade_on_net = pl.ary_myWeapons[pl.inventoryEquippedIndex].iBitsUpgrade_on;
	//}
	
}

#endif// CLIENT vs. SERVER


#endif// OTHER_PREDICTION_TEST
//////////////////////////////////////////////////////////////////////////////////


