#include "Slider.as"
#include "CheckBox.as"
#include "ToolTipUtils.as"
#include "HoverUtils.as"

class MenuItemInfo
{
    string text;
    string description;

    Vec2f pos;
    Vec2f dim;

    Vec2f list_pos;
    Vec2f list_dim;

    Vec2f sidebar_pos;
    Vec2f sidebar_dim;
    Sidebar sidebar;

    Vec2f[] tl_rects_const;
    Vec2f[] br_rects_const;
    
    Vec2f[] tl_rects;
    Vec2f[] br_rects;

    string[] tooltips;
    int[] hovered;

    bool require_tick_update;
    Vec2f mpos;

    Vec2f tooltip_padding;

    MenuItemInfo(string _text, string _description, Vec2f _sidebar_dim = Vec2f_zero,
        Vec2f _pos = Vec2f_zero, Vec2f _dim = Vec2f_zero, Vec2f _list_pos = Vec2f_zero, Vec2f _list_dim = Vec2f_zero)
    {
        text = _text;
        description = _description;

        pos = _pos;
        dim = _dim;

        list_pos = _list_pos;
        list_dim = _list_dim;
        
        require_tick_update = false;
        mpos = Vec2f(-1, -1);

        tooltip_padding = Vec2f(4,4);
        
        makeSidebar();
        update();
    }

    void makeSidebar()
    {
        sidebar_pos = list_pos + Vec2f(list_dim.x, 0);
        sidebar = Sidebar(sidebar_pos, sidebar_dim);

        sidebar.addSlider("Slider", "Slider tooltip", Vec2f(16, 16), Vec2f(0, 0), 0, 0);
        sidebar.addCheckbox("Checkbox", "Checkbox tooltip", Vec2f(16, 16), false);
    }

    void tick()
    {
        CControls@ controls = getControls();
        if (controls is null) return;

        mpos = controls.getInterpMouseScreenPos();
        bool item_hover = mpos.x >= pos.x && mpos.x <= pos.x + dim.x
            && mpos.y >= pos.y && mpos.y <= pos.y + dim.y;

        bool do_tick = require_tick_update || item_hover;
        if (!do_tick) return;

        if (item_hover) require_tick_update = true;
        else require_tick_update = false;

        sidebar.tick();
        hovered = getHoveredIndexes(mpos, tl_rects, br_rects);
    }

    void render(u8 alpha)
    {
        sidebar.render(alpha);

        for (uint i = 0; i < tooltips.length; i++)
        {
            if (hovered.find(i) != -1)
            {
                renderToolTip(alpha, tooltips[i]);
            }
        }
    }

    void renderToolTip(u8 alpha, string tooltip)
    {
        Vec2f tooltip_dim = getToolTipDim(tooltip);
        Vec2f tooltip_pos = mpos + Vec2f(16, 16);

        if (tooltip_pos.x + tooltip_dim.x > getScreenWidth())
        {
            tooltip_pos.x = mpos.x - tooltip_dim.x - 16;
        }

        if (tooltip_pos.y + tooltip_dim.y > getScreenHeight())
        {
            tooltip_pos.y = mpos.y - tooltip_dim.y - 16;
        }

        drawRectangle(tooltip_pos, tooltip_pos + tooltip_dim, SColor(alpha, 0, 0, 0), 1, 2, SColor(alpha, 75, 75, 75));
        GUI::DrawText(tooltip, tooltip_pos + tooltip_padding, SColor(alpha, 255, 255, 255));
    }

    Vec2f getToolTipDim(string tooltip)
    {
        Vec2f text_dim;
        GUI::GetTextDimensions(tooltip, text_dim);
        return text_dim + tooltip_padding;
    }

    void addTooltip(string tooltip, Vec2f _tl, Vec2f _br, bool const_rect = false)
    {
        tooltips.push_back(tooltip);
        
        if (const_rect)
        {
            tl_rects_const.push_back(_tl);
            br_rects_const.push_back(_br);
        }
        else
        {
            tl_rects.push_back(_tl);
            br_rects.push_back(_br);
        }
    }

    void update()
    {
        tooltips = array<string>();
        tl_rects = tl_rects_const;
        br_rects = br_rects_const;

        // sidebar rects
        for (u8 i = 0; i < sidebar.sliders.length; i++)
        {
            addTooltip(sidebar.sliders[i].hover_tooltip, sidebar.sliders[i].pos, sidebar.sliders[i].pos + sidebar.sliders[i].dim);
        }

        for (u8 i = 0; i < sidebar.checkboxes.length; i++)
        {
            addTooltip(sidebar.checkboxes[i].hover_tooltip, sidebar.checkboxes[i].pos, sidebar.checkboxes[i].pos + sidebar.checkboxes[i].dim);
        }
    }
};

class Sidebar
{
    Vec2f dim;
    Vec2f pos;

    f32 gap;
    Vec2f mpos;

    u8[] order;
    MenuItemSlider[] sliders;
    MenuItemCheckbox[] checkboxes;

    Sidebar(Vec2f _pos, Vec2f _dim)
    {
        pos = _pos;
        dim = _dim;

        gap = 24.0f;
        mpos = Vec2f(-1,-1);

        order = array<u8>();
    }

    bool addSlider(string _title, string _tooltip, Vec2f _button_dim = Vec2f(16, 16), Vec2f _capture_margin = Vec2f_zero, f32 _start_pos = 0, u8 _snap_points = 0)
    {
        sliders.push_back(MenuItemSlider(_title, _tooltip, pos, dim, _button_dim, _capture_margin, _start_pos, _snap_points));

        order.push_back(0);
        return true;
    }

    bool addCheckbox(string _title, string _tooltip, Vec2f _dim = Vec2f(16, 16), bool _state = false)
    {
        checkboxes.push_back(MenuItemCheckbox(_title, _tooltip, pos, _dim, _state));

        order.push_back(1);
        return true;
    }

    void tick()
    {
        CControls@ controls = getControls();
        if (controls is null) return;
        mpos = controls.getInterpMouseScreenPos();
        
        for (uint i = 0; i < sliders.length; i++)
        {
            sliders[i].tick();
        }

        for (uint i = 0; i < checkboxes.length; i++)
        {
            checkboxes[i].tick();
        }
    }

    void render(u8 alpha)
    {
        drawRectangle(pos, pos + dim, SColor(alpha, 0, 0, 0), 1, 2, SColor(alpha, 75, 75, 75));

        // render sliders and checkboxes in order they added
        if (sliders.size() + checkboxes.size() != order.size())
        {
            if (getGameTime() % 30 == 0) print("Sidebar: render() - sliders and checkboxes count doesn't match titles count");
            return;
        }

        uint sliderIndex = 0;
        uint checkboxIndex = 0;
        for (uint i = 0; i < order.size(); i++)
        {
            Vec2f current_pos = pos + Vec2f(0, i * gap);
            if (order[i] == 0)
            {
                sliders[sliderIndex].pos = current_pos;
                sliders[sliderIndex].render(alpha);
                sliderIndex++;
            }
            else if (order[i] == 1)
            {
                checkboxes[checkboxIndex].pos = current_pos;
                checkboxes[checkboxIndex].render(alpha);
                checkboxIndex++;
            }
        }
    }
};

class MenuItemSlider : Slider
{
    bool rect_hover;
    string hover_tooltip;

    Vec2f mpos;

    MenuItemSlider(string _name = "", string _hover_tooltip = "", Vec2f _pos = Vec2f_zero, Vec2f _dim = Vec2f_zero, Vec2f _button_dim = Vec2f_zero, Vec2f _capture_margin = Vec2f_zero, f32 _start_pos = 0, u8 _snap_points = 0)
    {
        super(_name, _pos, _dim, _button_dim, _capture_margin, _start_pos, _snap_points);

        rect_hover = false;
        hover_tooltip = _hover_tooltip;

        mpos = Vec2f(-1, -1);
    }

    void tick()
    {
        CControls@ controls = getControls();
        if (controls is null) return;

        mpos = controls.getInterpMouseScreenPos();
        if (rect_hover)
        {
            if (controls.isKeyPressed(KEY_LBUTTON) || controls.isKeyPressed(KEY_RBUTTON))
            {
                requestUpdate(mpos, button_pos);
                captured = true;
                button_pos = mpos - (dim.x >= dim.y ? Vec2f(9, 0) : Vec2f(0, 8));
            }
            else
            {
                captured = false;
            }
        }

        Vec2f snap_point = button_pos;
        if (snap_points > 0)
        {
            snap_point = getNearestSnapPoint();
        }

        button_pos = clampPos(snap_point);
        scrolled = Maths::Round((tl - button_pos).Length() / (dim.x > dim.y ? (dim.x - button_dim.x) : (dim.y - button_dim.y)) * 100.0f) / 100.0f;
    }

    void render(u8 alpha) override
    {
        GUI::SetFont("score-smaller");
        u8 style = 0;

        Vec2f snap_point = button_pos;
        if (snap_points > 0)
        {
            snap_point = getNearestSnapPoint();
        }

        Vec2f snap = getSnap();
        Vec2f aligned_dim = Vec2f(dim.x - button_dim.x, dim.y - button_dim.y);
        button_pos = clampPos(snap_point);

        Vec2f drawpos = button_pos + (dim.y > dim.x ? Vec2f(-aligned_dim.x / 2, 0) : Vec2f(0, -aligned_dim.y / 2));

        scrolled = Maths::Round((tl - button_pos).Length() / (dim.x > dim.y ? aligned_dim.x : aligned_dim.y) * 100.0f) / 100.0f;
        // track
        GUI::DrawFramedPane(tl, br);
        // button
        GUI::DrawSunkenPane(drawpos, drawpos + button_dim);
    }
};

class MenuItemCheckbox : CheckBox
{
    string name;
    bool rect_hover;
    string hover_tooltip;

    MenuItemCheckbox(string _name = "", string _hover_tooltip = "", Vec2f _pos = Vec2f_zero, Vec2f _dim = Vec2f_zero, bool _state = false)
    {
        super(_state, _pos, _dim);
        
        name = _name;
        rect_hover = false;
        hover_tooltip = _hover_tooltip;
    }
};

int[] getHoveredIndexes(Vec2f aimpos, Vec2f[] &in tl_rects, Vec2f[] &in br_rects)
{
    int[] hovered;

    for (uint i = 0; i < tl_rects.length; i++)
    {
        if (aimpos.x >= tl_rects[i].x && aimpos.x <= br_rects[i].x
            && aimpos.y >= tl_rects[i].y && aimpos.y <= br_rects[i].y)
        {
            hovered.push_back(i);
        }
    }

    return hovered;
}