class_name ResourceNode
extends RigidBody2D

@export var display_name: String
@export var spawn_chance: float = 1.0
@export var starting_resources: int = 5
@export var launch_speed: float = 100.0
@export var launch_duration: float = 0.25
@export var node_type: Array[ResourceNodeType]
@export var loot: PackedScene
@export var explosion_scene: PackedScene

@onready var spawn_point: Node2D = get_parent()

var explosion_instance
var tween
var loot_instance
var direction

var current_resources:
	set(resource_count):
		current_resources = resource_count
		if resource_count <= 0:
			explosion_instance = explosion_scene.instantiate()
			explosion_instance.position = position
			explosion_instance.one_shot = true
			spawn_point.add_child(explosion_instance)
			tween = get_tree().create_tween()
			tween.tween_property(self, "scale", Vector2(), 0.25)
			tween.tween_callback(queue_free)

func _ready():
	current_resources = starting_resources

func resource_spawn():
	loot_instance = loot.instantiate()
	loot_instance.position = position
	spawn_point.call_deferred("add_child", loot_instance)
	direction = Vector2(randf_range(-1.0,1.0), randf_range(-1.0,1.0)).normalized()
	loot_instance.launch(direction * launch_speed, launch_duration)

func resource_harvest(amount):
	for n in amount:
		resource_spawn()
	current_resources -= amount
