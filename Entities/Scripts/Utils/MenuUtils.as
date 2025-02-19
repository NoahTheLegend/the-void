#include "MenuCommon.as"

bool AddMenuItem(CBlob@ this, string text, string description)
{
    MenuItemInfo@[]@ menuItems;
    if (!this.get("MenuItems", @menuItems))
    {
        @menuItems = array<MenuItemInfo@>();
        this.set("MenuItems", @menuItems);
    }

    for (uint i = 0; i < menuItems.length; i++)
    {
        if (menuItems[i].text == text)
        {
            return false;
        }
    }
    
    menuItems.push_back(MenuItemInfo(text, description));
    return true;
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