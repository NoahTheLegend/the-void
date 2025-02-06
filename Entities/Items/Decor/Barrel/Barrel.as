
#include "GenericButtonCommon.as"

void onInit(CBlob@ this)
{
	this.inventoryButtonPos = Vec2f(0, 0);
	this.getCurrentScript().tickFrequency = 90;

	this.Tag("heavy weight");
	this.SetFacingLeft(XORRandom(100) < 50);

	this.addCommandID("sync");

	if (isServer())
	{
		this.set_u8("anim", XORRandom(anims.length));
		this.set_u8("frame", XORRandom(10));
	}

	if (isClient())
	{
		CBitStream params;
		params.write_bool(true);
		params.write_u16(getLocalPlayer().getNetworkID());
		this.SendCommand(this.getCommandID("sync"), params);
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob.getDistanceTo(this) <= 8.0f && canSeeButtons(this, forBlob);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.isCollidable() && !blob.hasTag("flesh");
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (this.getSprite() is null) return;
	this.getSprite().SetRelativeZ(-20.0f);
}

const string[] anims = {
	"red",
	"yellow",
	"green"
};

void onInit(CSprite@ this)
{
	// Building
	CBlob@ blob = this.getBlob();
	this.SetZ(-20); 
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("sync"))
	{
		bool init;
		if (!params.saferead_bool(init)) return;
		u16 ply_id;
		if (!params.saferead_u16(ply_id)) return;

		CPlayer@ ply = getPlayerByNetworkId(ply_id);
		if (init && isServer() && ply !is null)
		{
			CBitStream params1;
			params1.write_bool(false);
			params1.write_u16(ply_id);
			params1.write_u8(this.get_u8("anim"));
			params1.write_u8(this.get_u8("frame")); // amount of frames here, since its serverside you gotta do it manually
			this.server_SendCommandToPlayer(this.getCommandID("sync"), params1, ply);

			return;
		}
		if (!init && isClient())
		{
			u8 anim = params.read_u8();
			u8 frame = params.read_u8();

			if (anim > anims.length) return;

			CSprite@ sprite = this.getSprite();
			if (sprite is null) return;

			VaryVisuals(sprite, anim, frame);
		}
	}
}

void VaryVisuals(CSprite@ this, u8 anim, u8 frame)
{
	this.SetAnimation(anims[anim]);
	this.SetFrameIndex(frame);
}
