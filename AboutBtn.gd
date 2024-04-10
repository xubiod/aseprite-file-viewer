extends TextureButton

func _on_pressed() -> void:
	$"..".on_about_pressed.emit()
