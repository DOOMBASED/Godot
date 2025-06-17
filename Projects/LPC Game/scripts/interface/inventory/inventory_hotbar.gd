extends Control

@onready var hotbar_container = $HBoxContainer

var dragged_slot = null

func _ready() -> void:
	Global.inventory_updated.connect(_update_hotbar_ui)
	_update_hotbar_ui()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey && event.pressed:
		for i in range(Global.hotbar_size):
			if Input.is_action_just_pressed("hotbar" + str(i + 1)):
				use_hotbar_item(i)
				break

func _update_hotbar_ui():
	clear_hotbar_container()
	for i in range(Global.hotbar_size):
		var slot = Global.inventory_slot_scene.instantiate()
		slot.set_slot_index(i)
		slot.drag_start.connect(_on_drag_start)
		slot.drag_stop.connect(_on_drag_stop)
		hotbar_container.add_child(slot)
		if Global.hotbar_inventory[i] != null:
			slot.set_item(Global.hotbar_inventory[i])
		else:
			slot.set_empty()
		slot.key_label.visible = true
		slot.quantity_small.visible = true
		slot.quantity_label.visible = false
		slot.key_label.text = str(i + 1)
		slot.update_assignment()

func clear_hotbar_container():
	while hotbar_container.get_child_count() > 0:
		var child = hotbar_container.get_child(0)
		hotbar_container.remove_child(child)
		child.queue_free()

func _on_drag_start(slot_control : Control):
	dragged_slot = slot_control

func get_slot_while_dragging() -> Control:
	var mouse_position = get_global_mouse_position()
	for slot in hotbar_container.get_children():
		var slot_rect = Rect2(slot.global_position, slot.size)
		if slot_rect.has_point(mouse_position):
			return slot
	return null

func get_slot_index(slot: Control) -> int:
	for i in range(hotbar_container.get_child_count()):
		if hotbar_container.get_child(i) == slot:
			return i
	return -1

func drop_slot(slot1: Control, slot2: Control):
	var slot1_index = get_slot_index(slot1)
	var slot2_index = get_slot_index(slot2)
	if slot1_index == -1 || slot2_index == -1:
		return
	else:
		if Global.swap_hotbar_items(slot1_index, slot2_index):
			_update_hotbar_ui()

func _on_drag_stop():
	var target_slot = get_slot_while_dragging()
	if target_slot && dragged_slot != target_slot:
		drop_slot(dragged_slot, target_slot)
	dragged_slot = null

func use_hotbar_item(slot_index):
	if slot_index < Global.hotbar_inventory.size():
		var item = Global.hotbar_inventory[slot_index]
		if item != null:
			Global.player_node.apply_item_effect(item)
			var use = Global.player_node.should_use
			if use:
				item["quantity"] -= 1
				if item["quantity"] <= 0:
					Global.hotbar_inventory[slot_index] = null
					Global.remove_item(item["type"], item["effect"])
				Global.inventory_updated.emit()
			elif !use:
				print("Item not used")
