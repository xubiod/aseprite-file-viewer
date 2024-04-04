extends TextureButton

const PIN_OUT : Texture2D = preload("res://tex/ui/pin-out.svg")
const PIN_IN  : Texture2D = preload("res://tex/ui/pin-in.svg")

@onready var window : Window = get_viewport().get_window()

func _normal_to_all() -> void:
	texture_pressed = texture_normal
	texture_hover = texture_normal
	texture_disabled = texture_normal
	texture_focused = texture_normal

func _init() -> void:
	_normal_to_all()

func _on_toggled(button_pressed: bool) -> void:
	texture_normal = PIN_IN if button_pressed else PIN_OUT
	_normal_to_all()

	window.always_on_top = button_pressed
