
// Why do the powerup display names (usables) even have dashes in them in original TS?
// No idea.  Up to preference, I don't care either way.


void powerup_Usable_onTouch(int powerupDataID){
	//TODO - see if the player has no equipped powerup and, if that is so,
	// make it refer to my powerup type.
	// and do we really even need to cast to 'usable' instead of using 'basic'?
	powerupdata_usable_t powerupDataRef = *((powerupdata_usable_t*)ary_powerupData[powerupDataID]);
	
	//...
	
}//END OF powerup_Usable_onTouch



void powerup_SlowMotion_onTouch(void){
	powerup_Usable_onTouch(POWERUP_ID::SlowMotion);
}
void powerup_SlowMotion_onUse(player pl){
	
}
void powerup_SlowMotion_onEnd(player pl){
	
}

powerupdata_usable_t powerup_SlowMotion =
{
	POWERUPDATA_TYPEID_USABLE,
	"Slow-Motion",
	5,
	powerup_SlowMotion_onTouch,
	5,
	powerup_SlowMotion_onUse,
	powerup_SlowMotion_onEnd
};






void powerup_InfiniteClip_onTouch(void){
	powerup_Usable_onTouch(POWERUP_ID::InfiniteClip);
}
void powerup_InfiniteClip_onUse(player pl){
	
}
void powerup_InfiniteClip_onEnd(player pl){
	
}

powerupdata_usable_t powerup_InfiniteClip =
{
	POWERUPDATA_TYPEID_USABLE,
	"Infinite-Ammo",
	3,
	powerup_InfiniteClip_onTouch,
	3,
	powerup_InfiniteClip_onUse,
	powerup_InfiniteClip_onEnd
};








void powerup_DoubleClip_onTouch(void){
	powerup_Usable_onTouch(POWERUP_ID::DoubleClip);
}
void powerup_DoubleClip_onUse(player pl){
	
}
void powerup_DoubleClip_onEnd(player pl){
	
}
// Stats unknown! Just guessing the time it lasts too.
powerupdata_usable_t powerup_DoubleClip =
{
	POWERUPDATA_TYPEID_USABLE,
	"Double-Clip",
	11,
	powerup_DoubleClip_onTouch,
	5,
	powerup_DoubleClip_onUse,
	powerup_DoubleClip_onEnd
};


void powerup_KungFu_onTouch(void){
	
}
powerupdata_instant_t powerup_KungFu =
{
	POWERUPDATA_TYPEID_INSTANT,
	"Kung-Fu",
	1,
	powerup_KungFu_onTouch
};




void powerup_SlowPause_onTouch(void){
	powerup_Usable_onTouch(POWERUP_ID::SlowPause);
}
void powerup_SlowPause_onUse(player pl){
	
}
void powerup_SlowPause_onEnd(player pl){
	
}
powerupdata_usable_t powerup_SlowPause =
{
	POWERUPDATA_TYPEID_USABLE,
	"Slow-Pause",
	10,
	powerup_SlowPause_onTouch,
	3,
	powerup_SlowPause_onUse,
	powerup_SlowPause_onEnd
};




// Called "SlowPauseOld". This was the slowpause powerup from an earlier version of TS.
// We'll just call it "Pause" to differentiate it from the current Slow-Pause.
// This does work as a more literal 'pause' anyway, instead of being an enhanced version
// of "Slow-mo" that lasts 3 seconds instead of 5.
// This can still last just 3 seconds from having a pretty nice benefit though
// (stopping time for all nearby players except the one using this powerup).
// But all players, including the user, can't attack in any way either during this time.
// The point is to use this powerup to move away if caught off-guard, or turn the tables
// and catch the other off-guard by suddenly stopping time like this.
void powerup_SlowPauseOld_onTouch(void){
	powerup_Usable_onTouch(POWERUP_ID::SlowPauseOld);
}
void powerup_SlowPauseOld_onUse(player pl){
	
}
void powerup_SlowPauseOld_onEnd(player pl){
	
}
// Stats unknown! Just guessing the time it lasts too.
powerupdata_usable_t powerup_SlowPauseOld =
{
	POWERUPDATA_TYPEID_USABLE,
	"Pause",
	4,
	powerup_SlowPauseOld_onTouch,
	3,
	powerup_SlowPauseOld_onUse,
	powerup_SlowPauseOld_onEnd
};



// cut fire-delays in half for the duration.
// TAGGG - CRITICAL. CONSIDER: should we also speed-up reload speeds by half so that low-clip-sized or
// mono-clip-sized weapons (contender) are treated more fairly?
// If we can easily speed up viewmodel animations here in FTE too (programatically), sure.
void powerup_DoubleFirerate_onTouch(void){
	powerup_Usable_onTouch(POWERUP_ID::DoubleFirerate);
}
void powerup_DoubleFirerate_onUse(player pl){
	
}
void powerup_DoubleFirerate_onEnd(player pl){
	
}
powerupdata_usable_t powerup_DoubleFirerate =
{
	POWERUPDATA_TYPEID_USABLE,
	"Double-Firerate",
	2,
	powerup_DoubleFirerate_onTouch,
	5,
	powerup_DoubleFirerate_onUse,
	powerup_DoubleFirerate_onEnd
};






// Grants a m61 grenade.
// Does nothing if the player touching me can't afford to add its slot count or
// already has the max number of grenades (2).
void powerup_Grenade_onTouch(void){
	
}
powerupdata_instant_t powerup_Grenade =
{
	POWERUPDATA_TYPEID_INSTANT,
	"Grenade",
	6,
	powerup_Grenade_onTouch
};




void powerup_Health_onTouch(void){
	
}
powerupdata_instant_t powerup_Health =
{
	POWERUPDATA_TYPEID_INSTANT,
	"Health",
	7,
	powerup_Health_onTouch
};



void powerup_Armor_onTouch(void){
	
}
powerupdata_instant_t powerup_Armor =
{
	POWERUPDATA_TYPEID_INSTANT,
	"Armor",
	8,
	powerup_Armor_onTouch
};



void powerup_SuperJump_onTouch(void){
	
}
powerupdata_instant_t powerup_SuperJump =
{
	POWERUPDATA_TYPEID_INSTANT,
	"Super-Jump",
	9,
	powerup_SuperJump_onTouch
};



#ifdef SERVER
// Given a powerup entity
void powerup_linkToStruct(ts_powerup arg_entity, POWERUP_ID arg_id){
	
	
}
#endif


void setupPowerupData(void){
	
	ASSIGN_POWERUPDATA(SlowMotion)
	ASSIGN_POWERUPDATA(InfiniteClip)
	ASSIGN_POWERUPDATA(DoubleClip)
	ASSIGN_POWERUPDATA(KungFu)
	ASSIGN_POWERUPDATA(SlowPause)
	ASSIGN_POWERUPDATA(SlowPauseOld)
	ASSIGN_POWERUPDATA(DoubleFirerate)
	ASSIGN_POWERUPDATA(Grenade)
	ASSIGN_POWERUPDATA(Health)
	ASSIGN_POWERUPDATA(Armor)
	ASSIGN_POWERUPDATA(SuperJump)
	
}//END OF setupPowerupData



