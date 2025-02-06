#include "FoodCommon.as"

void onInit(CBlob@ this)
{
	if (!this.exists("eat sound")) this.set_string("eat sound", "/Eat.ogg");
    
    this.addCommandID("menu");

	this.addCommandID("open_canned");
    this.addCommandID("fill");
    
    this.addCommandID("eat100");
    this.addCommandID("eat50");
    this.addCommandID("eat25");

    this.addCommandID("sync");
	this.Tag("pushedByDoor");

    // not spritesheet! Only animation frames (i.e. 0 and 8)
    if (!this.exists("type")) this.set_u8("type", 0);
    if (!this.exists("invframe")) this.set_u8("invframe", this.inventoryIconFrame);

    CSprite@ sprite = this.getSprite();
    if (sprite is null) return;

    AddIconToken("$icon_fill$", sprite.getConsts().filename, Vec2f(16, 16), this.get_u8("type"));
	AddIconToken("$icon_eat100$", "FoodIcons.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_eat50$", "FoodIcons.png", Vec2f(16, 16), 1);
    AddIconToken("$icon_eat25$", "FoodIcons.png", Vec2f(16, 16), 2);
    AddIconToken("$icon_opencanned$", "FoodIcons.png", Vec2f(16, 16), 3);

    initFoodStats(this);
    if (isClient()) defaultSync(this);
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ ap)
{
    if (getLocalPlayerBlob() !is null && getLocalPlayerBlob() is attached)
    {
        defaultSync(this);
    }
}

void defaultSync(CBlob@ this)
{
    if (isClient())
    {
        CBitStream params;
        params.write_bool(false);
        params.write_u16(getLocalPlayer().getNetworkID()); // might be null pls test
        this.SendCommand(this.getCommandID("sync"), params);
    }
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    return; // all other code is legacy
    if (this.hasTag("trash")) return;

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
    if (ap !is null && ap.getOccupied() !is null && ap.getOccupied().isMyPlayer()) // caller doesnt work like this :\
    {
        CBitStream params;
        params.write_u16(ap.getOccupied().getNetworkID());
		caller.CreateGenericButton(22, Vec2f(0, 0), this, this.getCommandID("menu"), "", params);
    }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
    if (cmd == this.getCommandID("sync"))
    {
        bool init = params.read_bool();
        u16 plyid;
        if (!params.saferead_u16(plyid)) return;

        CPlayer@ local = getPlayerByNetworkId(plyid);
        if (!init && isServer() && local !is null)
        {
            CBitStream nextparams;
            nextparams.write_bool(true);
            nextparams.write_u16(plyid);

            nextparams.write_string(this.getInventoryName());
            nextparams.write_u8(this.get_u8("type"));
            nextparams.write_bool(this.hasTag("canned_food"));
            nextparams.write_bool(false);

            this.server_SendCommandToPlayer(this.getCommandID("sync"), nextparams, local);
        }
        else if (init && isClient())
        {
            string name;
            if (!params.saferead_string(name)) return;
            u8 frame;
            if (!params.saferead_u8(frame)) return;
            bool is_canned;
            if (!params.saferead_bool(is_canned)) return;

            if (!this.hasTag("foodstats_synced"))
            {
                this.Tag("foodstats_synced");
                initFoodStats(this);
            }
           
            if (this.hasTag("canned_food") && !is_canned)
                this.Untag("canned_food");

            bool trash = params.read_bool(); // consumed
            if (trash)
                this.Tag("trash"); 

            this.setInventoryName(name);
            this.set_u8("type", frame);
            CSprite@ sprite = this.getSprite();
            if (sprite !is null)
            {
                sprite.animation.frame = frame;
                this.SetInventoryIcon(sprite.getConsts().filename, this.get_u8("invframe")+frame, Vec2f(16,16));
            }
        }
    }
	else if (cmd == this.getCommandID("menu"))
    {
        u16 callerid;
        if (!params.saferead_u16(callerid)) return;

        CBlob@ caller = getBlobByNetworkID(callerid);
        if (caller is null) return;

        Menu(this, caller);
    }
    else if (cmd == this.getCommandID("open_canned"))
    {
        CSprite@ sprite = this.getSprite();
        if (isClient() && sprite !is null)
        {
            this.getSprite().PlaySound("TinCanOpen.ogg");
            AddSpecificSpriteLayer(this, sprite);
        }
        this.Untag("canned_food");
    }
    else if (cmd == this.getCommandID("eat100"))
    {
        playEatSound(this); 

        u16 callerid;
        if (!params.saferead_u16(callerid)) return;
        CBlob@ caller = getBlobByNetworkID(callerid);

        if (isServer())
            emptyCanned(this, caller, callerid);
    }
    else if (cmd == this.getCommandID("eat50"))
    {
        playEatSound(this); 

        u16 callerid;
        if (!params.saferead_u16(callerid)) return;
        CBlob@ caller = getBlobByNetworkID(callerid);

        if (isServer())
        {
            if (this.getHealth() - 0.5f <= 0.0f)
                emptyCanned(this, caller, callerid);
            else
                this.server_SetHealth(this.getHealth() - 0.5f);
        }
    }
    else if (cmd == this.getCommandID("eat25"))
    {
        playEatSound(this); 
        
        u16 callerid;
        if (!params.saferead_u16(callerid)) return;
        CBlob@ caller = getBlobByNetworkID(callerid);

        if (isServer())
        {
            if (this.getHealth() - 0.25f <= 0.0f)
                emptyCanned(this, caller, callerid);
            else
                this.server_SetHealth(this.getHealth() - 0.25f);
        }
    }
}

void Menu(CBlob@ this, CBlob@ caller)
{
	if (caller !is null && caller.isMyPlayer())
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());

        bool canned = this.hasTag("canned_food");
		CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(0.0f, 0.0f), this, Vec2f(canned ? 1 : 3, 1), "Options");

		if (menu !is null)
		{
			menu.deleteAfterClick = true;

            f32 hp = this.getHealth();
            f32 ihp = this.getInitialHealth();


            if (canned)
            {
                bool can_open = false;

                CInventory@ inv = caller.getInventory();
                if (inv !is null)
                {
                    for (u8 i = 0; i < inv.getInventorySlots().x * inv.getInventorySlots().y; i++)
                    {
                        CBlob@ b = inv.getItem(i);
                        if (b !is null &&
                            (b.hasTag("sharp") || b.hasTag("axe") || b.hasTag("pickaxe")))
                        {
                            can_open = true;
                            break;
                        }
                    }
                }

                CGridButton@ btn = menu.AddButton("$icon_opencanned$", "Open"+(can_open?"":" (requires something sharp)"), this.getCommandID("open_canned"), Vec2f(1, 1), params);
                btn.SetEnabled(can_open);
                return;
            }
            {
			    CGridButton@ btn = menu.AddButton("$icon_eat100$", "Eat", this.getCommandID("eat100"), Vec2f(1, 1), params);
			    if ((btn !is null && hp < ihp) || canned)
                    btn.SetEnabled(false);
            }
            {
                CGridButton@ btn = menu.AddButton("$icon_eat50$", "Eat (1/2)", this.getCommandID("eat50"), Vec2f(1, 1), params);
			    if ((btn !is null && hp < ihp*0.5f) || canned)
                    btn.SetEnabled(false);
            }
            {
                CGridButton@ btn = menu.AddButton("$icon_eat25$", "Eat (1/4)", this.getCommandID("eat25"), Vec2f(1, 1), params);
			    if ((btn !is null && hp < ihp*0.25f) || canned)
                    btn.SetEnabled(false);
            }
        }
	}
}

void onRender(CSprite@ this)
{
    if (!(isClient() && isServer())) return;

    CBlob@ blob = this.getBlob();
    if (blob is null) return;

    FoodStats@ stats;
    if (!blob.get("FoodStats", @stats)) return;

    Vec2f pos = getDriver().getScreenPosFromWorldPos(Vec2f_lerp(blob.getOldPosition(), blob.getPosition(), getInterpolationFactor()));
    GUI::DrawText(stats.name+"\nh "+stats.hunger+"\nt "+stats.thirst+"\nhp "+blob.getHealth(), pos, SColor(255,255,255,0));
}

void AddSpecificSpriteLayer(CBlob@ this, CSprite@ sprite)
{
    CSpriteLayer@ open_can = sprite.getSpriteLayer("open_can");
        if (open_can is null)
    {
        CSpriteLayer@ layer = sprite.addSpriteLayer("open_can", sprite.getConsts().filename, 16, 16);
        if (layer is null) return;
        Animation@ anim = layer.addAnimation("default", 0, false);
        if (anim is null) return;
        anim.AddFrame(this.getName() == "foodcan" ? 71 : 79);

        layer.SetAnimation("default");
        layer.animation.frame = 0;
    }
}