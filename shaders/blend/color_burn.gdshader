shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform sampler2D tex_frg_3 : source_color;
uniform sampler2D screen_tex_frg_4 : hint_screen_texture;

void fragment() {
// Texture2D:3
	vec4 n_out3p0 = texture(tex_frg_3, UV);

// VectorDecompose:5
	float n_out5p0 = n_out3p0.x;
	float n_out5p1 = n_out3p0.y;
	float n_out5p2 = n_out3p0.z;
	float n_out5p3 = n_out3p0.w;

// VectorCompose:9
	vec3 n_out9p0 = vec3(n_out5p0, n_out5p1, n_out5p2);

// Input:11
	vec2 n_out11p0 = SCREEN_UV;

	vec4 n_out4p0;
// Texture2D:4
	n_out4p0 = texture(screen_tex_frg_4, n_out11p0);

// VectorDecompose:8
	float n_out8p0 = n_out4p0.x;
	float n_out8p1 = n_out4p0.y;
	float n_out8p2 = n_out4p0.z;
	float n_out8p3 = n_out4p0.w;

// VectorCompose:7
	vec3 n_out7p0 = vec3(n_out8p0, n_out8p1, n_out8p2);

// ColorOp:10
	vec3 n_out10p0 = vec3(1.0) - (vec3(1.0) - n_out9p0) / (n_out7p0);

// Output:0
	ALBEDO = n_out10p0;
	ALPHA = n_out5p3;
}
