extends Node2D


func _ready():
	$CanvasLayer/Spent.connect("toggled", self, "_on_spent")
	$CanvasLayer/HitButton.connect("pressed", self, "_on_hit")
	$CanvasLayer/KillButton.connect("pressed", self, "_on_kill")

func _on_spent(value): $Unit.set_spent(value)
func _on_hit(): $Unit.hit()
func _on_kill(): $Unit.kill()

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()
