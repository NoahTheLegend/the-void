#include "ShadowCastHooks.as"
#include "CustomBlocks.as";

void onInit(CRules@ this)
{
    if(isClient())
	{
		this.set_s32("render_id", -1);
        Texture::createFromFile("shadow_tex", "pixel.png");
        //Texture::createFromFile("overlay", "cosmos.png");
        onReload(this);
    }
}

SMaterial shadow_material;
const float SHADOW_FAR_PLANE = 10.0f;
const float SHADOW_NEAR_PLANE = 0.0f;

/*
const float override_z = 100.0f;
SMesh override_z_mesh;
SMaterial override_z_material;

const float overlay_z = 0.000001f;
SMesh overlay_mesh;
SMaterial overlay_material;
*/

void onReload(CRules@ this)
{
    if(isClient())
	{
        print("-------SHADOWCAST INIT-------");
        // set up map hooks
        MAP_LOAD_CALLBACK@ map_load_func = @onMapLoad;
        this.set("MAP_LOAD_CALLBACK", @map_load_func);

        SET_TILE_CALLBACK@ set_tile_func = @onSetTile;
        this.set("SET_TILE_CALLBACK", @set_tile_func);

        //since we just created it that means map didnt called it, call it ourselves
        onMapLoad(getMap().tilemapwidth, getMap().tilemapheight);

		int id = this.get_s32("render_id");
		if(id != -1) Render::RemoveScript(id);

        id = Render::addScript(Render::layer_postworld, getCurrentScriptName(), "Render", 0);
		this.set_s32("render_id", id);

        shadow_material.AddTexture("shadow_tex");
        shadow_material.SetFlag(SMaterial::COLOR_MASK, true);
        shadow_material.SetFlag(SMaterial::COLOR_MATERIAL, true);
        shadow_material.SetFlag(SMaterial::LIGHTING, false);
        shadow_material.SetFlag(SMaterial::ZBUFFER, true);
        shadow_material.SetFlag(SMaterial::ZWRITE_ENABLE, true);
        shadow_material.SetFlag(SMaterial::FRONT_FACE_CULLING, false);
        shadow_material.SetFlag(SMaterial::BACK_FACE_CULLING, true);
        shadow_material.SetFlag(SMaterial::FOG_ENABLE, false);
        shadow_material.SetFlag(SMaterial::TEXTURE_WRAP, false);
        shadow_material.SetFlag(SMaterial::BILINEAR_FILTER, false);
        shadow_material.SetFlag(SMaterial::TRILINER_FILTER, false);
        shadow_material.SetFlag(SMaterial::ANISOTROPIC_FILTER, false);
        shadow_material.SetMaterialType(SMaterial::SOLID);

/*
        override_z_material.AddTexture("pixel.png");
        override_z_material.SetFlag(SMaterial::COLOR_MASK, true);
        override_z_material.SetFlag(SMaterial::COLOR_MATERIAL, false);
        override_z_material.SetFlag(SMaterial::ZBUFFER, true);
        override_z_material.SetFlag(SMaterial::ZWRITE_ENABLE, true);
        override_z_material.SetFlag(SMaterial::LIGHTING, false);
        //override_z_material.SetFlag(SMaterial::BLEND_OPERATION, true);
        override_z_material.SetFlag(SMaterial::FOG_ENABLE, false);
        override_z_material.SetFlag(SMaterial::TEXTURE_WRAP, false);
        override_z_material.SetFlag(SMaterial::BILINEAR_FILTER, false);
        override_z_material.SetFlag(SMaterial::TRILINER_FILTER, false);
        override_z_material.SetFlag(SMaterial::ANISOTROPIC_FILTER, false);
        override_z_material.SetMaterialType(SMaterial::SOLID);
        //override_z_material.SetBlendOperation(SMaterial::BlendType::NONE);


        overlay_material.AddTexture("overlay");
        overlay_material.SetFlag(SMaterial::COLOR_MASK, true);
        overlay_material.SetFlag(SMaterial::COLOR_MATERIAL, true);
        overlay_material.SetFlag(SMaterial::ZBUFFER, true);
        overlay_material.SetFlag(SMaterial::ZWRITE_ENABLE, true);
        overlay_material.SetFlag(SMaterial::LIGHTING, false);
        //overlay_material.SetFlag(SMaterial::BLEND_OPERATION, true);
        overlay_material.SetFlag(SMaterial::FOG_ENABLE, false);
        overlay_material.SetFlag(SMaterial::TEXTURE_WRAP, false);
        overlay_material.SetFlag(SMaterial::BILINEAR_FILTER, false);
        overlay_material.SetFlag(SMaterial::TRILINER_FILTER, false);
        overlay_material.SetFlag(SMaterial::ANISOTROPIC_FILTER, false);
        overlay_material.SetMaterialType(SMaterial::SOLID);
        //overlay_material.SetBlendOperation(SMaterial::BlendType::NONE);

        Vertex[] verts = 
        {
            Vertex(0.0f, 0.0f, override_z, 0.0f, 0.0f, color_white),
            Vertex(1.0f, 0.0f, override_z, 1.0f, 0.0f, color_white),
            Vertex(1.0f, 1.0f, override_z, 1.0f, 1.0f, color_white),
            Vertex(0.0f, 1.0f, override_z, 0.0f, 1.0f, color_white)
        };
        uint16[] indices = 
        {
            0, 1, 2,
            0, 2, 3
        };

        override_z_mesh.SetVertex(verts);
        override_z_mesh.SetIndices(indices);
        override_z_mesh.SetDirty(SMesh::Buffer::VERTEX_INDEX);
        override_z_mesh.SetHardwareMapping(SMesh::Map::STATIC);
        override_z_mesh.BuildMesh();

        verts[0].z = overlay_z;
        verts[1].z = overlay_z;
        verts[2].z = overlay_z;
        verts[3].z = overlay_z;

        overlay_mesh.SetVertex(verts);
        overlay_mesh.SetIndices(indices);
        overlay_mesh.SetDirty(SMesh::Buffer::VERTEX_INDEX);
        overlay_mesh.SetHardwareMapping(SMesh::Map::STATIC);
        overlay_mesh.BuildMesh();
*/
	}
}

ShadowChunk[] chunks;
const int CHUNK_SIZE = 16;
const int chunk_update_per_tick = 16;

u8[] tile_nums;
bool[] solids;
bool solid_map;
int map_size;

bool full_update_needed;
int last_index;
bool chunk_initialization;
const int tile_update_per_tick = 8000;

int[] tiles_to_update;

void onMapLoad(int width, int height)
{
    map_size = width * height;
    full_update_needed = true;
    chunk_initialization = false;
    last_index = 0;

    tile_nums.clear();
    tile_nums = u8[](map_size);
    solids.clear();
    solids = bool[](map_size);

    solid_map = false;

    tiles_to_update.clear();
}

void onSetTile(int offset, uint16 tiletype)
{
    // uses hardcoded tile solid check! extend for custom tiles!!!
    // i cant think of any way to do it with tile flag, because tile isnt placed yet
    solids[offset] = isSolid(getMap(), tiletype) && !isTileIce(tiletype);

    tiles_to_update.push_back(offset);
}

void onTick(CRules@ this)
{
    if(full_update_needed)
    {
        CMap@ map = getMap();
        if(!chunk_initialization)
        {
            if(!solid_map)
            {
                for(int i = 0; i < map_size; i++)
                {
                    Tile tile = map.getTile(i);
                    solids[i] = isSolid(getMap(), tile.type) && !isTileIce(tile.type);
                }
                solid_map = true;
            }
            int max_index = last_index + tile_update_per_tick;
            if(max_index >= map_size)
            {
                chunk_initialization = true;
                max_index = map_size;
            }
            //print("max_index: " + max_index);
            for(int i = last_index; i < max_index; i++)
            {
                UpdateTileNum(map, i);
            }
            last_index += tile_update_per_tick;
        }
        else // create chunks (without making meshes yet)
        {
            chunks.clear();
            
            int x_max = Maths::Ceil(float(map.tilemapwidth) / float(CHUNK_SIZE));
            int y_max = Maths::Ceil(float(map.tilemapheight) / float(CHUNK_SIZE));
            
            int x_size = 16;
            int y_size = 16;

            for(int y = 0; y < y_max; y++)
            {
                x_size = 16;
                if(y == y_max - 1)
                {
                    y_size = map.tilemapheight - y * CHUNK_SIZE;
                }
                for(int x = 0; x < x_max; x++)
                {
                    if(x == x_max - 1)
                    {
                        x_size = map.tilemapwidth - x * CHUNK_SIZE;
                    }

                    ShadowChunk chunk = ShadowChunk(Vec2f(x * CHUNK_SIZE, y * CHUNK_SIZE), Vec2f(x_size, y_size));
                    chunks.push_back(chunk);
                }
            }
            chunk_initialization = false;
            full_update_needed = false;
        }
    }
    else
    {
        // make/update chunk meshes
        int chunks_updated = 0;
        for(int i = 0; i < chunks.size(); i++)
        {
            if(chunks_updated >= chunk_update_per_tick)
                break;

            ShadowChunk@ chunk = chunks[i];
            if(chunk.update_needed)
            {
                if(chunk.onScreen())
                {
                    chunk.on_screen = true;
                    chunk.UpdateMesh();
                    chunks_updated++;
                }
                else
                    chunk.on_screen = false;
            }
        }

        // update tiles
        if(tiles_to_update.size() > 0)
        {
            CMap@ map = getMap();
            for(int i = 0; i < tiles_to_update.size(); i++)
            {
                int offset = tiles_to_update[i];
                UpdateTileNum(map, offset);

                int[] dirs = {-map.tilemapwidth-1, -map.tilemapwidth, -map.tilemapwidth+1, -1, 1, map.tilemapwidth-1, map.tilemapwidth, map.tilemapwidth+1};
                for(int i = 0; i < dirs.size(); i++)
                {
                    int n_offset = offset + dirs[i];
                    if(!inMap(map, n_offset))
                        continue;
                    UpdateTileNum(map, n_offset);
                    int chunk_x = Maths::Floor((n_offset % map.tilemapwidth) / CHUNK_SIZE);
                    int chunk_y = Maths::Floor((n_offset / map.tilemapwidth) / CHUNK_SIZE);
                    //print("chunk_x: " + chunk_x + " chunk_y: " + chunk_y);
                    int x_max = Maths::Ceil(float(map.tilemapwidth) / float(CHUNK_SIZE));
                    //print("x_max: " + x_max);
                    int chunk_offset = chunk_y * x_max + chunk_x;
                    if(chunk_offset < chunks.size())
                    {
                        ShadowChunk@ chunk = chunks[chunk_y * x_max + chunk_x];
                        chunk.update_needed = true;
                    }
                }
            }
            tiles_to_update.clear();
        }
    }
}

// 0,0,0
// 0,t,0  ==  [0000]t[0000] == 0b00000000 our u8
// 0,0,0

void UpdateTileNum(CMap@ map, int offset)
{
    int num = 0;

    if(!solids[offset])
    {
        tile_nums[offset] = 0;
        return;
    }
    
    int pos = offset - map.tilemapwidth - 1; // top left
    if(inMap(map, pos))
        if(solids[pos])
            num |= 0b10000000;
    
    pos = offset - map.tilemapwidth; // top mid
    if(inMap(map, pos))
        if(solids[pos])
            num |= 0b01000000;
    
    pos = offset - map.tilemapwidth + 1; // top right
    if(inMap(map, pos))
        if(solids[pos])
            num |= 0b00100000;
    
    pos = offset - 1; // left
    if(inMap(map, pos))
        if(solids[pos])
            num |= 0b00010000;
    
    pos = offset + 1; // right
    if(inMap(map, pos))
        if(solids[pos])
            num |= 0b00001000;
    
    pos = offset + map.tilemapwidth - 1; // bottom left
    if(inMap(map, pos))
        if(solids[pos])
            num |= 0b00000100;
    
    pos = offset + map.tilemapwidth; // bottom mid
    if(inMap(map, pos))
        if(solids[pos])
            num |= 0b00000010;
    
    pos = offset + map.tilemapwidth + 1; // bottom right
    if(inMap(map, pos))
        if(solids[pos])
            num |= 0b00000001;
    
    tile_nums[offset] = num;
}

// map bounds check (i cant believe CMap doesnt have this)
bool inMap(CMap@ map, int offset)
{
    return offset >= 0 && offset < map.tilemapwidth * map.tilemapheight;
}

class ShadowChunk
{
    SMesh mesh;
    Vec2f world_pos;
    Vec2f world_size;
    Vec2f pos;
    Vec2f size;
    bool update_needed;
    bool empty;
    bool on_screen;

    Vertex[] _verts;
    uint16[] _indices;

    ShadowChunk(Vec2f _pos, Vec2f _size)
    {
        pos = _pos;
        world_pos = _pos * 8;
        size = _size;
        world_size = _size * 8;
        update_needed = true;
        empty = true;
        on_screen = false;

        mesh.SetHardwareMapping(SMesh::STATIC);
    }

    void UpdateMesh()
    {
        Vec2f pos_end = pos+size;

        mesh.Clear();

        Vertex[] verts;
        uint16[] indices;

        for(int y = pos.y; y < pos_end.y; y++)
        {
            for(int x = pos.x; x < pos_end.x; x++)
            {
                int index = y * getMap().tilemapwidth + x;
                //print("index: "+index);
                if(!solids[index])
                    continue;
                int num = tile_nums[index];
                if(num == 255) // fully ocluded
                    continue;
                
                AddFaces(@verts, @indices, x, getMap().tilemapheight-y-getMap().tilemapheight, num);
            }
        }

        if(verts.size() == 0)
        {
            update_needed = false;
            empty = true;
            return;
        }

        empty = false;

        mesh.SetVertex(verts);
        mesh.SetIndices(indices);
        mesh.SetDirty(SMesh::Buffer::VERTEX_INDEX);
        mesh.BuildMesh();

        _verts = verts;
        _indices = indices;
        
        update_needed = false;
    }

    // i wrote this by hand :) (could be optimized)
    void AddFaces(Vertex[]@ verts, uint16[]@ indices, int x, int y, int num)
    {
        // 0,0,0
        // 0,t,0  ==  00000000 our u8
        // 0,0,0

        // fully open or X
        if(~num & 0b01011010 == 0b01011010)
        {
            verts.push_back(Vertex(x, y-1, SHADOW_NEAR_PLANE,  1, 0, color_black));
            verts.push_back(Vertex(x,      y-1, SHADOW_FAR_PLANE,   1, 1, color_black));
            verts.push_back(Vertex(x+1,    y-1, SHADOW_FAR_PLANE, 0, 1, color_black));
            verts.push_back(Vertex(x+1, y-1, SHADOW_NEAR_PLANE,0, 0, color_black));
            AddFaceIndices(@indices, verts.size());

            verts.push_back(Vertex(x, y, SHADOW_FAR_PLANE,     0, 1, color_black));
            verts.push_back(Vertex(x, y, SHADOW_NEAR_PLANE,    0, 0, color_black));
            verts.push_back(Vertex(x+1, y, SHADOW_NEAR_PLANE,  1, 0, color_black));
            verts.push_back(Vertex(x+1, y, SHADOW_FAR_PLANE,   1, 1, color_black));
            AddFaceIndices(@indices, verts.size());

            verts.push_back(Vertex(x, y-1, SHADOW_NEAR_PLANE, 0, 0, color_black));
            verts.push_back(Vertex(x, y, SHADOW_NEAR_PLANE, 1, 0, color_black));
            verts.push_back(Vertex(x, y, SHADOW_FAR_PLANE, 1, 1, color_black));
            verts.push_back(Vertex(x, y-1, SHADOW_FAR_PLANE, 0, 1, color_black));
            AddFaceIndices(@indices, verts.size());

            verts.push_back(Vertex(x+1, y-1, SHADOW_FAR_PLANE, 1, 1, color_black));
            verts.push_back(Vertex(x+1, y, SHADOW_FAR_PLANE, 0, 1, color_black));
            verts.push_back(Vertex(x+1, y, SHADOW_NEAR_PLANE, 0, 0, color_black));
            verts.push_back(Vertex(x+1, y-1, SHADOW_NEAR_PLANE, 1, 0, color_black));
            AddFaceIndices(@indices, verts.size());

            return;
        }

        // cross +
        if(num & 0b01011010 == 0b01011010 && ~num & 0b10100101 == 0b10100101)
        {
            verts.push_back(Vertex(x+0.5, y-1, SHADOW_NEAR_PLANE, 0, 0, color_black));
            verts.push_back(Vertex(x+0.5, y, SHADOW_NEAR_PLANE, 1, 0, color_black));
            verts.push_back(Vertex(x+0.5, y, SHADOW_FAR_PLANE, 1, 1, color_black));
            verts.push_back(Vertex(x+0.5, y-1, SHADOW_FAR_PLANE, 0, 1, color_black));
            AddFaceIndices(@indices, verts.size());

            verts.push_back(Vertex(x+0.5, y-1, SHADOW_FAR_PLANE, 1, 1, color_black));
            verts.push_back(Vertex(x+0.5, y, SHADOW_FAR_PLANE, 0, 1, color_black));
            verts.push_back(Vertex(x+0.5, y, SHADOW_NEAR_PLANE, 0, 0, color_black));
            verts.push_back(Vertex(x+0.5, y-1, SHADOW_NEAR_PLANE, 1, 0, color_black));
            AddFaceIndices(@indices, verts.size());

            verts.push_back(Vertex(x, y-0.5, SHADOW_NEAR_PLANE,  1, 0, color_black));
            verts.push_back(Vertex(x,      y-0.5, SHADOW_FAR_PLANE,   1, 1, color_black));
            verts.push_back(Vertex(x+1,    y-0.5, SHADOW_FAR_PLANE, 0, 1, color_black));
            verts.push_back(Vertex(x+1, y-0.5, SHADOW_NEAR_PLANE,0, 0, color_black));
            AddFaceIndices(@indices, verts.size());

            verts.push_back(Vertex(x, y-0.5, SHADOW_FAR_PLANE,     0, 1, color_black));
            verts.push_back(Vertex(x, y-0.5, SHADOW_NEAR_PLANE,    0, 0, color_black));
            verts.push_back(Vertex(x+1, y-0.5, SHADOW_NEAR_PLANE,  1, 0, color_black));
            verts.push_back(Vertex(x+1, y-0.5, SHADOW_FAR_PLANE,   1, 1, color_black));
            AddFaceIndices(@indices, verts.size());

            return;
        }

        // | , -| and |-
        if(num & 0b01000010 == 0b01000010)
        {
            verts.push_back(Vertex(x+0.5, y-1, SHADOW_NEAR_PLANE, 0, 0, color_black));
            verts.push_back(Vertex(x+0.5, y, SHADOW_NEAR_PLANE, 1, 0, color_black));
            verts.push_back(Vertex(x+0.5, y, SHADOW_FAR_PLANE, 1, 1, color_black));
            verts.push_back(Vertex(x+0.5, y-1, SHADOW_FAR_PLANE, 0, 1, color_black));
            AddFaceIndices(@indices, verts.size());

            verts.push_back(Vertex(x+0.5, y-1, SHADOW_FAR_PLANE, 1, 1, color_black));
            verts.push_back(Vertex(x+0.5, y, SHADOW_FAR_PLANE, 0, 1, color_black));
            verts.push_back(Vertex(x+0.5, y, SHADOW_NEAR_PLANE, 0, 0, color_black));
            verts.push_back(Vertex(x+0.5, y-1, SHADOW_NEAR_PLANE, 1, 0, color_black));
            AddFaceIndices(@indices, verts.size());

            if(num & 0b00010000 == 0b00010000 && num & 0b10000100 != 0b10000100)
            {
                verts.push_back(Vertex(x, y-0.5, SHADOW_NEAR_PLANE,  1, 0, color_black));
                verts.push_back(Vertex(x,      y-0.5, SHADOW_FAR_PLANE,   1, 1, color_black));
                verts.push_back(Vertex(x+0.5,    y-0.5, SHADOW_FAR_PLANE, 0, 1, color_black));
                verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE,0, 0, color_black));
                AddFaceIndices(@indices, verts.size());

                verts.push_back(Vertex(x, y-0.5, SHADOW_FAR_PLANE,     0, 1, color_black));
                verts.push_back(Vertex(x, y-0.5, SHADOW_NEAR_PLANE,    0, 0, color_black));
                verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE,  1, 0, color_black));
                verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_FAR_PLANE,   1, 1, color_black));
                AddFaceIndices(@indices, verts.size());
            }
            else if(num & 0b00001000 == 0b00001000 && num & 0b00100001 != 0b00100001)
            {
                verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE,  1, 0, color_black));
                verts.push_back(Vertex(x+0.5,      y-0.5, SHADOW_FAR_PLANE,   1, 1, color_black));
                verts.push_back(Vertex(x+1,    y-0.5, SHADOW_FAR_PLANE, 0, 1, color_black));
                verts.push_back(Vertex(x+1, y-0.5, SHADOW_NEAR_PLANE,0, 0, color_black));
                AddFaceIndices(@indices, verts.size());

                verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_FAR_PLANE,     0, 1, color_black));
                verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE,    0, 0, color_black));
                verts.push_back(Vertex(x+1, y-0.5, SHADOW_NEAR_PLANE,  1, 0, color_black));
                verts.push_back(Vertex(x+1, y-0.5, SHADOW_FAR_PLANE,   1, 1, color_black));
                AddFaceIndices(@indices, verts.size());
            }
        }

        // -- , -'- and -,-
        if(num & 0b00011000 == 0b00011000)
        {
            verts.push_back(Vertex(x, y-0.5, SHADOW_NEAR_PLANE,  1, 0, color_black));
            verts.push_back(Vertex(x,      y-0.5, SHADOW_FAR_PLANE,   1, 1, color_black));
            verts.push_back(Vertex(x+1,    y-0.5, SHADOW_FAR_PLANE, 0, 1, color_black));
            verts.push_back(Vertex(x+1, y-0.5, SHADOW_NEAR_PLANE,0, 0, color_black));
            AddFaceIndices(@indices, verts.size());

            verts.push_back(Vertex(x, y-0.5, SHADOW_FAR_PLANE,     0, 1, color_black));
            verts.push_back(Vertex(x, y-0.5, SHADOW_NEAR_PLANE,    0, 0, color_black));
            verts.push_back(Vertex(x+1, y-0.5, SHADOW_NEAR_PLANE,  1, 0, color_black));
            verts.push_back(Vertex(x+1, y-0.5, SHADOW_FAR_PLANE,   1, 1, color_black));
            AddFaceIndices(@indices, verts.size());

            if(num & 0b01000000 == 0b01000000 && num & 0b10100000 != 0b10100000)
            {
                verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE, 0, 0, color_black));
                verts.push_back(Vertex(x+0.5, y, SHADOW_NEAR_PLANE, 1, 0, color_black));
                verts.push_back(Vertex(x+0.5, y, SHADOW_FAR_PLANE, 1, 1, color_black));
                verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_FAR_PLANE, 0, 1, color_black));
                AddFaceIndices(@indices, verts.size());

                verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_FAR_PLANE, 1, 1, color_black));
                verts.push_back(Vertex(x+0.5, y, SHADOW_FAR_PLANE, 0, 1, color_black));
                verts.push_back(Vertex(x+0.5, y, SHADOW_NEAR_PLANE, 0, 0, color_black));
                verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE, 1, 0, color_black));
                AddFaceIndices(@indices, verts.size());
            }
            else if(num & 0b00000010 == 0b00000010 && num & 0b00000101 != 0b00000101)
            {
                verts.push_back(Vertex(x+0.5, y-1, SHADOW_NEAR_PLANE, 0, 0, color_black));
                verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE, 1, 0, color_black));
                verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_FAR_PLANE, 1, 1, color_black));
                verts.push_back(Vertex(x+0.5, y-1, SHADOW_FAR_PLANE, 0, 1, color_black));
                AddFaceIndices(@indices, verts.size());

                verts.push_back(Vertex(x+0.5, y-1, SHADOW_FAR_PLANE, 1, 1, color_black));
                verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_FAR_PLANE, 0, 1, color_black));
                verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE, 0, 0, color_black));
                verts.push_back(Vertex(x+0.5, y-1, SHADOW_NEAR_PLANE, 1, 0, color_black));
                AddFaceIndices(@indices, verts.size());
            }
        }

        // stubs
        // up
        if(num & 0b01000000 == 0b01000000 && ~num & 0b00011010 == 0b00011010)
        {
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE, 0, 0, color_black));
            verts.push_back(Vertex(x+0.5, y, SHADOW_NEAR_PLANE, 1, 0, color_black));
            verts.push_back(Vertex(x+0.5, y, SHADOW_FAR_PLANE, 1, 1, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_FAR_PLANE, 0, 1, color_black));
            AddFaceIndices(@indices, verts.size());

            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_FAR_PLANE, 1, 1, color_black));
            verts.push_back(Vertex(x+0.5, y, SHADOW_FAR_PLANE, 0, 1, color_black));
            verts.push_back(Vertex(x+0.5, y, SHADOW_NEAR_PLANE, 0, 0, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE, 1, 0, color_black));
            AddFaceIndices(@indices, verts.size());

            return;
        }

        // down
        if(num & 0b00000010 == 0b00000010 && ~num & 0b01011000 == 0b01011000)
        {
            verts.push_back(Vertex(x+0.5, y-1, SHADOW_NEAR_PLANE, 0, 0, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE, 1, 0, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_FAR_PLANE, 1, 1, color_black));
            verts.push_back(Vertex(x+0.5, y-1, SHADOW_FAR_PLANE, 0, 1, color_black));
            AddFaceIndices(@indices, verts.size());

            verts.push_back(Vertex(x+0.5, y-1, SHADOW_FAR_PLANE, 1, 1, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_FAR_PLANE, 0, 1, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE, 0, 0, color_black));
            verts.push_back(Vertex(x+0.5, y-1, SHADOW_NEAR_PLANE, 1, 0, color_black));
            AddFaceIndices(@indices, verts.size());

            return;
        }

        // left
        if(num & 0b00010000 == 0b00010000 && ~num & 0b01001010 == 0b01001010)
        {
            verts.push_back(Vertex(x, y-0.5, SHADOW_NEAR_PLANE,  1, 0, color_black));
            verts.push_back(Vertex(x,      y-0.5, SHADOW_FAR_PLANE,   1, 1, color_black));
            verts.push_back(Vertex(x+0.5,    y-0.5, SHADOW_FAR_PLANE, 0, 1, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE,0, 0, color_black));
            AddFaceIndices(@indices, verts.size());

            verts.push_back(Vertex(x, y-0.5, SHADOW_FAR_PLANE,     0, 1, color_black));
            verts.push_back(Vertex(x, y-0.5, SHADOW_NEAR_PLANE,    0, 0, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE,  1, 0, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_FAR_PLANE,   1, 1, color_black));
            AddFaceIndices(@indices, verts.size());

            return;
        }

        // right
        if(num & 0b00001000 == 0b00001000 && ~num & 0b01010010 == 0b01010010)
        {
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE,  1, 0, color_black));
            verts.push_back(Vertex(x+0.5,      y-0.5, SHADOW_FAR_PLANE,   1, 1, color_black));
            verts.push_back(Vertex(x+1,    y-0.5, SHADOW_FAR_PLANE, 0, 1, color_black));
            verts.push_back(Vertex(x+1, y-0.5, SHADOW_NEAR_PLANE,0, 0, color_black));
            AddFaceIndices(@indices, verts.size());

            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_FAR_PLANE,     0, 1, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE,    0, 0, color_black));
            verts.push_back(Vertex(x+1, y-0.5, SHADOW_NEAR_PLANE,  1, 0, color_black));
            verts.push_back(Vertex(x+1, y-0.5, SHADOW_FAR_PLANE,   1, 1, color_black));
            AddFaceIndices(@indices, verts.size());

            return;
        }

        // corners
        // '-
        if(num & 0b01001000 == 0b01001000 && ~num & 0b00010010 == 0b00010010)
        {
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE, 0, 0, color_black));
            verts.push_back(Vertex(x+0.5, y, SHADOW_NEAR_PLANE, 1, 0, color_black));
            verts.push_back(Vertex(x+0.5, y, SHADOW_FAR_PLANE, 1, 1, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_FAR_PLANE, 0, 1, color_black));
            AddFaceIndices(@indices, verts.size());

            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_FAR_PLANE, 1, 1, color_black));
            verts.push_back(Vertex(x+0.5, y, SHADOW_FAR_PLANE, 0, 1, color_black));
            verts.push_back(Vertex(x+0.5, y, SHADOW_NEAR_PLANE, 0, 0, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE, 1, 0, color_black));
            AddFaceIndices(@indices, verts.size());

            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE,  1, 0, color_black));
            verts.push_back(Vertex(x+0.5,      y-0.5, SHADOW_FAR_PLANE,   1, 1, color_black));
            verts.push_back(Vertex(x+1,    y-0.5, SHADOW_FAR_PLANE, 0, 1, color_black));
            verts.push_back(Vertex(x+1, y-0.5, SHADOW_NEAR_PLANE,0, 0, color_black));
            AddFaceIndices(@indices, verts.size());

            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_FAR_PLANE,     0, 1, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE,    0, 0, color_black));
            verts.push_back(Vertex(x+1, y-0.5, SHADOW_NEAR_PLANE,  1, 0, color_black));
            verts.push_back(Vertex(x+1, y-0.5, SHADOW_FAR_PLANE,   1, 1, color_black));
            AddFaceIndices(@indices, verts.size());

            return;
        }

        // -'
        if(num & 0b01010000 == 0b01010000 && ~num & 0b00001010 == 0b00001010)
        {
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE, 0, 0, color_black));
            verts.push_back(Vertex(x+0.5, y, SHADOW_NEAR_PLANE, 1, 0, color_black));
            verts.push_back(Vertex(x+0.5, y, SHADOW_FAR_PLANE, 1, 1, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_FAR_PLANE, 0, 1, color_black));
            AddFaceIndices(@indices, verts.size());

            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_FAR_PLANE, 1, 1, color_black));
            verts.push_back(Vertex(x+0.5, y, SHADOW_FAR_PLANE, 0, 1, color_black));
            verts.push_back(Vertex(x+0.5, y, SHADOW_NEAR_PLANE, 0, 0, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE, 1, 0, color_black));
            AddFaceIndices(@indices, verts.size());

            verts.push_back(Vertex(x, y-0.5, SHADOW_NEAR_PLANE,  1, 0, color_black));
            verts.push_back(Vertex(x,      y-0.5, SHADOW_FAR_PLANE,   1, 1, color_black));
            verts.push_back(Vertex(x+0.5,    y-0.5, SHADOW_FAR_PLANE, 0, 1, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE,0, 0, color_black));
            AddFaceIndices(@indices, verts.size());

            verts.push_back(Vertex(x, y-0.5, SHADOW_FAR_PLANE,     0, 1, color_black));
            verts.push_back(Vertex(x, y-0.5, SHADOW_NEAR_PLANE,    0, 0, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE,  1, 0, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_FAR_PLANE,   1, 1, color_black));
            AddFaceIndices(@indices, verts.size());

            return;
        }

        // ,-
        if(num & 0b00001010 == 0b00001010 && ~num & 0b01010000 == 0b01010000)
        {
            verts.push_back(Vertex(x+0.5, y-1, SHADOW_NEAR_PLANE, 0, 0, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE, 1, 0, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_FAR_PLANE, 1, 1, color_black));
            verts.push_back(Vertex(x+0.5, y-1, SHADOW_FAR_PLANE, 0, 1, color_black));
            AddFaceIndices(@indices, verts.size());

            verts.push_back(Vertex(x+0.5, y-1, SHADOW_FAR_PLANE, 1, 1, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_FAR_PLANE, 0, 1, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE, 0, 0, color_black));
            verts.push_back(Vertex(x+0.5, y-1, SHADOW_NEAR_PLANE, 1, 0, color_black));
            AddFaceIndices(@indices, verts.size());

            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE,  1, 0, color_black));
            verts.push_back(Vertex(x+0.5,      y-0.5, SHADOW_FAR_PLANE,   1, 1, color_black));
            verts.push_back(Vertex(x+1,    y-0.5, SHADOW_FAR_PLANE, 0, 1, color_black));
            verts.push_back(Vertex(x+1, y-0.5, SHADOW_NEAR_PLANE,0, 0, color_black));
            AddFaceIndices(@indices, verts.size());

            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_FAR_PLANE,     0, 1, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE,    0, 0, color_black));
            verts.push_back(Vertex(x+1, y-0.5, SHADOW_NEAR_PLANE,  1, 0, color_black));
            verts.push_back(Vertex(x+1, y-0.5, SHADOW_FAR_PLANE,   1, 1, color_black));
            AddFaceIndices(@indices, verts.size());

            return;
        }

        // -,
        if(num & 0b00010010 == 0b00010010 && ~num & 0b01001000 == 0b01001000)
        {
            verts.push_back(Vertex(x+0.5, y-1, SHADOW_NEAR_PLANE, 0, 0, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE, 1, 0, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_FAR_PLANE, 1, 1, color_black));
            verts.push_back(Vertex(x+0.5, y-1, SHADOW_FAR_PLANE, 0, 1, color_black));
            AddFaceIndices(@indices, verts.size());

            verts.push_back(Vertex(x+0.5, y-1, SHADOW_FAR_PLANE, 1, 1, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_FAR_PLANE, 0, 1, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE, 0, 0, color_black));
            verts.push_back(Vertex(x+0.5, y-1, SHADOW_NEAR_PLANE, 1, 0, color_black));
            AddFaceIndices(@indices, verts.size());

            verts.push_back(Vertex(x, y-0.5, SHADOW_NEAR_PLANE,  1, 0, color_black));
            verts.push_back(Vertex(x,      y-0.5, SHADOW_FAR_PLANE,   1, 1, color_black));
            verts.push_back(Vertex(x+0.5,    y-0.5, SHADOW_FAR_PLANE, 0, 1, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE,0, 0, color_black));
            AddFaceIndices(@indices, verts.size());

            verts.push_back(Vertex(x, y-0.5, SHADOW_FAR_PLANE,     0, 1, color_black));
            verts.push_back(Vertex(x, y-0.5, SHADOW_NEAR_PLANE,    0, 0, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_NEAR_PLANE,  1, 0, color_black));
            verts.push_back(Vertex(x+0.5, y-0.5, SHADOW_FAR_PLANE,   1, 1, color_black));
            AddFaceIndices(@indices, verts.size());

            return;
        }
    }

    // could be optimized
    void AddFaceIndices(uint16[]@ indices, int size)
    {
        indices.push_back(size - 4);
        indices.push_back(size - 3);
        indices.push_back(size - 2);
        indices.push_back(size - 4);
        indices.push_back(size - 2);
        indices.push_back(size - 1);
    }

    // called from ontick and managed if mesh should be drawn there
    bool onScreen()
    {
        Driver@ driver = getDriver();
        Vec2f screen_pos = driver.getScreenPosFromWorldPos(world_pos);
        Vec2f screen_pos_end = driver.getScreenPosFromWorldPos(world_pos + world_size);

        // check if at least part of rectangle is in screen bounds 
        return (screen_pos_end.x >= 0 && screen_pos_end.y >= 0) || (screen_pos.x <= driver.getScreenWidth() && screen_pos.y <= driver.getScreenHeight()); // hmm
    }

    void Render()
    {
        if(!empty && on_screen)
        {
            mesh.RenderMesh();
            //Render::RawTrianglesIndexed("shadow_tex", _verts, _indices);
        }
    }
}

void Render(int id)
{
	CCamera@ cam = getCamera();
    
    // i stole most of this dogshit from engine, i have no idea what it does now, but at some point i did
    // (calculates camera real zoom)
    float resolution_factor = Maths::Max(float(getScreenWidth()) / 1280.0f, float(getScreenHeight()) / 720.0f);
	float dist = (0.5f)/resolution_factor;
    float cam_zoom = (SHADOW_FAR_PLANE * 2.0f) / float(getScreenHeight());
    float fDynaDistance = cam.targetDistance * resolution_factor;
    cam_zoom /= ((0.5) / fDynaDistance);

    CBlob@ my_bloba = getLocalPlayerBlob();

    // if our blob is dead use camera position
    Vec2f eye_pos_world = my_bloba !is null ? my_bloba.getInterpolatedPosition() : cam.getPosition();
    Vec2f eye_pos_screen = getDriver().getScreenPosFromWorldPos(eye_pos_world);
    eye_pos_world *= cam_zoom;

    Render::ClearZ();

    float[] model;
    Matrix::MakeIdentity(model);

/*
    // draw z override quad
    Render::SetTransformScreenspace();
    override_z_material.SetVideoMaterial();
    Matrix::SetScale(model, getScreenWidth(), getScreenHeight(), 1);
    Render::SetModelTransform(model);
    override_z_mesh.RenderMesh();
*/

    // draw shadows
    shadow_material.SetVideoMaterial();
    float[] proj;
    Matrix::MakePerspective(proj, Maths::Pi/2.0f, float(getScreenWidth()) / float(getScreenHeight()), SHADOW_NEAR_PLANE+0.01f, SHADOW_FAR_PLANE);

    // modify projection matrix translation
    float[] temp;
    Matrix::MakeIdentity(temp);
    Vec2f pos_diff = eye_pos_screen*2.0f - Vec2f(getScreenWidth(), getScreenHeight());
    pos_diff.x /= getScreenWidth();
    pos_diff.y /= getScreenHeight();
    Matrix::SetTranslation(temp, pos_diff.x, -pos_diff.y, 0);
    Matrix::MultiplyImmediate(temp, proj);
    Render::SetProjectionTransform(temp);
    
    Matrix::MakeIdentity(model);
    Matrix::SetScale(model, cam_zoom*8, cam_zoom*8, 1);
    Render::SetModelTransform(model);

    float[] view;
    Matrix::MakeIdentity(view);
    Matrix::SetTranslation(view, -eye_pos_world.x, eye_pos_world.y, 0);
    Render::SetViewTransform(view);

    // render shadows
    if(!full_update_needed && chunks.size() > 0)
    {
        for(int i = 0; i < chunks.size(); i++)
        {
            chunks[i].Render();
        }
    }

/*
    // render overlay
    Render::SetTransformScreenspace();
    overlay_material.SetVideoMaterial();
    Matrix::MakeIdentity(model);
    Render::SetViewTransform(model);
    Matrix::SetScale(model, getScreenWidth(), getScreenHeight(), 1);
    Render::SetModelTransform(model);

    overlay_mesh.RenderMesh();
*/
}