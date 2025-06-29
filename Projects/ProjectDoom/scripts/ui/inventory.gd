class_name InventoryNode
extends Node

@onready var inventory_slot_scene = preload("res://scenes/interface/inventory_slot.tscn")

var inventory_max: int = 32
var inventory_size: int = 16
var inventory: Array = []
var inventory_full: bool = false
var inventory_ui: MarginContainer = null

var hotbar_max: int = 9
var hotbar_size: int = 4
var hotbar_inventory: Array = []

signal inventory_updated

func _ready() -> void:
	Global.set_player_inventory(self)
	inventory.resize(inventory_size)
	hotbar_inventory.resize(hotbar_size)

func inventory_ui_set(current_inventory_ui: MarginContainer) -> void:
	inventory_ui = current_inventory_ui

func inventory_swap_items(index_1: int, index_2: int) -> bool:
	if index_1 < 0 || index_1 > inventory.size() || index_2 > inventory.size():
		return false
	var temp = inventory[index_1]
	inventory[index_1] = inventory[index_2]
	inventory[index_2] = temp
	inventory_updated.emit()
	return true

func inventory_increase_size(extra_slots: int) -> void:
	inventory.resize(inventory.size() + extra_slots)
	if inventory.size() >= inventory_max:
		inventory.resize(inventory_max)
	inventory_full = false
	inventory_updated.emit()

func item_add(item: Item, assign: bool = false):
	var assigned: bool = false
	if assign:
		for i in range(hotbar_inventory.size()):
			assigned = item_add_to_hotbar(item)
			inventory_updated.emit()
			return true
		return false
	if !assigned:
		for i1 in range(inventory.size()):
			if inventory[i1] != null && inventory[i1].item_id == item.item_id:
				inventory[i1].item_quantity += item.item_count
				if inventory.count(null) == 0:
					inventory_full = true
				return true
			elif inventory[i1] == null:
				for i2 in range(i1 + 1, inventory.size()):
					if inventory[i2] != null && inventory[i2].item_id == item.item_id:
						inventory[i2].item_quantity += item.item_count
						return true
				inventory[i1] = item
				if inventory.count(null) == 0:
					inventory_full = true
					return false
				else:
					item.item_quantity = item.item_count
					return true
		return false

func item_add_to_hotbar(item) -> bool:
	for i in range(hotbar_size):
		if hotbar_inventory[i] == null:
			hotbar_inventory[i] = item
			return true
	return false

func item_remove(item: Item) -> bool:
	for i in range(inventory.size()):
		if inventory[i] != null && inventory[i].item_id == item.item_id:
			inventory[i].item_quantity -= 1
			if inventory[i].item_quantity <= 0:
				inventory[i] = null
				inventory_full = false
				inventory_ui.selected_item = null
			inventory_updated.emit()
			return true
	return false

func item_remove_from_hotbar(item_id: String) -> bool:
	for i in range(hotbar_inventory.size()):
		if hotbar_inventory[i] != null && hotbar_inventory[i].item_id == item_id:
			if hotbar_inventory[i].item_quantity <= 0:
				hotbar_inventory[i] = null
			inventory_updated.emit()
			return true
	return false

func item_unassign_hotbar(item_id: String) -> bool:
	for i in range(hotbar_inventory.size()):
		if hotbar_inventory[i] != null && hotbar_inventory[i].item_id == item_id:
			hotbar_inventory[i] = null
			inventory_updated.emit()
			return true
	return false

func item_drop_position(item_position: Vector2) -> Vector2:
	var radius: int = 32
	var nearby_items: Array = get_tree().get_nodes_in_group("items")
	for item in nearby_items:
		if item.global_position.distance_to(item_position) < radius:
			var random_offset = Vector2(randf_range(-radius, radius), randf_range(-radius, radius))
			item_position += random_offset
			break
	return item_position

func item_drop(item: Item, drop_position: Vector2) -> void:
	var item_scene: Resource = load(inventory_ui.selected_item.item_scene)
	var item_instance: Node = item_scene.instantiate()
	item_instance.base_item = item
	drop_position = item_drop_position(drop_position)
	item_instance.position = drop_position
	get_tree().get_first_node_in_group("world").add_child(item_instance)
	item_instance.global_transform.origin = drop_position

func hotbar_assignment_check(item: Item):
	return item in hotbar_inventory

func hotbar_swap_items(index1: int, index2: int) -> bool:
	if index1 < 0 || index1 > hotbar_inventory.size() || index2 > hotbar_inventory.size():
		return false
	var temp = hotbar_inventory[index1]
	hotbar_inventory[index1] = hotbar_inventory[index2]
	hotbar_inventory[index2] = temp
	inventory_updated.emit()
	return true
