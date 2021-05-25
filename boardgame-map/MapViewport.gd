extends Viewport

onready var camera = $Camera2D
onready var Counter = load("res://Counter.tscn")

var state
enum State {NONE, CLICK_MAP, DRAG_MAP, DRAG_COUNTER}
var dragged_counter
var counter_clamp_x := [0, 0]
var counter_clamp_y := [0, 0]

func _init() -> void:
	state = State.NONE
	disable_3d = true
	transparent_bg = true
	usage = Viewport.USAGE_2D
	physics_object_picking = true

func _ready() -> void:
	var _n
	_n = $Sprite/Area2D.connect("input_event", self, "_input_event")
	add_counter(Counter.instance(), 100, 100)
	add_counter(Counter.instance(), 300, 100)

func add_counter(c, x, y) -> void:
	c.position.x = x
	c.position.y = y
	var _n = c.connect("counter_clicked", self, "_on_counter_clicked")
	add_child(c)

func resized() -> void:
	$Camera2D.configure_with(self, $Sprite, 1)
	update_area()
	var sz = $Sprite.texture.get_size()
	if $Sprite.centered:
		counter_clamp_x = [-sz[0] / 2, sz[0] / 2]
		counter_clamp_y = [-sz[1] / 2, sz[1] / 2]
	else:
		counter_clamp_x = [0, sz[0]]
		counter_clamp_y = [0, sz[1]]

func update_area() -> void:
	$Sprite/Area2D.position.x = camera.to.x
	$Sprite/Area2D.position.y = camera.to.y
	$Sprite/Area2D/CollisionShape2D.shape.extents = camera.visible_size / 2

func _on_counter_clicked(counter, button_index, pressed) -> void:
	if button_index == BUTTON_LEFT:
		if pressed:
#			print("start dragging counter")
			dragged_counter = counter
			state = State.DRAG_COUNTER
		elif state == State.DRAG_COUNTER:
#			print("stop dragging counter")
			state = State.NONE

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if state == State.DRAG_COUNTER:
			if event.button_index == BUTTON_LEFT and not event.pressed:
#				print("stop dragging counter (from map)")
				state = State.NONE
		elif event.pressed:
			if event.button_index == BUTTON_LEFT:
#				print("start dragging map")
				state = State.CLICK_MAP
		else:
			if state == State.NONE:
				if event.button_index == BUTTON_WHEEL_UP:
					camera.zoom_in(event.get_position())
				elif event.button_index == BUTTON_WHEEL_DOWN:
					camera.zoom_out(event.get_position())
				elif event.button_index == BUTTON_RIGHT:
					camera.homing()
				state = State.NONE
			elif event.button_index == BUTTON_LEFT:
				if state == State.CLICK_MAP:
#					print("cancel dragging map")
					camera.slide_to(event.get_position())
#				elif state == State.DRAG_MAP:
#					print("stop dragging map")
				state = State.NONE
			update_area()
	elif event is InputEventMouseMotion:
		if state == State.CLICK_MAP:
			state = State.DRAG_MAP
		elif state == State.DRAG_MAP:
			camera.drag(event.relative)
			update_area()
		elif state == State.DRAG_COUNTER:
			dragged_counter.position += event.relative * camera.zoom
			dragged_counter.position.x = clamp(dragged_counter.position.x, counter_clamp_x[0], counter_clamp_x[1])
			dragged_counter.position.y = clamp(dragged_counter.position.y, counter_clamp_y[0], counter_clamp_y[1])
