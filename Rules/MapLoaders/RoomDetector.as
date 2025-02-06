#define SERVER_ONLY
#include "CustomBlocks.as";

array<u8> tile_map();
const u16 max_steps_per_tick = 2;
const u32 max_length = 1000; // it is shorter so uh dont count this for tiles 
const Vec2f debug_area = Vec2f(20, 20);

void onInit(CRules@ this)
{
    Reset(this);
}

void onRestart(CRules@ this)
{
    Reset(this);
}

void Reset(CRules@ this)
{
    CMap@ map = getMap();
    if (map is null)
    {
        error("Could not update map matrix");
        return;
    }

    array<u8> new_tile_map(map.tilemapwidth*map.tilemapheight);
	tile_map = new_tile_map;
}

void onSetTile(CMap@ map, u32 index, TileType new_tile, TileType old_tile)
{
    if (getRules().hasTag("loading")) return;

    // add a separate bool hook to see which materials save temperature (room space)
    bool old_solid = false;
    //bool new_solid = false;
    if (isSolid(map, old_tile)) old_solid = true;
    //if (isCustomSolid(map, new_tile)) new_solid = true;

    //if (!old_solid || new_solid) return;
    if (!old_solid) return;

    flood_order.push_back(index); // put recent block in the list
}

u32[] list = {};
u32[] flood_order = {};
u32 start_index = 0;
int length = max_length;
int current_length = 0;
int steps_remaining = max_steps_per_tick;
bool reverse = false;
u32 steps_done = 0;

void onTick(CRules@ this)
{
    CMap@ map = getMap();
    if (map is null) return;

    if (list.size() == 0 && flood_order.size() > 0) // start new flood if list is empty and we have one waiting
    {
        ResetFlood();
        start_index = flood_order[flood_order.size()-1];
        reverse = false;
        flood_order.erase(flood_order.size()-1);
    }

    if (start_index != 0) // new startpos is assigned from the order
    {
        list.push_back(start_index); // assign an entry equal to startpos before loop
        start_index = 0; // reset startpos so it won't add more next ticks

        while (list.size() != 0)
        {
            steps_done++;
            if (current_length > length) reverse = true; // reverse if we didn't close the flood and we can't see further
            
            u32 step = list[0];

            if (reverse ? tile_map[step] == 0 : tile_map[step] != 0) // this is necessary trust me
            {
                list.erase(0);
                continue;
            }

            Vec2f pos = map.getTileWorldPosition(step);
            if (length > 0 || reverse)
            {
                u32 up = step - map.tilemapwidth;
                if (FloodValidation(map, pos, up))
                {
                    list.push_back(up);
                }
                
                u32 right = step + 1;
                if (FloodValidation(map, pos, right))
                {
                    list.push_back(right);
                }

                u32 down = step + map.tilemapwidth;
                if (FloodValidation(map, pos, down))
                {
                    list.push_back(down);
                }

                u32 left = step - 1;
                if (FloodValidation(map, pos, left))
                {
                    list.push_back(left);
                }
            }

            tile_map[step] = reverse ? 0 : 255; // todo: count exposures to set relative temperature near them
            current_length++;
            list.erase(0);

            bool exposure = isTileExposure(map.getTile(step).type);
            if (exposure)
                reverse = true;
            
            if (steps_remaining == 0) // save for next tick if we exhausted the limit
            {
                steps_done = 0;
                start_index = step;
                steps_remaining = max_steps_per_tick;
                break;
            }
            
            steps_remaining--;
        }
    }
}

void ResetFlood()
{
    list = array<u32>();
    start_index = 0;
    length = max_length;
    current_length = 0;
}

bool FloodValidation(CMap@ map, Vec2f pos, u32 index)
{
    TileType tile = map.getTile(index).type;
    bool isroom = tile_map[index] != 0;
    
    bool solid = isSolid(map, tile);
    bool solidblob = false;

    pos = pos + Vec2f(4, 4);
    CBlob@[] blobs;
    map.getBlobsAtPosition(pos, @blobs);
    {
        for (u8 i = 0; i < blobs.size(); i++)
        {
            solidblob = blobs[i] !is null
                && (blobs[i].hasTag("solid") || blobs[i].hasTag("door"));
        }
    }

    return reverse ? isroom : (!isroom && !solid && !solidblob);
}

void onRender(CRules@ this) // debug
{
    if (!(isClient() && isServer())) return;
    if (tile_map.size() == 0) return;
    CMap@ map = getMap();
    if (map is null) return;

    if (getControls() is null) return;
    if (!getControls().isKeyPressed(KEY_LSHIFT)) return;

    Vec2f pos = getControls().getMouseWorldPos()+Vec2f(8, 8);
    Vec2f area = debug_area;
    int room_count = 0;
    
    GUI::SetFont("menu");
    GUI::DrawText("list size: "+list.size()+"\nindex: "+start_index+"\nflood order size: "+flood_order.size()+"\nroom count: "+room_count+"\nsteps in last tick: "+steps_done+"\nremaining: "+(length-current_length),
        Vec2f(15, 50), SColor(255, 255, 255, 25));
    GUI::SetFont("default");

    for (u32 i = 0; i < area.x * area.y; i++)
    {
        Vec2f current_pos = pos - (area*4) + Vec2f(i%area.x * 8, Maths::Floor(Maths::Floor(i/area.x) * 8));
        Vec2f centralized_pos = Vec2f(Maths::Floor(current_pos.x/8)*8-4.0f, Maths::Floor(current_pos.y/8)*8-4.0f);
        Vec2f screen_pos = getDriver().getScreenPosFromWorldPos(centralized_pos);

        SColor color = SColor(125, 255, 25, 25);
        u32 offset = map.getTileOffset(centralized_pos);
        bool has_room = tile_map[offset] != 0;

        if (has_room)
        {
            room_count++;
            color.set(125, 25, 255, 25);
        }

        GUI::DrawRectangle(screen_pos-Vec2f(4,4), screen_pos+Vec2f(4,4), color);
        if (i == 0) GUI::DrawTextCentered(offset+"", screen_pos-Vec2f(4,2), SColor(155, 255, 255, 0));
    }
}