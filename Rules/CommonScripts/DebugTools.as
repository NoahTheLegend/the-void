void onInit(CRules@ this)
{
    this.set_bool("debug_global_gravity", false);
}

void onTick(CRules@ this)
{
    if (!(isClient() && isServer())) return;

    CControls@ controls = getControls();
    if (controls is null) return;

    if (controls.isKeyPressed(KEY_KEY_X))
    {
        if (controls.isKeyJustPressed(KEY_KEY_1))
        {
            // gravity
            sv_gravity = this.get_bool("debug_global_gravity") ? 0.0f : 9.81f / 2;
            this.set_bool("debug_global_gravity", !this.get_bool("debug_global_gravity"));
        }
    }
}

void onRender(CRules@ this)
{

}