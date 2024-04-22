extends FileDialog

const LAYER_SHOWN	: Texture2D = preload("res://tex/ui/visibility-shown.svg")
const LAYER_HIDDEN	: Texture2D = preload("res://tex/ui/visibility-hidden.svg")

const showcase_item	: PackedScene = preload("res://image_element.tscn")
const layer_item	: PackedScene = preload("res://layer_item.tscn")

@onready var parent	: Node3D = %ImagesHolder

var border_image			: Image
var border_image_texture	: ImageTexture

func _enter_tree() -> void:
	if !OS.is_debug_build():
		current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)

func _on_file_selected(path : String) -> void:
	if !(path.ends_with(".ase") || path.ends_with(".aseprite")):
		$"../WrongImport".show()
		return

	if !Importer.import(path):
		$"../WrongImport".show()
		return

	# kill all the children
	for child in parent.get_children():
		child.queue_free()

	for item in %LeftSideUI.layerview.get_children():
		item.queue_free()

#	%LeftSideUI.external_frame_update.emit(0)
#	%LeftSideUI.frameslider.max_value = len(Importer.all_frames) - 2
#	%LeftSideUI.frameslider.tick_count = (%LeftSideUI.frameslider.max_value / 4) + 2

	%BottomSideUI.external_frame_update.emit(0)
	%BottomSideUI.frameslider.max_value = len(Importer.all_frames) - 2
	%BottomSideUI.frameslider.tick_count = (%BottomSideUI.frameslider.max_value / 4) + 2

	parent.position.x = -Importer.image_size.x/(Importer.UPSCALE_BY * 2.0)
	parent.position.y = -Importer.image_size.y/(4.0)
	parent.inital_position = parent.position

	var current_index = 0
	var parents : Dictionary = {-1: -1}
	for layer in Importer.all_layers:
		layer = layer as AsepriteLayer
		parents[layer.ChildLevel] = current_index
		Importer.all_layers[current_index].Parent = parents[layer.ChildLevel-1]

		var item = layer_item.instantiate()
		item.plop(layer.Name, current_index, layer.ChildLevel, parents[layer.ChildLevel-1])
		item.i_updated.connect(%ImagesHolder._on_layerview_update)
		%LeftSideUI.layerview.add_child(item)
		current_index += 1

	border_image = null
	border_image = Image.create(Importer.image_size.x, Importer.image_size.y, false, Image.FORMAT_LA8)
	border_image.fill(Color(1,1,1,0.1))
	border_image.fill_rect(Rect2i(1,1,Importer.image_size.x-2,Importer.image_size.y-2),Color(1.0,1.0,1.0,0.0))

	border_image_texture = ImageTexture.create_from_image(border_image)

	if showcase_item.can_instantiate():
		for idx in len(Importer.all_layers):
			if Importer.all_layers[idx].Type != AsepriteLayer.LayerType.NORMAL:
				continue
			var new_item : ImageElement = showcase_item.instantiate()
			new_item.based_on_index = idx
			new_item.assign_border_texture(border_image_texture)
			parent.add_child(new_item)
	else:
		push_error("FUCK")

	(%BottomSideUI as BottomSideUI).new_file_imported.emit()

	# TODO: unfuck up this disaster of a line
	(%LeftSideUI as LeftSideUI).padding.custom_minimum_size.y = (%BottomSideUI as BottomSideUI).get_true_height()

func _on_left_side_ui_import_button_pressed() -> void: show()
