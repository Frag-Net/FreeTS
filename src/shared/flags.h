/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

//TAGGG - NOTE.  These are used for the "gflags" variable on all (most?) entities.
// the "flags" variable uses the ones from nuclide defines instead and should not be used with any 
// new constants, or ones not already in nuclide's own src/shared/flags.
// So here can start over counting from bit #0 because it uses a new var, gflags instead of flags.

// ALSO... nuclide depends on the GF_SEMI_TOGGLED constant being defined somewhere in the gamemod?
// If not any mentions of it in nuclide's src or base/src files that happen to be included 
// (base/src/shared/weapons_common.qc comes to mind) will cause errors.
// Strange as gflags should be handled by the gamemod only.

// There is also a new var called "identity" in CBaseEntity, part of Nuclide now.
// identity can be set to "1", and it looks like it is for everything ever made in Nuclide.
// It signifies that the entity can be respawned if the server is looking for things to call
// ".Respawn" on.
// Making a constant here to make that easier to spot when used here.

#define IDENTITY_CANRESPAWN	(1<<0)


// Also, no GF_CANRESPAWN anymore.  Was used in the old base, now using the IDENTITY_CANRESPAWN thing above.



/* game flags */
#define GF_SEMI_TOGGLED		(1<<0)
// TAGGG - added for secondary to also be able to tell if this
// is the first frame being pressed.  Needs to be involved a tiny bit
// manually as this one wasn't part of Nuclide.
#define GF_SEMI_SECONDARY_TOGGLED			(1<<1)
#define GF_UNUSED3			(1<<2)
#define GF_UNUSED4			(1<<3)
#define GF_UNUSED5			(1<<4)
#define GF_UNUSED6			(1<<5)
#define GF_UNUSED7			(1<<6)
#define GF_UNUSED8			(1<<7)
#define GF_UNUSED9			(1<<8)
#define GF_UNUSED10			(1<<9)
#define GF_UNUSED11			(1<<10)
#define GF_UNUSED12			(1<<11)
#define GF_UNUSED13			(1<<12)
#define GF_UNUSED14			(1<<14)
#define GF_UNUSED15			(1<<16)
#define GF_UNUSED16			(1<<13)
#define GF_UNUSED17			(1<<17)
#define GF_UNUSED18			(1<<18)
#define GF_UNUSED19			(1<<19)
#define GF_UNUSED20			(1<<20)
#define GF_UNUSED21			(1<<21)
#define GF_UNUSED22			(1<<22)
#define GF_UNUSED23			(1<<23) 
