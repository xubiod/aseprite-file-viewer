class_name LeftSideUI extends VBoxContainer

signal import_button_pressed
signal frame_changed(value: float)
signal zoom_changed(value: float)

signal external_frame_update(value: float)

@onready var layerview		: VBoxContainer = %LayerView
@onready var frameslider	: HSlider = %FrameSlider
@onready var padding		: Control = $Padding

const ANIMATION_PLAY	: Texture2D = preload("res://tex/ui/animation-play.svg")
const ANIMATION_PAUSE	: Texture2D = preload("res://tex/ui/animation-pause.svg")
const ANIMATION_REVERSE	: Texture2D = preload("res://tex/ui/animation-play-reverse.svg")

var processing_animation_press : bool = false

var times : float = 0

var play_direction : int = 1

func _on_import_btn_pressed() -> void:						import_button_pressed.emit()
func _on_frame_slider_value_changed(value: float) -> void:	frame_changed.emit(value)
func _on_zoom_slider_value_changed(value: float) -> void:	zoom_changed.emit(value)

func _on_external_frame_update(new_value: float) -> void:	%FrameSlider.value = new_value
