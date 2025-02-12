void onInit(CBlob@ this)
{
    this.Tag("custom_inventory");

    if (!isClient()) return;
    this.set_u32("last_hover_time", 0);
    
    if (!this.exists("max_inventory_distance")) this.set_f32("max_inventory_distance", 24.0f);
    if (!this.exists("inventory_open_sound")) this.set_string("inventory_open_sound", "GateOpen");
    if (!this.exists("inventory_closed_sound")) this.set_string("inventory_closed_sound", "GateClose");
    if (!this.exists("inventory_volume")) this.set_f32("inventory_volume", 0.75f);
    if (!this.exists("inventory_pitch")) this.set_f32("inventory_pitch", 1.0f);
    if (!this.exists("inventory_pitch_random")) this.set_f32("inventory_pitch_random", 0.1f);
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
    return false;
}

void onTick(CBlob@ this)
{
    if (!isClient()) return;

    u32 gt = getGameTime();
    u32 last_hover_time = this.get_u32("last_hover_time");
    bool highlight = last_hover_time >= gt;

    CSprite@ sprite = this.getSprite();
    if (sprite is null) return;

    sprite.setRenderStyle(highlight ? RenderStyle::outline : RenderStyle::normal);
}