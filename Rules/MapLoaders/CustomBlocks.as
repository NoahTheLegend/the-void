
/**
 *	Template for modders - add custom blocks by
 *		putting this file in your mod with custom
 *		logic for creating tiles in HandleCustomTile.
 *
 * 		Don't forget to check your colours don't overlap!
 *
 *		Note: don't modify this file directly, do it in a mod!
 */

namespace CMap
{
	enum CustomTiles
	{
		tile_caution = tile_steel - 96,
		tile_caution_v0,
		tile_caution_v1,
		tile_caution_v2,

		tile_elderbrick = tile_steel - 80,
		tile_elderbrick_v0,
		tile_elderbrick_d0,
		tile_elderbrick_d1,
		tile_elderbrick_d2,
		tile_elderbrick_d3,
		tile_elderbrick_d4,

		tile_polishedstone = tile_steel - 64,
		tile_polishedstone_v0,
		tile_polishedstone_v1,
		tile_polishedstone_v2,
		tile_polishedstone_v3,
		tile_polishedstone_v4,
		tile_polishedstone_v5,
		tile_polishedstone_v6,
		tile_polishedstone_v7,
		tile_polishedstone_v8,
		tile_polishedstone_v9,
		tile_polishedstone_v10,
		tile_polishedstone_v11,
		tile_polishedstone_v12,
		tile_polishedstone_v13,
		tile_polishedstone_v14,
		tile_polishedstone_d0 = tile_polishedstone + 16,
		tile_polishedstone_d1,
		tile_polishedstone_d2,
		tile_polishedstone_d3,
		tile_polishedstone_d4,
		
		tile_bpolishedstone = tile_steel - 32,
		tile_bpolishedstone_v0,
		tile_bpolishedstone_v1,
		tile_bpolishedstone_v2,
		tile_bpolishedstone_v3,
		tile_bpolishedstone_v4,
		tile_bpolishedstone_v5,
		tile_bpolishedstone_v6,
		tile_bpolishedstone_v7,
		tile_bpolishedstone_v8,
		tile_bpolishedstone_v9,
		tile_bpolishedstone_v10,
		tile_bpolishedstone_v11,
		tile_bpolishedstone_v12,
		tile_bpolishedstone_v13,
		tile_bpolishedstone_v14,
		tile_bpolishedstone_d0 = tile_bpolishedstone + 16,
		tile_bpolishedstone_d1,
		tile_bpolishedstone_d2,
		tile_bpolishedstone_d3,
		tile_bpolishedstone_d4,

		tile_steel = 512,
		tile_steel_v0,
		tile_steel_v1,
		tile_steel_v2,
		tile_steel_v3,
		tile_steel_v4,
		tile_steel_v5,
		tile_steel_v6,
		tile_steel_v7,
		tile_steel_v8,
		tile_steel_v9,
		tile_steel_v10,
		tile_steel_v11,
		tile_steel_v12,
		tile_steel_v13,
		tile_steel_v14,
		tile_steel_d0 = tile_steel + 16,
		tile_steel_d1,
		tile_steel_d2,
		tile_steel_d3,
		tile_steel_d4,
		tile_steel_d5,
		tile_steel_d6,
		tile_steel_d7,
		tile_steel_d8,

		tile_bsteel = tile_steel + 32,
		tile_bsteel_v0,
		tile_bsteel_v1,
		tile_bsteel_v2,
		tile_bsteel_d0,
		tile_bsteel_d1,
		tile_bsteel_d2,
		tile_bsteel_d3,
		tile_bsteel_d4,

		tile_bglass_d0 = tile_bsteel + 15, // intended to be +15!
		tile_bglass = tile_bsteel + 16,
		tile_bglass_v0,
		tile_bglass_v1,
		tile_bglass_v2,
		tile_bglass_v3,
		tile_bglass_v4,
		tile_bglass_v5,
		tile_bglass_v6,
		tile_bglass_v7,
		tile_bglass_v8,
		tile_bglass_v9,
		tile_bglass_v10,
		tile_bglass_v11,
		tile_bglass_v12,
		tile_bglass_v13,
		tile_bglass_v14,

		tile_snow = tile_bglass + 16,
		tile_snow_v0,
		tile_snow_v1,
		tile_snow_v2,
		tile_snow_v3,
		tile_snow_v4,
		tile_snow_v5,
		tile_snow_d0,
		tile_snow_d1,
		tile_snow_d2,
		tile_snow_d3,

		tile_snow_pile = tile_snow + 16,
		tile_snow_pile_v0,
		tile_snow_pile_v1,
		tile_snow_pile_v2,
		tile_snow_pile_v3,
		tile_snow_pile_v4,
		tile_snow_pile_v5,

		tile_ice = tile_snow_pile + 16,
		tile_ice_v0,
		tile_ice_v1,
		tile_ice_v2,
		tile_ice_v3,
		tile_ice_v4,
		tile_ice_v5,
		tile_ice_v6,
		tile_ice_v7,
		tile_ice_v8,
		tile_ice_v9,
		tile_ice_v10,
		tile_ice_v11,
		tile_ice_v12,
		tile_ice_v13,
		tile_ice_v14,
		tile_ice_d0 = tile_ice + 16,
		tile_ice_d1,
		tile_ice_d2,
		tile_ice_d3,

		tile_thick_ice = tile_ice + 32,
		tile_thick_ice_v0,
		tile_thick_ice_v1,
		tile_thick_ice_v2,
		tile_thick_ice_v3,
		tile_thick_ice_v4,
		tile_thick_ice_v5,
		tile_thick_ice_v6,
		tile_thick_ice_v7,
		tile_thick_ice_v8,
		tile_thick_ice_v9,
		tile_thick_ice_v10,
		tile_thick_ice_v11,
		tile_thick_ice_v12,
		tile_thick_ice_v13,
		tile_thick_ice_v14,
		tile_thick_ice_d0 = tile_thick_ice + 16,
		tile_thick_ice_d1,
		tile_thick_ice_d2,
		tile_thick_ice_d3,

		tile_bice = tile_thick_ice + 32,
		tile_bice_v0,
		tile_bice_v1,
		tile_bice_v2,
		tile_bice_v3,
		tile_bice_v4,
		tile_bice_v5,
		tile_bice_v6,
		tile_bice_v7,
		tile_bice_v8,
		tile_bice_v9,
		tile_bice_v10,
		tile_bice_v11,
		tile_bice_v12,
		tile_bice_v13,
		tile_bice_v14,

		tile_snow_bricks = tile_bice + 16,
		tile_snow_bricks_d0,
		tile_snow_bricks_d1,
		tile_bsnow_bricks = tile_snow_bricks + 3,
		tile_bsnow_bricks_d0,
		tile_bsnow_bricks_d1
	};
};

bool isSolid(u32 type)
{
	return isSolid(getMap(), type);
}

bool isSolid(CMap@ map, u32 type) // thin ice is not solid
{
	return map.isTileSolid(type) || map.isTileGround(type) || isTileSteel(type) || isTilePolishedStone(type) || isTileCaution(type)
		|| isTileSnow(type) || isTileAnyIce(type) || isTileElderBrick(type) || isTileSnowBricks(type);
}

bool isSolid(CMap@ map, Vec2f pos)
{
	u32 type = map.getTile(pos).type;
	return isSolid(map, type);
}

bool isHardSolid(CMap@ map, u32 type) // only tiles with friction
{
	return map.isTileSolid(type) || map.isTileGround(type) || isTileSteel(type) || isTilePolishedStone(type) || isTileCaution(type) || isTileElderBrick(type) || isTileSnowBricks(type);
}

bool isHardSolid(CMap@ map, Vec2f pos) // thin ice is not solid
{
	u32 type = map.getTile(pos).type;
	return isHardSolid(map, type);
}

bool isHardSolid(u32 type)
{
	return isHardSolid(getMap(), type);
}

bool isTileExposure(u32 index) // for RoomDetector.as
{
	return index == CMap::tile_empty || isTileSnowPile(index);
}

bool isTileCaution(u32 index)
{return index >= CMap::tile_caution && index <= CMap::tile_caution_v2;}

bool isTileSteel(u32 index)
{return index >= CMap::tile_steel && index <= CMap::tile_steel_d8;}

bool isTileBackSteel(u32 index)
{return index >= CMap::tile_bsteel && index <= CMap::tile_bsteel_d4;}

bool isTileSnow(TileType tile)
{return (tile >= CMap::tile_snow && tile <= CMap::tile_snow_d3) || isTileGround(tile);}

bool isTileGround(TileType tile)
{{return getMap().isTileGround(tile);}}

bool isTileSnowPile(TileType tile)
{return tile >= CMap::tile_snow_pile && tile <= CMap::tile_snow_pile_v5;}

bool isTileElderBrick(u32 index)
{return index >= CMap::tile_elderbrick && index <= CMap::tile_elderbrick_d4;}

bool isTilePolishedStone(u32 index)
{return index >= CMap::tile_polishedstone && index <= CMap::tile_polishedstone_d4;}

bool isTileBackPolishedStone(u32 index)
{return index >= CMap::tile_bpolishedstone && index <= CMap::tile_bpolishedstone_d4;}

bool isTileIce(u32 index)
{return index >= CMap::tile_ice && index <= CMap::tile_ice_d3;}

bool isTileThickIce(u32 index)
{return index >= CMap::tile_thick_ice && index <= CMap::tile_thick_ice_d3;}

bool isTileAnyIce(u32 index)
{return isTileIce(index) || isTileThickIce(index);}

bool isTileBackGlass(u32 index)
{return index >= CMap::tile_bglass_d0 && index <= CMap::tile_bglass_v14;}

bool isTileSnowBricks(u32 index)
{return index >= CMap::tile_snow_bricks && index <= CMap::tile_snow_bricks_d1;}

bool isTileBackSnowBricks(u32 index)
{return index >= CMap::tile_bsnow_bricks && index <= CMap::tile_bsnow_bricks_d1;}