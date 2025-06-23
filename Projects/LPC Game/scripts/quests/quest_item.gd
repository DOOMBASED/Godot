extends Area2D

var item_id: String
var item_quantity: int = 1

func _ready() -> void:
	item_id = get_parent().item_id
