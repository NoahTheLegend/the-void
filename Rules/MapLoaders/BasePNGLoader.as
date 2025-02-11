// BasePNGLoader.as
// NSFL if you don't unzoom it out in your editor

// Note for modders upgrading their mod, handlePixel's signature has changed recently!

#include "LoaderColors.as";
#include "LoaderUtilities.as";
#include "CustomBlocks.as";

enum WAROffset
{
	autotile_offset = 0,
	tree_offset,
	bush_offset,
	grain_offset,
	spike_offset,
	ladder_offset,
	offsets_count
};

//global
Random@ map_random = Random();

class PNGLoader
{
	PNGLoader()
	{
		offsets = int[][](offsets_count, int[](0));
	}

	CFileImage@ image;
	CMap@ map;

	int[][] offsets;

	int current_offset_count;

	bool loadMap(CMap@ _map, const string& in filename)
	{
		@map = _map;
		@map_random = Random();

		if(!getNet().isServer())
		{
			SetupMap(0, 0);
			SetupBackgrounds();

			return true;
		}

		@image = CFileImage( filename );

		if(image.isLoaded())
		{
			SetupMap(image.getWidth(), image.getHeight());
			SetupBackgrounds();

			while(image.nextPixel())
			{
				const SColor pixel = image.readPixel();
				const int offset = image.getPixelOffset();

				// Optimization: check if the pixel color is the sky color
				// We do this before calling handlePixel because it is overriden, and to avoid a SColor copy
				if (pixel.color != map_colors::sky)
				{
					handlePixel(pixel, offset);
				}

				getNet().server_KeepConnectionsAlive();
			}

			// late load - after placing tiles
			for(uint i = 0; i < offsets.length; ++i)
			{
				int[]@ offset_set = offsets[i];
				current_offset_count = offset_set.length;
				for(uint step = 0; step < current_offset_count; ++step)
				{
					handleOffset(i, offset_set[step], step, current_offset_count);
					getNet().server_KeepConnectionsAlive();
				}
			}
			return true;
		}
		return false;
	}

	// Queue an offset to be autotiled
	void autotile(int offset)
	{
		offsets[autotile_offset].push_back(offset);
	}

	void handlePixel(const SColor &in pixel, int offset)
	{
		u8 alpha = pixel.getAlpha();

		if (alpha < 255)
		{
			alpha &= ~0x80;
			const Vec2f position = getSpawnPosition(map, offset);

			//print("ARGB = "+alpha+", "+pixel.getRed()+", "+pixel.getGreen()+", "+pixel.getBlue());

			// TODO future reader, if the new angelscript release has arrived; consider using named arguments for spawnBlob etc if it doesn't clutter the lines too much.
			// It might be nice for things like the static argument.

			// Test color with alpha 255
			switch (pixel.color | 0xFF000000)
			{
				// Alpha spawn and flag
				case map_colors::alpha_spawn: autotile(offset); AddMarker(map, offset, "red main spawn"); break;
				case map_colors::alpha_flag:  autotile(offset); AddMarker(map, offset, "red spawn");      break;
			}
		}
		else
		{
			switch (pixel.color)
			{
			// Custom
			// tiles
			case map_colors::tile_ice:              map.SetTile(offset, CMap::tile_ice);              break;
			case map_colors::tile_thick_ice:    	map.SetTile(offset, CMap::tile_thick_ice);        break;
			case map_colors::tile_bice:    			map.SetTile(offset, CMap::tile_bice);   	      break;
			case map_colors::tile_glass:			map.SetTile(offset, CMap::tile_glass);            break;
			case map_colors::tile_bglass:           map.SetTile(offset, CMap::tile_bglass);           break;

			case map_colors::tile_steel:            map.SetTile(offset, CMap::tile_steel);            break;
			case map_colors::tile_bsteel:           map.SetTile(offset, CMap::tile_bsteel);           break;
			case map_colors::tile_caution:          map.SetTile(offset, CMap::tile_caution);          break;
			case map_colors::tile_caution_v0:       map.SetTile(offset, CMap::tile_caution_v0);       break;
			case map_colors::tile_caution_v1:       map.SetTile(offset, CMap::tile_caution_v1);       break;
			case map_colors::tile_caution_v2:       map.SetTile(offset, CMap::tile_caution_v2);       break;
			case map_colors::tile_polishedmetal:    map.SetTile(offset, CMap::tile_polishedmetal);    break;
			case map_colors::tile_bpolishedmetal:   map.SetTile(offset, CMap::tile_bpolishedmetal);   break;

			// blobs	
			//case map_colors::locker:     			autotile(offset); spawnBlob(map, "locker", offset); break;
			//case map_colors::barrel:     			autotile(offset); spawnBlob(map, "barrel", offset); break;
			case map_colors::locker_b:    			autotile(offset); spawnBlob(map, "locker", offset, 0); break;
			case map_colors::locker_r:    			autotile(offset); spawnBlob(map, "locker", offset, 1); break;
			case map_colors::barrel_b:    			autotile(offset); spawnBlob(map, "barrel", offset, 0); break;
			case map_colors::barrel_r:    			autotile(offset); spawnBlob(map, "barrel", offset, 1); break;
			case map_colors::core_b:				autotile(offset); spawnBlob(map, "core", offset, 0); break;
			case map_colors::core_r:				autotile(offset); spawnBlob(map, "core", offset, 1); break;
			// Light sources
			case map_colors::lamp_1x1_b_0: autotile(offset); spawnBlob(map, "lamp_1x1", offset, 0, true); break;
			case map_colors::lamp_1x1_r_0: autotile(offset); spawnBlob(map, "lamp_1x1", offset, 1, true); break;
			case map_colors::lamp_1x1_b_90: autotile(offset); spawnBlob(map, "lamp_1x1", offset, 0, true, Vec2f_zero, 90); break;
			case map_colors::lamp_1x1_r_90: autotile(offset); spawnBlob(map, "lamp_1x1", offset, 1, true, Vec2f_zero, 90); break;
			case map_colors::lamp_1x1_b_180: autotile(offset); spawnBlob(map, "lamp_1x1", offset, 0, true, Vec2f_zero, 180); break;
			case map_colors::lamp_1x1_r_180: autotile(offset); spawnBlob(map, "lamp_1x1", offset, 1, true, Vec2f_zero, 180); break;
			case map_colors::lamp_1x1_b_270: autotile(offset); spawnBlob(map, "lamp_1x1", offset, 0, true, Vec2f_zero, 270); break;
			case map_colors::lamp_1x1_r_270: autotile(offset); spawnBlob(map, "lamp_1x1", offset, 1, true, Vec2f_zero, 270); break;

			case map_colors::lamp_2x1_b_0: autotile(offset); spawnBlob(map, "lamp_2x1", offset, 0, true); break;
			case map_colors::lamp_2x1_r_0: autotile(offset); spawnBlob(map, "lamp_2x1", offset, 1, true); break;
			case map_colors::lamp_2x1_b_90: autotile(offset); spawnBlob(map, "lamp_2x1", offset, 0, true, Vec2f_zero, 90); break;
			case map_colors::lamp_2x1_r_90: autotile(offset); spawnBlob(map, "lamp_2x1", offset, 1, true, Vec2f_zero, 90); break;
			case map_colors::lamp_2x1_b_180: autotile(offset); spawnBlob(map, "lamp_2x1", offset, 0, true, Vec2f_zero, 180); break;
			case map_colors::lamp_2x1_r_180: autotile(offset); spawnBlob(map, "lamp_2x1", offset, 1, true, Vec2f_zero, 180); break;
			case map_colors::lamp_2x1_b_270: autotile(offset); spawnBlob(map, "lamp_2x1", offset, 0, true, Vec2f_zero, 270); break;
			case map_colors::lamp_2x1_r_270: autotile(offset); spawnBlob(map, "lamp_2x1", offset, 1, true, Vec2f_zero, 270); break;

			case map_colors::lamp_3x1_b_0: autotile(offset); spawnBlob(map, "lamp_3x1", offset, 0, true); break;
			case map_colors::lamp_3x1_r_0: autotile(offset); spawnBlob(map, "lamp_3x1", offset, 1, true); break;
			case map_colors::lamp_3x1_b_90: autotile(offset); spawnBlob(map, "lamp_3x1", offset, 0, true, Vec2f_zero, 90); break;
			case map_colors::lamp_3x1_r_90: autotile(offset); spawnBlob(map, "lamp_3x1", offset, 1, true, Vec2f_zero, 90); break;
			case map_colors::lamp_3x1_b_180: autotile(offset); spawnBlob(map, "lamp_3x1", offset, 0, true, Vec2f_zero, 180); break;
			case map_colors::lamp_3x1_r_180: autotile(offset); spawnBlob(map, "lamp_3x1", offset, 1, true, Vec2f_zero, 180); break;
			case map_colors::lamp_3x1_b_270: autotile(offset); spawnBlob(map, "lamp_3x1", offset, 0, true, Vec2f_zero, 270); break;
			case map_colors::lamp_3x1_r_270: autotile(offset); spawnBlob(map, "lamp_3x1", offset, 1, true, Vec2f_zero, 270); break;

			// Tiles
			case map_colors::tile_ground:           map.SetTile(offset, CMap::tile_ground);           break;
			case map_colors::tile_ground_back:      map.SetTile(offset, CMap::tile_ground_back);      break;
			case map_colors::tile_stone:            map.SetTile(offset, CMap::tile_stone);            break;
			case map_colors::tile_thickstone:       map.SetTile(offset, CMap::tile_thickstone);       break;
			case map_colors::tile_bedrock:          map.SetTile(offset, CMap::tile_bedrock);          break;
			case map_colors::tile_gold:             map.SetTile(offset, CMap::tile_gold);             break;
			case map_colors::tile_castle:           map.SetTile(offset, CMap::tile_castle);           break;
			case map_colors::tile_castle_back:      map.SetTile(offset, CMap::tile_castle_back);      break;
			case map_colors::tile_castle_moss:      map.SetTile(offset, CMap::tile_castle_moss);      break;
			case map_colors::tile_castle_back_moss: map.SetTile(offset, CMap::tile_castle_back_moss); break;
			case map_colors::tile_wood:             map.SetTile(offset, CMap::tile_wood);             break;
			case map_colors::tile_wood_back:        map.SetTile(offset, CMap::tile_wood_back);        break;
			case map_colors::tile_grass:            map.SetTile(offset, CMap::tile_grass + map_random.NextRanged(3)); break;

			// Water
			case map_colors::water_air:
				map.server_setFloodWaterOffset(offset, true);
			break;
			case map_colors::water_backdirt:
				map.server_setFloodWaterOffset(offset, true);
				map.SetTile(offset, CMap::tile_ground_back);
			break;

			// Ladders
			case map_colors::ladder:
			//case map_colors::tile_ladder_ground: // same as map_colors::ladder
			case map_colors::tile_ladder_castle:
			case map_colors::tile_ladder_wood:
				autotile(offset);
				offsets[ladder_offset].push_back( offset );
			break;

			default:
				
			};
		}
	}

	//override this to add post-load offset types.
	void handleOffset(int type, int offset, int position, int count)
	{
		switch (type)
		{
		case autotile_offset:
			PlaceMostLikelyTile(map, offset);
		break;
		case tree_offset:
		{
			// load trees only at the ground
			if(isSolid(map, map.getTile(offset + map.tilemapwidth).type)) return;

			CBlob@ tree = server_CreateBlobNoInit( "tree_pine" );
			if(tree !is null)
			{
				tree.Tag("startbig");
				tree.setPosition( getSpawnPosition( map, offset ) );
				tree.Init();
				if (map.getTile(offset).type == CMap::tile_empty)
				{
					map.SetTile(offset, CMap::tile_grass + map_random.NextRanged(3) );
				}
			}
		}
		break;
		case bush_offset:
			server_CreateBlob("bush", -1, map.getTileWorldPosition(offset) + Vec2f(4, 4));
		break;
		case grain_offset:
		{
			CBlob@ grain = server_CreateBlobNoInit("grain_plant");
			if(grain !is null)
			{
				grain.Tag("instant_grow");
				grain.setPosition( map.getTileWorldPosition(offset) + Vec2f(4, 4));
				grain.Init();
			}
		}
		break;
		case spike_offset:
			spawnBlob(map, "spikes", -1, map.getTileWorldPosition(offset) + Vec2f(4, 4), true);
		break;
		case ladder_offset:
			spawnLadder(map, offset);
		break;
		};
	}

	void SetupMap(int width, int height)
	{
		map.CreateTileMap(width, height, 8.0f, "Sprites/world.png");
	}

	void SetupBackgrounds()
	{
		// sky
		map.CreateSky(color_black, Vec2f(1.0f, 1.0f), 200, "Sprites/Back/cloud", 0);
		map.CreateSkyGradient("Sprites/skygradient.png"); // override sky color with gradient

		// background
		//map.AddBackground("Sprites/Back/BackgroundPlains.png", Vec2f(0.0f, -40.0f), Vec2f(0.06f, 20.0f), color_white);
		//map.AddBackground("Sprites/Back/BackgroundTrees.png", Vec2f(0.0f,  -100.0f), Vec2f(0.18f, 70.0f), color_white);
		//map.AddBackground("Sprites/Back/BackgroundIsland.png", Vec2f(0.0f, -220.0f), Vec2f(0.3f, 180.0f), color_white);

		// fade in
		SetScreenFlash(255,   0,   0,   0);
	}

	CBlob@ spawnLadder(CMap@ map, int offset)
	{
		bool up = false, down = false, right = false, left = false;
		int[]@ ladders = offsets[ladder_offset];
		for (uint step = 0; step < ladders.length; ++step)
		{
			const int lof = ladders[step];
			if (lof == offset-map.tilemapwidth) {
				up = true;
			}
			if (lof == offset+map.tilemapwidth) {
				down = true;
			}
			if (lof == offset+1) {
				right = true;
			}
			if (lof == offset-1) {
				left = true;
			}
		}
		if ( offset % 2 == 0 && ((left && right) || (up && down)) )
		{
			return null;
		}

		CBlob@ blob = server_CreateBlob( "ladder", -1, getSpawnPosition( map, offset) );
		if (blob !is null)
		{
			// check for horizontal placement
			for (uint step = 0; step < ladders.length; ++step)
			{
				if (ladders[step] == offset-1 || ladders[step] == offset+1)
				{
					blob.setAngleDegrees( 90.0f );
					break;
				}
			}
			blob.getShape().SetStatic( true );
		}
		return blob;
	}
}

void PlaceMostLikelyTile(CMap@ map, int offset)
{
	const TileType up = map.getTile(offset - map.tilemapwidth).type;
	const TileType down = map.getTile(offset + map.tilemapwidth).type;
	const TileType left = map.getTile(offset - 1).type;
	const TileType right = map.getTile(offset + 1).type;

	if (up != CMap::tile_empty)
	{
		const TileType[] neighborhood = { up, down, left, right };

		if ((neighborhood.find(CMap::tile_castle) != -1) ||
		    (neighborhood.find(CMap::tile_castle_back) != -1))
		{
			map.SetTile(offset, CMap::tile_castle_back);
		}
		else if ((neighborhood.find(CMap::tile_wood) != -1) ||
		         (neighborhood.find(CMap::tile_wood_back) != -1))
		{
			map.SetTile(offset, CMap::tile_wood_back );
		}
		else if ((neighborhood.find(CMap::tile_ground) != -1) ||
		         (neighborhood.find(CMap::tile_ground_back) != -1))
		{
			map.SetTile(offset, CMap::tile_ground_back);
		}
		// metal tiles
		else if ((neighborhood.find(CMap::tile_steel) != -1 ||
				  neighborhood.find(CMap::tile_bsteel) != -1 ||
				  neighborhood.find(CMap::tile_polishedmetal) != -1 ||
				  neighborhood.find(CMap::tile_bpolishedmetal) != -1 ||
				  neighborhood.find(CMap::tile_caution) != -1))
		{
			map.SetTile(offset, CMap::tile_bsteel);
		}
		// ice
		else if ((neighborhood.find(CMap::tile_ice) != -1 ||
				  neighborhood.find(CMap::tile_thick_ice) != -1 ||
				  neighborhood.find(CMap::tile_bice) != -1))
		{
			map.SetTile(offset, CMap::tile_bice);
		}
		// glass
		else if ((neighborhood.find(CMap::tile_glass) != -1 ||
				  neighborhood.find(CMap::tile_bglass) != -1))
		{
			map.SetTile(offset, CMap::tile_bglass);
		}
	}
	else if(isSolid(map, down) && (map.isTileGrass(left) || map.isTileGrass(right)))
	{
		map.SetTile(offset, CMap::tile_grass + 2 + map_random.NextRanged(2));
	}
}

u8 getTeamFromChannel(u8 channel)
{
	// only the bits we want
	channel &= 0x0F;

	return (channel > 7)? 255 : channel;
}

u8 getChannelFromTeam(u8 team)
{
	return (team > 7)? 0x0F : team;
}

u16 getAngleFromChannel(u8 channel)
{
	// only the bits we want
	channel &= 0x30;

	switch(channel)
	{
		case 16: return 90;
		case 32: return 180;
		case 48: return 270;
	}

	return 0;
}

u8 getChannelFromAngle(u16 angle)
{
	switch(angle)
	{
		case  90: return 16;
		case 180: return 32;
		case 270: return 48;
	}

	return 0;
}

Vec2f getSpawnPosition(CMap@ map, int offset)
{
	Vec2f pos = map.getTileWorldPosition(offset);
	f32 tile_offset = map.tilesize * 0.5f;
	pos.x += tile_offset;
	pos.y += tile_offset;
	return pos;
}

CBlob@ spawnHall(CMap@ map, int offset, u8 team)
{
	CBlob@ hall = spawnBlob(map, "hall", offset, team);
	if (hall !is null) // add research to first hall
	{
		hall.AddScript("Researching.as");
		hall.Tag("script added");
	}
	return @hall;
}

CBlob@ spawnBlob(CMap@ map, const string &in name, u8 team, Vec2f position)
{
	return server_CreateBlob(name, team, position);
}

CBlob@ spawnBlob(CMap@ map, const string &in name, u8 team, Vec2f position, const bool fixed)
{
	CBlob@ blob = server_CreateBlob(name, team, position);
	blob.getShape().SetStatic(fixed);

	return blob;
}

CBlob@ spawnBlob(CMap@ map, const string &in name, u8 team, Vec2f position, s16 angle)
{
	CBlob@ blob = server_CreateBlob(name, team, position);
	blob.setAngleDegrees(angle);

	return blob;
}

CBlob@ spawnBlob(CMap@ map, const string &in name, u8 team, Vec2f position, s16 angle, const bool fixed)
{
	CBlob@ blob = spawnBlob(map, name, team, position, angle);
	blob.getShape().SetStatic(fixed);

	return blob;
}

CBlob@ spawnBlob(CMap@ map, const string& in name, int offset, u8 team = 255, bool attached_to_map = false, Vec2f posOffset = Vec2f_zero, s16 angle = 0)
{
	return spawnBlob(map, name, team, getSpawnPosition(map, offset) + posOffset, angle, attached_to_map);
}

CBlob@ spawnVehicle(CMap@ map, const string& in name, int offset, int team = -1)
{
	CBlob@ blob = server_CreateBlob(name, team, getSpawnPosition( map, offset));
	if(blob !is null)
	{
		blob.RemoveScript("DecayIfLeftAlone.as");
	}
	return blob;
}

void AddMarker(CMap@ map, int offset, const string& in name)
{
	map.AddMarker(map.getTileWorldPosition(offset), name);
}

void SaveMap(CMap@ map, const string &in fileName)
{
	const u32 width = map.tilemapwidth;
	const u32 height = map.tilemapheight;
	const u32 space = width * height;

	CFileImage image(width, height, true);
	image.setFilename(fileName, IMAGE_FILENAME_BASE_MAPS);

	// image starts at -1, 0
	image.nextPixel();

	// iterate through tiles
	for(uint i = 0; i < space; i++)
	{
		SColor color = getColorFromTileType(map.getTile(i).type);
		if(map.isInWater(map.getTileWorldPosition(i)))
		{
			if(color == map_colors::sky)
			{
				color = map_colors::water_air;
			}
			else
			{
				color = map_colors::water_backdirt;
			}
		}
		image.setPixelAndAdvance(color);
	}

	// iterate through blobs
	CBlob@[] blobs;
	getBlobs(@blobs);
	for(uint i = 0; i < blobs.length; i++)
	{
		CBlob@ blob = blobs[i];
		if(blob.getShape() is null) continue;

		SColor color;
		Vec2f offset;

		getInfoFromBlob(blob, color, offset);
		if(color == map_colors::unused) continue;

		const Vec2f position = map.getTileSpacePosition(blob.getPosition() + offset);

		image.setPixelAtPosition(position.x, position.y, color, false);
	}

	// iterate through markers
	const array<string> TEAM_NAME =
	{
		"blue",
		"red",
		"green",
		"purple",
		"orange",
		"aqua",
		"teal",
		"gray"
	};

	for(u8 i = 0; i < TEAM_NAME.length; i++)
	{
		array<Vec2f> position;

		SColor color;

		if(map.getMarkers(TEAM_NAME[i]+" main spawn", @position))
		{
			for(u8 j = 0; j < position.length; j++)
			{
				color = map_colors::alpha_spawn;
				color.setAlpha(0x80 | getChannelFromTeam(i));
				position[j] = map.getTileSpacePosition(position[j]);

				image.setPixelAtPosition(position[j].x, position[j].y, color, false);
			}
		}

		position.clear();
		if(map.getMarkers(TEAM_NAME[i]+" spawn", @position))
		{
			for(u8 j = 0; j < position.length; j++)
			{
				color = map_colors::alpha_flag;
				color.setAlpha(0x80 | getChannelFromTeam(i));
				position[j] = map.getTileSpacePosition(position[j]);

				image.setPixelAtPosition(position[j].x, position[j].y, color, false);
			}
		}
	}

	image.Save();
}

void getInfoFromBlob(CBlob@ this, SColor &out color, Vec2f &out offset)
{
	const string name = this.getName();

	// declare some default values
	color = map_colors::unused;
	offset = Vec2f_zero;

	// BLOCKS
	if(this.getShape().isStatic())
	{
		if(name == "ladder")
		{
			color = map_colors::alpha_ladder;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "spikes")
		{
			color = map_colors::alpha_spikes;
			color.setAlpha(getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "stone_door")
		{
			color = map_colors::alpha_stone_door;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "trap_block")
		{
			color = map_colors::alpha_trap_block;
			color.setAlpha(getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "bridge")
		{
			color = map_colors::alpha_bridge;
			color.setAlpha(getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "wooden_door")
		{
			color = map_colors::alpha_wooden_door;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "wooden_platform")
		{
			color = map_colors::alpha_wooden_platform;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		// MECHANISMS
		else if(name == "coin_slot")
		{
			color = map_colors::alpha_coin_slot;
			color.setAlpha(getChannelFromTeam(255));
		}
		else if(name == "lever")
		{
			color = map_colors::alpha_lever;
			color.setAlpha(getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "pressure_plate")
		{
			color = map_colors::alpha_pressure_plate;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()));
		}
		else if(name == "push_button")
		{
			color = map_colors::alpha_push_button;
			color.setAlpha(getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "sensor")
		{
			color = map_colors::alpha_sensor;
			color.setAlpha(getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "diode")
		{
			color = map_colors::alpha_diode;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "elbow")
		{
			color = map_colors::alpha_elbow;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "emitter")
		{
			color = map_colors::alpha_emitter;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "inverter")
		{
			color = map_colors::alpha_inverter;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "junction")
		{
			color = map_colors::alpha_junction;
			color.setAlpha(getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "magazine")
		{
			color = map_colors::alpha_magazine;

			const string[] MAGAZINE_ITEM = {
			"mat_bombs",
			"mat_waterbombs",
			"mat_arrows",
			"mat_waterarrows",
			"mat_firearrows",
			"mat_bombarrows",
			"food"};

			u8 alpha = MAGAZINE_ITEM.length;

			CInventory@ inventory = this.getInventory();
			if(inventory.isFull())
			{
				CBlob@ blob = inventory.getItem(0);

				s8 element = MAGAZINE_ITEM.find(blob.getName());
				if(element != -1)
				{
					alpha = element;
				}
			}
			color.setAlpha(alpha);
		}
		else if(name == "oscillator")
		{
			color = map_colors::alpha_oscillator;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "randomizer")
		{
			color = map_colors::alpha_randomizer;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "receiver")
		{
			color = map_colors::alpha_receiver;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "resistor")
		{
			color = map_colors::alpha_resistor;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "tee")
		{
			color = map_colors::alpha_tee;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "toggle")
		{
			color = map_colors::alpha_toggle;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "transistor")
		{
			color = map_colors::alpha_transistor;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "wire")
		{
			color = map_colors::alpha_wire;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()) | getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "bolter")
		{
			color = map_colors::alpha_bolter;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()));
		}
		else if(name == "dispenser")
		{
			color = map_colors::alpha_dispenser;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()));
		}
		else if(name == "lamp")
		{
			color = map_colors::alpha_lamp;
			color.setAlpha(getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "obstructor")
		{
			color = map_colors::alpha_obstructor;
			color.setAlpha(getChannelFromTeam(this.getTeamNum()));
		}
		else if(name == "spiker")
		{
			color = map_colors::alpha_spiker;
			color.setAlpha(getChannelFromAngle(this.getAngleDegrees()));
		}
	}

	// FLORA
	if(name == "bush")
	{
		color = map_colors::bush;
	}
	else if(name == "flowers")
	{
		color = map_colors::flowers;
	}
	else if(name == "grain_plant")
	{
		color = map_colors::grain;
	}
	else if(name == "tree_pine" || name == "tree_bushy")
	{
		color = map_colors::tree;
	}
	// FAUNA
	else if(name == "bison")
	{
		color = map_colors::bison;
	}
	else if(name == "chicken")
	{
		color = map_colors::chicken;
	}
	else if(name == "fishy")
	{
		color = map_colors::fish;
	}
	else if(name == "shark")
	{
		color = map_colors::shark;
	}

	// set last bit to true so the minimum alpha is 128
	u8 alpha = color.getAlpha();
	if(alpha != 0xFF)
	{
		color.setAlpha(0x80 | alpha);
	}
}

SColor getColorFromTileType(TileType tile)
{
	if(tile >= TILE_LUT.length)
	{
		return map_colors::unused;
	}
	return TILE_LUT[tile];
}

const SColor[] TILE_LUT = {
map_colors::unused,                // |   0 |
map_colors::unused,                // |   1 |
map_colors::unused,                // |   2 |
map_colors::unused,                // |   3 |
map_colors::unused,                // |   4 |
map_colors::unused,                // |   5 |
map_colors::unused,                // |   6 |
map_colors::unused,                // |   7 |
map_colors::unused,                // |   8 |
map_colors::unused,                // |   9 |
map_colors::unused,                // |  10 |
map_colors::unused,                // |  11 |
map_colors::unused,                // |  12 |
map_colors::unused,                // |  13 |
map_colors::unused,                // |  14 |
map_colors::unused,                // |  15 |
map_colors::tile_ground,           // |  16 |
map_colors::tile_ground,           // |  17 |
map_colors::tile_ground,           // |  18 |
map_colors::tile_ground,           // |  19 |
map_colors::tile_ground,           // |  20 |
map_colors::tile_ground,           // |  21 |
map_colors::tile_ground,           // |  22 |
map_colors::tile_ground,           // |  23 |
map_colors::tile_ground,           // |  24 |
map_colors::tile_grass,            // |  25 |
map_colors::tile_grass,            // |  26 |
map_colors::tile_grass,            // |  27 |
map_colors::tile_grass,            // |  28 |
map_colors::tile_ground,           // |  29 | damaged
map_colors::tile_ground,           // |  30 | damaged
map_colors::tile_ground,           // |  31 | damaged
map_colors::tile_ground_back,      // |  32 |
map_colors::tile_ground_back,      // |  33 |
map_colors::tile_ground_back,      // |  34 |
map_colors::tile_ground_back,      // |  35 |
map_colors::tile_ground_back,      // |  36 |
map_colors::tile_ground_back,      // |  37 |
map_colors::tile_ground_back,      // |  38 |
map_colors::tile_ground_back,      // |  39 |
map_colors::tile_ground_back,      // |  40 |
map_colors::tile_ground_back,      // |  41 |
map_colors::unused,                // |  42 |
map_colors::unused,                // |  43 |
map_colors::unused,                // |  44 |
map_colors::unused,                // |  45 |
map_colors::unused,                // |  46 |
map_colors::unused,                // |  47 |
map_colors::tile_castle,           // |  48 |
map_colors::tile_castle,           // |  49 |
map_colors::tile_castle,           // |  50 |
map_colors::tile_castle,           // |  51 |
map_colors::tile_castle,           // |  52 |
map_colors::tile_castle,           // |  53 |
map_colors::tile_castle,           // |  54 |
map_colors::unused,                // |  55 |
map_colors::unused,                // |  56 |
map_colors::unused,                // |  57 |
map_colors::tile_castle,           // |  58 | damaged
map_colors::tile_castle,           // |  59 | damaged
map_colors::tile_castle,           // |  60 | damaged
map_colors::tile_castle,           // |  61 | damaged
map_colors::tile_castle,           // |  62 | damaged
map_colors::tile_castle,           // |  63 | damaged
map_colors::tile_castle_back,      // |  64 |
map_colors::tile_castle_back,      // |  65 |
map_colors::tile_castle_back,      // |  66 |
map_colors::tile_castle_back,      // |  67 |
map_colors::tile_castle_back,      // |  68 |
map_colors::tile_castle_back,      // |  69 |
map_colors::unused,                // |  70 |
map_colors::unused,                // |  71 |
map_colors::unused,                // |  72 |
map_colors::unused,                // |  73 |
map_colors::unused,                // |  74 |
map_colors::unused,                // |  75 |
map_colors::tile_castle_back,      // |  76 | damaged
map_colors::tile_castle_back,      // |  77 | damaged
map_colors::tile_castle_back,      // |  78 | damaged
map_colors::tile_castle_back,      // |  79 | damaged
map_colors::tile_gold,             // |  80 |
map_colors::tile_gold,             // |  81 |
map_colors::tile_gold,             // |  82 |
map_colors::tile_gold,             // |  83 |
map_colors::tile_gold,             // |  84 |
map_colors::tile_gold,             // |  85 |
map_colors::unused,                // |  86 |
map_colors::unused,                // |  87 |
map_colors::unused,                // |  88 |
map_colors::unused,                // |  89 |
map_colors::tile_gold,             // |  90 | damaged
map_colors::tile_gold,             // |  91 | damaged
map_colors::tile_gold,             // |  92 | damaged
map_colors::tile_gold,             // |  93 | damaged
map_colors::tile_gold,             // |  94 | damaged
map_colors::unused,                // |  95 |
map_colors::tile_stone,            // |  96 |
map_colors::tile_stone,            // |  97 |
map_colors::unused,                // |  98 |
map_colors::unused,                // |  99 |
map_colors::tile_stone,            // | 100 | damaged
map_colors::tile_stone,            // | 101 | damaged
map_colors::tile_stone,            // | 102 | damaged
map_colors::tile_stone,            // | 103 | damaged
map_colors::tile_stone,            // | 104 | damaged
map_colors::unused,                // | 105 |
map_colors::tile_bedrock,          // | 106 |
map_colors::tile_bedrock,          // | 107 |
map_colors::tile_bedrock,          // | 108 |
map_colors::tile_bedrock,          // | 109 |
map_colors::tile_bedrock,          // | 110 |
map_colors::tile_bedrock,          // | 111 |
map_colors::unused,                // | 112 |
map_colors::unused,                // | 113 |
map_colors::unused,                // | 114 |
map_colors::unused,                // | 115 |
map_colors::unused,                // | 116 |
map_colors::unused,                // | 117 |
map_colors::unused,                // | 118 |
map_colors::unused,                // | 119 |
map_colors::unused,                // | 120 |
map_colors::unused,                // | 121 |
map_colors::unused,                // | 122 |
map_colors::unused,                // | 123 |
map_colors::unused,                // | 124 |
map_colors::unused,                // | 125 |
map_colors::unused,                // | 126 |
map_colors::unused,                // | 127 |
map_colors::unused,                // | 128 |
map_colors::unused,                // | 129 |
map_colors::unused,                // | 130 |
map_colors::unused,                // | 131 |
map_colors::unused,                // | 132 |
map_colors::unused,                // | 133 |
map_colors::unused,                // | 134 |
map_colors::unused,                // | 135 |
map_colors::unused,                // | 136 |
map_colors::unused,                // | 137 |
map_colors::unused,                // | 138 |
map_colors::unused,                // | 139 |
map_colors::unused,                // | 140 |
map_colors::unused,                // | 141 |
map_colors::unused,                // | 142 |
map_colors::unused,                // | 143 |
map_colors::unused,                // | 144 |
map_colors::unused,                // | 145 |
map_colors::unused,                // | 146 |
map_colors::unused,                // | 147 |
map_colors::unused,                // | 148 |
map_colors::unused,                // | 149 |
map_colors::unused,                // | 150 |
map_colors::unused,                // | 151 |
map_colors::unused,                // | 152 |
map_colors::unused,                // | 153 |
map_colors::unused,                // | 154 |
map_colors::unused,                // | 155 |
map_colors::unused,                // | 156 |
map_colors::unused,                // | 157 |
map_colors::unused,                // | 158 |
map_colors::unused,                // | 159 |
map_colors::unused,                // | 160 |
map_colors::unused,                // | 161 |
map_colors::unused,                // | 162 |
map_colors::unused,                // | 163 |
map_colors::unused,                // | 164 |
map_colors::unused,                // | 165 |
map_colors::unused,                // | 166 |
map_colors::unused,                // | 167 |
map_colors::unused,                // | 168 |
map_colors::unused,                // | 169 |
map_colors::unused,                // | 170 |
map_colors::unused,                // | 171 |
map_colors::unused,                // | 172 |
map_colors::tile_wood_back,        // | 173 |
map_colors::unused,                // | 174 |
map_colors::unused,                // | 175 |
map_colors::unused,                // | 176 |
map_colors::unused,                // | 177 |
map_colors::unused,                // | 178 |
map_colors::unused,                // | 179 |
map_colors::unused,                // | 180 |
map_colors::unused,                // | 181 |
map_colors::unused,                // | 182 |
map_colors::unused,                // | 183 |
map_colors::unused,                // | 184 |
map_colors::unused,                // | 185 |
map_colors::unused,                // | 186 |
map_colors::unused,                // | 187 |
map_colors::unused,                // | 188 |
map_colors::unused,                // | 189 |
map_colors::unused,                // | 190 |
map_colors::unused,                // | 191 |
map_colors::unused,                // | 192 |
map_colors::unused,                // | 193 |
map_colors::unused,                // | 194 |
map_colors::unused,                // | 195 |
map_colors::tile_wood,             // | 196 |
map_colors::tile_wood,             // | 197 |
map_colors::tile_wood,             // | 198 |
map_colors::unused,                // | 199 |
map_colors::tile_wood,             // | 200 | damaged
map_colors::tile_wood,             // | 201 | damaged
map_colors::tile_wood,             // | 202 | damaged
map_colors::tile_wood,             // | 203 | damaged
map_colors::tile_wood,             // | 204 | damaged
map_colors::tile_wood_back,        // | 205 |
map_colors::tile_wood_back,        // | 206 |
map_colors::tile_wood_back,        // | 207 | damaged
map_colors::tile_thickstone,       // | 208 |
map_colors::tile_thickstone,       // | 209 |
map_colors::unused,                // | 210 |
map_colors::unused,                // | 211 |
map_colors::unused,                // | 212 |
map_colors::unused,                // | 213 |
map_colors::tile_thickstone,       // | 214 | damaged
map_colors::tile_thickstone,       // | 215 | damaged
map_colors::tile_thickstone,       // | 216 | damaged
map_colors::tile_thickstone,       // | 217 | damaged
map_colors::tile_thickstone,       // | 218 | damaged
map_colors::unused,                // | 219 |
map_colors::unused,                // | 220 |
map_colors::unused,                // | 221 |
map_colors::unused,                // | 222 |
map_colors::unused,                // | 223 |
map_colors::tile_castle_moss,      // | 224 |
map_colors::tile_castle_moss,      // | 225 |
map_colors::tile_castle_moss,      // | 226 |
map_colors::tile_castle_back_moss, // | 227 |
map_colors::tile_castle_back_moss, // | 228 |
map_colors::tile_castle_back_moss, // | 229 |
map_colors::tile_castle_back_moss, // | 230 |
map_colors::tile_castle_back_moss, // | 231 |
map_colors::unused,                // | 232 |
map_colors::unused,                // | 233 |
map_colors::unused,                // | 234 |
map_colors::unused,                // | 235 |
map_colors::unused,                // | 236 |
map_colors::unused,                // | 237 |
map_colors::unused,                // | 238 |
map_colors::unused,                // | 239 |
map_colors::unused,                // | 240 |
map_colors::unused,                // | 241 |
map_colors::unused,                // | 242 |
map_colors::unused,                // | 243 |
map_colors::unused,                // | 244 |
map_colors::unused,                // | 245 |
map_colors::unused,                // | 246 |
map_colors::unused,                // | 247 |
map_colors::unused,                // | 248 |
map_colors::unused,                // | 249 |
map_colors::unused,                // | 250 |
map_colors::unused,                // | 251 |
map_colors::unused,                // | 252 |
map_colors::unused,                // | 253 |
map_colors::unused,                // | 254 |
map_colors::unused};               // | 255 |