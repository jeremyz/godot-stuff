extends Node2D

signal on_gesture

var block = false

func _ready():
	$Timer.wait_time = 0.2
	$Timer.connect("timeout", self, "_on_timeout")

func _unhandled_input(event):
	if block: return
	if event is InputEventMagnifyGesture:	emit_signal("on_gesture", "Magnify", event.factor)
	elif event is InputEventPanGesture:		emit_signal("on_gesture", "Pan", event.delta)
	elif event is InputEventMouseButton:
		if event.is_pressed():
			var bx = event.button_index 
			if   bx == BUTTON_RIGHT:		emit_signal("on_gesture", "HOME", 0)
			elif bx == BUTTON_LEFT:			emit_signal("on_gesture", "MOVE_TO", get_global_mouse_position())
			elif bx == BUTTON_WHEEL_UP:		emit_signal("on_gesture", "ZOOM_IN_TO", get_global_mouse_position())
			elif bx == BUTTON_WHEEL_DOWN:	emit_signal("on_gesture", "ZOOM_OUT_FROM", get_global_mouse_position())
	if not event is InputEventMouseMotion:
		get_tree().set_input_as_handled() # let them reach the Locations and CombatPositions

func _block():
	block = true
	$Timer.start()
func _on_timeout(): block = false