//fall damage for all characters and fall damaged items
// apply Rules "fall vel modifier" property to change the damage velocity base

#include "Hitters.as";
#include "KnockedCommon.as";
#include "FallDamageCommon.as";
#include "CustomBlocks.as";
#include "UtilityChecks.as";

const u8 knockdown_time = 12;

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickIfTag = "dead";
}
void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (!solid || this.isInInventory() || this.hasTag("invincible"))
	{
		return;
	}

	if (blob !is null && (blob.hasTag("player") || blob.hasTag("no falldamage")))
	{
		return; //no falldamage when stomping
	}

	Vec2f vel = this.getOldVelocity();
	bool playsound = true;

	if (vel.Length() < 0.1f) { return; }

	f32 damage = FallDamageAmount(vel.Length());
	if (damage != 0.0f) //interesting value
	{
		bool doknockdown = true;
		if (damage > 0.0f)
		{
			// check if we aren't touching a trampoline
			CBlob@[] overlapping;

			if (this.getOverlapping(@overlapping))
			{
				for (uint i = 0; i < overlapping.length; i++)
				{
					CBlob@ b = overlapping[i];

					if (b.hasTag("no falldamage"))
					{
						return;
					}
				}
			}

			if (damage > 0.1f)
			{
				this.server_Hit(this, point1, normal, damage, Hitters::fall);
			}
			else
			{
				doknockdown = false;
			}
		}

		if (doknockdown)
			setKnocked(this, knockdown_time);

		if (!this.hasTag("should be silent") && playsound)
		{				
			if (this.getHealth() > damage) //not dead
				playSoundInProximity(this, "/BreakBone", 1.0f, 1.0f);
			else
				playSoundInProximity(this, "/FallDeath", 1.0f, 1.0f);
		}
	}
}

void onTick(CBlob@ this)
{
	this.Tag("should be silent");
	this.getCurrentScript().tickFrequency = 0;
}
