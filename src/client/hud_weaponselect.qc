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

var float fHUDWeaponLast;

typedef struct {
	string sSprite;
	vector vOrigin;
} weaponsymbolinfo_t;


/*
=================
HUD_DrawWeaponSelect_PreviousItem

Checks and returns the next slot with a weapon in it
=================
*/

//TAGGG - REPLACEMENT.
//Now deal with int's (type) instead.
//Also, this takes two parameters now: what index in the player weapon list to start looking for
//the next weapon from, and whether finding the next/previous weapon is restricted
//to some slot in particular, like pressing the "2" key to go through weapons in slot 2
//(on reaching the last weapon, the 1st weapon in slot 2 is selected again, don't move to slot 3).
//Note that this is the same display slot. There is no slot 0.
//A slot of "-1" will be code for, no restriction, feel free to move between slots on trying to go
//to the previous weapon on the first of a slot, or the next weapon on the last of a slot.
//The last optional parameter, neede if freeSlotMovement is false, is what slot the weapon must belong to.
//If we pick a slot different of the currently selected weapon, we start over in the new slot.
int
HUD_DrawWeaponSelect_PreviousItem(int weaponID_toStartFrom, BOOLEAN freeSlotMovement, optional int forcedSlot)
{
	player pl = (player)pSeat->m_ePlayer;
	
	// set to TRUE if we start at an invalid range, so that we may include the first valid of any sort.
	BOOLEAN canAcceptSame = FALSE;
	
	
	//printfline("HUD_DrawWeaponSelect_PreviousItem: weaponID_toStartFrom:%i pl.ary_myWeapons_softMax:%i", weaponID_toStartFrom, pl.ary_myWeapons_softMax);
	//TAGGG CRITICAL - why wasn't this ">=" and just ">" ???
	if(weaponID_toStartFrom >= pl.ary_myWeapons_softMax){
		//shouldn't be possible but just in case.
		canAcceptSame = TRUE;
		return pl.ary_myWeapons_softMax-1;
	}
	
	weapondynamic_t dynaRef;
		
	weapondata_basic_t* weaponBasicP;
	weapondata_basic_t weaponBasicRef;
	
	int currentSlot = -1;
	
	if(weaponID_toStartFrom != -1){
		// Get what slot the currently equipped weapon is on.
		// If it doesn't match the forcedSlot (if applicable: 1-5 keys forcing one),
		// we start over at a weapon of ID -1 for the next one.
		// This happens on switching slots (picking a different 1-5 key) while weapon select
		// is open in a different slot, like having some weapon selected ins lot 2 but pressing 5.
		// Being in akimbo and requesting a lost other than 5 is also enough to force a reset of weaponID
		// to start from.
		dynaRef = pl.ary_myWeapons[weaponID_toStartFrom];
		
		if(!freeSlotMovement ){
			
			//That is, if the player was selecting a weapon in akimbo, but the slot is no longer 5..
			if(pl.weaponSelectHighlightAkimbo){
				if(forcedSlot!=5){
					weaponID_toStartFrom = -1; //hack to start at #0 instead
					canAcceptSame = FALSE;
					//dynaRef = pl.ary_myWeapons[0];
				}
			}else{
				//pl.weaponSelectHighlightAkimbo = FALSE;
				weapondata_basic_t* weaponBasicInvGetP = ary_weaponData[dynaRef.weaponID];
				weapondata_basic_t weaponBasicInvGetRef = *weaponBasicInvGetP;
				currentSlot = weaponBasicInvGetRef.iInventorySlot;
				
				//notice: picking an akimbo weapon choice while a non-akimbo weapon is selected
				// will trigger this too, since the forcedSlot will be 5. non-akimbo weapons never have that.
				
				if(currentSlot != forcedSlot){
					weaponID_toStartFrom = -1; //hack to start at #0 instead
					canAcceptSame = FALSE;
					//dynaRef = pl.ary_myWeapons[0];
				}
			}
			pl.weaponSelectHighlightAkimbo = (forcedSlot == 5);
			currentSlot = forcedSlot;
		}else{
			
			if(!pl.weaponSelectHighlightAkimbo){
			
				//So we have a place to start looking from. Off we go, find the next weapon that belongs to this same slot.
				//If we can't find it, we have to decide whether to loop back to the 1st/last weapon of this same slot,
				//or move on to the next/previous slot's first/last weapon.
				weaponBasicP = ary_weaponData[dynaRef.weaponID];
				weaponBasicRef = *weaponBasicP;
				currentSlot = weaponBasicRef.iInventorySlot;
				
			}else{
				weapondata_basic_t* weaponBasicBaseP = ary_weaponData[dynaRef.weaponID];
				weapondata_basic_t weaponBasicBaseRef = *weaponBasicBaseP;
				if(weaponBasicBaseRef.iAkimboID > 0 && dynaRef.iBitsUpgrade & BITS_WEAPONOPT_AKIMBO){
					
					weaponBasicP = ary_akimboUpgradeData[weaponBasicBaseRef.iAkimboID];
					weaponBasicRef = *weaponBasicP;
					//Should always be 5 for akimbo weapons regardless.
					//currentSlot = weaponBasicRef.iInventorySlot;
					currentSlot = 5;
					
				}else{
					//???  clearly can't go through this weapon as akimbo.
					pl.weaponSelectHighlightAkimbo = FALSE;
					
					weaponBasicP = ary_weaponData[dynaRef.weaponID];
					weaponBasicRef = *weaponBasicP;
					currentSlot = weaponBasicRef.iInventorySlot;
				}
			}
		}
	}else{
		//weaponID_toStartFrom is -1?  ok.
		canAcceptSame = FALSE;
		//dynaRef = pl.ary_myWeapons[0];
		pl.weaponSelectHighlightAkimbo = (forcedSlot == 5);
		currentSlot = forcedSlot;
	}
	
	
	//we only use the toStartFrom offset for finding the next/previous weapon in the same slot.
	//After that we start from the beginning/end of the next/previous slot accordingly for searching.
	int weaponID_toStartFromThisSlot = weaponID_toStartFrom;
	if(canAcceptSame && weaponID_toStartFromThisSlot != -1){
		weaponID_toStartFromThisSlot -= 1;
	}
	
	BOOLEAN scheduleTermination = FALSE;
	//int lastWeaponToCheck = 0;
	
	for(int slotOffset = 0; slotOffset <= 5; slotOffset++){
		
		int slotToMatch = ((currentSlot + slotOffset - 1) % 5) + 1;
		
		if(slotToMatch < 5){
			for(int i = weaponID_toStartFromThisSlot+1; i < pl.ary_myWeapons_softMax; i++){
				//where does a weapon match our slot? pick it.
				weapondynamic_t dynaOtherRef;
				dynaOtherRef = pl.ary_myWeapons[i];
				
				weapondata_basic_t* weaponBasicOtherP = ary_weaponData[dynaOtherRef.weaponID];
				weapondata_basic_t weaponBasicOtherRef = *weaponBasicOtherP;
				
				if(weaponBasicOtherRef.iInventorySlot == slotToMatch){
					//woohoo
					//foundNewWeapon = TRUE;
					pl.weaponSelectHighlightAkimbo = FALSE;
					//printfline("FOUND NON-AKIMBO WEAPO %i, ITS NAME: %s", i, weaponBasicOtherRef.sDisplayName);
					
					return i;
				}
			}
		}else{
			//oh my
			//if(pl.weaponSelectHighlightAkimbo){
			//	//don't reset toStartFrom.  Offset is intentional.
			//}
			
			for(int i = weaponID_toStartFromThisSlot+1; i < pl.ary_myWeapons_softMax; i++){
				//where does a weapon match our slot? pick it.
				weapondynamic_t dynaOtherRef;
				dynaOtherRef = pl.ary_myWeapons[i];
				
				weapondata_basic_t* weaponBasicOtherP = ary_weaponData[dynaOtherRef.weaponID];
				weapondata_basic_t weaponBasicOtherRef = *weaponBasicOtherP;
				
				if(weaponBasicOtherRef.iAkimboID > 0 && dynaOtherRef.iBitsUpgrade & BITS_WEAPONOPT_AKIMBO){
					//this weapon is akimbo, yay.
					pl.weaponSelectHighlightAkimbo = TRUE;
					return i;
				}
				
				
				if(weaponBasicOtherRef.iInventorySlot == slotToMatch){
					//To handle stand-alone akimbo weapons found.
					
					if(dynaOtherRef.iBitsUpgrade & BITS_WEAPONOPT_AKIMBO){
						pl.weaponSelectHighlightAkimbo = TRUE;
					}else{
						pl.weaponSelectHighlightAkimbo = FALSE;
					}
					return i;
				}
			}
		}
		
		//Moving on to check a different slot?  Reset weaponID_toStartFromThisSlot then
		weaponID_toStartFromThisSlot = -1;   //hack to make it start at 0
		
		if(scheduleTermination){
			//last shot we got.
			break;
		}
		
		if(freeSlotMovement == TRUE){
			
		}else{
			slotOffset -= 1;  //keep the slot exactly the same
			
			scheduleTermination = TRUE;
		}
		
	}//END OF LOOP THROUGH SLOTS
	
	//printfline("END.  weaponID_toStartFrom:%i", weaponID_toStartFrom);
	return weaponID_toStartFrom;  //uhhhh.  what??  guess there would be no change in this odd case
}//HUD_DrawWeaponSelect_PreviousItem

int
HUD_DrawWeaponSelect_NextItem(int weaponID_toStartFrom, BOOLEAN freeSlotMovement, optional int forcedSlot)
{
	player pl = (player)pSeat->m_ePlayer;
	
	// set to TRUE if we start at an invalid range, so that we may include the first valid of any sort.
	BOOLEAN canAcceptSame = FALSE;
	
	if(weaponID_toStartFrom >= pl.ary_myWeapons_softMax){
		//shouldn't be possible but just in case.
		canAcceptSame = TRUE;
		return pl.ary_myWeapons_softMax-1;
	}
	
	weapondynamic_t dynaRef;
		
	weapondata_basic_t* weaponBasicP;
	weapondata_basic_t weaponBasicRef;
	
	int currentSlot = -1;
	
	//printfline("HUD_DrawWeaponSelect_NextItem weaponID_toStartFrom:%i", weaponID_toStartFrom);
	
	if(weaponID_toStartFrom != -1){
		dynaRef = pl.ary_myWeapons[weaponID_toStartFrom];
		
		if(!freeSlotMovement ){
			//That is, if the player was selecting a weapon in akimbo, but the slot is no longer 5..
			
			if(pl.weaponSelectHighlightAkimbo){
				if(forcedSlot!=5){
					weaponID_toStartFrom = 1; //hack to start at #max instead
					canAcceptSame = FALSE;
					//dynaRef = pl.ary_myWeapons[0];
				}
			}else{
				//pl.weaponSelectHighlightAkimbo = FALSE;
				weapondata_basic_t* weaponBasicInvGetP = ary_weaponData[dynaRef.weaponID];
				weapondata_basic_t weaponBasicInvGetRef = *weaponBasicInvGetP;
				currentSlot = weaponBasicInvGetRef.iInventorySlot;
				
				//notice: picking an akimbo weapon choice while a non-akimbo weapon is selected
				// will trigger this too, since the forcedSlot will be 5. non-akimbo weapons never have that.
				if(currentSlot != forcedSlot){
					weaponID_toStartFrom = 1; //hack to start at #max instead
					canAcceptSame = FALSE;
					//dynaRef = pl.ary_myWeapons[0];
				}
			}
			
			if(pl.weaponSelectHighlightAkimbo != (forcedSlot==5) ){
				weaponID_toStartFrom = 1; //hack to start at #max instead
				canAcceptSame = FALSE;
				//dynaRef = pl.ary_myWeapons[0];
			}else{
				
				
			}
			pl.weaponSelectHighlightAkimbo = (forcedSlot == 5);
			currentSlot = forcedSlot;
		}else{
			
			if(!pl.weaponSelectHighlightAkimbo){
			
				//So we have a place to start looking from. Off we go, find the next weapon that belongs to this same slot.
				//If we can't find it, we have to decide whether to loop back to the 1st/last weapon of this same slot,
				//or move on to the next/previous slot's first/last weapon.
				weaponBasicP = ary_weaponData[dynaRef.weaponID];
				weaponBasicRef = *weaponBasicP;
				currentSlot = weaponBasicRef.iInventorySlot;
				
			}else{
				weapondata_basic_t* weaponBasicBaseP = ary_weaponData[dynaRef.weaponID];
				weapondata_basic_t weaponBasicBaseRef = *weaponBasicBaseP;
				if(weaponBasicBaseRef.iAkimboID > 0 && dynaRef.iBitsUpgrade & BITS_WEAPONOPT_AKIMBO){
					
					weaponBasicP = ary_akimboUpgradeData[weaponBasicBaseRef.iAkimboID];
					weaponBasicRef = *weaponBasicP;
					//Should always be 5 for akimbo weapons regardless.
					//currentSlot = weaponBasicRef.iInventorySlot;
					currentSlot = 5;
					
				}else{
					//???  clearly can't go through this weapon as akimbo.
					pl.weaponSelectHighlightAkimbo = FALSE;
					
					weaponBasicP = ary_weaponData[dynaRef.weaponID];
					weaponBasicRef = *weaponBasicP;
					currentSlot = weaponBasicRef.iInventorySlot;
				}
			}
		}
	}else{
		// is.. this even possible?
		//weaponID_toStartFrom is -1?  ok.
		
		// was ... = 1;  ?
		weaponID_toStartFrom = pl.ary_myWeapons_softMax; //hack to start at #max instead
		
		canAcceptSame = FALSE;
		//dynaRef = pl.ary_myWeapons[0];
		pl.weaponSelectHighlightAkimbo = (forcedSlot == 5);
		currentSlot = forcedSlot;
	}
	
	//we only use the toStartFrom offset for finding the next/previous weapon in the same slot.
	//After that we start from the beginning/end of the next/previous slot accordingly for searching.
	int weaponID_toStartFromThisSlot = weaponID_toStartFrom;
	if(canAcceptSame){
		weaponID_toStartFromThisSlot += 1;
	}
	
	BOOLEAN scheduleTermination = FALSE;
	//int lastWeaponToCheck = 0;
	
	//printfline("weaponID_toStartFromThisSlot:%i, canAcceptSame:%d", weaponID_toStartFromThisSlot, canAcceptSame);
	
	for(int slotOffset = 0; slotOffset <= 5; slotOffset++){
		
		//int slotToMatch = ((currentSlot - slotOffset - 1) % 5) + 1;
		int slotToMatch = (currentSlot - slotOffset - 1);
		if(slotToMatch < 0){
			slotToMatch += 5;  //easy way to loop around if we go under the minimum slot
		}
		//printfline("what slot %i", slotToMatch);
		
		slotToMatch = (int)((((float)slotToMatch) % 5)) + 1;
		
		if(slotToMatch < 5){
			for(int i = weaponID_toStartFromThisSlot-1; i >= 0; i--){
				//where does a weapon match our slot? pick it.
				weapondynamic_t dynaOtherRef;
				dynaOtherRef = pl.ary_myWeapons[i];
				
				weapondata_basic_t* weaponBasicOtherP = ary_weaponData[dynaOtherRef.weaponID];
				weapondata_basic_t weaponBasicOtherRef = *weaponBasicOtherP;
				
				if(weaponBasicOtherRef.iInventorySlot == slotToMatch){
					//woohoo
					//foundNewWeapon = TRUE;
					pl.weaponSelectHighlightAkimbo = FALSE;
					//printfline("HUD_DrawWeaponSelect_NextItem NON-AKIMBO WEAPON %i, ITS NAME: %s", i, weaponBasicOtherRef.sDisplayName);
					return i;
				}
			}
		}else{
			//oh my
			//if(pl.weaponSelectHighlightAkimbo){
			//	//don't reset toStartFrom.  Offset is intentional.
			//}
			
			for(int i = weaponID_toStartFromThisSlot-1; i >= 0; i--){
				// where does a weapon match our slot? pick it.
				weapondynamic_t dynaOtherRef;
				dynaOtherRef = pl.ary_myWeapons[i];
				
				weapondata_basic_t* weaponBasicOtherP = ary_weaponData[dynaOtherRef.weaponID];
				weapondata_basic_t weaponBasicOtherRef = *weaponBasicOtherP;
				
				if(weaponBasicOtherRef.iAkimboID > 0 && dynaOtherRef.iBitsUpgrade & BITS_WEAPONOPT_AKIMBO){
					//this weapon is akimbo, yay.
					pl.weaponSelectHighlightAkimbo = TRUE;
					return i;
				}
				
				if(weaponBasicOtherRef.iInventorySlot == slotToMatch){
					//To handle stand-alone akimbo weapons found.
					
					if(dynaOtherRef.iBitsUpgrade & BITS_WEAPONOPT_AKIMBO){
						pl.weaponSelectHighlightAkimbo = TRUE;
					}else{
						pl.weaponSelectHighlightAkimbo = FALSE;
					}
					return i;
				}
			}
		}
		
		//Moving on to check a different slot?  Reset weaponID_toStartFromThisSlot then
		//	hack to make it start at ary_myWeapons_softMax.  That is not having "- 1".
		weaponID_toStartFromThisSlot = pl.ary_myWeapons_softMax;
		
		if(scheduleTermination){
			//last shot we got.
			break;
		}
		
		if(freeSlotMovement == TRUE){
			
		}else{
			slotOffset -= 1;  //keep the slot exactly the same
			scheduleTermination = TRUE;
		}
	}//END OF LOOP THROUGH SLOTS
	
	
	//printfline("END. weaponID_toStartFrom:%i", weaponID_toStartFrom);
	// is "- 1" always a good idea here?
	return weaponID_toStartFrom - 1;  //uhhhh.  what??  guess there would be no change in this odd case
}//HUD_DrawWeaponSelect_NextItem


void
HUD_DrawWeaponSelect_Forward(void)
{
	player pl = (player)pSeat->m_ePlayer;
	if(pl.iState != PLAYER_STATE::SPAWNED){
		return;
	}
	
	if(pl.weaponSelectHighlightID == -1){
		//pick the weapon after then
		pl.weaponSelectHighlightAkimbo = pl.weaponEquippedAkimbo;
		pl.weaponSelectHighlightID = HUD_DrawWeaponSelect_NextItem(pl.inventoryEquippedIndex, TRUE);
		
		//printfline("HUD_DrawWeaponSelect_Forward A? %i", pl.weaponSelectHighlightID);
		
		if(pl.weaponSelectHighlightID != -1){
			sound(pl, CHAN_ITEM, "common/wpn_hudon.wav", 0.5, ATTN_NONE);
			pSeat->m_flHUDWeaponSelectTime = time + 3;
		}else{
			pSeat->m_flHUDWeaponSelectTime = 0;
		}
	}else{
		
		//printfline("HUD_DrawWeaponSelect_Forward B? %i", pl.weaponSelectHighlightID);
		
		pl.weaponSelectHighlightID = HUD_DrawWeaponSelect_NextItem(pl.weaponSelectHighlightID, TRUE);
		if(pl.weaponSelectHighlightID != -1){
			sound(pl, CHAN_ITEM, "common/wpn_moveselect.wav", 0.5, ATTN_NONE);
			pSeat->m_flHUDWeaponSelectTime = time + 3;
		}else{
			pSeat->m_flHUDWeaponSelectTime = 0;
		}
	}
	
}

void
HUD_DrawWeaponSelect_Back(void)
{
	player pl = (player)pSeat->m_ePlayer;
	if(pl.iState != PLAYER_STATE::SPAWNED){
		return;
	}
	
	if(pl.weaponSelectHighlightID == -1){
		//pick the weapon after then
		pl.weaponSelectHighlightAkimbo = pl.weaponEquippedAkimbo;
		pl.weaponSelectHighlightID = HUD_DrawWeaponSelect_PreviousItem(pl.inventoryEquippedIndex, TRUE);
		
		//printfline("HUD_DrawWeaponSelect_Back C? %i", pl.weaponSelectHighlightID);
		
		if(pl.weaponSelectHighlightID != -1){
			sound(pl, CHAN_ITEM, "common/wpn_hudon.wav", 0.5, ATTN_NONE);
			pSeat->m_flHUDWeaponSelectTime = time + 3;
		}else{
			pSeat->m_flHUDWeaponSelectTime = 0;
		}
	}else{
		
		//printfline("HUD_DrawWeaponSelect_Back D? %i", pl.weaponSelectHighlightID);
		
		pl.weaponSelectHighlightID = HUD_DrawWeaponSelect_PreviousItem(pl.weaponSelectHighlightID, TRUE);
		if(pl.weaponSelectHighlightID != -1){
			sound(pl, CHAN_ITEM, "common/wpn_moveselect.wav", 0.5, ATTN_NONE);
		pSeat->m_flHUDWeaponSelectTime = time + 3;
		}else{
			pSeat->m_flHUDWeaponSelectTime = 0;
		}
	}

}




// TODO!!! also for this to be supported instead of HUD_DrawWeaponSelect_CheckClick,
// need to involve "m_iHUDWeaponSelected" elsewhere in this file properly!
// _Trigger is not even called if iHUDWeaponSelected is FALSE !
void
HUD_DrawWeaponSelect_Trigger(void)
{
	player pl = (player)pSeat->m_ePlayer;
	if(pl.iState != PLAYER_STATE::SPAWNED){
		return;
	}
	
	//TAGGG - TODO - was commented out in old FreeTS, doing so here too.
	// But figure out what it needs to do, this likely wasn't pointless
	/*
	player pl = (player)pSeat->m_ePlayer;
	pl.setInventoryEquippedIndex(pSeat->m_iHUDWeaponSelected);
	sendevent("PlayerSwitchWeapon", "i", pSeat->m_iHUDWeaponSelected);
	sound(pSeat->m_ePlayer, CHAN_ITEM, "common/wpn_select.wav", 0.5f, ATTN_NONE);
	pSeat->m_iHUDWeaponSelected = pSeat->m_flHUDWeaponSelectTime = 0;
	*/
	
	// Redirect!
	// ACTUALLY not yet.  This redirect won't work until script
	// involving m_iHUDWeaponSelected is properly hooked up!
	
	// NEVERMIND.  Attempt to stop holding down primary fire while pushing number keys
	// to open weapon-select instantly picking a weapon.
	// It works, but can be annoying as this completly blocks the ability to tell
	// what is or isn't a fresh key press during that time.  Not worth it.
	/*
	player pl = (player)pSeat->m_ePlayer;
	if(pSeat->m_flInputBlockTime > time){
		return;
	}
	*/
	
	HUD_DrawWeaponSelect_CheckClick();
}



// Cheap way to instantly close the weapon select area
BOOLEAN
HUD_CloseWeaponSelect(BOOL playOffSound)
{
	player pl = (player)pSeat->m_ePlayer;
	
	if(pSeat->m_flHUDWeaponSelectTime != -1){
		
		if(playOffSound && getplayerkeyvalue(player_localnum, "*spec") == "0"  ){
			sound(pl, CHAN_ITEM, "common/wpn_hudoff.wav", 0.5, ATTN_NONE);
		}
		//pSeat->fHUDWeaponSelected = 0;   //no harm but no need now
		
		//TAGGG - only makes sense.
		pl.weaponSelectHighlightID = -1;
		pl.weaponSelectHighlightAkimbo = FALSE;
		
		pSeat->m_flHUDWeaponSelectTime = -1;
		return TRUE;
	}
	
	return FALSE;   //did not.
}



/*
=================
HUD_DrawWeaponSelect

Drawn every frame through HUD.c
=================
*/
void
HUD_DrawWeaponSelect(void)
{
	player pl = (player)pSeat->m_ePlayer;
	
	if ( pSeat->m_flHUDWeaponSelectTime < time) {
		//if (pSeat->fHUDWeaponSelected) {
		
		// only need to play the sound the first time,  but keep blocking
		// the below methods.
		if(pSeat->m_flHUDWeaponSelectTime != -1){
			pSeat->m_flHUDWeaponSelectTime = -1;
				
			//printfline("HUD_DrawWeaponSelect IM closin my weapon select 1");
			
			HUD_CloseWeaponSelect(TRUE);
		}
		
		//}
		return;
	}
	
	//TAGGG - TEST THIS!!! Does the compile order allow this??
	drawPlayerInventory_buy(FALSE);
	
	drawPlayerInventory_TopBar(-1, FALSE);
	
}//HUD_DrawWeaponSelect




//if the user clicked (by calling this mehtod we assume they did), we see
//if the user was in weapon select. If so, pick it.
BOOLEAN
HUD_DrawWeaponSelect_CheckClick(void)
{
	player pl = (player)pSeat->m_ePlayer;
	if(pl.iState != PLAYER_STATE::SPAWNED){
		HUD_CloseWeaponSelect(FALSE);
		return FALSE;
	}
	
	player pl = (player)pSeat->m_ePlayer;
	
	if(pl.weaponSelectHighlightID != -1){
		// clicking picks it then.
		
		pSeat->m_flHUDWeaponSelectTime = -1;
		
		// don't get overridden by the draw sound (CHAN_AUTO, not CHAN_ITEM)
		// ...or really, just don't play this at all.  The TS weapon is much more silent anyway,
		// needs more sound changes.  Removals?
		//sound(pl, CHAN_AUTO, "common/wpn_select.wav", 0.5f, ATTN_NONE);
		
		
		TS_playerEquippedWeapon(pl, pl.weaponSelectHighlightID, pl.weaponSelectHighlightAkimbo);
		
		pl.weaponSelectHighlightID = -1;
		pl.weaponSelectHighlightAkimbo = FALSE;
		
		return TRUE;
	}else{
		return FALSE;  //didn't change the weapon.
	}
}//HUD_DrawWeaponSelect_CheckClick


void
HUD_DrawWeaponSelect_Last(void)
{
	//TAGGG - TODO.  Support this.
	/*
	player pl = (player)pSeat->m_ePlayer;
	if (pl.g_items & g_weapons[pSeat->m_iOldWeapon].id) {
		pl.setInventoryEquippedIndex(pSeat->m_iOldWeapon);
		sendevent("PlayerSwitchWeapon", "i", pSeat->m_iOldWeapon);
	}
	*/
}



void
HUD_SlotSelect(int slot)
{
	player pl = (player)pSeat->m_ePlayer;
	if(pl.iState != PLAYER_STATE::SPAWNED){
		return;
	}
	
	int slotPicked = slot+1;
	
		
	// Keep track of the currently open slot. Navigate through it...
	// move to another slot if needed
	
	//printlinef("HUD_SlotSelect: %i maxweap:%i classname:%s\n", slot, pl.ary_myWeapons_softMax, pl.classname);
	//printfline("weapon slot currently highlighted: %i", pl.weaponSelectHighlightID);
	
	if(pl.weaponSelectHighlightID == -1){
		//pick the weapon after then
		
		pl.weaponSelectHighlightAkimbo = pl.weaponEquippedAkimbo;
		
		
		pl.weaponSelectHighlightID = HUD_DrawWeaponSelect_PreviousItem(-1, FALSE, slotPicked);
		if(pl.weaponSelectHighlightID != -1){
			sound(pl, CHAN_ITEM, "common/wpn_hudon.wav", 0.5, ATTN_NONE);
			pSeat->m_flHUDWeaponSelectTime = time + 3;
		}else{
			pSeat->m_flHUDWeaponSelectTime = 0;
		}
	}else{
		// uhhhh...  try going previous of -1 then?  Hits the first weapon we got I think.
		pl.weaponSelectHighlightID = HUD_DrawWeaponSelect_PreviousItem(pl.weaponSelectHighlightID, FALSE, slotPicked);
		if(pl.weaponSelectHighlightID != -1){
			sound(pl, CHAN_ITEM, "common/wpn_moveselect.wav", 0.5, ATTN_NONE);
		pSeat->m_flHUDWeaponSelectTime = time + 3;
		}else{
			pSeat->m_flHUDWeaponSelectTime = 0;
		}
	}
	
}

