class_name AsepriteLayer extends RefCounted

const NO_PARENT : int = -1

enum LayerType {
	NORMAL = 0,
	GROUP,
	TILEMAP
}

enum BlendMode {
	NORMAL         = 0,
	MULTIPLY       = 1,
	SCREEN         = 2,
	OVERLAY        = 3,
	DARKEN         = 4,
	LIGHTEN        = 5,
	COLOR_DODGE    = 6,
	COLOR_BURN     = 7,
	HARD_LIGHT     = 8,
	SOFT_LIGHT     = 9,
	DIFFERENCE     = 10,
	EXCLUSION      = 11,
	HUE            = 12,
	SATURATION     = 13,
	COLOR          = 14,
	LUMINOSITY     = 15,
	ADDITION       = 16,
	SUBTRACT       = 17,
	DIVIDE         = 18,
}

static var BlendModeToShader : Dictionary = {
	BlendMode.NORMAL: 		null,#load(BLEND_SHADER_DIR + "normal.gdshader") as Shader,
	BlendMode.MULTIPLY: 	null,#load(BLEND_SHADER_DIR + "multiply.gdshader") as Shader,
	BlendMode.SCREEN: 		load("res://shaders/blend/screen.gdshader") as Shader,
	BlendMode.OVERLAY: 		load("res://shaders/blend/overlay.gdshader") as Shader,
	BlendMode.DARKEN: 		load("res://shaders/blend/darken.gdshader") as Shader,
	BlendMode.LIGHTEN: 		load("res://shaders/blend/lighten.gdshader") as Shader,
	BlendMode.COLOR_DODGE: 	load("res://shaders/blend/color_dodge.gdshader") as Shader,
	BlendMode.COLOR_BURN: 	load("res://shaders/blend/color_burn.gdshader") as Shader,
	BlendMode.HARD_LIGHT: 	load("res://shaders/blend/hard_light.gdshader") as Shader,
	BlendMode.SOFT_LIGHT: 	load("res://shaders/blend/soft_light.gdshader") as Shader,
	BlendMode.DIFFERENCE: 	load("res://shaders/blend/difference.gdshader") as Shader,
	BlendMode.EXCLUSION: 	null,
	BlendMode.HUE: 			null,
	BlendMode.SATURATION: 	null,
	BlendMode.COLOR: 		null,
	BlendMode.LUMINOSITY: 	null,
	BlendMode.ADDITION: 	null,#load(BLEND_SHADER_DIR + "add.gdshader") as Shader,
	BlendMode.SUBTRACT: 	null,
	BlendMode.DIVIDE: 		null,
}

static var BlendModeToString : Dictionary = {
	BlendMode.NORMAL: 		"Normal",
	BlendMode.MULTIPLY: 	"Multiply",
	BlendMode.SCREEN: 		"Screen",
	BlendMode.OVERLAY: 		"Overlay",
	BlendMode.DARKEN: 		"Darken",
	BlendMode.LIGHTEN: 		"Lighten",
	BlendMode.COLOR_DODGE: 	"Color Dodge",
	BlendMode.COLOR_BURN: 	"Color Burn",
	BlendMode.HARD_LIGHT: 	"Hard Light",
	BlendMode.SOFT_LIGHT: 	"Soft Light",
	BlendMode.DIFFERENCE: 	"Difference",
	BlendMode.EXCLUSION: 	"Exclusion",
	BlendMode.HUE: 			"Hue",
	BlendMode.SATURATION: 	"Saturation",
	BlendMode.COLOR: 		"Color",
	BlendMode.LUMINOSITY: 	"Luminosity",
	BlendMode.ADDITION: 	"Addition",
	BlendMode.SUBTRACT: 	"Subtract",
	BlendMode.DIVIDE: 		"Divide",
}

enum FlagItems {
	VISIBLE = 1,
	EDITABLE = 2,
	LOCK_MOVEMENT = 4,
	BACKGROUND = 8,
	PREFER_LINKED_CELLS = 16,
	GROUP_SHOULD_BE_COLLAPSED = 32,
	IS_REFERENCE = 64,
}

@export_flags("Visible","Editable","Lock Movement","Background","Prefer Linked Cells", "Group should be Collapsed", "Is reference") var Flags : int

var Type			: LayerType
var ChildLevel		: int
var DefaultWidth	: int
var DefaultHeight	: int
var Blending		: BlendMode
var Opacity			: int
var Name			: String

var TilesetIndex : int

var Parent : int

func is_visible(deepness : int = 16) -> bool:
	var result = Flags & FlagItems.VISIBLE > 0

	if result && deepness > 0 && Parent != NO_PARENT:
		result = result && (Importer.all_layers[Parent] as AsepriteLayer).is_visible(deepness - 1)

	return result

func get_full_name(deepness : int = 16) -> String:
	var result = Name

	if deepness > 0 && Parent != NO_PARENT:
		result = (Importer.all_layers[Parent] as AsepriteLayer).get_full_name(deepness - 1) + "." + result

	return result

func get_blend_shader() -> Shader: return BlendModeToShader[Blending] as Shader
