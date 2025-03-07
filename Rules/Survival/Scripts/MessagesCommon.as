#include "UtilitiesCommon.as";

bool mouseHovered(MessageContainer@ this, Slider slider)
{
    CControls@ controls = getControls();
    Vec2f mpos = controls.getMouseScreenPos();

    bool isOnMessageContainer = (mpos.x >= this.tl.x && mpos.x <= this.br.x && mpos.y >= this.tl.y && mpos.y <= this.br.y);
    if (isOnMessageContainer) return true;

    bool isOnSlider = (mpos.x >= slider.tl.x && mpos.x <= slider.br.x && mpos.y >= slider.tl.y && mpos.y <= slider.br.y);
    if (isOnSlider) return true;
    
    return false;
}

string formDefaultTitle(CPlayer@ this)
{
    if (this is null) return "Unknown source";
    else return this.getCharacterName()+" said:";
}  

MessageText makeText(string text = "NULL", string title = formDefaultTitle(null), u8 title_offset = 4, u16 max_length = 255, u8 delay = 1, bool playsound = !areMessagesMutedWhileHidden())
{
    MessageText messageText(text, title, title_offset, max_length, delay, playsound);
    return messageText;
}      

void addMessage(MessageText messageText)
{
    MessageContainer@ box;
    if (getRules().get("MessageContainer", @box))
    {
        if (box !is null)
        {
            Message msg(messageText);
            box.addMessage(msg);
        }
    }
}

bool hover(Vec2f mpos, Vec2f tl, Vec2f br)
{
    return mpos.x >= tl.x && mpos.x <= br.x
        && mpos.y >= tl.y && mpos.y <= br.y;
}