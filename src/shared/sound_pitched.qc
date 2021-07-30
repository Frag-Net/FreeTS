/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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

typedef enum
{
	SNDP_AK47,
	SNDP_AKIMBOCOLTS,
	SNDP_BARRETTM82,
	SNDP_M3_FIRE,
	SNDP_BERETTA,
	SNDP_BERETTA_SIL,
} sfx_pitched_t;


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

#ifdef CLIENT
/* TODO: add the rest */
const string sfx_pitched_s[] =
{
	"weapons/ak47/fire.wav",
	"weapons/gold/gold-fire.wav",
	"weapons/barrett/fire.wav",
	"weapons/m3/m3-fire.wav",
	"weapons/beretta/fire.wav",
	"weapons/beretta/fire-sil.wav"
};

void
SoundPitched_Receive(void)
{
	entity ent = findfloat(world, entnum, readentitynum());
	int id = readbyte();

	if (ent)
		sound(ent, CHAN_WEAPON, sfx_pitched_s[id], 1.0f, ATTN_NORM, 400, SOUNDFLAG_FOLLOW);
}
#endif
