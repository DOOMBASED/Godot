extends Node2D

@export var items_to_spawn: int = 0

@onready var items = $SpawnedItems
@onready var item_spawn_area = $SpawnedItemsArea
@onready var spawn_collision : CollisionShape2D = $SpawnedItemsArea/CollisionShape2D

func _ready() -> void:
	spawn_random_items(items_to_spawn)

func spawn_item(data, pos):
	var item_scene = preload("res://scenes/items/item_base.tscn")
	var item_instance = item_scene.instantiate()
	item_instance.init_items(data["id"], data["type"], data["equippable"], data["name"], data["effect"], data["magnitude"], data["texture"], data["scene"])
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
	spawn_collision.queue_free()

func get_random_position():
	var area_rect = spawn_collision.shape.get_rect()
	var x = randf_range(-area_rect.position.x, area_rect.position.x)
	var y = randf_range(-area_rect.position.y, area_rect.position.y)
	return item_spawn_area.to_global(Vector2(x, y))
