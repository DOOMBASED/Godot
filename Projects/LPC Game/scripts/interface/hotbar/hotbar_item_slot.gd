extends Control

@onready var hotbar_container: HBoxContainer = $ItemHotbar

var dragged_slot: Control = null

func _ready() -> void:
	Global.inventory_updated.connect(_on_hotbar_updated)
	_on_hotbar_updated()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey && event.pressed:
		for i in range(Global.hotbar_size):
			if Input.is_action_just_pressed("hotbar" + str(i + 1)):
				hotbar_use_item(i)
				break

func hotbar_get_index(slot: Control) -> int:
	for i in range(hotbar_container.get_child_count()):
		if hotbar_container.get_child(i) == slot:
			return i
	return -1

func hotbar_use_item(slot_index: int) -> void:
	if Global.player_node.interface.visible == true:
		if slot_index < Global.hotbar_inventory.size():
			var item = Global.hotbar_inventory[slot_index]
			if item != null:
				Global.player_node.item_effect(item)
				var use: bool = Global.player_node.should_use
				if use:
					item["quantity"] -= 1
					if item["quantity"] <= 0:
						Global.hotbar_inventory[slot_index] = null
						Global.item_remove(item["id"])
					Global.inventory_updated.emit()
				elif !use:
					print("Item not used")
				if item["type"] == "Equipment" || item["type"] == "Spell":
					if Global.player_node.hand!= null:
						Global.player_node.hand.equipped_item = item["equippable"]

func hotbar_slot_clear() -> void:
	while hotbar_container.get_child_count() > 0:
		var child: Control = hotbar_container.get_child(0)
		hotbar_container.remove_child(child)
		child.queue_free()

func hotbar_slot_dragging() -> Control:
	var mouse_position: Vector2 = get_global_mouse_position()
	for slot in hotbar_container.get_children():
		var slot_rect: Rect2 = Rect2(slot.global_position, slot.size)
		if slot_rect.has_point(mouse_position):
			return slot
	return null

func hotbar_slot_drop(slot1: Control, slot2: Control) -> void:
	var slot1_index: int = hotbar_get_index(slot1)
	var slot2_index: int = hotbar_get_index(slot2)
	if slot1_index == -1 || slot2_index == -1:
		return
	else:
		if Global.hotbar_swap_items(slot1_index, slot2_index):
			_on_hotbar_updated()

func _on_drag_start(slot_control: Control) -> void:
	dragged_slot = slot_control

func _on_drag_stop() -> void:
	var target_slot: Control = hotbar_slot_dragging()
	if target_slot && dragged_slot != target_slot:
		hotbar_slot_drop(dragged_slot, target_slot)
	dragged_slot = null

func _on_hotbar_updated() -> void:
	hotbar_slot_clear()
	for i in range(Global.hotbar_size):
		var slot: Node = Global.inventory_slot_scene.instantiate()
		slot.slot_set_index(i)
		slot.drag_start.connect(_on_drag_start)
		slot.drag_stop.connect(_on_drag_stop)
		hotbar_container.add_child(slot)
		if Global.hotbar_inventory[i] != null:
			slot.slot_set_item(Global.hotbar_inventory[i])
		else:
			slot.slot_set_empty()
		slot.key_label_box.visible = true
		slot.key_label.text = str(i + 1)
		slot.slot_set_assignment()
