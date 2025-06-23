extends Node2D

@export var scenes: Array[PackedScene]
@export var chance: float = 0.25

@onready var world: Node2D = get_tree().get_first_node_in_group("WorldCell")
@onready var sprite: Sprite2D = $Sprite2D

var item
var items_to_spawn: PackedScene

func _ready() -> void:
	spawn_random_scenes()

func spawn_random_scenes() -> void:
	if randf() > chance:
		items_to_spawn = scenes.pick_random()
		item = items_to_spawn.instantiate()
		if randf() > item.spawn_chance:
			item.queue_free()
		else:
			item.position = position + Vector2(randf_range(-16.0, 16.0),randf_range(-16.0, 16.0))
			world.add_child.call_deferred(item)
	queue_free()
