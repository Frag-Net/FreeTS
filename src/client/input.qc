
// NEW FILE.

// RECENT: This file is pending deletion, if the "GamePlayerSpawn" message call in
// ts/src/shared/input.qc is good enough.
// That would mean GameClient_SpectatorInputRaw, nor any pSeatLocal vars only it uses,
// would no longer be necessary.
// Just want to be sure first with some more tests, no getting locked out of spawning.
// GameClient_PlayerInputRaw is tiny and hud.qc can do what it does instead.

// The "DISABLED" area further down is worth seeing if supporting right click to close
// an open weapon select immediately without applying any selection is a good idea though. 

 // -----------------------------
 
 

// WARNING: Do not get this file mixed up with <game>/src/shared/input.qc, that one is
// only called when the player is spawned (collision, seen by others, etc.).
// This is for checking to see if the user performed some action that does not need
// to be checked by the server, such as INPUT_BUTTON0 (primary fire) while not in any
// VGUI choice (blank screen) to send a message to the server to swawn the player.
// This is reached through draw-calls (root of the calls is method CSQC_UpdateView).
// It works.

// ALSO, this is called continually to check for user-provided input, it is not only
// called when user input is detected.  Be aware of that.


// Also, this version is for while in spectator.  See further down for the "for-player"
// version.
void
GameClient_SpectatorInputRaw(void)
{
	// If in spectator with nothing open (no MoTD, no buyside menu),
	// go ahead and spawn ingame.
	
	if(pSeatLocal->fVGUI_Display == VGUI_SCREEN::NONE && pSeatLocal->m_flPrevVGUI != VGUI_SCREEN::NONE){
		// Current display is NONE, yet the previous wasn't (Recent change to NONE)?
		// Set that.
		pSeatLocal->m_bNeedPrimaryRelease = TRUE;
		pSeatLocal->m_flReleaseTime = time + 0.15f;
	}
	
	pSeatLocal->m_flPrevVGUI = pSeatLocal->fVGUI_Display;
	
	// OKAY.  So little issue.
	// Modern Nuclide does not offer a way to read "input_buttons" in the usual places
	// (CSQC_Input_Frame), can they be re-gathered?

	// COPIED FROM src/client/predict.qc, for scraping through
	// all queued input frames for sending (or not yet verified to have
	// been received by the server.  I think?).
	// Or use the one at clientcommandframe only.  Hmm.

	// quote from fteextensions.qc:
	// The sequence number range used for prediction should normally be
	//     servercommandframe < sequence <= clientcommandframe.

	//printf("WHAT are the client/server comm frames? %d %d\n", clientcommandframe, servercommandframe);
	//for (int i = pl.sequence + 1; i <= clientcommandframe; i++) {
	
	/*
	bool wasButtonPushedThisFrame = FALSE;
	for (int i = servercommandframe+1; i <= clientcommandframe; i++) {
		float flSuccess = getinputstate(i);
		if (flSuccess == FALSE) {
			continue;
		}

		//if (i==clientcommandframe){
		//	CSQC_Input_Frame();
		//}

		if (input_timelength == 0) {
			break;
		}
		
		if((input_buttons & INPUT_BUTTON0) != 0){
			//printfline("IM here man %d\n", (input_buttons & INPUT_BUTTON0) != 0);
			// any frame says I got pushed?  Treat it as such.
			wasButtonPushedThisFrame = TRUE;
		}

		//input_sequence = i;
	}
	*/
	
	float flSuccess = getinputstate(clientcommandframe);
	if (flSuccess) {
		//printf("BUT HOW? %d - %d\n", (pSeatLocal->m_bNeedPrimaryRelease), (( input_buttons & INPUT_BUTTON0)!=0) );
		
		// IDEA: could we just do this?
		/*
		if(pSeatLocal->m_bNeedPrimaryRelease){
			if(!wasButtonPushedThisFrame)){
				pSeatLocal->m_bNeedPrimaryRelease = FALSE;
			}
		}
		*/
		// INSTEAD OF THIS
		///////////////////////////////////////////////////////
		if(pSeatLocal->m_bNeedPrimaryRelease){
			// yay.
			if(!(input_buttons & INPUT_BUTTON0)){
				// not pushed?  Check it
				if(time >= pSeatLocal->m_flReleaseTime){
					// okay!  Not touched for enough time.
					pSeatLocal->m_bNeedPrimaryRelease = FALSE;
				}
			}else{
				// Touched?  Oh.
				pSeatLocal->m_flReleaseTime = time + 0.15f;
			}
		}
		///////////////////////////////////////////////////////
		
		player pl = (player)pSeat->m_ePlayer;
		
		// primary fire?
		if(!pSeatLocal->m_bNeedPrimaryRelease && (input_buttons & INPUT_BUTTON0) ){
			
			if(
				pSeatLocal->fVGUI_Display == VGUI_SCREEN::NONE &&
				//getplayerkeyvalue(player_localnum, "*spec") != "0"
				pl.iState != PLAYER_STATE::SPAWNED
			){
				// && getstati(STAT_RULE_ALLOW_SPAWN))
				// just send the intention we want to spawn, the server will see if a delay is needed.
				// And only work if we're not in some other screen AND not spawned. Clicking to spawn while ingame (die) would be irritating.
				
				// Check is no longer needed, only the spectator would have reached this method to begin with.
				//if( stof(getplayerkeyvalue(player_localnum, "*team")) == TEAM_SPECTATOR)
				
				//TAGGG - TODO - should some minimum cooldown before respawning be enforced,
				// and the countdown shows up if the user clicks too soon since a respawn?
				// Print this if the client suspects that will be the case, or let spawn-delay
				// be some serverstat that is known here at all times.
				//CSQC_Parse_CenterPrint("Spawning soon...\n");
									
				sendevent( "GamePlayerSpawn", "");
				
				VGUI_ChangeScreen(VGUI_SCREEN::NONE);

				// probably unnecessary?
				EV_TS_resetViewModel();
					
			}
		}
	}
	
}//GameClient_SpectatorInputRaw


// While a player.
void
GameClient_PlayerInputRaw(void)
{
	player pl = (player)pSeat->m_ePlayer;
	// weapon select extra.
	if(pl == NULL){
		return;
	}
	
	// This was removed?  Legacy VGUI
	// If we are inside a VGUI, don't let the client do stuff outside
	if (pl.iState != PLAYER_STATE::SPAWNED && pSeatLocal->fVGUI_Display != VGUI_SCREEN::NONE){
		pSeat->m_flInputBlockTime = time + 0.2;
	}
	
	
	// No need to check for calling TS_HUD_DrawWeaponSelect_CheckClick or
	// HUD_DrawWeaponSelect_Trigger here, Nuclide calls the latter which works
	// fine.
	
	
	// CRITICAL.
	// DISABLED.
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
	/*
	if(pSeat->m_iInputAttack2){   //input_buttons & INPUT_BUTTON3){
		if(HUD_CloseWeaponSelect(TRUE)){
			pSeat->m_flInputBlockTime = time + 0.2;
			input_impulse = 0;
			input_buttons = 0;
			pSeat->m_iInputAttack2 = FALSE;
		}else{
			//pSeat->m_iInputAttack2 = TRUE;
		}
	}
	*/
	
}//GameClient_PlayerInputRaw


