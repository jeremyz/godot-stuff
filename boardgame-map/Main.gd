extends Node2D

func _ready() -> void:
	_on_resize()
	var _none
	_none = get_tree().get_root().connect("size_changed", self, "_on_resize")
	var _r0 = $ShakeBtn.connect("pressed", self, "_on_shake")
	var _r1 = $Clouds.connect("toggled", self, "_on_cloud")
	var _r2 = $Shocks.connect("toggled", self, "_on_shock")
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

func _on_shake() -> void:
	$ViewportContainer/MapViewport/Camera2D.shake($ShakeSlider.value, 1.0)

func _on_shock(on : bool) -> void:
	if on:
		var shader = ShaderMaterial.new()
		shader.shader = load("res://blast.shader")
		var s : Sprite = $ViewportContainer/MapViewport/Sprite
		s.set_material(shader)
	else:
		$ViewportContainer/MapViewport/Sprite.set_material(null)

func _on_cloud(on : bool) -> void:
	$ViewportContainer.material.set_shader_param("smoke_on", on)
