shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform sampler2D tex_frg_3;
uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
// Texture2D:3
	vec4 texture_colour = texture(tex_frg_3, UV);

// VectorDecompose:5
	float n_out5p0 = texture_colour.x;
	float n_out5p1 = texture_colour.y;
	float n_out5p2 = texture_colour.z;
	float result_alpha = texture_colour.w;

// VectorCompose:9
	vec3 n_out9p0 = vec3(n_out5p0, n_out5p1, n_out5p2);

// Input:11
	vec2 screenUV = SCREEN_UV;

	vec4 screen_colour = texture(screen_texture, screenUV);

// VectorDecompose:8
	float n_out8p0 = screen_colour.x;
	float n_out8p1 = screen_colour.y;
	float n_out8p2 = screen_colour.z;
	float n_out8p3 = screen_colour.w;

// VectorCompose:7
	vec3 n_out7p0 = vec3(n_out8p0, n_out8p1, n_out8p2);

	vec3 result_colour;
// ColorOp:10
	{
		float base = n_out9p0.x;
		float blend = n_out7p0.x;
		if (base < 0.5) {
			result_colour.x = (base * (2.0 * blend));
		} else {
			result_colour.x = (1.0 - (1.0 - base) * (1.0 - 2.0 * (blend - 0.5)));
		}
	}
	{
		float base = n_out9p0.y;
		float blend = n_out7p0.y;
		if (base < 0.5) {
			result_colour.y = (base * (2.0 * blend));
		} else {
			result_colour.y = (1.0 - (1.0 - base) * (1.0 - 2.0 * (blend - 0.5)));
		}
	}
	{
		float base = n_out9p0.z;
		float blend = n_out7p0.z;
		if (base < 0.5) {
			result_colour.z = (base * (2.0 * blend));
		} else {
			result_colour.z = (1.0 - (1.0 - base) * (1.0 - 2.0 * (blend - 0.5)));
		}
	}

// Output:0
	ALBEDO = result_colour;
	ALPHA = result_alpha;
}