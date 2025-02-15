
void onInit(CBlob@ this)
{
    this.addCommandID("sync_menu");
    this.addCommandID("move_at");
    this.addCommandID("attach_player");
    this.addCommandID("detach_player");
    
    u16[] attached_players;
    this.set("attached_players", @attached_players);
    this.set_bool("draw_attached_players", false);

	RequestSync(this);
}

void onTick(CBlob@ this)
{
    if (!isClient()) return;

    CBlob@ local = getLocalPlayerBlob();
    if (local is null) return;

    CPlayer@ p = local.getPlayer();
    if (p is null) return;

    u16 netid = p.getNetworkID();
    u16[]@ attached_players;
    this.get("attached_players", @attached_players);

    if (attached_players.find(netid) != -1)
    {
        bool left = local.isKeyPressed(key_left);
        bool right = local.isKeyPressed(key_right);
        bool up = local.isKeyPressed(key_up);
        bool down = local.isKeyPressed(key_down);

        CBitStream params;
        params.write_bool(left);
        params.write_bool(right);
        params.write_bool(up);
        params.write_bool(down);
        this.SendCommand(this.getCommandID("move_at"), params);
    }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("move_at"))
    {
        bool left = params.read_bool();
        bool right = params.read_bool();
        bool up = params.read_bool();
        bool down = params.read_bool();

        
    }
    else if (cmd == this.getCommandID("sync_menu"))
    {
        bool request = params.read_bool();
        u16 pid = params.read_u16();

        if (request && isServer())
        {
            Sync(this, pid);
        }
        else if (!request && isClient())
        {
            u16[] attached_players;
            
            u8 attached_count = params.read_u8();
            for (u8 i = 0; i < attached_count; i++)
            {
                u16 netid = params.read_u16();
                attached_players.push_back(netid);
            }
            
            this.set("attached_players", @attached_players);
        }
    }
    else if (cmd == this.getCommandID("attach_player"))
    {
        if (!isServer()) return;

        u16 netid = params.read_u16();
        u16[]@ attached_players;
        this.get("attached_players", @attached_players);

        if (attached_players.find(netid) == -1)
            attached_players.push_back(netid);

        Sync(this);
    }
    else if (cmd == this.getCommandID("detach_player"))
    {
        if (!isServer()) return;

        u16 netid = params.read_u16();
        u16[]@ attached_players;
        this.get("attached_players", @attached_players);

        int index = attached_players.find(netid);
        if (index != -1)
            attached_players.removeAt(index);

        Sync(this);
    }
}

void Sync(CBlob@ this, u16 pid = 0)
{
	if (!isServer()) return;

	CBitStream params;
	params.write_bool(false);
	params.write_u16(0);

    u16[]@ attached_players;
    this.get("attached_players", @attached_players);

    params.write_u8(attached_players.length);
    for (u8 i = 0; i < attached_players.length; i++)
    {
        params.write_u16(attached_players[i]);
    }

	if (pid != 0)
	{
		CPlayer@ p = getPlayerByNetworkId(pid);
		if (p !is null)
			this.server_SendCommandToPlayer(this.getCommandID("sync_menu"), params, p);
	}

	if (pid == 0)
		this.SendCommand(this.getCommandID("sync_menu"), params);
}

void RequestSync(CBlob@ this)
{
	if (!isClient() || getLocalPlayer() is null) return;

	CBitStream params;
	params.write_bool(true);
	params.write_u16(getLocalPlayer().getNetworkID());
	this.SendCommand(this.getCommandID("sync_menu"), params);
}