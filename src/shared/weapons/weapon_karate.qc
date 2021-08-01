
//TAGGG - TODO - some kicks should disarm the player hit, I forget if it's all kicks
// or just crouch-kicks.

// ALSO, weapons that lack world-models will never drop, safe assumption.
// That is why karate never drops.


enum weaponseq_karate{
	//nothing = 0
	idle,
	draw,
	punch_left,
	punch_right,
	block_low,
	kick,
	sidekick,
	uppercut,
	spinkick,
	backkick,
	punch_right2
	
};


BOOLEAN weapon_Karate_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_Karate_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_Karate_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_Karate_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
void weapon_Karate_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}
BOOLEAN weapon_Karate_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_Karate_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	
}
void weapon_Karate_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}

void weapon_Karate_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_Karate_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
}

	
weapondata_basic_t weapon_Karate =
{
	WEAPONDATA_TYPEID_BASIC,
	"Karate",
	"models/v_melee.mdl",
	"",
	"",
	"",
	"sprites/weapons/kungfu.spr",
	weapon_Karate_onPrimaryAttack,
	weapon_Karate_onPrimaryAttackRelease,
	weapon_Karate_onSecondaryAttack,
	weapon_Karate_onSecondaryAttackRelease,
	weapon_Karate_onEquip,
	weapon_Karate_onUnEquip,
	weapon_Karate_onThink,
	weapon_Karate_onDrawHUD,
	weapon_Karate_onReload,
	weapon_Karate_onColdCock,
	weaponseq_karate::idle,
	weaponseq_karate::draw,
	31 / 35,   // 31/35 ?
	0.17f,  //fire delay. this is most certainly wrong. find something more accurate later.
	20.0f,
	FALSE,
	BITS_WEAPONOPT_NONE,
	BITS_WEAPONOPT_NONE,
	0,
	0,
	BUYCATEGORY_NONE,
	1,
	{0.022000, 1.500000, 0.007000},   //will karate even use these?
};




void
w_karate_precache(void)
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

void
w_karate_updateammo(player pl)
{
	
}

string
w_karate_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::Karate]).sWorldModelPath;
}

string
w_karate_pmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::Karate]).sPlayerModelPath;
}

string
w_karate_deathmsg(void)
{
	return "";
}

void
w_karate_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapondata_basic_t* basicP = ary_weaponData[WEAPON_ID::Karate];
	weapon_base_onEquip(pl, basicP, arg_thisWeapon);
}

void
w_karate_holster(void)
{
}


void
w_karate_primary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	float randomChoice;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	// no continuous fire for karate
	INPUT_PRIMARY_TAP_GATE
	
	// TODO - base karate melee damage?  I forget.
	MELEE_HIT_RESPONSE theReaper = weapon_base_onPrimaryAttack_melee(pl, ary_weaponData[WEAPON_ID::Karate], arg_thisWeapon, 30 * pl.fKarateStamina, 55);
	
	//pointsound(vPos, "player/closecombat.wav", impactSoundVolume, ATTN_NORM+0.1);

	
	weapon_base_setWholeAttackDelay(pl, 0.175f);
	pl.fMoveBlockDelay = time + 0.09f;
	//pl.fUncrouchBlockDelay = time + 1.0f;
	
	
	#ifdef SERVER
	// need the fleshhit sound
	if (theReaper == MELEE_HIT_RESPONSE::NONE ) {
		TS_Weapons_PlaySoundDirect(pl, "player/closecombat.wav");
	}else if(theReaper == MELEE_HIT_RESPONSE::SOFT){
		TS_Weapons_PlaySoundDirect(pl, "player/closecombat.wav");
	}else if(theReaper == MELEE_HIT_RESPONSE::METAL){
		TS_Weapons_PlaySoundDirect(pl, "player/closecombat.wav");
	}else if(theReaper == MELEE_HIT_RESPONSE::FLESH){
		TS_Weapons_PlaySoundDirect(pl, "player/kungfuhit.wav");
	}
	#endif
	
	//Animation_ShootWeapon( self );
	pl.fKarateStamina = bound(0, pl.fKarateStamina - 0.085, 1);
	
	randomChoice = randomInRange_i(0, 3);
	if(randomChoice == 0){
		TS_Weapons_ViewAnimation(weaponseq_karate::punch_left, (31.0f/40.0f) );
	}else if(randomChoice == 1){
		TS_Weapons_ViewAnimation(weaponseq_karate::punch_right, (31.0f/30.0f) );
	}else if(randomChoice == 2){
		TS_Weapons_ViewAnimation(weaponseq_karate::uppercut, (31.0f/30.0f) );
	}else if(randomChoice == 3){
		TS_Weapons_ViewAnimation(weaponseq_karate::punch_right2, (31.0f/30.0f) );
	}
	
	
	// TODO - player model anims for melee?
	/*
	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	*/
}



// moved to a method so that early termination does not stop too much.
void w_karate_determineSecondaryAttack(MELEE_HIT_RESPONSE* theReaper, int* meleeAnimToPlay){
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	float curSpeed;
	
	curSpeed = vlen(pl.velocity);
	
	if(input_buttons & INPUT_BUTTON8){
		//crouching?
		//spin kick
		(*meleeAnimToPlay) = 1;
		(*theReaper) = weapon_base_onPrimaryAttack_melee(pl, ary_weaponData[WEAPON_ID::Karate], arg_thisWeapon, 40 * pl.fKarateStamina, 72);
		weapon_base_setWholeAttackDelay(pl, 1);
		pl.fMoveBlockDelay = time + 1;
		pl.fKarateStamina = bound(0, pl.fKarateStamina - 0.25, 1);
		
		// curSpeed > 160
		// if not in sneak (BUTTON7) and moving at 90% of my top speed, count as a moving kick
		return;
	}
	
	float myMaxSpeed = pl.Physics_MaxSpeed();
	
	if( !(input_buttons&INPUT_BUTTON7) && curSpeed > myMaxSpeed * 0.92 ) {
		
		makevectors(pl.v_angle);
		vector _2d_dir = normalize([v_forward.x, v_forward.y, 0]);
		vector velocity_dir = normalize(pl.velocity);
		
		if(dotproduct(_2d_dir, velocity_dir) <= -0.7 && pl.v_angle.x >= -55 && pl.v_angle.x <= 55){
			// moving back-kick
			(*meleeAnimToPlay) = 2;
			(*theReaper) = weapon_base_onPrimaryAttack_melee_fromCustomDirection(pl, ary_weaponData[WEAPON_ID::Katana], arg_thisWeapon, 30 * pl.fKarateStamina, 76, -v_forward);
			weapon_base_setWholeAttackDelay(pl, 1);
			pl.fMoveBlockDelay = time + 1;
			//TAGGG - NOTE. Why is this stamina-loss in original TS so high?
			// Changing.  Original was 67%, but really now?  40% is plenty.
			// Original TS behavior seesm to scale the stamina lost with the player speed,
			// but why only ever with back-kicks?  Seems like an oversight.
			pl.fKarateStamina = bound(0, pl.fKarateStamina - 0.40, 1);
		}else{
			//moving-kick
			(*meleeAnimToPlay) = 0;
			(*theReaper) = weapon_base_onPrimaryAttack_melee_fromCustomDirection(pl, ary_weaponData[WEAPON_ID::Katana], arg_thisWeapon, 30 * pl.fKarateStamina, 74, v_forward);
			weapon_base_setWholeAttackDelay(pl, 0.53);
			pl.fMoveBlockDelay = time + 0.46;
			pl.fKarateStamina = bound(0, pl.fKarateStamina - 0.16, 1);
		}
		
		return;
	}
	
	if(input_movevalues.x < -40 && pl.v_angle.x >= -55 && pl.v_angle.x <= 55){
		//standing back-kick.
		makevectors(pl.v_angle);
		(*meleeAnimToPlay) = 2;
		(*theReaper) = weapon_base_onPrimaryAttack_melee_fromCustomDirection(pl, ary_weaponData[WEAPON_ID::Katana], arg_thisWeapon, 30 * pl.fKarateStamina, 74, -v_forward);
		weapon_base_setWholeAttackDelay(pl, 1);
		pl.fMoveBlockDelay = time + 1;
		pl.fKarateStamina = bound(0, pl.fKarateStamina - 0.3, 1);
		return;
	}
	
	
	// DEFAULT: nothing special then.
	(*meleeAnimToPlay) = 0;
	(*theReaper) = weapon_base_onPrimaryAttack_melee(pl, ary_weaponData[WEAPON_ID::Karate], arg_thisWeapon, 30 * pl.fKarateStamina, 66);
	weapon_base_setWholeAttackDelay(pl, 0.53);
	pl.fMoveBlockDelay = time + 0.46;
	
	// Original behavior was this has the same stamina drain as a punch, but does that really make sense?
	// A kick has a longer cooldown so it's impossible to run out of stamina just from doing standing kicks.
	//pl.fKarateStamina = bound(0, pl.fKarateStamina - 0.085, 1);
	pl.fKarateStamina = bound(0, pl.fKarateStamina - 0.17, 1);
	
}//w_karate_determineSecondaryAttack


void
w_karate_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	float randomChoice;
	MELEE_HIT_RESPONSE theReaper;
	int meleeAnimToPlay = 0;
	
	if(pl.w_attack_next > 0){
		return;
	}
	
	INPUT_SECONDARY_TAP_GATE
	
	pl.fMoveBlockCapSpeed = 35;
	
	
	// TODO - base karate melee damage?  I forget.
	
	//pointsound(vPos, "player/closecombat.wav", impactSoundVolume, ATTN_NORM+0.1);
	
	w_karate_determineSecondaryAttack(&theReaper, &meleeAnimToPlay);
	
	
	//pl.fUncrouchBlockDelay = time + 1.0f;
	//Animation_ShootWeapon( self );
	
	#ifdef SERVER
	// need the fleshhit sound
	if (theReaper == MELEE_HIT_RESPONSE::NONE ) {
		TS_Weapons_PlaySoundDirect(pl, "player/closecombat.wav");
	}else if(theReaper == MELEE_HIT_RESPONSE::SOFT){
		TS_Weapons_PlaySoundDirect(pl, "player/closecombat.wav");
	}else if(theReaper == MELEE_HIT_RESPONSE::METAL){
		TS_Weapons_PlaySoundDirect(pl, "player/closecombat.wav");
	}else if(theReaper == MELEE_HIT_RESPONSE::FLESH){
		TS_Weapons_PlaySoundDirect(pl, "player/kungfuhit.wav");
	}
	#endif
	
	
	if(meleeAnimToPlay == 0){
		//ordinary
		randomChoice = randomInRange_i(0,1);
		if(randomChoice == 0){
			TS_Weapons_ViewAnimation(weaponseq_karate::kick, (31.0f/30.0f) );
		}else if(randomChoice == 1){
			TS_Weapons_ViewAnimation(weaponseq_karate::sidekick, (31.0f/30.0f) );
		}
	}else if(meleeAnimToPlay == 1){
		//spin kick
		TS_Weapons_ViewAnimation(weaponseq_karate::spinkick, (31.0f/30.0f) );
	}else if(meleeAnimToPlay == 2){
		//back kick
		TS_Weapons_ViewAnimation(weaponseq_karate::backkick, (31.0f/30.0f) );
	}
	
	// TODO - player model anims for melee?
	/*
	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	*/
	
}



void
w_karate_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	// make a "HUAH" sound with a little cooldown?
	
	//Every time you push the reload key, it resets the cooldown time regardless
	//of whether it actually blocks this turn or not.
	//How to handle blocking is yet unknown... TODO by the way.
	
	if(time >= pl.flKarateBlockCooldown){
		// allow it.  Whatever 'it' is
		TS_Weapons_PlaySoundDirect(pl, "player/block.wav");
		TS_Weapons_ViewAnimation(weaponseq_karate::block_low, (31.0f/30.0f) );
	}
	
	pl.flKarateBlockCooldown = time + 1.3f;
}


// ???
float
w_karate_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}



void
w_karate_hud(void)
{
#ifdef CSQC
	vector clrDraw;
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
		
	weapondata_basic_t baseRef = *ary_weaponData[WEAPON_ID::Karate];
	
	vector vEquippedWeaponInfoDraw = [video_res[0] - 128 - 8, video_res[1] - 19 - 8];
	
	//int iBitsCurrentWeaponOpts = BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_FLASHLIGHT | BITS_WEAPONOPT_SCOPE;
	int iBitsCurrentWeaponOpts = arg_thisWeapon.iBitsUpgrade;
	
	clrDraw = clrPaleBlue;
	
	//draw the stamina bar
	drawfill( vEquippedWeaponInfoDraw, [128, 19], clrPaleBlue, 0.86f - 0.60f );
	// oh no.  not minus 0, it is my weakness.	.......... ???????????????????
	//drawfill( vEquippedWeaponInfoDraw + [0,0], [(128-0) * pl.fKarateStamina, 19-2], clrPaleBlue, 0.86f - 0.55f );
	drawfill( vEquippedWeaponInfoDraw + [0,0], [(128) * pl.fKarateStamina, 19-2], clrPaleBlue, 0.86f - 0.45f );
	vEquippedWeaponInfoDraw.y -= 20;
	
	//title
	drawfill( vEquippedWeaponInfoDraw, [128, 19], clrPaleBlue, 0.86f - 0.60f );
	Gfx_Text( [vEquippedWeaponInfoDraw.x + 2, vEquippedWeaponInfoDraw.y + 4], baseRef.sDisplayName, vButtonFontSize, clrPaleBlue, 0.98f, DRAWFLAG_ADDITIVE, FONT_ARIAL_STD );
	vEquippedWeaponInfoDraw.y -= 20;
#endif
}

// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
void
w_karate_hudpic(int selected, vector pos, float a)
{
	//
}


weapon_t w_karate =
{
	
	.name		= "karate",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_karate_draw,
	.holster	= w_karate_holster,
	.primary	= w_karate_primary,
	.secondary	= w_karate_secondary,
	.reload		= w_karate_reload,
	.release	= NULL,
	.crosshair	= w_karate_hud,
	.precache	= w_karate_precache,
	.pickup		= NULL,
	.updateammo	= w_karate_updateammo,
	.wmodel		= w_karate_wmodel,
	.pmodel		= w_karate_pmodel,
	.deathmsg	= w_karate_deathmsg,
	.aimanim	= w_karate_aimanim,
	.hudpic		= NULL
	
};
