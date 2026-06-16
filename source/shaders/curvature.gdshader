shader_type spatial;
render_mode unshaded, blend_mul;

uniform sampler2D normal_texture: hint_normal_roughness_texture;
uniform float ridge: hint_range(0.0, 2.0, 0.0001) = 1.0;
uniform float valley: hint_range(0.0, 2.0, 0.0001) = 1.0;
//uniform float size: hint_range(0.0, 2.0, 0.0001) = 1.0;
//uniform float perspective: hint_range(0.0, 2.0, 0.0001) = 1.0;
//vec2 offset = vec2(size) * (1.0 + FRAGCOORD.w * perspective);

float curvatureSoftClamp(float curvature, float control) {
	if (curvature < 0.5f / control) {
		return curvature * (1.0f - curvature * control);
	}
	return 0.25f / control;
}

void fragment() {
	vec2 uv = SCREEN_UV;
	float curvature = 0.0;
	vec3 offset = vec3(0.5 / VIEWPORT_SIZE, 0.0);
	float normal_up = texture(normal_texture, uv + offset.zy).g;
	float normal_down = texture(normal_texture, uv - offset.zy).g;
	float normal_right = texture(normal_texture, uv + offset.xz).r;
	float normal_left = texture(normal_texture, uv - offset.xz).r;
	float normal_diff = (normal_down - normal_up) + (normal_right - normal_left);

	if (normal_diff < 0.0) {
		curvature = -2.0 * curvatureSoftClamp(-normal_diff, 1.0/valley);
	}
	else {
		curvature = 2.0 * curvatureSoftClamp(normal_diff, 1.0/ridge);
	}

	ALBEDO = vec3(1.0 + curvature);
}