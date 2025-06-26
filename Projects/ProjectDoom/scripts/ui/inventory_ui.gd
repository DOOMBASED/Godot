extends MarginContainer

@onready var slot_grid: GridContainer = $VBoxContainer/MarginContainer/VBoxContainer/SlotGrid
@onready var usage_grid: GridContainer = $VBoxContainer/MarginContainer/VBoxContainer/UsageGrid

func _ready() -> void:
	Inventory.inventory_updated.connect(_on_inventory_updated)
	Inventory.set_inventory_ui(self)
	usage_grid.visible = false
	_on_inventory_updated()

func slot_clear() -> void:
	while slot_grid.get_child_count() > 0:
		var child: InventorySlot = slot_grid.get_child(0)
		slot_grid.remove_child(child)
		child.queue_free()

func _on_inventory_updated() -> void:
	slot_clear()
	for item in Inventory.inventory:
		var slot: Node = Inventory.inventory_slot_scene.instantiate()
		slot_grid.add_child(slot)
		if item != null:
			slot.slot_set_item(item)
		else:
			slot.slot_set_empty()

func _on_use_button_pressed() -> void:
	print("use")

func _on_details_button_pressed() -> void:
	print("details")

func _on_drop_button_pressed() -> void:
	print("drop")

func _on_close_button_pressed() -> void:
	usage_grid.visible = false
