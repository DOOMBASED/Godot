class_name Item
extends Resource

@export var item_id: String
@export var item_name: String
@export var item_type: String
@export var item_texture: Texture2D
@export var item_rarity: float
@export var item_count: int = 1
var item_quantity: int = 0
var item_scene = "res://scenes/items/item_base.tscn"
