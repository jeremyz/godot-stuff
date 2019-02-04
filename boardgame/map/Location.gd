#warning-ignore-all:return_value_discarded
extends Area2D

export(Vector2) var dimension

func _ready():
	var rect = RectangleShape2D.new()
	rect.extents = dimension
	$CollisionShape2D.shape = rect
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	add_to_group("LOC")

func _on_mouse_entered(): print("enter : %s [ %s %s %s ]" % [name, position, dimension, rotation])
func _on_mouse_exited(): print("exit : %s " % name)