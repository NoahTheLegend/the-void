
bool inProximity(CBlob@ blob, CBlob@ blob1)
{
    if (blob is null || blob1 is null) return false;
    return
        (!getMap().rayCastSolidNoBlobs(blob.getPosition(), blob1.getPosition())
        || !getMap().rayCastSolidNoBlobs(blob.getPosition() - Vec2f(0,8), blob1.getPosition() - Vec2f(0,8)));
}