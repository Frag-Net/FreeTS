
enum weaponseq_ragingbull{
	idle,
	shoot,
	shoot2,
	draw,
	reload
};


BOOLEAN weapon_RagingBull_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_RagingBull_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_RagingBull_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_RagingBull_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
void weapon_RagingBull_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}
BOOLEAN weapon_RagingBull_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_RagingBull_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::RagingBull], arg_thisWeapon);
}
void weapon_RagingBull_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_RagingBull_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_RagingBull_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
	
}



weapondata_gun_t weapon_RagingBull =
{
	WEAPONDATA_TYPEID_GUN,
	"Raging Bull",
	"models/v_bull.mdl",
	"models/p_bull.mdl",
	"",
	"models/w_bull.mdl",
	"sprites/weapons/bull.spr",
	weapon_RagingBull_onPrimaryAttack,
	weapon_RagingBull_onPrimaryAttackRelease,
	weapon_RagingBull_onSecondaryAttack,
	weapon_RagingBull_onSecondaryAttackRelease,
	weapon_RagingBull_onEquip,
	weapon_RagingBull_onUnEquip,
	weapon_RagingBull_onThink,
	weapon_RagingBull_onDrawHUD,
	weapon_RagingBull_onReload,
	weapon_RagingBull_onColdCock,
	weaponseq_ragingbull::idle,
	weaponseq_ragingbull::draw,
	31.0f / 33.0f,
	0.35f,  //fire delay. this is most certainly wrong. find something more accurate later.
	27.0f,
	TRUE,
	BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_SCOPE,
	BITS_WEAPONOPT_NONE,
	2100,
	15,
	BUYCATEGORY_HANDGUNS,
	2,
	{0.010000, 8.000000, 0.000000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_SEMI,
	BITS_FIREMODE_SEMI,
	AMMO_ID::_p454Casull,
	5,
	4096,
	weaponseq_ragingbull::reload,
	61.0f / 30.0f,
	-1,
	-1,
	-1,
	1
	
};




void
w_ragingbull_precache(void)
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
w_ragingbull_updateammo(player pl)
{
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//Weapons_UpdateAmmo(pl, arg_thisWeapon.iClipLeft, pl.ary_ammoTotal[AMMO_ID::_9x19mm], -1);
}

string
w_ragingbull_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::RagingBull]).sWorldModelPath;
}

string
w_ragingbull_pmodel(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	return (*ary_weaponData[WEAPON_ID::RagingBull]).sPlayerModelPath;
}

string
w_ragingbull_deathmsg(void)
{
	return "";
}

void
w_ragingbull_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::RagingBull], arg_thisWeapon);
}

void
w_ragingbull_holster(void)
{
}

void
w_ragingbull_primary(void)
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
	
	TS_Weapons_PlaySoundDirect(pl, "weapons/bull/fire01.wav");
	if ( random() <= 0.5 ) {
		TS_Weapons_ViewAnimation(weaponseq_ragingbull::shoot, 31.0f/30.0f);
	} else {
		TS_Weapons_ViewAnimation(weaponseq_ragingbull::shoot2, 31.0f/30.0f);
	}
	
#ifdef CLIENT
	View_ShowMuzzleflash(MUZZLE_SMALL);
	View_AddEvent(w_ejectshell_pistol, 0.0f);
#endif
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::RagingBull], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}

void
w_ragingbull_secondary(void)
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
				pl.setZoom(0.5f);
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
w_ragingbull_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::RagingBull], arg_thisWeapon);
}


// ???
float
w_ragingbull_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_ragingbull_hud(void)
{
	player pl = (player)self;
	
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::RagingBull], arg_thisWeapon);

}

// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
void
w_ragingbull_hudpic(int selected, vector pos, float a)
{
	//
}

weapon_t w_ragingbull =
{
	
	.name		= "ragingbull",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_ragingbull_draw,
	.holster	= w_ragingbull_holster,
	.primary	= w_ragingbull_primary,
	.secondary	= w_ragingbull_secondary,
	.reload		= w_ragingbull_reload,
	.release	= NULL,
	.crosshair	= w_ragingbull_hud,
	.precache	= w_ragingbull_precache,
	.pickup		= NULL,
	.updateammo	= w_ragingbull_updateammo,
	.wmodel		= w_ragingbull_wmodel,
	.pmodel		= w_ragingbull_pmodel,
	.deathmsg	= w_ragingbull_deathmsg,
	.aimanim	= w_ragingbull_aimanim,
	.hudpic		= NULL
	
};

