extends Node3D

@export var item_name = ""
@export var item_type = ""
@export var item_effect = ""
@export var effect_magnitude : int
@export var item_texture: Texture
@export var item_mesh: PackedScene

@onready var player
@onready var icon_sprite = $Icon
@onready var icon_label = $Label
@onready var debug_mesh = $DebugMesh

var scene_path: String = "res://scenes/inventory_item.tscn"

var in_range = false

func _ready() -> void:
	player = Global.player_node
	var instance = item_mesh.instantiate()
	add_child(instance)
	icon_sprite.texture = item_texture
	debug_mesh.visible = false

func _process(_delta: float) -> void:
	icon_sprite.texture = item_texture
	icon_label.font_size = 32
	icon_label.text = item_name
	if in_range && player.object == self && Input.is_action_just_pressed("interact"):
		pickup_item()

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
		Global.add_item(item)
		self.queue_free()

func set_item_data(data):
	item_type = data["type"]
	item_name = data["name"]
	item_effect = data["effect"]
	effect_magnitude = data["magnitude"]
	item_texture = data["texture"]
	item_mesh = data["mesh"]

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		in_range = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		in_range = false
