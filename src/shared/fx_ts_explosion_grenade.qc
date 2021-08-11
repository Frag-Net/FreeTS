
// TS-grenade explosion, not to be confused with the default HL one
// (FX_Explosion).  Referring to the Valve one instead by file, no
// need to fork that.


#ifdef CLIENT
var int FX_TS_EXPLOSION_PARTICLE;

void
FX_TS_Explosion_Grenade_Init(void)
{
	//Sound_Precache("fx.ts_explosion_grenade");
	FX_TS_EXPLOSION_PARTICLE = particleeffectnum("ts_fx_explosion_grenade.explosion_grenade");
}

#else

// sound only
void
FX_TS_Explosion_Grenade_Init(void)
{
	Sound_Precache("fx.ts_explosion_grenade");
}

#endif


// TS uses a unique explosion for grenades, but still retains the default
// HL explosion + sound for other things like map-driven events
// (see shooting the explosives barrel in the basement of ts_bikini.bsp).
// Unsure if anything else uses this same effect.
void
FX_TS_Explosion_Grenade(vector vecPos)
{
#ifdef SERVER
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EVENT_TS::FX_TS_EXPLOSION_GRENADE);
	WriteCoord(MSG_MULTICAST, vecPos[0]); 
	WriteCoord(MSG_MULTICAST, vecPos[1]); 
	WriteCoord(MSG_MULTICAST, vecPos[2]);
	msg_entity = self;
	multicast(vecPos, MULTICAST_PVS);
#else
	pointparticles(FX_TS_EXPLOSION_PARTICLE, vecPos, [0,0,0], 1);
	// uh-oh, no generated entity to play the sound on.
	// Leaving it up to the greande itself to do that then
	
	// oh wait would this work?
	// The FTE built-in method pointsound that this leads to does not support pitch-shift.
	// Because... FTE.  So, no.  Grenade explosion sounds come pitch-shifted and have
	// to be adjusted to play normally
	//Sound_PlayAt(vecPos, "fx.ts_explosion_grenade");
	
#endif
}


#ifdef SERVER
// call me around a FX_TS_Explosion_Grenade call in TS_GrenadeProjectile
void
FX_TS_Explosion_Grenade_PlaySound(entity eSelf){
	//Sound_Play(eSelf, CHAN_WEAPON, "fx.ts_explosion_grenade");
	
	// if we're not using the sound-script, do it by a manual call
	//Client_ShakeOnce(vector pos, float radius, float duration, float frequency, float amplitude)
	
	// there is a command, soundlength("x") that takes a path to a .wav file I think?
	// Probably unnecessary
	Client_ShakeOnce(eSelf.origin, 512, 1.7, 2.1, 3.4);

	float randomChoice = random();
	if(randomChoice < 0.2){
		SoundPitched_Channel_Send(eSelf, SNDP_EXPLODE, CHAN_AUTO);
	}else if(randomChoice < 0.4){
		SoundPitched_Channel_Send(eSelf, SNDP_EXPLODE1, CHAN_AUTO);
	}else if(randomChoice < 0.6){
		SoundPitched_Channel_Send(eSelf, SNDP_EXPLODE2, CHAN_AUTO);
	}else if(randomChoice < 0.8){
		SoundPitched_Channel_Send(eSelf, SNDP_EXPLODE3, CHAN_AUTO);
	}else{
		SoundPitched_Channel_Send(eSelf, SNDP_EXPLODE4, CHAN_AUTO);
	}
}
#endif

