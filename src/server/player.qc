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

/*
====================
UseWorkaround
====================
*/
void UseWorkaround(entity eTarget)
{
	eActivator = self;
	entity eOldSelf = self;
	self = eTarget;
	self.PlayerUse();
	self = eOldSelf;
}

/*
====================
Player_UseDown
====================
*/
void Player_UseDown(void)
{
	vector vecSrc;

	//TAGGG - CHECK.  Does the "self.flags & FL_USE_RELEASED" check need to be commented out?
	// Old way has it that way
	if (self.health <= 0) {
		return;
	} else if (!(self.flags & FL_USE_RELEASED)) {
		return;
	}

	makevectors(self.v_angle);
	vecSrc = self.origin + self.view_ofs;
	
	
	player pl = (player)self;

	//TAGGG - modern FreeHL way.  Replacing it with my own completely for now
	/*
	self.hitcontentsmaski = CONTENTBITS_POINTSOLID;
	traceline(vecSrc, vecSrc + (v_forward * 64), MOVE_HITMODEL, self);


	if (trace_ent.PlayerUse) {
		self.flags &= ~FL_USE_RELEASED;
		
		UseWorkaround(trace_ent);

		// Some entities want to support Use spamming
		if (!(self.flags & FL_USE_RELEASED)) {
			sound(self, CHAN_ITEM, "common/wpn_select.wav", 0.25, ATTN_IDLE);
		}
	} else {
		sound(self, CHAN_ITEM, "common/wpn_denyselect.wav", 0.25, ATTN_IDLE);
		self.flags &= ~FL_USE_RELEASED;
	}
	*/
	
	
	BOOLEAN isPickup;
	
	//TAGGG - point of interest!
	// Old way for the 2nd to last param here was MOVE_NOMONSTERS (1).
	// FreeHL's way is now MOVE_HITMODEL.  Trying that out, revert if needed
	traceline ( vecSrc, vecSrc + ( v_forward * 36 ), MOVE_HITMODEL, self );
	
	entity ef = findradius(trace_endpos, 40);
	while (ef) {
		//printfline("An entity found: %s has use? %d", ef.classname, (ef.PlayerUse!=NULL) );

		if (ef.PlayerUse != NULL) {
			
			
			vector dirTowards = normalize(ef.origin - self.origin);
			
			//TODO - how do we obtain this.  v_forward from make angles??
			vector dirFacing = v_forward;
			
			// cheap check for now, this is the only combo that has both
			// a class of "remove_me" and a 'PlayerUse' method set.
			isPickup = (ef.classname == "remove_me");
			
			//isPickup = FALSE;
			
			if(isPickup){
				//woohoo.
				//just keep trying use on anything we can.
				UseWorkaround(ef);
				//return;
			}else{
				float prod = dotproduct(dirTowards, dirFacing);
				float dist = vlen(ef.origin - self.origin);
				//printfline("use dotprod:%.2f dist:%.2f", prod, dist);
				if(prod >= 0.97 && dist < 52){
					
					UseWorkaround(ef);
				}
			}
			
			
			
		}
		ef = ef.chain;
	}
	
	
	//printfline("self.mins.z? %.2f", self.mins.z);
	//search around where the player is standing too.
	ef = findradius(self.origin + [0,0,self.mins.z], 30);
	while (ef) {
		if (ef.PlayerUse != NULL) {
			
			
			isPickup = (ef.classname == "remove_me");
			
			//isPickup = FALSE;
			
			if(isPickup){
				
				UseWorkaround(ef);
			}
			//return;
		}
		ef = ef.chain;
	}
	
	
	self.flags &= ~FL_USE_RELEASED;
	
	
}

/*
====================
Player_UseUp
====================
*/
void Player_UseUp(void) {
	if (!(self.flags & FL_USE_RELEASED)) {
		self.flags |= FL_USE_RELEASED;
	}
}

// check out TS_playerEquippedWeapon, it already does this
/*
//TAGGG - CRITICAL!  Make this work better with the inventory system.
// Changing activeweapon directly is meaningless to us, changing
/// inventoryEquippedIndex makes more sense, then activeweapon from that
// ...unless we trust that is handled anyway, but I doubt that.
void CSEv_PlayerSwitchWeapon_i(int w)
{
	player pl = (player)self;
	
	//pl.activeweapon = w;
	pl.setInventoryEquippedIndex(w);
	Weapons_Draw();
}
*/

void
Player_Precache(void)
{
	searchhandle pm;
	pm = search_begin("models/player/*/*.mdl", TRUE, TRUE);
	for (int i = 0; i < search_getsize(pm); i++) {
		precache_model(search_getfilename(pm, i));
	}
	search_end(pm);
}
