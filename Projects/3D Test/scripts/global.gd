extends Node

@export var inventory_max = 32
@export var hotbar_size = 5
@export var inventory = []
@export var hotbar_inventory = []
@export var spawnable_items = [
	{"name": "Potion", 
	"type": "Consumable", 
	"effect": "Health", 
	"magnitude": 15, 
	"texture": preload("res://tres/test_item_potion_icon.tres"), 
	"mesh": preload("res://scenes/test_item_potion.tscn")},
	
	{"name": "Poison", 
	"type": "Consumable", 
	"effect": "Damage", 
	"magnitude": 10, 
	"texture": preload("res://tres/test_item_poison_icon.tres"), 
	"mesh": preload("res://scenes/test_item_poison.tscn")},
	
	{"name": "Energy", 
	"type": "Consumable", 
	"effect": "Stamina", 
	"magnitude": 25, 
	"texture": preload("res://tres/test_item_energy_icon.tres"), 
	"mesh": preload("res://scenes/test_item_energy.tscn")},
	
	{"name": "Slots+", 
	"type": "Consumable", 
	"effect": "Inventory", 
	"magnitude": 4, 
	"texture": preload("res://tres/test_item_bag_icon.tres"), 
	"mesh": preload("res://scenes/test_item_bag.tscn")},
]

@onready var inventory_slot_scene = preload("res://scenes/inventory_slot.tscn")

var player_node = null

signal inventory_updated
 
func _ready() -> void:
	inventory.resize(16)
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
		added_to_hotbar = add_hotbar_item(item)
		inventory_updated.emit()
	if !added_to_hotbar:
		for i in range(inventory.size()):
			if inventory[i] != null && inventory[i]["type"] == item["type"] && inventory[i]["effect"] == item["effect"]:
				inventory[i]["quantity"] += item["quantity"]
				inventory_updated.emit()
				return true
			elif inventory[i] == null:
				inventory[i] = item
				inventory_updated.emit()
				return true
		return false

func add_hotbar_item(item):
	for i in range(hotbar_size):
		if hotbar_inventory[i] == null:
			hotbar_inventory[i] = item
			return true
	return false

func remove_item(item_type, item_effect):
	for i in range(inventory.size()):
		if inventory[i] != null && inventory[i]["type"] == item_type && inventory[i]["effect"] == item_effect:
			inventory[i]["quantity"] -= 1
			if inventory[i]["quantity"] <= 0:
				inventory[i] = null
			inventory_updated.emit()
			return true
	return false

func remove_hotbar_item(item_type, item_effect):
	for i in range(hotbar_inventory.size()):
		if hotbar_inventory[i] != null && hotbar_inventory[i]["type"] == item_type && hotbar_inventory[i]["effect"] == item_effect:
			if hotbar_inventory[i]["quantity"] <= 0:
				hotbar_inventory[i] = null
			inventory_updated.emit()
			return true
	return false

func unassign_hotbar_item(item_type, item_effect):
	for i in range(hotbar_inventory.size()):
		if hotbar_inventory[i] != null && hotbar_inventory[i]["type"] == item_type && hotbar_inventory[i]["effect"] == item_effect:
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

func adjust_drop_position(position):
	var radius = 10
	var nearby_items = get_tree().get_nodes_in_group("Items")
	for item in nearby_items:
		if item.global_position.distance_to(position) < radius:
			var random_offset = Vector3(randf_range(-radius, radius), 0.0, randf_range(-radius, radius))
			position += random_offset
			break
	return position
