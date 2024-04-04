class_name BottomSideUI extends VBoxContainer

signal new_file_imported
signal frame_changed(value: float)
signal external_frame_update(value: float)
signal range_changed(from: int, to: int)

const ANIMATION_PLAY	: Texture2D = preload("res://tex/ui/animation-play.svg")
const ANIMATION_PAUSE	: Texture2D = preload("res://tex/ui/animation-pause.svg")
const ANIMATION_REVERSE	: Texture2D = preload("res://tex/ui/animation-play-reverse.svg")

const DIRECTION_FORWARD				: Texture2D = preload("res://tex/ui/direction-forward.svg")
const DIRECTION_REVERSE				: Texture2D = preload("res://tex/ui/direction-reverse.svg")
const DIRECTION_PINGPONG			: Texture2D = preload("res://tex/ui/direction-pingpong.svg")
const DIRECTION_PINGPONG_REVERSE	: Texture2D = preload("res://tex/ui/direction-pingpong-reverse.svg")
const DIRECTION_ARR : Array[Texture2D] = [
	DIRECTION_FORWARD, DIRECTION_REVERSE, DIRECTION_PINGPONG, DIRECTION_PINGPONG_REVERSE
]

const FRAME_TOOLTIP	: String = "Frame {num}\n{duration}ms"
const TAG_TOOLTIP	: String = "{name} [{start}, {end}]"

@onready var frameslider : HSlider = $MainContainer/FrameSlider

@onready var play_btn			: Button = $MainContainer/PlayBtn
@onready var reverse_btn		: Button = $MainContainer/ReversePlayBtn
var processing_animation_press	: bool = false

@onready var FRAME_DISPLAY_ITEM : PackedScene = load("res://frame_display_item.tscn")

var times			: float = 0
var play_direction	: int = 1
var ping_pong		: bool = false

var frame_range : Vector2i

func _init() -> void: visible = false

func _process(delta: float) -> void:
	if play_btn.button_pressed || reverse_btn.button_pressed:
		times += delta * 1000
		if times > Importer.all_frames[Importer.view_frame].DurationMS:
			times = 0
			if (frameslider.value == frame_range.y || frameslider.value == frameslider.max_value) && play_direction == 1:
				if ping_pong:
					play_direction *= -1
				else:
					frameslider.value = frame_range.x
			elif (frameslider.value == frame_range.x || frameslider.value == frameslider.min_value) && play_direction == -1:
				if ping_pong:
					play_direction *= -1
				else:
					frameslider.value = frame_range.y
			else:
				frameslider.value = frameslider.value + play_direction

func _on_frame_slider_value_changed(value: float) -> void:
	frame_changed.emit(value)
	var _frm = Importer.all_frames[floori(value)]
	frameslider.tooltip_text = FRAME_TOOLTIP.format({"num": floori(value), "duration": _frm.DurationMS})

func _on_external_frame_update(new_value: float) -> void: frameslider.value = new_value

func _on_play_btn_toggled(button_pressed: bool) -> void:
	if processing_animation_press:
		return
	processing_animation_press = true

	reverse_btn.button_pressed = false
	reverse_btn.icon = ANIMATION_REVERSE

	play_btn.icon = ANIMATION_PLAY if !button_pressed else ANIMATION_PAUSE
	play_direction = 1
	times = 0

	processing_animation_press = false

func _on_reverse_play_btn_toggled(button_pressed: bool) -> void:
	if processing_animation_press:
		return
	processing_animation_press = true

	play_btn.button_pressed = false
	play_btn.icon = ANIMATION_PLAY

	reverse_btn.icon = ANIMATION_REVERSE if !button_pressed else ANIMATION_PAUSE
	play_direction = -1
	times = 0

	processing_animation_press = false

func _on_new_file_imported() -> void:
	visible = len(Importer.all_frames) > 2
	$MainContainer/PlayBtn.button_pressed = false
	$MainContainer/ReversePlayBtn.button_pressed = false

	var framedisp = $MainContainer/FrameDisplay

	for child in framedisp.get_children():
		child.queue_free()

	for frame_idx in len(Importer.all_frames):
		var item = FRAME_DISPLAY_ITEM.instantiate() as FrameDisplayItem
		item.setup(frame_idx)
		item.new_frame.connect(_on_frame_display_item_new_frame)
		range_changed.connect(item._range_changed)
		framedisp.add_child(item)

	frame_range = Vector2i(0, len(Importer.all_frames))

	$TagItems/TagPicker.clear()
	$TagItems/TagPicker.add_item("*")
	for tag_idx in len(Importer.all_tags):
		$TagItems/TagPicker.add_item(TAG_TOOLTIP.format({"name": Importer.all_tags[tag_idx].Name, "start": Importer.all_tags[tag_idx].From, "end": Importer.all_tags[tag_idx].To}))
	$TagItems.visible = $TagItems/TagPicker.item_count > 1

	range_changed.emit(frame_range.x, frame_range.y)

func _on_frame_display_item_new_frame(new_value: float) -> void: $MainContainer/FrameSlider.value = new_value

func _on_tag_picker_item_selected(index: int) -> void:
	index -= 1
	if index == -1:
		frame_range = Vector2i(0, len(Importer.all_frames)-2)
		$TagItems/TagDirection.texture = DIRECTION_FORWARD
		ping_pong = false
		play_direction = 1
	else:
		var _me = Importer.all_tags[index]

		frame_range = Vector2i(_me.From, _me.To)
		$TagItems/TagDirection.texture = DIRECTION_ARR[_me.LoopDirection]
		ping_pong = _me.LoopDirection >= AsepriteTag.LoopDir.PINGPONG
		play_direction = -1 if _me.LoopDirection == AsepriteTag.LoopDir.REVERSE || _me.LoopDirection == AsepriteTag.LoopDir.PINGPONGREVERSE else 1

	range_changed.emit(frame_range.x, frame_range.y)

func get_true_height() -> float:
	if !visible:
		return 0.
	return floorf(size.y / 36.) * 36.
