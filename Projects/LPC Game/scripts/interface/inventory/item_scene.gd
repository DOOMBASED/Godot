extends RigidBody2D

var direction = Vector2.ZERO
var speed = 480

var inventory_item

func _ready() -> void:
	inventory_item = get_parent()

func _process(delta: float) -> void:
	if inventory_item.in_range && Input.is_action_pressed("interact"):
		move_to_player(delta)

func move_to_player(delta):
	inventory_item.position = inventory_item.position.move_toward(Global.player_node.position, delta * speed)
	if position.round() == Global.player_node.position.round():
		queue_free()
