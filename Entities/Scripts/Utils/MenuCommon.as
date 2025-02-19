#include "Slider.as"
#include "CheckBox.as"
#include "ToolTipUtils.as"

class MenuItemInfo
{
    string text;
    string description;

    Vec2f tl;
    Vec2f dim;

    MenuItemSlider[] sliders;
    MenuItemCheckbox[] checkboxes;

    Vec2f[] tl_rects_static;
    Vec2f[] br_rects_static;
    
    Vec2f[] tl_rects;
    Vec2f[] br_rects;
    int[] hovered;

    bool require_tick_update;
    Vec2f mpos;

    MenuItemInfo(string _text, string _description)
    {
        text = _text;
        description = _description;
        
        require_tick_update = false;
        mpos = Vec2f(-1,-1);
    }

    void tick()
    {
        CControls@ controls = getControls();
        if (controls is null) return;

        Vec2f aimpos = controls.getInterpMouseScreenPos();
        bool item_hover = aimpos.x >= tl.x && aimpos.x <= tl.x + dim.x
            && aimpos.y >= tl.y && aimpos.y <= tl.y + dim.y;

        bool do_tick = require_tick_update || item_hover;
        if (!do_tick) return;

        if (item_hover) require_tick_update = true;
        else require_tick_update = false;

        hovered = getHoveredIndexes(aimpos, tl_rects, br_rects);
        for (uint i = 0; i < sliders.length; i++)
        {
            sliders[i].rect_hover = hovered.find(i) != -1;
            sliders[i].tick();
        }
    }

    void render(u8 alpha)
    {
        for (uint i = 0; i < sliders.length; i++)
        {
            sliders[i].render(alpha);
            GUI::DrawText("Hello", Vec2f(500,500), SColor(255, 255, 255, 255));
        }
    }

    void addRect(Vec2f _tl, Vec2f _br, bool static = false)
    {
        if (static)
        {
            tl_rects_static.push_back(_tl);
            br_rects_static.push_back(_br);
        }
        else
        {
            tl_rects.push_back(_tl);
            br_rects.push_back(_br);
        }
    }

    void addSlider(string _name, Vec2f _pos, Vec2f _dim, Vec2f _button_dim, Vec2f _capture_margin = Vec2f_zero, f32 _start_pos = 0, u8 _snap_points = 0)
    {
        addSlider(MenuItemSlider(_name, _pos, _dim, _button_dim, _capture_margin, _start_pos, _snap_points));
    }

    void addSlider(MenuItemSlider slider)
    {
        sliders.push_back(slider);
        addRect(slider.pos, slider.pos + slider.dim);
    }

    void addCheckbox(bool _state, Vec2f _pos, Vec2f _dim)
    {
        addCheckbox(MenuItemCheckbox(_state, _pos, _dim));
    }

    void addCheckbox(MenuItemCheckbox checkbox)
    {
        checkboxes.push_back(checkbox);
        addRect(checkbox.pos, checkbox.pos + checkbox.dim);
    }

    void updateRects()
    {
        tl_rects = tl_rects_static;
        br_rects = br_rects_static;

        for (u8 i = 0; i < sliders.length; i++)
        {
            addRect(sliders[i].pos, sliders[i].pos + sliders[i].dim);
        }

        for (u8 i = 0; i < checkboxes.length; i++)
        {
            addRect(checkboxes[i].pos, checkboxes[i].pos + checkboxes[i].dim);
        }
    }
};

class MenuItemSlider : Slider
{
    bool rect_hover;
    string hover_tooltip;

    MenuItemSlider(string _name = "", Vec2f _pos = Vec2f_zero, Vec2f _dim = Vec2f_zero, Vec2f _button_dim = Vec2f_zero, Vec2f _capture_margin = Vec2f_zero, f32 _start_pos = 0, u8 _snap_points = 0)
    {
        super(_name, _pos, _dim, _button_dim, _capture_margin, _start_pos, _snap_points);

        rect_hover = false;
        hover_tooltip = "";
    }

    void tick()
    {
        CControls@ controls = getControls();
        if (controls is null) return;

        Vec2f mpos = controls.getInterpMouseScreenPos();
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
    bool rect_hover;
    string hover_tooltip;

    MenuItemCheckbox(bool _state = false, Vec2f _pos = Vec2f_zero, Vec2f _dim = Vec2f_zero)
    {
        super(_state, _pos, _dim);

        rect_hover = false;
        hover_tooltip = "";
    }

    //void render(u8 alpha)
    //{
    //    
    //}
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