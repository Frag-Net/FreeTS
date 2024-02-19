




#ifdef SERVER
void
centerprintToAll(string strSend){
	for (entity eFind = world; (eFind = find(eFind, classname, "player"));) {
		centerprint(eFind, strSend);
	}
	// NOTE!  These would be real spectators now, not just players that can use
	// the buy menu.  Is that ok?
	for (entity eFind = world; (eFind = find(eFind, classname, "spectator"));) {
		centerprint(eFind, strSend);
	}
}//END OF centerprintToAll
#endif



// NOTICE - there already is a "floor" method, but it might be considered
// incorrect for negative numbers. We have a fix!
int
floor_proper(float arg){
	if(arg >= 0){
		//no change needed
		return (int)(floor(arg));
	}else{
		// aha!  Do a little shifting around.
		// In short, this is the same as though arg were positive, and we took the opposite
		// direction operation instead... and make the result negative.
		// So yes, floor_proper(-42.7) would be -43, not -42.
		return (int)(-ceil(-arg));
	}
}
int ceil_proper(float arg){
	if(arg >= 0){
		//no change needed
		return (int)(ceil(arg));
	}else{
		//same idea as above.
		return (int)(-floor(-arg));
	}
}



// New utility method.
// I don't know if QuakeC has its own "round"-like method, but I tried.
int round(float arg){

	// WHOOPS.  There is one.
	// We'll trust it rounds properly, as in	2.5 rounded is 3. and -2.5 rounded is -3.
	return (int)rint(arg);

	/*
	float decimalOnly = arg - ((int)arg);
		
	if(arg >= 0){
		//this... might be cheaper than some modulos operation?
		if(decimalOnly < 0.5){
			//round down.
			return floor(arg);
		}else{
			//round up.
			return ceil(arg);
		}
	}else{
		if(decimalOnly < -0.5){
			//round down.
			return floor(arg);
		}else{
			//round up.
			return ceil(arg);
		}
	}
	*/
	
}//END OF round



float randomInRange_raw_f(float min, float max){
	return min + ((max - min) * random());
}//randomInRange


// This is the fixed version to ensure random() does not hit an invalid range.
// Although this is much more important for the int one in most cases.
// NOTE! Turns it it is already impossible for random() to return exactly 1, so
// removing the bound check.  No different from _raw above.
float randomInRange_f(float min, float max){
	/*
	float r = random();
	if(r >= 1.0f){
		//r = 0.999f;  //should be fine
		//nah, just play it safe... force the max possible it would usually be in this case
		//However many decimals out to go is unclear. Let's be safe here.
		//Especially considering that float precision could be limited
		//to 3-4 places, judging from printouts trying to use more digits.
		return max - 0.001f;
	}
	*/
	return min + ((max - min) * random());
}//zrandomInRange



int randomInRange_raw_i(int min, int max){
	return min + floor_proper((max - min + 1) * random());
}// randomInRange

// This is the fixed version to ensure random() does not hit an invalid range.
int randomInRange_i(int min, int max){
	float r = random();
	if(r >= 1.0f){
		//r = 0.999f;  //should be fine
		return max;   //that's the point really
	}

	return min + floor_proper((max - min + 1) * random());

}//randomInRange

//And just an isolated version of what goes on to make sure the random value isn't >= 1.
float safeRandom(void){
	float r = random();
	if(r >= 1.0f){
		//adjust
		return 1.0f - 0.001f;
	}else{
		//looks fine
		return r;
	}
}//safeRandom



// Called for some things, like grenades, that don't behave as well
// when removed instantly by "remove(self)".
// This gives a slight delay so that the pain logic still receives
// the coordinates of the grenade that detonated (clientside).
// As for why we couldn't just send the coords of the grenade from the
// server's end, no idea.
// Only lets you specify the entity to GET a location from, and if the
// entity disappears too soon, no location gets sent.
#ifdef SERVER
void removeSelfDelayed(entity entTarget){
	
	setmodel( entTarget, NULL );
	entTarget.modelindex = 0;  //This may be redundant with above.
	
	entTarget.solid = SOLID_NOT;
	entTarget.velocity = '0 0 0';
	entTarget.movetype = MOVETYPE_NONE;
	entTarget.takedamage = DAMAGE_NO;
	entTarget.flags = 0;  //safety?
	
	entTarget.dmg_take = 0;
	entTarget.dmg_save = 0;
	entTarget.dmg_inflictor = NULL;
	
	
	entTarget.touch = NULL;
	//entTarget.gravity = 0;
	entTarget.classname = "remove_me";  //safety
	setsize( entTarget, '0 0 0', '0 0 0' );
	
	entTarget.think = entity_removeSelf;
	entTarget.nextthink = time + 0.11f;
	
	//entTarget.alpha = 0.0;  //not helpful..
}
#endif

void entity_removeSelf(void){
	remove(self);  //that's it.
}


// A "string" is still returned.
// Oh wait... we have a built-in for this.  ah well.
// And can't be static because...   even what 'static' means in FTE had to be 
// completely re-defined, apparently.
string floatToChar(float someFloat){
	/*
	switch(someFloat){
		case 65: return "a";
		case 66: return "b";
	}
	*/
	return chr2str(someFloat);
}


// How many bits in 'bitmask' are set (1), from bitStart to bitEnd?
// Note that bitStart and End are meant to be the bits themselves, they're not single counts like
// indexes of characters in some string (spaces to move from the left).
// That is, to represent the 5th bit, we don't want "5", we want 16 (binary: 10000).
// The first bit is 1, however (binary: still 1). Starting at 0 does not make as much sense, but would still work I think.
// Example: in a bitmask of 43 (binary: 101011), there are 4 1's.
// bitEnd defaults to the largest bit possible in a 32-bit int (really 0x80000000), but because QuakeC forces int's to be
// signed, this bit actually represents the greatest negative number possible, oddly enough.
int count1Bits(int bitmask, optional int bitStart = 0x1, optional int bitEnd = -2147483648){
	int _1Count = 0;
	int currentBit = bitStart;
	while(TRUE){
		if(bitmask & currentBit){
			_1Count += 1;
		}
		if(currentBit < bitEnd){
			currentBit = currentBit << 1;  //next.
		}else{
			//stop!
			break;
		}
	}
	
	return _1Count;
}//END OF count1Bits


// Where is the locaiton of the first bit, given bits bitStart and endBit (see above about those).
// Note this search is in increasing order, so in bitmask 164 (binary: 10100100), we expect
// 4 to be returned as that is the third bit (first 1 from the right).
// AND note that this method returns '0' if no 1 bit could be found in the range given.
// a bit of 0 is impossible to be returned if any were found, so it's a good flag.
// Signed-bit oddities may prevent '-1' from being a great answer.
int findFirst1Bit(int bitmask, optional int bitStart = 0x1i, optional int bitEnd = -2147483648i){
	int currentBit = bitStart;
	while(TRUE){
		if(bitmask & currentBit){
			//we found a bit with 1!
			return currentBit;
		}
		if(currentBit < bitEnd){
			currentBit = currentBit << 1;  //next.
		}else{
			//stop!
			break;
		}
	}
	//got this far without returning yet?  Stop.
	return 0;
}//END OF findFirst1Bit







// NOTICE - "common/null.wav" must be precached someplace earlier.
// As of now that is in server/entry.c, method 'initents'.
// I doubt support for optional flags (2nd to last parameter) is necessary, but we could.
void stopSound(entity e, float chan){
	sound(e, chan, "common/null.wav", 0.0, ATTN_NONE, 0, 0);
	
	/*
	// This doesn't do anything... ?   unlike what the 'built-in's file says about it ?
#ifdef CLIENT
	soundupdate(pl, CHAN_VOICE, "", -1, ATTN_NORM, 100, 0, 0);
#endif
	*/
}//END OF stopSound







void entity_beginCorpseFadeOut(void){
	
	//Most things default to 0, strangely (which is still opaque though)
	//Have to count down from 1 though to "fade out".
	self.alpha = 1;
	
	self.think = entity_corpseFadeOut;
	self.nextthink = time + 0;
}//END OF entity_beginCorpseFadeOut

void entity_corpseFadeOut(void){
	//sooo... what's the difference?  'CUZ I DON'T GET IT
	//self.alpha -= ‭0.01428571f;  // 1/70
	
	self.alpha = self.alpha - 0.01428571f;
	
	if(self.alpha <= 0.01){
		//printfline("corpse despawned");
		//safety measure, exactly 0 makes it opaque actually.
		//Remove anyway.
		self.alpha = 0.01;
		
		remove(self);
	}else{
		//more transparency left to go clearly.
		self.think = entity_corpseFadeOut;
		self.nextthink = time + 0.1;
	}
}//END OF entity_beginCorpseFadeOut


// It is assumed the player pitch is 0 for mid-level, and goes up for negative degrees, down for positive.
// what's returned is instead 0 for as low as possible, 1 for as high as possible.
// How high/low the player is looking can have an impact on the stunt performed, or so I was told.
// Also used to draw the dot that goes along the segmented arc (of three pieces) to the left ofthe crosshair.
float getViewPitchRelativeRatio(float playerPitch){
	return (bound(-31, playerPitch, 30) + 31) / (30 - -31);
}//END OF getViewPitchRelativeRatio


// actually 0 in this case, used to be random(4, 8).
float getViewModelAnimExtraDuration(void){
	return 0;
}


#ifdef SERVER
void entityRemoveRespawnFlag(CBaseEntity arg_this){
	// old way
	//arg_this.gflags &= ~GF_CANRESPAWN;
	arg_this.identity &= ~IDENTITY_CANRESPAWN;
}
#endif






// Typically call me from weapons in shared script!
void
TS_Weapons_ViewAnimation(player pl, int i, float fDuration)
{
	//printfline("TS_Weapons_ViewAnimation: %i %.2f", i, fDuration);
	pl.w_idle_next = fDuration;
#ifdef CLIENT
	TS_View_PlayAnimation(pl, i, fDuration);
#else
	pl.flViewModelFrame = i;
#endif
	pl.weapontime = 0.0f;
}

void
TS_Weapons_ViewAnimation_noLaserLock(player pl, int i, float fDuration)
{
	//printfline("TS_Weapons_ViewAnimation_noLaserLock: %i %.2f", i, fDuration);
	pl.w_idle_next = fDuration;
#ifdef CLIENT
	TS_View_PlayAnimation_noLaserLock(pl, i, fDuration);
#else
	pl.flViewModelFrame = i;
#endif
	pl.weapontime = 0.0f;
}


void
TS_Weapons_ViewAnimation_EndIdle(player pl, int i, float fDuration)
{
	//printfline("TS_Weapons_ViewAnimation_EndIdle: %i %.2f", i, fDuration);
	pl.w_idle_next = fDuration;
#ifdef CLIENT
	TS_View_PlayAnimation_EndIdle(pl, i, fDuration);
#else
	pl.flViewModelFrame = i;
#endif
	pl.weapontime = 0.0f;
}

void
TS_Weapons_ViewAnimation_EndIdle_custom(player pl, int i, float fDuration, float fIdleEndOffset)
{
	//printfline("TS_Weapons_ViewAnimation_EndIdle_custom: %i %.2f %.2f", i, fDuration, fIdleEndOffset);
	pl.w_idle_next = fDuration;
#ifdef CLIENT
	TS_View_PlayAnimation_EndIdle_custom(pl, i, fDuration, fIdleEndOffset);
#else
	pl.flViewModelFrame = i;
#endif
	pl.weapontime = 0.0f;
}



#ifdef CLIENT

void
TS_View_PlayAnimation(player pl, int iSequence, float fDuration){
	
	/*
	// TEST!!!
	float flSequence = (float)iSequence;
	player pl = (player)pSeat->m_ePlayer;
	if(pSeat->m_eViewModel.frame != flSequence){
		printfline("WHaaa??? %d %d", pSeat->m_eViewModel.frame, flSequence);
		pSeat->m_eViewModel.frame = flSequence;
		pl.weapontime = 0.0f;
		pSeat->m_eViewModel.frame1time = 0;
	}
	*/
	
	pSeat->m_eViewModel.frame = (float)iSequence;
	pl.weapontime = 0.0f;
	pl.weaponframe = iSequence;
	SAVE_STATE(pl.weapontime)
	
	//pSeat->m_eViewModel.frame2time = 0;
	//pSeat->m_eViewModel.frame1time = 0;
	//MODDD
	//viewModelFrameChangedRecently = 1;
	
	pl.w_freeze_idle_next = -1;  //assume this?
	pl.lasersightUnlockTime = FALSE;
}

void
TS_View_PlayAnimation_noLaserLock(player pl, int iSequence, float fDuration){
	pSeat->m_eViewModel.frame = (float)iSequence;
	pl.weapontime = 0.0f;
	pl.weaponframe = iSequence;
	SAVE_STATE(pl.weapontime)
	
	pl.w_freeze_idle_next = -1;  //assume this?
	pl.lasersightUnlockTime = TRUE;
}


void
TS_View_PlayAnimation_EndIdle(player pl, int iSequence, float fDuration){
	pSeat->m_eViewModel.frame = (float)iSequence;
	pl.weapontime = 0.0f;
	pl.weaponframe = iSequence;
	SAVE_STATE(pl.weapontime)
	
	// ?? Do we want to do this or not then
	pl.lasersightUnlockTime = FALSE;  //reset
	// unspecified fIdleEndOffset time?  default to 0 (exactly at animation end)
	pl.w_freeze_idle_next = fDuration + 0 + getViewModelAnimExtraDuration();
}


void
TS_View_PlayAnimation_EndIdle_custom(player pl, int iSequence, float fDuration, float fIdleEndOffset){
	pSeat->m_eViewModel.frame = (float)iSequence;
	pl.weapontime = 0.0f;
	pl.weaponframe = iSequence;
	SAVE_STATE(pl.weapontime)

	pl.lasersightUnlockTime = FALSE;  //reset
	pl.w_freeze_idle_next = fDuration + fIdleEndOffset + getViewModelAnimExtraDuration();
}

#endif



//TAGGG - TODO - support the 'local player slowdown feature'.
// And, can have a separate 'TS_Weapons_PlaySound' method to play sounds with calls to
// .sndshd script files instead, like how FreeHL does like this:
//     Sound_Play(pl, CHAN_WEAPON, "weapon_mp5.shoot");
// Same for precache methods alongisde that, I doubt this is the default
// precache-sound method being used for that:
//     Sound_Precache("weapon_mp5.shoot");

void TS_Weapons_PlaySoundDirect(player pl, string samp){
	
	// OLD WAY:
#ifdef SERVER
		sound(pl, CHAN_WEAPON, samp, 1, ATTN_NORM);
#endif
	
	
	// for now, only server too.  Don't really understand how unicast works.
	// Nope, not even that works consistently.  Serverside only, sometimes it just skips
	// playing completely.
	/*
#ifdef SERVER
	float flVol = 1.0f;
	float flSpeed = 100.0f;
	sound(pl, CHAN_WEAPON, samp, flVol, ATTN_NORM, flSpeed, SOUNDFLAG_PLAYER_SHARED, 0);
#endif
	*/
}


// customize channel, not usually needed
void TS_Weapons_PlaySoundChannelDirect(player pl, string samp, int chann){
	
	// OLD WAY:
#ifdef SERVER
		sound(pl, chann, samp, 1, ATTN_NORM);
#endif
	
	
	/*
#ifdef SERVER
	float flVol = 1.0f;
	float flSpeed = 100.0f;
	sound(pl, chann, samp, flVol, ATTN_NORM, flSpeed, SOUNDFLAG_PLAYER_SHARED, 0);
#endif
	*/
}
