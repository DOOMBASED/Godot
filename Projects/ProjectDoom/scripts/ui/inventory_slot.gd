class_name InventorySlot
extends Panel

@onready var item_sprite: Sprite2D = $MarginContainer/ItemSprite
@onready var item_quantity_label: Label = $MarginContainer/Control/ItemQuantityLabel
@onready var item_slot_button: Button = $ItemSlotButton

var item: Item = null

func slot_set_item(new_item: Item) -> void:
	item = new_item
	item_sprite.texture = new_item.item_texture
	item_quantity_label.text = str(new_item.item_quantity)
	item_slot_button.visible = true

func slot_set_empty() -> void:
	item_sprite.texture = null
	item_quantity_label.text = ""
	item_slot_button.visible = false

func _on_item_slot_button_pressed() -> void:
	Inventory.inventory_ui.usage_grid.visible = true
