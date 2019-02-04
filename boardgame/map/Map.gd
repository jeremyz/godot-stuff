#warning-ignore-all:return_value_discarded
extends Node2D

func _ready():
	$Camera.configure_with($Sprite)
	$Camera.current = true
	$Camera.drag_margin_h_enabled = false
	$Camera.drag_margin_v_enabled = false
	$Gestures.connect("on_gesture", $Camera, "_on_gesture")