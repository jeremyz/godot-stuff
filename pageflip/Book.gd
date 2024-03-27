@icon("res://Book.png")
#warning-ignore-all:return_value_discarded
extends NinePatchRect

class_name Book

@export var flip_duration := 0.8
@export var cylinder_ratio := 0.3
@export var border_width := 100

@onready var time := 0.0
@onready var pages_dir := "."
@onready var pages := [0, 0, 0]
@onready var flipping := false

@onready var page := $Clipper/Page
@onready var slider := $Clipper/Slider

func _ready() -> void:
	slider.visible = false
	slider.self_modulate.a = 0.5
	page.material.set_shader_parameter("time", 0)
	page.material.set_shader_parameter("rect", page.size)
	page.material.set_shader_parameter("flip_duration", flip_duration)
	page.material.set_shader_parameter("cylinder_ratio", cylinder_ratio)
	$Clipper/Left.size.x = border_width
	$Clipper/Left.gui_input.connect(_on_slider_input.bind(true))
	$Clipper/Left.mouse_entered.connect(_on_slider.bind(true, true))
	$Clipper/Left.mouse_exited.connect(_on_slider.bind(true, false))
	$Clipper/Right.size.x = border_width
	$Clipper/Right.gui_input.connect(_on_slider_input.bind(false))
	$Clipper/Right.mouse_entered.connect(_on_slider.bind(false, true))
	$Clipper/Right.mouse_exited.connect(_on_slider.bind(false, false))

func show_book(dir : String, current_page : int, max_page : int) -> void:
	pages_dir = dir
	pages[0] = current_page
	pages[2] = max_page
	_reset_shader(false)
	visible = true

func _slider(left : bool) -> void:
	slider.size = Vector2(border_width, page.size.y) # FIXME
	var img := slider.get_child(0)
	img.position = Vector2(0, (slider.size.y - img.size.y) / 2)
	if left:
		slider.position.x = 0
		img.flip_h = true
	else:
		slider.position.x = page.size.x -border_width
		img.flip_h = false
		img.position.x = slider.size.x - slider.get_child(0).size.x

func _process(delta : float) -> void:
	if flipping:
		time += delta
		if time > flip_duration:
			time += 1
			flipping = false
			if (pages[0] > pages[1] and pages[1] == 0) or (pages[0] < pages[1] and pages[1] == pages[2]):
				slider.visible = false
			pages[0] = pages[1]
		page.material.set_shader_parameter("time", time)

func _on_prev() -> void:
	pages[1] = pages[0] - 1
	_reset_shader(true)

func _on_next() -> void:
	pages[1] = pages[0] + 1
	_reset_shader(true)

func _reset_shader(flip : bool) -> void:
	time = 0.0
	flipping = flip
	var flip_left = pages[0] < pages[1]
	page.material.set_shader_parameter("flip_left", flip_left)
	page.material.set_shader_parameter("cylinder_direction", Vector2(5.0, 1.0 if flip_left else -1.0))
	page.material.set_shader_parameter("current_page", load("res://%s/%02d.png" % [pages_dir, pages[0]]))
	page.material.set_shader_parameter("next_page", load("res://%s/%02d.png" % [pages_dir, pages[1]]))

func _on_slider(left : bool, entered : bool) -> void:
	if (left and pages[0] == 0) or (not left and pages[0] == pages[2]):
		slider.visible = false
	else:
		_slider(left)
		slider.visible = entered

func _on_slider_input(event : InputEvent, left : bool) -> void:
	if not flipping and event is InputEventMouseButton and event.is_pressed():
		if  (left and pages[0] == 0) or (not left and pages[0] == pages[2]):
			return
		if left:
			_on_prev()
		else:
			_on_next()
