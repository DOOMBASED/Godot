class_name LootableItem
extends Area2D

@export var inventory_item: PackedScene
@export var resource_type: ResourceNodeItem
@export var stats_type: ResourceStats
@export var loot_shape: CollisionShape2D
@export var stats_shape: CollisionShape2D
@export var shadow: Sprite2D
@export var loot_amount: int = 1
@export var xp_amount: int = 2

var stats
var launch_velocity = Vector2.ZERO
var launch_duration = 0.0
var launch_elapsed = 0.0
var launching = false:
	set(is_launching):
		launching = is_launching
		loot_shape.disabled = launching
		shadow.visible = !launching
		stats_shape.disabled = !launching

func _ready():
	connect("body_entered", _on_body_entered)

func _process(delta):
	check_launch(delta)

func _on_body_entered(body):
	if body == Global.player_node:
		var instance = inventory_item.instantiate()
		instance.pickup_item()
		queue_free()

func check_launch(delta):
	if launching:
		position += launch_velocity * delta
		launch_elapsed += delta
		if launch_elapsed >= launch_duration:
			launching = false

func launch(velocity, duration):
	launch_velocity = velocity
	launch_duration = duration
	launch_elapsed = 0.0
	launching = true

func _on_lootable_stats_body_entered(body):
	if body == Global.player_node && launching == true:
		stats = body.find_child("Stats")
		if stats:
			stats.add_stats(stats_type, xp_amount)
