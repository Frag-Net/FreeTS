

enum EVENT_TS{
	SPAWN = EV_SEPARATOR,
	RESET_VIEW_MODEL,
	RESET_PLAYER,
	// Is this in nuclide now?  I don't think so, verify.
	// Same for EXPLOSION / SHAKE below.  DROP_WEAPON probably is if we use
	// the nuclide way for that.
	PLAYER_DEATH,
	EFFECT_EXPLOSION,
	EFFECT_SHAKE,
	DROP_WEAPON,
	//TAGGG - NEW.  Like EV_IMPACT but to paint a decal only.
	EV_PLACEDECAL,
	EV_IMPACT_MELEE,
	SOUNDPITCHED,
	TEST,
};

