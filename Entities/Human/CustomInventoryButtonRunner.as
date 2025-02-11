const f32 radius = 32.0f;
void onInit(CBlob@ this)
{
    this.addCommandID("request_putin_carried");
}

void onTick(CBlob@ this)
{
    if (!this.isMyPlayer()) return;

    CControls@ controls = getControls();
    if (controls is null) return;

    CHUD@ hud = getHUD();
    if (hud is null) return;
    if (hud.hasMenus()) return;

    Vec2f mpos = controls.getMouseWorldPos();
    CBlob@[] blobs;
    getMap().getBlobsInRadius(mpos, radius, @blobs);

    f32 temp = 999.0f;
    CBlob@ closest = null;

    for (int i = 0; i < blobs.length; i++)
    {
        CBlob@ blob = blobs[i];
        if (blob is null) continue;
        if (!blob.hasTag("custom_inventory")) continue;
        if (blob.getDistanceTo(this) > blob.get_f32("max_inventory_distance")
            && !blob.isOverlapping(this)) continue;

        f32 dist = (blob.getPosition() - mpos).Length();
        if (dist < temp)
        {
            temp = dist;
            @closest = blob;
        }
    }

    if (closest !is null)
    {
        bool holding = this.isKeyPressed(key_use);
        if (holding) closest.set_u32("last_hover_time", getGameTime()+1);

        Vec2f sc = getDriver().getScreenCenterPos();
        if (this.isKeyJustReleased(key_use))
        {
            CBlob@ carried = this.getCarriedBlob();
            if (carried !is null)
            {
                CBitStream params;
                params.write_u16(closest.getNetworkID());
                this.SendCommand(this.getCommandID("request_putin_carried"), params);
            }
            else // open inventory 
            {
                closest.CreateInventoryMenu(sc);
            }
        }
    }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
    if (this.getCommandID("request_putin_carried") == cmd)
    {
        u16 netid;
        if (!params.saferead_u16(netid)) return;

        CBlob@ blob = getBlobByNetworkID(netid);
        if (blob is null) return;

        CBlob@ carried = this.getCarriedBlob();
        if (carried !is null && carried.canBePutInInventory(blob))
        {
            if (isServer())
            {
                blob.server_DetachFromAll();
                blob.server_PutInInventory(carried);
            }

            if (this.isMyPlayer())
            {
                Sound::Play("PutInInventory.ogg");
            }
        }
    }
}