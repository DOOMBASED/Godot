class_name StatsItemDisplay
extends HBoxContainer

@export var display_texture: TextureRect
@export var display_label: Label

var stats_type: Resource:
	set(new_type):
		stats_type = new_type
		display_texture.texture = stats_type.display_texture

func stats_update(count: int) -> void:
	display_label.text = str(count).pad_zeros(3) + " XP"
