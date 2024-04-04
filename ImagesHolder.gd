extends Node3D

const SEPERATION_WEIGHT				: float = 0.5
const background_effect_reduction	: int = 2560

@export var speed : float = 0.3

var inital_position		: Vector3
var mom					: Vector2 = Vector2(0,0)
var separation_approach	: float = Importer.STARTING_SEPARATION

var angle_approach : float = 0

func _enter_tree() -> void: inital_position = position

func _process(_delta : float) -> void:
	position.x += mom.x
	position.y += mom.y

	RenderingServer.global_shader_parameter_set("camera_position", Vector2(position.x / background_effect_reduction, position.y / background_effect_reduction))

	mom *= 0.8
	mom += speed * Input.get_vector("move_east","move_west","move_north","move_south")

	if Importer.truespreadout:
		separation_approach = Importer.STARTING_SEPARATION * Importer.seperation_distance
		angle_approach = -45
	else:
		separation_approach = Importer.STARTING_SEPARATION
		angle_approach = 0

	Importer.layer_separation = lerpf(Importer.layer_separation, separation_approach, SEPERATION_WEIGHT)
	rotation_degrees.x = lerpf(rotation_degrees.x, angle_approach, SEPERATION_WEIGHT)
	rotation_degrees.y = lerpf(rotation_degrees.y, angle_approach, SEPERATION_WEIGHT)

	if Input.is_action_just_pressed("reset_position"):
		position = inital_position

func update_all(frame_updated : bool = false) -> void:
	for child in get_children():
		child.update_from_layer()
		if frame_updated:
			child.update_from_frame()

func _on_layerview_update() -> void: update_all()

func _on_left_side_ui_frame_changed(value: float) -> void:
	Importer.view_frame = round(value)
	update_all(true)
	update_all(true) # what the fuck?

func _on_bottom_side_ui_frame_changed(value : float) -> void: _on_left_side_ui_frame_changed(value)
