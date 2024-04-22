extends Sprite3D

var init_size : float

func _ready() -> void:
	init_size = pixel_size / 1.
	pixel_size = init_size

func _on_left_side_ui_zoom_changed(value: float) -> void: pixel_size = init_size / value

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_IN:
			visible = true
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			visible = false
