extends CharacterBody2D

@export var npc_id: String
@export var npc_name: String

func start_dialogue():
	print(npc_name + ": Hello DOOM! My name is " + npc_name + ".")
	print("")
