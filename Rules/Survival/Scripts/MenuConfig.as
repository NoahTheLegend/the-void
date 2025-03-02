#define CLIENT_ONLY

#include "FUI.as";

const string CACHE_DIR = "../Cache/";
const string SETTINGS_FILE = "VOIDMOD_settings";

const s32 SPACING_W = 8;
const s32 SPACING_H = 4;
const s32 TEXT_H = 20;
const s32 LABEL_H = 28;

FUI::Canvas canvas_buttons();
FUI::Canvas canvas_settings();

FUI::AnimationRect settings_anim_rect_canvas();
FUI::AnimationRect settings_anim_rect_save();
FUI::AnimationText settings_anim_text_save();
FUI::AnimationRect settings_anim_rect_title();
FUI::AnimationText settings_anim_text_title();
FUI::AnimationText settings_anim_text_messages_mute();
FUI::AnimationRect settings_anim_rect_messages_volume();

bool settings_is_open = false;
bool messages_mute = false;
f32 messages_volume = 0.5;

void onInit(CRules@ rules) {
  SettingsLoad();
  SettingsAnimationReset();
}

void onRestart(CRules@ rules) {
  SettingsAnimationReset();
}

void onReload(CRules @rules) {
  SettingsAnimationReset();
}

void onRender(CRules@ this) {
  canvas_buttons.begin();
  if (canvas_buttons.drawButton(Vec2f(16, 16), Vec2f(52, 52), "Open mod settings")) {
    settings_is_open = !settings_is_open;
  }
  canvas_buttons.drawIcon(FUI::Icons::GEAR, Vec2f(18, 18));
  canvas_buttons.end();

  canvas_settings.begin(Vec2f(-200, -200), Vec2f(200, 200), FUI::Alignment::CC);
  if (settings_is_open) {
    settings_anim_rect_title.play();
    if (settings_anim_rect_title.isEnd()) {
      settings_anim_rect_canvas.play();
      settings_anim_rect_save.play();
      settings_anim_text_title.play();
      if (settings_anim_rect_canvas.isEnd()) {
        settings_anim_text_messages_mute.play();
        settings_anim_rect_messages_volume.play();
        settings_anim_text_save.play();
      }
    }
  } else {
    settings_anim_rect_messages_volume.playReverse();
    settings_anim_text_messages_mute.playReverse();
    settings_anim_text_save.playReverse();
    if (settings_anim_text_messages_mute.isStart()) {
      settings_anim_text_title.playReverse();
      settings_anim_rect_canvas.playReverse();
      settings_anim_rect_save.playReverse();
      if (settings_anim_rect_canvas.isStart()) {
        settings_anim_rect_title.playReverse();
      }
    }
  }
  if (settings_anim_rect_canvas.isPlayOrEnd())
    canvas_settings.drawPane(settings_anim_rect_canvas.tl, settings_anim_rect_canvas.br);
  if (settings_anim_rect_save.isPlayOrEnd())
    if(canvas_settings.drawButton(settings_anim_rect_save.tl, settings_anim_rect_save.br, "Save all settings")) SettingsSave();
  if (settings_anim_rect_save.isPlayOrEnd())
    canvas_settings.drawTextCentered(settings_anim_text_save.text, settings_anim_rect_save.tl, settings_anim_rect_save.br);
  if (settings_anim_rect_title.isPlayOrEnd())
    canvas_settings.drawPane(settings_anim_rect_title.tl, settings_anim_rect_title.br);
  if (settings_anim_text_messages_mute.isPlayOrEnd())
    messages_mute = canvas_settings.drawToggle(messages_mute, Vec2f(8, LABEL_H + 6));
  if (settings_anim_text_title.isPlayOrEnd())
    canvas_settings.drawTextCentered(settings_anim_text_title.text, settings_anim_rect_title.tl, settings_anim_rect_title.br);
  if (settings_anim_text_messages_mute.isPlayOrEnd())
    canvas_settings.drawText(settings_anim_text_messages_mute.text, Vec2f(6 + 16 + 4, LABEL_H + 6));
  if (settings_anim_rect_messages_volume.isPlayOrEnd())
    messages_volume = canvas_settings.drawSlider(messages_volume, settings_anim_rect_messages_volume.tl, settings_anim_rect_messages_volume.br);

  canvas_settings.end();
}

void SettingsAnimationReset() {
  settings_is_open = false;
  settings_anim_rect_title.tl_start = Vec2f(canvas_settings.getSize().x / 2, 0);
  settings_anim_rect_title.br_start = Vec2f(canvas_settings.getSize().x / 2, LABEL_H);
  settings_anim_rect_title.tl_end = Vec2f(0, 0);
  settings_anim_rect_title.br_end = Vec2f(canvas_settings.getSize().x, LABEL_H);
  settings_anim_rect_title.duration = 20;
  settings_anim_rect_title.frame = 0;
  settings_anim_text_title.text = "";
  settings_anim_text_title.result = "S.E.T.T.I.N.G.S";
  settings_anim_text_title.duration = 20;
  settings_anim_text_title.frame = 0;
  settings_anim_rect_canvas.tl_start = settings_anim_rect_title.tl_end;
  settings_anim_rect_canvas.br_start = settings_anim_rect_title.br_end;
  settings_anim_rect_canvas.tl_end = settings_anim_rect_title.tl_end;
  settings_anim_rect_canvas.br_end = canvas_settings.getSize();
  settings_anim_rect_canvas.duration = 20;
  settings_anim_rect_canvas.frame = 0;
  settings_anim_rect_save.tl_start = settings_anim_rect_title.tl_end;
  settings_anim_rect_save.br_start = settings_anim_rect_title.br_end;
  settings_anim_rect_save.tl_end = Vec2f(0, canvas_settings.getSize().y - LABEL_H);
  settings_anim_rect_save.br_end = canvas_settings.getSize();
  settings_anim_rect_save.duration = 20;
  settings_anim_rect_save.frame = 0;
  settings_anim_text_save.text = "";
  settings_anim_text_save.result = "S.A.V.E";
  settings_anim_text_save.duration = 10;
  settings_anim_rect_save.frame = 0;
  settings_anim_text_messages_mute.text = "";
  settings_anim_text_messages_mute.result = "Mute messages";
  settings_anim_text_messages_mute.duration = 15;
  settings_anim_text_messages_mute.frame = 0;
  settings_anim_rect_messages_volume.tl_start = Vec2f(8, LABEL_H + TEXT_H + 8);
  settings_anim_rect_messages_volume.br_start = Vec2f(48, LABEL_H + TEXT_H + LABEL_H + 8);
  settings_anim_rect_messages_volume.tl_end = Vec2f(8, LABEL_H + TEXT_H + 8);
  settings_anim_rect_messages_volume.br_end = Vec2f(canvas_settings.getSize().x / 2, LABEL_H + TEXT_H + LABEL_H + 8);
  settings_anim_rect_messages_volume.duration = 15;
  settings_anim_rect_messages_volume.frame = 0;
}

void SettingsLoad() {
  ConfigFile config_file;
  if (config_file.loadFile(CACHE_DIR + SETTINGS_FILE)) {
    if (config_file.exists("messages_mute"))
      messages_mute = config_file.read_bool("messages_mute");
    if (config_file.exists("messages_volume"))
      messages_volume = config_file.read_f32("messages_volume");
  }
}

void SettingsSave() {
  ConfigFile config_file;
  config_file.add_bool("messages_mute", messages_mute);
  config_file.add_f32("messages_volume", messages_volume);
  config_file.saveFile(SETTINGS_FILE + ".cfg");
}
