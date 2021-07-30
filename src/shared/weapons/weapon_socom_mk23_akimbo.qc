

enum weaponseq_socom_mk23_akimbo{
	//...
	idle = 0,
	shoot_right1 = 1,
	shoot_right2 = 2,
	shoot_left1 = 3,
	shoot_left2 = 4,
	draw = 5,
	idleb = 6,
	shoot_rightb1 = 7,
	shoot_rightb2 = 8,
	shoot_leftb1 = 9,
	shoot_leftb2 = 10,
	change = 11,
	rechange = 12,
	reload = 13,
	shoot_linked = 14,
	shoot_linked_last = 15,
	reloadb = 16
	
};



BOOLEAN weapon_SOCOM_MK23_akimbo_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_SOCOM_MK23_akimbo_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_SOCOM_MK23_akimbo_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_SOCOM_MK23_akimbo_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
void weapon_SOCOM_MK23_akimbo_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}
BOOLEAN weapon_SOCOM_MK23_akimbo_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_SOCOM_MK23_akimbo_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::SOCOM_MK23_akimbo], arg_thisWeapon);
}
void weapon_SOCOM_MK23_akimbo_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_SOCOM_MK23_akimbo_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_SOCOM_MK23_akimbo_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
	
}


	
weapondata_ironsight_t weapon_SOCOM_MK23_akimbo =
{
	WEAPONDATA_TYPEID_IRONSIGHT,
	"Ak. SOCOM-MK23",  //want "Akimbo SOCOM-MK23" but it takes up a bit too much space
	"models/v_mk23_Akimbo.mdl",
	"models/p_mk23_Akimbo.mdl",
	"models/p_mk23_Akimbo_sil.mdl",
	"models/w_mk23.mdl",
	"sprites/weapons/mk23_Akimbo.spr",
	weapon_SOCOM_MK23_akimbo_onPrimaryAttack,
	weapon_SOCOM_MK23_akimbo_onPrimaryAttackRelease,
	weapon_SOCOM_MK23_akimbo_onSecondaryAttack,
	weapon_SOCOM_MK23_akimbo_onSecondaryAttackRelease,
	weapon_SOCOM_MK23_akimbo_onEquip,
	weapon_SOCOM_MK23_akimbo_onUnEquip,
	weapon_SOCOM_MK23_akimbo_onThink,
	weapon_SOCOM_MK23_akimbo_onDrawHUD,
	weapon_SOCOM_MK23_akimbo_onReload,
	weapon_SOCOM_MK23_akimbo_onColdCock,
	weaponseq_socom_mk23_akimbo::idle,
	weaponseq_socom_mk23_akimbo::draw,
	31.0f / 40.0f,
	0.19f,  //fire delay. this is most certainly wrong. find something more accurate later.
	15.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_FLASHLIGHT | BITS_WEAPONOPT_AKIMBO,
	BITS_WEAPONOPT_AKIMBO,
	1400,  //for use if bought straight-off Akimbo, not upgraded.
	20,
	BUYCATEGORY_HANDGUNS,
	5,
	{0.030000, 2.200000, 0.000000},
	// IDEA: for now, let akimbo weapons be able to redirect back to the singular version
	// in this space.  If negative, this is an akimbo weapon referring to the singular version.
	-WEAPON_ID::SOCOM_MK23,
	BITS_FIREMODE_AKIMBO_SEMI_AUTO | BITS_FIREMODE_AKIMBO_FREE_SEMI,
	BITS_FIREMODE_AKIMBO_SEMI_AUTO,
	AMMO_ID::_45Acp,
	12,  //clip
	4096, //range
	weaponseq_socom_mk23_akimbo::reload,
	76.0f / 30.0f,
	1,
	-1,
	2,
	-1,
	{
		weaponseq_socom_mk23_akimbo::change,
		21.0f/60.0f,
		weaponseq_socom_mk23_akimbo::rechange,
		21.0f/60.0f,
		weaponseq_socom_mk23_akimbo::idleb,
		weaponseq_socom_mk23_akimbo::reloadb,
		76.0f/30.0f,
		{0.030000, 2.200000, 0.000000}
	}
};





void
w_socom_mk23_akimbo_precache(void)
{
#ifdef SERVER
	//Sound_Precache("weapon_glock.fire");
	//precache_model("models/w_9mmhandgun.mdl");
	//precache_model("models/shell.mdl");
#else
	//precache_model("models/v_9mmhandgun.mdl");
	//precache_model("models/p_9mmhandgun.mdl");
	//precache_model("models/shell.mdl");
	//Sound_Precache("modelevent_shell.land");
#endif
}

// I guess?  I don't know if we really benefit from doing this.
void
w_socom_mk23_akimbo_updateammo(player pl)
{
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//Weapons_UpdateAmmo(pl, arg_thisWeapon.iClipLeft, pl.ary_ammoTotal[AMMO_ID::_9x19mm], -1);
}

string
w_socom_mk23_akimbo_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::SOCOM_MK23_akimbo]).sWorldModelPath;
}

string
w_socom_mk23_akimbo_pmodel(void)
{
	// Do we have the silencer?
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::SOCOM_MK23_akimbo]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::SOCOM_MK23_akimbo]).sPlayerSilencerModelPath;
	}
}

string
w_socom_mk23_akimbo_deathmsg(void)
{
	return "";
}

void
w_socom_mk23_akimbo_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::SOCOM_MK23_akimbo], arg_thisWeapon);
}

void
w_socom_mk23_akimbo_holster(void)
{
}



var int leftCount = 0;
var int rightCount = 0;

// General attack method to be called by primary or secondary fire as needed.
// The firemode used determines whether only pressing primary fire works (alternate b/w
// the Akimbo weapons with each shot), or primary & secondary control the left/right
// Akimbo weapons consistently.
// Putting it here avoids duplicating a bunch of code.
// Also, "attackTypeUsed" is whether primary (FALSE) or secondary (TRUE) lead to this point.
BOOLEAN weapon_SOCOM_MK23_akimbo_attack(player localPlayer, weapondynamic_t arg_thisWeapon, int attackTypeUsed){
	player pl = localPlayer;
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	//special case
	int finalAkimboChoice = BITS_AKIMBOCHOICE_NONE;  //default
	
	// NOTE! weapon_akimbo_semiAttackChoice already handles telling to skip firing if
	// pl.recentAttackHadAmmo == FALSE or finalAkimboChoice is 0 or -1, no need
	// to keep track of w_attack_next per variant.
	// Also,
	//TODO - CRITICAL!
	// Muzzle flashes and shell ejections for akimbo pending!
	
	// because I am not copy/pasting this monstrosity 5 times.
	finalAkimboChoice = weapon_akimbo_semiAttackChoice(localPlayer, ary_weaponData[WEAPON_ID::SOCOM_MK23_akimbo], arg_thisWeapon, attackTypeUsed);
	
#ifdef CLIENT
	SAVE_STATE(pl.nextAkimboAttackPreference);
#endif
	
	if(finalAkimboChoice == -1){
		//pl.akimboFirePrev = 0;
		return FALSE;
	}
	
	
	/*
	// DEBUG
	if(finalAkimboChoice > 0){
		finalAkimboChoice = BITS_AKIMBOCHOICE_BOTH;
	}
	*/
	if(pl.recentAttackHadAmmo == FALSE){
		if((finalAkimboChoice & BITS_AKIMBOCHOICE_LEFT)){
			PLAY_CLICK_SOUND_LEFT
		}
		if((finalAkimboChoice & BITS_AKIMBOCHOICE_RIGHT)){
			PLAY_CLICK_SOUND_RIGHT
		}
		return FALSE;
	}
	
	
	// ??  Is this even possible?
	if(finalAkimboChoice == 0){
		//pl.akimboFirePrev = 0;
		return FALSE;
	}
	
	
	// DEBUG!!!
	if((finalAkimboChoice & BITS_AKIMBOCHOICE_LEFT)){
		leftCount++;
	}
	if((finalAkimboChoice & BITS_AKIMBOCHOICE_RIGHT)){
		rightCount++;
	}
	printfline("COUNTS!  %i %i", leftCount, rightCount);
	
	// Use me for things the recent firing round already did to avoid redundancy.
	// That is, if left-click was pressed a fraction of a second ago and then right-click
	// to force leading here to play the dual-fire anim, no need to do the muzzle flash,
	// shell ejection and traceattack call for the left weapon.
	// Viewmodel anims (the whole point) and fire delays are OK to set based off the
	// sudden dual-fire request though.
	int effectiveAkimboChoice = finalAkimboChoice & ~pl.akimboTest;  //finalAkimboChoice;//BITS_AKIMBOCHOICE_NONE & ~pl.akimboTest
	
	weapon_base_onAttack(localPlayer, ary_weaponData[WEAPON_ID::SOCOM_MK23_akimbo], arg_thisWeapon, effectiveAkimboChoice);
	
	
	if(effectiveAkimboChoice & BITS_AKIMBOCHOICE_LEFT){
		if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
			TS_Weapons_PlaySoundDirect(pl, "weapons/mk23/mk23-fire.wav");
		} else {
			TS_Weapons_PlaySoundDirect(pl, "weapons/mk23/mk23-fire-sil.wav");
		}
	}
	if(effectiveAkimboChoice & BITS_AKIMBOCHOICE_RIGHT){
		if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
			TS_Weapons_PlaySoundDirect(pl, "weapons/mk23/mk23-fire.wav");
		} else {
			TS_Weapons_PlaySoundDirect(pl, "weapons/mk23/mk23-fire-sil.wav");
		}
	}
	
	
	if(pl.akimboTest == 0 && !(finalAkimboChoice == BITS_AKIMBOCHOICE_BOTH)){
		// Not both fire types chosen
		// Firing the opposite way within this time will let the dual animation play.
		pl.akimboDualFireToleranceTime = 0.06f; //3.0f;  //0.07f;
		
		if(finalAkimboChoice == BITS_AKIMBOCHOICE_LEFT){
			//printfline("VM: LEFT");
			if(!arg_thisWeapon.iIronSight){
				if ( random() <= 0.5 ) {
					TS_Weapons_ViewAnimation_EndIdle_custom( weaponseq_socom_mk23_akimbo::shoot_left1, (31.0f/40.0f), 2 );
				} else {
					TS_Weapons_ViewAnimation_EndIdle_custom( weaponseq_socom_mk23_akimbo::shoot_left2, (31.0f/40.0f), 2 );
				}
			}else{
				if ( random() <= 0.5 ) {
					TS_Weapons_ViewAnimation_EndIdle_custom( weaponseq_socom_mk23_akimbo::shoot_leftb1, (31.0f/40.0f), 2 );
				} else {
					TS_Weapons_ViewAnimation_EndIdle_custom( weaponseq_socom_mk23_akimbo::shoot_leftb2, (31.0f/40.0f), 2 );
				}
			}
			
			weapon_base_setLeftAttackDelay(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay);

			if(arg_thisWeapon.iFireModeAkimbo == BITS_FIREMODE_AKIMBO_SEMI_AUTO){
				// in semi fire, set the opposite delay a little too.
				weapon_base_setRightAttackDelay_AtLeast(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay * 0.5);
			}else if(arg_thisWeapon.iFireModeAkimbo == BITS_FIREMODE_AKIMBO_FREE_SEMI){
				weapon_base_setRightAttackDelay_AtLeast(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay * 0.3);
			}
		}else if(finalAkimboChoice == BITS_AKIMBOCHOICE_RIGHT){
			//printfline("VM: RIGHT");
			if(!arg_thisWeapon.iIronSight){
				if ( random() <= 0.5 ) {
					TS_Weapons_ViewAnimation_EndIdle_custom( weaponseq_socom_mk23_akimbo::shoot_right1, (31.0f/40.0f), 2 );
				} else {
					TS_Weapons_ViewAnimation_EndIdle_custom( weaponseq_socom_mk23_akimbo::shoot_right2, (31.0f/40.0f), 2 );
				}
			}else{
				if ( random() <= 0.5 ) {
					TS_Weapons_ViewAnimation_EndIdle_custom( weaponseq_socom_mk23_akimbo::shoot_rightb1, (31.0f/40.0f), 2 );
				} else {
					TS_Weapons_ViewAnimation_EndIdle_custom( weaponseq_socom_mk23_akimbo::shoot_rightb2, (31.0f/40.0f), 2 );
				}
			}
			
			weapon_base_setRightAttackDelay(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay);

			if(arg_thisWeapon.iFireModeAkimbo == BITS_FIREMODE_AKIMBO_SEMI_AUTO){
				weapon_base_setLeftAttackDelay_AtLeast(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay * 0.5);
			}else if(arg_thisWeapon.iFireModeAkimbo == BITS_FIREMODE_AKIMBO_FREE_SEMI){
				weapon_base_setLeftAttackDelay_AtLeast(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay * 0.3);
			}
		}
	}else{
		//printfline("VM: BOTH");
		
		// dual fire'd?  Don't use it for doing this again.
		pl.akimboDualFireToleranceTime = 0;
		
		// both fire types?
		if(!arg_thisWeapon.iIronSight){
			if(arg_thisWeapon.iClipLeft > 0){
				TS_Weapons_ViewAnimation_EndIdle_custom( weaponseq_socom_mk23_akimbo::shoot_linked, (31.0f/40.0f), 2);
			}else{
				//that is... insanely situational.
				TS_Weapons_ViewAnimation( weaponseq_socom_mk23_akimbo::shoot_linked_last, 31.0f/40.0f);
			}
		}else{
			// not ironsight eh?  WE DONT HAVE A LINKED ANIM FOR THAT.
			// but hey, original TS had this issue too at least, it just did no anim here.
			// Or force idle, whatever.
			TS_Weapons_ViewAnimation( weaponseq_socom_mk23_akimbo::idleb, 1.5f );
		}
		
		weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay * 1);
	}
	
	return TRUE;
}//END OF weapon_SOCOM_MK23_akimbo_attack


void
w_socom_mk23_akimbo_primary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	// reset
	pl.akimboTest = 0;
	
	// in addition to the primary input, which lead to '_primary' being called at all.
	if(input_buttons & INPUT_BUTTON3){
		if(!weapon_akimbo_semiAttackDualHack(pl, arg_thisWeapon, BITS_AKIMBOCHOICE_BOTH, &weapon_SOCOM_MK23_akimbo_attack)){
			// nothing unusual here.
			pl.akimboTest = 0;
			weapon_SOCOM_MK23_akimbo_attack(pl, arg_thisWeapon, BITS_AKIMBOCHOICE_BOTH);
		}else{
		}
	}else{
		if(!weapon_akimbo_semiAttackDualHack(pl, arg_thisWeapon, BITS_AKIMBOCHOICE_RIGHT, &weapon_SOCOM_MK23_akimbo_attack)){
			weapon_SOCOM_MK23_akimbo_attack(pl, arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
			pl.akimboFirePrev = BITS_AKIMBOCHOICE_LEFT;
		}
		
	}
	
}


void
w_socom_mk23_akimbo_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	// reset
	pl.akimboTest = 0;
	
	// NOTE - holding primary is impossible, would've called _primary above if so.
	// Only secondary could possibly be held (and, is).
	if(arg_thisWeapon.iFireModeAkimbo == BITS_FIREMODE_AKIMBO_SEMI_AUTO){
		// since secondary fire does nothing in semi-auto, we let it do ironsight stuff here
		weapon_ironsight_ToggleIronsight(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::SOCOM_MK23_akimbo], arg_thisWeapon);
		
	}else{
		// fires the right weapon always
		
		//weapon_SOCOM_MK23_akimbo_attack(pl, arg_thisWeapon, BITS_AKIMBOCHOICE_RIGHT);
		//return;
		
		if(!weapon_akimbo_semiAttackDualHack(pl, arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT, &weapon_SOCOM_MK23_akimbo_attack)){
			weapon_SOCOM_MK23_akimbo_attack(pl, arg_thisWeapon, BITS_AKIMBOCHOICE_RIGHT);
			pl.akimboFirePrev = BITS_AKIMBOCHOICE_RIGHT;
		}
	}
	
}


void
w_socom_mk23_akimbo_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_ironsight_Reload(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::SOCOM_MK23_akimbo], arg_thisWeapon);
	
	leftCount = 0;
	rightCount = 0;
}

// ???
float
w_socom_mk23_akimbo_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}


void
w_socom_mk23_akimbo_hud(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::SOCOM_MK23_akimbo], arg_thisWeapon);
}


// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
void
w_socom_mk23_akimbo_hudpic(int selected, vector pos, float a)
{
	//
}


weapon_t w_socom_mk23_akimbo =
{
	
	.name		= "socom_mk23",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_socom_mk23_akimbo_draw,
	.holster	= w_socom_mk23_akimbo_holster,
	.primary	= w_socom_mk23_akimbo_primary,
	.secondary	= w_socom_mk23_akimbo_secondary,
	.reload		= w_socom_mk23_akimbo_reload,
	.release	= NULL,
	.crosshair	= w_socom_mk23_akimbo_hud,
	.precache	= w_socom_mk23_akimbo_precache,
	.pickup		= NULL,
	.updateammo	= w_socom_mk23_akimbo_updateammo,
	.wmodel		= w_socom_mk23_akimbo_wmodel,
	.pmodel		= w_socom_mk23_akimbo_pmodel,
	.deathmsg	= w_socom_mk23_akimbo_deathmsg,
	.aimanim	= w_socom_mk23_akimbo_aimanim,
	.hudpic		= NULL
	
};

