extends Node2D

@export var items_to_spawn: int = 0
@export var spawnable_items: Array[Resource] = []

@onready var items: Node2D = $SpawnedItems
@onready var item_spawn_area: Area2D = $SpawnedItemsArea
@onready var item_spawn_collision: CollisionShape2D = $SpawnedItemsArea/CollisionShape2D

func _ready() -> void:
	spawn_random_items(items_to_spawn)


func get_random_position() -> Vector2:
	var area_rect: Rect2 = item_spawn_collision.shape.get_rect()
	var x: float = randf_range(-area_rect.position.x, area_rect.position.x)
	var y: float = randf_range(-area_rect.position.y, area_rect.position.y)
	return item_spawn_area.to_global(Vector2(x, y))

func spawn_random_items(count: int) -> void:
	if items_to_spawn != 0 && spawnable_items.size() != 0:
		var attempts: int = 0
		var spawned_count: int = 0
		while spawned_count < count && attempts < items_to_spawn:
			var pos = get_random_position()
			spawn_item(spawnable_items[randi() % spawnable_items.size()], pos)
			spawned_count += 1
			attempts += 1
		item_spawn_collision.queue_free()

func spawn_item(data: Resource, pos: Vector2) -> void:
	var item_scene: Resource = preload("res://scenes/items/item_base.tscn")
	var item_instance: Node = item_scene.instantiate()
	item_instance.item_initialize(data["id"], data["type"], data["equippable"], data["name"], data["effect"], data["magnitude"], data["texture"], data["scene"], data["quantity"])
	item_instance.position = pos
	items.add_child(item_instance)
