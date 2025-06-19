extends Node

@export var inventory_max = 16
@export var inventory_size = 8
@export var hotbar_size = 8
@export var inventory = []
@export var hotbar_inventory = []

@onready var inventory_slot_scene = preload("res://scenes/interface/hotbar/hotbar_item_button.tscn")

var player_node = null
var inventory_full = false

signal inventory_updated
 
func _ready() -> void:
	inventory.resize(inventory_size)
	hotbar_inventory.resize(hotbar_size)

func set_player(player):
	player_node = player

func increase_inventory_size(extra_slots):
	inventory.resize(inventory.size() + extra_slots)
	if inventory.size() >= inventory_max:
		inventory.resize(inventory_max)
	inventory_updated.emit()

func add_item(item, to_hotbar = false):
	var added_to_hotbar = false
	if to_hotbar:
		for i in range(hotbar_inventory.size()):
			added_to_hotbar = add_hotbar_item(item)
			inventory_updated.emit()
			return true
		return false
	if !added_to_hotbar:
		for i in range(inventory.size()):
			if inventory[i] == null:
				inventory[i] = item
				if inventory.count(null) == 0:
					inventory_full = true
					return false
				else:
					return true
			elif inventory[i] != null && inventory[i]["id"] == item["id"]:
				inventory[i]["quantity"] += item["quantity"]
				if inventory.count(null) == 0:
					inventory_full = true
				return true
		return false

func add_hotbar_item(item):
	for i in range(hotbar_size):
		if hotbar_inventory[i] == null:
			hotbar_inventory[i] = item
			return true
	return false

func remove_item(item_id):
	for i in range(inventory.size()):
		if inventory[i] != null && inventory[i]["id"] == item_id:
			inventory[i]["quantity"] -= 1
			if inventory[i]["quantity"] <= 0:
				inventory[i] = null
				inventory_full = false
			inventory_updated.emit()
			return true
	return false

func remove_hotbar_item(item_id):
	for i in range(hotbar_inventory.size()):
		if hotbar_inventory[i] != null && hotbar_inventory[i]["id"] == item_id:
			if hotbar_inventory[i]["quantity"] <= 0:
				hotbar_inventory[i] = null
			inventory_updated.emit()
			return true
	return false

func unassign_hotbar_item(item_id):
	for i in range(hotbar_inventory.size()):
		if hotbar_inventory[i] != null && hotbar_inventory[i]["id"] == item_id:
			hotbar_inventory[i] = null
			inventory_updated.emit()
			return true
	return false

func check_hotbar_assignment(item_to_check):
	return item_to_check in hotbar_inventory

func swap_inventory_items(index1, index2):
	if index1 < 0 || index1 > inventory.size() || index2 > inventory.size():
		return false
	var temp = inventory[index1]
	inventory[index1] = inventory[index2]
	inventory[index2] = temp
	inventory_updated.emit()
	return true

func swap_hotbar_items(index1, index2):
	if index1 < 0 || index1 > hotbar_inventory.size() || index2 > hotbar_inventory.size():
		return false
	var temp = hotbar_inventory[index1]
	hotbar_inventory[index1] = hotbar_inventory[index2]
	hotbar_inventory[index2] = temp
	inventory_updated.emit()
	return true

func drop_item(item_data, drop_position):
	var item_scene = load(item_data["scene_path"])
	var item_instance = item_scene.instantiate()
	item_instance.set_item_data(item_data)
	drop_position = adjust_drop_position(drop_position)
	item_instance.position = drop_position
	get_tree().current_scene.add_child(item_instance)
	item_instance.global_transform.origin = drop_position

func adjust_drop_position(position):
	var radius = 64
	var nearby_items = get_tree().get_nodes_in_group("Items")
	for item in nearby_items:
		if item.global_position.distance_to(position) < radius:
			var random_offset = Vector2(randf_range(-radius, radius), randf_range(-radius, radius))
			position += random_offset
			break
	return position
