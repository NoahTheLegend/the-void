
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

		tile_polishedmetal = tile_steel - 64,
		tile_polishedmetal_v0,
		tile_polishedmetal_v1,
		tile_polishedmetal_v2,
		tile_polishedmetal_v3,
		tile_polishedmetal_v4,
		tile_polishedmetal_v5,
		tile_polishedmetal_v6,
		tile_polishedmetal_v7,
		tile_polishedmetal_v8,
		tile_polishedmetal_v9,
		tile_polishedmetal_v10,
		tile_polishedmetal_v11,
		tile_polishedmetal_v12,
		tile_polishedmetal_v13,
		tile_polishedmetal_v14,
		tile_polishedmetal_d0 = tile_polishedmetal + 16,
		tile_polishedmetal_d1,
		tile_polishedmetal_d2,
		tile_polishedmetal_d3,
		tile_polishedmetal_d4,
		
		tile_bpolishedmetal = tile_steel - 32,
		tile_bpolishedmetal_v0,
		tile_bpolishedmetal_v1,
		tile_bpolishedmetal_v2,
		tile_bpolishedmetal_v3,
		tile_bpolishedmetal_v4,
		tile_bpolishedmetal_v5,
		tile_bpolishedmetal_v6,
		tile_bpolishedmetal_v7,
		tile_bpolishedmetal_v8,
		tile_bpolishedmetal_v9,
		tile_bpolishedmetal_v10,
		tile_bpolishedmetal_v11,
		tile_bpolishedmetal_v12,
		tile_bpolishedmetal_v13,
		tile_bpolishedmetal_v14,
		tile_bpolishedmetal_d0 = tile_bpolishedmetal + 16,
		tile_bpolishedmetal_d1,
		tile_bpolishedmetal_d2,
		tile_bpolishedmetal_d3,
		tile_bpolishedmetal_d4,

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

		tile_bglass_d0 = tile_bsteel + 15,
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

		tile_glass = tile_bglass + 16,
		tile_glass_v0,
		tile_glass_v1,
		tile_glass_v2,
		tile_glass_v3,
		tile_glass_v4,
		tile_glass_v5,
		tile_glass_v6,
		tile_glass_v7,
		tile_glass_v8,
		tile_glass_v9,
		tile_glass_v10,
		tile_glass_v11,
		tile_glass_v12,
		tile_glass_v13,
		tile_glass_v14,
		tile_glass_d0,
		tile_glass_d1,

		tile_ice = tile_bglass + 48,
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
	};
};

bool isSolid(u32 type)
{
	return isSolid(getMap(), type);
}

bool isMetalTile(u32 type)
{
	return isTileSteel(type) || isTilePolishedMetal(type) || isTileCaution(type);
}

bool isSolid(CMap@ map, u32 type) // thin ice is not solid
{
	return map.isTileSolid(type) || map.isTileGround(type) || isTileSteel(type) || isTilePolishedMetal(type) || isTileCaution(type)
		|| isTileAnyIce(type) || isTileGlass(type);
}

bool isSolid(CMap@ map, Vec2f pos)
{
	u32 type = map.getTile(pos).type;
	return isSolid(map, type);
}

bool isHardSolid(CMap@ map, u32 type) // only tiles with friction
{
	return map.isTileSolid(type) || map.isTileGround(type)
		|| isTileSteel(type) || isTilePolishedMetal(type) || isTileCaution(type);
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
	return index == CMap::tile_empty;
}

bool isTileCaution(u32 index)
{return index >= CMap::tile_caution && index <= CMap::tile_caution_v2;}

bool isTileSteel(u32 index)
{return index >= CMap::tile_steel && index <= CMap::tile_steel_d8;}

bool isTileBackSteel(u32 index)
{return index >= CMap::tile_bsteel && index <= CMap::tile_bsteel_d4;}

bool isTilePolishedMetal(u32 index)
{return index >= CMap::tile_polishedmetal && index <= CMap::tile_polishedmetal_d4;}

bool isTileBackpolishedmetal(u32 index)
{return index >= CMap::tile_bpolishedmetal && index <= CMap::tile_bpolishedmetal_d4;}

bool isTileIce(u32 index)
{return index >= CMap::tile_ice && index <= CMap::tile_ice_d3;}

bool isTileThickIce(u32 index)
{return index >= CMap::tile_thick_ice && index <= CMap::tile_thick_ice_d3;}

bool isTileAnyIce(u32 index)
{return isTileIce(index) || isTileThickIce(index);}

bool isTileGlass(TileType tile)
{return tile >= CMap::tile_glass && tile <= CMap::tile_glass_d1;}

bool isTileBackGlass(u32 index)
{return index >= CMap::tile_bglass_d0 && index <= CMap::tile_bglass_v14;}