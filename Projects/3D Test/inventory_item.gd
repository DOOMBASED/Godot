@tool
extends Node3D

@export var item_type = ""
@export var item_name = ""
@export var item_effect = ""
@export var item_texture: Texture
@export var item_mesh: PackedScene

@onready var player
@onready var icon_sprite = $Icon
@onready var icon_label = $Icon/Label

var scene_path: String = "res://inventory_item.tscn"

var in_range = false

func _ready() -> void:
	if Engine.is_editor_hint() == false:
		player = Global.player_node
		var instance = item_mesh.instantiate()
		add_child(instance)
		icon_sprite.texture = item_texture

func _process(_delta: float) -> void:
	if Engine.is_editor_hint() == false:
		icon_sprite.texture = item_texture
		icon_label.font_size = 32
		if in_range && player.object == self && Input.is_action_just_pressed("interact"):
			pickup_item()

func pickup_item():
	var item = {
		"quantity" : 1,
		"item_type" : item_type,
		"item_name" : item_name,
		"item_texture" : item_texture,
		"item_mesh" : item_mesh,
		"item_effect" : item_effect,
		"scene_path" : scene_path,
	}
	if Global.player_node:
		Global.add_item(item)
		self.queue_free()
		

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		in_range = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		in_range = false

func set_item_data(data):
	item_type = data["item_type"]
	item_name = data["item_name"]
	item_effect = data["item_effect"]
	item_texture = data["item_texture"]
	item_mesh = data["item_mesh"]
