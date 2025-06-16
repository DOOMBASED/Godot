class_name Hand
extends Sprite2D

@export var equipped_item: ItemEquipment:
	set(next_equipped):
		equipped_item = next_equipped
		if next_equipped != null && next_equipped.is_displayed == true:
			texture = equipped_item.display_texture
		else:
			texture = null

@onready var collided = false

func _on_weapon_body_entered(body):
	if body is ResourceNode && collided == false:
		if equipped_item != null:
			if equipped_item.has_method("interact"):
				equipped_item.interact(body)
	if equipped_item is EquipmentTool:
		if body.has_method("damage_health"):
			body.damage_health(randf_range(equipped_item.min_amount, equipped_item.max_amount))
	collided = true
	await get_tree().create_timer(0.5).timeout
	collided = false
