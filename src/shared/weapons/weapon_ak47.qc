
enum weaponseq_ak47{
	idle,
	reload,
	draw,
	shoot,
	idle2,
	change,
	rechange,
	shoot2,
	reloadb
};

void weapon_ak47_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_ak47_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}

void weapon_ak47_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::AK47], arg_thisWeapon);
}
void weapon_ak47_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
}

weapondata_ironsight_t weapon_ak47 =
{
	WEAPONDATA_TYPEID_IRONSIGHT,
	"AK47",
	"models/v_ak47.mdl",
	"models/p_ak47.mdl",
	"",
	"models/w_ak47.mdl",
	"sprites/weapons/ak47.spr",
	weapon_ak47_onPrimaryAttackRelease,
	weapon_ak47_onSecondaryAttackRelease,
	weapon_ak47_onThink,
	weapon_ak47_onColdCock,
	weaponseq_ak47::idle,
	weaponseq_ak47::draw,
	31.0f / 35.0f,
	0.0625f,  //fire delay.
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_SCOPE,
	BITS_WEAPONOPT_NONE,
	3000,
	40,
	BUYCATEGORY_RIFLES,
	4,
	{0.003000, 3.000000, 0.000000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_FULL | BITS_FIREMODE_SEMI,
	BITS_FIREMODE_FULL,
	AMMO_ID::_7P62X39MM,
	30,  //clip
	4096, //range
	weaponseq_ak47::reload,
	81.0f / 35.0f,
	-1,
	-1,
	-1,
	1,
	{
		weaponseq_ak47::change,
		21.0f/60.0f,
		weaponseq_ak47::rechange,
		21.0f/60.0f,
		weaponseq_ak47::idle2,
		weaponseq_ak47::reloadb,
		84.0f / 35.0f,
		{0.003000, 3.000000, 0.000000}
	}
};



void
w_ak47_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::AK47]);
#ifdef SERVER
	//precache_sound("weapons/ak47/clipin.wav");
	//precache_sound("weapons/ak47/clipout.wav");
	precache_sound("weapons/ak47/fire.wav");
	//precache_sound("weapons/ak47/slideback.wav");
#else
	
#endif
}

void
w_ak47_updateammo(player pl)
{
}

string
w_ak47_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::AK47]).sWorldModelPath;
}

string
w_ak47_pmodel(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	return (*ary_weaponData[WEAPON_ID::AK47]).sPlayerModelPath;
}

string
w_ak47_deathmsg(void)
{
	return "";
}

void
w_ak47_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::AK47], arg_thisWeapon);
}

void
w_ak47_holster(void)
{
}

void
w_ak47_primary(void)
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

	SoundPitched_Send(pl, SNDP_AK47_FIRE); /* get around protocol limits */
	
	if(!arg_thisWeapon.iIronSight){
		TS_Weapons_ViewAnimation(weaponseq_ak47::shoot, 31.0f/30.0f);
	}else{
		TS_Weapons_ViewAnimation(weaponseq_ak47::shoot2, 31.0f/30.0f);
	}
	
#ifdef CLIENT
	weapon_ShowMuzzleFlash(MUZZLEFLASH_ID::RIFLE);
	weapon_EjectShell(SHELLEJECT_ID::_56);
#endif
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::AK47], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}

void
w_ak47_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	if(pl.w_attack_next > 0){
		return;
	}
	
	INPUT_SECONDARY_TAP_GATE
	
	if(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SCOPE){
		// toggle through the zoom.
		pl.iZoomLevel = (pl.iZoomLevel + 1) % 3;
		switch(pl.iZoomLevel){
			case 0:{
				pl.setZoom(1.00f);
			break;}
			case 1:{
				pl.setZoom(0.4f);
			break;}
			case 2:{
				pl.setZoom(0.1625f);
			break;}
		}//END OF switch

	}else{
		// no scope?  we use ironsights then.
		weapon_ironsight_ToggleIronsight(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::AK47], arg_thisWeapon);
	}
	
}

void
w_ak47_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_ironsight_Reload(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::AK47], arg_thisWeapon);
}

float
w_ak47_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_ak47_hud(void)
{
	player pl = (player)self;
	
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::AK47], arg_thisWeapon);

}


weapon_t w_ak47 =
{
	
	.name		= "ak47",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_ak47_draw,
	.holster	= w_ak47_holster,
	.primary	= w_ak47_primary,
	.secondary	= w_ak47_secondary,
	.reload		= w_ak47_reload,
	.release	= NULL,
	.crosshair	= w_ak47_hud,
	.precache	= w_ak47_precache,
	.pickup		= NULL,
	.updateammo	= w_ak47_updateammo,
	.wmodel		= w_ak47_wmodel,
	.pmodel		= w_ak47_pmodel,
	.deathmsg	= w_ak47_deathmsg,
	.aimanim	= w_ak47_aimanim,
	.hudpic		= NULL
	
};

