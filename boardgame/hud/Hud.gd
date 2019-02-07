extends CanvasLayer

signal on_cam_btn

var cam_btns_state = []

func _ready():
	for btn in get_tree().get_nodes_in_group("cam_btns"):
		cam_btns_state.append(btn.pressed)
		btn.connect("toggled", self, "_on_cam_up")
	load_units()

func load_units():
	var us = load("res://unit/USUnit.tscn")
	var ge = load("res://unit/GEUnit.tscn")
	var tex = load("res://unit/assets/units.png")
	var unit
	var n = 0
	var cont = $UnitContainer
	for y in 3:
		for x in 4:
			if n < 6:
				unit = ge.instance()
			else:
				unit = us.instance()
			n += 1
			unit.set_body(x * 128, y * 128, 128, 128, tex)
			cont.add(unit, 64, 64)

func _on_free_move():
	var btns = get_tree().get_nodes_in_group("cam_btns")
	for i in btns.size():
		if cam_btns_state[i]:
			btns[i].pressed = false
			cam_btns_state[i] = false

func _on_cam_up(val):
	var btns = get_tree().get_nodes_in_group("cam_btns")
	for i in btns.size():
		if cam_btns_state[i]:
			btns[i].pressed = false
			cam_btns_state[i] = false
		if btns[i].pressed:
			cam_btns_state[i] = true
			print("EMIT %s" % btns[i].name)
			emit_signal("on_cam_btn", btns[i].name)
	if not val:
		emit_signal("on_cam_btn", "home")