#include "UtilityChecks.as"

const u8 tap_delay = 10;
const f32 radius = 8.0f;
void onInit(CBlob@ this)
{
    this.addCommandID("request_putin_carried");
    this.addCommandID("pick_inventory");
    this.addCommandID("update_menu");

    this.set_u16("update_netid", 0);
    this.set_u32("update_timing", 0);
}

void onTick(CBlob@ this)
{
    if (!this.isMyPlayer()) return;
    if (this.isKeyJustPressed(key_pickup)) this.ClearGridMenus();

    bool holding = this.isKeyPressed(key_eat);
    if (!holding)
    {
        if (this.hasTag("ignore_holding")) this.Untag("ignore_holding");
        else return;
    }
    if (isInMenu(this)) return;

    CControls@ controls = getControls();
    if (controls is null) return;

    if (this.hasTag("request_update") && getGameTime() >= this.get_u32("update_timing"))
    {
        u16 netid = this.get_u16("update_netid");
        CBlob@ blob = getBlobByNetworkID(netid);
        if (blob !is null)
        {
            Vec2f sc = getDriver().getScreenCenterPos();
            CreateCustomInventoryMenu(this, blob, sc);

            this.Untag("request_update");
            this.set_u16("update_netid", 0);
            this.set_u32("update_timing", 0);
        }
    }

    CHUD@ hud = getHUD();
    if (hud is null || hud.hasMenus()) return;

    Vec2f mpos = controls.getMouseWorldPos();
    CBlob@[] blobs;
    getMap().getBlobsInBox(mpos - Vec2f(radius, radius), mpos + Vec2f(radius, radius), @blobs);

    f32 closestDist = 999.0f;
    CBlob@ closest = null;
    for (int i = 0; i < blobs.length; i++)
    {
        CBlob@ blob = blobs[i];
        if (blob !is null && blob.hasTag("custom_inventory") && 
            (blob.getDistanceTo(this) < blob.get_f32("max_inventory_distance") || blob.isOverlapping(this)))
        {
            f32 dist = (blob.getPosition() - mpos).Length();
            if (dist < closestDist)
            {
                closestDist = dist;
                @closest = blob;
            }
        }
    }

    if (closest !is null)
    {
        if (holding)
        {
            closest.set_u32("last_hover_time", getGameTime() + 1);
            this.Tag("ignore_holding");
        }

        Vec2f sc = getDriver().getScreenCenterPos();
        if (this.isKeyJustReleased(key_eat) || (holding && this.isKeyJustPressed(key_action1)))
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
                CreateCustomInventoryMenu(this, closest, sc);

                f32 volume = closest.get_f32("inventory_volume");
                f32 pitch = closest.get_f32("inventory_pitch") + XORRandom(100 * closest.get_f32("inventory_pitch_random")) * 0.01f;
                this.getSprite().PlayRandomSound(closest.get_string("inventory_open_sound"), volume, pitch);
            }
        }
    }
}

void CreateCustomInventoryMenu(CBlob@ this, CBlob@ blob, Vec2f screenpos)
{
    this.ClearGridMenus();

    CInventory@ inv = blob.getInventory();
    if (inv is null) return;

    CGridMenu@ menu = CreateGridMenu(screenpos, blob, inv.getInventorySlots(), blob.getInventoryName());
    if (menu !is null)
    {
        menu.deleteAfterClick = false;
        menu.SetCaptionEnabled(true);

        array<CBlob@> items;
        array<int> itemCounts;

        for (int i = 0; i < inv.getItemsCount(); i++)
        {
            CBlob@ item = inv.getItem(i);
            if (item is null) continue;

            bool found = false;
            for (uint j = 0; j < items.length; j++)
            {
                if (items[j].getName() == item.getName())
                {
                    itemCounts[j] += item.getQuantity();
                    found = true;
                    break;
                }
            }

            if (!found)
            {
                items.push_back(item);
                itemCounts.push_back(item.getQuantity());
            }
        }

        for (uint i = 0; i < items.length; i++)
        {
            CBlob@ item = items[i];
            int itemCount = itemCounts[i];

            while (itemCount > 0)
            {
                CBitStream params;
                params.write_u16(blob.getNetworkID());
                params.write_string(item.getName());

                Vec2f frame_dim = Vec2f(Maths::Round(item.inventoryFrameDimension.x / 16.0f), Maths::Round(item.inventoryFrameDimension.y / 16.0f));
                CGridButton@ button = menu.AddButton("$"+item.getName()+"$", item.getInventoryName(), "CustomInventoryButtonRunner.as", "CallbackPickInventory", frame_dim, params);
                if (button !is null)
                {
                    int quantity = Maths::Min(itemCount, item.inventoryMaxStacks * item.maxQuantity);
                    button.SetNumber(quantity);
                    button.deleteAfterClick = true;

                    itemCount -= quantity;
                }
            }
        }
    }
}

void CallbackPickInventory(CBitStream@ params)
{
    CBlob@ this = getLocalPlayerBlob();
    if (this is null) return;

    this.SendCommand(this.getCommandID("pick_inventory"), params);
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
    else if (this.getCommandID("pick_inventory") == cmd)
    {
        if (isServer())
        {
            u16 netid;
            string itemName;
            if (!params.saferead_u16(netid)) return;
            if (!params.saferead_string(itemName)) return;

            CBlob@ blob = getBlobByNetworkID(netid);
            if (blob is null) return;

            CInventory@ inv = blob.getInventory();
            if (inv is null) return;

            bool success = false;
            CBlob@ carried = this.getCarriedBlob();
            if (carried is null)
            {
                //if (isServer())
                {
                    CBlob@ item = inv.getItem(itemName);
                    if (item !is null)
                    {
                        blob.server_PutOutInventory(item);
                        this.server_Pickup(item);

                        success = true;
                    }
                }
            }
            else
            {
                //if (isServer())
                {
                    CBlob@ item = inv.getItem(itemName);
                    if (item !is null && carried.canBePutInInventory(this))
                    {
                        carried.server_DetachFromAll();
                        this.server_PutInInventory(carried);

                        blob.server_PutOutInventory(item);
                        this.server_Pickup(item);

                        success = true;
                    }
                }
            }

            if (success)
            {
                CBitStream params1;
                params1.write_u16(netid);
                this.server_SendCommandToPlayer(this.getCommandID("update_menu"), params1, this.getPlayer());
            }
        }
    }
    else if (this.getCommandID("update_menu") == cmd)
    {
        if (!this.isMyPlayer()) return;

        u16 netid;
        if (!params.saferead_u16(netid)) return;

        CBlob@ blob = getBlobByNetworkID(netid);
        if (blob is null) return;
        
        this.Tag("request_update");
        this.set_u16("update_netid", netid);
        this.set_u32("update_timing", getGameTime() + 2);
        //Vec2f sc = getDriver().getScreenCenterPos();
        //CreateCustomInventoryMenu(this, blob, sc);
    }
}