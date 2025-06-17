extends Node2D

@export var item_id:String = ""
@export var item_name:String = ""
@export var item_type:String = ""
@export var item_effect:String = ""
@export var effect_magnitude: int
@export var item_texture: Texture
@export var spawn_chance: float = 1.0

@onready var sprite: Sprite2D = $Sprite2D

var scene_path: String = "res://scenes/items/inventory_item.tscn"

var direction = Vector2.ZERO
var speed = 480
var in_range = false

func _ready() -> void:
	if get_parent().is_in_group("Resource"):
		item_texture = get_parent().resource_type.display_texture
	else:
		sprite.texture = item_texture

func _process(delta: float) -> void:
	if in_range == true && Input.is_action_pressed("interact"):
		move_to_player(delta)
		if position.round() == Global.player_node.position.round():
			pickup_item()

func pickup_item():
	var item = {
		"quantity" : 1,
		"id" : item_id,
		"type" : item_type,
		"name" : item_name,
		"texture" : item_texture,
		"effect" : item_effect,
		"magnitude" : effect_magnitude,
		"scene_path" : scene_path,
	}
	if Global.player_node:
		Global.add_item(item, false)
		self.queue_free()
		if Global.player_node.update_inventory_on_pickup == true:
			Global.inventory_updated.emit()


func move_to_player(delta):
	position = position.move_toward(Global.player_node.position, delta * speed)

func set_item_data(data):
	item_id = data["id"]
	item_type = data["type"]
	item_name = data["name"]
	item_effect = data["effect"]
	effect_magnitude = data["magnitude"]
	item_texture = data["texture"]
	scene_path = data["scene_path"]

func init_items(id, type, i_name, effect, magnitude, texture, scene):
	item_id = id
	item_type = type
	item_name = i_name
	item_effect = effect
	effect_magnitude = magnitude
	item_texture = texture
	scene_path = scene

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == Global.player_node:
		in_range = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == Global.player_node:
		in_range = false
