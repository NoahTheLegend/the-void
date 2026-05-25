
void onInit(CBlob@ this)
{
    this.addCommandID("sync_building");

    // todo: electricity
    this.set_bool("enabled", true);
    this.set_f32("working_efficiency", 1.0f);

    if (!isClient()) return;
    if (getLocalPlayer() is null) return;

    CBitStream params;
    params.write_bool(true);
    params.write_u16(getLocalPlayer().getNetworkID());
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("sync_building"))
    {
        bool request = params.read_bool();
        u16 pid = params.read_u16();

        if (isServer() && request)
        {
            Sync(this, pid);
        }
        else if (isClient() && !request)
        {
            bool enabled = params.read_bool();
            f32 efficiency = params.read_f32();

            this.set_bool("enabled", enabled);
            this.set_f32("working_efficiency", efficiency);
        }
    }
}

void Sync(CBlob@ this, u16 pid = 0)
{
    if (!isServer()) return;

    CBitStream params;
    params.write_bool(false);
    params.write_u16(pid);
    params.write_bool(this.get_bool("enabled"));
    params.write_f32(this.get_f32("working_efficiency"));

    if (pid != 0)
    {
        CPlayer@ p = getPlayerByNetworkId(pid);
        if (p !is null)
            this.server_SendCommandToPlayer(this.getCommandID("sync_building"), params, p);
    }
    else
    {
        this.SendCommand(this.getCommandID("sync_building"), params);
    }
}