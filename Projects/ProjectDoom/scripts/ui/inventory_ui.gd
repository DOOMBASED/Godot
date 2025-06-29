extends MarginContainer

@onready var slot_grid: GridContainer = $HBoxContainer/InventoryContainer/MarginContainer/VBoxContainer/SlotGrid
@onready var usage_grid: GridContainer = $HBoxContainer/InventoryContainer/MarginContainer/VBoxContainer/UsageGrid
@onready var details_container: VBoxContainer = $HBoxContainer/DetailsContainer
@onready var assign_panel: Panel = $HBoxContainer/InventoryContainer/MarginContainer/VBoxContainer/UsageGrid/AssignPanel
@onready var details_panel: Panel = $HBoxContainer/InventoryContainer/MarginContainer/VBoxContainer/UsageGrid/DetailsPanel
@onready var drop_panel: Panel = $HBoxContainer/InventoryContainer/MarginContainer/VBoxContainer/UsageGrid/DropPanel
@onready var use_panel: Panel = $HBoxContainer/InventoryContainer/MarginContainer/VBoxContainer/UsageGrid/UsePanel
@onready var item_texture_display: TextureRect = $HBoxContainer/DetailsContainer/MarginContainer/VBoxContainer/VBoxContainer/PanelContainer/ItemTextureDisplay
@onready var item_name_label: Label = $HBoxContainer/DetailsContainer/MarginContainer/VBoxContainer/VBoxContainer/ItemNameLabel
@onready var item_type_label: Label = $HBoxContainer/DetailsContainer/MarginContainer/VBoxContainer/VBoxContainer/ItemTypeLabel
@onready var item_effect_label: Label = $HBoxContainer/DetailsContainer/MarginContainer/VBoxContainer/VBoxContainer/ItemEffectLabel
@onready var item_quantity_label: Label = $HBoxContainer/DetailsContainer/MarginContainer/VBoxContainer/VBoxContainer/ItemQuantityLabel
@onready var assign_label: Label = $HBoxContainer/InventoryContainer/MarginContainer/VBoxContainer/UsageGrid/AssignPanel/AssignLabel
@onready var use_label: Label = $HBoxContainer/InventoryContainer/MarginContainer/VBoxContainer/UsageGrid/UsePanel/UseLabel
@onready var use_message_label: Label = $HBoxContainer/DetailsContainer/MarginContainer/VBoxContainer/UseMessageLabel

var player: Player = null
var selected_item: Item = null
var dragged_slot: InventorySlot = null

var assigned: bool = false
var use_cooldown: bool = false

func _ready() -> void:
	player = Global.player
	Inventory.inventory_ui_set(self)
	Inventory.inventory_updated.connect(_on_inventory_updated)
	details_container.visible = false
	_on_inventory_updated()

func slot_set_assignment() -> void:
	assigned = Inventory.hotbar_assignment_check(selected_item)
	if assigned:
		assign_label.text = "Unassign"
	else:
		assign_label.text = "Assign"

func slot_get_index(slot: InventorySlot) -> int:
	for i in range(slot_grid.get_child_count()):
		if slot_grid.get_child(i) == slot:
			return i
	return -1

func slot_dragging() -> InventorySlot:
	var mouse_position: Vector2 = Global.viewport.get_global_mouse_position()
	for slot in slot_grid.get_children():
		var slot_rect = Rect2(slot.global_position, slot.size)
		if slot_rect.has_point(mouse_position):
			return slot
	return null

func slot_drop(slot_1: InventorySlot, slot_2: InventorySlot) -> void:
	var slot_index_1: int = slot_get_index(slot_1)
	var slot_index_2: int = slot_get_index(slot_2)
	if slot_index_1 == -1 || slot_index_2 == -1:
		return
	else:
		if Inventory.inventory_swap_items(slot_index_2, slot_index_1):
			_on_inventory_updated()

func slot_clear() -> void:
	while slot_grid.get_child_count() > 0:
		var child: InventorySlot = slot_grid.get_child(0)
		slot_grid.remove_child(child)
		child.queue_free()

func _on_inventory_updated() -> void:
	slot_clear()
	if selected_item == null:
		use_panel.visible = false
		assign_panel.visible = false
		details_panel.visible = false
		details_container.visible = false
		drop_panel.visible = false
	for item in Inventory.inventory:
		var slot: Node = Inventory.inventory_slot_scene.instantiate()
		slot_grid.add_child(slot)
		slot.drag_start.connect(_on_drag_start)
		slot.drag_stop.connect(_on_drag_stop)
		if item != null:
			slot.slot_set_item(item)
			if item == selected_item:
				slot.self_modulate = Color.GREEN
		else:
			slot.slot_set_empty()

func _on_drag_start(slot: InventorySlot) -> void:
	dragged_slot = slot

func _on_drag_stop() -> void:
	var target_slot: InventorySlot = slot_dragging()
	if target_slot && dragged_slot != target_slot:
		slot_drop(dragged_slot, target_slot)
	dragged_slot = null

func _on_details_button_pressed() -> void:
	assign_label.text = "Assign"
	slot_set_assignment()
	if selected_item != null:
		details_panel.visible = false
		assign_panel.visible = true
		details_container.visible = true
		item_texture_display.texture = selected_item.item_texture
		item_name_label.text = "Name:     " + selected_item.item_name
		item_type_label.text = "Type:     " + selected_item.item_type
		if selected_item is ItemUsable:
			item_effect_label.visible = true
			item_effect_label.text = "Effect:   " + selected_item.item_effect + " +" + str(selected_item.item_magnitude)
		elif selected_item is ItemEquipment:
			item_effect_label.visible = true
			item_effect_label.text = "Effect:   " + selected_item.equipped_item.item_effect
		elif selected_item is not ItemUsable || selected_item is not ItemEquipment:
			item_effect_label.visible = false
		item_quantity_label.text = "Quantity: " + str(selected_item.item_quantity)
	elif selected_item == null:
		details_container.visible = false
		item_texture_display.texture = null
		item_name_label.text = ""
		item_type_label.text = ""
		item_effect_label.text = ""
		item_quantity_label.text = ""

func _on_assign_button_pressed() -> void:
	if selected_item != null:
		if assigned:
			Inventory.item_unassign_hotbar(selected_item.item_id)
			assigned = false
		else:
			Inventory.item_add(selected_item, true)
			assigned = true
		slot_set_assignment()
		_on_inventory_updated()
	else:
		print("Cannot assign this item!")
		print("")

func _on_use_button_pressed() -> void:
	if selected_item != null && !use_cooldown:
		if selected_item is ItemUsable:
			_on_details_button_pressed()
			player.effects.item_effect(selected_item)
			use_cooldown = true
			use_panel.self_modulate = Color.RED
		if selected_item is ItemEquipment:
			print("equip " + selected_item.item_name)

func _on_drop_button_pressed() -> void:
	if selected_item != null:
		var drop_position: Vector2 = player.global_position + Vector2(player.direction_last * 48)
		var drop_offset: Vector2 = player.direction_last
		Inventory.item_drop(selected_item, drop_position + drop_offset)
		Inventory.item_remove(selected_item)
		Inventory.item_remove_from_hotbar(selected_item.item_id)

func _on_close_button_pressed() -> void:
	selected_item = null
	if details_container.visible:
		details_container.visible = false
		details_panel.visible = true
		assign_panel.visible = false
		print("details doesnt work after clicking close")
	else:
		self.visible = false
