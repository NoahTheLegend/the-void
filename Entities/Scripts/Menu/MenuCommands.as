#include "Slider.as"
#include "CheckBox.as"
#include "RadioButton.as"
#include "OptionUtils.as"
#include "MenuConsts.as"

void SendCommand(CBlob@ this, string cmd, Serializer@ serializer)
{
    if (this is null || serializer is null) return;
    this.SendCommand(this.getCommandID(cmd), serializer.params);
}

class Serializer
{
    u16 blob_id;
    CBitStream params;

    Serializer(u16 _blob_id)
    {
        blob_id = _blob_id;
    }

    void Serialize(CBlob@ blob, Sidebar@ sidebar)
    {
        if (sidebar is null)
        {
            print ("Couldn't serialize command: sidebar is null");
            return;
        }

        CBlob@ local = getLocalPlayerBlob();
        if (local is null)
        {
            print("Couldn't serialize command "+sidebar.submit.cmd+": local blob is null");
            return;
        }

        // 0 - local id
        params.write_u16(local.getNetworkID());

        u16[]@ attached_players;
        if (!blob.get("attached_players", @attached_players))
        {
            print("Couldn't serialize command "+sidebar.submit.cmd+": attached_players is null");
            return;
        }

        // 1 - attached players quantity
        params.write_u8(attached_players.length);

        // 2 - attached players
        for (uint i = 0; i < attached_players.length; i++)
        {
            params.write_u16(attached_players[i]);
        }

        // 3 - fields quantity
        params.write_u8(sidebar.fields.length);
    
        for (u8 i = 0; i < sidebar.fields.length; i++)
        {
            auto@ field = sidebar.fields[i];

            // 4 - field type
            params.write_u8(field.tag);

            // 5 - options quantity
            params.write_u8(field.options.length);

            for (u8 j = 0; j < field.options.length; j++)
            {
            auto@ option = field.options[j];

            // 6 - option type
            if (option.has_slider)
            {
                params.write_u8(OptionType::slider);
                // 7 - option tag
                params.write_s32(option.tag);
                // 8 - slider value

                switch (option.tag)
                {
                    case SliderTag::slider_quantity:
                    {
                        int step = option.slider.scrolled * option.slider.snap_points;
                        params.write_f32(step);
                        break;
                    }
                    case SliderTag::slider_factor:
                    {
                        params.write_f32(option.slider.scrolled);
                        break;
                    }
                }
            }
            else if (option.has_check)
            {
                params.write_u8(OptionType::check);
                // 7 - option tag
                params.write_s32(option.tag);
                // 8 - checkbox value
                params.write_bool(option.check.state);
            }
            else if (option.has_radio_button_list)
            {
                RadioButtonList@ list = @option.radio_button_list;
                if (list is null)
                {
                print("Couldn't serialize command "+sidebar.submit.cmd+": radio_button_list is null");
                return;
                }

                RadioButton@ button = @list.buttons[list.selected];
                if (button is null)
                {
                print("Couldn't serialize command "+sidebar.submit.cmd+": radio_button is null");
                return;
                }

                params.write_u8(OptionType::radio_button_list);
                // 7 - option tag
                params.write_s32(option.tag);
                // 8 - radio button value
                params.write_u8(list.selected);
            }
            }
        }
    }
}