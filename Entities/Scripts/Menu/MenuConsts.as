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