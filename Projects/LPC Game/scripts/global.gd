extends Node

@export var inventory_max: int = 28
@export var inventory_size: int = 8
@export var hotbar_size: int = 8
@export var inventory: Array = []
@export var hotbar_inventory: Array = []

@onready var inventory_slot_scene = preload("res://scenes/interface/hotbar/hotbar_item_button.tscn")

var player_node = null
var player_name: String = ""
var inventory_full: bool = false

signal inventory_updated
 
func _ready() -> void:
	inventory.resize(inventory_size)
	hotbar_inventory.resize(hotbar_size)

func set_player(player: Node):
	player_node = player

func inventory_increase_size(extra_slots: int) -> void:
	inventory.resize(inventory.size() + extra_slots)
	if inventory.size() >= inventory_max:
		inventory.resize(inventory_max)
	inventory_updated.emit()

func inventory_swap_items(index1: int, index2: int) -> bool:
	if index1 < 0 || index1 > inventory.size() || index2 > inventory.size():
		return false
	var temp = inventory[index1]
	inventory[index1] = inventory[index2]
	inventory[index2] = temp
	inventory_updated.emit()
	return true

func item_add(item: Dictionary, to_hotbar = false):
	var added_to_hotbar: bool = false
	if to_hotbar:
		for i in range(hotbar_inventory.size()):
			added_to_hotbar = item_add_to_hotbar(item)
			inventory_updated.emit()
			return true
		return false
	if !added_to_hotbar:
		for i1 in range(inventory.size()):
			if inventory[i1] != null && inventory[i1]["id"] == item["id"]:
				inventory[i1]["quantity"] += item["quantity"]
				if inventory.count(null) == 0:
					inventory_full = true
				return true
			elif inventory[i1] == null:
				for i2 in range(i1 + 1, inventory.size()):
					if inventory[i2] != null && inventory[i2]["id"] == item["id"]:
						inventory[i2]["quantity"] += item["quantity"]
						return true
				inventory[i1] = item
				if inventory.count(null) == 0:
					inventory_full = true
					return false
				else:
					return true
		return false

func item_add_to_hotbar(item) -> bool:
	for i in range(hotbar_size):
		if hotbar_inventory[i] == null:
			hotbar_inventory[i] = item
			return true
	return false

func item_remove(item_id: String) -> bool:
	for i in range(inventory.size()):
		if inventory[i] != null && inventory[i]["id"] == item_id:
			inventory[i]["quantity"] -= 1
			if inventory[i]["quantity"] <= 0:
				inventory[i] = null
				inventory_full = false
			inventory_updated.emit()
			return true
	return false

func item_remove_from_hotbar(item_id: String) -> bool:
	for i in range(hotbar_inventory.size()):
		if hotbar_inventory[i] != null && hotbar_inventory[i]["id"] == item_id:
			if hotbar_inventory[i]["quantity"] <= 0:
				hotbar_inventory[i] = null
			inventory_updated.emit()
			return true
	return false

func item_unassign_hotbar(item_id: String) -> bool:
	for i in range(hotbar_inventory.size()):
		if hotbar_inventory[i] != null && hotbar_inventory[i]["id"] == item_id:
			hotbar_inventory[i] = null
			inventory_updated.emit()
			return true
	return false

func item_drop(item_data, drop_position: Vector2) -> void:
	var item_scene: Resource = load(item_data["scene_path"])
	var item_instance: Node = item_scene.instantiate()
	item_instance.item_set_data(item_data)
	drop_position = item_drop_position(drop_position)
	item_instance.position = drop_position
	get_tree().current_scene.add_child(item_instance)
	item_instance.global_transform.origin = drop_position

func item_drop_position(position: Vector2) -> Vector2:
	var radius: int = 64
	var nearby_items: Array = get_tree().get_nodes_in_group("Items")
	for item in nearby_items:
		if item.global_position.distance_to(position) < radius:
			var random_offset = Vector2(randf_range(-radius, radius), randf_range(-radius, radius))
			position += random_offset
			break
	return position

func hotbar_swap_items(index1: int, index2: int) -> bool:
	if index1 < 0 || index1 > hotbar_inventory.size() || index2 > hotbar_inventory.size():
		return false
	var temp = hotbar_inventory[index1]
	hotbar_inventory[index1] = hotbar_inventory[index2]
	hotbar_inventory[index2] = temp
	inventory_updated.emit()
	return true

func hotbar_assignment_check(item_to_check):
	return item_to_check in hotbar_inventory
