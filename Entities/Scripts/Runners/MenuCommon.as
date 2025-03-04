#include "Slider.as"
#include "CheckBox.as"
#include "RadioButton.as"
#include "ToolTipUtils.as"
#include "HoverUtils.as"
#include "OptionsUtils.as"
#include "MenuConsts.as"

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

        sidebar.addSlider("Slider", "Slider tooltip", Vec2f(32,20), Vec2f(8, 8), 0, 5);
        sidebar.options[0].setSliderTextMode(1);

        sidebar.addCheckbox("Checkbox", "Checkbox tooltip", Vec2f(16, 16), false);
        sidebar.addCheckbox("Checkbox 1", "Checkbox tooltip 1", Vec2f(32, 24), false);
        
        sidebar.addRadioList("Radio List", "Radio List tooltip", Vec2f(4, 1), Vec2f(32,32));
        sidebar.addRadioListButton("Radio List", "Radio 1", "Radio 1 description", "InteractionIcons.png", Vec2f(32,32), 0, 1);
        sidebar.addRadioListButton("Radio List", "Radio 2", "Radio 2 description", "InteractionIcons.png", Vec2f(32,32), 1, 1);

        sidebar.update();
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

    u8 tooltip_alpha;
    u8 tooltip_hold_time;
    u8 current_hold_time;

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

        tooltip_alpha = 0;
        tooltip_hold_time = TOOLTIP_HOLD_TIME;
        current_hold_time = 0;

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

        bool item_hover = isMouseInScreenBox(mpos, pos, pos + dim);

        bool do_tick = require_tick_update || item_hover;
        if (!do_tick) return;

        if (item_hover) require_tick_update = true;
        else require_tick_update = false;

        hovered = getHoveredIndexes(mpos, tl_rects, br_rects);
        if (hovered.size() > 0)
        {
            current_hold_time++;
            if (current_hold_time >= tooltip_hold_time)
            {
                tooltip_alpha = Maths::Lerp(tooltip_alpha, 255, 0.25f);
                current_hold_time = tooltip_hold_time;
            }
        }
        else
        {
            current_hold_time = 0;
            tooltip_alpha = 0;
        }
    }

    void render(u8 alpha)
    {
        CControls@ controls = getControls();
        if (controls is null) return;

        Vec2f new_mpos = controls.getInterpMouseScreenPos();
        if (new_mpos != mpos)
        {
            current_hold_time = 0;
            tooltip_alpha = 0;
        }
        mpos = new_mpos;
        drawRectangle(pos, pos + dim, SColor(alpha, 0, 0, 0), 1, 2, SColor(alpha, 75, 75, 75));

        // render options in order they added
        if (options.size() != order.size())
        {
            if (getGameTime() % 30 == 0) print("Sidebar: render() - options count doesn't match titles count");
            return;
        }

        bool request_update = false;
        Vec2f current_pos = pos + padding;
        for (uint i = 0; i < order.size(); i++)
        {
            if (options[i].pos != current_pos)
                request_update = true;

            options[i].setPosition(current_pos);
            options[i].render(alpha);

            current_pos += Vec2f(0, options[i].dim.y + padding.y);
        }

        if (request_update) update();
        if (hovered.size() > 0) renderToolTip(Maths::Min(alpha, tooltip_alpha), tooltips[hovered[hovered.size() - 1]]);
    }

    bool addSlider(string _title, string _tooltip, Vec2f _button_dim = Vec2f(16, 16), Vec2f _capture_margin = Vec2f_zero, f32 _start_pos = 0, u8 _snap_points = 0)
    {
        dim.y += _button_dim.y + padding.y + height_text * 2;
        Option option = Option(_title, pos, Vec2f(dim.x - padding.x * 2, height_text * 2 + _button_dim.y), true);
        option.parent_dim = dim;
        option.hover_tooltip = _tooltip;
        option.slider = Slider(_title, pos + Vec2f(padding.x, 0), Vec2f(dim.x - padding.x * 2, _button_dim.y), _button_dim, _capture_margin, _start_pos, _snap_points);
        options.push_back(option);

        order.push_back(0);
        if (_tooltip != "") addTooltip(_tooltip, pos, pos + Vec2f(dim.x, _button_dim.y));

        return true;
    }

    bool addCheckbox(string _title, string _tooltip, Vec2f _dim = Vec2f(16, 16), bool _state = false)
    {
        dim.y += _dim.y + padding.y;
        Option option = Option(_title, pos, Vec2f(dim.x - padding.x * 2, _dim.y), false, true);
        option.parent_dim = dim;
        option.hover_tooltip = _tooltip;
        option.check = CheckBox(_state, pos, _dim);
        options.push_back(option);

        order.push_back(1);
        if (_tooltip != "") addTooltip(_tooltip, pos, pos + Vec2f(dim.x, height_checkbox));

        return true;
    }

    bool addRadioList(string _title, string _tooltip, Vec2f _grid = Vec2f(1, 1), Vec2f _item_dim = Vec2f(16, 16))
    {
        f32 height = _item_dim.y * _grid.y + height_radio_button_list;
        dim.y += height + padding.y;
        
        Vec2f radio_dim = Vec2f(dim.x - padding.x * 2, height);
        Option option = Option(_title, pos, radio_dim, false, false, true);
        option.parent_dim = dim;
        option.hover_tooltip = _tooltip;
        option.radio_button_list = RadioButtonList(_title, pos + height_radio_button_list, radio_dim, _grid, _item_dim);
        options.push_back(option);

        order.push_back(2);
        if (_tooltip != "") addTooltip(_tooltip, pos, pos + Vec2f(dim.x, height_radio_button_list));

        return true;
    }
    
    bool addRadioListButton(string radio_list_title, string _title, string _description, string _icon, Vec2f _icon_dim, u8 _index = 0, f32 _scale = 1)
    {
        for (uint i = 0; i < options.size(); i++)
        {
            if (options[i].default_text == radio_list_title)
            {
                options[i].radio_button_list.addRadioButton(makeRadioButton(_title, _description, _icon, _icon_dim, _index, _scale));
                if (_description != "") addTooltip(_description, pos, pos + Vec2f(dim.x, height_radio_button_list));
                return true;
            }
        }
        return false;
    }

    void renderToolTip(u8 alpha, string tooltip)
    {
        if (tooltip_alpha == 0) return;
        
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
            if (option.has_radio_button_list)
            {
                addTooltip(option.hover_tooltip, option.pos, option.pos + option.dim);

                for (uint j = 0; j < option.radio_button_list.buttons.length; j++)
                {
                    RadioButton radio_button = option.radio_button_list.buttons[j];
                    if (radio_button.description != "")
                        addTooltip(radio_button.description, radio_button.pos, radio_button.pos + radio_button.dim);
                }
            }
        }
    }
};

int[] getHoveredIndexes(Vec2f mpos, Vec2f[] &in tl_rects, Vec2f[] &in br_rects)
{
    int[] hovered;

    for (uint i = 0; i < tl_rects.length; i++)
    {
        if (isMouseInScreenBox(mpos, tl_rects[i], br_rects[i]))
        {
            hovered.push_back(i);
        }
    }

    return hovered;
}