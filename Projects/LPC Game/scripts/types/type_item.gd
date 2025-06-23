class_name ResourceItem
extends Resource

@export var id: String
@export var name: String
@export var type: String
@export var equippable: Resource
@export var texture: Texture2D
@export var effect: String
@export var magnitude: int
@export var spawn_chance: float

var scene = "res://scenes/items/item_base.tscn"

var quantity: int = 1
