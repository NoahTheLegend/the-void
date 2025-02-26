#define CLIENT_ONLY

namespace KUI {

////////////// CONTSANTS //////////////
const int WINDOW_TITLE_H = 24;

////////////// COLORS //////////////
namespace Colors {
  const SColor BACKGROUND = SColor(0xFF000000);
  const SColor FOREGROUND = SColor(0xFFFFFFFF);
  const SColor ERROR = SColor(0xFFFF0000);
}

////////////// INPUT //////////////
namespace Input {
  CControls@ controls = getControls();

  bool _now_press = false;
  bool _was_press = false;

  void Update() {
    if(controls is null) return;
    _was_press = _now_press;
    _now_press = controls.mousePressed1;
  }

  bool IsPress() {
    return _now_press;
  }

  bool IsJustPressed() {
    return (_now_press and !_was_press) ? true : false;
  }

  bool IsJustReleased() {
    return (!_now_press and _was_press) ? true : false;
  }

  Vec2f GetCursorPos() {
    return controls.getMouseScreenPos();
  }

  void  SetCursorPos(Vec2f pos) {
    controls.setMousePosition(pos);
  }
}

////////////// VARIABLES //////////////

// Screen space //
Vec2f screen_tl = Vec2f_zero;
Vec2f screen_br = Vec2f_zero;

////////////// ENUMS //////////////

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

////////////// CLASSES //////////////

class AnimationRectangle {
  Vec2f tl = Vec2f(0, 0);
  Vec2f br = Vec2f(0, 0);
  Vec2f tl_start = Vec2f(0, 0);
  Vec2f br_start = Vec2f(0, 0);
  Vec2f tl_end = Vec2f(0, 0);
  Vec2f br_end = Vec2f(0, 0);
  float frame = 0;
  float duration = 10;

  void play() {
    float t = frame / duration;

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
  float frame = 0;
  float duration = 10;

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

////////////// FUNCTIONS //////////////
 
void Begin(Vec2f tl = Vec2f_zero, Vec2f br = Vec2f(getScreenWidth(), getScreenHeight())) {
  GUI::SetFont("Terminus_14");
  KUI::Input::Update();

  screen_tl = tl;
  screen_br = br;
}

void End() {
  GUI::SetFont("menu");

  screen_tl = Vec2f_zero;
  screen_br = Vec2f_zero;
}

void DrawPane(Vec2f tl, Vec2f br, Alignment alignment = Alignment::TL) {
  tl = Align(alignment, tl);
  br = Align(alignment, br);
  GUI::DrawRectangle(tl, br, Colors::FOREGROUND);
  GUI::DrawRectangle(tl + Vec2f(2, 2), br - Vec2f(2, 2), Colors::BACKGROUND);
}

void DrawText(string text, Vec2f pos, SColor color = Colors::FOREGROUND, Alignment alignment = Alignment::TL) {
  pos = Align(alignment, pos);
  GUI::DrawText(text, pos, color);
}

void DrawTextRectCentered(string text, Vec2f tl, Vec2f br, SColor color = Colors::FOREGROUND, Alignment alignment = Alignment::TL) {
  tl = Align(alignment, tl);
  br = Align(alignment, br);
  Vec2f dim = Vec2f(0,0);
  GUI::GetTextDimensions(text, dim);
  GUI::DrawText(text, tl + Vec2f((br.x - tl.x) / 2 - dim.x / 2 - 2, (br.y - tl.y) / 2 - dim.y / 2 - 2), color);
}

Vec2f Align(Alignment alignment, Vec2f pos) {
  Vec2f screen_sz = screen_br - screen_tl;
  switch (alignment) {
    case TL:
      break;
    case TC:
      break;
    case TR:
      break;
    case CL:
      break;
    case CC:
      pos = screen_sz / 2 + pos;
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
  return pos;
}

}
 
