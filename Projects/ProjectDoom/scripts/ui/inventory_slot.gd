class_name InventorySlot
extends Panel

@onready var item_sprite: Sprite2D = $MarginContainer/ItemSprite
@onready var item_quantity_label: Label = $MarginContainer/Control/ItemQuantityLabel
@onready var key_label: Label = $MarginContainer/Control/KeyLabel
@onready var item_slot_button: Button = $ItemSlotButton
@onready var inventory_ui: MarginContainer = Inventory.inventory_ui
@onready var parent = get_parent()

var item: Item = null

var slot_index: int = -1
var slot_color: Color = Color(1.0, 1.0, 1.0, 0.784)

signal drag_start(slot)
signal drag_stop()

func slot_set_index(new_index) -> void:
	slot_index = new_index

func slot_set_item(new_item: Item) -> void:
	item = new_item
	item_sprite.texture = new_item.item_texture
	item_quantity_label.text = str(new_item.item_quantity)
	item_slot_button.visible = true

func slot_set_empty() -> void:
	item_sprite.texture = null
	item_quantity_label.text = ""
	item_slot_button.visible = false

func _on_item_slot_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed():
			for child in parent.get_children():
				if child.self_modulate != slot_color:
					child.self_modulate = slot_color
			self_modulate = Color.GREEN
			inventory_ui.selected_item = item
			inventory_ui.details_panel.visible = true
			inventory_ui.drop_panel.visible = true
			if item is ItemUsable:
				inventory_ui.use_panel.visible = true
				inventory_ui.use_label.text = "Use"
			elif item is ItemEquipment:
				inventory_ui.use_panel.visible = true
				inventory_ui.use_label.text = "Equip"
			else:
				inventory_ui.use_panel.visible = false
			if inventory_ui.details_container.visible:
				inventory_ui._on_details_button_pressed()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				self_modulate = Color.GREEN
				drag_start.emit(self)
			else:
				drag_stop.emit()
				self_modulate = slot_color
