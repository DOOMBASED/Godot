extends Node2D

@export var base_item: Item

@onready var item_sprite: Sprite2D = $ItemSprite

var player_in_range: bool = false

func _ready() -> void:
	item_sprite.texture = base_item.item_texture

func _process(_delta: float) -> void:
	if player_in_range:
		if Input.is_action_pressed("interact"):
			item_pickup()

func item_pickup() -> void:
	Global.player.recent_pickup_time = 0
	Global.player.recent_pickup = true
	var item = base_item
	if Global.player:
		Inventory.item_add(item)
		self.queue_free()

func _on_item_area_body_entered(body: Node2D) -> void:
	if body == Global.player:
		player_in_range = true

func _on_item_area_body_exited(body: Node2D) -> void:
	if body == Global.player:
		player_in_range = false
