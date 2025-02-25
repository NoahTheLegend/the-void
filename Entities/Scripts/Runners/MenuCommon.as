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

        sidebar.addSlider("Slider", "Slider tooltip", Vec2f(32, 20), Vec2f(8, 8), 0, 0);
        sidebar.addCheckbox("Checkbox", "Checkbox tooltip", Vec2f(16, 16), false);
        sidebar.addCheckbox("Checkbox 1", "Checkbox tooltip 1", Vec2f(16, 16), false);
    }

    void tick()
    {
        sidebar.tick();
        
        CControls@ controls = getControls();
        if (controls is null) return;

        mpos = controls.getInterpMouseScreenPos();
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
        for (u8 i = 0; i < sidebar.options.length; i++)
        {
            Option option = sidebar.options[i];
            if (option.has_slider)
            {
                addTooltip(option.hover_tooltip, option.slider.pos, option.slider.pos + option.slider.dim);
            }
            else
            {
                addTooltip(option.hover_tooltip, option.check.pos, option.check.pos + option.check.dim);
            }
        }
    }
};

class Sidebar
{
    Vec2f dim;
    Vec2f pos;
    
    Vec2f padding;
    Vec2f mpos;

    u8[] order;
    Option[] options;

    Sidebar(Vec2f _pos, Vec2f _dim)
    {
        pos = _pos;
        dim = _dim;

        padding = Vec2f(8,8);
        mpos = Vec2f(-1,-1);

        order = array<u8>();
        options = array<Option>();
    }

    void tick()
    {
        CControls@ controls = getControls();
        if (controls is null) return;
        mpos = controls.getInterpMouseScreenPos();
    
        for (uint i = 0; i < options.length; i++)
        {
            options[i].tick();
        }
    }

    void render(u8 alpha)
    {
        drawRectangle(pos, pos + dim, SColor(alpha, 0, 0, 0), 1, 2, SColor(alpha, 75, 75, 75));

        // render options in order they added
        if (options.size() != order.size())
        {
            if (getGameTime() % 30 == 0) print("Sidebar: render() - options count doesn't match titles count");
            return;
        }

        for (uint i = 0; i < order.size(); i++)
        {
            Vec2f current_pos = pos + padding + Vec2f(0, 0 * i);
            options[i].setPosition(current_pos);
            options[i].render(alpha);
        }
    }

    bool addSlider(string _title, string _tooltip, Vec2f _button_dim = Vec2f(16, 16), Vec2f _capture_margin = Vec2f_zero, f32 _start_pos = 0, u8 _snap_points = 0)
    {
        Option option = Option(_title, pos, true, false);
        option.parent_dim = dim;
        option.hover_tooltip = _tooltip;
        option.slider = Slider(_title, pos + Vec2f(padding.x, 0), Vec2f(dim.x - padding.x * 2, _button_dim.y), _button_dim, _capture_margin, _start_pos, _snap_points);
        options.push_back(option);

        order.push_back(0);
        return true;
    }

    bool addCheckbox(string _title, string _tooltip, Vec2f _dim = Vec2f(16, 16), bool _state = false)
    {
        Option option = Option(_title, pos, false, true);
        option.parent_dim = dim;
        option.hover_tooltip = _tooltip;
        option.check = CheckBox(_state, pos + Vec2f(0, 0), _dim);
        options.push_back(option);

        order.push_back(1);
        return true;
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