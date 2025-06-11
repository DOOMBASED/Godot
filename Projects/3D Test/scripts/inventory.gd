extends Control

@onready var player = $"../.."
@onready var inventory_grid = $TextureRect/GridContainer

var dragged_slot = null

func _ready() -> void:
	Global.inventory_updated.connect(_on_inventory_updated)
	_on_inventory_updated()

func _on_inventory_updated():
	clear_grid_container()
	for item in Global.inventory:
		var slot = Global.inventory_slot_scene.instantiate()
		slot.drag_start.connect(_on_drag_start)
		slot.drag_stop.connect(_on_drag_stop)
		inventory_grid.add_child(slot)
		if item != null:
			slot.set_item(item)
		else:
			slot.set_empty()

func clear_grid_container():
	while inventory_grid.get_child_count() > 0:
		var child = inventory_grid.get_child(0)
		inventory_grid.remove_child(child)
		child.queue_free()

func _on_drag_start(slot_control : Control):
	dragged_slot = slot_control

func get_slot_while_dragging() -> Control:
	var mouse_position = self.get_parent().get_global_mouse_position()
	for slot in inventory_grid.get_children():
		var slot_rect = Rect2(slot.global_position, slot.size)
		if slot_rect.has_point(mouse_position):
			return slot
	return null

func get_slot_index(slot: Control) -> int:
	for i in range(inventory_grid.get_child_count()):
		if inventory_grid.get_child(i) == slot:
			return i
	return -1

func drop_slot(slot1: Control, slot2: Control):
	var slot1_index = get_slot_index(slot1)
	var slot2_index = get_slot_index(slot2)
	if slot1_index == -1 || slot2_index == -1:
		return
	else:
		if Global.swap_inventory_items(slot1_index, slot2_index):
			_on_inventory_updated()

func _on_drag_stop():
	var target_slot = get_slot_while_dragging()
	if target_slot && dragged_slot != target_slot:
		drop_slot(dragged_slot, target_slot)
	dragged_slot = null
