
//class CTSWorldGun;

// not inheriting from CBaseEntity... this wasn't made with that in mind,
//  and it doesn't look like it needs anything from there.
//  If there were a version of this to be respawnable, it may make sense to make it a child of
//  CBaseEntiy and then remove the GF_CANRESPAWN flag gflags added to all CBaseEntities by default
//  (I think)... since changed to the IDENTITY_CANRESPAWN flag of ".identity" for CBaseEntity's
class CTSWorldGun{

	// After being recently accessed by a player but not deleted,
	// I enforce a cooldown time before any other player (including the same one)
	// can try to pick me up again. This stops spamming inventory scans every
	// single frame if a player stands over a weapon they can't pick up.
	float accessibleCooldownTime;
	// To avoid server clutter over time, a pickup will delete itself
	float expireTime;
	
	weapondynamic_t myInfo;
	
	
	void(void) CTSWorldGun;
	virtual void() Think;
	virtual void() Touch;
	virtual void() PlayerUse;
	static CTSWorldGun (player arg_player, int arg_weaponID) generate;
	static CTSWorldGun (player arg_player, weapondynamic_t dynaRefPRE) generate2;
	
	virtual void (player arg_player, int arg_weaponID) copyFrom;
	virtual void (player arg_player, weapondynamic_t tempRef) copyFrom2;
	
	virtual void (player arg_player, int arg_weaponID) copyTo;
	
};


