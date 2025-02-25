#define CLIENT_ONLY

#include "KUI.as";

bool isOpen = true;

void onRender(CRules@ this)
{
    KUI::Begin();
    KUI::WindowConfig windowConfig();
    windowConfig.pos = Vec2f(10, 10);
    windowConfig.alignment = KUI::Alignment::TL;
    windowConfig.closable = true;
    if(isOpen and KUI::Window("Settings", Vec2f(300, 300), windowConfig)) {
        
    } else {
       isOpen = false;
    }
    KUI::End();
}
