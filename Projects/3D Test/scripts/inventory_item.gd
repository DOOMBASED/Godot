extends Node3D

@export var item_name = ""
@export var item_type = ""
@export var item_effect = ""
@export var effect_magnitude : int
@export var item_texture: Texture
@export var item_mesh: PackedScene

@onready var player

var scene_path: String = "res://scenes/inventory_item.tscn"

func _ready() -> void:
	player = Global.player_node
	var instance = item_mesh.instantiate()
	add_child(instance)

func pickup_item():
	var item = {
		"quantity" : 1,
		"type" : item_type,
		"name" : item_name,
		"texture" : item_texture,
		"mesh" : item_mesh,
		"effect" : item_effect,
		"magnitude" : effect_magnitude,
		"scene_path" : scene_path,
	}
	if Global.player_node:
		Global.add_item(item, false)
		self.queue_free()

func set_item_data(data):
	item_type = data["type"]
	item_name = data["name"]
	item_effect = data["effect"]
	effect_magnitude = data["magnitude"]
	item_texture = data["texture"]
	item_mesh = data["mesh"]

func init_items(type, i_name, effect, magnitude, texture, mesh):
	item_type = type
	item_name = i_name
	item_effect = effect
	effect_magnitude = magnitude
	item_texture = texture
	item_mesh = mesh
