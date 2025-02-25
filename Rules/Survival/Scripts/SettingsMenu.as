#define CLIENT_ONLY

#include "KUI.as";

KUI::AnimationRectangle window_anim_rect_title();
KUI::AnimationRectangle window_anim_rect();
KUI::AnimationText window_anim_title();

void onInit(CRules@ rules) {
  window_anim_rect_title.tl_start = Vec2f(0, -150);
  window_anim_rect_title.br_start = Vec2f(0, -150 + KUI::window_title_h);
  window_anim_rect_title.tl_end = Vec2f(-150, -150);
  window_anim_rect_title.br_end = Vec2f(150, -150 + KUI::window_title_h);
  window_anim_rect_title.duration = 10;

  window_anim_rect.tl_start = window_anim_rect_title.tl_end;
  window_anim_rect.br_start = window_anim_rect_title.br_end;
  window_anim_rect.tl_end = Vec2f(-150, -150);
  window_anim_rect.br_end = Vec2f(150, 150);
  window_anim_rect.duration = 15;

  window_anim_title.result = "SETTINGS";
  window_anim_title.duration = 20;
}
/*
void onRender(CRules@ this) {
  CControls@ controls = getControls();
  KUI::Begin();
  KUI::DrawPane(window_anim_rect.tl, window_anim_rect.br, KUI::Alignment::CC);
  KUI::DrawPane(window_anim_rect_title.tl, window_anim_rect_title.br, KUI::Alignment::CC);
  KUI::DrawTextRectCentered(window_anim_title.text, window_anim_rect_title.tl, window_anim_rect_title.br, KUI::Alignment::CC);

  if (controls.isKeyPressed(EKEY_CODE::KEY_KEY_G)) {
    window_anim_rect_title.play();
    if(window_anim_rect_title.isEnd()) {
      window_anim_rect.play();
      if(window_anim_rect.isEnd()) {
        window_anim_title.play();
      }
    }
  }
  
  KUI::End();
}
*/
