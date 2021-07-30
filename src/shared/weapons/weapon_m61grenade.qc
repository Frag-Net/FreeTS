
enum weaponseq_m61grenade{
	idle,
	draw,
	start,
	throw,
	throw_slide
};

extern BOOLEAN weapon_grenade_onInputPress(player localPlayer, weapondynamic_t arg_thisWeapon, int attackTypeUsed);
//extern BOOLEAN weapon_grenade_onInputRelease(player localPlayer, weapondynamic_t arg_thisWeapon);


BOOLEAN weapon_M61Grenade_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_M61Grenade_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_M61Grenade_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_M61Grenade_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}



void weapon_M61Grenade_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	
}
BOOLEAN weapon_M61Grenade_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}



//Serverside only method, generates an entity
#ifdef SSQC

static void weapon_M61Grenade_Touch( void );
static void weapon_M61Grenade_Explode( void );

void weapon_M61Grenade_spawnProjectile(player localPlayer, weapondynamic_t arg_thisWeapon, BOOL wasToss, float heldDuration){
	player pl = localPlayer;
	
	weapondata_throwable_t basicRef = *((weapondata_throwable_t*)ary_weaponData[WEAPON_ID::M61Grenade]);
	
	makevectors( localPlayer.v_angle );
	entity eNade = spawn();
	setorigin( eNade, ( localPlayer.origin + localPlayer.view_ofs ) + ( v_forward * 16 ) );
	setmodel( eNade, basicRef.sWorldModelPath );
	setsize( eNade, '-1 -1 -1', '1 1 1' );
	
	vector vDir = aim ( localPlayer, 100000 );
	eNade.owner = localPlayer;
	eNade.classname = "remove_me";
	eNade.solid = SOLID_TRIGGER; // This is so grenades will not get slowed down by windows they touch
	eNade.angles = vectoangles( vDir );
	
	//TAGGG - TODO, CRITICAL.
	// Factor in wasToss, heldDuration (out of 3, small minimum from clicking without holding down while
	// some of the toss anim plays)?
	eNade.velocity = ( vDir * 200 );  //was 1000
	
	eNade.avelocity = ( v_forward * 1000 );
	eNade.movetype = MOVETYPE_BOUNCE;
	eNade.touch = weapon_M61Grenade_Touch;
	eNade.gravity = 0.5f;
	
	eNade.think = weapon_M61Grenade_Explode;
	eNade.nextthink = time + 3.0f;
	
}


static void weapon_M61Grenade_Touch( void ) {
	float randomChoice;
	if ( other.solid == SOLID_TRIGGER ) {
		return;
	}
	if ( other == self.owner ) {
		return;
	}
	if ( ( other.classname == "func_breakable" ) && ( other.material == GSMATERIAL_GLASS ) ) {
		// this means, insta-break the breakable glass we hit.
		// Calling this BLUNT I guess?  The grenade is really a rock at this point.
		Damage_Apply( other, self.owner, other.health, WEAPON_ID::M61Grenade, DMG_BLUNT);
	}

	randomChoice = random();
	if(randomChoice < 0.25){
		sound(self, CHAN_WEAPON, "weapons/grenbounce1.wav", 1, ATTN_NORM);
	}else if(randomChoice < 0.5){
		sound(self, CHAN_WEAPON, "weapons/grenbounce2.wav", 1, ATTN_NORM);
	}else if(randomChoice < 0.75){
		sound(self, CHAN_WEAPON, "weapons/grenbounce3.wav", 1, ATTN_NORM);
	}else{
		sound(self, CHAN_WEAPON, "weapons/grenbounce4.wav", 1, ATTN_NORM);
	}
}


static void weapon_M61Grenade_Explode( void ) {
	float randomChoice;
	
	//!!! THIS IS THE COUNTERSTIKRE EFFECT.
	//Comment/uncomment as needed.
	//...we redirect this to the new lines for TS.  Easier to keep
	//the change to env_explosion and func_breakables that explode.
	Effect_CreateExplosion( self.origin );
	
	//Effect_ScreenShake( self.origin, 2048, 255 );
	//Effect_Explosion( self.origin + [0,0,16] );
	
	// Is this accurate? I just know a grenade can kill a player with around
	// 150 health from a powerup, and takes 100 down to 20 from a good distance.
	// CHANGE!  Don't we want to tell who attacked (who threw the grenade), not just give
	// the grenade itself for the 2nd "eAttacker" parameter?
	Damage_Radius( self.origin, self.owner, 160, 380, TRUE, WEAPON_ID::M61Grenade );
	//Damage_Radius( self.origin, self, 75, 550, TRUE, WEAPON_ID::M61Grenade );
	
	//Damage_Apply(other, this, m_iDamage, WEAPON_ID::M61Grenade, DMG_GENERIC);
	
	// this is mad old
	//Damage_Apply(plPlayer, world, plPlayer.dmg, DAMAGE_DROWNING, WEAPON_NONE);
	//Damage_Apply(target, world, 5, DMG_DROWN, 0);

	//Damage_Apply( self, world, fFallDamage, 0, DMG_FALL);

	randomChoice = random();
	if(randomChoice < 0.2){
		sound(self, CHAN_WEAPON, "explo/explode.wav", 1, ATTN_NORM);
	}else if(randomChoice < 0.4){
		sound(self, CHAN_WEAPON, "explo/explode1.wav", 1, ATTN_NORM);
	}else if(randomChoice < 0.6){
		sound(self, CHAN_WEAPON, "explo/explode2.wav", 1, ATTN_NORM);
	}else if(randomChoice < 0.8){
		sound(self, CHAN_WEAPON, "explo/explode3.wav", 1, ATTN_NORM);
	}else{
		sound(self, CHAN_WEAPON, "explo/explode4.wav", 1, ATTN_NORM);
	}
	
	// delay this so damage indicators can figure out where I came from!
	// ...weird, I know.
	//remove( self );
	removeSelfDelayed(self);
}
#endif


void weapon_M61Grenade_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	player pl = localPlayer;
	
	//TAGGG - WARNING!!!
	// grenadeHeldDuration is not networked!  It counts up faster for the client than the server.
	// If using to keep track of what animation to play (like HL having different throw anims for
	// range), that should be networked so that this gives an accurate viewmodel.
	// ALTHOUGH, this applies to the time of picking a throw anim, not spawning the grenade.
	if(pl.grenadeSpawnTime != -1 && pl.grenadeFireIndex > 0){
		pl.grenadeHeldDuration = min(pl.grenadeHeldDuration + input_timelength, 3);
		
		if(pl.w_attack_next <= pl.grenadeSpawnTime){
			// TODO - have another timer or var help with that???
			// Or set pl.w_attack_next to the max time effective to hold a grenade back to begin with,
			// and check for being sooner than 0 somewhere else...
			
			printfline("grenadespawn: HELD TIME: %.2f", pl.grenadeHeldDuration);
		
			arg_thisWeapon.iCount -= 1;
			pl.updateSlotCountsForEquippedWeapon();
			pl.grenadeSpawnTime = -1;
			
			#ifdef SERVER
			weapon_M61Grenade_spawnProjectile(localPlayer, arg_thisWeapon, pl.grenadeToss, pl.grenadeHeldDuration);
			#endif
		}
	}
	
	
	if(pl.w_attack_next > 0){
		// wait for w_attack_next to expire before doing logic against grenadeFireIndex choice
		// (except above, checks a bit differently for spawning the grenade)
		return;
	}
	
	/*
	// debugging, prevChoice was a global var
	if(pl.grenadeFireIndex != prevChoice){
		printfline("!!! w_attack_next FINISHED WITH GRENFIREIN: %i", pl.grenadeFireIndex);
		prevChoice = pl.grenadeFireIndex;
	}
	if(pl.grenadeFireIndex > 0){
		printfline("pl.grenadeFireIndex resolved: %i", pl.grenadeFireIndex);
	}
	*/
	
	if(pl.grenadeFireIndex == 0){
		// pin pull animation is finished, ready to throw when the input is not held down.
		pl.grenadeHeldDuration = min(pl.grenadeHeldDuration + input_timelength, 3);
		
		if(!(input_buttons & INPUT_BUTTON0) && !(input_buttons & INPUT_BUTTON3)){
			// neither input held down?  Move on
			//printfline("!!! RELEASE");
			pl.grenadeFireIndex = 1;
		}
	}
	// should this be joined by else or no?
	if(pl.grenadeFireIndex == 1){
		// Release detected, do the throw anim + spawn the grenade soon
		if(!pl.grenadeToss){
			TS_Weapons_ViewAnimation(weaponseq_m61grenade::throw, 11.0f/30.0f);
		}else{
			TS_Weapons_ViewAnimation(weaponseq_m61grenade::throw_slide, 11.0f/30.0f);
		}
		pl.grenadeFireIndex = 2;
		// re-use shotgunAddAmmoTime instead, make the var more genericly named maybe???
		//pl.grenadeSpawnTime = time + 4.0f/30.0f;
		weapon_base_setWholeAttackDelay(pl, (11.0f/30.0f) * 1);
		
		pl.grenadeSpawnTime = pl.w_attack_next - 4.0f/30.0f;
	}else if(pl.grenadeFireIndex == 2){
		// Throw anim is over, decide whether to deploy another grenade or remove the
		// weapon if out of grenades.
		
		//printfline("Remove grenade? Count:%i", arg_thisWeapon.iCount);
		if(arg_thisWeapon.iCount > 0){
			TS_Weapons_ViewAnimation(weaponseq_m61grenade::draw, 31.0f / 40.0f );
			pl.grenadeFireIndex = -1;
			weapon_base_setWholeAttackDelay(pl, (31.0f/40.0f));
		}else{
			
			// no more, remove this item and pick another.
			//printfline("removeWeaponFromInventory PRE cur weapo: %i", pl.inventoryEquippedIndex);
			
			removeWeaponFromInventory(pl, pl.inventoryEquippedIndex);
			playerEquipIdealSafe(pl);
			
			//printfline("removeWeaponFromInventory POST cur weapo: %i", pl.inventoryEquippedIndex);
			pl.grenadeFireIndex = -1;  // paranoia?
			return;
		}
		
	}
	
}
void weapon_M61Grenade_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_M61Grenade_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_M61Grenade_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
}


weapondata_throwable_t weapon_M61Grenade =
{
	WEAPONDATA_TYPEID_THROWABLE,
	"M61 Grenade",
	"models/v_m61.mdl",
	"models/p_m61.mdl",
	"",
	"models/w_m61.mdl",
	"sprites/weapons/m61.spr",
	weapon_M61Grenade_onPrimaryAttack,
	weapon_M61Grenade_onPrimaryAttackRelease,
	weapon_M61Grenade_onSecondaryAttack,
	weapon_M61Grenade_onSecondaryAttackRelease,
	weapon_M61Grenade_onEquip,
	weapon_M61Grenade_onUnEquip,
	weapon_M61Grenade_onThink,
	weapon_M61Grenade_onDrawHUD,
	weapon_M61Grenade_onReload,
	weapon_M61Grenade_onColdCock,
	weaponseq_m61grenade::idle,
	weaponseq_m61grenade::draw,
	31.0f / 40.0f,
	0.5,  //fire delay. this is most certainly wrong. find something more accurate later.
	8.0f,  //dmg
	FALSE,
	BITS_WEAPONOPT_FULLLOAD,
	BITS_WEAPONOPT_NONE,
	1500,
	10,
	BUYCATEGORY_SPECIALPURPOSE,
	1,
	{0.100000, 1.000000, 0.000000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	2
	
};



BOOLEAN weapon_grenade_onInputPress(player localPlayer, weapondynamic_t arg_thisWeapon, int attackTypeUsed){
	player pl = localPlayer;
	
	if(arg_thisWeapon.iCount == 0){
		// what.  how.
		removeWeaponFromInventory(pl, pl.inventoryEquippedIndex);
		playerEquipIdealSafe(pl);
		return;
	}

	// Initiating a throw is only do-able when the attack delay is up, and a fresh key press.
	// Don't allow to interrupt the deploy anim.
	if(pl.w_attack_next <= 0 && (INPUT_PRIMARY_TAP_CHECK(pl) || INPUT_SECONDARY_TAP_CHECK(pl))){
		if(pl.grenadeFireIndex == -1){
			pl.grenadeFireIndex = 0;
			pl.grenadeSpawnTime = -1;  // not yet!
			pl.grenadeHeldDuration = 0;
			TS_Weapons_ViewAnimation(weaponseq_m61grenade::start, (31.0f/35.0f) );
			weapon_base_setWholeAttackDelay(pl, 0.6);	
		}
	}
	
	// Once already started, this can affect being a normal throw or slide-throw.
	if(pl.grenadeFireIndex == 0){
		if(attackTypeUsed & BITS_AKIMBOCHOICE_LEFT){
			pl.grenadeToss = FALSE;  //throw, this was primary.
		}else if(attackTypeUsed & BITS_AKIMBOCHOICE_RIGHT){
			pl.grenadeToss = TRUE;  //throw, this was sec.
		}
	}
	
	return TRUE;
}



// This might look appealing (linked to either primary/secondary input being released), 
// but releasing too early (while the pull-pin anim is still happening) means the grenade
// will stay held back until primary or secondary is completely pushed/released again,
// which is not ideal.  Pressing an input + releasing fast should just mean the grenade
// fires as soon as possible so long as it is not still held down at that point.
// It makes far more sense to just check for either input still being held-down in the think
// method during the pullpin grenade phase.
/*
BOOLEAN weapon_grenade_onInputRelease(player localPlayer, weapondynamic_t arg_thisWeapon){
	player pl = localPlayer;
	if(pl.w_attack_next > 0){
		// wait for w_attack_next to expire before doing logic against grenadeFireIndex choice
		// (except above, checks a bit differently for spawning the grenade)
		return;
	}
	if(pl.grenadeFireIndex == 0){
		// pin pull animation is finished, ready to throw when the input is not held down.
		if(!(input_buttons & INPUT_BUTTON0) && !(input_buttons & INPUT_BUTTON3)){
			// primary not held down?  Move on then
			//printfline("!!! RELEASE DETECT");
			pl.grenadeFireIndex = 1;
		}
	}
}
*/


void
w_m61grenade_precache(void)
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
w_m61grenade_updateammo(player pl)
{
	
}

string
w_m61grenade_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::M61Grenade]).sWorldModelPath;
}

string
w_m61grenade_pmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::M61Grenade]).sPlayerModelPath;
}

string
w_m61grenade_deathmsg(void)
{
	return "";
}

void
w_m61grenade_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	pl.grenadeFireIndex = -1;
	pl.grenadeSpawnTime = -1;
	pl.grenadeHeldDuration = 0;
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::M61Grenade], arg_thisWeapon);
}

void
w_m61grenade_holster(void)
{
}

void
w_m61grenade_primary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_grenade_onInputPress(pl, arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
}

void
w_m61grenade_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_grenade_onInputPress(pl, arg_thisWeapon, BITS_AKIMBOCHOICE_RIGHT);
}

void
w_m61grenade_reload(void)
{

}

// ???
float
w_m61grenade_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_m61grenade_hud(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_throwable_onDrawHUD(pl, (weapondata_throwable_t*)ary_weaponData[WEAPON_ID::M61Grenade], arg_thisWeapon);
}

// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
void
w_m61grenade_hudpic(int selected, vector pos, float a)
{
	//
}


weapon_t w_m61grenade =
{
	
	.name		= "m61grenade",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_m61grenade_draw,
	.holster	= w_m61grenade_holster,
	.primary	= w_m61grenade_primary,
	.secondary	= w_m61grenade_secondary,
	.reload		= w_m61grenade_reload,
	.release	= NULL,
	.crosshair	= w_m61grenade_hud,
	.precache	= w_m61grenade_precache,
	.pickup		= NULL,
	.updateammo	= w_m61grenade_updateammo,
	.wmodel		= w_m61grenade_wmodel,
	.pmodel		= w_m61grenade_pmodel,
	.deathmsg	= w_m61grenade_deathmsg,
	.aimanim	= w_m61grenade_aimanim,
	.hudpic		= NULL
	
};

