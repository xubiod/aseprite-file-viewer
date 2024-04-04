shader_type spatial;
render_mode blend_mix, unshaded;

void fragment() {
	ALBEDO = COLOR.rgb;
	ALPHA = COLOR.a;
}
