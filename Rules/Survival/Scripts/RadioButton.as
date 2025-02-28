#include "ToolTipUtils.as"
#include "HoverUtils.as"

RadioButton makeRadioButton(string _name, string _description, string _icon, Vec2f _icon_dim, int _index = 0, f32 _scale = 1)
{
    return RadioButton(_name, _description, _icon, _icon_dim, _index, _scale);
}

class RadioButtonList
{
    string title;
    int selected;
    int hovered_index;
    RadioButton[] buttons;

    Vec2f pos;
    Vec2f dim;
    Vec2f grid;
    Vec2f item_dim;
    
    Vec2f mpos;

    RadioButtonList(string _title, Vec2f _pos, Vec2f _dim, Vec2f _grid = Vec2f_zero, Vec2f _item_dim = Vec2f_zero)
    {
        title = _title;
        selected = -1;
        hovered_index = -1;

        pos = _pos;
        dim = _dim;

        if (_grid != Vec2f_zero)
            grid = _grid;
        else
            grid = calculateGrid(dim);
        if (_item_dim != Vec2f_zero)
            item_dim = _item_dim;
        else
            item_dim = calculateItemDim(dim, grid);
    }

    void tick()
    {
        CControls@ controls = getControls();
        if (controls is null) return;

        mpos = controls.getInterpMouseScreenPos();
        hovered_index = getHoverIndex();

        //if (getGameTime()%30==0) print("Hovered index: " + hovered_index +" Selected index: " + selected +" Buttons size: " + buttons.size());

        if (controls.isKeyJustPressed(KEY_LBUTTON) || controls.isKeyJustPressed(KEY_RBUTTON))
        {
            if (hovered_index != -1)
                select(hovered_index);
        }
    }

    void render()
    {
        for (uint i = 0; i < buttons.length; i++)
        {
            buttons[i].selected = false;
            buttons[i].hovered = false;

            if (i == selected)
                buttons[i].selected = true;
            if (i == hovered_index)
                buttons[i].hovered = true;
            
            buttons[i].pos = pos + Vec2f((i % int(grid.x)) * item_dim.x, (i / int(grid.x)) * item_dim.y);
            buttons[i].dim = item_dim;
            buttons[i].list_dim = dim;
            buttons[i].render();
        }
    }

    void setPosition(Vec2f _pos)
    {
        pos = _pos;
    }

    bool canAddButton()
    {
        return buttons.size() < grid.x * grid.y;
    }

    void addRadioButton(RadioButton@ button)
    {
        if (canAddButton())
        {
            buttons.push_back(button);
        }
    }

    void removeRadioButton(int index)
    {
        if (index < 0 || index >= buttons.size())
            return;

        buttons.removeAt(index);
    }

    void select(int index)
    {
        if (index == selected)
        {
            selected = -1;
            onSelect(index);
            return;
        }
    }

    void onSelect(int index)
    {
        if (isClient())
        {

        }

        if (isServer())
        {

        }
    }

    Vec2f calculateGrid(Vec2f _dim)
    {
        return Vec2f(_dim.x / item_dim.x, _dim.y / item_dim.y);
    }

    Vec2f calculateItemDim(Vec2f _dim, Vec2f _grid)
    {
        return Vec2f(_dim.x / _grid.x, _dim.y / _grid.y);
    }

    int getHoverIndex()
    {
        Vec2f mouse = mpos - pos;
        int x = mouse.x / item_dim.x;
        int y = mouse.y / item_dim.y;
        int index = x + y * int(grid.x);

        if (mouse.x >= 0 && mouse.y >= 0 && index >= 0 && index < buttons.size())
            return index;
            
        return -1;
    }

    RadioButton@ getButton(int index)
    {
        return @buttons[index];
    }
};

class RadioButton
{
    string name;
    string description;
    string icon;
    int icon_index;
    Vec2f icon_dim;
    f32 icon_scale;
    bool selected;
    bool hovered;

    Vec2f pos;
    Vec2f dim;
    Vec2f list_dim;

    RadioButton(string _name, string _description, string _icon, Vec2f _icon_dim, int _index = 0, f32 _scale = 1)
    {
        name = _name;
        description = _description;
        icon = _icon;
        icon_dim = _icon_dim;
        icon_index = _index;
        icon_scale = _scale;
        selected = false;
        hovered = false;

        pos = Vec2f_zero;
        dim = Vec2f_zero;
        list_dim = Vec2f_zero;
    }

    void render()
    {
        if (selected)
        {
            drawRectangle(pos, pos + dim, SColor(255, 255, 255, 255));
            drawRectangle(pos + Vec2f(1, 1), pos + dim - Vec2f(1, 1), SColor(255, 0, 0, 0));
        }
        else if (hovered)
        {
            drawRectangle(pos, pos + dim, SColor(255, 255, 255, 255));
            drawRectangle(pos + Vec2f(1, 1), pos + dim - Vec2f(1, 1), SColor(255, 0, 0, 0));
        }

        Vec2f scale_offset = (dim * (1.0f - icon_scale));
        Vec2f icon_pos = pos - dim/2 + scale_offset;
        GUI::DrawIcon(icon, icon_index, icon_dim, icon_pos, icon_scale);
    }
}