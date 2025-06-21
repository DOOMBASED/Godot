class_name EquipmentTool
extends ItemEquipment

@export var valid_node_types: Array[ResourceNodeType]
@export var min_amount: int = 1
@export var max_amount: int = 1

var is_displayed = true

func interact(body):
	for i in valid_node_types:
		if body.node_type.has(i):
			body.resource_harvest(randf_range(min_amount,max_amount))
