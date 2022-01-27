extends Node2D

onready var cont = $HRContainer
onready var rng := RandomNumberGenerator.new()

var dragged_item : TextureRect = null
var dragged_size := Vector2(80, 80)
var dragged_offset := Vector2(40, 40)
var kill := false

func _ready() -> void:
	var _r = $Reset.connect("pressed", self, "__reset")
	_r = $Show.connect("pressed", self, "__show")
	_r = $Delete.connect("mouse_entered", self, "__on_can_destroy", [true])
	_r = $Delete.connect("mouse_exited", self, "__on_can_destroy", [false])
	_r = $DragUp.connect("toggled", self, "__on_toggle")
	_r = cont.connect("item_dragged", self, "__on_dragged_item")
	cont.dimensions(Vector2(820, 100), 10, 140)
	__reset()

func __show() -> void:
	cont.enable(not cont.enabled)

func __reset() -> void:
	cont.enabled = false
	cont.visible = false
	cont.clear()
	for _i in range(9):
		var t : TextureRect = TextureRect.new()
		t.texture = load("res://icon.png")
		t.modulate = Color(rng.randf(), rng.randf(), rng.randf(), 1)
		cont.add(t)
	cont.enable(true)

func __on_dragged_item(item : TextureRect) -> void:
	dragged_item = item
	dragged_item.rect_size = dragged_size
	add_child(dragged_item)

func __on_toggle(v : bool) -> void:
	cont.drag_up = v
	cont.dimensions(Vector2(820, 100), 10, 140)
	__reset()

func __on_can_destroy(b : bool) -> void:
	kill = b
	if kill:
		$Delete.modulate = Color(1, 0, 0, 1)
	else:
		$Delete.modulate = Color(0, 0, 0, 1)

func _input(event : InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()
	elif (event is InputEventMouseButton and event.button_index == BUTTON_LEFT):
		if dragged_item != null and not event.is_pressed():
			remove_child(dragged_item)
			if kill:
				cont.dragged_completed()
				dragged_item.queue_free()
			else:
				cont.dragged_canceled(dragged_item)
			dragged_item = null
	elif event is InputEventMouseMotion and dragged_item != null:
		dragged_item.rect_position = get_global_mouse_position() - dragged_offset
