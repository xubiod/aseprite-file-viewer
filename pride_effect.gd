@tool
class_name RichTextPride extends RichTextEffect

# [pride pattern=trans speed=4.0 stretch=5.0 offset=0.0] text [/pride]

var bbcode = "pride"

const colour : Dictionary = {"def": [Color.WHITE], "trans": [Color.LIGHT_BLUE, Color.LIGHT_PINK, Color.WHITE, Color.LIGHT_PINK]}
# const colour_count : float = float(len(colour))

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var spd : float = 1. / char_fx.env.get("speed", 4.)
	var stretch : float = 1. / char_fx.env.get("stretch", 5.)
	var offset : float = char_fx.env.get("offset", 0.)
	var pattern : String = char_fx.env.get("pattern", "def")
	var colour_count : float = float(len(colour.get(pattern)))

	var effective : float = (char_fx.elapsed_time / spd)

	var progress0 : float = wrapf(((float(char_fx.relative_index) * stretch + offset) / float(char_fx.glyph_count)) + effective, 0, colour_count)
	# var progress1 : float = wrapf(((float(char_fx.relative_index + 1) * stretch + offset) / float(char_fx.glyph_count)) + effective, 0, colour_count)

	char_fx.color = colour.get(pattern)[int(progress0)]

	return true
