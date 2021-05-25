extends Sprite

signal counter_clicked(counter, button, pressed)

func _ready() -> void:
	var _n
	_n = $Area2D.connect("input_event", self, "_input_event")
#	_n = $Area2D.connect("mouse_entered", self, "_mouse_entered")
#	_n = $Area2D.connect("mouse_exited", self, "_mouse_exited")

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		emit_signal("counter_clicked", self, event.button_index, event.pressed)

#func _mouse_entered() -> void:
#	print("mouse entered")
#
#func _mouse_exited() -> void:
#	print("mouse exited")
