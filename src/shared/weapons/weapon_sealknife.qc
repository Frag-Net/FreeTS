
enum weaponseq_sealknife{
	idle,
	draw,
	slash1,
	slash2,
	slash3
};

void weapon_sealknife_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_sealknife_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_sealknife_onThink(player pl, weapondynamic_t arg_thisWeapon){
}
void weapon_sealknife_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
}

weapondata_throwable_t weapon_sealknife =
{
	WEAPONDATA_TYPEID_THROWABLE,
	"Seal Knife",
	"models/v_sealknife.mdl",
	"models/p_sealknife.mdl",
	"",
	"models/w_sealknife.mdl",
	"sprites/weapons/sealknife.spr",
	weapon_sealknife_onPrimaryAttackRelease,
	weapon_sealknife_onSecondaryAttackRelease,
	weapon_sealknife_onThink,
	weapon_sealknife_onColdCock,
	NULL,
	weaponseq_sealknife::idle,
	weaponseq_sealknife::draw,
	31.0f / 30.0f,
	0.24,  //fire delay
	15.0f,  //dmg
	FALSE,
	BITS_WEAPONOPT_FULLLOAD,
	BITS_WEAPONOPT_NONE,
	100,
	1,
	BUYCATEGORY_SPECIALPURPOSE,
	1,
	{0.100000, 1.000000, 0.000000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	10,
	50,   //thrown damage
	1350,  //thrown speed
	0.22  //thrown gravity (higher = falls faster)
	
};



void
w_sealknife_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::SEALKNIFE]);
#ifdef SERVER
	precache_sound("weapons/knife/knife_miss.wav");
	precache_sound("weapons/knife/knife_hit.wav");
	precache_sound("weapons/knife/knife_hitbody.wav");
#else
	
#endif
}

void
w_sealknife_updateammo(player pl)
{
	
}

string
w_sealknife_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::SEALKNIFE]).sWorldModelPath;
}

string
w_sealknife_pmodel(player pl)
{
	return (*ary_weaponData[WEAPON_ID::SEALKNIFE]).sPlayerModelPath;
}

string
w_sealknife_deathmsg(void)
{
	return "";
}

void
w_sealknife_draw(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::SEALKNIFE], arg_thisWeapon);
}

void
w_sealknife_holster(player pl)
{
}


void
w_sealknife_primary(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	INPUT_PRIMARY_TAP_GATE
	
	weapondata_basic_t baseRef = *ary_weaponData[WEAPON_ID::SEALKNIFE];
	MELEE_HIT_RESPONSE hitRep =  weapon_base_onPrimaryAttack_melee(pl, ary_weaponData[WEAPON_ID::SEALKNIFE], arg_thisWeapon, baseRef.fAttackDamage, 55);
	
	weapon_base_setWholeAttackDelay(pl, (ary_weaponData[WEAPON_ID::SEALKNIFE])->fAttackDelay);
			
	// Only the server is doing traces so far to get results for this to be worth checking.
#ifdef SERVER
	//printfline("melee hit reponse: %d soft? %d", hitRep, (hitRep==MELEE_HIT_RESPONSE::SOFT));
	if (hitRep == MELEE_HIT_RESPONSE::NONE ) {
		TS_Weapons_PlaySoundDirect(pl, "weapons/knife/knife_miss.wav");
	}else if(hitRep == MELEE_HIT_RESPONSE::SOFT){
		//nothin
	}else if(hitRep == MELEE_HIT_RESPONSE::METAL){
		TS_Weapons_PlaySoundDirect(pl, "weapons/knife/knife_hit.wav");
	}else if(hitRep == MELEE_HIT_RESPONSE::FLESH){
		arg_thisWeapon.iForceBodygroup1Submodel = 2;
		TS_Weapons_PlaySoundDirect(pl, "weapons/knife/knife_hitbody.wav");
	}
#endif


	// actually do this animation the same regardless as far as we know.
	int r = (float)input_sequence % 3;
	if(r == 0){
		TS_Weapons_ViewAnimation(pl, weaponseq_sealknife::slash1, (31.0f/30.0f) );
	}else if(r == 1){
		TS_Weapons_ViewAnimation(pl, weaponseq_sealknife::slash2, (31.0f/30.0f) );
	}else{
		TS_Weapons_ViewAnimation(pl, weaponseq_sealknife::slash3, (31.0f/30.0f) );
	}
	
}


void
w_sealknife_secondary(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	INPUT_SECONDARY_TAP_GATE
	
	weapondata_basic_t baseRef = *ary_weaponData[WEAPON_ID::SEALKNIFE];
	weapon_base_setWholeAttackDelay(pl, baseRef.fAttackDelay);
	
	if(arg_thisWeapon.iCount > 0){
		//throw it!  play this sound too.
		arg_thisWeapon.iCount -= 1;
		pl.updateSlotCountsForEquippedWeapon();
		arg_thisWeapon.iForceBodygroup1Submodel = 1;  //reset, new knife is not bloody.
		TS_Weapons_PlaySoundDirect(pl, "weapons/knife/knife_miss.wav");
#ifdef SERVER
		CTSThrownProjectile::generate2(pl, arg_thisWeapon);
#endif
	}
	
	if(arg_thisWeapon.iCount > 0){
		// another knife left?  Bring it up with a draw animation.
		TS_Weapons_ViewAnimation(pl, weaponseq_sealknife::draw, (31.0f / 30.0f) );
	}else{
#ifdef SERVER
		// No knives left?  Unequip, pick something else.
		removeWeaponFromInventory(pl, pl.inventoryEquippedIndex);
		playerEquipIdealSafe(pl);
#endif
		
		return FALSE;
	}
	
}


void
w_sealknife_reload(player pl)
{
	// how do you reload a sword
}

float
w_sealknife_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_sealknife_hud(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_throwable_onDrawHUD(pl, (weapondata_throwable_t*)ary_weaponData[WEAPON_ID::SEALKNIFE], arg_thisWeapon);
}

void
w_sealknife_hudpic(player pl, int selected, vector pos, float a)
{
	//
}


weapon_t w_sealknife =
{
	
	.name		= "sealknife",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_sealknife_draw,
	.holster	= w_sealknife_holster,
	.primary	= w_sealknife_primary,
	.secondary	= w_sealknife_secondary,
	.reload		= w_sealknife_reload,
	.release	= NULL,
	.postdraw	= w_sealknife_hud,
	.precache	= w_sealknife_precache,
	.pickup		= NULL,
	.updateammo	= w_sealknife_updateammo,
	.wmodel		= w_sealknife_wmodel,
	.pmodel		= w_sealknife_pmodel,
	.deathmsg	= w_sealknife_deathmsg,
	.aimanim	= w_sealknife_aimanim,
	.hudpic		= NULL
	
};

