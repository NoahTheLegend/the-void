#include "CustomBlocks.as";

bool canSee(CBlob@ this, CBlob@ other, bool check_if_human = false)
{
    if (other is this) return true;
    if (this is null) return true;
    if (other is null) return false;

    CMap@ map = getMap();
    if (map is null) return false;

    bool is_human = check_if_human && other.hasTag("player");
    
    Vec2f tpos = this.getPosition() - Vec2f(0, is_human ? 4.0f : 0);
    Vec2f opos = other.getPosition() - Vec2f(0, is_human ? 4.0f : 0);

    Vec2f dir = opos - tpos;

    f32 obj_height = is_human ? 3.0f : other.getRadius(); // head pos for human, else half height to prevent hitting blobs
    f32 deg = Maths::ATan(obj_height / dir.Length())%360 * 64;

    HitInfo@[] infos;
    if (map.getHitInfosFromArc(tpos, -dir.Angle(), deg, dir.Length(), this, @infos))
    {
        for (int i = 0; i < infos.size(); i++)
        {
            HitInfo@ info = infos[i];
            if (info is null) continue;

            if (isSolid(map, info.tile))
                return false;
            
            if (info.blob !is null && info.blob.hasTag("opaque"))
                return false;
        }
    }

    return true;
}

//todo: canHear func for chat

void dumbTest(CBlob@ this)
{
    printf(""+canSee(this,getBlobByName("knight"), true));
}