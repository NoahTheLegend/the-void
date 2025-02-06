// LoaderUtilities.as

#include "DummyCommon.as";
#include "ParticleSparks.as";
#include "Hitters.as";
#include "CustomBlocks.as";
#include "ShadowCastHooks.as"
#include "CustomSparks.as";

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
	else if (isTileSnow(tile.type) || isTileSnowPile(tile.type))
	{ 	
		CBlob@ blob = getBlobByNetworkID(server_getDummyGridNetworkID(offset));
		if (blob !is null)
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
			// snow
			case CMap::tile_snow:
			case CMap::tile_snow_v0:
			case CMap::tile_snow_v1:
			case CMap::tile_snow_v2:
			case CMap::tile_snow_v3:
			case CMap::tile_snow_v4:
			case CMap::tile_snow_v5:
				return CMap::tile_snow_d0;

			case CMap::tile_snow_d0:
			case CMap::tile_snow_d1:
			case CMap::tile_snow_d2:
				return oldTileType + 1;

			case CMap::tile_snow_d3:
				return CMap::tile_empty;
			// snow pile
			case CMap::tile_snow_pile:
			case CMap::tile_snow_pile_v0:
			case CMap::tile_snow_pile_v1:
			case CMap::tile_snow_pile_v2:
			case CMap::tile_snow_pile_v3:
				return oldTileType + 2;

			case CMap::tile_snow_pile_v4:
			case CMap::tile_snow_pile_v5:
				return CMap::tile_empty;

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

			// snow bricks
			case CMap::tile_snow_bricks:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				map.server_SetTile(pos, CMap::tile_snow_bricks_d0);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				return CMap::tile_snow_bricks_d0;
			}
			case CMap::tile_snow_bricks_d0:
			{
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				return CMap::tile_snow_bricks_d1;
			}
			case CMap::tile_snow_bricks_d1:
				return CMap::tile_empty;

			// back snow bricks
			case CMap::tile_bsnow_bricks:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				map.server_SetTile(pos, CMap::tile_bsnow_bricks_d0);
				map.AddTileFlag(index, Tile::LIGHT_PASSES | Tile::BACKGROUND | Tile::WATER_PASSES);
				map.RemoveTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_SOURCE);

				return CMap::tile_bsnow_bricks_d0;
			}
			case CMap::tile_bsnow_bricks_d0:
			{
				map.AddTileFlag(index, Tile::LIGHT_PASSES | Tile::BACKGROUND | Tile::WATER_PASSES);
				map.RemoveTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_SOURCE);

				return CMap::tile_bsnow_bricks_d1;
			}
			case CMap::tile_bsnow_bricks_d1:
				return CMap::tile_empty;

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
			
			// elder bricks
			case CMap::tile_elderbrick:
			case CMap::tile_elderbrick_v0:
				return CMap::tile_elderbrick_d0;
			
			case CMap::tile_elderbrick_d0:
			case CMap::tile_elderbrick_d1:
			case CMap::tile_elderbrick_d2:
			case CMap::tile_elderbrick_d3:
				return oldTileType + 1;

			case CMap::tile_elderbrick_d4:
				return CMap::tile_ground_back;
			
			// polished stone
			case CMap::tile_polishedstone:
				return CMap::tile_polishedstone_d0;

			case CMap::tile_polishedstone_v0:
			case CMap::tile_polishedstone_v1:
			case CMap::tile_polishedstone_v2:
			case CMap::tile_polishedstone_v3:
			case CMap::tile_polishedstone_v4:
			case CMap::tile_polishedstone_v5:
			case CMap::tile_polishedstone_v6:
			case CMap::tile_polishedstone_v7:
			case CMap::tile_polishedstone_v8:
			case CMap::tile_polishedstone_v9:
			case CMap::tile_polishedstone_v10:
			case CMap::tile_polishedstone_v11:
			case CMap::tile_polishedstone_v12:
			case CMap::tile_polishedstone_v13:
			case CMap::tile_polishedstone_v14:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				map.server_SetTile(pos, CMap::tile_polishedstone_d0);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				for (u8 i = 0; i < 4; i++)
				{
					polishedstone_Update(map, map.getTileWorldPosition(index) + directions[i]);
				}
				return CMap::tile_polishedstone_d0;
			}

			case CMap::tile_polishedstone_d0:
			case CMap::tile_polishedstone_d1:
			case CMap::tile_polishedstone_d2:
			case CMap::tile_polishedstone_d3:
				return oldTileType + 1;

			case CMap::tile_polishedstone_d4:
				return CMap::tile_empty;

			// background polished stone
			case CMap::tile_bpolishedstone:
				return CMap::tile_bpolishedstone_d0;

			case CMap::tile_bpolishedstone_v0:
			case CMap::tile_bpolishedstone_v1:
			case CMap::tile_bpolishedstone_v2:
			case CMap::tile_bpolishedstone_v3:
			case CMap::tile_bpolishedstone_v4:
			case CMap::tile_bpolishedstone_v5:
			case CMap::tile_bpolishedstone_v6:
			case CMap::tile_bpolishedstone_v7:
			case CMap::tile_bpolishedstone_v8:
			case CMap::tile_bpolishedstone_v9:
			case CMap::tile_bpolishedstone_v10:
			case CMap::tile_bpolishedstone_v11:
			case CMap::tile_bpolishedstone_v12:
			case CMap::tile_bpolishedstone_v13:
			case CMap::tile_bpolishedstone_v14:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				map.server_SetTile(pos, CMap::tile_bpolishedstone_d0);
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::SOLID | Tile::LIGHT_SOURCE | Tile::COLLISION);

				for (u8 i = 0; i < 4; i++)
				{
					bpolishedstone_Update(map, map.getTileWorldPosition(index) + directions[i]);
				}
				return CMap::tile_bpolishedstone_d0;
			}

			case CMap::tile_bpolishedstone_d0:
			case CMap::tile_bpolishedstone_d1:
			case CMap::tile_bpolishedstone_d2:
			case CMap::tile_bpolishedstone_d3:
				return oldTileType + 1;

			case CMap::tile_bpolishedstone_d4:
				return CMap::tile_empty;

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
			if (tile_old == CMap::tile_snow_d3 || tile_old == CMap::tile_snow_bricks_d1
				|| tile_old == CMap::tile_bsnow_bricks_d1 || tile_old == CMap::tile_snow_pile_v4
					|| tile_old == CMap::tile_snow_pile_v5)
				OnSnowTileDestroyed(map, index);
			else if (tile_old == CMap::tile_ice_d3)
				OnIceTileDestroyed(map, index);
			else if (tile_old == CMap::tile_thick_ice_d3)
				OnIceTileDestroyed(map, index);
			else if (tile_old == CMap::tile_steel_d8 || tile_old == CMap:: tile_bsteel_d4)
				OnSteelTileDestroyed(map, index);
			else if (tile_old == CMap::tile_elderbrick_d4)
				OnElderBrickTileDestroyed(map, index);
			else if (tile_old == CMap::tile_polishedstone_d4)
				OnPolishedStoneTileDestroyed(map, index);
			else if (tile_old == CMap::tile_bpolishedstone_d4)
				OnBackPolishedStoneTileDestroyed(map, index);

			if(isTileSnowPile(map.getTile(index-map.tilemapwidth).type) && map.tilemapwidth < index)
				map.server_SetTile(map.getTileWorldPosition(index-map.tilemapwidth), CMap::tile_empty);
			break;
		}
	}

	if (map.getTile(index).type > 255)
	{
		u32 id = tile_new;
		map.SetTileSupport(index, 10);

		switch(tile_new)
		{
			case CMap::tile_snow:
				if(isClient())
				{
					int add = index % 7;
					if (add > 0)
					map.SetTile(index, CMap::tile_snow + add);
				}
				map.SetTileSupport(index, 1);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				break;

			case CMap::tile_snow_v0:
			case CMap::tile_snow_v1:
			case CMap::tile_snow_v2:
			case CMap::tile_snow_v3:
			case CMap::tile_snow_v4:
			case CMap::tile_snow_v5:
				map.SetTileSupport(index, 1);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				break;

			case CMap::tile_snow_d0:
			case CMap::tile_snow_d1:
			case CMap::tile_snow_d2:
			case CMap::tile_snow_d3:
				map.SetTileSupport(index, 1);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				if(isClient()) OnSnowTileHit(map, index);
				break;

			case CMap::tile_snow_pile:
			case CMap::tile_snow_pile_v0:
			case CMap::tile_snow_pile_v1:
			case CMap::tile_snow_pile_v2:
			case CMap::tile_snow_pile_v3:
			case CMap::tile_snow_pile_v4:
			case CMap::tile_snow_pile_v5:
				if(tile_new > tile_old && isTileSnowPile(tile_old)) // if pile got smaller do particles
				{
					if(isClient()) OnSnowTileHit(map, index);
				}
				map.SetTileSupport(index, 0);
				map.AddTileFlag(index, Tile::LIGHT_SOURCE | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
				map.RemoveTileFlag(index, Tile::SOLID | Tile::COLLISION);
				break;

			case CMap::tile_snow_bricks:
			case CMap::tile_snow_bricks_d0:
			case CMap::tile_snow_bricks_d1:
				map.SetTileSupport(index, 8);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				break;

			case CMap::tile_bsnow_bricks:
				map.SetTileSupport(index, 8);
				if(isClient())
				{
					int add = index % 6;
					if (add % 3 == 0) map.AddTileFlag(index, Tile::MIRROR);
					if (add % 2 == 0) map.AddTileFlag(index, Tile::FLIP);
				}
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
			case CMap::tile_bsnow_bricks_d0:
			case CMap::tile_bsnow_bricks_d1:
				map.SetTileSupport(index, 8);
				map.AddTileFlag(index, Tile::LIGHT_PASSES | Tile::BACKGROUND | Tile::WATER_PASSES);
				map.RemoveTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_SOURCE);
				break;

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

				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.1f);

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

			case CMap::tile_bglass:
			{
				Vec2f pos = map.getTileWorldPosition(index);
				bglass_SetTile(map, pos);
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES | Tile::LIGHT_SOURCE);
				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);

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
				OnBackGlassTileHit(map, index);
				break;

			case CMap::tile_bice:
			{
				map.SetTileSupport(index, 255);
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

				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.1f);

				break;
			}

			case CMap::tile_bsteel_v0:
			case CMap::tile_bsteel_v1:
			case CMap::tile_bsteel_v2:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);

				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.1f);
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

				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.1f);

				break;
			}

			case CMap::tile_elderbrick:
				elderbrick_SetTile(map, pos);
				map.SetTileSupport(index, 255);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				break;
				
			case CMap::tile_elderbrick_v0:
				map.SetTileSupport(index, 255);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				break;

			case CMap::tile_elderbrick_d0:
			case CMap::tile_elderbrick_d1:
			case CMap::tile_elderbrick_d2:
			case CMap::tile_elderbrick_d3:
			case CMap::tile_elderbrick_d4:
				map.SetTileSupport(index, 255);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				OnElderBrickTileHit(map, index);
				break;

			case CMap::tile_polishedstone:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				polishedstone_SetTile(map, pos);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 0.925f);

				break;
			}

			case CMap::tile_polishedstone_v0:
			case CMap::tile_polishedstone_v1:
			case CMap::tile_polishedstone_v2:
			case CMap::tile_polishedstone_v3:
			case CMap::tile_polishedstone_v4:
			case CMap::tile_polishedstone_v5:
			case CMap::tile_polishedstone_v6:
			case CMap::tile_polishedstone_v7:
			case CMap::tile_polishedstone_v8:
			case CMap::tile_polishedstone_v9:
			case CMap::tile_polishedstone_v10:
			case CMap::tile_polishedstone_v11:
			case CMap::tile_polishedstone_v12:
			case CMap::tile_polishedstone_v13:
			case CMap::tile_polishedstone_v14:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				break;

			case CMap::tile_polishedstone_d0:
			case CMap::tile_polishedstone_d1:
			case CMap::tile_polishedstone_d2:
			case CMap::tile_polishedstone_d3:
			case CMap::tile_polishedstone_d4:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				OnPolishedStoneTileHit(map, index);
				break;

			case CMap::tile_bpolishedstone:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				bpolishedstone_SetTile(map, pos);
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::SOLID | Tile::LIGHT_SOURCE | Tile::COLLISION);

				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 0.925f);

				break;
			}

			case CMap::tile_bpolishedstone_v0:
			case CMap::tile_bpolishedstone_v1:
			case CMap::tile_bpolishedstone_v2:
			case CMap::tile_bpolishedstone_v3:
			case CMap::tile_bpolishedstone_v4:
			case CMap::tile_bpolishedstone_v5:
			case CMap::tile_bpolishedstone_v6:
			case CMap::tile_bpolishedstone_v7:
			case CMap::tile_bpolishedstone_v8:
			case CMap::tile_bpolishedstone_v9:
			case CMap::tile_bpolishedstone_v10:
			case CMap::tile_bpolishedstone_v11:
			case CMap::tile_bpolishedstone_v12:
			case CMap::tile_bpolishedstone_v13:
			case CMap::tile_bpolishedstone_v14:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::SOLID | Tile::LIGHT_SOURCE | Tile::COLLISION);
				break;

			case CMap::tile_bpolishedstone_d0:
			case CMap::tile_bpolishedstone_d1:
			case CMap::tile_bpolishedstone_d2:
			case CMap::tile_bpolishedstone_d3:
			case CMap::tile_bpolishedstone_d4:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::SOLID | Tile::LIGHT_SOURCE | Tile::COLLISION);
				OnBackPolishedStoneTileHit(map, index);
				break;
		}
	}
}

void OnSnowTileHit(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);
		for (int i = 0; i < 3; i++)
		{
			Vec2f vel = getRandomVelocity( 0.6f, 2.0f, 180.0f);
			vel.y = -Maths::Abs(vel.y)+Maths::Abs(vel.x)/4.0f-2.0f-float(XORRandom(100))/100.0f;
			SColor color = (XORRandom(10) % 2 == 1) ? SColor(255, 57, 51, 47)
			: SColor(255, 110, 100, 93);
			ParticlePixel(pos+Vec2f(4, 0), vel, color, true);
		}
		Sound::Play("dig_dirt" + (1 + XORRandom(3)), pos, 0.80f, 1.30f);
	}
}

void OnSnowTileDestroyed(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);
		for (int i = 0; i < 15; i++)
		{
			Vec2f vel = getRandomVelocity( 0.6f, 2.0f, 180.0f);
			vel.y = -Maths::Abs(vel.y)+Maths::Abs(vel.x)/4.0f-2.0f-float(XORRandom(100))/100.0f;
			SColor color = (XORRandom(10) % 2 == 1) ? SColor(255, 57, 51, 47)
			: SColor(255, 110, 100, 93);
			ParticlePixel(pos+Vec2f(4, 0), vel, color, true);
		}
		ParticleAnimated("Smoke.png", pos+Vec2f(4, 0),
		Vec2f(0, 0), 0.0f, 1.0f, 3, 0.0f, false);
		Sound::Play("destroy_dirt.ogg", pos, 0.80f, 1.30f);
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

		Sound::Play("GlassBreak2.ogg", pos, 1.0f, 0.8f);
		customSparks(pos, 1, rnd_vel(2,1,10.0f), SColor(255,25,75+XORRandom(75),200+XORRandom(55)));
	}
}

void OnIceTileDestroyed(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("GlassBreak1.ogg", pos, 1.0f, 0.7f);
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

		Sound::Play("dig_stone.ogg", pos, 1.0f, 0.95f);
		sparks(pos, 1, 1);
	}
}

void OnSteelTileDestroyed(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("destroy_stone.ogg", pos, 1.0f, 0.9f);
	}
}

void OnBackSteelTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);

	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("dig_stone.ogg", pos, 1.0f, 1.0f);
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

void elderbrick_SetTile(CMap@ map, Vec2f pos)
{
	Tile tile = map.getTile(pos);
	tile.dirt = 255;
	if (!isSolid(map, map.getTile(pos-Vec2f(0,8)).type))
		map.SetTile(map.getTileOffset(pos), CMap::tile_elderbrick_v0);
}

void OnElderBrickTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	map.RemoveTileFlag(index, Tile::LIGHT_PASSES);

	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("dig_stone.ogg", pos, 1.0f, 0.825f);
		sparks(pos, 1, 1);
	}
}

void OnElderBrickTileDestroyed(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("destroy_stone.ogg", pos, 1.0f, 0.75f);
	}
}

void polishedstone_SetTile(CMap@ map, Vec2f pos)
{
	map.SetTile(map.getTileOffset(pos), CMap::tile_polishedstone + polishedstone_GetMask(map, pos));

	for (u8 i = 0; i < 4; i++)
	{
		polishedstone_Update(map, pos + directions[i]);
	}
}

u8 polishedstone_GetMask(CMap@ map, Vec2f pos)
{
	u8 mask = 0;

	for (u8 i = 0; i < 4; i++)
	{
		if (checkPolishedStoneTile(map, pos + directions[i])) mask |= 1 << i;
	}

	return mask;
}

void polishedstone_Update(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	if (checkPolishedStoneTile(map, pos))
		map.SetTile(map.getTileOffset(pos),CMap::tile_polishedstone+polishedstone_GetMask(map,pos));
}

void OnPolishedStoneTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	map.RemoveTileFlag(index, Tile::LIGHT_PASSES);

	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 0.95f);
	}
}

void OnPolishedStoneTileDestroyed(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("destroy_wall.ogg", pos, 1.0f, 0.9f);
	}
}

void bpolishedstone_SetTile(CMap@ map, Vec2f pos)
{
	map.SetTile(map.getTileOffset(pos), CMap::tile_bpolishedstone + bpolishedstone_GetMask(map, pos));

	for (u8 i = 0; i < 4; i++)
	{
		bpolishedstone_Update(map, pos + directions[i]);
	}
}

u8 bpolishedstone_GetMask(CMap@ map, Vec2f pos)
{
	u8 mask = 0;

	for (u8 i = 0; i < 4; i++)
	{
		if (checkBackPolishedStoneTile(map, pos + directions[i])) mask |= 1 << i;
	}

	return mask;
}

void bpolishedstone_Update(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	if (checkBackPolishedStoneTile(map, pos))
		map.SetTile(map.getTileOffset(pos),CMap::tile_bpolishedstone+bpolishedstone_GetMask(map,pos));
}

void OnBackPolishedStoneTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
	map.RemoveTileFlag(index, Tile::SOLID | Tile::LIGHT_SOURCE | Tile::COLLISION);

	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 0.9f);
	}
}

void OnBackPolishedStoneTileDestroyed(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("destroy_wall.ogg", pos, 1.0f, 0.85f);
	}
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

void bglass_SetTile(CMap@ map, Vec2f pos)
{
	map.SetTile(map.getTileOffset(pos), CMap::tile_bglass + bglass_GetMask(map, pos));

	for (u8 i = 0; i < 4; i++)
	{
		bglass_Update(map, pos + directions[i]);
	}
}

void bglass_Update(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	if (checkBackGlassTile(map, pos))
		map.server_SetTile(pos,CMap::tile_bglass+bglass_GetMask(map,pos));
}

void OnBackGlassTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES | Tile::LIGHT_SOURCE);

	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("GlassBreak2.ogg", pos, 1.0f, 1.0f);
	}
}

// these are required only for getMask functions
bool checkPolishedStoneTile(CMap@ map, Vec2f pos) 
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_polishedstone && tile <= CMap::tile_polishedstone_v14;
}

bool checkBackGlassTile(CMap@ map, Vec2f pos) 
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_bglass && tile <= CMap::tile_bglass_v14;
}

bool checkBackPolishedStoneTile(CMap@ map, Vec2f pos) 
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_bpolishedstone && tile <= CMap::tile_bpolishedstone_v14;
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