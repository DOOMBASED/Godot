class_name EquipmentSpell
extends ItemEquipment

@export var valid_spell_types: Array[SpellType]
@export var min_damage: int = 1
@export var max_damage: int = 1

var is_displayed = true

#func interact(body):
	#for type in valid_spell_types:
		#if body.node_type.has(type):
			#body.harvest(randf_range(min_damage,max_damage))
