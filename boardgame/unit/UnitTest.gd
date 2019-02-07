extends Node2D

onready var mine = add_unit(load("res://unit/USUnit.tscn"), 256, 256)

func _ready():
	mine.position = Vector2(300, 300)
	add_unit(load("res://unit/GEUnit.tscn"), 256, 0).position = Vector2(150, 150)
	$CanvasLayer/Spent.connect("toggled", self, "_on_spent")
	$CanvasLayer/HitButton.connect("pressed", self, "_on_hit")
	$CanvasLayer/KillButton.connect("pressed", self, "_on_kill")

func add_unit(kls, x, y):
	var unit = kls.instance()
	unit.set_body(x, y, 128, 128, load("res://unit/assets/units.png"))
	add_child(unit)
	return unit

func _on_spent(value):
	mine.set_spent(value)

func _on_hit():
	mine.hit()

func _on_kill():
	mine.kill()

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()
