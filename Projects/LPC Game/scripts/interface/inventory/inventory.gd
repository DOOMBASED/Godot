class_name Inventory
extends Node

var resources: Dictionary = {}

signal resource_amount_changed(type, new_amount)

func add_resources(type, amount):
	if resources.has(type):
		resources[type] = resources[type] + amount
	else:
		resources[type] = amount
	emit_signal("resource_amount_changed", type, resources[type])
