extends Camera2D

export(float) var duration = 0.3	# move interpolation duration
export(float) var zoom_steps = 3	# zoom steps needed

onready var tween = $Tween
onready var timer = $Timer
onready var from := Vector3()
onready var to := Vector3()

var viewport_size : Vector2
var zoom_boundaries : Vector2
var map_center : Vector2
var texture_size : Vector2
var visible_size : Vector2
var dt_zoom : float

var shake_amplitude : int
var default_offset : Vector2

func _ready() -> void:
	zoom_boundaries = Vector2(0, 0)
	timer.connect("timeout", self, "_on_shake_timeout")
	set_process(false)

func configure_with(viewport : Viewport, map : Sprite, zoom_in : float) -> void:
	viewport_size = viewport.size
	texture_size = map.texture.get_size() * map.scale
	if map.centered:
		position.x = 0
		position.y = 0
	else:
		position.x = texture_size.x / 2
		position.y = texture_size.y / 2
	map_center = position
	zoom_boundaries.x = zoom_in
	zoom_boundaries.y = max(texture_size.x / viewport_size.x, texture_size.y / viewport_size.y)
	zoom.x = zoom_boundaries.y
	zoom.y = zoom_boundaries.y
	set_to(position, zoom.x)
	dt_zoom = (zoom_boundaries.y - zoom_boundaries.x) / zoom_steps
	print("VIEWPORT : %s" % viewport_size)
	print("TEXTURE  : %s" % texture_size)
	print("CENTER   : %s" % map_center)
	print("ZOOM     : %s %f" % [zoom_boundaries, dt_zoom])

func _process(delta : float) -> void:
	offset = Vector2(rand_range(-shake_amplitude, shake_amplitude), rand_range(-shake_amplitude, shake_amplitude)) * delta + default_offset

func shake(amplitude : int, dt : float = 1.0, delay : float = 0.0) -> void:
	default_offset = offset
	shake_amplitude = amplitude
	timer.wait_time = dt
	tween.stop_all()
	if delay > 0:
		yield(get_tree().create_timer(delay), "timeout")
	set_process(true)
	timer.start()

func _on_shake_timeout() -> void:
	set_process(false)
	tween.interpolate_property(self, "offset", offset, default_offset, 0.1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()

func is_zoomed_in() -> bool:
	return zoom.x == zoom_boundaries.x

func is_zoomed_out() -> bool:
	return zoom.x == zoom_boundaries.y

func move_to(pos : Vector2, z : float, d : float) -> void:
	if tween.is_active():
		return
	set_from()
	set_to(pos, z)
#	print("Move %s -> %s" % [from, to])
	if d == 0:
		__apply(to)
		return
	tween.interpolate_method(self, "__apply", from, to, d, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func __apply(v : Vector3) -> void:
	position.x = v.x
	position.y = v.y
	zoom.x = v.z
	zoom.y = v.z

func set_from() -> void:
	from.x = position.x
	from.y = position.y
	from.z = zoom.x

func set_to(p : Vector2, z : float) -> void:
	z = clamp(z, zoom_boundaries.x, zoom_boundaries.y)
	p = clamp_pos(p, z)
	to.x = p.x
	to.y = p.y
	to.z = z

func clamp_pos(pos : Vector2, z : float) -> Vector2:
	visible_size = viewport_size * z
	var delta = texture_size - (visible_size)
	if (delta.x <= 0):
		pos.x = map_center.x
		visible_size.x = texture_size.x
	else:
		var dx = int(delta.x / 2)
		pos.x = clamp(pos.x, map_center.x - dx, map_center.x + dx)
	if (delta.y <= 0):
		pos.y = map_center.y
		visible_size.y = texture_size.y
	else:
		var dy = int(delta.y / 2)
		pos.y = clamp(pos.y, map_center.y - dy, map_center.y + dy)
	return pos

func homing() -> void:
	move_to(map_center, zoom_boundaries.y, duration)

func zoom_in(pos : Vector2) -> void:
	if not is_zoomed_in():
		move_to(__mouse_2_camera(pos, 1), zoom.x - dt_zoom, duration)

func zoom_out(pos : Vector2) -> void:
	if not is_zoomed_out():
		move_to(__mouse_2_camera(pos, 2), zoom.x + dt_zoom, duration)

func slide_to(pos : Vector2) -> void:
	move_to(__mouse_2_camera(pos, 0), zoom.x, duration)

func drag(vec : Vector2) -> void:
	move_to(position - (vec * zoom.x), zoom.x, 0)

func __mouse_2_camera(pos : Vector2, mode : int) -> Vector2:
	# FIXME adjust the final position so that when zoomed the pixel under the cursor is still the same
	var offset = (pos - viewport_size / 2) 
	match mode:
		0:
			return position + offset * zoom.x
		1:
			return position + offset
		2:
			return position + offset
	return position
