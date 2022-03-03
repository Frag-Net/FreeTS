
enum weaponseq_katana{
	idle,
	draw,
	slash1,
	slash2,
	slash3
};

void weapon_katana_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_katana_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_katana_onThink(player pl, weapondynamic_t arg_thisWeapon){

}
void weapon_katana_onColdCock(player pl, weapondynamic_t arg_thisWeapon){

}

weapondata_melee_t weapon_katana =
{
	WEAPONDATA_TYPEID_MELEE,
	"Katana",
	"models/v_katana.mdl",
	"models/p_katana.mdl",
	"",
	"models/w_katana.mdl",
	"sprites/weapons/katana.spr",
	weapon_katana_onPrimaryAttackRelease,
	weapon_katana_onSecondaryAttackRelease,
	weapon_katana_onThink,
	weapon_katana_onColdCock,
	NULL,
	weaponseq_katana::idle,
	weaponseq_katana::draw,
	31.0f / 33.0f,
	0.33,  //fire delay
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
	weapon_precache(ary_weaponData[WEAPON_ID::KATANA]);
#ifdef SERVER
	precache_sound("weapons/katana/hit-body.wav");
	precache_sound("weapons/katana/hit.wav");
	precache_sound("weapons/katana/hit1.wav");
	precache_sound("weapons/katana/miss.wav");
	precache_sound("weapons/katana/miss1.wav");
#else
	
#endif
}

void
w_katana_updateammo(player pl)
{
	
}

string
w_katana_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::KATANA]).sWorldModelPath;
}

string
w_katana_pmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::KATANA]).sPlayerModelPath;
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
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::KATANA], arg_thisWeapon);
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
	MELEE_HIT_RESPONSE hitRep;
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
	
	// probably better than an input (input_buttons & INPUT_BUTTON8) check
	if(pl.flags & FL_CROUCHING){
		//okay, do the crouch attack!  Always use slash1 for it, resets cycler.
		// TODO - the duration of a crouch attack locks the player in crouch, let pmove.c know sometime!!
		pl.iMeleeCycler = 0;
		meleeAnimToPlay = 0;

		hitRep = weapon_base_onPrimaryAttack_melee(pl, ary_weaponData[WEAPON_ID::KATANA], arg_thisWeapon, 80, 72);
		
		weapon_base_setWholeAttackDelay(pl, 0.70);
		pl.fMoveBlockDelay = 1.0f;
		pl.fUncrouchBlockDelay = 1.0f;
		
		
	}else{
		// Check.  Are we moving backwards,  enough??  And not looking up/down too far?
		if(input_movevalues.x < -40 && GET_VIEW_ANGLES.x >= -55 && GET_VIEW_ANGLES.x <= 55){
			//okay!
			pl.iMeleeCycler = 0;
			meleeAnimToPlay = 2;
			
			makevectors( GET_VIEW_ANGLES );
			hitRep = weapon_base_onPrimaryAttack_melee_fromCustomDirection(pl, ary_weaponData[WEAPON_ID::KATANA], arg_thisWeapon, 80, 74, -v_forward);
			
			weapon_base_setWholeAttackDelay(pl, 0.75);
			pl.fMoveBlockDelay = 1.0f;
			//pl.fUncrouchBlockDelay = 1.0f;
		}else{
			// nothin special
			meleeAnimToPlay = pl.iMeleeCycler;
			pl.iMeleeCycler++;
			if(pl.iMeleeCycler >= 2 || pl.iMeleeCycler < 0){
				pl.iMeleeCycler = 0;
			}
			hitRep = weapon_base_onPrimaryAttack_melee(pl, ary_weaponData[WEAPON_ID::KATANA], arg_thisWeapon, 80, 66);
			
			weapon_base_setWholeAttackDelay(pl, (ary_weaponData[WEAPON_ID::KATANA])->fAttackDelay);
		}
	}
	
	
	// Don't check 'hitRep' client side, ray-checks to see what was hit are
	// ineffective there
#ifdef SERVER
	int r;
	
	if (hitRep == MELEE_HIT_RESPONSE::NONE ) {
		r = (float)input_sequence % 2;
		if(r == 0){
			SoundPitched_Send(pl, SNDP_KATANA_MISS);
		}else{
			SoundPitched_Send(pl, SNDP_KATANA_MISS1);
		}
	}else if(hitRep == MELEE_HIT_RESPONSE::SOFT){
		//nothin
	}else if(hitRep == MELEE_HIT_RESPONSE::METAL){
		r = (float)input_sequence % 2;
		if(r == 0){
			TS_Weapons_PlaySoundDirect(pl, "weapons/katana/hit.wav");
		}else{
			TS_Weapons_PlaySoundDirect(pl, "weapons/katana/hit1.wav");
		}
	}else if(hitRep == MELEE_HIT_RESPONSE::FLESH){
		arg_thisWeapon.iForceBodygroup1Submodel = 2;
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
	
	weapon_melee_onDrawHUD(pl, (weapondata_melee_t*)ary_weaponData[WEAPON_ID::KATANA], arg_thisWeapon);
	
}

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


