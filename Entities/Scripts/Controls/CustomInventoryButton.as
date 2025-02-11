// doesn't work, picking items doesn't attach them to the player
#define CLIENT_ONLY

void onInit(CBlob@ this)
{
    this.Tag("custom_inventory");

    this.set_u32("last_hover_time", 0);
    if (!this.exists("max_inventory_distance")) this.set_f32("max_inventory_distance", 24.0f);
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
    return false;
}

void onTick(CBlob@ this)
{
    u32 gt = getGameTime();
    u32 last_hover_time = this.get_u32("last_hover_time");
    bool highlight = last_hover_time >= gt;

    CSprite@ sprite = this.getSprite();
    if (sprite is null) return;

    sprite.setRenderStyle(highlight ? RenderStyle::outline : RenderStyle::normal);
}

// try to do something with onRemoveFromInventory hook