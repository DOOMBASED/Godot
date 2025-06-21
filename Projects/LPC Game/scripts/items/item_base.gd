extends Node2D

@export var item_id: String = ""
@export var item_name: String = ""
@export var item_type: String = ""
@export var item_effect: String = ""
@export var effect_magnitude: int
@export var item_texture: Texture
@export var equippable: Resource
@export var spawn_chance: float = 1.0

@onready var sprite: Sprite2D = $Sprite2D

var scene_path: String = "res://scenes/items/item_base.tscn"

var direction = Vector2.ZERO
var speed = 480
var in_range = false

func _ready() -> void:
	sprite.texture = item_texture

func _process(delta: float) -> void:
	if in_range == true && item_type && Global.player_node.ray_cast.is_colliding() == false:
		if item_type != "Quest Item" && Input.is_action_pressed("interact"):
			if Global.inventory_full == false:
				item_move_to_player(delta)
				if position.round() == Global.player_node.position.round():
					item_pickup()
			else:
				for i in range(Global.inventory.size()):
					if Global.inventory[i] != null:
						if Global.inventory[i]["id"] == item_id:
							item_move_to_player(delta)
							if position.round() == Global.player_node.position.round():
								item_pickup()
		elif item_type == "Quest Item" && Input.is_action_just_pressed("interact"):
			if Global.player_node.quest_items_check(item_id):
				Global.player_node.quest_objectives_check(item_id, "collection", get_child(0).item_quantity)
				queue_free()
			else:
				print("Item not needed for any active quest.")
				print("")

func item_set_data(data):
	item_id = data["id"]
	item_type = data["type"]
	equippable = data["equippable"]
	item_name = data["name"]
	item_effect = data["effect"]
	effect_magnitude = data["magnitude"]
	item_texture = data["texture"]
	scene_path = data["scene_path"]

func item_initialize(id, type, equip, i_name, effect, magnitude, texture, scene):
	item_id = id
	item_type = type
	equippable = equip
	item_name = i_name
	item_effect = effect
	effect_magnitude = magnitude
	item_texture = texture
	scene_path = scene

func item_move_to_player(delta):
	position = position.move_toward(Global.player_node.position, delta * speed)

func item_pickup():
	Global.player_node.time_since_pickup = 0
	Global.player_node.recent_pickup = true
	var item = {
		"quantity" : 1,
		"id" : item_id,
		"type" : item_type,
		"equippable" : equippable,
		"name" : item_name,
		"texture" : item_texture,
		"effect" : item_effect,
		"magnitude" : effect_magnitude,
		"scene_path" : scene_path,
	}
	if Global.player_node:
		Global.item_add(item, false)
		self.queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == Global.player_node:
		in_range = true
		if item_type == "Quest Item":
			Global.player_node.in_interact_area = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == Global.player_node:
		in_range = false
		if item_type == "Quest Item":
			Global.player_node.in_interact_area = false
