
const f32 min_vol = 0.0f;
const f32 max_vol = 4.0f;
const f32 min_pitch = 0.25f;
const f32 max_pitch = 2.0f;

shared class ClientVars {
    bool msg_mute;
    f32 msg_volume;
    f32 msg_volume_final;
    f32 msg_pitch;
    f32 msg_pitch_final;

    ClientVars()
    {
        msg_mute = false;
        msg_volume = 0.5f;
        msg_volume_final = Maths::Max(min_vol, msg_volume);
        msg_pitch = 0.5f;
        msg_pitch_final = Maths::Max(min_pitch, msg_pitch);
    }
};