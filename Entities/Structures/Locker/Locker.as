
#include "GenericButtonCommon.as"

const string[] anims = {
	"light",
	"dark",
	"blue"
};

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	this.SetZ(-50);
}

void onInit(CBlob@ this)
{
	this.getShape().getConsts().mapCollisions = false;
	AddIconToken("$store_inventory$", "InteractionIcons.png", Vec2f(32, 32), 28);
	this.inventoryButtonPos = Vec2f(0, 0);
	this.getCurrentScript().tickFrequency = 60;

	this.addCommandID("sync");
	// TODO: share randomprops (except seed) to nearby lockers
	if (isServer())
	{
		this.set_u8("anim", XORRandom(anims.length));
		this.set_u8("frame", XORRandom(12));
		this.set_u32("seed", XORRandom(696969));
	}

	if (isClient())
	{
		CBitStream params;
		params.write_bool(true);
		params.write_u16(getLocalPlayer().getNetworkID());
		this.SendCommand(this.getCommandID("sync"), params);
	}
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
			params1.write_u32(this.get_u32("seed")); // seed for spritelayers
			this.server_SendCommandToPlayer(this.getCommandID("sync"), params1, ply);

			return;
		}
		if (!init && isClient())
		{
			u8 anim = params.read_u8();
			u8 frame = params.read_u8();
			u32 seed = params.read_u32();

			if (anim > anims.length) return;

			CSprite@ sprite = this.getSprite();
			if (sprite is null) return;

			VaryVisuals(sprite, anim, frame, seed);
		}
	}
}

const u8 stickers_total = 7; // including 0

void VaryVisuals(CSprite@ this, u8 anim, u8 frame, u32 seed)
{ // if you struggle on reading this code, you have a skill issue (confirmed)
	this.SetAnimation(anims[anim]);
	this.SetFrameIndex(frame);

	if (this.animation.frame < 5)
	{
		bool has_amogus = (seed+"").find("6") != -1 && (seed+"").find("9") != -1;
		if (has_amogus)
		{
			CSpriteLayer@ amo = this.addSpriteLayer("amo", "VisualEffects.png", 16, 16);
			if (amo is null) return;
			Animation@ anim = amo.addAnimation("frame", 0, false);
			if (anim is null) return;
			//printf("sus");
			anim.AddFrame(seed%2 + 2);
			amo.SetAnimation(anim);
			amo.ScaleBy(Vec2f(0.33f, 0.33f));
			amo.SetOffset(Vec2f((XORRandom(100)-100)*0.01f,(XORRandom(30)-50)*0.1f));
		}
	}

	/* looks ugly in-game
	if (this.animation.frame < 5) // not open door
	{
		int stickers = Maths::Max(0, Maths::Round(seed/10)%5);
		if (stickers != 0)
		{
			for (u8 i = 0; i < stickers; i++)
			{
				CSpriteLayer@ s = this.addSpriteLayer("s"+i, "Stickers.png", 2, 2);
				if (s is null) continue;

				s.SetOffset(getStickerOffset(i, seed));
				printf(""+s.getOffset());

				Animation@ frame = s.addAnimation("frame", 0, false);
				if (frame is null) continue;

				frame.AddFrame(seed/(9-i)%stickers_total);
				s.SetAnimation("frame");
			}
		}
	}
	*/
}
/*
Vec2f getStickerOffset(u8 i, u32 seed)
{
	return Vec2f((Maths::Pow(seed, i+1)%15-7.5f)/8, Maths::Pow(seed, i+1)%4-4)*2;
}
*/

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob.getDistanceTo(this) <= 8.0f && canSeeButtons(this, forBlob);
}