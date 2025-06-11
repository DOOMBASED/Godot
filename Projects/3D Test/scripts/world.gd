extends Node3D

@export var items_to_spawn: int = 0

@onready var items = $Items
@onready var item_spawn_area = $SpawnArea
@onready var spawn_collision : CollisionShape3D = $SpawnArea/CollisionShape3D

func _ready() -> void:
	spawn_random_items(items_to_spawn)

func spawn_item(data, pos):
	var item_scene = preload("res://scenes/inventory_item.tscn")
	var item_instance = item_scene.instantiate()
	item_instance.init_items(data["type"], data["name"], data["effect"], data["magnitude"], data["texture"], data["mesh"])
	item_instance.position = pos
	items.add_child(item_instance)

func spawn_random_items(count):
	var attempts = 0
	var spawned_count = 0
	while spawned_count < count && attempts < items_to_spawn:
		var pos = get_random_position()
		spawn_item(Global.spawnable_items[randi() % Global.spawnable_items.size()], pos)
		spawned_count += 1
		attempts += 1

func get_random_position():
	var area_rect = spawn_collision.shape.get_size()
	var x = randf_range(-area_rect.x, area_rect.x)
	var y = 0.0
	var z = randf_range(-area_rect.z, area_rect.z)
	return item_spawn_area.to_global(Vector3(x, y, z))
