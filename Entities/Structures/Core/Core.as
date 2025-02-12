#include "GenericButtonCommon.as"

const u8 update_frequency = 30;
const Vec2f grinder_offset = Vec2f(23, 13);

void onInit(CBlob@ this)
{
	this.setPosition(this.getPosition()-Vec2f(0,24));
	this.inventoryButtonPos = Vec2f(0, 16);

	// defaultnobuild
	this.set_Vec2f("nobuild extend", Vec2f(0.0f, 8.0f));

	// todo: battery, lamp and terminal spritelayers

	this.addCommandID("sync");
	this.Tag("spawn");

	InitGrinder(this);

	if (!isClient()) return;

	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;

	sprite.getConsts().accurateLighting = true;
	sprite.SetZ(-50.0f);
	sprite.SetRelativeZ(-50.0f);
}

void onTick(CBlob@ this)
{
	if (getGameTime() % update_frequency == 0)
	{
		if (!hasGrinder(this)) InitGrinder(this);
		Sync(this);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{

}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("sync"))
    {
        bool request = params.read_bool();
        u16 pid = params.read_u16();
        
        if (request && isServer())
        {
            Sync(this, pid);
        }
        else if (!request && isClient())
        {

        }
    }
}

void Sync(CBlob@ this, u16 pid = 0)
{
	if (!isServer()) return;

	CBitStream params;
	params.write_bool(false);
	params.write_u16(0);

	if (pid != 0)
	{
		CPlayer@ p = getPlayerByNetworkId(pid);
		if (p !is null)
			this.server_SendCommandToPlayer(this.getCommandID("sync"), params, p);
	}

	if (pid == 0)
		this.SendCommand(this.getCommandID("sync"), params);
}


void RequestSync(CBlob@ this)
{
	if (!isClient() || getLocalPlayer() is null) return;

	CBitStream params;
	params.write_bool(true);
	params.write_u16(getLocalPlayer().getNetworkID());
	this.SendCommand(this.getCommandID("sync"), params);
}

void InitGrinder(CBlob@ this)
{
	if (!isServer()) return;

	CBlob@ blob = server_CreateBlob("grindersmall", this.getTeamNum(), this.getPosition() + grinder_offset);
	if (blob is null) return;

	if (blob.hasScript("AlignToTiles.as")) blob.RemoveScript("AlignToTiles.as");
	blob.AddScript("IgnoreDamage.as");

	this.set_u16("grinder_id", blob.getNetworkID());
	blob.set_u16("parent_id", this.getNetworkID());
}

bool hasGrinder(CBlob@ this)
{
	u16 id = this.get_u16("grinder_id");
	return id != 0 && getBlobByNetworkID(id) !is null;
}

void onDie(CBlob@ this)
{
	CBlob@ blob = getBlobByNetworkID(this.get_u16("grinder_id"));
	if (blob !is null) blob.server_Die();
}