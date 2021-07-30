

#ifdef SSQC
void Effect_Explosion(vector vecOrigin );
#else
void EV_Effect_Explosion(vector vecOrigin );
#endif



#ifdef SSQC
//TAGGG - Thank you The Wastes!
void Effect_ScreenShake(vector vecOrigin, float fRadius, float fStrength );
#else
void EV_Effect_ScreenShake(int iType);
#endif



void Effect_CreateExplosion(vector vPos);
