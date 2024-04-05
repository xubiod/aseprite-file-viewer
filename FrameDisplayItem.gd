class_name FrameDisplayItem extends ProgressBar

signal new_frame(new_value: float)

const HOVER_ALPHA	: float = 0.75
const UNHOVER_ALPHA : float = 0.35
const CURRENT_ALPHA : float = 0.9

const ACTIVE_MIN_H		: float = 24
const INACTIVE_MIN_H	: float = 18

const FRAME_TOOLTIP : String = "Frame {num}\n{duration}ms ({engine_frames} engine frames at 60fps)"

@export var hovering	: bool = false
var frame_based			: int

var target_alpha : float = UNHOVER_ALPHA

func setup(frame_index : int) -> void:
	frame_based = frame_index

	var _frm = Importer.all_frames[frame_index]

	size_flags_stretch_ratio = _frm.DurationMS
	max_value = _frm.DurationMS
	value = 0
	tooltip_text = FRAME_TOOLTIP.format({"num": frame_index, "duration": _frm.DurationMS, "engine_frames": ceilf(_frm.DurationMS / (1000. / 60.))})

func _process(_delta: float) -> void:
	if hovering:
		target_alpha = CURRENT_ALPHA if Importer.view_frame == frame_based else HOVER_ALPHA

		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			new_frame.emit(frame_based)
	else:
		target_alpha = CURRENT_ALPHA if Importer.view_frame == frame_based else UNHOVER_ALPHA

	custom_minimum_size.y = lerpf(custom_minimum_size.y, ACTIVE_MIN_H if (Importer.view_frame == frame_based || hovering) else INACTIVE_MIN_H, 0.3)
	modulate.a = lerpf(modulate.a, target_alpha, 0.3)

func _on_mouse_entered() -> void: hovering = true
func _on_mouse_exited()  -> void: hovering = false

func _range_changed(from: int, to: int) -> void:
	modulate = Color(Color.WHITE, modulate.a) if frame_based >= from && frame_based <= to else Color(Color.DIM_GRAY, modulate.a)
