#warning-ignore-all:return_value_discarded
#warning-ignore-all:unused_argument
extends Area2D

class_name Unit, "res://unit/assets/unit.png"

var freezed = false
var mouse_in = false
var dragging = false
var reverse = false
var dying = false
var death_time = 0
var drop_zone = null
var last_drop_zone = null

onready var hit_overlay = $Overlays/Hit

signal dropped_in (unit)
signal dropped_out (unit)
signal dropped_canceled (unit)

func _ready():
	$Tween.connect("tween_completed", self, "_on_tween_completed")
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	connect("area_entered", self, "_on_area_entered")
	$Body.material = $Body.material.duplicate(true)
	$Pawn.material = $Pawn.material.duplicate(true)

func set_body(x, y, w, h, tex):
	var body = $Body
	body.texture = tex
	body.region_enabled = true
	body.region_rect = Rect2(x, y, w, h) 

func kill():
	dying = true

func set_freezed(f):
	freezed = f

func set_spent(v):
	$SubOverlays/Spent.visible = v

func set_dragging():
	freezed = false
	dragging = true
	_set_selected(true)

func hit():
	hit_overlay.visible = true
	hit_overlay.modulate.a = 0
	_do_hit(0.6, 0.2, true)

func _do_hit(to, time, blink):
	reverse = blink
	var v0 = hit_overlay.modulate
	var v1 = hit_overlay.modulate
	v1.a = to
	$Tween.interpolate_property(hit_overlay, "modulate", v0, v1, time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_tween_completed(a, b):
	if reverse:
		_do_hit(0, 0.2, false)
	else:
		hit_overlay.visible = false

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
				last_drop_zone = drop_zone
				emit_signal("dropped_in", self)
			elif last_drop_zone:
				position = last_drop_zone.position
				rotation = last_drop_zone.rotation
				emit_signal("dropped_canceled", self)
			else:
				drop_zone = null
				emit_signal("dropped_out", self)
		get_tree().set_input_as_handled()

func _process(delta):
	if dying:
		_die()

func _set_selected(v):
	$Overlays/Selected.visible = v

func _die():
	death_time += 0.025
	if death_time >= 4.0:
		death_time = 0
		dying = false
	$SubOverlays/Spent.modulate.a = (1 - death_time / 2.0)
	$Pawn.material.set_shader_param("time", death_time)
	$Body.material.set_shader_param("amount", pow(death_time, 4))

func _on_mouse_entered():
	mouse_in = true

func _on_mouse_exited():
	mouse_in = false

func _on_area_entered(a):
	if a.is_in_group("drop_zone"):
		drop_zone = a