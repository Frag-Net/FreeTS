
class TS_GrenadeProjectile{
	void(void) TS_GrenadeProjectile;
	static void(void) precache;
	static TS_GrenadeProjectile(player arg_player, vector arg_vOrigin, vector arg_vThrowDir, vector arg_vPlayerForward, int arg_weaponTypeID) generate;
	virtual void(void) touch;
};
	
void TS_GrenadeProjectile_Explode(void);
