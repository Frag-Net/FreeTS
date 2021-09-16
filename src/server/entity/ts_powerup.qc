

#define POWERUP_MODEL_PATH "models/powerup.mdl"


enum pwuptype_choice{
	Random = 0,
	Slow_Motion = 1,
	Infinite_Clip = 2,
	Kung_Fu = 4,
	Slow_Pause = 8,
	Double_Firerate = 16,
	Grenade = 32,
	Health = 64,
	Armor = 128,
	Low_Gravity = 256   //better known as super/power jump?  ehh see the manual, it has the boots icon'd one.
};




#ifdef SERVER

class CTSPowerUp:CBaseEntity{
	
	//key values?
	pwuptype_choice m_ePwuptype;
	int m_iPwupduration;
	string m_strMessage;
	float expireTime;
	float respawnTime;
	
	// actual picked submodel. Can be looked at for logic on touch.
	// nahhh, just take it from the powerup_data_... structs.
	//int submodelIndex;
	
	// What member of ary_powerupData do I get my behavior/model/etc. from?
	POWERUP_ID dataID;
	BOOL alreadyPickedUp;
	BOOL isRespawnCall;
	
	vector mem_origin;
	
	void(void) CTSPowerUp;
	static void(void) precache;
	virtual void(void) CustomInit;
	//virtual void(void) restartAnim;
	virtual float(entity pvsent, float cflags) send;
	virtual void(void) Respawn;
	virtual void(void) think;
	virtual void(void) touch;
	virtual void(void) determineDataID;
	virtual void(void) declareDisposable;
};



void
CTSPowerUp::CTSPowerUp(void)
{
	
	// And why don't we just receive these as name/value pairs like clientside does?
	// I HAVE NO CLUE.
	// And is it a problem we never call CBaseEntity's constructor?
	// If we did it would read every single field that way, in addition to us
	// reading every single field here, just to get info that the CBaseEntity expects
	// (origin) and what CTSPowerUp expects. Not efficient!
	
	
	int nfields = tokenize( __fullspawndata );
	for (int i = 1; i < (nfields - 1 ); i += 2) {
		switch ( argv( i ) ) {
		case "pwuptype":
			m_ePwuptype = stoi(argv(i + 1));
			break;
		// this is actually the time that passes before respawning.
		// So at one time this was meant to determine how long a powerup lasts once used?  really?
		case "pwupduration":
			m_iPwupduration = stoi(argv(i + 1));
			break;
		// Pretty sure this goes completely unused.  Wouldn't only some tutorial have any reason
		// to put a message on screen upon touching a powerup (so I assume is the point)?
		case "message":
			m_strMessage = argv(i + 1);
			break;
		//VECTOR PARAMETER EXAMPLE (not in this one though):
		/*
		case "color":
			colormod = stov( argv( i + 1 ) );
			break;
		*/
		default:
			break;
		}
	}
	
	//gflags |= GF_CANRESPAWN;
	
}// constructor


void
CTSPowerUp::CustomInit(void)
{
	
	
	expireTime = -1;  //assumption.
	respawnTime = -1;
	
	//anything spechul?
	
	//setmodel( this, "models/powerup.mdl" );
	
	this.isRespawnCall = TRUE;
	
	this.alreadyPickedUp = FALSE;
	
	
	this.classname = "ts_powerup";
	this.owner = world;
	this.movetype = MOVETYPE_TOSS;
	this.solid = SOLID_TRIGGER; //or CORPSE
	
	this.pvsflags = PVSF_NOREMOVE | PVSF_IGNOREPVS;
	
	
	//customphysics?
	//eDrop.think = CTSPowerUp::Think;
	//eDrop.touch = CTSPowerUp::Touch;
	//this.nextthink = time + 0.5f;
	
	//uhh..  ok, sure
	//this.health = 1;
	
	setsize( this, '-24 -24 0', '24 24 48' );

	//this.modelflags = ?
	this.frame = 0;
	this.frame1time = 0;
	
	//frames: 31
	//FPS: 20
	
	//this.think = restartAnim;
	//this.nextthink = time + (31-2)/20;
	
	this.model = POWERUP_MODEL_PATH;
	
	//takedamage = DAMAGE_NO;
	
	// start at where I spawned, already recorded by CBaseEntity for us.
	origin = GetSpawnOrigin();
	
	// Tone the gravity down to see them fall better / prove their positions are reset on spawn.
	//this.gravity = 0.006;
	
	// And this lets the powerup start against the ground, compared to where it was placed on the map.
	// Original TS might not even do this, but hey.  Why not, it would end up here anyway in a second of
	// gametime.
	if(!droptofloor()){
		vector vSource = this.origin;
		//we must take matters into our own hands.
		traceline ( vSource, vSource + ( '0 0 -1' * 300 ), TRUE, this );
		//entity ef = findradius(trace_endpos, 40);
		
		this.origin[2] = trace_endpos[2];
	}
	
	// forget if we were on the ground.
	// Yes, we have to do this or we forget to fall since a origin force-change (teleport)
	// I LOVE YOU, ENGINE.
	flags &= ~FL_ONGROUND;
	groundentity = NULL;
	
	
	// Do this AFTER your position-shifting shenanigans you hooligan!
	setorigin(this, origin);
	
	determineDataID();
	
	// not necessarily the origin at spawntime,
	// this keeps track of the origin since the last time we let the client know what it is.
	// Yes.  Really.
	mem_origin = this.origin;
	
	this.SendEntity = send;
	this.SendFlags = 1;
	
	//this.touch = CTSPowerUp::Touch;
	//this.think = CTSPowerUp::Think;
	this.nextthink = time + 0;
	
	// ??? SERVERTEST
	//setmodel( this, "models/powerup.mdl" );
	
	//m_oldModel = POWERUP_MODEL_PATH;
	//RendermodeUpdate();
	
}// CustomInit



float CTSPowerUp::send(entity pvsent, float cflags)
{
	WriteByte(MSG_ENTITY, ENT_POWERUP);
	WriteCoord(MSG_ENTITY, this.origin[0]);
	WriteCoord(MSG_ENTITY, this.origin[1]);
	WriteCoord(MSG_ENTITY, this.origin[2]);
	WriteCoord(MSG_ENTITY, this.angles[0]);
	WriteCoord(MSG_ENTITY, this.angles[1]);
	WriteCoord(MSG_ENTITY, this.angles[2]);
	
	WriteByte(MSG_ENTITY, this.dataID);
	WriteByte(MSG_ENTITY, this.alreadyPickedUp);
	WriteByte(MSG_ENTITY, this.isRespawnCall);
	
	this.isRespawnCall = FALSE;  //only send once this time.
	
	//WriteByte(MSG_ENTITY, dataID);
	
	//WriteString(MSG_ENTITY, this.texture);
	
	return TRUE;
}



void
CTSPowerUp::Respawn(void)
{
	
	CustomInit();
	
}// Respawn




void
CTSPowerUp::think(void)
{
	
	//TAGGG - CRITICAL.  DISCUSS.
	// Is it ok to resend the entity to the client(s) just because our position changed?
	// There is no way around this?  Any part of physics handled clientside for an ounce of prediction?  etc.?
	// Would falling look odd on low internet connections?
	// Yes pre-placed map powerups wouldn't spend much time falling.  Or any if we're using the 'detect & snap to ground'
	// feature, but this is more of a concern for other things that seem to lose all default functionality for server-client
	// interactions (setting SendEntity ever I think is what causes this?)
	
	if(respawnTime != -1 && time >= respawnTime){
		// re-appear then!
		respawnTime = -1;
		Respawn();
		return;
	}
	if(this.origin != mem_origin){
		mem_origin = this.origin;
		//uh-oh.  we gotta tell the client.
		this.SendEntity = send;
		this.SendFlags = 1;
	}
	
	
	this.nextthink = time + 0.01;
	
}// think


void
CTSPowerUp::touch(void)
{
	
	
	if(other.classname != "player"){
		return;
	}
	
	//TAGGG - TODO.  Actually query to see whether our type of powerup is usable, and, if so, forbid
	// adding to the player if they already have a usable powerup equipped (stored for use).
	// Any other time, this powerup always gets deleted & makes the gunpickup noise in original TS behavior.
	// Deviate however, or not.
	sound( other, CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_NORM, 100, SOUNDFLAG_PLAYER_COMMON );
	
	
	//remove(self);
	
	if(this.expireTime == -1){
		//pre-placed by the map?  Create the illusion we disappeared.
		CBaseEntity::Hide();
		this.alreadyPickedUp = TRUE;
		
		//respawn 'm_iPwupduration seconds from now, often 60 (at least it is in ts_bikini)
		this.respawnTime = time + m_iPwupduration;
		
		this.SendEntity = send;
		this.SendFlags = 1;
	}else{
		//We were going to expire at some point?  Do so now then, no need to hide to never be respawned and deleted later.
		remove(this);
	}
	
}// touch




void
CTSPowerUp::determineDataID(void)
{
	int bitsToChoose[9];
	
	// really.. this is just setting bitsToChoose[0] to 0.  Stops a 'uninitialized variable'
	// warning when done this way instead.
	//	 God I love FTE.
	(*bitsToChoose) = 0;
	
	
	//TEST to see how this works out.
	// Should only ever spawn karate and double-fire.
	//m_ePwuptype = 4 | 16;
	// And infinite clip/double clip, and slow pause/old slow pause.
	//m_ePwuptype = 2 | 8;
	
	
	int _1Count = 0;
	int currentBit = 1;
	int bitmask = m_ePwuptype;
	int bitEnd = 256;
	while(TRUE){
		if(bitmask & currentBit){
			bitsToChoose[_1Count] = currentBit;
			_1Count += 1;
		}
		if(currentBit < bitEnd){
			currentBit = currentBit << 1;  //next.
		}else{
			//stop!
			break;
		}
	}
	
	
	int bitIndexChosen = 0;
	int bitChosen = 0;
	
	if(_1Count == 0){
		//choose from them all now.
		bitIndexChosen = randomInRange_i(0, 8);
		bitChosen = (1 << bitIndexChosen);
	}else if(_1Count == 1){
		bitIndexChosen = 0;
		bitChosen = bitsToChoose[bitIndexChosen];
	}else{
		bitIndexChosen = randomInRange_i(0, _1Count-1);
		bitChosen = bitsToChoose[bitIndexChosen];
	}
	
	//submodel 4: a pause sign.  ???
	//submodel 11: double-magazine (possible replacement for infinite ammo in some versions)?
	if(bitChosen == 1){
		//slow motion
		//submodelIndex = 5;
		dataID = POWERUP_ID::SlowMotion;
	}else if(bitChosen == 2){
		//"Infinite Clip"
		//submodelIndex = 3;
		
		if(_1Count == 1){
			//force the original only.
			dataID = POWERUP_ID::InfiniteClip;
		}else{
			//I was picked of at least 1 other choice? Allow me to be the alternate too.
			if(random() < 0.5){
				dataID = POWERUP_ID::InfiniteClip;
			}else{
				dataID = POWERUP_ID::DoubleClip;
			}
		}
	}else if(bitChosen == 4){
		//"Kung Fu"
		//submodelIndex = 1;
		dataID = POWERUP_ID::KungFu;
	}else if(bitChosen == 8){
		//Slow Pause
		//submodelIndex = 10;
		
		if(_1Count == 1){
			//force the original only.
			dataID = POWERUP_ID::SlowPause;
		}else{
			//I was picked of at least 1 other choice? Allow me to be the alternate too.
			if(random() < 0.5){
				dataID = POWERUP_ID::SlowPause;
			}else{
				dataID = POWERUP_ID::SlowPauseOld;
			}
		}
	}else if(bitChosen == 16){
		// Double Firerate
		//submodelIndex = 2;
		dataID = POWERUP_ID::DoubleFirerate;
	}else if(bitChosen == 32){
		//Grenade
		//submodelIndex = 6;
		dataID = POWERUP_ID::Grenade;
	}else if(bitChosen == 64){
		//Health
		//submodelIndex = 7;
		dataID = POWERUP_ID::Health;
	}else if(bitChosen == 128){
		//Armor
		//submodelIndex = 8;
		dataID = POWERUP_ID::Armor;
	}else if(bitChosen == 256){
		//Low gravity (or rather super jump)
		//submodelIndex = 9;
		dataID = POWERUP_ID::SuperJump;
	}
	
	
}// determineDataID


void
CTSPowerUp::declareDisposable(void)
{
	
	// Since we clearly weren't spawned by the map for this method to be called,
	// we need to do what "Respawn" would.  The would-be constructor stuff.
	CustomInit();
	
	this.classname = "remove_me";
	
	// TODO - decrease alpha slowly until the epiretime is up?
	// It's really bizarre original TS did that, but hey.  We don't have to replicate every little detail,
	// or if we greatly prefer whatever working a different way.
	// ALSO - the # seconds is an assumtpion, original powerup expire time not known yet.
	this.expireTime = time + 30;
	
	
	// actually not needed.  Things with the "remove_me" classname are deleted,
	// so there is never a chance to see this has the flag and respawn it.
	// Then again deletions can be delayed.  Maybe it's not a problem if entities 
	// with 'remove' called on them are exempt from searches in the same frame?
	// ehhh... let's just play it safe and do this then.
	
	
	// IAWEJGFAWEIFJAWEIA
	entityRemoveRespawnFlag(this);
	
	
}// declareDisposable



#endif


#ifdef CLIENT

class CTSPowerUp:CBaseEntity{
	
	//key values?
	pwuptype_choice m_ePwuptype;
	int m_iPwupduration;
	string m_strMessage;
	
	// What member of ary_powerupData do I get my behavior/model/etc. from?
	POWERUP_ID dataID;
	BOOL alreadyPickedUp;
	
	void(void) CTSPowerUp;
	static void(void) precache;
	virtual void(void) Initialized;
	virtual void(void) updateAnim;
	virtual void(string strField, string strKey) SpawnKey;
	
	virtual float(void) predraw;
	
	// Change to customphysics to override that without needing to hook it up
	// at startup, if this is ever needed?
	//virtual void(void)Physics;
	
	//virtual void(void)think;
};



void
CTSPowerUp::CTSPowerUp(void)
{
}


// Use me instead for startup stuff expected after reading spawnflags.
void
CTSPowerUp::Initialized(void)
{
	//base method is empty, this is pointless
	//CBaseEntity::Initialized();
	
	// until the server tells us!
	dataID = POWERUP_ID::NONE;
	
	this.frame = 0;
	//this.baseframe = 0;

	this.alreadyPickedUp = FALSE;
	
	
	this.classname = "ts_powerup";
	this.owner = world;


	//this.customphysics = Empty;
	// no use for customphysics, right?
	// so the client and server can do this? interesting.
	// looks like serverside is much more common though.
	// if we ever do customphysics, "frametime" may be good to use.
	// also, "runstandardplayerphysics(self)".   the snark's a good reference.
	
	// not helpful here unfortunately.
	//this.think = updateAnim;
	//this.nextthink = time + (31-1)/50;
	
	//CTSPowerUp selfRef = this;
	
}// Initialized




void
CTSPowerUp::updateAnim(void)
{
	
	//this.lerpfrac = 1;
	//this.baseframe1time = 0;
	//this.frame1time = 0;
	//printfline("CTSPowerUp::updateAnim %0.2f", this.frame1time);
	//this.frame1time += clframetime;
	
	//resets the anim frame.
	this.frame1time = 0;
	
	
	// Resetting the anim slightly before the marked frame end stops it from appearing to 
	// stall near the end.
	// Unsure if this is a goldsource/FTE engine difference, but this was a nice exercise
	// in a server/client interaction with an entity (or it's representative clone?)
	// besides the player.
	// Decals are a good source for that too though.
	this.think = updateAnim;
	this.nextthink = time + (31-1)/20 - 0.005;
	//this.nextthink = time + 0.017;
	//this.nextthink = time + 0.0;
	
}// restartAnim




void
Powerup_Parse(void)
{
	
	CTSPowerUp selfRef;

	/* convert us to an object of type decal */
	
	// Keep in mind, this is just clientside.  The server could really tell us to remove
	// ourselves if needed.
	if(self.classname != "ts_powerup"){
		//is this really persistent?
		//printfline("ts_powerup: Powerup_Parse. MY CLASSNAME IS INCORRECT: %s", self.classname);
		spawnfunc_CTSPowerUp();
		self.classname = "ts_powerup";
	}
	
	selfRef = (CTSPowerUp)self;

	BOOL mem_alreadyPickedUp = selfRef.alreadyPickedUp;




	// TEST.  we probably don't need this.
	// oh, not possible for the client... go figure.
	//selfRef.pvsflags = PVSF_NOREMOVE;
	
	selfRef.origin[0] = readcoord();
	selfRef.origin[1] = readcoord();
	selfRef.origin[2] = readcoord();

	selfRef.angles[0] = readcoord();
	selfRef.angles[1] = readcoord();
	selfRef.angles[2] = readcoord();
	
	selfRef.dataID = readbyte();
	selfRef.alreadyPickedUp = readbyte();
	BOOL isRespawnCall = readbyte();
	
	//selfRef.dataID = readbyte(
	//setmodel( entTarget, NULL );
	//entTarget.modelindex = 0;  //This may be redundant with above.
	
	
	//selfRef.modelIndex = 0;
	
	//selfRef.lerpfrac = 1;
	
	
	
	
	selfRef.frame = 0;
	//selfRef.frame1time += frametime;   ???
	//selfRef.frame1time = 0;  resets the anim to frame 0.
	
	
	//selfRef.baseframe = 0;
	
	//selfRef.baseframe1time += 0.1;
	
	
	if(isRespawnCall || (!selfRef.alreadyPickedUp && (mem_alreadyPickedUp != selfRef.alreadyPickedUp))){
		// forcively respawned, or appearing since being hidden?  Force animation time to 0 (start at beginning)
		selfRef.frame1time = 0;
		selfRef.think = CTSPowerUp::updateAnim;
		selfRef.nextthink = time + (31-1)/20 - 0.005;
	}
	
	
	
	if(!selfRef.alreadyPickedUp){
		
		if(mem_alreadyPickedUp != selfRef.alreadyPickedUp){
			//...  (script moved to above)
		}
		
		// display as usual.
		setmodel( selfRef, POWERUP_MODEL_PATH);
		
		powerupdata_basic_t powerupRef = *(ary_powerupData[selfRef.dataID]);
		int mySubmodel = powerupRef.iSubmodelChoice;
		
		setcustomskin(selfRef, "", sprintf("geomset 0 %i", mySubmodel));
	}else{
		// Player touched me?  Blank me!
		setmodel( selfRef, "" );
		selfRef.modelindex = 0;
		selfRef.think = NULL;
		selfRef.nextthink = 0;
	}
	
	
	//selfRef.customphysics = CTSPowerUp::Physics;
	//selfRef.think = CTSPowerUp::Think;
	//selfRef.nextthink = time + 0;
	
	// unnecessary.
	//selfRef.predraw = CTSPowerUp::predraw;
	
	// Why do we have to do this in Powerup_Parse and not just once in "Initialized?"
	selfRef.drawmask = MASK_ENGINE;
	
	
}// Powerup_Parse



float
CTSPowerUp::predraw(void)
{
	CTSPowerUp selfRef = (CTSPowerUp)self;
	
	selfRef.frame1time += clframetime;
	
		
	//adddecal(selfRef.m_strShader, selfRef.origin, selfRef.mins, selfRef.maxs, selfRef.color, 1.0f);
	addentity(selfRef);
	return PREDRAW_NEXT;
}


/*
void CTSPowerUp::Physics(void){
	
	this.frame1time += clframetime;
	
}// Physics

void CTSPowerUp::Think(void){
	
	this.frame1time += clframetime;
	this.nextthink = time + 0;
	
}// Physics
*/



void
CTSPowerUp::SpawnKey(string strField, string strKey)
{
	//printfline("SpawnKey:: CTSPowerUp: (%s: %s)", strField, strKey);

	switch (strField) {
		case "pwuptype":
			m_ePwuptype = stoi(strKey);
		break;
		case "pwupduration":
			m_iPwupduration = stoi(strKey);
		break;
		case "message":
			m_strMessage = strKey;
		break;
		
		
		// Just leave this disabled, only hinders us.
		// Way easier to force these things, constants work fine above.
			/*
		case "shader":
			//m_strSprite = strKey;
			//precache_pic(m_strSprite);
			//m_vecSize = drawgetimagesize(m_strSprite) / 2;
			break;
		case "model":
			//m_strSprite = sprintf("%s_0.tga", strKey);
			//m_vecSize = drawgetimagesize(m_strSprite) / 2;
			break;
		case "scale":
			//m_flScale = stof(strKey);
			break;
		case "rendercolor":
		case "rendercolour":
			//m_vecColor = stov(strKey) / 255;
			break;
		case "renderamt":
			//m_flMaxAlpha = stof(strKey) / 255;
			break;
		*/
		default:
			CBaseEntity::SpawnKey(strField, strKey);
	}
}


	
#endif


// SHARED?
void
CTSPowerUp::precache(void)
{
	precache_model(POWERUP_MODEL_PATH);
}


// ent name on maps is ts_powerup
void
ts_powerup(void)
{
	spawnfunc_CTSPowerUp();
}
