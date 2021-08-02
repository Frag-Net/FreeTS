
// New file.

// Try copying from _base/shared/effects.c.  From the up to date repository
// or the old one, dunno.
// ...this comment has aged terribly.
// No clue, these effects are due for a complete overhaul to better resemble
// TS sometime anyway.

#ifdef SSQC
void Effect_Explosion(vector vecOrigin )
{
	//the specialists explosion does not do this, strangely enough.
	//Decals_PlaceScorch(vecOrigin);
		
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte( MSG_MULTICAST, EVENT_TS::EFFECT_EXPLOSION );
	WriteCoord( MSG_MULTICAST, vecOrigin[0] );
	WriteCoord( MSG_MULTICAST, vecOrigin[1] );
	WriteCoord( MSG_MULTICAST, vecOrigin[2] );

	msg_entity = world;
	multicast( vecOrigin, MULTICAST_PVS );

}
#else
void EV_Effect_Explosion(vector vecOrigin ){
	pointparticles( PART_EXPLOSION, vecOrigin, [0,0,0], 1 );
}
#endif



#ifdef SSQC
//TAGGG - Thank you The Wastes!
void Effect_ScreenShake(vector vecOrigin, float fRadius, float fStrength )
{
	entity eDChain = findradius( vecOrigin, fRadius );
	while( eDChain ) {
		if ( eDChain.classname == "player" ) {
			float fDiff = vlen( vecOrigin - eDChain.origin );
				
			fDiff = ( fRadius - fDiff ) / fRadius;
			fStrength = fStrength * fDiff;
	
			if ( fDiff > 0 ) {
				WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
				WriteByte( MSG_MULTICAST, EVENT_TS::EFFECT_SHAKE );
				WriteByte( MSG_MULTICAST, (int)fStrength );
				
				msg_entity = eDChain;
				multicast( [0,0,0], MULTICAST_ONE );
			}
		}
		eDChain = eDChain.chain;
	}
}
#else
//void EV_Effect_ScreenShake(vector vecOrigin, float fRadius, float fStrength ){
// no, works a bit differently.
void EV_Effect_ScreenShake(int iType){
	
	View_ShakeCreate( iType );
}
#endif




//TAGGG - for the specialists, redirecting this to some other logic.
void
Effect_CreateExplosion(vector vPos)
{
	
	
#ifdef TS

#ifdef SSQC
	Effect_ScreenShake( vPos, 2048, 255 );
	Effect_Explosion( vPos + [0,0,16] );
#else
	printfline("WARNING!!!  Effect_CreateExplosion called clientside, but not supposed to be!");
#endif

#else
	
/*
#ifdef SERVER
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_EXPLOSION);
	WriteCoord(MSG_MULTICAST, vecPos[0]); 
	WriteCoord(MSG_MULTICAST, vecPos[1]); 
	WriteCoord(MSG_MULTICAST, vecPos[2]);
	msg_entity = self;
	multicast(vecPos, MULTICAST_PVS);
#else
	Decals_Place(vecPos, sprintf("{scorch%d", floor(random(1,4))));
	vecPos[2] += 48;
	env_sprite eExplosion = spawn(env_sprite);
	setorigin(eExplosion, vecPos);
	setmodel(eExplosion, "sprites/fexplo.spr");
	sound(eExplosion, CHAN_WEAPON, sprintf("weapons/explode%d.wav", floor(random() * 3) + 3), 1, ATTN_NORM);

	//eExplosion.think = FX_Explosion_Animate;
	eExplosion.effects = EF_ADDITIVE;
	eExplosion.drawmask = MASK_ENGINE;
	eExplosion.maxframe = modelframecount(eExplosion.modelindex);
	eExplosion.loops = 0;
	eExplosion.framerate = 20;
	eExplosion.nextthink = time + 0.05f;

	pointparticles(FX_EXPLOSION_MAIN, vecPos, [0,0,0], 1);
	pointparticles(FX_EXPLOSION_BS, vecPos, [0,0,0], 1);
#endif
*/

#endif


}




