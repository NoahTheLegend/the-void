#define CLIENT_ONLY

#include "FUI.as";

const int WINDOW_TITLE_H = 24;
const int BUTTON_H = 24;

FUI::Canvas canvas();

FUI::AnimationRect anim_rect_canvas();
FUI::AnimationRect anim_rect_title();
FUI::AnimationRect anim_rect_button();
FUI::AnimationText anim_text_title();
FUI::AnimationText anim_text_error();

bool is_open = false;

void onInit(CRules@ rules) {
  is_open = false;
  ResetAnimation();
}

void onRender(CRules@ this) {
  CControls@ controls = getControls();
  if (controls.isKeyPressed(EKEY_CODE::KEY_KEY_G)) {
    is_open = true;
    ResetAnimation();
  }
  
  if (is_open) {
    canvas.begin(Vec2f(-200, -200), Vec2f(200, 200), FUI::Alignment::CC);

    if (anim_rect_canvas.isPlayOrEnd())
      canvas.drawPane(anim_rect_canvas.tl, anim_rect_canvas.br);
    if (anim_rect_title.isPlayOrEnd())
      canvas.drawPane(anim_rect_title.tl, anim_rect_title.br);
    if (anim_text_title.isPlayOrEnd())
      canvas.drawTextCentered(anim_text_title.text, Vec2f(0, 0), Vec2f(canvas.getSize().x, WINDOW_TITLE_H), FUI::Colors::FOREGROUND);
    if (anim_text_error.isPlayOrEnd())
      canvas.drawText(anim_text_error.text, Vec2f(8, WINDOW_TITLE_H), FUI::Colors::ERROR);
    if (anim_rect_button.isPlayOrEnd())
      canvas.button(anim_rect_button.tl, anim_rect_button.br);
    
    anim_rect_title.play();
    if (anim_rect_title.isEnd()) {
      anim_rect_canvas.play();
      if (anim_rect_canvas.isEnd()) {
        anim_text_title.play();
        anim_text_error.play();
        anim_rect_button.play();
      }
    }

    canvas.end();
  }
}

void ResetAnimation() {
  anim_rect_title.tl_start = Vec2f(canvas.getSize().x / 2, 0);
  anim_rect_title.br_start = Vec2f(canvas.getSize().x / 2, WINDOW_TITLE_H);
  anim_rect_title.tl_end = Vec2f(0, 0);
  anim_rect_title.br_end = Vec2f(canvas.getSize().x, WINDOW_TITLE_H);
  anim_rect_title.duration = 20;
  anim_rect_title.frame = 0;
  anim_rect_canvas.tl_start = anim_rect_title.tl_end;
  anim_rect_canvas.br_start = anim_rect_title.br_end;
  anim_rect_canvas.tl_end = anim_rect_title.tl_end;
  anim_rect_canvas.br_end = canvas.getSize();
  anim_rect_canvas.duration = 30;
  anim_rect_canvas.frame = 0;
  anim_text_title.result = "S.E.T.T.I.N.G.S";
  anim_text_title.duration = 30;
  anim_text_title.frame = 0;
  anim_text_error.result = "CRITICAL Error: code 1488";
  anim_text_error.duration = 40;
  anim_text_error.frame = 0;
  anim_rect_button.tl_start = Vec2f(10, 48);
  anim_rect_button.br_start = Vec2f(10, 80);
  anim_rect_button.tl_end = Vec2f(10, 48);
  anim_rect_button.br_end = Vec2f(150, 80);
  anim_rect_button.duration = 20;
  anim_rect_button.frame = 0;
}
