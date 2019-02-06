extends Container

class_name UnitContainer, "res://unit/assets/unit-container.png"

var from
var to
var speed = 0
var offset = 20
var dragging = false

var pmax = 0
var pmin = 0
var tween = Tween.new()
var container = HBoxContainer.new()

func _ready():
	rect_clip_content = true
	tween = Tween.new()
	add_child(tween)
	container = HBoxContainer.new()
	container.rect_min_size.x = rect_size.x
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.connect("resized", self, "_on_resized")
	add_child(container)

func add(data, w, h):
	var c = Control.new()
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.rect_min_size = Vector2(w, h)
	c.add_child(data)
	container.add_child(c)

func _on_resized():
	pmin = rect_size.x - container.rect_size.x

func _gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			start_dragging()
		else:
			stop_dragging()
	elif event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			start_dragging()
		else:
			stop_dragging()
	elif dragging and event is InputEventMouseMotion:
		drag()

func drag():
	tween.stop_all()
	to = get_global_mouse_position()
	var v = to - from
	from = to
	var a = v.angle()
	if a < .2 and a > -.2:
		speed = int(v.length())
	elif a < -2.94 or a > 2.94:
		speed = int(-v.length())
	else:
		speed = 0
	if speed != 0:
		container.rect_position.x += v.x
		container.rect_position.x = clamp(container.rect_position.x, pmin - offset, pmax + offset)

func start_dragging():
	dragging = true
	from = get_global_mouse_position()

func stop_dragging():
	dragging = false
	var to = Vector2(0, 0)
	var pos = container.rect_position
	if pos.x > pmax:
		to.x = pmax
	elif pos.x < pmin:
		to.x = pmin
	else:
		to.x = clamp((pos.x + 10 * speed), pmin - offset, pmax + offset)
	tween.interpolate_property(container, "rect_position", pos, to, 1, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()