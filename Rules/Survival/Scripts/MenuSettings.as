#define CLIENT_ONLY

#include "FUI.as";
#include "UtilityChecks.as";

const string CACHE_DIR = "../Cache/";
const string SETTINGS_FILE = "VOIDMOD_settings";

const s32 SPACING_W = 8;
const s32 SPACING_H = 4;
const s32 TEXT_H = 20;
const s32 LABEL_H = 26;

FUI::Canvas canvas_buttons();
FUI::Canvas canvas_settings();
FUI::AnimationRect settings_anim_rect_canvas();
FUI::AnimationRect settings_anim_rect_title();
FUI::AnimationText settings_anim_text_title();
FUI::AnimationText settings_anim_text_msg_mute();
FUI::AnimationText settings_anim_text_msg_volume();
FUI::AnimationRect settings_anim_rect_msg_volume();

bool settings_is_open = false;
bool msg_mute = false;
f32 msg_volume = 0.5;

void onInit(CRules@ rules) {
  SettingsLoad();
  SettingsAnimationReset();
  FUI::debug_mode = true;
}

void onRestart(CRules@ rules) {
  SettingsAnimationReset();
}

void onReload(CRules @rules) {
  SettingsAnimationReset();
}

void onRender(CRules@ this) {

  canvas_buttons.begin();
  CBlob@ local_blob = getLocalPlayerBlob();
  CControls@ controls = getControls();

  if (canvas_buttons.drawButton(Vec2f(16, 16), Vec2f(52, 52), "Open mod settings") && (local_blob is null || !isInMenu(local_blob))) {
    settings_is_open = !settings_is_open;
    if (settings_is_open) {
      SettingsLoad();
      controls.setButtonsLock(true);
    } else {
      SettingsSave();
      controls.setButtonsLock(false);
    }
  }

  canvas_buttons.drawIcon(FUI::Icons::GEAR, Vec2f(18, 18));
  canvas_buttons.end();

  canvas_settings.begin(Vec2f(-200, -100), Vec2f(200, 100), FUI::Alignment::CC);
  if (settings_is_open) {
    settings_anim_rect_title.play();
    if (settings_anim_rect_title.isEnd()) {
      settings_anim_rect_canvas.play();
      settings_anim_text_title.play();
      if (settings_anim_rect_canvas.isEnd()) {
        settings_anim_text_msg_mute.play();
        settings_anim_text_msg_volume.play();
        settings_anim_rect_msg_volume.play();
      }
    }
  } else {
    settings_anim_rect_msg_volume.playReverse();
    settings_anim_text_msg_volume.playReverse();
    settings_anim_text_msg_mute.playReverse();
    if (settings_anim_text_msg_mute.isStart()) {
      settings_anim_text_title.playReverse();
      settings_anim_rect_canvas.playReverse();
      if (settings_anim_rect_canvas.isStart()) {
        settings_anim_rect_title.playReverse();
      }
    }
  }

  if (settings_anim_rect_canvas.isPlayOrEnd())
    canvas_settings.drawPane(settings_anim_rect_canvas.tl, settings_anim_rect_canvas.br);
  if (settings_anim_rect_title.isPlayOrEnd())
    canvas_settings.drawPane(settings_anim_rect_title.tl, settings_anim_rect_title.br);
  if (settings_anim_text_title.isPlayOrEnd())
    canvas_settings.drawTextCentered(settings_anim_text_title.text, settings_anim_rect_title.tl, settings_anim_rect_title.br);
  if (settings_anim_text_msg_mute.isPlayOrEnd())
    msg_mute = canvas_settings.drawToggle(msg_mute, Vec2f(8, settings_anim_rect_title.br.y + 6));
  if (settings_anim_text_msg_mute.isPlayOrEnd())
    canvas_settings.drawText(settings_anim_text_msg_mute.text, Vec2f(8 + 16 + 4, settings_anim_rect_title.br.y + 4));
  if (settings_anim_text_msg_volume.isPlayOrEnd())
    canvas_settings.drawText(settings_anim_text_msg_volume.text, Vec2f(8, settings_anim_rect_title.br.y + TEXT_H + 4));
  if (settings_anim_rect_msg_volume.isPlayOrEnd())
    msg_volume = canvas_settings.drawSlider(msg_volume, settings_anim_rect_msg_volume.tl, settings_anim_rect_msg_volume.br);

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
  settings_anim_text_msg_mute.text = "";
  settings_anim_text_msg_mute.result = "Mute messages";
  settings_anim_text_msg_mute.duration = 15;
  settings_anim_text_msg_mute.frame = 0;
  settings_anim_text_msg_volume.text = "";
  settings_anim_text_msg_volume.result = "Messages volume";
  settings_anim_text_msg_volume.duration = 15;
  settings_anim_text_msg_volume.frame = 0;
  settings_anim_rect_msg_volume.tl_start = Vec2f(8, LABEL_H + TEXT_H + TEXT_H + 8);
  settings_anim_rect_msg_volume.br_start = Vec2f(48, LABEL_H + TEXT_H + TEXT_H + LABEL_H + 8);
  settings_anim_rect_msg_volume.tl_end = Vec2f(8, LABEL_H + TEXT_H + TEXT_H + 8);
  settings_anim_rect_msg_volume.br_end = Vec2f(canvas_settings.getSize().x / 2, LABEL_H + TEXT_H + TEXT_H + LABEL_H + 8);
  settings_anim_rect_msg_volume.duration = 15;
  settings_anim_rect_msg_volume.frame = 0;
}

void SettingsLoad() {
  ConfigFile config_file;
  if (config_file.loadFile(CACHE_DIR + SETTINGS_FILE)) {
    if (config_file.exists("msg_mute"))
      msg_mute = config_file.read_bool("msg_mute");
    if (config_file.exists("msg_volume"))
      msg_volume = config_file.read_f32("msg_volume");
  }
}

void SettingsSave() {
  ConfigFile config_file;
  config_file.add_bool("msg_mute", msg_mute);
  config_file.add_f32("msg_volume", msg_volume);
  config_file.saveFile(SETTINGS_FILE + ".cfg");
}
