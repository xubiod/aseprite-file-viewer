extends RichTextLabel

var current_line : float = 0.0
var desired_line : float = 0.0

@onready var line_count = get_line_count()

func _on_scroll_reset_timeout() -> void:
	desired_line = 0.0

func _on_meta_clicked(meta) -> void:
	$"../..".meta_clicked.emit(meta)

func _on_meta_hover_started(meta) -> void:
	$"../..".meta_hover_start.emit(meta)

func _on_meta_hover_ended(meta) -> void:
	$"../..".meta_hover_stop.emit(meta)
