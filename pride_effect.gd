@tool
class_name RichTextPride extends RichTextEffect

# [pride speed=4.0 stretch=5.0 offset=0.0] text [/pride]

var bbcode = "pride"

const colour : Array[Color] = [Color.LIGHT_BLUE,Color.LIGHT_PINK,Color.WHITE,Color.LIGHT_PINK]#,Color.LIGHT_BLUE]

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var spd : float = 1. / char_fx.env.get("speed", 4.)
	var stretch : float = 1. / char_fx.env.get("stretch", 5.)
	var offset : float = char_fx.env.get("offset", 0.)

	var progress0 : float = wrapf(((float(char_fx.relative_index) * stretch + offset) / float(char_fx.glyph_count)) + (char_fx.elapsed_time / spd), 0, float(len(colour)))
	var progress1 : float = wrapf(((float(char_fx.relative_index + 1) * stretch + offset) / float(char_fx.glyph_count)) + (char_fx.elapsed_time / spd), 0, float(len(colour)))

	char_fx.color = colour[int(progress0)]#.lerp(colour[int(progress1)], abs(progress0 - progress1))

	return true
