class_name HotbarButton
extends Button

@export var item: ResourceItem:
	set(item_to_slot):
		item = item_to_slot

@onready var button_label = $InnerBorder/ButtonLabel
@onready var sprite = $InnerBorder/ItemIcon
@onready var outer_border = $OuterBorder

var hand
var index

func _ready():
	outer_border.modulate = Color.BLACK
	button_label.text = "ALT " + name
	sprite.texture = item.display_texture

func _process(_delta):
	hotkey_check()

func hotkey_check():
	if Input.is_action_pressed(name):
		if item is ItemEquipment:
			if hand != null:
				index = str(self.get_index() + 1)
				button_label.text =  "ALT " + index
				if hand != null && Input.is_action_just_pressed(index):
					hand.equipped_item = item
					outer_border.modulate = Color.GREEN
	if Input.is_action_just_pressed("unequip"):
		hand.equipped_item = null
		outer_border.modulate = Color.BLACK
		
