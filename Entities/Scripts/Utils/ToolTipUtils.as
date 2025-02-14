
const SColor _col_hologram = SColor(255,50,100,155);
const SColor _col_hologram_border = SColor(255,27,69,113);

void drawRectangle(Vec2f tl, Vec2f br, SColor color, u8 border_type = 0, f32 border_width = 0, SColor border_color = SColor(255, 0, 0, 0))
{
    switch (border_type)
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

void drawInterruptor(Vec2f tl, Vec2f br, Vec2f size, SColor col, f32 zoom, f32 speed = 1.0f, u8 type = 0)
{
    switch (type)
    {
        case 0: // default from top to bottom
        {
            f32 offset_y = ((getGameTime() * speed * zoom) % (br.y - tl.y) / zoom) * zoom;
            f32 line_y = tl.y + offset_y;
            GUI::DrawRectangle(Vec2f(tl.x, line_y - size.y * 0.5f * zoom), Vec2f(br.x, line_y + size.y * 0.5f * zoom), col);
            break;
        }
    }
}

//void drawCone()