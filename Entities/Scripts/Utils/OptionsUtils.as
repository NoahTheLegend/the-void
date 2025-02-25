#include "Slider.as";
#include "CheckBox.as";

class Section {
    string title;
    Vec2f pos;
    Vec2f dim;
    Vec2f padding;
    bool setting;

    Vec2f tl;
    Vec2f br;
    Option[] options;

    Vec2f title_dim;

    Section(string _title, Vec2f _pos, Vec2f _dim, bool _setting = false)
    {
        title = _title;
        pos = _pos;
        dim = _dim;

        tl = pos;
        br = pos+dim;
        padding = Vec2f(15, 10);
        setting = _setting;
        
        GUI::GetTextDimensions(title, title_dim);
    }

    void addOption(Option@ option)
    {
        option.parent_dim = this.dim;
        options.push_back(option);
    }

    void tick()
    {
        for (u8 i = 0; i < options.size(); i++)
        {
            options[i].tick();
        }
    }

    void render(u8 alpha)
    {
        SColor col_white = SColor(alpha,255,255,255);
        SColor col_grey = SColor(alpha,235,235,235);

        GUI::SetFont("Terminus_18");
        GUI::DrawText(title, pos + Vec2f(title_dim.x + padding.x/2, padding.y), col_white);
        GUI::DrawRectangle(tl+padding + Vec2f(0,28), Vec2f(br.x-padding.x, tl.y+padding.y + 30), col_grey);
        
        for (u8 i = 0; i < options.size(); i++)
        {
            options[i].render(alpha);
        }
    }
};

class Option {
    string default_text;
    string option_text;
    Vec2f pos;
    bool has_slider;
    f32 slider_startpos;
    bool has_check;
    Vec2f parent_dim;
    string hover_tooltip;
    bool setting;

    Slider slider;
    CheckBox check;

    Option(string _text, Vec2f _pos, bool _has_slider = false, bool _has_check = false, bool _setting = false)
    {
        this.default_text = _text;
        this.option_text = "";
        this.pos = _pos;
        this.has_slider = _has_slider;
        this.has_check = _has_check;
        this.slider_startpos = 0.5f;
        this.parent_dim = Vec2f(150, 150);
        this.hover_tooltip = "";
        this.setting = _setting;

        if (has_slider)
        {
            slider = Slider("option_slider", pos+Vec2f(0,23), Vec2f(this.parent_dim.x,15), Vec2f(15,15), Vec2f(8,8), slider_startpos, 0, this.setting);
        }
        if (has_check)
        {
            check = CheckBox(false, pos+Vec2f(0,1), Vec2f(18,18), this.setting);
        }
    }

    void setPosition(Vec2f _pos)
    {
        pos = _pos;

        slider.update();
        check.update();
    }

    void setSliderPos(f32 scroll)
    {
        slider.setScroll(scroll);
    }

    void setSliderTextMode(u8 mode)
    {
        slider.mode = mode;
    }

    void setCheck(bool flagged)
    {
        check.state = flagged;
    }

    void tick()
    {
        if (has_slider)
        {
            slider.tick();
        }
        if (has_check)
        {
            check.tick();
        }

        option_text = Maths::Round(slider.scrolled*100)+"%";
        if (slider.mode == 1)
            option_text = ""+(Maths::Abs(Maths::Clamp(slider.step.x+1,1,slider.snap_points+1)) * slider.description_step_mod - slider.description_step_mod);
        else if (slider.mode == 2)
            option_text = slider.descriptions[slider.getSnapPoint()];
        else if (slider.mode == 3)
            option_text = default_text;
    }

    void render(u8 alpha)
    {
        GUI::SetFont("menu");
        SColor col_white = SColor(alpha,255,255,255);
        if (has_slider)
        {
            slider.render(alpha);
            GUI::DrawText(option_text, slider.pos+Vec2f(0, slider.dim.y), SColor(255,255,235,120));
        }
        if (has_check)
        {
            check.render(alpha);
        }

        GUI::SetFont("Terminus_12");
        GUI::DrawText(default_text, has_check?pos+Vec2f(25,0):pos, col_white);
    }
};