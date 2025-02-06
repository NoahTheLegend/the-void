// Standard menu player controls

#include "EmotesCommon.as"
#include "StandardControlsCommon.as"

bool zoomModifier = false; // decides whether to use the 3 zoom system or not
int zoomModifierLevel = 4; // for the extra zoom levels when pressing the modifier key
f32 zoomLevel = 1.0f; // we can declare a global because this script is just used by myPlayer
f32 rawZoom = 1.0f;

void onInit(CBlob@ this)
{
	this.set_s32("tap_time", getGameTime());
	CBlob@[] blobs;
	this.set("pickup blobs", blobs);
	this.set_u16("hover netid", 0);
	this.set_bool("release click", false);
	this.set_bool("can button tap", true);
	this.addCommandID("pickup");
	this.addCommandID("putinheld");
	this.addCommandID("getout");
	this.addCommandID("detach");
	this.addCommandID("cycle");
	this.addCommandID("switch");
	this.addCommandID("tap inventory key");

	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";

	//add to the sprite
	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		sprite.AddScript("StandardControls.as");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (!getNet().isServer())                                // server only!
	{
		return;
	}

	if (cmd == this.getCommandID("putinheld"))
	{
		CBlob@ owner = getBlobByNetworkID(params.read_netid());

		putInHeld(owner);
	}
	else if (cmd == this.getCommandID("tap inventory key"))
	{
		CBlob@ owner = getBlobByNetworkID(params.read_netid());

		if (!putInHeld(owner))
		{
			this.SendCommand(this.getCommandID("cycle"));
		}
	}
	else if (cmd == this.getCommandID("pickup"))
	{
		CBlob@ owner = getBlobByNetworkID(params.read_netid());
		CBlob@ pick = getBlobByNetworkID(params.read_netid());

		if (owner !is null && pick !is null)
		{
			owner.server_Pickup(pick);
		}
	}
	else if (cmd == this.getCommandID("detach"))
	{
		CBlob@ obj = getBlobByNetworkID(params.read_netid());

		if (obj !is null)
		{
			this.server_DetachFrom(obj);
		}
	}
	else if (cmd == this.getCommandID("getout"))
	{
		if (this.getInventoryBlob() !is null)
		{
			this.getInventoryBlob().server_PutOutInventory(this);
		}
	}
}

bool putInHeld(CBlob@ owner)
{
	if (owner is null) return false;

	CBlob@ held = owner.getCarriedBlob();

	if (held is null) return false;

	return owner.server_PutInInventory(held);
}

bool ClickGridMenu(CBlob@ this, int button)
{
	CGridMenu @gmenu;
	CGridButton @gbutton;

	if (this.ClickGridMenu(button, gmenu, gbutton))   // button gets pressed here - thing get picked up
	{
		if (gmenu !is null)
		{
			// if (gmenu.getName() == this.getInventory().getMenuName() && gmenu.getOwner() !is null)
			{
				if (gbutton is null)    // carrying something, put it in
				{
					server_PutInHeld(this, gmenu.getOwner());
				}
				else // take something
				{
					// handled by button cmd   // hardcoded still :/
				}
			}
			return true;
		}
	}

	return false;
}

void ButtonOrMenuClick(CBlob@ this, Vec2f pos, bool clear, bool doClosestClick)
{
	if (!ClickGridMenu(this, 0))
		if (this.ClickInteractButton())
		{
			clear = false;
		}
		else if (doClosestClick)
		{
			if (this.ClickClosestInteractButton(pos, this.getRadius() * 1.0f))
			{
				this.ClearButtons();
				clear = false;
			}
		}

	if (clear)
	{
		this.ClearButtons();
		this.ClearMenus();
	}
}

void onTick(CBlob@ this)
{
	if (getCamera() is null)
	{
		return;
	}
	ManageCamera(this);

	CControls@ controls = getControls();

	// use menu

	if (this.isKeyJustPressed(key_use))
	{
		Tap(this);
		this.set_bool("can button tap", !getHUD().hasMenus());
		this.ClearMenus();
		this.ShowInteractButtons();
		this.set_bool("release click", true);
	}
	else if (this.isKeyJustReleased(key_use))
	{
		if (this.get_bool("release click"))
		{
			ButtonOrMenuClick(this, this.getPosition(), true, isTap(this) && this.get_bool("can button tap"));
		}

		this.ClearButtons();
	}

	CBlob @carryBlob = this.getCarriedBlob();


	// bubble menu

	if (this.isKeyJustPressed(key_bubbles))
	{
		Tap(this);
	}

	// taunt menu

	if (this.isKeyJustPressed(key_taunts))
	{
		Tap(this);
	}

	/*else dont use this cause menu won't be release/clickable
	if (this.isKeyJustReleased(key_bubbles))
	{
	    this.ClearBubbleMenu();
	} */

	// in crate

	if (this.isInInventory())
	{
		if (this.isKeyJustPressed(key_pickup))
		{
			CBlob@ invblob = this.getInventoryBlob();
			// Use the inventoryblob command if it has one (crate for example)
			if (invblob.hasCommandID("getout"))
			{
				CBitStream params;
				params.write_u16(this.getNetworkID());
				invblob.SendCommand(invblob.getCommandID("getout"), params);
			}
			else
			{
				this.SendCommand(this.getCommandID("getout"));
			}
		}

		return;
	}

	// no more stuff possible while in crate...

	// inventory menu

	if (this.getInventory() !is null && this.getTickSinceCreated() > 10)
	{
		if (this.isKeyJustPressed(key_inventory))
		{
			Tap(this);
			this.set_bool("release click", true);
			// this.ClearMenus();

			//  Vec2f center =  getDriver().getScreenCenterPos(); // center of screen
			Vec2f center = controls.getMouseScreenPos();
			if (this.exists("inventory offset"))
			{
				this.CreateInventoryMenu(center + this.get_Vec2f("inventory offset"));
			}
			else
			{
				this.CreateInventoryMenu(center);
			}

			//controls.setMousePosition( center );
		}
		else if (this.isKeyJustReleased(key_inventory))
		{
			if (isTap(this, 7))     // tap - put thing in inventory
			{
				CBitStream params;
				params.write_netid(this.getNetworkID());
				this.SendCommand(this.getCommandID("tap inventory key"), params);

				this.ClearMenus();
				return;
			}
			else // click inventory
			{
				if (this.get_bool("release click"))
				{
					ClickGridMenu(this, 0);
				}

				if (!this.hasTag("dont clear menus"))
				{
					this.ClearMenus();
				}
				else
				{
					this.Untag("dont clear menus");
				}
			}
		}
	}

	// release action1 to click buttons

	if (getHUD().hasButtons())
	{
		if ((this.isKeyJustPressed(key_action1) /*|| controls.isKeyJustPressed(KEY_LBUTTON)*/) && !this.isKeyPressed(key_pickup))
		{
			ButtonOrMenuClick(this, this.getAimPos(), false, true);
			this.set_bool("release click", false);
		}
	}

	// clear grid menus on move

	if (!this.isKeyPressed(key_inventory) &&
	        (this.isKeyJustPressed(key_left) || this.isKeyJustPressed(key_right) || this.isKeyJustPressed(key_up) ||
	         this.isKeyJustPressed(key_down) || this.isKeyJustPressed(key_action2) || this.isKeyJustPressed(key_action3))
	   )
	{
		this.ClearMenus();
	}

	//if (this.isKeyPressed(key_action1))
	//{
	//  //server_DropCoins( this.getAimPos(), 100 );
	//  CBlob@ mat = server_CreateBlob( "cata_rock", 0, this.getAimPos());
	//}

	// keybinds

	if (controls.ActionKeyPressed(AK_BUILD_MODIFIER))
	{
		EKEY_CODE[] keybinds = { KEY_KEY_1, KEY_KEY_2, KEY_KEY_3, KEY_KEY_4, KEY_KEY_5, KEY_KEY_6, KEY_KEY_7, KEY_KEY_8, KEY_KEY_9, KEY_KEY_0 };

		// loop backwards so leftmost keybinds have priority
		for (int i = keybinds.size() - 1; i >= 0; i--)
		{
			if (controls.isKeyJustPressed(keybinds[i]))
			{
				CBitStream params;
				params.write_u8(i);
				this.SendCommand(this.getCommandID("switch"), params);
			}
		}
	}
}

// show dots on chat

void onDie(CBlob@ this)
{
	set_emote(this, "off");
}

// CAMERA

void onInit(CSprite@ this)
{
	//backwards compat - tag the blob if we're assigned to the sprite too
	//so if it's not there, the blob can adjust the camera at 30fps at least
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	blob.Tag("60fps_camera");
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null || !blob.isMyPlayer()) return;
	zoomLevel = Maths::Lerp(zoomLevel, rawZoom, 0.1f);
	//do 60fps camera
	AdjustCamera(blob, true);
}

void AdjustCamera(CBlob@ this, bool is_in_render)
{
	CCamera@ camera = getCamera();
	f32 zoom = camera.targetDistance;

	f32 zoomSpeed = 0.1f;
	if (is_in_render)
	{
		zoomSpeed *= getRenderApproximateCorrectionFactor();
	}

	f32 minZoom = 0.5f; // TODO: make vars
	f32 maxZoom = 2.0f;

	f32 zoom_target = zoomLevel;

	if (zoom > zoom_target)
	{
		zoom = Maths::Max(zoom_target, zoom - zoomSpeed);
	}
	else if (zoom < zoom_target)
	{
		zoom = Maths::Min(zoom_target, zoom + zoomSpeed);
	}

	camera.targetDistance = zoom;
}

void ManageCamera(CBlob@ this)
{
	CCamera@ camera = getCamera();
	CControls@ controls = this.getControls();

	if (controls !is null)
	{
		if (controls.isKeyPressed(KEY_LSHIFT))
		{
			// mouse look & zoom
			if ((getGameTime() - this.get_s32("tap_time") > 5))
			{
				if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_ZOOMOUT)))
				{
					rawZoom = Maths::Max(1.0f, zoomLevel - 1.0f);
					Tap(this);
				}
				else if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_ZOOMIN)))
				{
					rawZoom = Maths::Min(4.0f, zoomLevel + 1.0f);
					Tap(this);
				}
			}
		}

		// zoom out
		if (controls.isKeyPressed(KEY_MINUS))
		{
			rawZoom = Maths::Max(1.0f, rawZoom - 0.1f);
		}
		// zoom in
		if (controls.isKeyPressed(KEY_PLUS))
		{
			rawZoom = Maths::Min(4.0f, rawZoom + 0.1f);
		}
	}

	if (!this.hasTag("60fps_camera"))
	{
		AdjustCamera(this, false);
	}

	f32 zoom = camera.targetDistance;
	bool fixedCursor = true;
	camera.mousecamstyle = 1; // fixed

	// camera
	camera.mouseFactor = 0.5f;
}
