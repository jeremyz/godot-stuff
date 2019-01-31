extends Area2D

export(Texture) var sprite

var mouseIn = false
var dragging = false
var back = false
var dying = false
var deathTime = 0
var _selected
var _hit
var _drop_zone

func _ready():
	$Sprite.texture = sprite
	_selected = load("res://unit/02_selected.png")
	_hit = load("res://unit/03_hit.png")
	$Tween.connect("tween_completed", self, "_on_tween_completed")
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")

func kill(): dying = true
func set_spent(v): $Spent.visible = v
func is_spent(): return $Spent.visible
func hit():
	$Selected.texture = _hit
	$Selected.visible = true
	_do_hit(0, 0.6, 0.2, true)

func _do_hit(a, b, c, d):
	back = d
	$Tween.interpolate_method(self, "__apply", a, b, c, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$Tween.start()
func __apply(v): $Selected.modulate.a = v
func _on_tween_completed(a, b):
	if back: _do_hit(.6, 0, 0.2, false)
	else: $Selected.visible = false

func _input(event):
	if mouseIn && event is InputEventMouseButton && event.is_pressed():
		rotation = 0
		dragging = true
		_set_selected(true)
		get_tree().set_input_as_handled()
	elif dragging && InputEventMouseMotion:
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			position = get_global_mouse_position()
		else:
			dragging = false
			_set_selected(false)
			if _drop_zone:
				position = _drop_zone.position
				rotation = _drop_zone.rotation
		get_tree().set_input_as_handled()

func _process(delta): if dying: _die()

func _set_selected(v):
	$Selected.texture = _selected
	$Selected.visible = v
	$Selected.modulate.a = 1

func _die():
	deathTime += 0.025
	if deathTime >= 4.0:
		deathTime = 0
		dying = false
	$Spent.modulate.a = (1 - deathTime / 2.0)
	$Pawn.material.set_shader_param("time", deathTime)
	$Sprite.material.set_shader_param("amount", pow(deathTime, 4)) 

func _on_mouse_entered(): mouseIn = true
func _on_mouse_exited():  mouseIn = false
func _on_area_exited(a):
	if a == _drop_zone:
		_drop_zone = null
func _on_area_entered(a):
	if a.is_in_group("drop_zone"):
		_drop_zone = a