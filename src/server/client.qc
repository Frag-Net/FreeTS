/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

/* called every input frame */
void
Game_RunClientCommand(void)
{
	//TAGGG
	// FreeHL does it this way instead now (further down)?
	// I don't think this is even significant.
	// Then again clientside does its call this way too?
	// In Predict_PlayerPreFrame, which is Nuclide.
	// Yet this is within the gamemod?  Odd.
	//PMove_Run();
	
	player pl = (player)self;
	pl.Physics_Run();
}

/* client cmd overrides happen here */
void
Game_ParseClientCommand(string cmd)
{
	tokenize(cmd);

	if (argv(1) == "timeleft") {
		string msg;
		string timestring;
		float timeleft;
		timeleft = cvar("mp_timelimit") - (time / 60);
		timestring = Util_TimeToString(timeleft);
		msg = sprintf("we have %s minutes remaining", timestring);
		bprint(PRINT_CHAT, msg);
		return;
	}

	clientcommand(self, cmd);
}
