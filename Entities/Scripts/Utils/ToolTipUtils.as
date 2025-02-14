
const SColor _col_hologram = SColor(255,50,100,155);
const SColor _col_hologram_border = SColor(255,27,69,113);
const SColor _col_hologram_cone = SColor(255,64,135,218);
const SColor _col_hologram_progress = SColor(255,75,255,255);

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
void drawCone(Vec2f start, Vec2f end, f32 angleDeg, SColor col)
{
    Driver@ driver = getDriver();

    Vec2f forward = end - start;
    float forwardLen = forward.Length();

    if (forwardLen < 0.0001f) return;
    forward.Normalize();

    Vec2f side = forward;
    side.RotateBy(90.0f);

    float halfAngleRad = angleDeg * 0.5f * Maths::Pi / 180.0f;
    float horizontalLen = forwardLen * Maths::Tan(halfAngleRad);
    Vec2f offset = side * horizontalLen;
    
    Vec2f cornerLeft  = end + offset;
    Vec2f cornerRight = end - offset;

    Vertex[] vertices;
    vertices.push_back(Vertex(
        driver.getWorldPosFromScreenPos(start),
        0.0f,
        Vec2f(0.0f, 0.0f),
        col
    ));
    col.setAlpha(0);
    vertices.push_back(Vertex(
        driver.getWorldPosFromScreenPos(cornerLeft),
        0.0f,
        Vec2f(1.0f, 0.0f),
        col
    ));
    vertices.push_back(Vertex(
        driver.getWorldPosFromScreenPos(cornerRight),
        0.0f,
        Vec2f(0.0f, 1.0f),
        col
    ));

    Render::RawTriangles("pixel", vertices);
}

void drawProgressBarAroundRectangle(Vec2f tl, Vec2f dim, f32 progress, f32 width, SColor col)
{
    if (progress < 0.0f) progress = 0.0f;
    if (progress > 1.0f) progress = 1.0f;

    f32 perimeter = 2.0f * (dim.x + dim.y); // Total perimeter length
    f32 progressLength = progress * perimeter; // Length of the progress bar

    Vec2f centerLeft = Vec2f(tl.x, tl.y + dim.y * 0.5f);
    Vec2f centerRight = Vec2f(tl.x + dim.x, tl.y + dim.y * 0.5f);
    Vec2f topLeft = tl;
    Vec2f topRight = Vec2f(tl.x + dim.x, tl.y);
    Vec2f bottomLeft = Vec2f(tl.x, tl.y + dim.y);
    Vec2f bottomRight = Vec2f(tl.x + dim.x, tl.y + dim.y);

    f32 drawn = 0.0f;

    // Draw left center to top left and bottom left simultaneously
    f32 leftLength = dim.y * 0.5f;
    if (drawn + leftLength * 2 > progressLength) {
        f32 halfProgress = (progressLength - drawn) * 0.5f;
        // Draw left center to partial top left
        GUI::DrawRectangle(Vec2f(centerLeft.x, centerLeft.y - halfProgress), Vec2f(centerLeft.x + width, centerLeft.y), col);
        // Draw left center to partial bottom left
        GUI::DrawRectangle(Vec2f(centerLeft.x, centerLeft.y), Vec2f(centerLeft.x + width, centerLeft.y + halfProgress + width), col);
        return;
    }
    // Draw left center to top left
    GUI::DrawRectangle(Vec2f(centerLeft.x, topLeft.y), Vec2f(centerLeft.x + width, centerLeft.y), col);
    // Draw left center to bottom left
    GUI::DrawRectangle(Vec2f(centerLeft.x, centerLeft.y), Vec2f(centerLeft.x + width, bottomLeft.y + width), col);
    drawn += leftLength * 2;

    // Draw top left to top right and bottom left to bottom right simultaneously
    f32 horizontalLength = dim.x;
    if (drawn + horizontalLength * 2 > progressLength) {
        f32 halfProgress = (progressLength - drawn) * 0.5f;
        // Draw partial top left to top right
        GUI::DrawRectangle(Vec2f(topLeft.x + width, topLeft.y), Vec2f(topLeft.x + width + halfProgress, topLeft.y + width), col);
        // Draw partial bottom left to bottom right
        GUI::DrawRectangle(Vec2f(bottomLeft.x + width, bottomLeft.y), Vec2f(bottomLeft.x + width + halfProgress, bottomLeft.y + width), col);
        return;
    }
    // Draw top left to top right
    GUI::DrawRectangle(Vec2f(topLeft.x + width, topLeft.y), Vec2f(topRight.x + width, topRight.y + width), col);
    // Draw bottom left to bottom right
    GUI::DrawRectangle(Vec2f(bottomLeft.x + width, bottomLeft.y), Vec2f(bottomRight.x + width, bottomRight.y + width), col);
    drawn += horizontalLength * 2 + width;

    // Draw top right to center right and bottom right to center right simultaneously
    f32 rightLength = dim.y * 0.5f;
    if (drawn + rightLength * 2 > progressLength) {
        f32 halfProgress = (progressLength - drawn) * 0.5f;
        // Draw top right to partial center right
        GUI::DrawRectangle(Vec2f(topRight.x, topRight.y + width), Vec2f(topRight.x + width, topRight.y + halfProgress + width), col);
        // Draw bottom right to partial center right
        GUI::DrawRectangle(Vec2f(bottomRight.x, bottomRight.y - halfProgress), Vec2f(bottomRight.x + width, bottomRight.y), col);
        return;
    }
    // Draw top right to center right
    GUI::DrawRectangle(Vec2f(topRight.x, topRight.y + width), Vec2f(topRight.x + width, centerRight.y - width), col);
    // Draw bottom right to center right
    GUI::DrawRectangle(Vec2f(bottomRight.x, centerRight.y + width), Vec2f(bottomRight.x + width, bottomRight.y), col);
    drawn += rightLength * 2;
}