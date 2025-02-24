#include "UtilityChecks.as"
#include "ToolTipUtils.as"
#include "MenuUtils.as"
#include "MenuCommon.as"

void onInit(CBlob@ this)
{
    this.addCommandID("sync_menu");
    this.addCommandID("move_at");
    this.addCommandID("attach_player");
    this.addCommandID("detach_player");
    
    resetAttached(this);

    this.set_bool("render", false);
    this.set_f32("fold", 0);

    this.set_s32("selected_item", 0);
    this.set_bool("draw_attached_players", false);

	RequestSync(this);
    initMenu(this);
}

void initMenu(CBlob@ this)
{
    AddMenuItem(this, "Test 0", "test descritpion amogus 0");
    AddMenuItem(this, "Test 1", "test descritpion amogus 1");
    AddMenuItem(this, "Test 2", "test descritpion amogus 2");
    AddMenuItem(this, "Test 3", "test descritpion amogus 3");
    AddMenuItem(this, "Test 4", "test descritpion amogus 4");
    AddMenuItem(this, "Test 5", "test descritpion amogus 5");
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

const f32 tilesize = 64;
const Vec2f base_menu_grid = Vec2f(4, 2);
const Vec2f sidebar_dim = Vec2f(150, 200);

void onRender(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    if (blob is null) return;

    bool render = blob.get_bool("render");
    f32 fold = render ? Maths::Lerp(blob.get_f32("fold"), 1.0f, 0.5f) : 0;
    blob.set_f32("fold", fold);
    //if (!render) return;
    
    CBlob@ local = getLocalPlayerBlob();
    if (local is null) return;

    CPlayer@ player = local.getPlayer();
    if (player is null) return;

    u8 alpha = 255 * fold;
    s32 selected_item = blob.get_s32("selected_item");

    Vec2f menu_grid = blob.exists("menu_grid") ? blob.get_Vec2f("menu_grid") : base_menu_grid;
    Vec2f menu_dim = menu_grid * tilesize;

    // debug
    if ((sv_test || player.isMod()) && getControls().isKeyPressed(KEY_KEY_R))
    {
        GUI::DrawText("Local id: "+local.get_u16("menu_id"), Vec2f(50, 10), SColor(255,255,255,5));
        GUI::DrawText("Blob id: "+blob.getNetworkID(), Vec2f(50, 30), SColor(255,255,255,5));
        GUI::DrawText("Blob name: "+blob.getName(), Vec2f(50, 50), SColor(255,255,255,5));
        GUI::DrawText("Alpha: "+alpha, Vec2f(50, 70), SColor(255,255,255,5));
        GUI::DrawText("Selected item: "+selected_item, Vec2f(50, 90), SColor(255,255,255,5));

        u16[]@ attached_players;
        blob.get("attached_players", @attached_players);

        GUI::DrawText("Attached players: " + attached_players.length, Vec2f(150, 10), SColor(255,255,255,5));
        for (u8 i = 0; i < attached_players.length; i++)
        {
            CPlayer@ p = getPlayerByNetworkId(attached_players[i]);
            if (p is null) continue;

            CBlob@ b = p.getBlob();
            if (b is null) continue;

            GUI::DrawText(p.getCharacterName(), Vec2f(150, 30 + i * 20), SColor(255,255,255,5));
        }
    }

    bool draw_attached = blob.get_bool("draw_attached_players");

    Vec2f screen_center = getDriver().getScreenCenterPos();
    Vec2f menu_pos = screen_center - menu_dim / 2;

    if (draw_attached)
    {
        u16[]@ attached_players;
        blob.get("attached_players", @attached_players);
    
        u8 attached_len = attached_players.length;
        Vec2f attached_dim = Vec2f(attached_rect_width, attached_len * charname_height);
        Vec2f attached_renderpos = menu_pos - Vec2f(attached_rect_width, 0);
        
        // draw main list
        drawRectangle(menu_pos, menu_pos + Vec2f(menu_dim.x, menu_dim.y * fold), SColor(alpha,0,0,0), 1, 2, SColor(alpha,75,75,75));
        
        // tips below bottom left of main list
        GUI::SetFont("default");
        GUI::DrawText("WASD - move   E - select   C - exit", menu_pos + Vec2f(0, menu_dim.y * fold + 5), SColor(alpha,255,255,255));
        
        GUI::SetFont("menu");
        MenuItemInfo@[]@ menuItems;
        if (blob.get("MenuItems", @menuItems))
        {
            // draw "buttons"
            for (s32 i = 0; i < menuItems.length; i++)
            {
                MenuItemInfo@ item = menuItems[i];
                if (item is null) continue;

                Vec2f item_pos = menu_pos + Vec2f((i % int(menu_grid.x)) * tilesize, (i / int(menu_grid.x)) * tilesize);
                Vec2f item_dim = Vec2f(tilesize, tilesize);
                
                bool update_sidebar = false;
                if (item.pos != item_pos || item.dim != item_dim)
                    update_sidebar = true;

                item.pos = item_pos;
                item.dim = item_dim;
                item.list_pos = menu_pos;
                item.list_dim = menu_dim;
                item.sidebar_dim = sidebar_dim;

                if (update_sidebar)
                {
                    item.makeSidebar();
                }

                if (selected_item == i)
                    drawRectangle(item_pos, item_pos + item_dim, SColor(alpha,0,0,0), 1, 2, SColor(alpha,255,255,255));

                GUI::DrawTextCentered(item.text, item_pos + Vec2f(item_dim.x / 2, item_dim.y / 2), SColor(alpha,255,255,255));
            }
        
            // draw current item on the sidebar to the right from list
            if (selected_item != -1 && selected_item < menuItems.length)
            {
                // draw selected item info

                MenuItemInfo@ item = menuItems[selected_item];
                if (item !is null)
                {
                    item.render(alpha);
                }
            }
        }

        // draw attached
        drawRectangle(attached_renderpos, attached_renderpos + Vec2f(attached_dim.x, attached_dim.y * fold), SColor(alpha,0,0,0), 1, 2, SColor(alpha,75,75,75));

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

int holding_time = 0;
const int max_holding_time = 10;
const int holding_time_step = 3;

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
    this.set_bool("render", found);
    this.set_bool("draw_attached_players", found);

    if (found)
    {
        bool left = local.isKeyJustPressed(key_left);
        bool right = local.isKeyJustPressed(key_right);
        bool up = local.isKeyJustPressed(key_up);
        bool down = local.isKeyJustPressed(key_down);

        bool holding_left = local.isKeyPressed(key_left);
        bool holding_right = local.isKeyPressed(key_right);
        bool holding_up = local.isKeyPressed(key_up);
        bool holding_down = local.isKeyPressed(key_down);

        if (holding_left || holding_right || holding_up || holding_down)
        {
            bool send = holding_time >= max_holding_time && holding_time % holding_time_step == 0;
            if (holding_time >= max_holding_time + holding_time_step)
            {
                holding_time = max_holding_time;
            }

            holding_time++;
            if (send)
            {
                left = holding_left;
                right = holding_right;
                up = holding_up;
                down = holding_down;
            }
        }
        else holding_time = 0;

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
        if (!isServer()) return;
        
        u16 netid = params.read_u16();
        CPlayer@ player = getPlayerByNetworkId(netid);
        if (player is null) return;

        CBlob@ caller = player.getBlob();
        if (caller is null) return;

        bool left = params.read_bool();
        bool right = params.read_bool();
        bool up = params.read_bool();
        bool down = params.read_bool();
        
        // select item of list based on grid and set selected item
        s32 selected_item = this.get_s32("selected_item");
        Vec2f menu_grid = this.exists("menu_grid") ? this.get_Vec2f("menu_grid") : base_menu_grid;

        MenuItemInfo@[]@ menuItems;
        if (!this.get("MenuItems", @menuItems))
        {
            error("MenuItems not found");
            return;
        }
        
        s32 last_item_idx = menuItems.length - 1;
        if (left && !right)
            selected_item = selected_item == 0 ? last_item_idx : selected_item - 1;
        if (right && !left)
            selected_item = selected_item == last_item_idx ? 0 : selected_item + 1;
        if (down && !up)
            selected_item = selected_item >= menuItems.length - menu_grid.x ? selected_item % menu_grid.x : selected_item + menu_grid.x;
        if (up && !down)
            selected_item = selected_item < menu_grid.x ? last_item_idx - (last_item_idx % int(menu_grid.x)) + selected_item : selected_item - menu_grid.x;

        // Ensure selected_item is within valid range
        selected_item = Maths::Clamp(selected_item, 0, last_item_idx);
        
        this.set_s32("selected_item", selected_item);
        this.Sync("selected_item", true);
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
            this.set_s32("selected_item", params.read_s32());

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

        if (attached_players.size() == 0)
            this.set_s32("selected_item", 0);

        Sync(this);
    }
}

void Sync(CBlob@ this, u16 pid = 0)
{
	if (!isServer()) return;

	CBitStream params;
	params.write_bool(false);
	params.write_u16(0);
    params.write_s32(this.get_s32("selected_item"));

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