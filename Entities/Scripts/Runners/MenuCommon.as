#include "Slider.as"
#include "CheckBox.as"
#include "ToolTipUtils.as"
#include "HoverUtils.as"
#include "OptionsUtils.as"

class MenuItemInfo
{
    string text;
    string description;

    Vec2f pos;
    Vec2f dim;

    Vec2f list_pos;
    Vec2f list_dim;

    Vec2f sidebar_pos;
    Sidebar sidebar;
    Vec2f mpos;

    MenuItemInfo(string _text, string _description, Vec2f _pos = Vec2f_zero,
        Vec2f _dim = Vec2f_zero, Vec2f _list_pos = Vec2f_zero, Vec2f _list_dim = Vec2f_zero)
    {
        text = _text;
        description = _description;

        pos = _pos;
        dim = _dim;

        list_pos = _list_pos;
        list_dim = _list_dim;
        
        mpos = Vec2f(-1, -1);
        makeSidebar();
    }

    void makeSidebar()
    {
        sidebar_pos = list_pos + Vec2f(list_dim.x, 0);
        sidebar = Sidebar(sidebar_pos);

        sidebar.addSlider("Slider", "Slider tooltip", Vec2f(32, 20), Vec2f(8, 8), 0, 0);
        sidebar.addCheckbox("Checkbox", "Checkbox tooltip", Vec2f(16, 16), false);
        sidebar.addCheckbox("Checkbox 1", "Checkbox tooltip 1", Vec2f(32, 24), false);
    }

    void tick()
    {
        sidebar.tick();
    }

    void render(u8 alpha)
    {
        sidebar.render(alpha);
    }
};

const f32 height_slider = 64;
const f32 height_checkbox = 16;

class Sidebar
{
    Vec2f dim;
    Vec2f pos;
    
    Vec2f padding;
    Vec2f mpos;

    Vec2f[] tl_rects_const;
    Vec2f[] br_rects_const;
    
    Vec2f[] tl_rects;
    Vec2f[] br_rects;

    string[] tooltips;
    Vec2f tooltip_padding;
    int[] hovered;

    u8[] order;
    Option[] options;

    bool require_tick_update;

    Sidebar(Vec2f _pos)
    {
        pos = _pos;

        padding = Vec2f(8,8);
        dim = Vec2f(150, padding.y);

        mpos = Vec2f(-1,-1);
        tooltip_padding = Vec2f(6,4);

        order = array<u8>();
        options = array<Option>();
        
        require_tick_update = true;
    }

    void tick()
    {
        for (uint i = 0; i < options.length; i++)
        {
            options[i].tick();
        }

        bool item_hover = mpos.x >= pos.x && mpos.x <= pos.x + dim.x
            && mpos.y >= pos.y && mpos.y <= pos.y + dim.y;

        bool do_tick = require_tick_update || item_hover;
        if (!do_tick) return;

        if (item_hover) require_tick_update = true;
        else require_tick_update = false;

        hovered = getHoveredIndexes(mpos, tl_rects, br_rects);
    }

    void render(u8 alpha)
    {
        CControls@ controls = getControls();
        if (controls is null) return;

        mpos = controls.getInterpMouseScreenPos();
        drawRectangle(pos, pos + dim, SColor(alpha, 0, 0, 0), 1, 2, SColor(alpha, 75, 75, 75));

        // render options in order they added
        if (options.size() != order.size())
        {
            if (getGameTime() % 30 == 0) print("Sidebar: render() - options count doesn't match titles count");
            return;
        }

        Vec2f current_pos = pos + padding;
        for (uint i = 0; i < order.size(); i++)
        {
            options[i].setPosition(current_pos);
            options[i].render(alpha);
            current_pos += Vec2f(0, options[i].dim.y + padding.y);
        }

        if (hovered.size() > 0)
        {
            renderToolTip(alpha, tooltips[hovered[0]]);
        }
    }

    bool addSlider(string _title, string _tooltip, Vec2f _button_dim = Vec2f(16, 16), Vec2f _capture_margin = Vec2f_zero, f32 _start_pos = 0, u8 _snap_points = 0)
    {
        dim.y += height_slider + padding.y;
        Option option = Option(_title, pos, Vec2f(dim.x - padding.x * 2, height_slider), true, false);
        option.parent_dim = dim;
        option.hover_tooltip = _tooltip;
        option.slider = Slider(_title, pos + Vec2f(padding.x, 0), Vec2f(dim.x - padding.x * 2, _button_dim.y), _button_dim, _capture_margin, _start_pos, _snap_points);
        options.push_back(option);

        order.push_back(0);
        if (_tooltip != "") addTooltip(_tooltip, pos, pos + Vec2f(dim.x, height_slider));

        return true;
    }

    bool addCheckbox(string _title, string _tooltip, Vec2f _dim = Vec2f(16, 16), bool _state = false)
    {
        dim.y += _dim.y + padding.y;
        Option option = Option(_title, pos, Vec2f(dim.x - padding.x * 2, _dim.y), false, true);
        option.parent_dim = dim;
        option.hover_tooltip = _tooltip;
        option.check = CheckBox(_state, pos + Vec2f(0, 0), _dim);
        options.push_back(option);

        order.push_back(1);
        if (_tooltip != "") addTooltip(_tooltip, pos, pos + Vec2f(dim.x, height_checkbox));

        return true;
    }

    void renderToolTip(u8 alpha, string tooltip)
    {
        Vec2f tooltip_dim = getToolTipDim(tooltip);
        Vec2f tooltip_pos = mpos + Vec2f(16, 16);
        tooltip_pos = mpos + Vec2f(24, 24);

        drawRectangle(tooltip_pos, tooltip_pos + tooltip_dim, SColor(alpha, 0, 0, 0), 1, 2, SColor(alpha, 75, 75, 75));
        GUI::DrawText(tooltip, tooltip_pos + tooltip_padding - Vec2f(1,0), SColor(alpha, 255, 255, 255));
    }

    Vec2f getToolTipDim(string tooltip)
    {
        Vec2f text_dim;
        GUI::GetTextDimensions(tooltip, text_dim);
        return text_dim + tooltip_padding * 2;
    }

    void addTooltip(string tooltip, Vec2f _tl, Vec2f _br, bool const_rect = false)
    {
        //print(_tl+" "+_br+" "+tooltip);
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
        for (u8 i = 0; i < options.length; i++)
        {
            Option option = options[i];
            if (option.has_slider)
            {
                addTooltip(option.hover_tooltip, option.pos, option.pos + option.dim);
            }
            if (option.has_check)
            {
                addTooltip(option.hover_tooltip, option.pos, option.pos + option.dim);
            }
        }
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