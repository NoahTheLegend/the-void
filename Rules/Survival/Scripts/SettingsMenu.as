#define CLIENT_ONLY

#include "KUI.as";

KUI::AnimationRectangle window_anim_rect_title();
KUI::AnimationRectangle window_anim_rect();
KUI::AnimationText window_anim_title();
KUI::AnimationText window_anim_error();

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
        KUI::Begin();
        if (window_anim_rect.isPlayOrEnd())
            KUI::DrawPane(window_anim_rect.tl, window_anim_rect.br, KUI::Alignment::CC);
        if (window_anim_rect_title.isPlayOrEnd())
            KUI::DrawPane(window_anim_rect_title.tl, window_anim_rect_title.br, KUI::Alignment::CC);
        if (window_anim_title.isPlayOrEnd())
            KUI::DrawTextRectCentered(window_anim_title.text, window_anim_rect_title.tl, window_anim_rect_title.br, KUI::Colors::FOREGROUND, KUI::Alignment::CC);
        if (window_anim_error.isPlayOrEnd())
            KUI::DrawText(window_anim_error.text, window_anim_rect.tl + Vec2f(4, KUI::WINDOW_TITLE_H), KUI::Colors::ERROR, KUI::Alignment::CC);
        window_anim_rect_title.play();
        if (window_anim_rect_title.isEnd()) {
            window_anim_rect.play();
            if (window_anim_rect.isEnd()) {
                window_anim_title.play();
                window_anim_error.play();
            }
        }
        KUI::End();
    }
}

void ResetAnimation() {
    window_anim_rect_title.tl_start = Vec2f(0, -100);
    window_anim_rect_title.br_start = Vec2f(0, -100 + KUI::WINDOW_TITLE_H);
    window_anim_rect_title.tl_end = Vec2f(-150, -100);
    window_anim_rect_title.br_end = Vec2f(150, -100 + KUI::WINDOW_TITLE_H);
    window_anim_rect_title.duration = 20;
    window_anim_rect_title.frame = 0;
    window_anim_rect.tl_start = window_anim_rect_title.tl_end;
    window_anim_rect.br_start = window_anim_rect_title.br_end;
    window_anim_rect.tl_end = Vec2f(-150, -100);
    window_anim_rect.br_end = Vec2f(150, 100);
    window_anim_rect.duration = 30;
    window_anim_rect.frame = 0;
    window_anim_title.result = "Settings";
    window_anim_title.duration = 15;
    window_anim_title.frame = 0;
    window_anim_error.result = "CRITICAL Error: code 1488";
    window_anim_error.duration = 40;
    window_anim_error.frame = 0;
}
