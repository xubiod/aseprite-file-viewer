shader_type spatial;
render_mode blend_mix, unshaded;

uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
	vec4 input_colour = COLOR;
	vec4 screen_colour = texture(screen_texture, SCREEN_UV);

	ALBEDO = vec3(input_colour.r + screen_colour.r,input_colour.g + screen_colour.g,input_colour.b + screen_colour.b);
	ALPHA = input_colour.a;
}