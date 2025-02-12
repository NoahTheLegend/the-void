#include "MessagesClass.as";

void onInit(CRules@ this)
{
    int id = Render::addScript(Render::layer_last, "HUD.as", "RenderHumanCursor", 50000);
	
	//if (getLocalPlayer() !is null)
	if (isClient())
	{
		MessageContainer setbox(30, Vec2f(getDriver().getScreenWidth()/3, 150), Vec2f(20, 15), 24);
		this.set("MessageContainer", @setbox);
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if (isClient() && isServer())
	{
		onInit(this);
	}
}

void onRestart(CRules@ this)
{
	if (isClient() && isServer())
	{
		onInit(this);
	}
}

void onRender(CRules@ this)
{
	if (isClient())
	{
		MessageContainer@ box;
    	if (this.get("MessageContainer", @box))
    	{
    	    if (box !is null)
    	    {
            	ClientVars@ vars = getVars();
    			if (vars !is null)
    			{
            	    box.vars = vars;
				}

    	        box.render();
    	    }
    	}
	}
}

void RenderHumanCursor(int id)
{
	CBlob@ blob = getLocalPlayerBlob();
	ManageCursors(blob);
}

void onTick(CRules@ this)
{
    CBlob@ blob = getLocalPlayerBlob();
    if (blob is null) return;
    
    blobTick(blob);
}

void blobTick(CBlob@ this)
{
	ResetChecks();

	if (this.isKeyJustPressed(key_taunts))
	{
		/*if (XORRandom(2) == 0) addMessage(makeText("onetwo,THREEFOURFIVE!!!sixseveneight,nine,teneleventwelvethirteen fourteen fifteen"+XORRandom(999), formDefaultTitle(null)));
		else*/ addMessage(makeText("lol"+(getGameTime()%30), formDefaultTitle(null)));
	}

	bool a1 = isAction(this);
	this.set_bool("a1", a1);

	u8 frame = getCursorFrame(this);
	this.set_u8("cursor_frame", frame);

	CInventory@ inv = this.getInventory();
	if (inv is null) return;
	Vec2f invsize = inv.getInventorySlots();
	
	for (u16 i = 0; i < invsize.x * invsize.y; i++)
	{
		CBlob@ b = inv.getItem(i);
		if (b is null || !b.hasTag("tool")) continue;

		if (b.hasTag("sharp")) has_sharp = true;
	}
}

bool has_sharp = false;

void ManageCursors(CBlob@ this)
{
	if (getControls() is null) return;
	CMap@ map = getMap();
	if (map is null) return;

	Vec2f mpos = getControls().getInterpMouseScreenPos();
	Vec2f offset = Vec2f(-3, -2);

	f32 v = 255; // visibility
	
	u8 frame = 0;
	bool a1 = getControls().isKeyPressed(KEY_LBUTTON) || getControls().isKeyPressed(KEY_RBUTTON);

	if (this !is null)
	{
		frame = this.get_u8("cursor_frame");
		a1 = this.get_bool("a1");

		if (!getControls().isMenuOpened())
		{
			CGridMenu@ menu = getGridMenuByName("Recipes");
			if (menu is null)
			{
				const u8 map_luminance = map.getColorLight(this.getAimPos()).getLuminance();
				v = Maths::Lerp(this.get_u8("current_alpha"), map_luminance, 0.1f);
				this.set_u8("current_alpha", v);
			}
		}
	}
	v = 255; // disabled temporarily
	f32 scale = getScaleFactor(frame) * cl_mouse_scale / 2;
	GUI::DrawIcon("HumanCursor.png", a1 ? frame+1 : frame, Vec2f(32, 32), mpos+offset, scale, SColor(Maths::Max(155,v), v, v, v));
}

u8 getCursorFrame(CBlob@ this)
{
	if (this.hasTag("carrying_sharp")) return 2;

	if (getControls() is null) return 0;
	CMap@ map = getMap();
	if (map is null) return 0;
	Vec2f mpos = getControls().getInterpMouseScreenPos();

	CBlob@[] list;
	map.getBlobsAtPosition(mpos, @list);
	for (u16 i = 0; i < list.length; i++)
	{
		CBlob@ b = list[i];
		if (b is null) continue;

		if (has_sharp && useSharp(this, b)) return 2;
	}

	return 0;
}

bool isAction(CBlob@ this)
{
	bool a1 = this.isKeyPressed(key_action1);
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null && ap.getOccupied() !is null && ap.getOccupied().get_bool("a1"))
		a1 = true;

	return a1;
}

bool useSharp(CBlob@ this, CBlob@ blob)
{
	return false;
}

f32 getScaleFactor(u8 frame)
{
	switch (frame)
	{
		case 0:
		case 1:
			return 0.5f;
		
		case 2:
		case 3:
			return 0.75f;
	}

	return 0.75f;
}

void ResetChecks()
{
	has_sharp = false;
}