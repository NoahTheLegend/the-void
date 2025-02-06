#include "Hitters.as";
#include "HumanCommon.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "Help.as";
#include "Requirements.as"
#include "PlacementCommon.as";
#include "ParticleSparks.as";
#include "MaterialCommon.as";

//can't be <2 - needs one frame less for gathering infos
const s32 hit_frame = 2;
const f32 hit_damage = 0.5f;

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -1.5f);

	this.Tag("player");
	this.Tag("flesh");

	HitData hitdata;
	this.set("hitdata", hitdata);

	this.Tag("heavy weight");

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.set_Vec2f("inventory offset", Vec2f(0.0f, 160.0f));

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";

	this.SetChatBubbleFont("RockwellMT_14");
	this.maxChatBubbleLines = 2;
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 1, Vec2f(16, 16));
	}
}

void onTick(CBlob@ this)
{
	if (this.isInInventory())
		return;

	const bool ismyplayer = this.isMyPlayer();

	if (ismyplayer && getHUD().hasMenus())
	{
		return;
	}

	// activate/throw
	if (ismyplayer)
	{
		if (this.isKeyJustPressed(key_action3))
		{
			CBlob@ carried = this.getCarriedBlob();
			if (carried is null || (!carried.hasTag("temp blob") && !carried.hasTag("can place")))
			{
				client_SendThrowOrActivateCommand(this);
			}
		}
	}

	if (ismyplayer && this.isKeyPressed(key_action1) && !this.isKeyPressed(key_inventory))
	{
		BlockCursor @bc;
		this.get("blockCursor", @bc);
	}

	// get rid of the built item
	if (this.isKeyJustPressed(key_inventory) || this.isKeyJustPressed(key_pickup))
	{
		this.set_u8("buildblob", 255);
		this.set_TileType("buildtile", 0);

		CBlob@ blob = this.getCarriedBlob();
		if (blob !is null && blob.hasTag("temp blob"))
		{
			blob.Untag("temp blob");
			blob.server_Die();
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{

}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (attached !is null && attached.getName() == "human"
		&& attached.hasTag("dead") && attached.getSprite() !is null)
	{
		attached.getSprite().SetRelativeZ(-5.0f);
		if (attached.getSprite().getSpriteLayer("head") !is null)
		{
			attached.getSprite().getSpriteLayer("head").SetRelativeZ(-4.0f);
		}
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	if (detached !is null && detached.getName() == "human"
		&& detached.hasTag("dead") && detached.getSprite() !is null)
	{
		detached.getSprite().SetRelativeZ(0.0f);
		if (detached.getSprite().getSpriteLayer("head") !is null)
		{
			detached.getSprite().getSpriteLayer("head").SetRelativeZ(1.0f);
		}
	}

	// ignore collision for built blob
	BuildBlock[][]@ blocks;
	if (!this.get("blocks", @blocks))
	{
		return;
	}

	const u8 PAGE = this.get_u8("build page");
	for (u8 i = 0; i < blocks[PAGE].length; i++)
	{
		BuildBlock@ block = blocks[PAGE][i];
		if (block !is null && block.name == detached.getName())
		{
			this.IgnoreCollisionWhileOverlapped(null);
			detached.IgnoreCollisionWhileOverlapped(null);
		}
	}

	// BUILD BLOB
	// take requirements from blob that is built and play sound
	// put out another one of the same
	if (detached.hasTag("temp blob"))
	{
		detached.Untag("temp blob");
		
		if (!detached.hasTag("temp blob placed"))
		{
			detached.server_Die();
			return;
		}

		uint i = this.get_u8("buildblob");
		if (i >= 0 && i < blocks[PAGE].length)
		{
			BuildBlock@ b = blocks[PAGE][i];
			if (b.name == detached.getName())
			{
				this.set_u8("buildblob", 255);
				this.set_TileType("buildtile", 0);

				CInventory@ inv = this.getInventory();

				CBitStream missing;
				if (hasRequirements(inv, b.reqs, missing, not b.buildOnGround))
				{
					server_TakeRequirements(inv, b.reqs);
				}
				// take out another one if in inventory
				server_BuildBlob(this, blocks[PAGE], i);
			}
		}
	}
	else if (detached.getName() == "seed")
	{
		if (not detached.hasTag('temp blob placed')) return;

		CBlob@ anotherBlob = this.getInventory().getItem(detached.getName());
		if (anotherBlob !is null)
		{
			this.server_Pickup(anotherBlob);
		}
	}
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	// destroy built blob if somehow they got into inventory
	if (blob.hasTag("temp blob"))
	{
		blob.server_Die();
		blob.Untag("temp blob");
	}
}

