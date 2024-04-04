extends Label

func _process(_delta : float) -> void: text = "Layers Spread" if Importer.truespreadout else "Normal"
