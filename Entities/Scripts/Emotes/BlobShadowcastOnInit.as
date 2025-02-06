#include "ShadowCastHooks.as"

void onInit(CBlob@ this)
{
	this.Tag("opaque");
}

// todo: should work with more than 8x8 blobs
void onTick(CBlob@ this)
{
    CMap@ map = getMap();
    if (map is null) return;

    SET_TILE_CALLBACK@ set_tile_func;
	getRules().get("SET_TILE_CALLBACK", @set_tile_func);
	if (set_tile_func !is null)
	{
		set_tile_func(map.getTileOffset(this.getPosition()), CMap::tile_castle);
	}

    if (getGameTime() > 30) this.getCurrentScript().runFlags |= Script::remove_after_this;
}