extends SpinBox

func _on_value_changed(new_value : float) -> void: Importer.view_frame = round(new_value)
