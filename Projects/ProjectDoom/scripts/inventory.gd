class_name InventoryNode
extends Node

@onready var inventory_slot_scene = preload("res://scenes/interface/inventory_slot.tscn")

var inventory_max: int = 32
var inventory_size: int = 16
var inventory: Array = []
var inventory_full: bool = false
var inventory_ui: MarginContainer = null

@warning_ignore("unused_signal")
signal inventory_updated

func _ready() -> void:
	Global.set_player_inventory(self)
	inventory.resize(inventory_size)

func set_inventory_ui(current_inventory_ui: MarginContainer):
	inventory_ui = current_inventory_ui

func item_add(item: Item):
	for i1 in range(inventory.size()):
		if inventory[i1] != null && inventory[i1].item_id == item.item_id:
			inventory[i1].item_quantity += item.item_count
			#inventory_updated.emit()
			if inventory.count(null) == 0:
				inventory_full = true
			return true
		elif inventory[i1] == null:
			for i2 in range(i1 + 1, inventory.size()):
				if inventory[i2] != null && inventory[i2].item_id == item.id:
					inventory[i2].item_quantity += item.item_count
					#inventory_updated.emit()
					return true
			inventory[i1] = item
			if inventory.count(null) == 0:
				inventory_full = true
				return false
			else:
				#inventory_updated.emit()
				return true
	return false
