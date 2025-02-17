#include "UtilityChecks.as"
#include "ToolTipUtils.as"

void onInit(CBlob@ this)
{
    this.addCommandID("sync_menu");
    this.addCommandID("move_at");
    this.addCommandID("attach_player");
    this.addCommandID("detach_player");
    
    resetAttached(this);
    this.set_bool("draw_attached_players", false);

	RequestSync(this);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if (caller is null) return;

    CPlayer@ player = caller.getPlayer();
    if (player is null) return;

    if (caller.getDistanceTo(this) > 40.0f) return;
    if (isInMenu(caller)) return;

    if (caller.getTeamNum() == this.getTeamNum())
    {
        CBitStream params;
        params.write_u16(player.getNetworkID());

        CButton@ button = caller.CreateGenericButton(11, Vec2f(0, 0), this, this.getCommandID("attach_player"), "Menu", params);
    }
}

const u8 max_name_length = 12;
const u8 charname_height = 30;
const f32 attached_rect_width = 100;

bool render = false;
const Vec2f menu_dim = Vec2f(300, 200);

void onRender(CSprite@ this)
{
    //if (!render) return;

    CBlob@ blob = this.getBlob();
    if (blob is null) return;

    CBlob@ local = getLocalPlayerBlob();
    if (local is null) return;

    CPlayer@ player = local.getPlayer();
    if (player is null) return;

    u8 alpha = 255 * fold;
    // debug
    if (getControls().isKeyPressed(KEY_KEY_R))
    {
        GUI::DrawText("Local id: "+local.get_u16("menu_id"), Vec2f(50, 10), SColor(alpha,255,255,5));
        GUI::DrawText("Blob id: "+blob.getNetworkID(), Vec2f(50, 30), SColor(alpha,255,255,5));

        u16[]@ attached_players;
        blob.get("attached_players", @attached_players);

        GUI::DrawText("Attached players: " + attached_players.length, Vec2f(150, 10), SColor(alpha,255,255,5));
        for (u8 i = 0; i < attached_players.length; i++)
        {
            CPlayer@ p = getPlayerByNetworkId(attached_players[i]);
            if (p is null) continue;

            CBlob@ b = p.getBlob();
            if (b is null) continue;

            GUI::DrawText(p.getCharacterName(), Vec2f(50, 50 + i * 20), SColor(alpha,255,255,5));
        }
    }

    bool draw_attached = blob.get_bool("draw_attached_players");

    Vec2f screen_center = getDriver().getScreenCenterPos();
    Vec2f menu_dim = blob.exists("menu_dim") ? blob.get_Vec2f("menu_dim") : Vec2f(300, 200);
    Vec2f menu_pos = screen_center - menu_dim / 2;

    GUI::SetFont("menu");
    if (draw_attached)
    {
        u16[]@ attached_players;
        blob.get("attached_players", @attached_players);
    
        u8 attached_len = attached_players.length;
        Vec2f attached_dim = Vec2f(attached_rect_width, attached_len * charname_height);
        Vec2f attached_renderpos = menu_pos - Vec2f(attached_rect_width, 0);

        drawRectangle(attached_renderpos, attached_renderpos + attached_dim, SColor(alpha,0,0,0), 1, 2, SColor(alpha,75,75,75));

        for (u8 i = 0; i < attached_len; i++)
        {
            CPlayer@ p = getPlayerByNetworkId(attached_players[i]);
            if (p is null) continue;

            CBlob@ b = p.getBlob();
            if (b is null) continue;

            string character_name = p.getCharacterName();
            // if character_name size is more than max_name_length symbols, truncate and add 3 dots
            if (character_name.size() > max_name_length)
                character_name = character_name.substr(0, max_name_length) + "...";
            
            GUI::DrawTextCentered(character_name, attached_renderpos + Vec2f(attached_rect_width / 2 - 2, i * charname_height + charname_height / 2), SColor(alpha,255,255,255));
        }
    }
}

void resetAttached(CBlob@ this)
{
    u16[] attached_players;
    this.set("attached_players", attached_players);
}

f32 fold = 0.0f;

void onTick(CBlob@ this)
{
    if (isServer() && getGameTime() % 150 == 0)
    {
        // clear nonexisting players
        u16[]@ attached_players;
        this.get("attached_players", @attached_players);

        for (u8 i = 0; i < attached_players.length; i++)
        {
            CPlayer@ p = getPlayerByNetworkId(attached_players[i]);
            if (p is null)
            {
                attached_players.removeAt(i);
                i--;
            }
        }
    }

    if (!isClient()) return;

    CBlob@ local = getLocalPlayerBlob();
    if (local is null) return;

    CPlayer@ player = local.getPlayer();
    if (player is null) return;

    u16 this_netid = this.getNetworkID();
    u16 netid = player.getNetworkID();
    u16 local_menu_runner = local.get_u16("menu_id");

    bool found = local_menu_runner == this_netid;
    render = found;
    fold = render ? Maths::Lerp(fold, 1.0f, 0.25f) : 0;
    this.set_bool("draw_attached_players", found);

    if (found)
    {
        bool left = local.isKeyPressed(key_left);
        bool right = local.isKeyPressed(key_right);
        bool up = local.isKeyPressed(key_up);
        bool down = local.isKeyPressed(key_down);

        if (left || right || up || down)
        {
            CBitStream params;
            params.write_u16(netid);
            params.write_bool(left);
            params.write_bool(right);
            params.write_bool(up);
            params.write_bool(down);
            this.SendCommand(this.getCommandID("move_at"), params);
        }
    }
    
    if (!found || local.isKeyJustPressed(key_pickup))
    {
        CBitStream params;
        params.write_u16(netid);
        this.SendCommand(this.getCommandID("detach_player"), params);
    }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("move_at"))
    {
        u16 netid = params.read_u16();
        CPlayer@ player = getPlayerByNetworkId(netid);
        if (player is null) return;

        CBlob@ caller = player.getBlob();
        if (caller is null) return;

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
                if (attached_players !is null)
                {
                    attached_players.push_back(netid);
                }
            }
            
            this.set("attached_players", attached_players);
        }
    }
    else if (cmd == this.getCommandID("attach_player"))
    {
        u16 netid = params.read_u16();

        if (isClient())
        {
            CPlayer@ player = getPlayerByNetworkId(netid);
            if (player !is null)
            {
                CBlob@ caller = player.getBlob();
                if (caller !is null && caller.isMyPlayer())
                    attachMenu(caller, this);
            }
        }
            
        if (!isServer()) return;

        u16[]@ attached_players;
        if (!this.get("attached_players", @attached_players))
        {
            resetAttached(this);
        }
        if (this.get("attached_players", @attached_players))
        {
            if (attached_players.find(netid) == -1)
                attached_players.push_back(netid);
        }
    
        Sync(this);
    }
    else if (cmd == this.getCommandID("detach_player"))
    {
        u16 netid = params.read_u16();

        if (isClient())
        {
            CPlayer@ player = getPlayerByNetworkId(netid);
            if (player !is null)
            {
                CBlob@ caller = player.getBlob();
                if (caller !is null && caller.isMyPlayer())
                    resetMenu(caller);
            }
        }

        if (!isServer()) return;

        u16[]@ attached_players;
        if (!this.get("attached_players", @attached_players))
        {
            resetAttached(this);
        }
        if (this.get("attached_players", @attached_players))
        {
            int index = attached_players.find(netid);
            if (index != -1)
                attached_players.removeAt(index);
        }

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