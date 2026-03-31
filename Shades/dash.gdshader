shader_type canvas_item;

group_uniforms SpeedLine;
uniform vec2 dash_dir = vec2(1.0, 0.0); // 速度方向
uniform float line_count = 6.0;         // 速度线数量
uniform float length = 0.4;             // 速度线长度
uniform float thickness = 0.03;         // 粗细
uniform float randomness = 0.3;         // 随机偏移
uniform float intensity = 1.0;          // 强度
group_uniforms;

float rand(float x) {
    return fract(sin(x * 12.9898) * 43758.5453);
}

void fragment() {
    vec4 base = texture(TEXTURE, UV);

    float line_value = 0.0;

    // 生成多条速度线
    for (float i = 0.0; i < line_count; i += 1.0) {
        float offset = rand(i) * randomness;

        // 每条线的中心位置
        float center = (i + offset) / line_count;

        // 与 dash_dir 垂直方向的距离
        float perp = dot(UV - vec2(center), vec2(-dash_dir.y, dash_dir.x));

        // 线条粗细
        float line_shape = smoothstep(thickness, 0.0, abs(perp));

        // 沿 dash_dir 的渐隐
        float along = dot(UV, dash_dir);
        float fade = smoothstep(length, 0.0, along);

        line_value += line_shape * fade;
    }

    line_value *= intensity;

    COLOR = base + vec4(vec3(line_value), 0.0);
}
