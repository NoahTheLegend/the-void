
void onTick(CBlob@ this)
{
   if (isServer() || this.isMyPlayer())
   {
        CMap@ map = getMap();
        Vec2f pos = this.getPosition();

        if (pos.x < 0)
            this.setPosition(Vec2f(map.tilemapwidth * 8 - 8, pos.y));
        else if (pos.x > map.tilemapwidth * 8)
            this.setPosition(Vec2f(8, pos.y));

        if (pos.y < 0)
            this.setPosition(Vec2f(pos.x, map.tilemapheight * 8 - 8));
        else if (pos.y > map.tilemapheight * 8)
            this.setPosition(Vec2f(pos.x, 8));
   } 
}