class_name HotbarButton
extends Button

@export var item: ResourceItem:
	set(item_to_slot):
		item = item_to_slot
		icon = item.display_texture

@onready var button_label = $ButtonLabel

var hand
var index

func _ready():
	button_label.text = name
	connect("pressed", _on_pressed)

func _process(_delta):
	hotkey_check()

func _on_pressed():
	if item is ItemEquipment:
		if hand != null:
			index = str(self.get_index() + 1)
			hand.equipped_item = item
			if hand != null:
				hand.equipped_item = item

func hotkey_check():
	if Input.is_action_pressed(name):
		if item is ItemEquipment:
			if hand != null:
				index = str(self.get_index() + 1)
				button_label.text = index
				if hand != null && Input.is_action_just_pressed(index):
					hand.equipped_item = item
	if Input.is_action_just_pressed("unequip"):
		hand.equipped_item = null
		
