extends Node2D

@export var item_name = ""
@export var item_type = ""
@export var item_effect = ""
@export var effect_magnitude : int
@export var item_texture: Texture
@export var item_scene: PackedScene
@export var spawn_chance: float = 1.0

@onready var player

var scene_path: String = "res://scenes/interface/inventory/inventory_item.tscn"

var in_range = false

func _ready() -> void:
	player = Global.player_node
	var instance = item_scene.instantiate()
	add_child(instance)
	if get_parent().is_in_group("Resource"):
		item_texture = get_parent().resource_type.display_texture

func _input(_event: InputEvent) -> void:
	if in_range == true && Input.is_action_pressed("interact"):
		pickup_item()

func pickup_item():
	var item = {
		"quantity" : 1,
		"type" : item_type,
		"name" : item_name,
		"texture" : item_texture,
		"scene" : item_scene,
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
	item_scene = data["scene"]

func init_items(type, i_name, effect, magnitude, texture, scene):
	item_type = type
	item_name = i_name
	item_effect = effect
	effect_magnitude = magnitude
	item_texture = texture
	item_scene = scene

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		in_range = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		in_range = false
