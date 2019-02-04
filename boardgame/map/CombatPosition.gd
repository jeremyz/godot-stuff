#warning-ignore-all:return_value_discarded
extends Area2D

func _ready():
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	add_to_group("CB")

func _on_mouse_entered(): print("enter : %s [ %s %s ]" % [name, position, rotation])
func _on_mouse_exited(): print("exit : %s " % name)