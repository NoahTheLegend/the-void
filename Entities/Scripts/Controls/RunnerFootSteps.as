#define CLIENT_ONLY

#include "RunnerCommon.as"
#include "CustomBlocks.as";
#include "UtilityChecks.as";
#include "RayCasts.as";

void onInit(CSprite@ this)
{
	// this.getCurrentScript().runFlags |= Script::tick_onground;
	this.getCurrentScript().runFlags |= Script::tick_not_inwater;
	this.getCurrentScript().runFlags |= Script::tick_moving;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	// no playing sound if it's in shadow
	if (!blob.isMyPlayer() && !inProximity(blob, getLocalPlayerBlob()))
		return;

	const bool left		= blob.isKeyPressed(key_left);
	const bool right	= blob.isKeyPressed(key_right);
	const bool up		= blob.isKeyPressed(key_up);
	const bool down		= blob.isKeyPressed(key_down);

	if (
		(blob.isOnGround() && (left || right)) ||
		(blob.isOnLadder() && (left || right || up || down))
	) {
		RunnerMoveVars@ moveVars;
		if (!blob.get("moveVars", @moveVars))
		{
			return;
		}
		if ((blob.getNetworkID() + getGameTime()) % (moveVars.walkFactor < 1.0f ? 14 : 8) == 0)
		{
			f32 volume = Maths::Min(0.1f + blob.getShape().vellen * 0.1f, 1.0f);
			TileType tile = blob.getMap().getTile(blob.getPosition() + Vec2f(0.0f, blob.getRadius() + 4.0f)).type;
			TileType up_tile = blob.getMap().getTile(blob.getPosition() + Vec2f(0.0f, blob.getRadius() - 4.0f)).type;

			f32 pitch = 1.0f;
			CMap@ map = blob.getMap();
			
			if (map.isTileCastle(tile))
			{
				this.PlayRandomSound("concrete_run", Maths::Min(0.3f, volume), pitch);
			}
			else if (map.isTileWood(tile))
			{
				pitch = 1.1f + XORRandom(150) * 0.001f;
				this.PlayRandomSound("wood_walk", Maths::Min(0.3f, volume), pitch);
			}
			else if (isMetalTile(tile))
			{
				this.PlayRandomSound("metalbar_run", Maths::Min(0.3f, volume), pitch);
			}
			else if (blob.isOnLadder())
			{
				f32 pitch = 0.75f + XORRandom(10) / 20.0f; //0.75f - 1.25f
				//this.PlaySound("/WoodHeavyBump1", volume, pitch);
				//replace with metal ladder
			}
		}
	}
}