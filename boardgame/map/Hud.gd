extends CanvasLayer

signal on_cam_btn

var cam_btns_state = []

func _ready():
	for btn in get_tree().get_nodes_in_group("cam_btns"):
		cam_btns_state.append(btn.pressed)
		btn.connect("toggled", self, "_on_cam_up")


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
		emit_signal("on_cam_btn", "HOME")