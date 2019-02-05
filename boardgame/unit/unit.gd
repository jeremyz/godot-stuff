#warning-ignore-all:return_value_discarded
#warning-ignore-all:unused_argument
extends Area2D

var freezed = false
var mouse_in = false
var dragging = false
var reverse = false
var dying = false
var death_time = 0
var drop_zone = null

onready var selected_tex = load("res://unit/02_selected.png")
onready var hit_tex = load("res://unit/03_hit.png")
onready var overlay = $Overlay

func _ready():
	$Tween.connect("tween_completed", self, "_on_tween_completed")
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	connect("area_entered", self, "_on_area_entered")
	$Sprite.material = $Sprite.material.duplicate(true)
	$Pawn.material = $Pawn.material.duplicate(true)

func set_texture(x, y, w, h, tex):
	var sprite = $Sprite
	sprite.texture = tex
	sprite.region_enabled = true
	sprite.region_rect = Rect2(x, y, w, h)

func set_freezed(f):
	freezed = f

func kill():
	dying = true

func set_spent(v):
	$Spent.visible = v

func hit():
	overlay.texture = hit_tex
	overlay.visible = true
	_do_hit(0.6, 0.2, true)

func _do_hit(to, time, blink):
	reverse = blink
	var v0 = overlay.modulate
	var v1 = overlay.modulate
	v1.a = to
	$Tween.interpolate_property(overlay, "modulate", v0, v1, time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_tween_completed(a, b):
	if reverse:
		_do_hit(0, 0.2, false)
	else:
		overlay.visible = false

func _input(event):
	if freezed:
		return
	if mouse_in && event is InputEventMouseButton && event.is_pressed():
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
			if drop_zone and overlaps_area(drop_zone):
				position = drop_zone.position
				rotation = drop_zone.rotation
			else:
				drop_zone = null
		get_tree().set_input_as_handled()

func _process(delta):
	if dying:
		_die()

func _set_selected(v):
	overlay.texture = selected_tex
	overlay.visible = v
	overlay.modulate.a = 1

func _die():
	death_time += 0.025
	if death_time >= 4.0:
		death_time = 0
		dying = false
	$Spent.modulate.a = (1 - death_time / 2.0)
	$Pawn.material.set_shader_param("time", death_time)
	$Sprite.material.set_shader_param("amount", pow(death_time, 4))

func _on_mouse_entered():
	mouse_in = true

func _on_mouse_exited():
	mouse_in = false

func _on_area_entered(a):
	if a.is_in_group("drop_zone"):
		drop_zone = a