#define CLIENT_ONLY

#include "KUI.as";

KUI::Animation window_animation();

void onInit(CRules@ rules) {
  window_animation.tl_start = Vec2f(0, 0);
  window_animation.br_start = Vec2f(0, 0);
  window_animation.tl_end = Vec2f(-200, -200);
  window_animation.br_end = Vec2f(200, 200);
  window_animation.duration = 10;
}

/*
void onRender(CRules@ this) {
  CControls@ controls = getControls();
  KUI::Begin();
  KUI::Window("Settings", window_animation.tl, window_animation.br,
  KUI::Alignment::CC); KUI::End();
  if (controls.isKeyPressed(EKEY_CODE::KEY_KEY_G)) window_animation.play();
}
*/
