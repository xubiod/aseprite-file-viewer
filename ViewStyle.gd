extends Button

const VIEW_NORMAL : Texture2D = preload("res://tex/ui/view-2d.svg")
const VIEW_SPREAD : Texture2D = preload("res://tex/ui/view-3d.svg")

func _process(_delta : float) -> void:
	if Importer.truespreadout && icon != VIEW_SPREAD:
		icon = VIEW_SPREAD
	elif !Importer.truespreadout && icon != VIEW_NORMAL:
		icon = VIEW_NORMAL

	Importer.truespreadout = (Importer.spreadout != Input.is_action_pressed("separate"))

func _on_pressed() -> void: Importer.spreadout = !Importer.spreadout
