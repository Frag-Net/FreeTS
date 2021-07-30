
// NOTE - this was not a type in the original TS, just seemed convenient to make.

//class TSThrownProjectile;


class TSThrownProjectile : TSWorldGun{

	void(void) TSThrownProjectile;
	virtual void() Think;
	virtual void() Touch;
	virtual void() PlayerUse;
	static TSThrownProjectile (player arg_player, int arg_weaponID) generate;
	static TSThrownProjectile (player arg_player, weapondynamic_t dynaRefPRE) generate2;
	
	virtual void (player arg_player, int arg_weaponID) copyFrom;
	virtual void (player arg_player, weapondynamic_t tempRef) copyFrom2;
	
	virtual void (player arg_player, int arg_weaponID) copyTo;
	
	virtual void (BOOL becomeStuck, optional vector dir, optional entity stuckTo, BOOL touchedBreakableGlass)becomePickupable;
	
	// Like FTE's supplied 'owner' field, but for keeping track of who threw this knife after
	// the 'owner' field gets reset to still keep track of who should be blamed for damage inflicted.
	entity m_owner;
	
	float startAngularVelocityDelay;
	//vector vPreviousVelocity;
	
	float forceBecomePickupableTime;
	
	vector queuedVelocity;
	float queuedVelocityApplyTime;
	float switchToNormalPickupBoundsTime;
};

