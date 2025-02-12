
void onInit(CBlob@ this)
{
    CShape@ shape = this.getShape();
    if (shape is null) return;
    shape.getConsts().mapCollisions = false;

    #ifndef STAGING
    CSprite@ sprite = this.getSprite();
    if (sprite is null) return;
    sprite.getConsts().accurateLighting = true;
    #endif

    this.Tag("building");
    this.Tag("builder always hit");
    this.Tag("builder urgent hit");
}