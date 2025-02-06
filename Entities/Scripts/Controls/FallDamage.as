//fall damage for all characters and fall damaged items
// apply Rules "fall vel modifier" property to change the damage velocity base

#include "Hitters.as";
#include "KnockedCommon.as";
#include "FallDamageCommon.as";
#include "CustomBlocks.as";

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

	f32 vely = this.getOldVelocity().y;
	bool playsound = true;

	if (vely < 0 || Maths::Abs(normal.x) > Maths::Abs(normal.y) * 2) { return; }

	f32 damage = FallDamageAmount(vely);
	if (damage != 0.0f) //interesting value
	{
		bool doknockdown = true;

		if (vely*this.getMass() > 500)
    	{
    	    point1 = point1+Vec2f(0, 4);

    	    CMap@ map = getMap();
    	    if (map !is null)
    	    {
    	        TileType tc = map.getTile(point1).type;
    	        TileType tl = map.getTile(point1-Vec2f(8,0)).type;
    	        TileType tr = map.getTile(point1+Vec2f(8,0)).type;
    	        if (isServer() && (isTileIce(tc) || isTileExposure(tc)))
    	        {
    	            TileType utc = map.getTile(point1+Vec2f(0,8)).type;
    	            TileType utl = map.getTile(point1-Vec2f(8,-8)).type;
    	            TileType utr = map.getTile(point1+Vec2f(8,8)).type;
	
    	            if (!isSolid(map, utc))
    	                for (u8 i = 0; i < 4; i++) {map.server_DestroyTile(point1, 15.0f, this);}
    	            if (isTileIce(tl) && !isSolid(map, utl))
    	                for (u8 i = 0; i < 4; i++) {map.server_DestroyTile(point1-Vec2f(8,0), 15.0f, this);}
    	            if (isTileIce(tr) && !isSolid(map, utr))
    	                for (u8 i = 0; i < 4; i++) {map.server_DestroyTile(point1+Vec2f(8,0), 15.0f, this);}
    	        }
    	        else if (isTileSnow(tc) || isTileExposure(tc))
    	        {
					damage = 0.0f;
					playsound = false;
					
					if (isServer())
					{
						TileType atc = map.getTile(point1+Vec2f(0,-8)).type;
    	            	TileType atl = map.getTile(point1-Vec2f(8,8)).type;
    	            	TileType atr = map.getTile(point1+Vec2f(8,-8)).type;

    	            	if (!isSolid(map, atc))
    	            	    for (u8 i = 0; i < 3; i++) {map.server_DestroyTile(point1, 15.0f, this);}
    	            	if (isTileSnow(tl) && !isSolid(map, atl))
    	            	    for (u8 i = 0; i < 3; i++) {map.server_DestroyTile(point1-Vec2f(8,0), 15.0f, this);}
    	            	if (isTileSnow(tr) && !isSolid(map, atr))
    	            	    for (u8 i = 0; i < 3; i++) {map.server_DestroyTile(point1+Vec2f(8,0), 15.0f, this);}
					}
    	        }
    	    }
    	}

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
				Sound::Play("/BreakBone", this.getPosition());
			else
			{
				Sound::Play("/FallDeath.ogg", this.getPosition());
			}
		}
	}
}

void onTick(CBlob@ this)
{
	this.Tag("should be silent");
	this.getCurrentScript().tickFrequency = 0;
}
