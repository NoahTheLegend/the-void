#define CLIENT_ONLY

#include "Hitters.as"

void onInit(CBlob@ this)
{
	this.Tag("soft");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (damage > 0.05f) //sound for all damage
	{
		if (hitterBlob !is this)
		{
			this.getSprite().PlaySound("dig_soft", Maths::Min(1.25f, Maths::Max(0.5f, damage)));
		}

		makeGibParticle("GenericGibs", worldPoint, getRandomVelocity((this.getPosition() - worldPoint).getAngle(), 1.0f + damage, 90.0f) + Vec2f(0.0f, -2.0f),
		                2, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
	}
    return damage;
}


void onGib(CSprite@ this)
{
	this.PlaySound("dig_soft.ogg", 1.0f, 0.75f);
}