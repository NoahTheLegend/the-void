#include "Slider.as"
#include "CheckBox.as"
#include "RadioButton.as"
#include "ToolTipUtils.as"
#include "HoverUtils.as"
#include "OptionUtils.as"
#include "MenuConsts.as"
#include "MenuCommands.as"

/*
    System for creating and managing menu items.
    

    MenuItemInfo - contains all necessary information about menu item, mostly for rendering.
    Sidebar - Contains OptionFields of options, submit button and serializer for sending commands.
    OptionField - Wrapper for particular options.
    Option - Contains sliders/checkboxes/radio buttons, one per option.

    Serializes options in order:
    0 - [u16]                   local id
    1 - [u8]                    attached players quantity
    2 - [u16[]]                 attached players
    3 - [u8]                    fields quantity
    4 - [u8]                    field type (e.g. create_blob)                 repeatable
    5 - [u8]                    options quantity                              repeatable
    6 - [u8]                    option type (e.g. slider)                     repeatable
    7 - [s32]                   option enum tag (e.g. slider_quantity)        repeatable
    8 - [f32 / bool / u8]       slider / checkbox / radio button values       repeatable
*/

class MenuItemInfo
{
    u16 blob_id;
    string text;
    string description;

    Vec2f pos;
    Vec2f dim;

    Vec2f list_pos;
    Vec2f list_dim;

    Vec2f sidebar_pos;
    Sidebar sidebar;
    Vec2f mpos;

    MenuItemInfo(u16 _blob_id, string _text, string _description)
    {
        blob_id = _blob_id;
        text = _text;
        description = _description;

        pos = Vec2f_zero;
        dim = Vec2f_zero;
        list_pos = Vec2f_zero;
        list_dim = Vec2f_zero;
        
        mpos = Vec2f(-1, -1);
        makeSidebar();
    }

    void makeSidebar()
    {
        sidebar_pos = list_pos + Vec2f(list_dim.x, 0);
        sidebar = Sidebar(sidebar_pos);

        sidebar.addField("root");

        Option@ test_slider = sidebar.addSlider(0, "Slider", "Slider tooltip", Vec2f(32, 20), Vec2f(8, 8), 0, 5);
        sidebar.fields[0].options[0].setSliderTextMode(1);
        string[] slider_descs = {"yep1", "yep2", "yep3", "yep4", "yep5", "yep6"};
        sidebar.fields[0].options[0].addSliderDescriptions(slider_descs);

        sidebar.addCheckbox(0, "Checkbox", "Checkbox tooltip", Vec2f(24, 24), false);
        
        Option@ list = sidebar.addRadioList(0, "Radio List", "Radio List tooltip", Vec2f(4, 1), Vec2f(32, 32));
        sidebar.addRadioListButton(0, "Radio List", "Radio 1", "Radio 1 description", "InteractionIcons.png", Vec2f(32, 32), 0, 1);
        sidebar.addRadioListButton(0, "Radio List", "Radio 2", "Radio 2 description", "InteractionIcons.png", Vec2f(32, 32), 1, 1);
        sidebar.addRadioListButton(0, "Radio List", "Radio 3", "Radio 3 description", "InteractionIcons.png", Vec2f(32, 32), 2, 1);
        sidebar.addRadioListButton(0, "Radio List", "Radio 4", "Radio 4 description", "InteractionIcons.png", Vec2f(32, 32), 3, 1);

        sidebar.addSubmit(blob_id, "Submit", "Send tooltip", Vec2f(64, 32), "test_cmd");
        sidebar.addSerializer(blob_id);

        sidebar.updateRects();
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

// wrapper for particular options
class OptionField
{
    OptionField@[] children;
    int tag;

    Option@[] options;

    OptionField()
    {
        options = array<Option@>();

        tag = 0;
    }

    void setEnumTag(int _tag)
    {
        tag = _tag;
    }

    void addOption(Option@ _option)
    {
        options.push_back(@_option);
    }

    void addChild(OptionField@ _child)
    {
        children.push_back(_child);
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

    Button@ submit;
    OptionField@[] fields;
    Serializer@ serializer;
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
        
        require_tick_update = true;
    }

    void tick()
    {
        for (uint i = 0; i < fields.length; i++)
        {
            for (uint j = 0; j < fields[i].options.length; j++)
            {
                fields[i].options[j].tick();
            }
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

        if (submit !is null)
        {
            submit.tick();

            if (submit.send_command)
            {
                submit.send_command = false;
                SerializeCommand();
            }
        }
    }

    bool SerializeCommand()
    {
        if (serializer is null) return false;
        if (submit is null) return false;

        CBlob@ blob = getBlobByNetworkID(submit.blob_id);
        if (blob is null) return false;

        Serialize();
        SendCommand(blob, submit.cmd, serializer);

        return true;
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

        // debug
        //for (u8 i = 0; i < tl_rects.length; i++)
        //{
        //    drawRectangle(tl_rects[i], br_rects[i], SColor(alpha, 0, 0, 0), 1, 2, SColor(alpha, 75, 255, 75));
        //}

        // render options in order they added
        bool request_update = false;
        Vec2f current_pos = pos + padding;
        for (uint i = 0; i < fields.length; i++)
        {
            for (uint j = 0; j < fields[i].options.length; j++)
            {
                if (fields[i].options[j].pos != current_pos)
                    request_update = true;

                fields[i].options[j].setPosition(current_pos);
                fields[i].options[j].render(alpha);

                current_pos += Vec2f(0, fields[i].options[j].dim.y + padding.y);
            }
        }

        if (submit !is null)
        {
            if (submit.pos != current_pos)
                request_update = true;

            submit.setPosition(current_pos);
            submit.render(alpha);
        }

        if (request_update) updateRects();
        if (hovered.size() > 0)
        {
            renderToolTip(Maths::Min(alpha, tooltip_alpha), tooltips[hovered[hovered.size() - 1]]);
        }
    }

    bool addField(string _title)
    {
        fields.push_back(OptionField());
        return true;
    }

    Option@ addSlider(u8 field_index, string _title, string _tooltip, Vec2f _button_dim = Vec2f(16, 16), Vec2f _capture_margin = Vec2f_zero, f32 _start_pos = 0, u8 _snap_points = 0)
    {
        if (field_index >= fields.length) return null;

        dim.y += _button_dim.y + padding.y + height_text * 2;
        Option option = Option(_title, pos, Vec2f(dim.x - padding.x * 2, height_text * 2 + _button_dim.y), true);
        option.parent_dim = dim;
        option.hover_tooltip = _tooltip;
        option.slider = Slider(_title, pos + Vec2f(padding.x, 0), Vec2f(dim.x - padding.x * 2, _button_dim.y), _button_dim, _capture_margin, _start_pos, _snap_points);
        fields[field_index].addOption(option);

        if (_tooltip != "") addTooltip(_tooltip, pos, pos + Vec2f(dim.x, _button_dim.y));

        return @option;
    }

    Option@ addCheckbox(u8 field_index, string _title, string _tooltip, Vec2f _dim = Vec2f(16, 16), bool _state = false)
    {
        if (field_index >= fields.length) return null;

        dim.y += _dim.y + padding.y;
        Option option = Option(_title, pos, Vec2f(dim.x - padding.x * 2, _dim.y), false, true);
        option.parent_dim = dim;
        option.hover_tooltip = _tooltip;
        option.check = CheckBox(_state, pos, _dim);
        fields[field_index].addOption(option);

        if (_tooltip != "") addTooltip(_tooltip, pos, pos + Vec2f(dim.x, height_checkbox));

        return @option;
    }

    Option@ addRadioList(u8 field_index, string _title, string _tooltip,
        Vec2f _grid = Vec2f(1, 1), Vec2f _item_dim = Vec2f(16, 16))
    {
        if (field_index >= fields.length) return null;

        f32 height = _item_dim.y * _grid.y + height_radio_button_list;
        dim.y += height + padding.y;
        
        Vec2f radio_dim = Vec2f(dim.x - padding.x * 2, height);
        Option option = Option(_title, pos, radio_dim, false, false, true);
        option.parent_dim = dim;
        option.hover_tooltip = _tooltip;
        option.radio_button_list = RadioButtonList(_title, pos + height_radio_button_list, radio_dim, _grid, _item_dim);
        fields[field_index].addOption(option);

        if (_tooltip != "") addTooltip(_tooltip, pos, pos + Vec2f(dim.x, height_radio_button_list));

        return @option;
    }
    
    bool addRadioListButton(u8 field_index, string radio_list_title, string _title, string _description,
        string _icon, Vec2f _icon_dim, u8 _index = 0, f32 _scale = 1)
    {
        if (field_index >= fields.length) return false;

        for (uint i = 0; i < fields[field_index].options.length; i++)
        {
            if (fields[field_index].options[i].default_text == radio_list_title)
            {
                fields[field_index].options[i].radio_button_list.addRadioButton(makeRadioButton(_title, _description, _icon, _icon_dim, _index, _scale));
                if (_description != "") addTooltip(_description, pos, pos + Vec2f(dim.x, height_radio_button_list));
                return true;
            }
        }
        return false;
    }

    Button@ addSubmit(u16 _blob_id, string _title, string _tooltip, Vec2f _dim, string _cmd)
    {
        if (submit !is null) return null;

        dim.y += _dim.y + padding.y;
        @submit = @Button(_blob_id, _title, pos, _dim, _cmd);
        submit.hover_tooltip = _tooltip;

        if (_tooltip != "") addTooltip(_tooltip, pos, pos + Vec2f(dim.x, _dim.y));

        return @submit;
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

    void updateRects()
    {
        tooltips = array<string>();
        tl_rects = tl_rects_const;
        br_rects = br_rects_const;

        // sidebar rects
        for (u8 i = 0; i < fields.length; i++)
        {
            for (u8 j = 0; j < fields[i].options.length; j++)
            {
                Option option = fields[i].options[j];
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

                    for (uint k = 0; k < option.radio_button_list.buttons.length; k++)
                    {
                        RadioButton radio_button = option.radio_button_list.buttons[k];
                        if (radio_button.description != "")
                            addTooltip(radio_button.description, radio_button.pos, radio_button.pos + radio_button.dim);
                    }
                }
            }
        }

        // submit
        if (submit !is null)
            addTooltip(submit.hover_tooltip, submit.pos, submit.pos + submit.dim);
    }

    void addSerializer(u16 _blob_id)
    {
        @serializer = @Serializer(_blob_id);
    }

    void Serialize()
    {
        if (submit is null)
        {
            print("Couldn't serialize command: submit button is null");
            return;
        }

        if (serializer is null)
        {
            print("Couldn't serialize command "+submit.cmd+": serializer is null");
            return;
        }
        
        CBlob@ blob = getBlobByNetworkID(submit.blob_id);
        if (blob is null)
        {
            print("Couldn't serialize command "+submit.cmd+": executer blob is null");
            return;
        }

        serializer.params.Clear();
        serializer.Serialize(blob, @this);
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