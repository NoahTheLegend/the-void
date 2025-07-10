#include "MenuCommon.as"

const u8 TOOLTIP_HOLD_TIME = 30;

const f32 height_text = 20;
const f32 height_slider = 64;
const f32 height_checkbox = 16;
const f32 height_radio_button_list = 24;

namespace FieldTag
{
    enum Type
    {
        create_blob = 0,

        TOTAL
    }
}

namespace OptionType
{
    enum Type
    {
        slider = 0,
        check,
        radio_button_list,

        TOTAL
    }
}

namespace SliderTag
{
    enum Type
    {
        slider_quantity = 0,
        slider_factor,

        TOTAL
    }
}

namespace CheckTag
{
    enum Type
    {
        check_state = 0,

        TOTAL
    }
}

namespace ButtonListTag
{
    enum Type
    {
        button_selected = 0,

        TOTAL
    }
}

void makeSidebar(MenuItemInfo@ item, string[] fields = array<string>())
{
    Sidebar@ sidebar = @item.sidebar;
    if (sidebar is null) return;
    
    item.sidebar_pos = item.list_pos + Vec2f(item.list_dim.x, 0);

    if (fields.size() == 0)
    {
        sidebar.addField("root");
    }
    else
    {
        bool add_field = true;

        for (u8 i = 0; i < fields.size(); i++)
        {
            sidebar.addField(fields[i]);
        }
    }

    sidebar.updateRects();
}

MenuItemInfo@ AddMenuItem(CBlob@ this, string text, string description, string[] fields = array<string>())
{
    if (this is null) return null;
    
    MenuItemInfo@[]@ menuItems;
    if (!this.get("MenuItems", @menuItems))
    {
        @menuItems = array<MenuItemInfo@>();
        this.set("MenuItems", @menuItems);
    }

    
    MenuItemInfo item = MenuItemInfo(this.getNetworkID(), text, description);
    makeSidebar(item, fields);
    menuItems.push_back(item);

    return @item;
}

Option@ makeSliderOption(MenuItemInfo@ item, u8 tag, u8 field_index, string title, string tooltip,
    Vec2f button_dim = Vec2f(16, 16), Vec2f capture_margin = Vec2f(8, 8), f32 startpos = 0, int snap_points = 0)
{
    Sidebar@ sidebar = item.sidebar;
    if (sidebar is null)
    {
        error("Sidebar is null in Option@ makeSlider()");
        return null;
    }

    Option@ slider = sidebar.addSlider(field_index, title, tooltip, button_dim, Vec2f(8, 8), startpos, snap_points);
    slider.tag = tag;

    return slider;
}

void setSliderTextMode(Option@ slider, u8 mode, string[] descriptions = array<string>())
{
    if (slider is null)
    {
        error("Slider is null in void setSliderTextMode()");
        return;
    }

    slider.setSliderTextMode(mode);
    slider.addSliderDescriptions(descriptions);
}

Option@ makeCheckBoxOption(MenuItemInfo@ item, u8 tag, u8 field_index, string title, string tooltip,
    Vec2f dim = Vec2f(24, 24), bool state = false)
{
    Sidebar@ sidebar = item.sidebar;
    if (sidebar is null)
    {
        error("Sidebar is null in Option@ makeCheckBox()");
        return null;
    }

    Option@ check = sidebar.addCheckbox(field_index, title, tooltip, dim, state);
    check.tag = tag;

    return check;
}

Option@ makeRadioListOption(MenuItemInfo@ item, u8 tag, u8 field_index, string title, string tooltip, Vec2f grid,
    Vec2f button_dim = Vec2f(32, 32), u8 selected = 0)
{
    Sidebar@ sidebar = item.sidebar;
    if (sidebar is null)
    {
        error("Sidebar is null in Option@ makeRadioList()");
        return null;
    }

    Option@ radio_list = sidebar.addRadioList(field_index, title, tooltip, grid, button_dim);
    radio_list.radio_button_list.selected = selected;
    radio_list.tag = tag;

    return radio_list;
}

void addRadioListButton(MenuItemInfo@ item, u8 field_index, string radio_list, string title, string tooltip,
    string icon = "InteractionIcons.png", Vec2f icon_dim = Vec2f(32, 32), int icon_index = 0, f32 icon_scale = 1)
{
    Sidebar@ sidebar = item.sidebar;
    if (sidebar is null)
    {
        error("Sidebar is null in void addRadioListButton()");
        return;
    }

    /*bool addRadioListButton(u8 field_index, string radio_list_title, string _title, string _tooltip,
        string _icon, Vec2f _icon_dim, int _icon_index, f32 _scale = 1)*/
    sidebar.addRadioListButton(field_index, radio_list, title, tooltip, icon, icon_dim, icon_index, icon_scale);
}

Button@ addSubmit(MenuItemInfo@ item, string title, string tooltip, Vec2f dim, string cmd)
{
    Sidebar@ sidebar = item.sidebar;
    if (sidebar is null)
    {
        error("Sidebar is null in void addSubmit()");
        return null;
    }

    sidebar.addSubmit(item.blob_id, title, tooltip, dim, cmd);
    return sidebar.submit;
}

MenuItemInfo@[] GetMenuItemList(CBlob@ this)
{
    MenuItemInfo@[]@ menuItems;
    if (!this.get("MenuItems", @menuItems))
    {
        @menuItems = array<MenuItemInfo@>();
        this.set("MenuItems", @menuItems);
    }

    return menuItems;
}

MenuItemInfo@ GetMenuItem(CBlob@ this, uint index)
{
    MenuItemInfo@[]@ menuItems;
    if (!this.get("MenuItems", @menuItems))
    {
        @menuItems = array<MenuItemInfo@>();
        this.set("MenuItems", @menuItems);
    }

    if (index >= menuItems.length)
    {
        return null;
    }

    return menuItems[index];
}