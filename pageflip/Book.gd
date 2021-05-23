#warning-ignore-all:return_value_discarded
extends NinePatchRect

class_name Book, "res://Book.png"

export var duration := 0.8
export var border_width := 100

onready var time := 0.0
onready var n := 0
onready var pages_dir := "."
onready var max_page := 0
onready var flipping := false
onready var imgs := [0, 0]

onready var page := $Clipper/Page
onready var slider := $Clipper/Slider

onready var scale := 1.0
onready var x_max := 0.0
onready var y_max := 0.0
onready var dragging := false
onready var drag_pos := Vector2(0, 0)

func _ready() -> void:
	page.material.set_shader_param("time", 0)
	page.material.set_shader_param("flip_duration", duration)
	page.material.set_shader_param("cylinder_ratio", 0.3)
	page.material.set_shader_param("rect", page.rect_size)
	$Clipper.connect("gui_input", self, "_on_book_input")
	$Clipper/Left.connect("gui_input", self, "_on_input", [true])
	$Clipper/Left.connect("mouse_entered", self, "_on_mouse", [true, true])
	$Clipper/Left.connect("mouse_exited", self, "_on_mouse", [true, false])
	$Clipper/Right.connect("gui_input", self, "_on_input", [false])
	$Clipper/Right.connect("mouse_entered", self, "_on_mouse", [false, true])
	$Clipper/Right.connect("mouse_exited", self, "_on_mouse", [false, false])
	_border($Clipper/Left, true)
	_border($Clipper/Right, false)
	_slider(false)
	slider.visible = false
	slider.self_modulate.a = 0.5

func show_book(dir : String, pages : int) -> void:
	pages_dir = dir
	max_page = pages - 1
	_reset(0, 0, duration + 1)
	visible = true

func _border(what : Control, left : bool) -> void:
	what.rect_min_size.x = border_width
	what.rect_size = Vector2(border_width, page.rect_size.y)
	what.rect_position = Vector2(0,0)
	if not left:
		what.rect_position.x = page.rect_size.x - border_width

func _slider(left : bool) -> void:
	slider.rect_size = Vector2(border_width, page.rect_size.y)
	slider.rect_min_size.x = border_width
	var img := slider.get_child(0)
	img.rect_position = Vector2(0, (slider.rect_size.y - img.rect_size.y) / 2)
	if left:
		slider.rect_position.x = 0
		img.flip_h = true
	else:
		slider.rect_position.x = page.rect_size.x -border_width
		img.flip_h = false
		img.rect_position.x = slider.rect_size.x - slider.get_child(0).rect_size.x

func _process(delta : float) -> void:
	if flipping:
		time += delta
		page.material.set_shader_param("time", time)
		if time > duration:
			flipping = false

func _reset(a : int, b : int, dt : float) -> void:
	n = b
	imgs[0] = load("res://%s/%02d.png" % [pages_dir, a])
	imgs[1] = load("res://%s/%02d.png" % [pages_dir, b])
	page.material.set_shader_param("current_page", imgs[0])
	page.material.set_shader_param("next_page", imgs[1])
	if n == 0:
		slider.visible = false
	if n == max_page:
		slider.visible = false
	time = dt
	flipping = (dt == 0.0)

func _on_mouse(left : bool, entered : bool) -> void:
	if scale != 1.0 or (left and n == 0) or (not left and n == max_page):
		return
	_slider(left)
	if entered:
		slider.visible = true
	else:
		slider.visible = false

func _on_input(event : InputEvent, left : bool) -> void:
	if  scale != 1.0 or (left and n == 0) or (not left and n == max_page):
		return
	if event is InputEventMouseButton and event.is_pressed():
		if left:
			_on_prev()
		else:
			_on_next()

func _on_prev() -> void:
#	Sound.page_flip()
	page.material.set_shader_param("flip_left", false)
	page.material.set_shader_param("cylinder_direction", Vector2(5.0, -1.0))
	_reset(n, n - 1, 0.0)

func _on_next() -> void:
#	Sound.page_flip()
	page.material.set_shader_param("flip_left", true)
	page.material.set_shader_param("cylinder_direction", Vector2(5.0, 1.0))
	_reset(n, n + 1, 0.0)

func _on_book_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		accept_event()
	var moved := false
	var scaled := false
	if dragging and (event is InputEventMouseMotion or event is InputEventScreenDrag):
		if scale == 1:
			if n > 0 and event.relative.x > 30:
				dragging = false
				_on_prev()
			if n < max_page and event.relative.x < - 30:
				dragging = false
				_on_next()
		else:
			page.rect_position += event.relative * scale
			moved = true
	if event is InputEventMouseButton:
		var idx = event.button_index
		var pressed := event.is_pressed()
		if idx == 0 or idx == 1:
			if (pressed and not $Timer.is_stopped()) or event.doubleclick:
				if scale == 1:
					scale = 2
				else:
					scale = 1
				scaled = true
				$Timer.stop()
			dragging = pressed
			drag_pos = get_global_mouse_position()
		elif (idx == 4 or idx == 5) and event.is_pressed():
			var v = page.rect_scale.x
			if idx == 4:
				v += 0.1
			if idx == 5:
				v -= 0.1
			v = clamp(v, 1, 2)
			scale = v
			scaled = true
	if scaled:
		x_max = page.rect_size.x - page.rect_size.x * scale
		y_max = page.rect_size.y - page.rect_size.y * scale
		page.rect_scale = Vector2(scale, scale)
		$Clipper/Left.visible = (scale == 1)
		$Clipper/Right.visible = (scale == 1)
	if moved or scaled:
		page.rect_position.x = clamp(page.rect_position.x, x_max, 0)
		page.rect_position.y = clamp(page.rect_position.y, y_max, 0)
