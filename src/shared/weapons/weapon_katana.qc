
enum weaponseq_katana{
	idle,
	draw,
	slash1,
	slash2,
	slash3
};


BOOLEAN weapon_Katana_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_Katana_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_Katana_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_Katana_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
void weapon_Katana_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}
BOOLEAN weapon_Katana_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_Katana_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){

}
void weapon_Katana_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_Katana_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){

}
void weapon_Katana_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){

}

	
weapondata_melee_t weapon_Katana =
{
	WEAPONDATA_TYPEID_MELEE,
	"Katana",
	"models/v_katana.mdl",
	"models/p_katana.mdl",
	"",
	"models/w_katana.mdl",
	"sprites/weapons/katana.spr",
	weapon_Katana_onPrimaryAttack,
	weapon_Katana_onPrimaryAttackRelease,
	weapon_Katana_onSecondaryAttack,
	weapon_Katana_onSecondaryAttackRelease,
	weapon_Katana_onEquip,
	weapon_Katana_onUnEquip,
	weapon_Katana_onThink,
	weapon_Katana_onDrawHUD,
	weapon_Katana_onReload,
	weapon_Katana_onColdCock,
	weaponseq_katana::idle,
	weaponseq_katana::draw,
	31.0f / 33.0f,
	0.33,  //fire delay. this is most certainly wrong. find something more accurate later.
	80,  //dmg
	FALSE,
	BITS_WEAPONOPT_NONE,
	BITS_WEAPONOPT_NONE,
	2900,
	10,
	BUYCATEGORY_SPECIALPURPOSE,
	1,
	{0.100000, 1.000000, 0.000000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE
	
	
};






void
w_katana_precache(void)
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
w_katana_updateammo(player pl)
{
	
}

string
w_katana_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::Katana]).sWorldModelPath;
}

string
w_katana_pmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::Katana]).sPlayerModelPath;
}

string
w_katana_deathmsg(void)
{
	return "";
}


void
w_katana_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::Katana], arg_thisWeapon);
}

void
w_katana_holster(void)
{
}


void
w_katana_primary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	float randomChoice;
	MELEE_HIT_RESPONSE theReaper;
	int meleeAnimToPlay = 0;
	
	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	INPUT_PRIMARY_TAP_GATE
	
	//TAGGG - TODO.
	// Crouch-attack should lock to the crouch state for 1 second (due to player model animation that coincides with this time).
	// And lock movement for 1 second, or at least make it very tiny?  weird behavior.
	// Backwards attack is the same, but doesn't affect crouch (lock movement for 1 second)
	
	pl.fMoveBlockCapSpeed = 4;
	
	if(input_buttons & INPUT_BUTTON8){
		//okay, do the crouch attack!  Always use slash1 for it, resets cycler.
		// TODO - the duration of a crouch attack locks the player in crouch, let pmove.c know sometime!!
		pl.iMeleeCycler = 0;
		meleeAnimToPlay = 0;

		theReaper = weapon_base_onPrimaryAttack_melee(pl, ary_weaponData[WEAPON_ID::Katana], arg_thisWeapon, 80, 72);
		
		/*
		// ???  Why was this here, did original TS do this noise on crouch-attacks in particular?
		#ifdef CLIENT
		TS_Weapons_PlaySoundDirect(pl, "player/closecombat.wav");
		#endif
		*/

		weapon_base_setWholeAttackDelay(pl, 0.70);
		pl.fMoveBlockDelay = time + 1.0f;
		pl.fUncrouchBlockDelay = time + 1.0f;
	}else{
		//Check.  Are we moving backwards,  enough??  And not looking up/down too far?
		if(input_movevalues.x < -40 && pl.v_angle.x >= -55 && pl.v_angle.x <= 55){
			//okay!
			pl.iMeleeCycler = 0;
			meleeAnimToPlay = 2;
			
			makevectors( pl.v_angle );
			theReaper = weapon_base_onPrimaryAttack_melee_fromCustomDirection(pl, ary_weaponData[WEAPON_ID::Katana], arg_thisWeapon, 80, 74, -v_forward);
			
			weapon_base_setWholeAttackDelay(pl, 0.75);
			pl.fMoveBlockDelay = time + 1.0f;
			//pl.fUncrouchBlockDelay = time + 1.0f;
		}else{
			//nothin special
			meleeAnimToPlay = pl.iMeleeCycler;
			pl.iMeleeCycler++;
			if(pl.iMeleeCycler >= 2 || pl.iMeleeCycler < 0){
				pl.iMeleeCycler = 0;
			}
			theReaper = weapon_base_onPrimaryAttack_melee(pl, ary_weaponData[WEAPON_ID::Katana], arg_thisWeapon, 80, 66);
		}
	}
	
	
	// Don't check 'theReaper' client side, ray-checks to see what was hit are
	// ineffective there
	#ifdef SERVER
	if (theReaper == MELEE_HIT_RESPONSE::NONE ) {
		randomChoice = randomInRange_i(0, 1);
		if(randomChoice == 0){
			TS_Weapons_PlaySoundDirect(pl, "weapons/katana/miss.wav");
		}else{
			TS_Weapons_PlaySoundDirect(pl, "weapons/katana/miss1.wav");
		}
	}else if(theReaper == MELEE_HIT_RESPONSE::SOFT){
		//nothin
	}else if(theReaper == MELEE_HIT_RESPONSE::METAL){
		randomChoice = randomInRange_i(0, 1);
		if(randomChoice == 0){
			TS_Weapons_PlaySoundDirect(pl, "weapons/katana/hit.wav");
		}else{
			TS_Weapons_PlaySoundDirect(pl, "weapons/katana/hit1.wav");
		}
	}else if(theReaper == MELEE_HIT_RESPONSE::FLESH){
		arg_thisWeapon.forceBodygroup1Submodel = 2;

		TS_Weapons_PlaySoundDirect(pl, "weapons/katana/hit-body.wav");
	}
	#endif
	
	
	if(meleeAnimToPlay == 0){
		//do that one.
		TS_Weapons_ViewAnimation(weaponseq_katana::slash1, (51.0f/33.0f) );
	}else if(meleeAnimToPlay == 1){ // == 1?
		TS_Weapons_ViewAnimation(weaponseq_katana::slash2, (51.0f/33.0f) );
	}else if(meleeAnimToPlay == 2){
		TS_Weapons_ViewAnimation(weaponseq_katana::slash3, (51.0f/33.0f) );
	}
	
}

void
w_katana_secondary(void)
{
	// nope.
}

void
w_katana_reload(void)
{
	// how do you reload a sword
}

// ???
float
w_katana_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_katana_hud(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_melee_onDrawHUD(pl, (weapondata_melee_t*)ary_weaponData[WEAPON_ID::Katana], arg_thisWeapon);
	
}

// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
void
w_katana_hudpic(int selected, vector pos, float a)
{
	//
}


weapon_t w_katana =
{
	
	.name		= "katana",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_katana_draw,
	.holster	= w_katana_holster,
	.primary	= w_katana_primary,
	.secondary	= w_katana_secondary,
	.reload		= w_katana_reload,
	.release	= NULL,
	.crosshair	= w_katana_hud,
	.precache	= w_katana_precache,
	.pickup		= NULL,
	.updateammo	= w_katana_updateammo,
	.wmodel		= w_katana_wmodel,
	.pmodel		= w_katana_pmodel,
	.deathmsg	= w_katana_deathmsg,
	.aimanim	= w_katana_aimanim,
	.hudpic		= NULL
	
};


