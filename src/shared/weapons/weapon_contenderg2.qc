
//TODO - is "stock" a melee attack??

enum weaponseq_contenderg2{
	idle,
	draw,
	reload,
	shoot1,
	shoot2,
	stock
};


BOOLEAN weapon_ContenderG2_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_ContenderG2_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_ContenderG2_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_ContenderG2_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
void weapon_ContenderG2_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}
BOOLEAN weapon_ContenderG2_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_ContenderG2_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::ContenderG2], arg_thisWeapon);
}
void weapon_ContenderG2_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_ContenderG2_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_ContenderG2_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
}


	
//weapondata_ironsight_t weapon_ContenderG2 =
weapondata_gun_t weapon_ContenderG2 =
{
	WEAPONDATA_TYPEID_GUN,
	"Contender G2",
	"models/v_contender.mdl",
	"models/p_contender.mdl",
	"",
	"models/w_contender.mdl",
	"sprites/weapons/contender.spr",
	weapon_ContenderG2_onPrimaryAttack,
	weapon_ContenderG2_onPrimaryAttackRelease,
	weapon_ContenderG2_onSecondaryAttack,
	weapon_ContenderG2_onSecondaryAttackRelease,
	weapon_ContenderG2_onEquip,
	weapon_ContenderG2_onUnEquip,
	weapon_ContenderG2_onThink,
	weapon_ContenderG2_onDrawHUD,
	weapon_ContenderG2_onReload,
	weapon_ContenderG2_onColdCock,
	weaponseq_contenderg2::idle,
	weaponseq_contenderg2::draw,
	31.0f / 30.0f,
	0.35f,  //fire delay. this is most certainly wrong. find something more accurate later.
	60.0f,
	TRUE,
	BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_SCOPE,
	BITS_WEAPONOPT_NONE,
	1500,
	15,
	BUYCATEGORY_HANDGUNS,
	2,
	
	{0.001000, 12.000000, 0.000000},
	
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_SEMI,
	BITS_FIREMODE_SEMI,
	
	AMMO_ID::_7p62x51mm,
	1,
	
	4096,
	weaponseq_contenderg2::reload,
	61.0f / 35.0f,
	-1,
	1,
	-1,
	2
	
	/*
	//ironsightdata_t
	{
		weaponseq_contenderg2::change,
		21.0f / 35.0f,
		weaponseq_contenderg2::rechange,
		21.0f / 35.0f,
		weaponseq_contenderg2::idle,
		weaponseq_contenderg2::reload,
		61.0f / 30.0f,
		//can have different firestats from ordinary firing.  Dbn't know yet though.
		{0.010000, 8.000000, 0.000000}
	}
	*/
};




void
w_contenderg2_precache(void)
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
w_contenderg2_updateammo(player pl)
{
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//Weapons_UpdateAmmo(pl, arg_thisWeapon.iClipLeft, pl.ary_ammoTotal[AMMO_ID::_9x19mm], -1);
}

string
w_contenderg2_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::ContenderG2]).sWorldModelPath;
}

string
w_contenderg2_pmodel(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	return (*ary_weaponData[WEAPON_ID::ContenderG2]).sPlayerModelPath;
}

string
w_contenderg2_deathmsg(void)
{
	return "";
}

void
w_contenderg2_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::ContenderG2], arg_thisWeapon);
}

void
w_contenderg2_holster(void)
{
}

void
w_contenderg2_primary(void)
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
	
	TS_Weapons_PlaySoundDirect(pl, "weapons/contender/fire.wav");
	
	if ( random() <= 0.5 ) {
		TS_Weapons_ViewAnimation(weaponseq_contenderg2::shoot1, 31.0f/30.0f);
	} else {
		TS_Weapons_ViewAnimation(weaponseq_contenderg2::shoot2, 31.0f/30.0f);
	}
	
#ifdef CLIENT
	View_ShowMuzzleflash(MUZZLE_SMALL);
	View_AddEvent(w_ejectshell_pistol, 0.0f);
#endif
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::ContenderG2], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}

void
w_contenderg2_secondary(void)
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
				//pl.viewzoom = 26/80;
				pl.setZoom(0.325f);
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
w_contenderg2_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::ContenderG2], arg_thisWeapon);
}


// ???
float
w_contenderg2_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_contenderg2_hud(void)
{
	player pl = (player)self;
	
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::ContenderG2], arg_thisWeapon);

}

// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
void
w_contenderg2_hudpic(int selected, vector pos, float a)
{
	//
}

weapon_t w_contenderg2 =
{
	
	.name		= "contenderg2",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_contenderg2_draw,
	.holster	= w_contenderg2_holster,
	.primary	= w_contenderg2_primary,
	.secondary	= w_contenderg2_secondary,
	.reload		= w_contenderg2_reload,
	.release	= NULL,
	.crosshair	= w_contenderg2_hud,
	.precache	= w_contenderg2_precache,
	.pickup		= NULL,
	.updateammo	= w_contenderg2_updateammo,
	.wmodel		= w_contenderg2_wmodel,
	.pmodel		= w_contenderg2_pmodel,
	.deathmsg	= w_contenderg2_deathmsg,
	.aimanim	= w_contenderg2_aimanim,
	.hudpic		= NULL
	
};

