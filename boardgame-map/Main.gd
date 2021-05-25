extends Node2D

func _ready() -> void:
	_on_resize()
	var _none
	_none = get_tree().get_root().connect("size_changed", self, "_on_resize")
	# Area2D._input_event are called only if the event is unwanted, mouse_filter must then be set to IGNIRE 
#	_none  = $ViewportContainer.connect("gui_input", self, "_gui_input")

func _on_resize():
	var wz = OS.get_window_size()
	print("*** resize ***")
	print("WINDOW   : %s" % wz)
	var  margin := 50
	$ViewportContainer.stretch = true
	$ViewportContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$ViewportContainer.rect_position.x = margin
	$ViewportContainer.rect_position.y = margin
	$ViewportContainer.rect_size.x = wz.x - (margin * 2)
	$ViewportContainer.rect_size.y = wz.y - (margin * 2)
	$ViewportContainer/MapViewport.resized()

#func _gui_input(event : InputEvent) -> void:
#	# this could forward the events to MapViewport, but Areas2D on the map won't receive _input_events
#	$ViewportContainer/MapViewport._input_event(null, event, 0)

func _input(event : InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()
