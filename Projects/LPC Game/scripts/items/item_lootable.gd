class_name LootableItem
extends Area2D

@export var resource_type: ResourceNodeItem
@export var stats_type: ResourceStats
@export var loot_shape: CollisionShape2D
@export var stats_shape: CollisionShape2D
@export var loot_amount: int = 1
@export var xp_amount: int = 2

var stats: Control
var launch_velocity: Vector2 = Vector2.ZERO
var launch_duration: float = 0.0
var launch_elapsed: float = 0.0
var launching: bool = false:
	set(is_launching):
		launching = is_launching
		loot_shape.disabled = launching
		stats_shape.disabled = !launching

func _ready() -> void:
	connect("body_entered", _on_body_entered)

func _process(delta: float) -> void:
	launch_check(delta)

func launch_check(delta: float) -> void:
	if launching:
		position += launch_velocity * delta
		launch_elapsed += delta
		if launch_elapsed >= launch_duration:
			launching = false

func launch(velocity: Vector2, duration: float) -> void:
	launch_velocity = velocity
	launch_duration = duration
	launch_elapsed = 0.0
	launching = true


func _on_body_entered(body: Node) -> void:
	if body == Global.player_node:
		var item: Resource = preload("res://scenes/items/item_base.tscn")
		var instance: Node = item.instantiate()
		instance.item_initialize(resource_type["id"], resource_type["type"], resource_type["equippable"], resource_type["name"], resource_type["effect"], resource_type["magnitude"], resource_type["texture"], resource_type["scene"], resource_type["quantity"])
		instance.item_pickup()
		queue_free()

func _on_lootable_stats_body_entered(body: Node) -> void:
	if body == Global.player_node && launching == true:
		stats = body.find_child("StatsManager")
		if stats:
			stats.stats_add(stats_type, xp_amount)
