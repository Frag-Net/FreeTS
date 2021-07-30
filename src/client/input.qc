
// NEW FILE.

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
		
		// primary fire?
		if(!pSeatLocal->m_bNeedPrimaryRelease && (input_buttons & INPUT_BUTTON0) ){
			
			if(
				pSeatLocal->fVGUI_Display == VGUI_SCREEN::NONE &&
				getplayerkeyvalue(player_localnum, "*spec") != "0"
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
		// ???
		return;
	}
	
	// This was removed?  Legacy VGUI
	// If we are inside a VGUI, don't let the client do stuff outside
	if ((pSeatLocal->fVGUI_Display != VGUI_SCREEN::NONE)) {
		pSeat->m_flInputBlockTime = time + 0.2;
	}
	
	// we're changing this up a little.
	// We'll call a method to let weapon-select related script determine whether
	// the player is going through weapon selection when they clicked, not here.
	// That is we just call it if a click was detected, it does the rest.
	// It will return TRUE if it caused the current weapon to be changed
	// (since we don't want to send a fire order below like left-clicking usually does)
	// NO NEED FOR THIS CHECK, Nuclide does HUD_DrawWeaponSelect_Trigger on detecting a
	// click while something is selected in weapon select.
	// WAIT!  Keep for now, other things have to be changed internally for _Trigger to
	// work right.
	
	/*
	// Nuclide calls the Trigger method fine again
	if(input_buttons & INPUT_BUTTON0){
		if(HUD_DrawWeaponSelect_CheckClick()){
			input_buttons = 0;
			pSeat->m_flInputBlockTime = time + 0.2;
		}
	}
	*/
	
	//TAGGG - this block is all new.   apparently this is right-click.
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
	
}//GameClient_PlayerInputRaw


