extends Node3D

func _enter_tree() -> void:
	var window : Window = get_window()
	window.files_dropped.connect(_on_files_dropped)
	window.min_size = get_viewport().size

func _is_valid(fname: String) -> bool:
	return fname.ends_with(".ase") || fname.ends_with(".aseprite")

func _on_files_dropped(files: PackedStringArray) -> void:
	var valid_files : PackedStringArray = (files as Array).filter(_is_valid)

	if len(valid_files) > 0:
		$Windows/ImportDialog._on_file_selected(valid_files[0])
	else:
		$Windows/WrongImport.show()
