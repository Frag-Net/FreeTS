
enum weaponseq_steyraug{
	idle,
	draw,
	shoot,
	reload
};

void weapon_steyraug_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_steyraug_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_steyraug_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::STEYRAUG], arg_thisWeapon);
}
void weapon_steyraug_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
}

weapondata_gun_t weapon_steyraug =
{
	WEAPONDATA_TYPEID_GUN,
	"STEYR-AUG",
	"models/v_aug.mdl",
	"models/p_aug.mdl",
	"models/p_aug_sil.mdl",
	"models/w_aug.mdl",
	"sprites/weapons/aug.spr",
	weapon_steyraug_onPrimaryAttackRelease,
	weapon_steyraug_onSecondaryAttackRelease,
	weapon_steyraug_onThink,
	weapon_steyraug_onColdCock,
	weaponseq_steyraug::idle,
	weaponseq_steyraug::draw,
	31.0f / 30.0f,
	0.0625f,  //fire delay.
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_SCOPE,
	BITS_WEAPONOPT_SCOPE,
	5000,
	40,
	BUYCATEGORY_RIFLES,
	4,
	{0.005000, 1.000000, 0.015000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_FULL | BITS_FIREMODE_SEMI,
	BITS_FIREMODE_FULL,
	AMMO_ID::_5P56NATO,
	30,  //clip
	4096, //range
	weaponseq_steyraug::reload,
	74.0f / 30.0f,
	1,
	-1,
	-1,
	-1
};



void
w_steyraug_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::STEYRAUG]);
#ifdef SERVER
	precache_sound("weapons/aug/aug-fire-sil.wav");
	precache_sound("weapons/aug/aug-fire.wav");
	//precache_sound("weapons/aug/boltpull.wav");
	//precache_sound("weapons/aug/boltslap.wav");
	//precache_sound("weapons/aug/clipin.wav");
	//precache_sound("weapons/aug/clipout.wav");
#else
	
#endif
}

void
w_steyraug_updateammo(player pl)
{
}

string
w_steyraug_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::STEYRAUG]).sWorldModelPath;
}

string
w_steyraug_pmodel(void)
{
	// Do we have the silencer?
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::STEYRAUG]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::STEYRAUG]).sPlayerSilencerModelPath;
	}
}

string
w_steyraug_deathmsg(void)
{
	return "";
}

void
w_steyraug_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::STEYRAUG], arg_thisWeapon);
}

void
w_steyraug_holster(void)
{
}

void
w_steyraug_primary(void)
{
	float randomChoice;
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
	
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		SoundPitched_Send(pl, SNDP_STEYRAUG_FIRE);
	} else {
		SoundPitched_Send(pl, SNDP_STEYRAUG_FIRE_SIL);
	}
	
	TS_Weapons_ViewAnimation(weaponseq_steyraug::shoot, 31.0f/30.0f);

	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		weapon_ClientEffects(MUZZLEFLASH_ID::RIFLE, SHELLEJECT_ID::_56);
	} else {
		weapon_EjectShell(SHELLEJECT_ID::_56);
	}
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::STEYRAUG], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}

void
w_steyraug_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	if(pl.w_attack_next > 0){
		return;
	}
	
	INPUT_SECONDARY_TAP_GATE
	
	if(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SCOPE){
		// toggle through the zoom.
		pl.iZoomLevel = (pl.iZoomLevel + 1) % 2;
		switch(pl.iZoomLevel){
			case 0:{
				pl.setZoom(1.00f);
			break;}
			case 1:{
				pl.setZoom(0.50f);
			break;}
		}
	}
	
}


void
w_steyraug_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::STEYRAUG], arg_thisWeapon);
}

float
w_steyraug_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_steyraug_hud(void)
{
	player pl = (player)self;
	
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::STEYRAUG], arg_thisWeapon);

}

void
w_steyraug_hudpic(int selected, vector pos, float a)
{
	//
}

weapon_t w_steyraug =
{
	
	.name		= "steyraug",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_steyraug_draw,
	.holster	= w_steyraug_holster,
	.primary	= w_steyraug_primary,
	.secondary	= w_steyraug_secondary,
	.reload		= w_steyraug_reload,
	.release	= NULL,
	.crosshair	= w_steyraug_hud,
	.precache	= w_steyraug_precache,
	.pickup		= NULL,
	.updateammo	= w_steyraug_updateammo,
	.wmodel		= w_steyraug_wmodel,
	.pmodel		= w_steyraug_pmodel,
	.deathmsg	= w_steyraug_deathmsg,
	.aimanim	= w_steyraug_aimanim,
	.hudpic		= NULL
	
};

