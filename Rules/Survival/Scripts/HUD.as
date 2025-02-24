#include "MessagesClass.as";

void onInit(CRules@ this)
{
	if (isClient())
	{
		this.set_s32("cursor_id", 0);
		//int id = Render::addScript(Render::layer_last, "HUD.as", "RenderHumanCursor", 10000);

		MessageContainer setbox(10, Vec2f(getDriver().getScreenWidth()/3, 150), Vec2f(20, 15), 24);
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

int hack = 0;
void onRender(CRules@ this)
{
	if (isClient())
	{
		CPlayer@ player = getLocalPlayer();
		if (player !is null)
		{
			int id = this.get_s32("cursor_id");
			hack++;
			
			if (hack <= 2)
			{
				id = Render::addScript(Render::layer_last, "HUD.as", "RenderHumanCursor", 10000);
				this.set_s32("cursor_id", id);
				print("set cursor id: "+id);
			}
		}

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
		else*/ addMessage(makeText("lol..."+(getGameTime()%30), formDefaultTitle(null)));
	}

	bool a1 = isAction(this);
	this.set_bool("a1", a1);

	u8 frame = getCursorFrame(this);
	this.set_u8("cursor_frame", frame);

	has_sharp = this.hasTag("carrying_sharp");
	has_weapon = this.hasTag("carrying_weapon");
	
	if (has_sharp)
	{
		offset = Vec2f(-4, -4);
	}
	else if (has_weapon)
	{
		offset = Vec2f(-15, -15);
	}
}

Vec2f offset = Vec2f_zero;
bool has_sharp = false;
bool has_weapon = false;

void ManageCursors(CBlob@ this)
{
	if (this is null) return;
	if (getControls() is null) return;

	CMap@ map = getMap();
	if (map is null) return;

	Vec2f mpos = getControls().getInterpMouseScreenPos();
	Vec2f cursor_offset = offset;

	f32 v = 255; // visibility
	
	u8 frame = getCursorFrame(this);
	f32 scale = getScaleFactor(frame) * cl_mouse_scale / 2;
	GUI::DrawIcon("HumanCursor.png", frame, Vec2f(32, 32), mpos + cursor_offset, scale, SColor(Maths::Max(155,v), v, v, v));
}

u8 getCursorFrame(CBlob@ this)
{
	bool a1 = isAction(this);
	u8 extra = a1 ? 1 : 0;

	u8 frame = 0;
	if (this.hasTag("carrying_sharp")) frame = 2;
	else if (this.hasTag("carrying_weapon")) frame = 4;

	return frame + extra;
}

bool isAction(CBlob@ this)
{
	if (this is null) return false;

	bool a1 = this.isKeyPressed(key_action1);
	CBlob@ carried = this.getCarriedBlob();
	if (carried !is null)
	{
		AttachmentPoint@ ap = carried.getAttachments().getAttachmentPointByName("PICKUP");
		if (ap !is null)
		{
			a1 = ap.isKeyPressed(key_action1) || carried.isKeyPressed(key_action1);
		}
	}

	return a1;
}

f32 getScaleFactor(u8 frame)
{
	switch (frame)
	{
		case 0:
		case 1:
		case 4:
		case 5:
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
	has_weapon = false;
}