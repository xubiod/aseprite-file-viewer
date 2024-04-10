extends Window

@onready var right_side : RightSideUI = %RightSideUI

func _ready() -> void:
	right_side.on_about_pressed.connect(_on_about_pressed)

func _on_about_pressed() -> void:
	show()

func _on_main_text_meta_clicked(meta : Variant) -> void:
	var url = str(meta)
	if url.begins_with("http"):
		OS.shell_open(url)

func _on_close_requested() -> void:
	hide()

func _on_main_text_meta_hover_started(meta : Variant) -> void:
	var url = str(meta)
	if url.begins_with("http"):
		$Container/MainText.tooltip_text = "Opens in browser"

func _on_main_text_meta_hover_ended(meta : Variant) -> void:
	$Container/MainText.tooltip_text = ""
