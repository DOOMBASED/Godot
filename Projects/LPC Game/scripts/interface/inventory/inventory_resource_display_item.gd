class_name ResourceItemDisplay
extends HBoxContainer

@onready var display_texture = $TextureRect
@onready var display_label = $Label

var resource_type:
	set(new_type):
		resource_type = new_type
		display_texture.texture = resource_type.display_texture

func update_count(count):
	display_label.text = str(count).pad_zeros(3)
