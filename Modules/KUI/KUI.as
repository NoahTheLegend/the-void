#define CLIENT_ONLY

namespace KUI {

////////////// CONTSANTS //////////////
const string    icons = "KUI_Icons.png";
const int       window_title_h = 24;
const Vec2f     window_inner_margin = Vec2f(8, 2);
const int       window_close_icon = 16;
const Vec2f     window_close_icon_size = Vec2f(8,8);
const int       tab_h = 24;
const int       text_h = 16;
const int       button_h = 24;
const int       toggle_h = 16;
const int       toggle_icon_t = 0;
const int       toggle_icon_f = 4;
const Vec2f     toggle_icon_sz = Vec2f(8,8);
const int       stepper_h = 16;
const int       stepper_icon_l = 8;
const int       stepper_icon_r = 12;
const Vec2f     stepper_icon_sz = Vec2f(8,8);
const int       slider_h = 24;
const int       dragger_h = 24;
const int       keybind_h = 24;
const int       keybind_w = 160;
const int       spacing = 2;

////////////// COLORS //////////////
namespace Colors {
    const SColor FOREGROUND = SColor(0xFFE5E1D8);
    const SColor BACKGROUND = SColor(0xFF1F1F1F);
    const SColor BLACK = SColor(0xFF000000);
    const SColor RED = SColor(0xFFF7786D);
    const SColor GREEN = SColor(0xFFBDE97C);
    const SColor YELLOW = SColor(0xFFEFDFAC);
    const SColor BLUE = SColor(0xFF6EBAf8);
    const SColor MAGENTA = SColor(0xFFEf88FF);
    const SColor CYAN = SColor(0xFF90FDF8);
    const SColor WHITE = SColor(0xFFE5E1D8);
}

////////////// INPUT //////////////
namespace Input {
    CControls@      controls = getControls();

    bool            _now_press = false;
    bool            _was_press = false;

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
    tl = Vec2f_lerp(tl_start, tl_end, frame / duration);
    br = Vec2f_lerp(br_start, br_end, frame / duration);
    frame = Maths::Min(frame + 1, duration);
  }

  bool isEnd() {
    return frame == duration;
  }
}

class AnimationText {
  string text = "";
  string result = "";
  float frame = 0;
  float duration = 10;

  void play() {
    text = result;
    text.resize(Maths::Lerp(0, result.length(), frame / duration));
    frame = Maths::Min(frame + 1, duration);
  }

  bool isEnd() {
    return frame == duration;
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
    Vec2f screen_sz = screen_br - screen_tl;
    switch (alignment) {
      case TL:
        break;
      case TC:
        //window_tl = Vec2f(screen_sz.x / 2 - size.x / 2, 0);
        //window_br = Vec2f(screen_sz.x / 2 + size.x / 2, size.y);
        break;
      case TR:
        //window_tl = Vec2f(screen_sz.x - size.x, 0);
        //window_br = Vec2f(screen_sz.x, size.y);
        break;
      case CL:
        //window_tl = Vec2f(0, screen_sz.y / 2 - size.y / 2);
        //window_br = Vec2f(size.x, screen_sz.y / 2 + size.y / 2);
        break;
      case CC:
        tl = screen_sz / 2 + tl;
        br = screen_sz / 2 + br;
        break;
      case CR:
        //window_tl = Vec2f(screen_sz.x - size.x, screen_sz.y / 2 - size.y / 2);
        //window_br = Vec2f(screen_sz.x, screen_sz.y / 2 + size.y / 2);
        break;
      case BL:
        //window_tl = Vec2f(0, screen_sz.y - size.y);
        //window_br = Vec2f(size.x, screen_sz.y);
        break;
      case BC:
        //window_tl = Vec2f(screen_sz.x / 2 - size.x / 2, screen_sz.y - size.y);
        //window_br = Vec2f(screen_sz.x / 2 + size.x / 2, screen_sz.y);
        break;
      case BR:
        //window_tl = screen_sz - size;
        //window_br = screen_sz;
        break;
  }

  
  GUI::DrawRectangle(tl, br, Colors::FOREGROUND);
  GUI::DrawRectangle(tl + Vec2f(2, 2), br - Vec2f(2, 2), Colors::BACKGROUND);
}

void DrawTextRectCentered(string text, Vec2f tl, Vec2f br, Alignment alignment = Alignment::TL) {
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
      tl = screen_sz / 2 + tl;
      br = screen_sz / 2 + br;
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

  Vec2f dim = Vec2f(0,0);
  GUI::GetTextDimensions(text, dim);

  GUI::DrawText(
    text,
    tl + Vec2f((br.x - tl.x) / 2 - dim.x / 2 - 2, (br.y - tl.y) / 2 - dim.y / 2 - 2),
    KUI::Colors::FOREGROUND
  );
}

}
