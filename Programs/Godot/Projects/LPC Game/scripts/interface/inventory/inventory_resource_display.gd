extends MarginContainer

@export var item_display_template : PackedScene

@onready var player = get_tree().get_first_node_in_group("player")
@onready var display_grid = $DisplayGrid

var displays : Array[ResourceItemDisplay]
var inventory

func _ready():
	visible = true
	inventory = player.find_child("Inventory")
	inventory.connect("resource_amount_changed",on_inventory_amount_changed)

func on_inventory_amount_changed(type, new_amount):
	var current_display
	for display in displays:
		if display.resource_type == type:
			current_display = display
			current_display.update_count(new_amount)
			break
	if current_display == null:
		var new_display = item_display_template.instantiate()
		display_grid.add_child(new_display)
		displays.append(new_display)
		new_display.resource_type = type
		new_display.update_count(new_amount)
