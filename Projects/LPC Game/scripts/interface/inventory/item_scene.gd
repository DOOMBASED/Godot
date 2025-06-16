extends RigidBody2D

@onready var player = Global.player_node

var direction = Vector2.ZERO
var speed = 240

var inventory_item

func _ready() -> void:
	inventory_item = get_parent()

func _process(delta: float) -> void:
	if inventory_item.in_range && Input.is_action_pressed("interact"):
		move_to_player(delta)

func move_to_player(delta):
	inventory_item.position = inventory_item.position.move_toward(player.position, delta * speed)
	if position.round() == player.position.round():
		queue_free()
