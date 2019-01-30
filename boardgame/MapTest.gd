extends Node

func _ready():
	pass
	$Map/Camera.connect("on_free_move", $Hud, "_on_free_move")
	$Hud.connect("on_cam_btn", $Map/Camera, "_on_cam_btn")

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()
