extends NinePatchRect

class_name HRContainer, "res://HRContainer.svg"

signal item_selected(item)
signal item_dragged(item)

export (bool) var drag_up = true			# zoom and drag direction
export (int) var scroll_offset = 15			# mouse scroll offset
export (int) var drag_offset = 10			# mouse out offset to drag
export (int) var loop_offset = 10			# offset threshold to requeue the items
export (bool) var hide_on_disabled = true	# hide when disabled ?

const DEBUG : bool = false
const DRAG_A : float = 0.2
const DRAG_O : float = 2.94

onready var tween := $Tween
onready var clipper := $Clipper
onready var container := $Clipper/HBoxContainer
onready var mark := $Clipper/HBoxContainer/Mark

var enabled : bool = true
var slot_size : Vector2				# Control size
var slot_offset : int				# slot width + spacing
var mark_offset : int				# mark width + spacing
var selected_slot : Control			# current selected and zoomed slot
var cont_x : int = 0				# HBox x offset
var hsep : int						# half HBox separation - 1 px
var dragging : bool					# are we dragging
var drag_limit : Vector2			# left-right limit
var dragged_item : TextureRect		# the item that is dragged out
var ppos : Vector2					# left click position
var lpos : Vector2					# to compute sliding offset

func _ready() -> void:
	visible = false
	var _r = $Tween.connect("tween_completed", self, "__on_tween_completed")

func dimensions(sz : Vector2, m : int, x :int) -> void:
	clipper.anchor_left = 0
	if drag_up:
		clipper.anchor_top = 1
		clipper.anchor_right = 1
		clipper.anchor_bottom = 1
		clipper.margin_left = m
		clipper.margin_top = -m - x
		clipper.margin_right = -m
		clipper.margin_bottom = -m
	else:
		clipper.anchor_top = 0
		clipper.anchor_right = 1
		clipper.anchor_bottom = 1
		clipper.margin_left = m
		clipper.margin_top = m
		clipper.margin_right = -m
		clipper.margin_bottom = x - m
	container.rect_size = clipper.rect_size
	slot_size.x = sz.y - 2 * m
	slot_size.y = x
	mark.rect_size.y = slot_size.y
	mark.get_node("Mark").rect_size.y = slot_size.x
	if drag_up:
		mark.get_node("Mark").rect_position.y = slot_size.y - slot_size.x
	else:
		mark.get_node("Mark").rect_position.y = 0
	rect_size = sz
	var separation : int = container.get("custom_constants/separation")
	hsep = int(separation / 2.0) - 1
	slot_offset = int(slot_size.x + separation)
	mark_offset = mark.rect_size.x + separation
	drag_limit = Vector2(clipper.rect_position.x, clipper.rect_position.x + clipper.rect_size.x)
	if DEBUG:
		debug()

func debug() -> void:
	print("DEBUG ***********************")
	print("SELF : %s" % rect_size)
	print("Clipper : %s - %s" % [clipper.rect_size, clipper.rect_position])
	print("HBox : %s - %s" % [container.rect_size, container.rect_position])
	print("Slot : %s" % slot_size)
	print("Mark : %s" % mark.rect_size)

func clear() -> void:
	for c in container.get_children():
		if c == mark:
			continue
		container.remove_child(c)
		c.queue_free()

func offset(offset : int) -> void:
	for _i in range(offset):
		container.move_child(container.get_child(0), container.get_child_count() - 1)

func center() -> void:
	if rect_size.x > container.get_minimum_size().x:
		container.rect_position.x = (rect_size.x - container.get_minimum_size().x - (slot_size.y - slot_size.x)) / 2
		__container_updated()

func enable(e : bool) -> void:
	enabled = e
	if not hide_on_disabled:
		return
	if tween.is_active():
		tween.stop_all()
	if e:
		_alpha(1)
		center()
	else:
		_alpha(0)

func _alpha(a : int) -> void:
	if a == 1:
		modulate.a = 0
		visible = true
	var m = modulate
	m.a = a
	tween.interpolate_property(self, "modulate", modulate, m, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()

func __on_tween_completed(_o : Object, _p : NodePath) -> void:
	if modulate.a == 0:
		visible = false
	else:
		visible = true
	dragging = false
	dragged_item = null

func __clear_item(item : TextureRect) -> void:
	item.rect_position.x = 0
	item.rect_position.y = 0

func __prepare_item(item : TextureRect) -> void:
	__clear_item(item)
	item.expand = true
	item.rect_size.x = slot_size.x
	item.rect_size.y = slot_size.x
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if drag_up:
		item.rect_position.y = slot_size.y - slot_size.x

func add(item : TextureRect) -> Control:
	__prepare_item(item)
	var c = Control.new()
	c.rect_min_size = slot_size
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(item)
	if DEBUG:
		var t := TextureRect.new()
		t.texture = load("res://r.png")
		t.expand = true
		t.rect_min_size = c.rect_min_size
		c.add_child(t)
	container.add_child(c)
	__container_updated()
	return c

func __container_updated() -> void:
	cont_x = -1
	if clipper.rect_size.x > container.get_minimum_size().x:
		mark.visible = false
	else:
		mark.visible = true

func __scale_selected_slot(slot: Control, zoomed : bool) -> void:
	if slot == null:
		return
	var d := slot_size.x
	if zoomed:
		d = slot_size.y
	var item : TextureRect = slot.get_child(0)
	item.rect_size.x = d
	item.rect_size.y = d
	slot.rect_min_size.x = d
	if drag_up:
		if zoomed:
			item.rect_position.y = 0
		else:
			item.rect_position.y = slot_size.y - slot_size.x
	if DEBUG:
		var t : TextureRect = slot.get_child(1)
		t.rect_size.x = d
		t.rect_size.y = d
		if zoomed:
			print("  zoomed : %s - %s - %s" % [slot, slot.rect_position, slot.rect_size])

func _process(_delta : float) -> void:
	if not enabled or (selected_slot != null and cont_x == int(container.rect_position.x)):
		return
	cont_x = int(container.rect_position.x)
	var next : Control = null
	var mid : float = rect_size.x / 2 - clipper.margin_left - cont_x
	for c in container.get_children():
		if mid >= c.rect_position.x - hsep and mid <= c.rect_position.x + c.rect_size.x + hsep:
			next = c
			break
	if next == null:
		container.rect_position.x = container.rect_position.x + hsep
		return
	if next == selected_slot or next == mark or next.get_child_count() == 0:
		return
	__scale_selected_slot(selected_slot, false)
	selected_slot = next
	__scale_selected_slot(selected_slot, true)
	emit_signal("item_selected", selected_slot.get_child(0))

func _gui_input(event : InputEvent) -> void:
	if event is InputEventScreenTouch or (event is InputEventMouseButton and event.button_index == BUTTON_LEFT):
		if event.is_pressed():
			ppos = clipper.get_local_mouse_position()
			lpos = ppos
		else:
			release(clipper.get_local_mouse_position())
		dragging = event.is_pressed()
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			__slide(scroll_offset)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			__slide(-scroll_offset)
	elif dragged_item == null and dragging and (event is InputEventMouseMotion or event is InputEventScreenDrag):
		__check_direction()
	accept_event()

func release(rpos : Vector2) -> void:
	if (rpos - ppos).length() < 20:
		var mid : float = rect_size.x / 2 - clipper.margin_left - cont_x
		rpos.x -= container.rect_position.x
		for c in container.get_children():
			if rpos.x >= c.rect_position.x - hsep and rpos.x <= c.rect_position.x + c.rect_size.x + hsep:
				if c.rect_position.x < mid:
					__slide(mid - c.rect_position.x - slot_size.y / 2)
				else:
					__slide(mid - c.rect_position.x)
				cont_x = 0
				break

func __check_direction() -> void:
	tween.stop_all()
	var tmp = clipper.get_local_mouse_position()
	var v = tmp - lpos
	var a = v.angle()
	lpos = tmp
	if drag_up and lpos.y < -drag_offset and lpos.x > drag_limit.x and lpos.x < drag_limit.y:
		__drag_out()
	elif not drag_up and lpos.y > rect_size.y + drag_offset and lpos.x > drag_limit.x and lpos.x < drag_limit.y:
		__drag_out()
	elif a < DRAG_A and a > -DRAG_A:
		__slide(v.x)
	elif a < -DRAG_O or a > DRAG_O:
		__slide(v.x)

func __slide(dx : float) -> void:
	container.rect_position.x += dx
	var reference : float = 0
	if rect_size.x > container.get_minimum_size().x:
		reference = (rect_size.x - container.get_minimum_size().x) / 2 + slot_offset / 3.0
	while container.rect_position.x > (reference + loop_offset): # drag right
		var last := container.get_child(container.get_child_count() -1)
		container.move_child(last, 0)
		if last == mark:
			container.rect_position.x -= mark_offset
		else:
			container.rect_position.x -= slot_offset
	while true: # drag left
		var offset =  slot_offset
		var first := container.get_child(0)
		if first == mark:
			offset = mark_offset
		if -container.rect_position.x < (offset + loop_offset - reference):
			break
		container.rect_position.x += offset
		container.move_child(first, container.get_child_count())

func __drag_out() -> void:
	if not selected_slot:
		print("FIXME itemContainer#drag_out : %d" % container.rect_position.x)
		return
	if DEBUG:
		print("  drag out : %s - %s" % [selected_slot, selected_slot.rect_position])
	dragged_item = selected_slot.get_child(0)
	selected_slot.remove_child(dragged_item)
	__clear_item(dragged_item)
	emit_signal("item_dragged", dragged_item)
	enable(false)

func dragged_canceled(item : TextureRect) -> void:
	if selected_slot:
		__prepare_item(item)
		selected_slot.add_child(item)
		if DEBUG:
			selected_slot.move_child(item, 0)
	else:
		print("FIXME  deploy_canceled : selected_slot is null")
	selected_slot = null
	enable(true)

func dragged_completed() -> void:
	if selected_slot:
		container.remove_child(selected_slot)
		selected_slot.queue_free()
		__container_updated()
		enable(true)
	else:
		print("FIXME : dragged completed : selected_slot is null")
