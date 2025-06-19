extends Node2D

@export var scenes: Array[PackedScene]
@export var chance: float = 0.25

@onready var world = get_tree().get_first_node_in_group("WorldCell")
@onready var sprite = $Sprite2D

var scenes_to_spawn
var item

func _ready():
	spawn_random_scenes()

func spawn_random_scenes():
	if randf() > chance:
		scenes_to_spawn = scenes.pick_random()
		item = scenes_to_spawn.instantiate()
		if randf() > item.spawn_chance:
			item.queue_free()
		else:
			item.position = position + Vector2(randf_range(-16.0, 16.0),randf_range(-16.0, 16.0))
			world.add_child.call_deferred(item)
	queue_free()
