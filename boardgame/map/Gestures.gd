#warning-ignore-all:return_value_discarded
extends Node2D

signal on_gesture

var block = false

func _ready():
	$Timer.wait_time = 0.2
	$Timer.connect("timeout", self, "_on_timeout")

func _unhandled_input(event):
	if block:
		return
	if event is InputEventMagnifyGesture:
		emit_signal("on_gesture", "magnify", event.factor)
	elif event is InputEventScreenDrag:
		emit_signal("on_gesture", "drag", event.relative)
	elif event is InputEventScreenTouch:
		if event.is_pressed():
			emit_signal("on_gesture", "touch", event.position)
	elif event is InputEventMouseButton:
		if event.is_pressed():
			var bx = event.button_index 
			if   bx == BUTTON_RIGHT:
				emit_signal("on_gesture", "home", 0)
			elif bx == BUTTON_LEFT:
				emit_signal("on_gesture", "move_to", get_global_mouse_position())
			elif bx == BUTTON_WHEEL_UP:
				emit_signal("on_gesture", "zoom_in_to", get_global_mouse_position())
			elif bx == BUTTON_WHEEL_DOWN:
				emit_signal("on_gesture", "zoom_out_from", get_global_mouse_position())

func _block():
	block = true
	$Timer.start()

func _on_timeout():
	block = false