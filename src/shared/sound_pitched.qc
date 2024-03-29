/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */ 


// Some sounds are not pitched down, don't involve in this system!
// All knife sounds, karate sounds, shotgun pump sounds, and all
// katana sounds except miss and miss1 are pitched normally in the
// as-is sound files.


//#define SOUNDPITCHED_SEND_ALL_DEBUG


void
SoundPitched_Send(entity ent, int id)
{
#ifdef SERVER
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EVENT_TS::SOUNDPITCHED);
	WriteEntity(MSG_MULTICAST, ent); 
	WriteByte(MSG_MULTICAST, id); 

	msg_entity = ent;
	multicast(ent.origin, MULTICAST_PHS);
#endif
}

// like above, but takes the channel to play on
// Could be cloned per channel as there are not many channels that need to be
// pick-able.
void
SoundPitched_Channel_Send(entity ent, int id, float chan)
{
#ifdef SERVER
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EVENT_TS::SOUNDPITCHED_CHANNEL);
	WriteEntity(MSG_MULTICAST, ent); 
	WriteByte(MSG_MULTICAST, id); 
	WriteByte(MSG_MULTICAST, (int)chan); 

	msg_entity = ent;
	multicast(ent.origin, MULTICAST_PHS);
#endif
}



#ifdef CLIENT
const string sfx_pitched_s[] =
{
	"weapons/ak47/fire.wav",
	"weapons/gold/gold-fire.wav",
	"weapons/barrett/fire.wav",
	"weapons/m3/m3-fire.wav",
	"weapons/beretta/fire.wav",
	"weapons/beretta/fire-sil.wav",
	"weapons/contender/fire.wav",
	"weapons/deagle/fire.wav",
	"weapons/deagle/fire-sil.wav",
	"weapons/fnh/fnh-fire.wav",
	"weapons/fnh/fnh-fire-sil.wav",
	"weapons/glock/glock-fire.wav",
	"weapons/glock/glock-fire-sil.wav",
	"weapons/glock22/glock22-fire.wav",
	"weapons/glock22/glock22-fire-sil.wav",
	"weapons/pdw/fire.wav",
	"weapons/pdw/fire-sil.wav",
	"weapons/katana/miss.wav",
	"weapons/katana/miss1.wav",
	"weapons/m4/m4-fire.wav",
	"weapons/m4/m4-fire-sil.wav",
	"weapons/m16/fire.wav",
	"weapons/m60/m60-fire.wav",
	"weapons/mac10/mac10-fire.wav",
	"weapons/mac10/mac10-fire-sil.wav",
	"weapons/uzi/uzi-fire.wav",
	"weapons/uzi/uzi-fire-sil.wav",
	"weapons/mossberg/fire.wav",
	"weapons/mp5k/mp5k-fire.wav",
	"weapons/mp5k/mp5k-fire-sil.wav",
	"weapons/mp5sd/mp5sd-fire.wav",
	"weapons/bull/fire01.wav",
	"weapons/ruger/fire.wav",
	"weapons/sawedoff/fire.wav",
	"weapons/skorpion/fire.wav",
	"weapons/mk23/mk23-fire.wav",
	"weapons/mk23/mk23-fire-sil.wav",
	"weapons/spas12/spas12-fire.wav",
	"weapons/aug/aug-fire.wav",
	"weapons/aug/aug-fire-sil.wav",
	"weapons/tmp/fire.wav",
	"weapons/tmp/fire-sil.wav",
	"weapons/ump/ump-fire.wav",
	"weapons/ump/ump-fire-sil.wav",
	"weapons/usas/usas-fire.wav",
	"explo/explode.wav",
	"explo/explode1.wav",
	"explo/explode2.wav",
	"explo/explode3.wav",
	"explo/explode4.wav"
};

void
SoundPitched_Receive(void)
{
	entity ent = findfloat(world, entnum, readentitynum());
	int id = readbyte();
	
	//printfline("SoundPitched_Receive %i:%s", id, sfx_pitched_s[id]);

	if (ent)
		sound(ent, CHAN_WEAPON, sfx_pitched_s[id], 1.0f, ATTN_NORM, 400, SOUNDFLAG_FOLLOW);
}


#ifndef SOUNDPITCHED_SEND_ALL_DEBUG
void
SoundPitched_Channel_Receive(void)
{
	entity ent = findfloat(world, entnum, readentitynum());
	int id = readbyte();
	float chan = (float)readbyte();
	
	if (ent)
		sound(ent, chan, sfx_pitched_s[id], 1.0f, ATTN_NORM, 400, SOUNDFLAG_FOLLOW);
}


#else
	
// ISSUE: sounds seem to play only for the entity that called for
// the message to be played from serverside.  If it's a spawned entity
// (like a grenade sending itself to make the explosion sound), no player
// can hear it.  No idea if adjusting the volume to go lower the distance
// the listener is from the source (also considering attenuation) is a good
// idea.

// DEBUG VERSION: with the 'ent-search' requirement removed, this plays
// for any listening player nearby, which the greande explosion sound
// definitely wants.  Although I would think most firing sounds should
// be heard by other players too.
void
SoundPitched_Channel_Receive(void)
{
	printfline("---SoundPitched_Channel_Receive");
	
	float myEntNum = readentitynum();
	entity ent = findfloat(world, entnum, myEntNum);
	int id = readbyte();
	float chan = (float)readbyte();
	
	printfline("recventnum:%d self.cln:%s myentnum:%d", myEntNum, self.classname, self.entnum);
	printfline("ent found? %i", (int)(ent != NULL));
	
	//if (ent)
	//	sound(ent, chan, sfx_pitched_s[id], 1.0f, ATTN_NORM, 400, SOUNDFLAG_FOLLOW);
	sound(self, chan, sfx_pitched_s[id], 1.0f, ATTN_NORM, 400, SOUNDFLAG_FOLLOW);
}

#endif// SOUNDPITCHED_SEND_ALL_DEBUG

#endif// CLIENT
