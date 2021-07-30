
enum weaponseq_hk_pdw{
	idle,
	reload,
	draw,
	shoot,
	shoot2,
	shoot3
};


BOOLEAN weapon_HK_PDW_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_HK_PDW_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_HK_PDW_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_HK_PDW_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}

void weapon_HK_PDW_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}
BOOLEAN weapon_HK_PDW_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_HK_PDW_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::HK_PDW], arg_thisWeapon);	
}
void weapon_HK_PDW_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_HK_PDW_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_HK_PDW_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
	
}


weapondata_gun_t weapon_HK_PDW =
{
	WEAPONDATA_TYPEID_GUN,
	"MP7-PDW",
	"models/v_pdw.mdl",
	"models/p_pdw.mdl",
	"models/p_pdw_Sil.mdl",
	"models/w_pdw.mdl",
	"sprites/weapons/pdw.spr",
	weapon_HK_PDW_onPrimaryAttack,
	weapon_HK_PDW_onPrimaryAttackRelease,
	weapon_HK_PDW_onSecondaryAttack,
	weapon_HK_PDW_onSecondaryAttackRelease,
	weapon_HK_PDW_onEquip,
	weapon_HK_PDW_onUnEquip,
	weapon_HK_PDW_onThink,
	weapon_HK_PDW_onDrawHUD,
	weapon_HK_PDW_onReload,
	weapon_HK_PDW_onColdCock,
	weaponseq_hk_pdw::idle,
	weaponseq_hk_pdw::draw,
	31.0f / 30.0f,
	0.0625f,  //fire delay.
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_SCOPE,
	BITS_WEAPONOPT_NONE,
	2800,
	30,
	BUYCATEGORY_SMGS,
	3,
	{0.003000, 1.900000, 0.007500},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_FULL | BITS_FIREMODE_SEMI,
	BITS_FIREMODE_FULL,
	AMMO_ID::_5p7x28,
	40,  //clip
	4096, //range
	weaponseq_hk_pdw::reload,
	81.0f / 35.0f,
	1,
	-1,
	-1,
	2
};


void
w_hk_pdw_precache(void)
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
w_hk_pdw_updateammo(player pl)
{
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//Weapons_UpdateAmmo(pl, arg_thisWeapon.iClipLeft, pl.ary_ammoTotal[AMMO_ID::_9x19mm], -1);
}

string
w_hk_pdw_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::HK_PDW]).sWorldModelPath;
}

string
w_hk_pdw_pmodel(void)
{
	// Do we have the silencer?
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::HK_PDW]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::HK_PDW]).sPlayerSilencerModelPath;
	}
}

string
w_hk_pdw_deathmsg(void)
{
	return "";
}

void
w_hk_pdw_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::HK_PDW], arg_thisWeapon);
}

void
w_hk_pdw_holster(void)
{
}

void
w_hk_pdw_primary(void)
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
		TS_Weapons_PlaySoundDirect(pl, "weapons/pdw/fire.wav");
	} else {
		TS_Weapons_PlaySoundDirect(pl, "weapons/pdw/fire-sil.wav");
	}

	randomChoice = random();
	if(randomChoice < 1/3){
		TS_Weapons_ViewAnimation(weaponseq_hk_pdw::shoot, 21.0f/30.0f);
	}else if(randomChoice < 2/3){
		TS_Weapons_ViewAnimation(weaponseq_hk_pdw::shoot2, 21.0f/30.0f);
	}else{
		TS_Weapons_ViewAnimation(weaponseq_hk_pdw::shoot3, 21.0f/30.0f);
	}
	
#ifdef CLIENT
	View_ShowMuzzleflash(MUZZLE_SMALL);
	View_AddEvent(w_ejectshell_pistol, 0.0f);
#endif
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::HK_PDW], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}

void
w_hk_pdw_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	if(pl.w_attack_next > 0){
		return;
	}
	
	INPUT_SECONDARY_TAP_GATE
	
	if(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SCOPE){
		// toggle through the zoom.
		
		switch(pl.currentZoomChoice){
			case -1:{
				//pl.viewzoom = 40/80;
				pl.setZoom(0.50f);
				pl.currentZoomChoice++;
			break;}
			case 0:{
				//pl.viewzoom = 0;
				pl.setZoom(1.00f);
				pl.currentZoomChoice = -1;
			break;}
			
		}//END OF switch

	}
	
}


void
w_hk_pdw_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::HK_PDW], arg_thisWeapon);
}


// ???
float
w_hk_pdw_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_hk_pdw_hud(void)
{
	player pl = (player)self;
	
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::HK_PDW], arg_thisWeapon);

}

// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
void
w_hk_pdw_hudpic(int selected, vector pos, float a)
{
	//
}

weapon_t w_hk_pdw =
{
	
	.name		= "hk_pdw",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_hk_pdw_draw,
	.holster	= w_hk_pdw_holster,
	.primary	= w_hk_pdw_primary,
	.secondary	= w_hk_pdw_secondary,
	.reload		= w_hk_pdw_reload,
	.release	= NULL,
	.crosshair	= w_hk_pdw_hud,
	.precache	= w_hk_pdw_precache,
	.pickup		= NULL,
	.updateammo	= w_hk_pdw_updateammo,
	.wmodel		= w_hk_pdw_wmodel,
	.pmodel		= w_hk_pdw_pmodel,
	.deathmsg	= w_hk_pdw_deathmsg,
	.aimanim	= w_hk_pdw_aimanim,
	.hudpic		= NULL
	
};

