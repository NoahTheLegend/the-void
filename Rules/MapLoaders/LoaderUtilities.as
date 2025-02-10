// LoaderUtilities.as

#include "DummyCommon.as";
#include "ParticleSparks.as";
#include "Hitters.as";
#include "CustomBlocks.as";
#include "ShadowCastHooks.as"
#include "CustomSparks.as";
#include "UtilityChecks.as";

const Vec2f[] directions =
{
	Vec2f(0, -8),
	Vec2f(0, 8),
	Vec2f(8, 0),
	Vec2f(-8, 0)
};

bool onMapTileCollapse(CMap@ map, u32 offset)
{
	SET_TILE_CALLBACK@ set_tile_func;
	getRules().get("SET_TILE_CALLBACK", @set_tile_func);
	if (set_tile_func !is null)
	{
		set_tile_func(offset, 0);
	}

	Tile tile = map.getTile(offset);
	if (isDummyTile(tile.type))
	{
		CBlob@ blob = getBlobByNetworkID(server_getDummyGridNetworkID(offset));
		if(blob !is null)
		{
			blob.server_Die();
		}
	}
	return true;
}


TileType server_onTileHit(CMap@ map, f32 damage, u32 index, TileType oldTileType)
{
	Vec2f pos = map.getTileWorldPosition(index);

	if (map.getTile(index).type > 255)
	{
		switch(oldTileType)
		{
			// ice
			case CMap::tile_ice:
				return CMap::tile_ice_d0;

			case CMap::tile_ice_v0:
			case CMap::tile_ice_v1:
			case CMap::tile_ice_v2:
			case CMap::tile_ice_v3:
			case CMap::tile_ice_v4:
			case CMap::tile_ice_v5:
			case CMap::tile_ice_v6:
			case CMap::tile_ice_v7:
			case CMap::tile_ice_v8:
			case CMap::tile_ice_v9:
			case CMap::tile_ice_v10:
			case CMap::tile_ice_v11:
			case CMap::tile_ice_v12:
			case CMap::tile_ice_v13:
			case CMap::tile_ice_v14:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				map.server_SetTile(pos, CMap::tile_ice_d0);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				for (u8 i = 0; i < 4; i++)
				{
					ice_Update(map, map.getTileWorldPosition(index) + directions[i]);
				}
				return CMap::tile_ice_d0;
			}

			case CMap::tile_ice_d0:
			case CMap::tile_ice_d1:
			case CMap::tile_ice_d2:
				return oldTileType + 1;

			case CMap::tile_ice_d3:
				return CMap::tile_empty;

			// thick ice
			case CMap::tile_thick_ice:
				return CMap::tile_thick_ice_d0;

			case CMap::tile_thick_ice_v0:
			case CMap::tile_thick_ice_v1:
			case CMap::tile_thick_ice_v2:
			case CMap::tile_thick_ice_v3:
			case CMap::tile_thick_ice_v4:
			case CMap::tile_thick_ice_v5:
			case CMap::tile_thick_ice_v6:
			case CMap::tile_thick_ice_v7:
			case CMap::tile_thick_ice_v8:
			case CMap::tile_thick_ice_v9:
			case CMap::tile_thick_ice_v10:
			case CMap::tile_thick_ice_v11:
			case CMap::tile_thick_ice_v12:
			case CMap::tile_thick_ice_v13:
			case CMap::tile_thick_ice_v14:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				map.server_SetTile(pos, CMap::tile_thick_ice_d0);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				for (u8 i = 0; i < 4; i++)
				{
					thickice_Update(map, map.getTileWorldPosition(index) + directions[i]);
				}
				return CMap::tile_thick_ice_d0;
			}

			case CMap::tile_thick_ice_d0:
			case CMap::tile_thick_ice_d1:
			case CMap::tile_thick_ice_d2:
				return oldTileType + 1;

			case CMap::tile_thick_ice_d3:
				return CMap::tile_bice;

			// steel
			case CMap::tile_steel:
				return CMap::tile_steel_d0;

			case CMap::tile_steel_v0:
			case CMap::tile_steel_v1:
			case CMap::tile_steel_v2:
			case CMap::tile_steel_v3:
			case CMap::tile_steel_v4:
			case CMap::tile_steel_v5:
			case CMap::tile_steel_v6:
			case CMap::tile_steel_v7:
			case CMap::tile_steel_v8:
			case CMap::tile_steel_v9:
			case CMap::tile_steel_v10:
			case CMap::tile_steel_v11:
			case CMap::tile_steel_v12:
			case CMap::tile_steel_v13:
			case CMap::tile_steel_v14:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				map.server_SetTile(pos, CMap::tile_steel_d0);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				for (u8 i = 0; i < 4; i++)
				{
					steel_Update(map, map.getTileWorldPosition(index) + directions[i]);
				}
				return CMap::tile_steel_d0;
			}

			case CMap::tile_steel_d0:
			case CMap::tile_steel_d1:
			case CMap::tile_steel_d2:
			case CMap::tile_steel_d3:
			case CMap::tile_steel_d4:
			case CMap::tile_steel_d5:
			case CMap::tile_steel_d6:
			case CMap::tile_steel_d7:
				return oldTileType + 1;

			case CMap::tile_steel_d8:
				return CMap::tile_empty;

			// caution steel
			case CMap::tile_caution:
			case CMap::tile_caution_v0:
			case CMap::tile_caution_v1:
			case CMap::tile_caution_v2:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				map.server_SetTile(pos, CMap::tile_steel_d4);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				return CMap::tile_steel_d3;
			}

			// polished stone
			case CMap::tile_polishedmetal:
				return CMap::tile_polishedmetal_d0;

			case CMap::tile_polishedmetal_v0:
			case CMap::tile_polishedmetal_v1:
			case CMap::tile_polishedmetal_v2:
			case CMap::tile_polishedmetal_v3:
			case CMap::tile_polishedmetal_v4:
			case CMap::tile_polishedmetal_v5:
			case CMap::tile_polishedmetal_v6:
			case CMap::tile_polishedmetal_v7:
			case CMap::tile_polishedmetal_v8:
			case CMap::tile_polishedmetal_v9:
			case CMap::tile_polishedmetal_v10:
			case CMap::tile_polishedmetal_v11:
			case CMap::tile_polishedmetal_v12:
			case CMap::tile_polishedmetal_v13:
			case CMap::tile_polishedmetal_v14:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				map.server_SetTile(pos, CMap::tile_polishedmetal_d0);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				for (u8 i = 0; i < 4; i++)
				{
					polishedmetal_Update(map, map.getTileWorldPosition(index) + directions[i]);
				}
				return CMap::tile_polishedmetal_d0;
			}

			case CMap::tile_polishedmetal_d0:
			case CMap::tile_polishedmetal_d1:
			case CMap::tile_polishedmetal_d2:
			case CMap::tile_polishedmetal_d3:
				return oldTileType + 1;

			case CMap::tile_polishedmetal_d4:
				return CMap::tile_empty;

			// background polished stone
			case CMap::tile_bpolishedmetal:
				return CMap::tile_bpolishedmetal_d0;

			case CMap::tile_bpolishedmetal_v0:
			case CMap::tile_bpolishedmetal_v1:
			case CMap::tile_bpolishedmetal_v2:
			case CMap::tile_bpolishedmetal_v3:
			case CMap::tile_bpolishedmetal_v4:
			case CMap::tile_bpolishedmetal_v5:
			case CMap::tile_bpolishedmetal_v6:
			case CMap::tile_bpolishedmetal_v7:
			case CMap::tile_bpolishedmetal_v8:
			case CMap::tile_bpolishedmetal_v9:
			case CMap::tile_bpolishedmetal_v10:
			case CMap::tile_bpolishedmetal_v11:
			case CMap::tile_bpolishedmetal_v12:
			case CMap::tile_bpolishedmetal_v13:
			case CMap::tile_bpolishedmetal_v14:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				map.server_SetTile(pos, CMap::tile_bpolishedmetal_d0);
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::SOLID | Tile::LIGHT_SOURCE | Tile::COLLISION);

				for (u8 i = 0; i < 4; i++)
				{
					bpolishedmetal_Update(map, map.getTileWorldPosition(index) + directions[i]);
				}
				return CMap::tile_bpolishedmetal_d0;
			}

			case CMap::tile_bpolishedmetal_d0:
			case CMap::tile_bpolishedmetal_d1:
			case CMap::tile_bpolishedmetal_d2:
			case CMap::tile_bpolishedmetal_d3:
				return oldTileType + 1;

			case CMap::tile_bpolishedmetal_d4:
				return CMap::tile_empty;

			// glass
			case CMap::tile_glass:
				return CMap::tile_glass_d0;

			case CMap::tile_glass_v0:
			case CMap::tile_glass_v1:
			case CMap::tile_glass_v2:
			case CMap::tile_glass_v3:
			case CMap::tile_glass_v4:
			case CMap::tile_glass_v5:
			case CMap::tile_glass_v6:
			case CMap::tile_glass_v7:
			case CMap::tile_glass_v8:
			case CMap::tile_glass_v9:
			case CMap::tile_glass_v10:
			case CMap::tile_glass_v11:
			case CMap::tile_glass_v12:
			case CMap::tile_glass_v13:
			case CMap::tile_glass_v14:
			{
				Vec2f pos = map.getTileWorldPosition(index);
				map.server_SetTile(pos, CMap::tile_glass_d0);

				for (u8 i = 0; i < 4; i++)
				{
					glass_Update(map, map.getTileWorldPosition(index) + directions[i]);
				}
				return CMap::tile_glass_d0;
			}

			case CMap::tile_glass_d0:
				return CMap::tile_glass_d1;
			
			case CMap::tile_glass_d1:
				return CMap::tile_empty;

			// bglass
			case CMap::tile_bglass:
				return CMap::tile_bglass_d0;

			case CMap::tile_bglass_v0:
			case CMap::tile_bglass_v1:
			case CMap::tile_bglass_v2:
			case CMap::tile_bglass_v3:
			case CMap::tile_bglass_v4:
			case CMap::tile_bglass_v5:
			case CMap::tile_bglass_v6:
			case CMap::tile_bglass_v7:
			case CMap::tile_bglass_v8:
			case CMap::tile_bglass_v9:
			case CMap::tile_bglass_v10:
			case CMap::tile_bglass_v11:
			case CMap::tile_bglass_v12:
			case CMap::tile_bglass_v13:
			case CMap::tile_bglass_v14:
			{
				Vec2f pos = map.getTileWorldPosition(index);
				map.server_SetTile(pos, CMap::tile_bglass_d0);

				for (u8 i = 0; i < 4; i++)
				{
					bglass_Update(map, map.getTileWorldPosition(index) + directions[i]);
				}
				return CMap::tile_bglass_d0;
			}

			case CMap::tile_bglass_d0:
				return CMap::tile_empty;

			case CMap::tile_bice:
			case CMap::tile_bice_v0:
			case CMap::tile_bice_v1:
			case CMap::tile_bice_v2:
			case CMap::tile_bice_v3:
			case CMap::tile_bice_v4:
			case CMap::tile_bice_v5:
			case CMap::tile_bice_v6:
			case CMap::tile_bice_v7:
			case CMap::tile_bice_v8:
				return oldTileType;

			case CMap::tile_bsteel:
				return CMap::tile_bsteel_d0;

			case CMap::tile_bsteel_v0:
			case CMap::tile_bsteel_v1:
			case CMap::tile_bsteel_v2:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				map.server_SetTile(pos, CMap::tile_bsteel_d0);
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::LIGHT_SOURCE | Tile::SOLID | Tile::COLLISION);

				OnBackSteelTileUpdate(false, true, map, map.getTileWorldPosition(index));
				return CMap::tile_bsteel_d0;
			}

			case CMap::tile_bsteel_d0:
			case CMap::tile_bsteel_d1:
			case CMap::tile_bsteel_d2:
			case CMap::tile_bsteel_d3:
				return oldTileType + 1;

			case CMap::tile_bsteel_d4:
				return CMap::tile_empty;
		}
	}

	return map.getTile(index).type;
}

void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{
	Vec2f pos = map.getTileWorldPosition(index);

	SET_TILE_CALLBACK@ set_tile_func;
	getRules().get("SET_TILE_CALLBACK", @set_tile_func);
	if (set_tile_func !is null)
	{
		set_tile_func(index, tile_new);
	}

	if (!getRules().hasTag("loading")
		&& ((tile_new == CMap::tile_empty && tile_old != CMap::tile_empty) // any tile nearby broke, now empty
		|| (tile_old == CMap::tile_empty))) // any tile nearby placed
	{
		for (u8 i = 0; i < 4; i++)
		{
			bice_Update(map, pos + directions[i]);
		}
	}

	switch(tile_new)
	{
		case CMap::tile_empty:
		case CMap::tile_ground_back:
		{
			if (tile_old == CMap::tile_ice_d3 || tile_old == CMap::tile_thick_ice_d3 || tile_old == CMap::tile_bice)
				OnIceTileDestroyed(map, index);
			else if (tile_old == CMap::tile_steel_d8 || tile_old == CMap:: tile_bsteel_d4)
				OnSteelTileDestroyed(map, index);
			else if (tile_old == CMap::tile_polishedmetal_d4)
				OnPolishedMetalTileDestroyed(map, index);
			else if (tile_old == CMap::tile_bpolishedmetal_d4)
				OnBackPolishedMetalTileDestroyed(map, index);
			else if (tile_old == CMap::tile_glass_d1 || tile_old == CMap::tile_bglass_d0)
				OnGlassTileDestroyed(map, index);
				
			break;
		}
	}

	if (map.getTile(index).type > 255)
	{
		u32 id = tile_new;
		map.SetTileSupport(index, 255);

		switch(tile_new)
		{
			case CMap::tile_ice:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				ice_SetTile(map, pos);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				break;
			}

			case CMap::tile_thick_ice:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				thickice_SetTile(map, pos);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				break;
			}

			case CMap::tile_ice_v0:
			case CMap::tile_ice_v1:
			case CMap::tile_ice_v2:
			case CMap::tile_ice_v3:
			case CMap::tile_ice_v4:
			case CMap::tile_ice_v5:
			case CMap::tile_ice_v6:
			case CMap::tile_ice_v7:
			case CMap::tile_ice_v8:
			case CMap::tile_ice_v9:
			case CMap::tile_ice_v10:
			case CMap::tile_ice_v11:
			case CMap::tile_ice_v12:
			case CMap::tile_ice_v13:
			{
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				
				break;
			}
			case CMap::tile_thick_ice_v0:
			case CMap::tile_thick_ice_v1:
			case CMap::tile_thick_ice_v2:
			case CMap::tile_thick_ice_v3:
			case CMap::tile_thick_ice_v4:
			case CMap::tile_thick_ice_v5:
			case CMap::tile_thick_ice_v6:
			case CMap::tile_thick_ice_v7:
			case CMap::tile_thick_ice_v8:
			case CMap::tile_thick_ice_v9:
			case CMap::tile_thick_ice_v10:
			case CMap::tile_thick_ice_v11:
			case CMap::tile_thick_ice_v12:
			case CMap::tile_thick_ice_v13:
			{
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_SOURCE | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
				
				break;
			}

			case CMap::tile_ice_v14:
			case CMap::tile_thick_ice_v14:
			{	
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				break;
			}

			case CMap::tile_ice_d0:
			case CMap::tile_ice_d1:
			case CMap::tile_ice_d2:
			case CMap::tile_ice_d3:
			case CMap::tile_thick_ice_d0:
			case CMap::tile_thick_ice_d1:
			case CMap::tile_thick_ice_d2:
			case CMap::tile_thick_ice_d3:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				OnIceTileHit(map, index);
				break;

			case CMap::tile_steel:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				steel_SetTile(map, pos);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				if (isClient()) playSoundInProximityAtPos(map.getTileWorldPosition(index), "StepIce", 1.0f, 1.1f, true);

				break;
			}

			case CMap::tile_steel_v0:
			case CMap::tile_steel_v1:
			case CMap::tile_steel_v2:
			case CMap::tile_steel_v3:
			case CMap::tile_steel_v4:
			case CMap::tile_steel_v5:
			case CMap::tile_steel_v6:
			case CMap::tile_steel_v7:
			case CMap::tile_steel_v8:
			case CMap::tile_steel_v9:
			case CMap::tile_steel_v10:
			case CMap::tile_steel_v11:
			case CMap::tile_steel_v12:
			case CMap::tile_steel_v13:
			case CMap::tile_steel_v14:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				break;

			case CMap::tile_steel_d0:
			case CMap::tile_steel_d1:
			case CMap::tile_steel_d2:
			case CMap::tile_steel_d3:
			case CMap::tile_steel_d4:
			case CMap::tile_steel_d5:
			case CMap::tile_steel_d6:
			case CMap::tile_steel_d7:
			case CMap::tile_steel_d8:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				OnSteelTileHit(map, index);
				break;

			case CMap::tile_glass:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				glass_SetTile(map, pos);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_SOURCE | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::WATER_PASSES | Tile::BACKGROUND);

				break;
			}
			case CMap::tile_glass_v0:
			case CMap::tile_glass_v1:
			case CMap::tile_glass_v2:
			case CMap::tile_glass_v3:
			case CMap::tile_glass_v4:
			case CMap::tile_glass_v5:
			case CMap::tile_glass_v6:
			case CMap::tile_glass_v7:
			case CMap::tile_glass_v8:
			case CMap::tile_glass_v9:
			case CMap::tile_glass_v10:
			case CMap::tile_glass_v11:
			case CMap::tile_glass_v12:
			case CMap::tile_glass_v13:
			case CMap::tile_glass_v14:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_SOURCE | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::WATER_PASSES | Tile::BACKGROUND);

				break;

			case CMap::tile_glass_d0:
			case CMap::tile_glass_d1:
				OnGlassTileHit(map, index);
				break;

			case CMap::tile_bglass:
			{
				Vec2f pos = map.getTileWorldPosition(index);
				bglass_SetTile(map, pos);
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES | Tile::LIGHT_SOURCE);
				if (isClient()) playSoundInProximityAtPos(map.getTileWorldPosition(index), "build_wall.ogg", 1.0f, 1.0f);

				break;
			}

			case CMap::tile_bglass_v0:
			case CMap::tile_bglass_v1:
			case CMap::tile_bglass_v2:
			case CMap::tile_bglass_v3:
			case CMap::tile_bglass_v4:
			case CMap::tile_bglass_v5:
			case CMap::tile_bglass_v6:
			case CMap::tile_bglass_v7:
			case CMap::tile_bglass_v8:
			case CMap::tile_bglass_v9:
			case CMap::tile_bglass_v10:
			case CMap::tile_bglass_v11:
			case CMap::tile_bglass_v12:
			case CMap::tile_bglass_v13:
			case CMap::tile_bglass_v14:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES | Tile::LIGHT_SOURCE);
				break;

			case CMap::tile_bglass_d0:
				OnBGlassTileHit(map, index);
				break;

			case CMap::tile_bice:
			{
				Vec2f pos = map.getTileWorldPosition(index);
				bice_SetTile(map, pos);

				map.AddTileFlag(index, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::LIGHT_SOURCE | Tile::SOLID | Tile::COLLISION);

				break;
			}

			case CMap::tile_bsteel:
			{
				Vec2f pos = map.getTileWorldPosition(index);
				OnBackSteelTileUpdate(false, true, map, pos);

				TileType up = map.getTile(pos - Vec2f( 0.0f, 8.0f)).type;
				TileType down = map.getTile(pos + Vec2f( 0.0f, 8.0f)).type;
				bool isUp = (up >= CMap::tile_bsteel && up <= CMap::tile_bsteel_v2) ? true : false;
				bool isDown = (down >= CMap::tile_bsteel && down <= CMap::tile_bsteel_v2) ? true : false;

				if(isUp && isDown)
					map.SetTile(index, CMap::tile_bsteel_v2);
				else if(isUp || isDown)
				{
					if(isUp && !isDown)
						map.SetTile(index, CMap::tile_bsteel_v0);
					if(!isUp && isDown)
						map.SetTile(index, CMap::tile_bsteel_v1);
				}
				else
					map.SetTile(index, CMap::tile_bsteel);

				map.AddTileFlag(index, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::LIGHT_SOURCE | Tile::SOLID | Tile::COLLISION);

				if (isClient()) playSoundInProximityAtPos(map.getTileWorldPosition(index), "build_wall.ogg", 1.0f, 1.1f);
				break;
			}

			case CMap::tile_bsteel_v0:
			case CMap::tile_bsteel_v1:
			case CMap::tile_bsteel_v2:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);

				if (isClient()) playSoundInProximityAtPos(map.getTileWorldPosition(index), "build_wall.ogg", 1.0f, 1.1f);
				break;

			case CMap::tile_bsteel_d0:
			case CMap::tile_bsteel_d1:
			case CMap::tile_bsteel_d2:
			case CMap::tile_bsteel_d3:
			case CMap::tile_bsteel_d4:
				OnBackSteelTileHit(map, index);
				break;

			case CMap::tile_caution:
			case CMap::tile_caution_v0:
			case CMap::tile_caution_v1:
			case CMap::tile_caution_v2:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				if (isClient()) playSoundInProximityAtPos(map.getTileWorldPosition(index), "build_wall.ogg", 1.0f, 1.1f);

				break;
			}

			case CMap::tile_polishedmetal:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				polishedmetal_SetTile(map, pos);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				if (isClient()) playSoundInProximityAtPos(map.getTileWorldPosition(index), "build_wall.ogg", 1.0f, 0.925f);

				break;
			}

			case CMap::tile_polishedmetal_v0:
			case CMap::tile_polishedmetal_v1:
			case CMap::tile_polishedmetal_v2:
			case CMap::tile_polishedmetal_v3:
			case CMap::tile_polishedmetal_v4:
			case CMap::tile_polishedmetal_v5:
			case CMap::tile_polishedmetal_v6:
			case CMap::tile_polishedmetal_v7:
			case CMap::tile_polishedmetal_v8:
			case CMap::tile_polishedmetal_v9:
			case CMap::tile_polishedmetal_v10:
			case CMap::tile_polishedmetal_v11:
			case CMap::tile_polishedmetal_v12:
			case CMap::tile_polishedmetal_v13:
			case CMap::tile_polishedmetal_v14:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				break;

			case CMap::tile_polishedmetal_d0:
			case CMap::tile_polishedmetal_d1:
			case CMap::tile_polishedmetal_d2:
			case CMap::tile_polishedmetal_d3:
			case CMap::tile_polishedmetal_d4:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				OnPolishedMetalTileHit(map, index);
				break;

			case CMap::tile_bpolishedmetal:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				bpolishedmetal_SetTile(map, pos);
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::SOLID | Tile::LIGHT_SOURCE | Tile::COLLISION);

				if (isClient()) playSoundInProximityAtPos(map.getTileWorldPosition(index), "build_wall.ogg", 1.0f, 0.925f);

				break;
			}

			case CMap::tile_bpolishedmetal_v0:
			case CMap::tile_bpolishedmetal_v1:
			case CMap::tile_bpolishedmetal_v2:
			case CMap::tile_bpolishedmetal_v3:
			case CMap::tile_bpolishedmetal_v4:
			case CMap::tile_bpolishedmetal_v5:
			case CMap::tile_bpolishedmetal_v6:
			case CMap::tile_bpolishedmetal_v7:
			case CMap::tile_bpolishedmetal_v8:
			case CMap::tile_bpolishedmetal_v9:
			case CMap::tile_bpolishedmetal_v10:
			case CMap::tile_bpolishedmetal_v11:
			case CMap::tile_bpolishedmetal_v12:
			case CMap::tile_bpolishedmetal_v13:
			case CMap::tile_bpolishedmetal_v14:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::SOLID | Tile::LIGHT_SOURCE | Tile::COLLISION);
				break;

			case CMap::tile_bpolishedmetal_d0:
			case CMap::tile_bpolishedmetal_d1:
			case CMap::tile_bpolishedmetal_d2:
			case CMap::tile_bpolishedmetal_d3:
			case CMap::tile_bpolishedmetal_d4:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::SOLID | Tile::LIGHT_SOURCE | Tile::COLLISION);
				OnBackPolishedMetalTileHit(map, index);
				break;
		}
	}
}

void ice_SetTile(CMap@ map, Vec2f pos)
{
	map.SetTile(map.getTileOffset(pos), CMap::tile_ice + ice_GetMask(map, pos));

	for (u8 i = 0; i < 4; i++)
	{
		ice_Update(map, pos + directions[i]);
	}
}

u8 ice_GetMask(CMap@ map, Vec2f pos)
{
	u8 mask = 0;

	for (u8 i = 0; i < 4; i++)
	{
		if (checkIceTile(map, pos + directions[i]) || checkThickIceTile(map, pos + directions[i])) mask |= 1 << i;
	}

	return mask;
}

void ice_Update(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	if (checkIceTile(map, pos))
		map.SetTile(map.getTileOffset(pos),CMap::tile_ice+ice_GetMask(map,pos));
}

void thickice_SetTile(CMap@ map, Vec2f pos)
{
	map.SetTile(map.getTileOffset(pos), CMap::tile_thick_ice + thickice_GetMask(map, pos));

	for (u8 i = 0; i < 4; i++)
	{
		thickice_Update(map, pos + directions[i]);
	}
}

u8 thickice_GetMask(CMap@ map, Vec2f pos)
{
	u8 mask = 0;

	for (u8 i = 0; i < 4; i++)
	{
		if (checkThickIceTile(map, pos + directions[i]) || checkIceTile(map, pos + directions[i])) mask |= 1 << i;
	}

	return mask;
}

void thickice_Update(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	if (checkThickIceTile(map, pos))
		map.SetTile(map.getTileOffset(pos),CMap::tile_thick_ice+thickice_GetMask(map,pos));
}


void bice_SetTile(CMap@ map, Vec2f pos)
{
	map.SetTile(map.getTileOffset(pos), CMap::tile_bice + bice_GetMask(map, pos));

	for (u8 i = 0; i < 4; i++)
	{
		bice_Update(map, pos + directions[i]);
	}
}

u8 bice_GetMask(CMap@ map, Vec2f pos)
{
	u8 mask = 0;

	for (u8 i = 0; i < 4; i++)
	{
		if (checkBackIceTile(map, pos + directions[i]) || !isTileExposure(map.getTile(pos + directions[i]).type))
			mask |= 1 << i;
	}

	return mask;
}

void bice_Update(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	if (checkBackIceTile(map, pos))
	{
		map.SetTile(map.getTileOffset(pos),CMap::tile_bice+bice_GetMask(map,pos));
		// go on fucker you think youre smart then disable it DO IT place it in onSetTile hook
		u32 index = map.getTileOffset(pos);
		map.AddTileFlag(index, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
		map.RemoveTileFlag(index, Tile::LIGHT_SOURCE | Tile::SOLID | Tile::COLLISION);
	}
}

void OnIceTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	map.RemoveTileFlag(index, Tile::LIGHT_PASSES);

	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		playSoundInProximityAtPos(pos, "IceBreak", 1.0f, 0.95f+XORRandom(6)*0.01f, true);
		customSparks(pos, 1, rnd_vel(2,1,10.0f), SColor(255,25,75+XORRandom(75),200+XORRandom(55)));
	}
}

void OnIceTileDestroyed(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		playSoundInProximityAtPos(pos, "IceBreak", 1.0f, 0.8f+XORRandom(6)*0.01f, true);
	}
}

void steel_SetTile(CMap@ map, Vec2f pos)
{
	map.SetTile(map.getTileOffset(pos), CMap::tile_steel + steel_GetMask(map, pos));

	for (u8 i = 0; i < 4; i++)
	{
		steel_Update(map, pos + directions[i]);
	}
}

u8 steel_GetMask(CMap@ map, Vec2f pos)
{
	u8 mask = 0;

	for (u8 i = 0; i < 4; i++)
	{
		if (checkSteelTile(map, pos + directions[i])) mask |= 1 << i;
	}

	return mask;
}

void steel_Update(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	if (checkSteelTile(map, pos))
		map.SetTile(map.getTileOffset(pos),CMap::tile_steel+steel_GetMask(map,pos));
}

void OnSteelTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	map.RemoveTileFlag(index, Tile::LIGHT_PASSES);

	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		playSoundInProximityAtPos(pos, "MetalBreak", 1.0f, 0.95f+XORRandom(6)*0.01f, true);
		sparks(pos, 1, 1);
	}
}

void OnSteelTileDestroyed(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		playSoundInProximityAtPos(pos, "MetalBreak", 1.0f, 0.8f+XORRandom(6)*0.01f, true);
	}
}

void OnBackSteelTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);

	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		playSoundInProximityAtPos(pos, "MetalBreak", 1.0f, 1.025f+XORRandom(6)*0.01f, true);
		sparks(pos, 1, 1);
	}
}

void OnBackSteelTileUpdate(bool updateThis, bool updateOthers, CMap@ map, Vec2f pos)
{
	TileType up = map.getTile(pos - Vec2f( 0.0f, 8.0f)).type;
	TileType down = map.getTile(pos + Vec2f( 0.0f, 8.0f)).type;
	bool isUp = (up >= CMap::tile_bsteel && up <= CMap::tile_bsteel_v2) ? true : false;
	bool isDown = (down >= CMap::tile_bsteel && down <= CMap::tile_bsteel_v2) ? true : false;

	if(updateThis)
	{
		if(isUp && isDown)
			map.server_SetTile(pos, CMap::tile_bsteel_v2);
		else if(isUp || isDown)
		{
			if(isUp && !isDown)
				map.server_SetTile(pos, CMap::tile_bsteel_v0);
			if(!isUp && isDown)
				map.server_SetTile(pos, CMap::tile_bsteel_v1);
		}
		else
			map.server_SetTile(pos, CMap::tile_bsteel);
	}
	if(updateOthers)
	{
		if(isUp)
			OnBackSteelTileUpdate(true, false, map, pos - Vec2f( 0.0f, 8.0f));
		if(isDown)
			OnBackSteelTileUpdate(true, false, map, pos + Vec2f( 0.0f, 8.0f));
	}
}

void polishedmetal_SetTile(CMap@ map, Vec2f pos)
{
	map.SetTile(map.getTileOffset(pos), CMap::tile_polishedmetal + polishedmetal_GetMask(map, pos));

	for (u8 i = 0; i < 4; i++)
	{
		polishedmetal_Update(map, pos + directions[i]);
	}
}

u8 polishedmetal_GetMask(CMap@ map, Vec2f pos)
{
	u8 mask = 0;

	for (u8 i = 0; i < 4; i++)
	{
		if (checkPolishedMetalTile(map, pos + directions[i]) || checkGlassTile(map, pos + directions[i])) mask |= 1 << i;
	}

	return mask;
}

void polishedmetal_Update(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	if (checkPolishedMetalTile(map, pos))
		map.SetTile(map.getTileOffset(pos), CMap::tile_polishedmetal+polishedmetal_GetMask(map,pos));
}

void OnPolishedMetalTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	map.RemoveTileFlag(index, Tile::LIGHT_PASSES);

	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		playSoundInProximityAtPos(pos, "MetalBreak", 1.0f, 0.95f+XORRandom(6)*0.01f, true);
	}
}

void OnPolishedMetalTileDestroyed(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		playSoundInProximityAtPos(pos, "MetalBreak", 1.0f, 1.025f+XORRandom(6)*0.01f, true);
	}
}

void bpolishedmetal_SetTile(CMap@ map, Vec2f pos)
{
	map.SetTile(map.getTileOffset(pos), CMap::tile_bpolishedmetal + bpolishedmetal_GetMask(map, pos));

	for (u8 i = 0; i < 4; i++)
	{
		bpolishedmetal_Update(map, pos + directions[i]);
	}
}

u8 bpolishedmetal_GetMask(CMap@ map, Vec2f pos)
{
	u8 mask = 0;

	for (u8 i = 0; i < 4; i++)
	{
		if (checkBackPolishedMetalTile(map, pos + directions[i])) mask |= 1 << i;
	}

	return mask;
}

void bpolishedmetal_Update(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	if (checkBackPolishedMetalTile(map, pos))
		map.SetTile(map.getTileOffset(pos),CMap::tile_bpolishedmetal+bpolishedmetal_GetMask(map,pos));
}

void OnBackPolishedMetalTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
	map.RemoveTileFlag(index, Tile::SOLID | Tile::LIGHT_SOURCE | Tile::COLLISION);

	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		playSoundInProximityAtPos(pos, "dig_stone" + (1 + XORRandom(3)), 1.0f, 0.9f);
	}
}

void OnBackPolishedMetalTileDestroyed(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		playSoundInProximityAtPos(pos, "MetalBreak", 1.0f, 0.85f+XORRandom(6)*0.01f, true);
	}
}

void OnGlassTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);

	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		playSoundInProximityAtPos(pos, "GlassBreak2.ogg", 1.0f, 1.5f+XORRandom(6)*0.01f);
		glasssparks(pos, 3 + XORRandom(5));
	}
}

void OnBGlassTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES | Tile::LIGHT_SOURCE);

	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		playSoundInProximityAtPos(pos, "GlassBreak2.ogg", 1.0f, 1.0f);
		glasssparks(pos, 3 + XORRandom(2));
	}
}

void OnGlassTileDestroyed(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		playSoundInProximityAtPos(pos, "GlassBreak1.ogg", 1.0f, 1.0f);
		glasssparks(pos, 3 + XORRandom(3));
	}
}

void glasssparks(Vec2f at, int amount)
{
	switch(XORRandom(4))
	{
		case 1:
			at += Vec2f(4, 0);
			break;
		case 2:
			at += Vec2f(0, 4);
			break;
		case 3:
			at += Vec2f(8, 4);
			break;
		case 4:
			at += Vec2f(4, 8);
			break;
	}
	SColor[] colors =
	{
		SColor(255, 217, 242, 246),
		SColor(255, 255, 255, 255),
		SColor(255, 85, 119, 130),
		SColor(255, 79, 145, 167),
		SColor(255, 48, 60, 65),
		SColor(255, 21, 27, 30)
	};

	if (isClient())
	{
		for (int i = 0; i < amount; i++)
		{
			Vec2f vel = getRandomVelocity(0.1f, 1.0f, 180.0f);
			vel.y = -Maths::Abs(vel.y)+Maths::Abs(vel.x)/4.0f-2.0f-float(XORRandom(100))/100.0f;

			ParticlePixel(at, vel, colors[XORRandom(6)], true);
			CParticle@ p = makeGibParticle("GlassSparks.png", at, vel, 0, XORRandom(5)-1, Vec2f(4.0f, 4.0f), 0.0f, 1, "GlassBreak1.ogg");
			if (p !is null)
			{
				p.gravity = Vec2f_zero;
			}
		}
	}
}

u8 glass_GetMask(CMap@ map, Vec2f pos)
{
	u8 mask = 0;

	for (u8 i = 0; i < 4; i++)
	{
		if (checkGlassTile(map, pos + directions[i]) || checkPolishedMetalTile(map, pos + directions[i])) mask |= 1 << i;
	}

	return mask;
}

u8 bglass_GetMask(CMap@ map, Vec2f pos)
{
	u8 mask = 0;

	for (u8 i = 0; i < 4; i++)
	{
		if (checkBackGlassTile(map, pos + directions[i])) mask |= 1 << i;
	}

	return mask;
}

void glass_SetTile(CMap@ map, Vec2f pos)
{
	map.SetTile(map.getTileOffset(pos), CMap::tile_glass + glass_GetMask(map, pos));

	for (u8 i = 0; i < 4; i++)
	{
		glass_Update(map, pos + directions[i]);
	}
}

void bglass_SetTile(CMap@ map, Vec2f pos)
{
	map.SetTile(map.getTileOffset(pos), CMap::tile_bglass + bglass_GetMask(map, pos));

	for (u8 i = 0; i < 4; i++)
	{
		bglass_Update(map, pos + directions[i]);
	}
}

void glass_Update(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	if (isGlassTile(map, pos))
		map.server_SetTile(pos,CMap::tile_glass+glass_GetMask(map,pos));
}

void bglass_Update(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	if (isBGlassTile(map, pos))
		map.server_SetTile(pos,CMap::tile_bglass+bglass_GetMask(map,pos));
}

bool isGlassTile(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_glass && tile <= CMap::tile_glass_v14;
}

bool isBGlassTile(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_bglass && tile <= CMap::tile_bglass_v14;
}

// these are required only for getMask functions
bool checkPolishedMetalTile(CMap@ map, Vec2f pos) 
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_polishedmetal && tile <= CMap::tile_polishedmetal_v14;
}

bool checkGlassTile(CMap@ map, Vec2f pos) 
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_glass && tile <= CMap::tile_glass_v14;
}

bool checkBackGlassTile(CMap@ map, Vec2f pos) 
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_bglass && tile <= CMap::tile_bglass_v14;
}

bool checkBackPolishedMetalTile(CMap@ map, Vec2f pos) 
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_bpolishedmetal && tile <= CMap::tile_bpolishedmetal_v14;
}

bool checkIceTile(CMap@ map, Vec2f pos) 
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_ice && tile <= CMap::tile_ice_v14;
}

bool checkThickIceTile(CMap@ map, Vec2f pos) 
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_thick_ice && tile <= CMap::tile_thick_ice_v14;
}

bool checkBackIceTile(CMap@ map, Vec2f pos) 
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_bice && tile <= CMap::tile_bice_v14;
}

bool checkBackSteelTile(CMap@ map, Vec2f pos) 
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_bsteel && tile <= CMap::tile_bsteel_v2;
}

bool checkSteelTile(CMap@ map, Vec2f pos) 
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_steel && tile <= CMap::tile_steel_v14;
}