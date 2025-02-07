#include "CustomBlocks.as";

Tile getSurfaceTile(CBlob@ this)
{
    Tile empty = Tile();
    empty.type = 0;

    if (this is null) return empty;

    CMap@ map = getMap();
    if (map is null) return empty;

    return map.getTile(this.getPosition()+Vec2f(0, this.getRadius() + 4.0f));
}

void getSurfaceTiles(CBlob@ this, TileType &out t1, TileType &out t2)
{
    if (this is null) return;
    
    CMap@ map = getMap();
    if (map is null) return;

    Vec2f pos = this.getPosition();
    f32 rad = this.getRadius();
    t1 = map.getTile(pos+Vec2f(-4.0f, rad + 4.0f)).type;
    t2 = map.getTile(pos+Vec2f(4.0f, rad + 4.0f)).type;
}

bool inProximity(CBlob@ blob, CBlob@ blob1)
{
    if (blob is null || blob1 is null) return false;
    return
        (!getMap().rayCastSolidNoBlobs(blob.getPosition(), blob1.getPosition())
        || !getMap().rayCastSolidNoBlobs(blob.getPosition() - Vec2f(0,8), blob1.getPosition() - Vec2f(0,8)));
}

bool isInAirSpace(Vec2f pos)
{
    return false; //todo
}

bool isInAirSpace(CBlob@ blob)
{
    if (blob is null) return false;
    return isInAirSpace(blob.getPosition());
}

bool hasRadio(CBlob@ blob)
{
    return blob.get_bool("radio_enabled");
}

bool playSoundInProximity(CBlob@ blob, string filename, f32 volume = 1.0f, f32 pitch = 1.0f, bool random = false, f32 falloff_start = 512, f32 max_distance = 512.0f)
{
    if (!isClient()) return false;
    if (blob is null) return false;

    CPlayer@ player = getLocalPlayer();
    if (player is null) return true; // we can hear everything while dead

    Vec2f pos = blob.getPosition();
    Vec2f playerpos = player.getBlob().getPosition();
    f32 dist = (pos - playerpos).Length();

    if (inProximity(blob, player.getBlob()))
    {
        if (dist < falloff_start)
        {
            f32 volume = 1.0f;
            if (random) blob.getSprite().PlayRandomSound(filename, volume);
            else blob.getSprite().PlaySound(filename, volume);
            return true;
        }
        else if (dist < max_distance)
        {
            f32 volume = 1.0f - Maths::Min((dist - falloff_start) / (max_distance - falloff_start), 1.0f);
            if (random) blob.getSprite().PlayRandomSound(filename, volume);
            else blob.getSprite().PlaySound(filename, volume);
            return true;
        }
    }
    else
    {
        if (dist < max_distance / 10)
        {
            f32 volume = 1.0f - Maths::Min(dist / (max_distance / 10), 1.0f);
            if (random) blob.getSprite().PlayRandomSound(filename, volume);
            else blob.getSprite().PlaySound(filename, volume);
            return true;
        }
    }

    return false;
}

f32 getSoundFallOff(CBlob@ blob, f32 falloff_start, f32 max_distance = 512.0f)
{
    if (blob is null) return 0.0f;

    CPlayer@ player = getLocalPlayer();
    if (player is null) return 1.0f; // we can hear everything while dead

    Vec2f pos = blob.getPosition();
    Vec2f playerpos = player.getBlob().getPosition();
    f32 dist = (pos - playerpos).Length();

    return 1.0f - Maths::Min(dist / max_distance , 1.0f);
}