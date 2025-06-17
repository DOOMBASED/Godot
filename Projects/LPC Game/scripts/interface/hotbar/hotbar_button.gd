class_name HotbarButton
extends Button

@export var item: ResourceItem:
	set(item_to_slot):
		item = item_to_slot

@onready var button_label = $InnerBorder/ButtonLabel
@onready var sprite = $InnerBorder/ItemIcon
@onready var outer_border = $OuterBorder

var index

func _ready():
	connect("pressed", _on_pressed)
	button_label.text = "ALT " + name
	sprite.texture = item.texture

func _process(_delta):
	if item == Global.player_node.hand.equipped_item:
		outer_border.modulate = Color.GREEN
	else:
		outer_border.modulate = Color.BLACK
	hotkey_check()

func _on_pressed():
	if item is ItemEquipment:
		if Global.player_node.hand!= null:
			index = str(self.get_index() + 1)
			Global.player_node.hand.equipped_item = item

func hotkey_check():
	if Input.is_action_pressed(name):
		if item is ItemEquipment:
			if Global.player_node.hand != null:
				index = str(self.get_index() + 1)
				button_label.text =  "ALT " + index
				if Global.player_node.hand != null && Input.is_action_just_pressed(index):
					Global.player_node.hand.equipped_item = item
	if Input.is_action_just_pressed("unequip"):
		Global.player_node.hand.equipped_item = null
