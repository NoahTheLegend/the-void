#define CLIENT_ONLY

#include "KUI.as";

void onRender(CRules@ this)
{
    KUI::Begin();
    KUI::WindowConfig windowConfig();
    windowConfig.pos = Vec2f(10, 10);
    windowConfig.alignment = KUI::Alignment::TL;
    windowConfig.closable = true;
    KUI::Window("Settings", Vec2f(300, 300), windowConfig);
    KUI::End();
}
