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

int
ClientGame_ConsoleCommand(void)
{
	player pl;
	
	//printfline("ClientGame_ConsoleCommand: %s", argv(0));
	
	switch(argv(0)) {
		
	//TAGGG - is that ok?
	case "+speedcustom":
		pSeatLocal->iInputSpeed = TRUE;
		break;
	case "-speedcustom":
		pSeatLocal->iInputSpeed = FALSE;
		break;
		
	//TAGGG - NEW ONES
	case "getorigin":
		sendevent("TS_Debug_getOrigin", "");
	break;
	case "getangle":
		sendevent("TS_Debug_getAngle", "");
	break;
	case "firemode":
		TS_playerChangeFiremode();
	break;
	case "useitems":
		TS_playerUseItems();
	break;
	case "usepowerup":
		TS_playerUsePowerup();
	break;
	// I think the plus is good here then?
	// ...wait, not continuously reacted to in original TS.  I have no idea.
	// Oh well, catch the - anyway too to stop an annoying printout about that command being missing (release)
	case "+alt1":
		TS_playerCallAlt1();
	break;
	case "-alt1":
	
	break;
	//TAGGG - TODO: low priority.
	// Let holding down the coldcock key (C by default) continuously use it, just like
	// holding down primary fire to continuously fire.  Something about setting a var
	// to represent being held down or not for frame-by-frame logic to check for being on, then
	// do the 'sendevent'.  I think?
	case "+alt2":
		TS_playerCallAlt2();
		//pSeat->m_iInputAlt2 = TRUE;
	break;
	case "-alt2":
		//pSeat->m_iInputAlt2 = FALSE;
	break;
	
	case "dev_testorbituary":
	//TAGGG - CRITICAL.  Orbituary stuff...
		//HUD_AddOrbituaries(player_localnum, TEAM_T, player_localnum, TEAM_CT, floor(random(1, CS_WEAPON_COUNT)), FALSE);
		break;
		
	// CUT.
	/*
	case "minimap":
		pSeat.iMapExpand = 1 - pSeat.iMapExpand;
		break;
	case "overview_test":
		pSeat.iOverview = 1 - pSeat.iOverview;
		break;
	*/
	case "motd":
		if(getplayerkeyvalue( player_localnum, "*spec" ) != "0"){
			VGUI_ChangeScreen(VGUI_SCREEN::MOTD);
		}
		break;
	case "buy":
		//If we're in spectator mode we can do this
		//  no-screen check, not necessary probably:  pSeatLocal->fVGUI_Display == VGUI_SCREEN::NONE && 
		pl = (player)pSeat->m_ePlayer;
		
		printfline("CMD: BUY COMMAND RECEIVED!  Should I react?  %s (1=yes) : %d", getplayerkeyvalue( player_localnum, "*spec" ), pl.iState);
		
		// Should this use a "pl.iState != PLAYER_STATE::SPAWNED" check instead?
		//if(getplayerkeyvalue( player_localnum, "*spec" ) != "0"){
		if(pl.iState != PLAYER_STATE::SPAWNED){
			//we can show it!
			VGUI_ChangeScreen(VGUI_SCREEN::BUYSIDEMENU);
		}
		
		break;
	case "chooseteam":
		//VGUI_ChooseTeam();
		break;
	
	//TAGGG - CRITICAL
	// See CSEv_DropWeapon of src/server/weapons.qc, tie into that better
	// somehow, may need to rely on Nuclide's own pickup type instead of our own.
	case "drop":
		//sendevent("WeaponDrop", "");
		TS_playerDropWeapon();  //I do it fine.
		break;
	
		
		default:
		return (0);
	}
	return (1);
}
