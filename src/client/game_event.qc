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

void
ClientGame_EventParse(float fHeader)
{
	player pl = (player)pSeat->m_ePlayer;
	
	// !
	// Any need for a m_ePlayer classname check here?
	// I think none apply for being an authentic "spectator", most don't for being a
	// buymenu spectator (player with that is not PLAYER_STATE::SPAWNED)
	
	switch(fHeader){
	case EV_OBITUARY:{
		Obituary_Parse();
	}break;
	case EV_SPARK:{
		vector vSparkPos, vSparkAngle;
		vSparkPos[0] = readcoord();
		vSparkPos[1] = readcoord();
		vSparkPos[2] = readcoord();
		vSparkAngle[0] = readcoord();
		vSparkAngle[1] = readcoord();
		vSparkAngle[2] = readcoord();
		FX_Spark(vSparkPos, vSparkAngle);
	}break;
	case EV_GIBHUMAN:{
		vector vGibPos;
		vGibPos[0] = readcoord();
		vGibPos[1] = readcoord();
		vGibPos[2] = readcoord();
		FX_GibHuman(vGibPos);
	}break;
	case EV_BLOOD:{
		vector vBloodPos;
		vector vBloodColor;

		vBloodPos[0] = readcoord();
		vBloodPos[1] = readcoord();
		vBloodPos[2] = readcoord();

		vBloodColor[0] = readbyte() / 255;
		vBloodColor[1] = readbyte() / 255;
		vBloodColor[2] = readbyte() / 255;

		FX_Blood(vBloodPos, vBloodColor);
	}break;
	case EV_EXPLOSION:{
		vector vExploPos;

		vExploPos[0] = readcoord();
		vExploPos[1] = readcoord();
		vExploPos[2] = readcoord();

		FX_Explosion(vExploPos);
	}break;
	case EVENT_TS::FX_TS_EXPLOSION_GRENADE:{
		vector vExploPos2;

		vExploPos2[0] = readcoord();
		vExploPos2[1] = readcoord();
		vExploPos2[2] = readcoord();

		FX_TS_Explosion_Grenade(vExploPos2);
	}break;
	case EV_MODELGIB:{
		vector vecPos;
		vecPos[0] = readcoord();
		vecPos[1] = readcoord();
		vecPos[2] = readcoord();

		vector vSize;
		vSize[0] = readcoord();
		vSize[1] = readcoord();
		vSize[2] = readcoord();

		float fStyle = readbyte();
		int count = readbyte();
		FX_BreakModel(count, vecPos, vSize, [0,0,0], fStyle);
	}break;
	case EV_IMPACT:{
		int iType;
		vector vOrigin, vNormal;

		iType = (int)readbyte();
		vOrigin[0] = readcoord();
		vOrigin[1] = readcoord();
		vOrigin[2] = readcoord();

		vNormal[0] = readcoord();
		vNormal[1] = readcoord();
		vNormal[2] = readcoord();

		FX_Impact(iType, vOrigin, vNormal);
	}break;
	case EVENT_TS::EV_IMPACT_MELEE:{
		int iType3;
		vector vOrigin3;
		vector vNormal3;

		iType3 = (int)readbyte();
		vOrigin3[0] = readcoord();
		vOrigin3[1] = readcoord();
		vOrigin3[2] = readcoord();

		vNormal3[0] = readcoord();
		vNormal3[1] = readcoord();
		vNormal3[2] = readcoord();

		FX_Impact_Melee(iType3, vOrigin3, vNormal3);
	}break;
	case EV_CHAT:{
		float fSender = readbyte();
		float fTeam = readbyte();
		string sMessage = readstring();

		CSQC_Parse_Print(sprintf("%s: %s", getplayerkeyvalue(fSender, "name"), sMessage), PRINT_CHAT);
	}break;
	case EV_CHAT_TEAM:{
		float fSender2 = readbyte();
		float fTeam2 = readbyte();
		string sMessage2 = readstring();

		CSQC_Parse_Print(sprintf("[TEAM] %s: %s", getplayerkeyvalue(fSender2, "name"), sMessage2), PRINT_CHAT);
	}break;
	case EV_CHAT_VOX:{
		Vox_Play(readstring());
	}break;
	case EV_VIEWMODEL:{
		View_PlayAnimation(readbyte());
	}break;
	case EV_WEAPON_PICKUP:{
		int w = readbyte();
		
		// NOTE!
		// Phase me out, or use me instead.  Whichever.
		// Redundant with... oh?  Nothing here clearly by name.
		// Ah well, somewhere there's completly TS independent pickup logic
		// that really shouldn't be when some portions of weapons_common.qc and
		// an existing weapon pickup object exists, I think.

		/*
		if (autocvar_cl_autoweaponswitch == 1) {
			sendevent("PlayerSwitchWeapon", "i", w);
		}
		*/

		HUD_WeaponPickupNotify(w);
	}break;
	case EVENT_TS::SPAWN:{
		// time to read the config to send in the weapons one-by-one.
		deployConfig();
		
		// Just in case.
		UI_ChangeScreen(UI_SCREEN::NONE);

		// so that any choice of weapon, same as before or even nothing, will still
		// let client/view.qc do the whole viewmodel routine again
		pSeat->m_iLastWeapon = -2;
	}break;
	case EVENT_TS::RESET_VIEW_MODEL:{
		EV_TS_resetViewModel();
	}break;
	case EVENT_TS::RESET_PLAYER:{
		int resetInventory = readbyte();
		EV_TS_resetPlayer(pl, resetInventory);
	}break;
	case EVENT_TS::PLAYER_DEATH:{
		EV_PlayerDeath();
	}break;
	case EVENT_TS::PLAYER_NOCLIP:{
		EV_PlayerNoclip();
	}break;
	case EVENT_TS::EQUIP_CALLBACK:{
		EV_EquipCallback();
	}break;
	case EVENT_TS::TEST_CALLBACK:{
		int arg_mesageID = readint();
		EV_TestCallback(arg_mesageID);
	}break;
	case EVENT_TS::SOUNDPITCHED:{
		SoundPitched_Receive();
	}break;
	case EVENT_TS::SOUNDPITCHED_CHANNEL:{
		SoundPitched_Channel_Receive();
	}break;
	/*
	// can this even happen anymore?
	// If a drop-weapon call can be signaled by the server, not shared with the
	// client and server reaching a drop call independently, then yes.
	case EVENT_TS::DROP_WEAPON:{
		EV_TS_playerDropWeapon(pl);
	}break;
	*/
	case EVENT_TS::USEITEMS_CHANGE_CALLBACK:{
		pl.clientUseItemsCallback();
	}break;
	
#if OTHER_PREDICTION_TEST == 1
	case EVENT_TS::CUSTOM_PREDICTION_CALLBACK:{
		Custom_Prediction_Server_Callback(pl);
	}break;
#endif

	case EVENT_TS::VIEWANGLES_REQUEST:{
		
		sendevent("ViewAnglesR", "fff", view_angles.x, view_angles.y, view_angles.z);
	}break;

	
	case EVENT_TS::TEST:{
		//printfline("EVENT_TS::TEST HAPPENED");
		//clearscene();
	}break;
	}
		
}
