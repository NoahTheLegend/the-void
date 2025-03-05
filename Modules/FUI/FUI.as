#define CLIENT_ONLY

/*

  FUI (Futurism UI)

  Developed by kussakaa

  Februar 2025

 */

namespace FUI {

const string ICONS_FILENAME = "FUI_Icons.png";

bool debug_mode = false;

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

bool _isPointInRect(Vec2f pos, Vec2f tl, Vec2f br) {
  return pos.x > tl.x && pos.x < br.x && pos.y > tl.y && pos.y < br.y;
}

void _drawDebugRect(string info, Vec2f tl, Vec2f br, SColor color) {
  GUI::SetFont("Terminus_12");
  GUI::DrawRectangle(tl - Vec2f(1, 1), br + Vec2f(1, 1), color);
  Vec2f dim;
  GUI::GetTextDimensions(info, dim);
  GUI::DrawRectangle(Vec2f(tl.x - 1, br.y), Vec2f(tl.x - 1, br.y) + dim + Vec2f(4, 4), color);
  GUI::DrawText(info, Vec2f(tl.x, br.y), SColor(0xFF000000));
  GUI::SetFont("Terminus_14");
}

void _drawPane(Vec2f tl, Vec2f br) {
  if(debug_mode && getControls().mousePressed2 && _isPointInRect(getControls().getMouseScreenPos(), tl, br)) {
    _drawDebugRect("tl("+tl.x+":"+tl.y+") br("+br.x+":"+br.y+") pane", tl, br, SColor(0xFFFF0000));
  }
  GUI::DrawRectangle(tl, br, FUI::Colors::FRAME);
  GUI::DrawRectangle(tl + Vec2f(2, 2), br - Vec2f(2, 2), FUI::Colors::FG);
  GUI::DrawRectangle(tl + Vec2f(4, 4), br - Vec2f(4, 4), FUI::Colors::BG);
}

void _drawPaneHovered(Vec2f tl, Vec2f br) {
  if (debug_mode && getControls().mousePressed2 && _isPointInRect(getControls().getMouseScreenPos(), tl, br)) {
    _drawDebugRect("tl("+tl.x+":"+tl.y+") br("+br.x+":"+br.y+") pane hovered", tl, br, SColor(0xFF00FF00));
  }
  GUI::DrawRectangle(tl, br, FUI::Colors::FG);
  GUI::DrawRectangle(tl + Vec2f(4, 4), br - Vec2f(4, 4), FUI::Colors::BG);
}

void _drawPanePressed(Vec2f tl, Vec2f br) {
  if (debug_mode && getControls().mousePressed2 && _isPointInRect(getControls().getMouseScreenPos(), tl, br)) {
    _drawDebugRect("tl("+tl.x+":"+tl.y+") br("+br.x+":"+br.y+") pane pressed", tl, br, SColor(0xFF0000FF));
  }
  GUI::DrawRectangle(tl, br, FUI::Colors::FRAME);
  GUI::DrawRectangle(tl + Vec2f(2, 2), br - Vec2f(2, 2), FUI::Colors::FRAME);
  GUI::DrawRectangle(tl + Vec2f(4, 4), br - Vec2f(4, 4), FUI::Colors::BG);
}

void _drawTextCentered(string text, Vec2f tl, Vec2f br) {
  Vec2f dim = Vec2f(0,0);
  GUI::GetTextDimensions(text, dim);
  GUI::DrawText(text, tl + Vec2f(Maths::Floor(br.x - tl.x - dim.x) / 2 - 0.49, (br.y - tl.y - dim.y) / 2 - 1.49), FUI::Colors::FG);
}

/*
void GUI::DrawText(const string&in text, Vec2f upperleft, Vec2f lowerright, SColor color, bool HorCenter, bool VerCenter, bool drawBackgroundPane)
void GUI::DrawText(const string&in text, Vec2f upperleft, Vec2f lowerright, SColor color, bool HorCenter, bool VerCenter)
void GUI::DrawText(const string&in text, Vec2f pos, SColor color)
*/

class Canvas {
  Vec2f canvas_tl = Vec2f(0, 0);
  Vec2f canvas_br = Vec2f(0, 0);

  u32 _button_current = 0;
  u32 _button_hovered = 0;
  u32 _button_hovered_frame = 0;
  u32 _slider_current = 0;
  u32 _slider_selected = 0;

  CControls@ _controls = getControls();
  bool _now_press = false;
  bool _was_press = false;
  Vec2f _mouse_pos = Vec2f(0, 0);
  Vec2f _mouse_pos_old = Vec2f(0, 0);

  string _tooltip = "";
  AnimationRect _tooltip_rect_anim();
  AnimationText _tooltip_text_anim();

  void begin(Vec2f tl = Vec2f(0, 0), Vec2f br = Vec2f(getScreenWidth(), getScreenHeight()), FUI::Alignment alignment = FUI::Alignment::TL) {
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
    _slider_current = 0;

    if(_controls !is null) {
      _was_press = _now_press;
      _now_press = _controls.mousePressed1;
      _mouse_pos_old = _mouse_pos;
      _mouse_pos = _controls.getMouseScreenPos();
    }

    _tooltip = "";
  }

  void end() {
    if (_tooltip != "") {
      Vec2f tooltip_dim;
      GUI::GetTextDimensions(_tooltip, tooltip_dim);
      _tooltip_rect_anim.tl_start = Vec2f(_mouse_pos + Vec2f(32, 0));
      _tooltip_rect_anim.br_start = Vec2f(_mouse_pos + Vec2f(32, 28));
      _tooltip_rect_anim.tl_end = Vec2f(_mouse_pos + Vec2f(32, 0));
      _tooltip_rect_anim.br_end = Vec2f(_mouse_pos + Vec2f(32 + tooltip_dim.x + 12, 28));
      _tooltip_rect_anim.duration = 10;
      _tooltip_rect_anim.play();
      _tooltip_text_anim.text = "";
      _tooltip_text_anim.result = "";
      _tooltip_text_anim.duration = 20;
      _tooltip_text_anim.play();
      _tooltip_text_anim.result = _tooltip;
      _tooltip_text_anim.play();
      if (_tooltip_text_anim.isPlayOrEnd()) {
        _drawPane(_tooltip_rect_anim.tl, _tooltip_rect_anim.br);
        GUI::DrawText(_tooltip_text_anim.text, _mouse_pos + Vec2f(32 + 4, 4), FUI::Colors::FG);
      }
    }
    GUI::SetFont("menu");
  }

  Vec2f getSize() {
    return canvas_br - canvas_tl;
  }

  void drawPane(Vec2f tl, Vec2f br) {
    _drawPane(canvas_tl + tl, canvas_tl + br);
  }

  void drawText(string text, Vec2f pos) {
    GUI::DrawText(text, canvas_tl + pos, FUI::Colors::FG);
  }

  void drawTextCentered(string text, Vec2f tl, Vec2f br) {
    _drawTextCentered(text, canvas_tl + tl, canvas_tl + br);
  }

  void drawIcon(FUI::Icons icon, Vec2f pos) {
    switch (icon) {
      case GEAR:
        GUI::DrawIconDirect(ICONS_FILENAME, pos, _ICON_GEAR_FRAME_POS, _ICON_GEAR_FRAME_DIMENSIONS);
        break;
    }
  }

  bool drawButton(Vec2f tl, Vec2f br, string tooltip = "") {
    _button_current += 1;
    tl += canvas_tl;
    br += canvas_tl;
    if (_isPointInRect(_mouse_pos, tl, br)) { // hovered
      if (_isPress()) { // pressed
        _button_hovered_frame = 0;
        _drawPanePressed(tl, br);
        if (_isJustPressed()) {
          Sound::Play("FUI_Pressed.ogg");
          return true;
        }
      } else { // Hovered
        _drawPaneHovered(tl, br);
      }

      if (_button_hovered == _button_current) {
        if (_mouse_pos != _mouse_pos_old) _button_hovered_frame = 0;
        _button_hovered_frame += 60 * getRenderDeltaTime();
        if (_button_hovered_frame > 80 and tooltip != "" and !_isPress()) {
          _tooltip = tooltip;
          _tooltip_rect_anim.frame = _button_hovered_frame - 80;
          _tooltip_text_anim.frame = _button_hovered_frame - 80;
        }
      } else {
        _button_hovered_frame = 0;
        _button_hovered = _button_current;
        //Sound::Play("FUI_Hovered.ogg");
      }
    } else { // Normal
      _drawPane(tl, br);
      if (_button_hovered == _button_current) _button_hovered = 0;
    }
    return false;
  }

  bool drawToggle(bool value, Vec2f pos, string tooltip = "") {
    if (value) {
      if(drawButton(pos, pos + Vec2f(16, 16), tooltip)) value = !value;
      GUI::DrawRectangle(canvas_tl + pos + Vec2f(6,6), canvas_tl + pos + Vec2f(10,10), FUI::Colors::FG);
    } else {
      if(drawButton(pos, pos + Vec2f(16, 16), tooltip)) value = !value;
    }
    return value;
  }

  float drawSlider(float value, Vec2f tl, Vec2f br, float min = 0, float max = 1, float step = 0.001, string tooltip = "") {
    _slider_current += 1;

    tl += canvas_tl;
    br += canvas_tl;

    Vec2f value_dim;
    GUI::GetTextDimensions(formatFloat(max, "", 0, 2), value_dim);
    int value_w = value_dim.x + 16;
    if (_slider_selected == _slider_current) {
      GUI::DrawRectangle(tl, br, FUI::Colors::FRAME);
      GUI::DrawRectangle(tl + Vec2f(2, 2), br - Vec2f(2, 2), FUI::Colors::FRAME);
      GUI::DrawRectangle(tl + Vec2f(4, 4), br - Vec2f(4, 4), FUI::Colors::BG);
        value = (Maths::Clamp(_mouse_pos.x, tl.x + value_w / 2, br.x - value_w / 2) - tl.x - value_w / 2) / (br.x - tl.x - value_w) * (max - min) + min;
        if ((value % step) > (step / 2)) value += (step - value % step);
        else value -= value % step;
        if (_isJustReleased()) {
            _slider_selected = 0;
        }
    } else if (drawButton(tl - canvas_tl, br - canvas_tl, tooltip)) {
        _slider_selected = _slider_current;
    }
    Vec2f value_tl = Vec2f(tl.x + (br.x - tl.x - value_w) * (value - min) / (max - min), tl.y);
    Vec2f value_br = Vec2f(tl.x + (br.x - tl.x - value_w) * (value - min) / (max - min) + value_w, br.y);
    drawPane(value_tl - canvas_tl, value_br - canvas_tl);
    drawTextCentered(formatFloat(value, "", 0, 2), value_tl - canvas_tl, value_br - canvas_tl);
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

class Animation {
  f32 frame = 0;
  f32 duration = 0;

  bool isStart() {
    return frame <= 0;
  }

  bool isEnd() {
    return frame >= duration;
  }

  bool isPlay() {
    return frame > 0 and frame < duration;
  }

  bool isPlayOrEnd() {
    return frame > 0;
  }
}

class AnimationRect : Animation {
  Vec2f tl = Vec2f(0, 0);
  Vec2f br = Vec2f(0, 0);
  Vec2f tl_start = Vec2f(0, 0);
  Vec2f br_start = Vec2f(0, 0);
  Vec2f tl_end = Vec2f(0, 0);
  Vec2f br_end = Vec2f(0, 0);

  void play() {
    tl = tl_end;
    br = br_end;
    if (isEnd()) return;
    // time (0.0 - 1.0)
    f32 t = frame / duration;
    // bezier curve math for beutiful animation
    Vec2f tl_temp0 = Vec2f_lerp(tl_start, tl_end, t);
    Vec2f tl_temp1 = Vec2f_lerp(tl_start, tl_temp0, t);
    Vec2f tl_temp2 = Vec2f_lerp(tl_temp0, tl_end, t);
    tl = Vec2f_lerp(tl_temp1, tl_temp2, t);
    Vec2f br_temp0 = Vec2f_lerp(br_start, br_end, t);
    Vec2f br_temp1 = Vec2f_lerp(br_start, br_temp0, t);
    Vec2f br_temp2 = Vec2f_lerp(br_temp0, br_end, t);
    br = Vec2f_lerp(br_temp1, br_temp2, t);
    frame = Maths::Min(frame + 60 * getRenderDeltaTime(), duration);
  }

  void playReverse() {
    tl = tl_start;
    br = br_start;
    if (isStart()) return;
    // time (0.0 - 1.0)
    f32 t = frame / duration;
    // bezier curve math for beutiful animation
    Vec2f tl_temp0 = Vec2f_lerp(tl_start, tl_end, t);
    Vec2f tl_temp1 = Vec2f_lerp(tl_start, tl_temp0, t);
    Vec2f tl_temp2 = Vec2f_lerp(tl_temp0, tl_end, t);
    tl = Vec2f_lerp(tl_temp1, tl_temp2, t);
    Vec2f br_temp0 = Vec2f_lerp(br_start, br_end, t);
    Vec2f br_temp1 = Vec2f_lerp(br_start, br_temp0, t);
    Vec2f br_temp2 = Vec2f_lerp(br_temp0, br_end, t);
    br = Vec2f_lerp(br_temp1, br_temp2, t);
    frame = Maths::Max(frame - 60 * getRenderDeltaTime(), 0);
  }
}

class AnimationText : Animation {
  string text = "";
  string result = "";

  void play() {
    text = result;
    if (isEnd()) return;
    text.resize(Maths::Lerp(0, result.length(), frame / duration));
    text += "█";
    frame = Maths::Min(frame + 60 * getRenderDeltaTime(), duration);
    Sound::Play("FUI_Write.ogg");
  }

  void playReverse() {
    text = "";
    if (isStart()) return;
    text = result;
    text.resize(Maths::Lerp(0, result.length(), frame / duration));
    text += "█";
    frame = Maths::Max(frame - 60 * getRenderDeltaTime(), 0);
    Sound::Play("FUI_Delete.ogg");
  }
}

}
