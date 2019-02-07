extends Container

class_name UnitContainer, "res://unit/assets/unit-container.png"

signal dragging(dragged)

export(Vector2) var unit_position = Vector2(32, 32)
export(Vector2) var unit_scale = Vector2(0.5, 0.5)

var from : Vector2
var to : Vector2
var speed = 0
var offset = 20
var pressed = false
var selected_slot : Control = null

var pmax = 0
var pmin = 0
var tween : Tween
var container : HBoxContainer

#func _on_mouse_entered(): print("ENTERED")
#func _on_mouse_exited(): print("EXITED")

func _ready():
	#mouse_filter = Control.MOUSE_FILTER_PASS
	#connect("mouse_exited", self, "_on_mouse_exited")
	#connect("mouse_entered", self, "_on_mouse_entered")
	rect_clip_content = true
	tween = Tween.new()
	add_child(tween)
	container = HBoxContainer.new()
	add_child(container)
	container.rect_min_size.x = rect_size.x
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.connect("resized", self, "_on_resized")

func prepare_unit(unit : Unit):
	unit.set_freezed(true)
	unit.position = unit_position
	unit.scale = unit_scale

func add(unit : Unit, w, h):
	prepare_unit(unit)
	var c = Control.new()
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.rect_min_size = Vector2(w, h)
	c.add_child(unit)
	container.add_child(c)

func _on_cancel_dragging(unit : Unit):
	if selected_slot != null:
		prepare_unit(unit)
		selected_slot.add_child(unit)
		stop_dragged()
	release_input()

func _on_complete_dragging(unit : Unit):
	if selected_slot != null:
		container.remove_child(selected_slot)
		stop_dragged()
	release_input()

func release_input():
	# without that event, the cursor is logically still over the UnitContainer
	var event = InputEventMouseButton.new()
	event.pressed = false
	event.button_index = BUTTON_LEFT
	get_tree().input_event(event)

func _on_resized():
	pmin = rect_size.x - container.rect_size.x

func _gui_input(event):
	if event is InputEventScreenTouch or (event is InputEventMouseButton and event.button_index == BUTTON_LEFT):
		if event.pressed:
			start_pressed()
		else:
			stop_pressed()
	elif pressed and (event is InputEventMouseMotion or event is InputEventScreenDrag):
		check_direction()

func check_direction():
	tween.stop_all()
	to = get_global_mouse_position()
	var v = to - from
	from = to
	var a = v.angle()
	if a < .2 and a > -.2:
		slide(v.x, int(v.length()))
	elif a < -2.94 or a > 2.94:
		slide(v.x, int(-v.length()))
	elif -1.77 < a and a <  -1.37:
		drag()
		if get_local_mouse_position().y < 0:
			drag_out()
	else:
		speed = 0

func slide(dx, v):
	stop_dragged()
	speed = v
	container.rect_position.x += dx
	container.rect_position.x = clamp(container.rect_position.x, pmin - offset, pmax + offset)

func drag():
	stop_slide()
	var m = get_local_mouse_position().x - container.rect_position.x
	for c in container.get_children():
		var cc = c as Control
		if m >= cc.rect_position.x and m <= cc.rect_position.x + cc.rect_size.x:
			selected_slot = c
			break

func drag_out():
	if pressed and selected_slot != null:
		var unit = selected_slot.get_child(0)
		unit.set_freezed(false)
		selected_slot.remove_child(unit)
		emit_signal("dragging", unit)
	pressed = false

func start_pressed():
	pressed = true
	from = get_global_mouse_position()

func stop_pressed():
	pressed = false
	if selected_slot != null:
		stop_dragged()
	else:
		stop_slide()

func stop_dragged():
	selected_slot = null

func stop_slide():
	var to = Vector2(0, 0)
	var pos = container.rect_position
	if pos.x > pmax:
		to.x = pmax
	elif pos.x < pmin:
		to.x = pmin
	else:
		to.x = clamp((pos.x + 10 * speed), pmin - offset, pmax + offset)
	speed = 0
	tween.interpolate_property(container, "rect_position", pos, to, 1, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()