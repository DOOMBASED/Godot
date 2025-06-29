extends Node2D

@export var base_item: Item

@onready var item_sprite: Sprite2D = $ItemSprite

var player: Player = null
var player_in_range: bool = false

var speed = 360

func _ready() -> void:
	player = Global.player
	item_sprite.texture = base_item.item_texture

func _process(delta: float) -> void:
	if player_in_range:
		if Input.is_action_pressed("interact"):
			if !Inventory.inventory_full:
				item_move_to_player(delta)
				if position.round() == player.position.round():
					item_pickup()

func item_move_to_player(delta: float) -> void:
	position = position.move_toward(player.position.round(), delta * speed)

func item_pickup() -> void:
	var item: Item = base_item
	if player:
		Inventory.item_add(item, false)
		player.recent_pickup = true
		player.recent_pickup_time = 0
		self.queue_free()

func _on_item_area_body_entered(body: Node2D) -> void:
	if body == player:
		player_in_range = true

func _on_item_area_body_exited(body: Node2D) -> void:
	if body == player:
		player_in_range = false
