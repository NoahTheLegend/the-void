uniform sampler2D baseMap;

void main() {
    float strength = 1.5;

    float base_zoom_scale = (strength + 1.0) / 2.0;
    float zoom_scale = base_zoom_scale / strength;

    vec2 uv = gl_TexCoord[0].xy;
    vec2 uv_normalized = 2.0 * uv - 1.0;
    float r_distorted = length(uv_normalized);

    float r_max = sqrt(2.0);
    float theta_max = atan(1.0);

    float r_original = atan(r_distorted * strength) / (theta_max * strength) * zoom_scale;
    vec2 original_uv_normalized = (r_distorted > 0.0) 
        ? uv_normalized * (r_original / r_distorted) 
        : vec2(0.0, 0.0);

    vec2 original_uv = 0.5 * original_uv_normalized + 0.5;
    original_uv = mix(original_uv, clamp(original_uv, 0.0, 1.0), 0.9);

    gl_FragColor = texture2D(baseMap, original_uv);
    gl_FragColor.a = 1.0;
}