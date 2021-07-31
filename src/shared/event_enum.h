

// Best to avoid choices redundant with those offered by Nuclide.
// Not sure if EXPLOSION and SHAKE are already provided.
enum EVENT_TS{
	SPAWN = EV_SEPARATOR,
	RESET_VIEW_MODEL,
	RESET_PLAYER,
	PLAYER_DEATH,
	EFFECT_EXPLOSION,
	EFFECT_SHAKE,
	DROP_WEAPON,
	// NEW.  Like EV_IMPACT but to paint a decal only.
	EV_PLACEDECAL,
	EV_IMPACT_MELEE,
	SOUNDPITCHED,
	TEST,
};

