u32 period = 0;
// celsius
f32 temp_global = temp_mid;
const f32 temp_global_random = 10.0f;
const f32 temp_max = -18.500f;
const f32 temp_min = -52.000f;
const f32 temp_mid = -1.0f * Maths::Abs(temp_max-temp_min);
const f32 temp_random = 4.0f;                        // randomly added in certain way
// change period
const u16 temp_change_period = 1;                    // how quick to change temperature
const u16 temp_change_period_random = 0;             // randomness to period time
// misc
const f32 temp_change_amount = 0.5f;                 // one step amount
const f32 temp_bias = 0.5f;                          // relative to day time, decreases temp_max
const f32 temp_plateau = 2.5f;                       // relative to temp_bias, makes a gap equal to bias, for diapazones between day halves
// date
const u8  temp_date_deviation_chance = 40;           // from 1% to 100%
const f32 temp_date_deviation = 4.0f;                // amount of random deviation per day cycle with temp_date_deviation_chance to decrease
const f32 temp_date_deviation_max = 10.0f;           // max coldness dates can get (accumulate)
// blizzard
const f32 temp_blizzard_factor = 0.5f;               // min-max blizzard level
const f32 temp_blizzard_decrease = 8.0f;             // global temperature decrease base amount

const f32 mt = 0.1f;                                 // morning time end
const f32 et = 0.8f;                                 // evening time start
const f32 mdt = mt + (et - mt)/2;                    // midday time