extends ColorRect

signal i_updated

const VISIBILITY_SHOWN	: Texture2D = preload("res://tex/ui/visibility-shown.svg")
const VISIBILITY_HIDDEN	: Texture2D = preload("res://tex/ui/visibility-hidden.svg")

const TOOLTIP_TEMPLATE : String = "{name}\n{visible}\nBlend mode: {blend}\nOpacity: {opac}% ({rawopac}){extra}"

var rep_layer		: int
var parent_index	: int

var blend_mode_supported : bool

func _init() -> void: color.a = 0.0

func plop(layer_name : String, layer_id : int, child_level: int, parent : int) -> void:
	$ItemContainer/Name.text = layer_name
	rep_layer = layer_id
	$ItemContainer/Padding.custom_minimum_size.x = child_level * $ItemContainer/Visible.texture_normal.get_width()
	parent_index = parent

	match Importer.all_layers[rep_layer].Blending:
		AsepriteLayer.BlendMode.NORMAL, AsepriteLayer.BlendMode.ADDITION, \
		AsepriteLayer.BlendMode.MULTIPLY, AsepriteLayer.BlendMode.SUBTRACT:
			blend_mode_supported = true
		_:
			blend_mode_supported = false

	update_visible_icon()

func update_visible_icon() -> void:
	var vis = Importer.all_layers[rep_layer].Flags & AsepriteLayer.FlagItems.VISIBLE > 0
	$ItemContainer/Visible.texture_normal = VISIBILITY_SHOWN if vis else VISIBILITY_HIDDEN
	$ItemContainer/Visible.texture_pressed = VISIBILITY_SHOWN if !vis else VISIBILITY_HIDDEN
	$ItemContainer/Visible.texture_hover = $ItemContainer/Visible.texture_normal
	$ItemContainer/Visible.texture_disabled = $ItemContainer/Visible.texture_normal
	$ItemContainer/Visible.texture_focused = $ItemContainer/Visible.texture_normal

	$ItemContainer/Visible.tooltip_text = "Shown" if vis else "Hidden"

	update_tooltip()
	update_warning()

func update_tooltip() -> void:
	var _me : AsepriteLayer = Importer.all_layers[rep_layer]
	tooltip_text = TOOLTIP_TEMPLATE.format({
		"name": _me.Name,
		"visible": "Shown" if _me.Flags & _me.FlagItems.VISIBLE > 0 else "Hidden",
		"blend": AsepriteLayer.BlendModeToString[_me.Blending],
		"opac": str(floor((_me.Opacity*100)/255.0)),
		"rawopac": str(_me.Opacity),
		"extra": "\nIs a reference" if _me.Flags & _me.FlagItems.IS_REFERENCE > 0 else ""
	})

func update_warning() -> void:
	var _me : AsepriteLayer = Importer.all_layers[rep_layer]
	var warn = $ItemContainer/Warning as TextureRect

	# warning conditions
	warn.visible = false
	warn.tooltip_text = ""

	if !blend_mode_supported:
		warn.tooltip_text += "This blend mode (%s) is currently unsupported\nand will be treated as Normal" % AsepriteLayer.BlendModeToString[_me.Blending]
		warn.visible |= true

func _on_visible_pressed() -> void:
	Importer.all_layers[rep_layer].Flags ^= AsepriteLayer.FlagItems.VISIBLE
	update_visible_icon()
	i_updated.emit()

func _on_mouse_entered()	-> void: color.a = 0.06125
func _on_mouse_exited()		-> void: color.a = 0.0
