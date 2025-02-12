
void drawRectangle(Vec2f tl, Vec2f br, SColor color, u8 border_type = 0, f32 border_width = 0, SColor border_color = SColor(255, 0, 0, 0))
{
    switch(border_type)
    {
        case 0: // none
        {
            GUI::DrawRectangle(tl, br, color);
            break;
        }
        case 1: // thin
        {
            GUI::DrawRectangle(tl, br, border_color);
            GUI::DrawRectangle(tl + Vec2f(border_width, border_width), br - Vec2f(border_width, border_width), color);
            break;
        }
        case 2: // thick
        {
            GUI::DrawRectangle(tl, br, border_color);
            GUI::DrawRectangle(tl + Vec2f(border_width, border_width), br - Vec2f(border_width, border_width), border_color);
            GUI::DrawRectangle(tl + Vec2f(border_width * 2, border_width * 2), br - Vec2f(border_width * 2, border_width * 2), color);
            break;
        }
    }
}