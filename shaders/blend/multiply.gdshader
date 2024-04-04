shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform sampler2D tex_frg_3;
uniform sampler2D screen_tex_frg_4 : hint_screen_texture;

void fragment() {
// Texture2D:3
	vec4 n_out3p0 = texture(tex_frg_3, UV);

// Input:8
	vec2 n_out8p0 = SCREEN_UV;

	vec4 n_out4p0;
// Texture2D:4
	n_out4p0 = texture(screen_tex_frg_4, n_out8p0);

// VectorOp:2
	vec4 n_out2p0 = n_out3p0 * n_out4p0;

// VectorDecompose:6
	float n_out6p0 = n_out2p0.x;
	float n_out6p1 = n_out2p0.y;
	float n_out6p2 = n_out2p0.z;
	float n_out6p3 = n_out2p0.w;

// VectorCompose:7
	vec3 n_out7p0 = vec3(n_out6p0, n_out6p1, n_out6p2);

// VectorDecompose:5
	float n_out5p0 = n_out3p0.x;
	float n_out5p1 = n_out3p0.y;
	float n_out5p2 = n_out3p0.z;
	float n_out5p3 = n_out3p0.w;

// Output:0
	ALBEDO = n_out7p0;
	ALPHA = n_out5p3;
}