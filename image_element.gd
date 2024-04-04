class_name ImageElement extends Sprite3D

var based_on		: AsepriteCell
var based_on_index	: int

var selected_from_list	: bool = false
var normal_mat			: StandardMaterial3D = preload("res://materials/standard_mat.tres")
var material			: ShaderMaterial = preload("res://materials/shader_mat.tres")

func assign_border_texture(txture : ImageTexture) -> void:
	$VisibleOnLayerSpread/SpriteBorder.texture = txture

func _enter_tree() -> void:
	pixel_size = 0.01 * Importer.UPSCALE_BY
	position = Vector3.ZERO
	material_overlay = null
	render_priority = based_on_index

	material = material.duplicate()
	normal_mat = normal_mat.duplicate()

	material_override = normal_mat

	update_from_frame()
	update_from_layer()
	$VisibleOnLayerSpread/SpreadLabel.text = Importer.all_layers[based_on_index].get_full_name()
	$VisibleOnLayerSpread/SpreadLabel.position.x = (Importer.image_size.x + 4) * pixel_size
	$VisibleOnLayerSpread/SpreadLabel.position.y = ((Importer.image_size.y * based_on_index) / (float)(len(Importer.all_layers))*pixel_size)
	$VisibleOnLayerSpread/SpreadLabel.pixel_size = pixel_size / 10

	$VisibleOnLayerSpread/SpriteBorder.pixel_size = pixel_size

func _process(_delta) -> void:
	if based_on == null:
		return
	position.z = (based_on.LayerIndex + based_on.ZIndex) * Importer.layer_separation

# Seperated because of expensive-ness possibility
func update_from_frame() -> void:
	based_on = null
	texture = null
#	if material_override is ShaderMaterial:
#		material_override.set_shader_parameter("input_texture", texture)
#	elif material_override is StandardMaterial3D:
#		material_override.albedo_texture = null

	if !Importer.all_frames[Importer.view_frame].Cells.has(based_on_index):
		return

	var cell = Importer.all_frames[Importer.view_frame].Cells[based_on_index] as AsepriteCell
	if cell.IsLinked:
		cell = Importer.all_frames[cell.LinkedTo].Cells[based_on_index] as AsepriteCell

	if cell != null:
		based_on = cell
		texture = ImageTexture.create_from_image(based_on.CellImage)

		var shd = null #Importer.all_layers[based_on.LayerIndex].get_blend_shader()
		if shd == null:
			material_override = normal_mat
			material_override.albedo_texture = texture
			match Importer.all_layers[based_on.LayerIndex].Blending:
				AsepriteLayer.BlendMode.ADDITION:
					material_override.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
				AsepriteLayer.BlendMode.SUBTRACT:
					material_override.blend_mode = BaseMaterial3D.BLEND_MODE_SUB
				AsepriteLayer.BlendMode.MULTIPLY:
					material_override.blend_mode = BaseMaterial3D.BLEND_MODE_MUL
				_:
					material_override.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
			return

#		(material_override as ShaderMaterial).shader = Importer.all_layers[based_on.LayerIndex].get_blend_shader()
#		material_override.set_shader_parameter("input_texture", texture)
	return

func update_from_layer() -> void:
	if based_on == null || based_on.LayerIndex > len(Importer.all_layers)-1:
		visible = false
		return

	var _me = Importer.all_layers[based_on.LayerIndex]

	visible = _me.is_visible()
	transparency = 1.0 - (float(_me.Opacity) / 255.0)
