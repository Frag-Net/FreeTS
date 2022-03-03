
enum weaponseq_sawedoff{
	idle,
	draw,
	reload,
	shoot1,
	shoot2,
	idleb,
	reloadb,
	shoot1b,
	shoot2b,
	reload_sigle,
	reloadb_sigle,
	change,
	rechange,
	coldcock
};

void weapon_sawedoff_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_sawedoff_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_sawedoff_onThink(player pl, weapondynamic_t arg_thisWeapon){
	// not weapon_shotgun_onThink_reloadLogic!  Pushes the clip to max in one go like
	// any other weapon
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::SAWEDOFF], arg_thisWeapon);
}
void weapon_sawedoff_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
	if(pl.w_attack_next > 0){
		return;
	}
	
	MELEE_HIT_RESPONSE hitRep = weapon_base_coldcock(pl, ary_weaponData[WEAPON_ID::SAWEDOFF], arg_thisWeapon, 40, 66);
	weapon_base_setWholeAttackDelay(pl, 0.73f);
	TS_Weapons_ViewAnimation_noLaserLock(weaponseq_sawedoff::coldcock, (30.0f/30.0f) );
	
	arg_thisWeapon.iIronSight = 0;  // disable, coldcock returns to non-ironsight look
	
	if (hitRep == MELEE_HIT_RESPONSE::NONE ) {
		TS_Weapons_PlaySoundDirect(pl, "player/closecombat.wav");
	}else if(hitRep == MELEE_HIT_RESPONSE::SOFT){
		TS_Weapons_PlaySoundDirect(pl, "player/closecombat.wav");
	}else if(hitRep == MELEE_HIT_RESPONSE::METAL){
		TS_Weapons_PlaySoundDirect(pl, "player/closecombat.wav");
	}else if(hitRep == MELEE_HIT_RESPONSE::FLESH){
		TS_Weapons_PlaySoundDirect(pl, "weapons/knife/knife_hitbody.wav");
	}
}

weapondata_ironsight_t weapon_sawedoff =
{
	WEAPONDATA_TYPEID_IRONSIGHT,
	"Sawed-off",
	"models/v_sawedoff.mdl",
	"models/p_sawedoff.mdl",
	"",
	"models/w_sawedoff.mdl",
	"sprites/weapons/sawedoff.spr",
	weapon_sawedoff_onPrimaryAttackRelease,
	weapon_sawedoff_onSecondaryAttackRelease,
	weapon_sawedoff_onThink,
	weapon_sawedoff_onColdCock,
	NULL,
	weaponseq_sawedoff::idle,
	weaponseq_sawedoff::draw,
	31.0f / 33.0f,
	0.0625f,  //fire delay.
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_LASERSIGHT,
	BITS_WEAPONOPT_NONE,
	1900,
	20,
	BUYCATEGORY_SHOTGUNS,
	4,
	{0.070000, 7.000000, 0.000000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_SEMI,
	BITS_FIREMODE_SEMI,
	AMMO_ID::_SHELLS,
	2,  //clip
	4096, //range
	weaponseq_sawedoff::reload_sigle,
	61/30,  //delay.
	-1,
	-1,
	-1,
	-1,
	{
		weaponseq_sawedoff::change,
		21.0f/40.0f,
		weaponseq_sawedoff::rechange,
		21.0f/40.0f,
		weaponseq_sawedoff::idleb,
		weaponseq_sawedoff::reloadb_sigle,
		61/30,  //delay.
		{0.070000, 7.000000, 0.000000}
	}
};



void
w_sawedoff_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::SAWEDOFF]);
#ifdef SERVER
	//precache_sound("weapons/sawedoff/close.wav");
	precache_sound("weapons/sawedoff/fire.wav");
	
	// the ak47 fire sound is copied in the as-is files. Why?
	//precache_sound("weapons/sawedoff/fire1.wav");
	
	//precache_sound("weapons/sawedoff/insert-shell.wav");
	//precache_sound("weapons/sawedoff/open.wav");
	//precache_sound("weapons/sawedoff/shelldrop.wav");
	//precache_sound("weapons/sawedoff/shellout.wav");
	//precache_sound("weapons/sawedoff/tapspan.wav");
#else
	
#endif
}

void
w_sawedoff_updateammo(player pl)
{
}

string
w_sawedoff_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::SAWEDOFF]).sWorldModelPath;
}

string
w_sawedoff_pmodel(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	return (*ary_weaponData[WEAPON_ID::SAWEDOFF]).sPlayerModelPath;
}

string
w_sawedoff_deathmsg(void)
{
	return "";
}


void
w_sawedoff_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::SAWEDOFF], arg_thisWeapon);
}

void
w_sawedoff_holster(void)
{
}


void
w_sawedoff_primary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	if (pl.w_attack_next > 0.0) {
		return;
	}

	if(arg_thisWeapon.iFireMode == BITS_FIREMODE_SEMI){
		INPUT_PRIMARY_TAP_GATE
	}
	
	if (!arg_thisWeapon.iClipLeft || WEAPON_UNDERWATER_CHECK) {
		PLAY_CLICK_SOUND
		return;
	}
	
	SoundPitched_Send(pl, SNDP_SAWEDOFF_FIRE);
	
	int r;
	if(!arg_thisWeapon.iIronSight){
		r = (float)input_sequence % 2;
		if(r == 0){
			TS_Weapons_ViewAnimation(weaponseq_sawedoff::shoot1, 31.0f/33.0f);
		}else{
			TS_Weapons_ViewAnimation(weaponseq_sawedoff::shoot2, 31.0f/33.0f);
		}
	}else{
		r = (float)input_sequence % 2;
		if(r == 0){
			TS_Weapons_ViewAnimation(weaponseq_sawedoff::shoot1b, 31.0f/33.0f);
		}else{
			TS_Weapons_ViewAnimation(weaponseq_sawedoff::shoot2b, 31.0f/33.0f);
		}
	}
	
	// no shell eject
	weapon_ShowMuzzleFlash(MUZZLEFLASH_ID::SMALL);
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::SAWEDOFF], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}


void
w_sawedoff_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_ironsight_ToggleIronsight(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::SAWEDOFF], arg_thisWeapon);
}

// need custom reload logic, works more like a typical weapon
void
w_sawedoff_reload(void)
{
	int reloadSeq;
	float reloadDur;
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	//weapon_ironsight_Reload(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::SAWEDOFF], arg_thisWeapon);
	
	// CHECK - we have two reload anims for ordinary and ironsight mode each.
	// One for if we have 1 clip left, another for if we have 0 clip left.
	if(arg_thisWeapon.iClipLeft == 0){
		// do the both-empty reload anim.
		if(!arg_thisWeapon.iIronSight){
			reloadSeq = weaponseq_sawedoff::reload;
		}else{
			reloadSeq = weaponseq_sawedoff::reloadb;
		}
	}else{
		// wasn't 0? must be 1.  Otherwise we wouldn't have reached this point.
		if(!arg_thisWeapon.iIronSight){
			reloadSeq = weaponseq_sawedoff::reload_sigle;
		}else{
			reloadSeq = weaponseq_sawedoff::reloadb_sigle;
		}
	}
	
	reloadDur = 61.0f/30.0f;
	
	weapon_gun_Reload_CustomSequence(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::SAWEDOFF], arg_thisWeapon, reloadSeq, reloadDur);
}

float
w_sawedoff_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_sawedoff_hud(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::SAWEDOFF], arg_thisWeapon);

}

void
w_sawedoff_hudpic(int selected, vector pos, float a)
{
	//
}


weapon_t w_sawedoff =
{
	
	.name		= "sawedoff",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_sawedoff_draw,
	.holster	= w_sawedoff_holster,
	.primary	= w_sawedoff_primary,
	.secondary	= w_sawedoff_secondary,
	.reload		= w_sawedoff_reload,
	.release	= NULL,
	.crosshair	= w_sawedoff_hud,
	.precache	= w_sawedoff_precache,
	.pickup		= NULL,
	.updateammo	= w_sawedoff_updateammo,
	.wmodel		= w_sawedoff_wmodel,
	.pmodel		= w_sawedoff_pmodel,
	.deathmsg	= w_sawedoff_deathmsg,
	.aimanim	= w_sawedoff_aimanim,
	.hudpic		= NULL
	
};



