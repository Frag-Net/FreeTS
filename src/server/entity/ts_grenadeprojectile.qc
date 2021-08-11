void
TS_GrenadeProjectile::TS_GrenadeProjectile(void){
}

void
TS_GrenadeProjectile::precache(void)
{
	Sound_Precache("weapon_m61grenade.bounce");
	// Explosion sound is already precached in fx_ts_explosion_grenade.qc
	// And the projectile model uses the world model, so that is also already handled
}

TS_GrenadeProjectile
TS_GrenadeProjectile::generate(
	player arg_player, vector arg_vOrigin, vector arg_vThrowDir,
	vector arg_vPlayerForward, int arg_weaponTypeID
){
	TS_GrenadeProjectile eNade = spawn(TS_GrenadeProjectile);
	
	weapondata_throwable_t* basicP = ((weapondata_throwable_t*)ary_weaponData[arg_weaponTypeID]);
	
	setorigin(eNade, arg_vOrigin);
	setmodel(eNade, (*basicP).sWorldModelPath);
	setsize(eNade, [-1, -1, -1], [1, 1, 1]);
	
	eNade.owner = arg_player;
	eNade.classname = "remove_me";
	eNade.solid = SOLID_TRIGGER; // This is so grenades will not get slowed down by windows they touch
	eNade.angles = vectoangles( arg_vThrowDir );
	
	// TODO - CRITICAL.
	// Factor in wasToss, heldDuration (out of 3, small minimum from clicking without holding down while
	// some of the toss anim plays)?
	eNade.velocity = (arg_vThrowDir * 200);  //was 1000
	
	eNade.avelocity = (arg_vPlayerForward * 1000);
	eNade.movetype = MOVETYPE_BOUNCE;
	eNade.gravity = 0.5f;
	
	eNade.think = TS_GrenadeProjectile_Explode;
	eNade.nextthink = time + 3.0f;
	
	return eNade;
}

void
TS_GrenadeProjectile::touch(void){
	if ( other.solid == SOLID_TRIGGER ) {
		return;
	}
	if ( other == this.owner ) {
		return;
	}
	if ( ( other.classname == "func_breakable" ) && ( other.material == GSMATERIAL_GLASS ) ) {
		// this means, insta-break the breakable glass we hit.
		// Calling this BLUNT I guess?  The grenade is really a rock at this point.
		Damage_Apply( other, this.owner, other.health, WEAPON_ID::M61GRENADE, DMG_BLUNT);
	}

	Sound_Play(this, CHAN_WEAPON, "weapon_m61grenade.bounce");
}


void
TS_GrenadeProjectile_Explode(void){
	//float randomChoice;
	
	// Also - don't worry about the shakes, sound script file for the
	// explosion sound has a shake parameter that handles that.
	// FX_Explosion also counts the sound to play.
	FX_TS_Explosion_Grenade_PlaySound(self);
	FX_TS_Explosion_Grenade(self.origin);
	
	//!!! THIS IS THE COUNTERSTRIKE EFFECT.
	// Comment/uncomment as needed.
	// we redirect this to the new lines for TS.  Easier to keep
	// the change to env_explosion and func_breakables that explode.
	////////////Effect_CreateExplosion( self.origin );
	
	// Is this accurate? I just know a grenade can kill a player with around
	// 150 health from a powerup, and takes 100 down to 20 from a good distance.
	// CHANGE!  Don't we want to tell who attacked (who threw the grenade), not just give
	// the grenade itself for the 2nd "eAttacker" parameter?
	Damage_Radius(self.origin, self.owner, 160, 380, TRUE, WEAPON_ID::M61GRENADE);
	//Damage_Radius( self.origin, self, 75, 550, TRUE, WEAPON_ID::M61GRENADE );
	
	//Damage_Apply(other, this, m_iDamage, WEAPON_ID::M61GRENADE, DMG_GENERIC);
	
	// this is mad old
	//Damage_Apply(plPlayer, world, plPlayer.dmg, DAMAGE_DROWNING, WEAPON_NONE);
	//Damage_Apply(target, world, 5, DMG_DROWN, 0);
	
	//Damage_Apply( self, world, fFallDamage, 0, DMG_FALL);
	
	// delay this so damage indicators can figure out where I came from!
	// ...weird, I know.
	//remove( self );
	removeSelfDelayed(self);
}

