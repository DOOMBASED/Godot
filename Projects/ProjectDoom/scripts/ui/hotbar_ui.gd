extends MarginContainer

@onready var slot_container: HBoxContainer = $HBoxContainer/HotbarContainer/MarginContainer/VBoxContainer/SlotContainer

var dragged_slot: InventorySlot = null

func _ready() -> void:
	Inventory.inventory_updated.connect(_on_hotbar_updated)
	_on_hotbar_updated()

func hotbar_get_index(slot: InventorySlot) -> int:
	for i in range(slot_container.get_child_count()):
		if slot_container.get_child(i) == slot:
			return i
	return -1

func hotbar_slot_dragging() -> InventorySlot:
	var mouse_position: Vector2 = Global.viewport.get_global_mouse_position()
	for slot in slot_container.get_children():
		var slot_rect: Rect2 = Rect2(slot.global_position, slot.size)
		if slot_rect.has_point(mouse_position):
			return slot
	return null

func hotbar_slot_drop(slot_1: InventorySlot, slot_2: InventorySlot) -> void:
	var slot_index_1: int = hotbar_get_index(slot_1)
	var slot_index_2: int = hotbar_get_index(slot_2)
	if slot_index_1 == -1 || slot_index_2 == -1:
		return
	else:
		if Inventory.hotbar_swap_items(slot_index_1, slot_index_2):
			_on_hotbar_updated()

func hotbar_slot_clear() -> void:
	while slot_container.get_child_count() > 0:
		var child: InventorySlot = slot_container.get_child(0)
		slot_container.remove_child(child)
		child.queue_free()

func _on_hotbar_updated() -> void:
	hotbar_slot_clear()
	for i in range(Inventory.hotbar_size):
		var slot: Node = Inventory.inventory_slot_scene.instantiate()
		slot.slot_set_index(i)
		slot.drag_start.connect(_on_drag_start)
		slot.drag_stop.connect(_on_drag_stop)
		slot_container.add_child(slot)
		if Inventory.hotbar_inventory[i] != null:
			slot.slot_set_item(Inventory.hotbar_inventory[i])
		else:
			slot.slot_set_empty()
			slot.key_label.visible = true
			slot.key_label.text = str(i + 1)
		Inventory.inventory_ui.slot_set_assignment()

func _on_drag_start(slot_control: Control) -> void:
	dragged_slot = slot_control

func _on_drag_stop() -> void:
	var target_slot: InventorySlot = hotbar_slot_dragging()
	if target_slot && dragged_slot != target_slot:
		hotbar_slot_drop(dragged_slot, target_slot)
	dragged_slot = null
