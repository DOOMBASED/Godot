class_name Stats
extends Control

var stats: Dictionary = {}

signal stats_amount_changed(type, new_amount)

func stats_add(type: Resource, amount: int) -> void:
	if stats.has(type):
		stats[type] = stats[type] + amount
	else:
		stats[type] = amount
	emit_signal("stats_amount_changed", type, stats[type])
