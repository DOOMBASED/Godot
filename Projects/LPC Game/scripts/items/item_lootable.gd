class_name LootableItem
extends Area2D

@export var resource_type: ResourceNodeItem
@export var stats_type: ResourceStats
@export var loot_shape: CollisionShape2D
@export var stats_shape: CollisionShape2D
@export var loot_amount: int = 1
@export var xp_amount: int = 2

var stats
var launch_velocity: Vector2 = Vector2.ZERO
var launch_duration: float = 0.0
var launch_elapsed: float = 0.0
var launching: bool = false:
	set(is_launching):
		launching = is_launching
		loot_shape.disabled = launching
		stats_shape.disabled = !launching

func _ready():
	connect("body_entered", _on_body_entered)

func _process(delta):
	check_launch(delta)

func _on_body_entered(body):
	if body == Global.player_node:
		var item = preload("res://scenes/items/item_base.tscn")
		var instance = item.instantiate()
		instance.init_items(resource_type["id"], resource_type["type"], resource_type["equippable"], resource_type["name"], resource_type["effect"], resource_type["magnitude"], resource_type["texture"], resource_type["scene"])
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
