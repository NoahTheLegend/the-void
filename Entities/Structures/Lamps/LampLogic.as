const f32 disable_at_health_factor = 0.33f;

void onInit(CBlob@ this)
{
    this.Tag("builder always hit");
	this.Tag("destructable");
	
    this.SetFacingLeft(int(this.getPosition().x) % 2 == 0);
	this.set_bool("enabled", true);

    this.addCommandID("light_control");
    this.addCommandID("sync");
    RequestSync(this);

	this.getSprite().SetZ(-5);
    this.getCurrentScript().tickFrequency = 15;
}

void onTick(CBlob@ this)
{
    this.SetLight(this.get_bool("enabled"));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("light_control"))
    {
        if (!isServer()) return;
        bool turn_on = params.read_bool();

        if (this.getHealth() <= this.getInitialHealth() * disable_at_health_factor)
            turn_on = false;
            
        // todo failure message to terminal?

        this.set_bool("enabled", turn_on);
        Sync(this);
    }
    else if (cmd == this.getCommandID("sync"))
    {
        bool request = params.read_bool();
        u16 pid = params.read_u16();
        bool light = this.get_bool("enabled");
        
        if (request && isServer())
        {
            Sync(this, pid);
        }
        else if (!request && isClient())
        {
            this.set_bool("enabled", light);
        }
    }
}

void Sync(CBlob@ this, u16 pid = 0)
{
	if (!isServer()) return;

	CBitStream params;
	params.write_bool(false);
	params.write_u16(0);
    params.write_bool(this.get_bool("enabled"));

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

void onHealthChange(CBlob@ this, f32 oldHealth)
{
    f32 hp = this.getHealth();
    f32 inithp = this.getInitialHealth();

    string new_anim = "default";
    if (hp <= inithp * 0.66f)
        new_anim = "damaged";
    else if (hp <= inithp * disable_at_health_factor)
    {
        new_anim = "broken";
        this.set_bool("enabled", false);
    }

    if (!isClient()) return;

    CSprite@ sprite = this.getSprite();
    if (sprite is null) return;
    sprite.SetAnimation(new_anim);

    Animation@ anim = sprite.animation;
    bool enabled = this.get_bool("enabled");
    anim.frame = enabled ? 0 : 1;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return damage;
}

void onDie(CBlob@ this)
{
    this.getSprite().PlaySound("GlassBreak");
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
    return false;
}