#define CLIENT_ONLY

#include "FUI.as";

const s32 WINDOW_TITLE_H = 28;

FUI::Canvas canvas_settings();
FUI::Canvas canvas_buttons();

FUI::AnimationRect settings_anim_rect_canvas();
FUI::AnimationRect settings_anim_rect_title();
FUI::AnimationRect settings_anim_rect_sound_modifier();
    
FUI::AnimationText settings_anim_text_title();
FUI::AnimationText settings_anim_text_mute_messages();

bool is_open_menu_settings = false;

bool toggle_mute_messages = false;
f32 volume_modifier = 0.5;

void onInit(CRules@ rules) {
  onRestart(rules);
}

void onRestart(CRules@ rules) {
  is_open_menu_settings = false;
  SettingsAnimationReset();
}

void onRender(CRules@ this) {
  canvas_buttons.begin();
  // Button Open/Close Settings
  if (canvas_buttons.drawButton(Vec2f(16, 16), Vec2f(52, 52))) {
    is_open_menu_settings = !is_open_menu_settings;
  }
  canvas_buttons.drawIcon(FUI::Icons::GEAR, Vec2f(18, 18));
  canvas_buttons.end();

  canvas_settings.begin(Vec2f(-200, -200), Vec2f(200, 200), FUI::Alignment::CC);
  if (is_open_menu_settings) {
    settings_anim_rect_title.play();
    if (settings_anim_rect_title.isEnd()) {
      settings_anim_rect_canvas.play();
      settings_anim_text_title.play();
      if (settings_anim_rect_canvas.isEnd()) {
        settings_anim_text_mute_messages.play();
        settings_anim_rect_sound_modifier.play();
      }
    }
  } else {
    settings_anim_rect_sound_modifier.playReverse();
    settings_anim_text_mute_messages.playReverse();
    if (settings_anim_text_mute_messages.isStart()) {
      settings_anim_rect_canvas.playReverse();
      settings_anim_text_title.playReverse();
      if (settings_anim_rect_canvas.isStart()) {
        settings_anim_rect_title.playReverse();
      }
    }
  }
  if (settings_anim_rect_canvas.isPlayOrEnd())
    canvas_settings.drawPane(settings_anim_rect_canvas.tl, settings_anim_rect_canvas.br);
  if (settings_anim_rect_title.isPlayOrEnd())
    canvas_settings.drawPane(settings_anim_rect_title.tl, settings_anim_rect_title.br);
  if (settings_anim_text_mute_messages.isPlayOrEnd())
    toggle_mute_messages = canvas_settings.drawToggle(toggle_mute_messages, Vec2f(8, 32));
  if (settings_anim_text_title.isPlayOrEnd())
    canvas_settings.drawTextCentered(settings_anim_text_title.text, Vec2f(0, 0), Vec2f(canvas_settings.getSize().x, WINDOW_TITLE_H));
  if (settings_anim_text_mute_messages.isPlayOrEnd())
    canvas_settings.drawText(settings_anim_text_mute_messages.text, Vec2f(28, WINDOW_TITLE_H + 3));
  if (settings_anim_rect_sound_modifier.isPlayOrEnd())
    volume_modifier = canvas_settings.drawSliderFloat(volume_modifier, settings_anim_rect_sound_modifier.tl, settings_anim_rect_sound_modifier.br);

  canvas_settings.end();
}

void SettingsAnimationReset() {
  settings_anim_rect_title.tl_start = Vec2f(canvas_settings.getSize().x / 2, 0);
  settings_anim_rect_title.br_start = Vec2f(canvas_settings.getSize().x / 2, WINDOW_TITLE_H);
  settings_anim_rect_title.tl_end = Vec2f(0, 0);
  settings_anim_rect_title.br_end = Vec2f(canvas_settings.getSize().x, WINDOW_TITLE_H);
  settings_anim_rect_title.duration = 20;
  settings_anim_rect_title.frame = 0;
  settings_anim_rect_canvas.tl_start = settings_anim_rect_title.tl_end;
  settings_anim_rect_canvas.br_start = settings_anim_rect_title.br_end;
  settings_anim_rect_canvas.tl_end = settings_anim_rect_title.tl_end;
  settings_anim_rect_canvas.br_end = canvas_settings.getSize();
  settings_anim_rect_canvas.duration = 20;
  settings_anim_rect_canvas.frame = 0;
  settings_anim_text_title.text = "";
  settings_anim_text_title.result = "S.E.T.T.I.N.G.S";
  settings_anim_text_title.duration = 20;
  settings_anim_text_title.frame = 0;
  settings_anim_text_mute_messages.text = "";
  settings_anim_text_mute_messages.result = "Mute messages";
  settings_anim_text_mute_messages.duration = 15;
  settings_anim_text_mute_messages.frame = 0;
  settings_anim_rect_sound_modifier.tl_start = Vec2f(8, 56);
  settings_anim_rect_sound_modifier.br_start = Vec2f(48, 82);
  settings_anim_rect_sound_modifier.tl_end = Vec2f(8, 56);
  settings_anim_rect_sound_modifier.br_end = Vec2f(canvas_settings.getSize().x / 2, 82);
  settings_anim_rect_sound_modifier.duration = 15;
  settings_anim_rect_sound_modifier.frame = 0;
}

/*
ConfigFile
  <constructor>()
  <constructor>(const string&in)
  ConfigFile& opAssign(const ConfigFile&in)
  bool loadFile(string file)
  bool saveFile(string file)
  void remove(const string&in key)
  bool exists(const string&in key)
  void add_f32(string key, const float&in value)
  void addArray_f32(string key, const float[]&in arr)
  float read_f32(const string&in key)
  float read_f32(const string&in key, const float&in value)
  bool readIntoArray_f32(float[]&inout arr, const string&in key)
  void add_u16(string key, const uint16&in value)
  void addArray_u16(string key, const uint16[]&in arr)
  uint16 read_u16(const string&in key)
  uint16 read_u16(const string&in key, const uint16&in value)
  bool readIntoArray_u16(uint16[]&inout arr, const string&in key)
  void add_s16(string key, const int16&in value)
  void addArray_s16(string key, const int16[]&in arr)
  int16 read_s16(const string&in key)
  int16 read_s16(const string&in key, const int16&in value)
  bool readIntoArray_s16(int16[]&inout arr, const string&in key)
  void add_u32(string key, const uint&in value)
  void addArray_u32(string key, const uint[]&in arr)
  uint read_u32(const string&in key)
  uint read_u32(const string&in key, const uint&in value)
  bool readIntoArray_u32(uint[]&inout arr, const string&in key)
  void add_s32(string key, const int&in value)
  void addArray_s32(string key, const int[]&in arr)
  int read_s32(const string&in key)
  int read_s32(const string&in key, const int&in value)
  bool readIntoArray_s32(int[]&inout arr, const string&in key)
  void add_u8(string key, const uint8&in value)
  void addArray_u8(string key, const uint8[]&in arr)
  uint8 read_u8(const string&in key)
  uint8 read_u8(const string&in key, const uint8&in value)
  bool readIntoArray_u8(uint8[]&inout arr, const string&in key)
  void add_s8(string key, const int8&in value)
  void addArray_s8(string key, const int8[]&in arr)
  int8 read_s8(const string&in key)
  int8 read_s8(const string&in key, const int8&in value)
  bool readIntoArray_s8(int8[]&inout arr, const string&in key)
  void add_bool(string key, const bool&in value)
  void addArray_bool(string key, const bool[]&in arr)
  bool read_bool(const string&in key)
  bool read_bool(const string&in key, const bool&in value)
  bool readIntoArray_bool(bool[]&inout arr, const string&in key)
  void add_string(string key, const string&in value)
  void addArray_string(string key, const string[]&in arr)
  string read_string(const string&in key)
  string read_string(const string&in key, const string&in value)
  bool readIntoArray_string(string[]&inout arr, const string&in key)
  void ExtractToBitStream(CBitStream&inout bt)
 */
