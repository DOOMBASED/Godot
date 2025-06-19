extends MarginContainer

@export var stats_display_template : PackedScene

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var display_grid = $DisplayGrid

var stats_displays : Array[StatsItemDisplay]
var stats

func _ready():
	visible = true
	stats = player.find_child("Stats")
	stats.connect("stats_amount_changed",on_stats_amount_changed)

func on_stats_amount_changed(type, new_amount):
	var current_display
	for display in stats_displays:
		if display.stats_type == type:
			current_display = display
			current_display.update_count(new_amount)
			break
	if current_display == null:
		var new_display = stats_display_template.instantiate()
		display_grid.add_child(new_display)
		stats_displays.append(new_display)
		new_display.stats_type = type
		new_display.update_count(new_amount)
