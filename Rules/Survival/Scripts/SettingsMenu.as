#define CLIENT_ONLY

#include "KUI.as";

KUI::AnimationRectangle window_animation();
KUI::AnimationText window_animation_title();

void onInit(CRules@ rules) {
  window_animation.tl_start = Vec2f(0, 0);
  window_animation.br_start = Vec2f(0, 0);
  window_animation.tl_end = Vec2f(-150, -150);
  window_animation.br_end = Vec2f(150, 150);
  window_animation.duration = 10;

  window_animation_title.result = "SETTINGS";
  window_animation_title.duration = 20;
}

void onRender(CRules@ this) {
  CControls@ controls = getControls();
  KUI::Begin();
  KUI::Window(window_animation_title.text, window_animation.tl, window_animation.br,
  KUI::Alignment::CC); KUI::End();
  if (controls.isKeyPressed(EKEY_CODE::KEY_KEY_G)) {
    window_animation.play();
    if(window_animation.isEnd()) window_animation_title.play();
  }
}

