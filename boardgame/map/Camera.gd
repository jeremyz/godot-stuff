extends Camera2D

export(Vector2) var margin				# margin around the map (real value is half of it)
export(float) var duration = 0.3		# move interpolation duration
export(float) var magnify_factor = 10	# mouse scroll step divisor

var zoom_boundaries = Vector2(0,0)
var step
var map_position
var map_center
var texture_size

var from = Vector3()
var to = Vector3()

signal on_free_move

# $camera.current = true
# $camera.drag_margin_h_enabled = false
# $camera.drag_margin_v_enabled = false

var coords = {
	"Cellar" : Vector2(195, 1288),
	"NorthTerrace" : Vector2(1045, 472),
	"Keep" : Vector2(995, 703),
	"GreatHall" : Vector2(1280, 620),
	"SouthTerrace" : Vector2(1255, 952),
	"GateHouse" : Vector2(2360, 726),
	"BesottenJenny" : Vector2(2632, 832)
	}

func configure_with(map):
	texture_size = map.texture.get_size()
	map_position = map.position
	if map.centered:
		position.x = 0
		position.y = 0
	else:
		position.x = texture_size.x / 2
		position.y = texture_size.y / 2
	map_center = position
	var vs = get_viewport().size
	zoom_boundaries.y = max((texture_size.x + margin.x) / vs.x, (texture_size.y + margin.y) / vs.y)
	zoom_boundaries.x = max(1600 / vs.x, 800 / vs.y)
	step = (zoom_boundaries.y - zoom_boundaries.x) / 4
	zoom.x = zoom_boundaries.y
	zoom.y = zoom_boundaries.y
	#print("VIEWPORT : %s" % vs)
	#print("zMin:%s zMax:%s step:%s" % [zMin, zMax, step])

func look_at(pos):
	position = clamp_pos(pos, zoom.x)

func zoom_at(z):
	z = clamp(z, zoom_boundaries.x, zoom_boundaries.y)
	zoom.x = z
	zoom.y = z
	position = clamp_pos(position, z)

func move_to(pos, z, d):
	set_from()
	set_to(pos, z)
	# print("Move %s -> %s" % [from, to])
	$Tween.interpolate_method(self, "__apply", from, to, d, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	if not $Tween.is_active():
		$Tween.start()

func __apply(v):
	var z = clamp(v.z, zoom_boundaries.x, zoom_boundaries.y)
	zoom.x = z
	zoom.y = z
	position.x = v.x
	position.y = v.y
	position = clamp_pos(position, zoom.x) # still needed even if called within set_to(…)

func set_from():
	from.x = position.x
	from.y = position.y
	from.z = zoom.x

func set_to(p, z):
	p = clamp_pos(p, z)
	to.x = p.x
	to.y = p.y
	to.z = z

func clamp_pos(pos, z):
	var delta = texture_size - get_viewport().size * z + margin
	if (delta.x <= 0):
		pos.x = map_center.x
	else:
		var dx = delta.x / 2
		pos.x = clamp(pos.x, map_center.x - dx, map_center.x + dx)
	if (delta.y <= 0):
		pos.y = map_center.y
	else:
		var dy = delta.y / 2
		pos.y = clamp(pos.y, map_center.y - dy, map_center.y + dy)
	return pos

func _on_cam_btn(action):
	if action == "HOME":
		move_to(map_center, zoom_boundaries.y, duration)
	else:
		move_to(coords[action], zoom_boundaries.x, duration)

func _on_gesture(action, param):
	emit_signal("on_free_move")
	if action == "HOME":
		move_to(map_center, zoom_boundaries.y, duration)
	elif action == "MOVE_TO":
		move_to(param - map_position, zoom.x, duration)
	elif action == "ZOOM_IN_TO":
		move_to(param - map_position, zoom.x - step, duration)
	elif action == "ZOOM_OUT_FROM":
		move_to(param - map_position, zoom.x + step, duration)
	elif action == "LOOK_AT":
		look_at(param)
	elif action == "ZOOM_AT":
		zoom_at(param)
	elif action == "Magnify":
		if param > 1.0:
			zoom_at(zoom.x - (step / magnify_factor))
		else:
			zoom_at(zoom.x + (step / magnify_factor))