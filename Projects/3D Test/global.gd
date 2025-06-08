extends Node

@onready var inventory_slot_scene = preload("res://inventory_slot.tscn")

var player_node = null
var inventory = []

signal inventory_updated
 
func _ready() -> void:
	inventory.resize(32)

func set_player(player):
	player_node = player

func increase_inventory_size():
	inventory_updated.emit()

func add_item(item):
	for i in range(inventory.size()):
		if inventory[i] != null && inventory[i]["item_type"] == item["item_type"] && inventory[i]["item_effect"] == item["item_effect"]:
			inventory[i]["quantity"] += item["quantity"]
			inventory_updated.emit()
			return true
		elif inventory[i] == null:
			inventory[i] = item
			inventory_updated.emit()
			return true
		return false

func remove_item(item_type, item_effect):
	for i in range(inventory.size()):
		if inventory[i] != null && inventory[i]["item_type"] == item_type && inventory[i]["item_effect"] == item_effect:
			inventory[i]["quantity"] -= 1
			if inventory[i]["quantity"] <= 0:
				inventory[i] = null
			inventory_updated.emit()
			return true
	return false

func drop_item(item_data, drop_position):
	var item_scene = load(item_data["scene_path"])
	var item_instance = item_scene.instantiate()
	item_instance.set_item_data(item_data)
	drop_position = adjust_drop_position(drop_position)
	item_instance.position = drop_position
	get_tree().current_scene.add_child(item_instance)

func adjust_drop_position(position):
	var radius = 10
	var nearby_items = get_tree().get_nodes_in_group("Items")
	for item in nearby_items:
		if item.global_position.distance_to(position) < radius:
			var random_offset = Vector3(randf_range(-radius, radius), 0.0, randf_range(-radius, radius))
			position += random_offset
			print(random_offset)
			break
	return position
