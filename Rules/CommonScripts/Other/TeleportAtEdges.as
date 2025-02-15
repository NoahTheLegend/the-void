
const u8 sway_time = 2;
u32 teleport_time = 0;

void onTick(CBlob@ this)
{
    bool is_my_player = this.isMyPlayer();
    if (isServer() || is_my_player)
    {
        CMap@ map = getMap();
        Vec2f pos = this.getPosition();
        bool teleported = false;

        if (pos.x < 0)
        {
            this.setPosition(Vec2f(map.tilemapwidth * 8 - 8, pos.y));
            teleported = true;
        }
        else if (pos.x > map.tilemapwidth * 8)
        {
            this.setPosition(Vec2f(8, pos.y));
            teleported = true;
        }

        if (pos.y < 0)
        {
            this.setPosition(Vec2f(pos.x, map.tilemapheight * 8 - 8));
            teleported = true;
        }
        else if (pos.y > map.tilemapheight * 8)
        {
            this.setPosition(Vec2f(pos.x, 8));
            teleported = true;
        }

        if (is_my_player)
        {
            if (teleported) teleport_time = getGameTime();
            CCamera@ camera = getCamera();
            if (camera !is null)
            {
                camera.posLag = teleport_time + sway_time > getGameTime() ? 0.5f : 5;
            }
        }
    }
}