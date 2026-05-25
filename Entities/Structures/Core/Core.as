#include "GenericButtonCommon.as"
#include "MenuCommon.as"
#include "MenuUtils.as"
#include "OptionUtils.as"

const u8 update_frequency = 30;
const Vec2f grinder_offset = Vec2f(23, 21);

void onInit(CBlob@ this)
{
	this.inventoryButtonPos = Vec2f(0, 16);

	// defaultnobuild
	this.set_Vec2f("nobuild extend", Vec2f(0.0f, 8.0f));

	// todo: battery, lamp and terminal spritelayers

	this.addCommandID("sync_core");
	this.Tag("spawn");

	InitGrinder(this);
	if (!isClient()) return;

	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;

	sprite.getConsts().accurateLighting = true;
	sprite.SetZ(-50.0f);
	sprite.SetRelativeZ(-50.0f);

	makeOptions(this);
	RequestSync(this);
}

void makeOptions(CBlob@ this)
{
	{
		MenuItemInfo@ item = AddMenuItem(this, "Grinder", "Grind resources into dust");
		
		string[] descs = {"Slow", "Normal", "Fast"};
		Option@ grinding = makeSliderOption(item, SliderTag::slider_factor, 0, "Grinder", "Grinding Speed", Vec2f(16, 16), Vec2f(8, 8), 1, descs.size()-1);
		grinding.setScroll(0.5f);
		setSliderTextMode(grinding, 2, descs);
		this.set("grinding_option", @grinding);
		addSlideListenerOption(grinding, SetEfficiency);

		Option@ do_start = makeCheckBoxOption(item, 0, 0, "Start", "Start Grinding", Vec2f(24, 24), false);
		do_start.setCheck(true);
		this.set("grind_start_option", @do_start);
		addClickListenerOption(do_start, SetEnable);
	}
}

void addClickListenerOption(Option@ option, CLICK_CALLBACK@ listener)
{
   option.click_listeners.push_back(listener);
}

void addSlideListenerOption(Option@ option, SLIDE_CALLBACK@ listener)
{
    option.slide_listeners.push_back(listener);
}

void SetEnable(int x, int y, bool state, string name, Option@ option, CBlob@ blob)
{
	if (blob is null) return;

	blob.set_bool("enabled", state);
	// todo: actually this changed on our client, now we have to sync to server
}

void SetEfficiency(int x, int y, f32 scroll, string text, Option@ option, CBlob@ blob)
{
	print(""+(blob is null));
	if (blob is null) return;

	blob.set_f32("working_efficiency", scroll);

	print("efficiency: " + scroll);
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
    if (cmd == this.getCommandID("sync_core"))
    {
        bool request = params.read_bool();
        u16 pid = params.read_u16();
        
        if (request && isServer())
        {
            Sync(this, pid);
        }
        else if (!request && isClient())
        {
			// todo
			u16 grinder_id = params.read_u16();
			this.set_u16("grinder_id", grinder_id);

			Option@ grinding;
			if (this.get("grinding_option", @grinding))
			{
				grinding.associated_blob_id = grinder_id;
			}
			
			Option@ do_start;
			if (this.get("grind_start_option", @do_start))
			{
				do_start.associated_blob_id = grinder_id;
			}

			bool enabled = params.read_bool();
			this.set_bool("enabled", enabled);

			f32 efficiency = params.read_f32();
			this.set_f32("working_efficiency", efficiency);
        }
    }
}

void Sync(CBlob@ this, u16 pid = 0)
{
	if (!isServer()) return;

	CBitStream params;
	params.write_bool(false);
	params.write_u16(0);

	params.write_u16(this.get_u16("grinder_id"));
	params.write_bool(this.get_bool("enabled"));
	params.write_f32(this.get_f32("working_efficiency"));

	if (pid != 0)
	{
		CPlayer@ p = getPlayerByNetworkId(pid);
		if (p !is null)
			this.server_SendCommandToPlayer(this.getCommandID("sync_core"), params, p);
	}

	if (pid == 0)
		this.SendCommand(this.getCommandID("sync_core"), params);
}


void RequestSync(CBlob@ this)
{
	if (!isClient() || getLocalPlayer() is null) return;

	CBitStream params;
	params.write_bool(true);
	params.write_u16(getLocalPlayer().getNetworkID());
	this.SendCommand(this.getCommandID("sync_core"), params);
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

	Sync(this);
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