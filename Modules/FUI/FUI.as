#define CLIENT_ONLY

/*

  FUI (Futurism UI)

  Developed by kussakaa

  26.02.2025

 */

namespace FUI {

const string ICONS_FILENAME = "FUI_Icons.png";

enum Icons {
  GEAR,
}

const Vec2f _ICON_GEAR_FRAME_POS = Vec2f(0, 0);
const Vec2f _ICON_GEAR_FRAME_DIMENSIONS = Vec2f(16, 16);

namespace Colors {
  const SColor BG = SColor(0xFF0A0E14);
  const SColor FG = SColor(0xFFB3B1AD);
  const SColor FRAME = SColor(0xFF686868);
  const SColor ERROR = SColor(0xFFEA6C73);
}

enum Alignment {
  TL, // TOP LEFT
  TC, // TOP CENTER
  TR, // TOP RIGHT
  CL, // CENTER LEFT
  CC, // CENTER CENTER
  CR, // CENTER RIGHT
  BL, // BOTTOM LEFT,
  BC, // BOTTOM CENTER,
  BR, // BOTTOM RIGHT
}

class Canvas {
  Vec2f canvas_tl = Vec2f_zero;
  Vec2f canvas_br = Vec2f_zero;
  u32 _button_current = 0;
  u32 _button_hovered = 0;

  CControls@ _controls = getControls();
  bool _now_press = false;
  bool _was_press = false;

  void begin(Vec2f tl = Vec2f_zero, Vec2f br = Vec2f(getScreenWidth(), getScreenHeight()), Alignment alignment = Alignment::TL) {
    GUI::SetFont("Terminus_14");

    Vec2f screen_size = Vec2f(getScreenWidth(), getScreenHeight());
    switch (alignment) {
      case TL:
        canvas_tl = tl;
        canvas_br = br;
        break;
      case TC:
        break;
      case TR:
        break;
      case CL:
        break;
      case CC:
        canvas_tl = screen_size / 2 + tl;
        canvas_br = screen_size / 2 + br;
        break;
      case CR:
        break;
      case BL:
        break;
      case BC:
        break;
      case BR:
        break;
    }

    _button_current = 0;
    
    if(_controls !is null) {
      _was_press = _now_press;
      _now_press = _controls.mousePressed1;
    }
  }

  void end() {
    GUI::SetFont("menu");
  }

  Vec2f getSize() {
    return canvas_br - canvas_tl;
  }

  void drawPane(Vec2f tl, Vec2f br) {
    GUI::DrawRectangle(canvas_tl + tl, canvas_tl + br, Colors::FRAME);
    GUI::DrawRectangle(canvas_tl + tl + Vec2f(2, 2), canvas_tl + br - Vec2f(2, 2), Colors::FG);
    GUI::DrawRectangle(canvas_tl + tl + Vec2f(4, 4), canvas_tl + br - Vec2f(4, 4), Colors::BG);
  }

  void drawText(string text, Vec2f pos, SColor color = Colors::FG) {
    GUI::DrawText(text, canvas_tl + pos, color);
  }

  void drawTextCentered(string text, Vec2f tl, Vec2f br, SColor color = Colors::FG) {
    Vec2f dim = Vec2f(0,0);
    GUI::GetTextDimensions(text, dim);
    GUI::DrawText(text, canvas_tl + tl + Vec2f((br.x - tl.x) / 2 - dim.x / 2 - 2, (br.y - tl.y) / 2 - dim.y / 2 - 2), color);
  }

  void drawIcon(FUI::Icons icon, Vec2f pos) {
    switch (icon) {
      case GEAR:
        GUI::DrawIconDirect(ICONS_FILENAME, pos, _ICON_GEAR_FRAME_POS, _ICON_GEAR_FRAME_DIMENSIONS);
        break;
    }
  }
  
  bool drawButton(Vec2f tl, Vec2f br) {
    _button_current += 1;
    tl += canvas_tl;
    br += canvas_tl;
    Vec2f cpos = _controls.getMouseScreenPos();
    if (cpos.x > tl.x && cpos.x < br.x && cpos.y > tl.y && cpos.y < br.y) {
      if (_button_hovered != _button_current) {
        _button_hovered = _button_current;
        Sound::Play("FUI_Hovered");
      }
      if (_isPress()) { // Pressed
        GUI::DrawRectangle(tl, br, Colors::FRAME);
        GUI::DrawRectangle(tl + Vec2f(2, 2), br - Vec2f(2, 2), Colors::FRAME);
        GUI::DrawRectangle(tl + Vec2f(4, 4), br - Vec2f(4, 4), Colors::BG);
        if (_isJustPressed()) {
          Sound::Play("FUI_Pressed");
          return true;
        }
      } else { // Hovered
        GUI::DrawRectangle(tl, br, Colors::FG);
        GUI::DrawRectangle(tl + Vec2f(4, 4), br - Vec2f(4, 4), Colors::BG);
      }
    } else { // Normal
      GUI::DrawRectangle(tl, br, Colors::FRAME);
      GUI::DrawRectangle(tl + Vec2f(2, 2), br - Vec2f(2, 2), Colors::FG);
      GUI::DrawRectangle(tl + Vec2f(4, 4), br - Vec2f(4, 4), Colors::BG);
      if (_button_hovered == _button_current) _button_hovered = 0;
    }
    return false;
  }

  bool drawToggle(bool value, Vec2f pos) {
    if (value) {
      if(drawButton(pos, pos + Vec2f(16, 16))) value = !value;
      GUI::DrawRectangle(canvas_tl + pos + Vec2f(6,6), canvas_tl + pos + Vec2f(10,10), Colors::FG);
    } else {
      if(drawButton(pos, pos + Vec2f(16, 16))) value = !value;
    }
    return value;
  }

  bool _isPress() {
    return _now_press;
  }
  
  bool _isJustPressed() {
    return (_now_press and !_was_press) ? true : false;
  }
  
  bool _isJustReleased() {
    return (!_now_press and _was_press) ? true : false;
  }
}


class AnimationRect {
  Vec2f tl = Vec2f_zero;
  Vec2f br = Vec2f_zero;
  Vec2f tl_start = Vec2f_zero;
  Vec2f br_start = Vec2f_zero;
  Vec2f tl_end = Vec2f_zero;
  Vec2f br_end = Vec2f_zero;
  f32 frame = 0;
  f32 duration = 10;

  void play() {
    // time (0.0 - 1.0)
    f32 t = frame / duration;
    // bezier curve math for beutiful animation
    Vec2f tl_temp0 = Vec2f_lerp(tl_start, tl_end, t);
    Vec2f tl_temp1 = Vec2f_lerp(tl_start, tl_temp0, t);
    Vec2f tl_temp2 = Vec2f_lerp(tl_temp0, tl_end, t);
    tl = Vec2f_lerp(tl_temp1, tl_temp2, 1);
    Vec2f br_temp0 = Vec2f_lerp(br_start, br_end, t);
    Vec2f br_temp1 = Vec2f_lerp(br_start, br_temp0, t);
    Vec2f br_temp2 = Vec2f_lerp(br_temp0, br_end, t);
    br = Vec2f_lerp(br_temp1, br_temp2, 1);

    frame = Maths::Min(frame + 1, duration);
  }
  
  bool isEnd() {
    return frame == duration;
  }

  bool isPlay() {
    return frame != 0 && frame != duration;
  }

  bool isPlayOrEnd() {
    return frame != 0;
  }
}

class AnimationText {
  string text = "";
  string result = "";
  f32 frame = 0;
  f32 duration = 10;

  void play() {
    text = result;
    if (isEnd()) return;
    text.resize(Maths::Lerp(0, result.length(), frame / duration));
    text += "█";
    frame = Maths::Min(frame + 1, duration);
  }

  bool isEnd() {
    return frame == duration;
  }

  bool isPlay() {
    return frame != 0 && frame != duration;
  }

  bool isPlayOrEnd() {
    return frame != 0;
  }
}

}
 
