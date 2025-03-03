#define CLIENT_ONLY

/*

  FUI (Futurism UI)

  Developed by kussakaa

  Februar 2025

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


void _drawPaneGeneral(Vec2f tl, Vec2f br) {
  GUI::DrawRectangle(tl, br, FUI::Colors::FRAME);
  GUI::DrawRectangle(tl + Vec2f(2, 2), br - Vec2f(2, 2), FUI::Colors::FG);
  GUI::DrawRectangle(tl + Vec2f(4, 4), br - Vec2f(4, 4), FUI::Colors::BG);
}

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
    }
  }

  void end() {
    GUI::SetFont("menu");
  }

  Vec2f getSize() {
    return canvas_br - canvas_tl;
  }

  void drawPane(Vec2f tl, Vec2f br) {
    _drawPaneGeneral(canvas_tl + tl, canvas_tl + br);
  }

  void drawText(string text, Vec2f pos, SColor color = FUI::Colors::FG) {
    GUI::DrawText(text, canvas_tl + pos, color);
  }

  void drawTextCentered(string text, Vec2f tl, Vec2f br, SColor color = FUI::Colors::FG) {
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

  bool drawButton(Vec2f tl, Vec2f br, string tooltip = "") {
    _button_current += 1;
    tl += canvas_tl;
    br += canvas_tl;
    Vec2f cpos = _controls.getMouseScreenPos();
    if (cpos.x > tl.x && cpos.x < br.x && cpos.y > tl.y && cpos.y < br.y) {
      if (_isPress()) { // Pressed
        GUI::DrawRectangle(tl, br, FUI::Colors::FRAME);
        GUI::DrawRectangle(tl + Vec2f(2, 2), br - Vec2f(2, 2), FUI::Colors::FRAME);
        GUI::DrawRectangle(tl + Vec2f(4, 4), br - Vec2f(4, 4), FUI::Colors::BG);
        if (_isJustPressed()) {
          Sound::Play("FUI_Pressed.ogg");
          return true;
        }
      } else { // Hovered
        GUI::DrawRectangle(tl, br, FUI::Colors::FG);
        GUI::DrawRectangle(tl + Vec2f(4, 4), br - Vec2f(4, 4), FUI::Colors::BG);
      }

      if (_button_hovered == _button_current) {
        _button_hovered_frame += 1;
        if (_button_hovered_frame > 80 and tooltip != "") {
          Vec2f tooltip_dim;
          GUI::GetTextDimensions(tooltip, tooltip_dim);
          AnimationRect tooltip_rect_anim();
          tooltip_rect_anim.tl_start = Vec2f(cpos + Vec2f(32, 0));
          tooltip_rect_anim.br_start = Vec2f(cpos + Vec2f(32, 28));
          tooltip_rect_anim.tl_end = Vec2f(cpos + Vec2f(32, 0));
          tooltip_rect_anim.br_end = Vec2f(cpos + Vec2f(32 + tooltip_dim.x + 12, 28));
          tooltip_rect_anim.duration = 10;
          tooltip_rect_anim.frame = Maths::Min(_button_hovered_frame - 80, 20);
          tooltip_rect_anim.play();
          AnimationText tooltip_text_anim();
          tooltip_text_anim.text = "";
          tooltip_text_anim.result = tooltip;
          tooltip_text_anim.duration = 20;
          tooltip_text_anim.frame = Maths::Min(_button_hovered_frame - 80, 20);
          tooltip_text_anim.play();
          if (tooltip_text_anim.isPlayOrEnd()) {
            _drawPaneGeneral(tooltip_rect_anim.tl, tooltip_rect_anim.br);
            GUI::DrawText(tooltip_text_anim.text, cpos + Vec2f(32 + 4, 4), FUI::Colors::FG);
          }
        }
      } else {
        _button_hovered = _button_current;
        _button_hovered_frame = 0;
        //Sound::Play("FUI_Hovered.ogg");
      }
    } else { // Normal
      GUI::DrawRectangle(tl, br, FUI::Colors::FRAME);
      GUI::DrawRectangle(tl + Vec2f(2, 2), br - Vec2f(2, 2), FUI::Colors::FG);
      GUI::DrawRectangle(tl + Vec2f(4, 4), br - Vec2f(4, 4), FUI::Colors::BG);
      if (_button_hovered == _button_current) _button_hovered = 0;
    }
    return false;
  }

  bool drawToggle(bool value, Vec2f pos) {
    if (value) {
      if(drawButton(pos, pos + Vec2f(16, 16))) value = !value;
      GUI::DrawRectangle(canvas_tl + pos + Vec2f(6,6), canvas_tl + pos + Vec2f(10,10), FUI::Colors::FG);
    } else {
      if(drawButton(pos, pos + Vec2f(16, 16))) value = !value;
    }
    return value;
  }

  float drawSlider(float value, Vec2f tl, Vec2f br, float min = 0, float max = 1, float step = 0.05) {
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
        value = (Maths::Clamp(_controls.getMouseScreenPos().x, tl.x + value_w / 2, br.x - value_w / 2) - tl.x - value_w / 2) / (br.x - tl.x - value_w) * (max - min) + min;
        if ((value % step) > (step / 2)) value += (step - value % step);
        else value -= value % step;
        if (_isJustReleased()) {
            _slider_selected = 0;
        }
    } else if (drawButton(tl - canvas_tl, br - canvas_tl)) {
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
    frame = Maths::Min(frame + 1, duration);
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
    frame = Maths::Max(frame - 1, 0);
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
    frame = Maths::Min(frame + 1, duration);
    Sound::Play("FUI_Write.ogg");
  }

  void playReverse() {
    text = "";
    if (isStart()) return;
    text = result;
    text.resize(Maths::Lerp(0, result.length(), frame / duration));
    text += "█";
    frame = Maths::Max(frame - 1, 0);
    Sound::Play("FUI_Delete.ogg");
  }
}

}