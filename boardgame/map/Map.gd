#warning-ignore-all:return_value_discarded
extends Node2D

signal cancel_dragging
signal complete_dragging

func _ready():
	$Camera.configure_with($Sprite)
	$Camera.current = true
	$Camera.drag_margin_h_enabled = false
	$Camera.drag_margin_v_enabled = false
	$Gestures.connect("on_gesture", $Camera, "_on_gesture")


# from UnitContainer
func _on_dragging(unit : Unit):
	add_child(unit)
	unit.scale = Vector2(1, 1)
	unit.set_dragging()
	unit.connect("dropped_in", self, "_on_dropped_in")
	unit.connect("dropped_out", self, "_on_dropped_out")

# from Unit
func _on_dropped_in(unit : Unit):
	# remove_child(unit)
	# drop_zone.add_child(unit)
	emit_signal("complete_dragging", unit)
	disconnect_unit(unit)

# from Unit
func _on_dropped_out(unit : Unit):
	remove_child(unit)
	emit_signal("cancel_dragging", unit)
	disconnect_unit(unit)

func disconnect_unit(unit : Unit):
	unit.disconnect("dropped_in", self, "_on_dropped_in")
	unit.disconnect("dropped_out", self, "_on_dropped_out")