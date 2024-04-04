extends Camera3D

func _on_left_side_ui_zoom_changed(value: float) -> void: size = (1.0 / value) * Importer.UPSCALE_BY
