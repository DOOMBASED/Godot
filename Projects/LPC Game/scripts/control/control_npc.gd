extends CharacterBody2D

@export var npc_id: String
@export var npc_name: String
@export var dialogue_resource: Dialogue

var current_state = "start"
var current_branch_index = 0

func _ready():
	dialogue_resource.load_from_json("res://json/dialogue/dialogue_data.json")

func start_dialogue():
	var npc_dialogues = dialogue_resource.get_npc_dialogue(npc_id)
	if npc_dialogues.is_empty():
		return

func get_current_dialogue():
	var npc_dialogues = dialogue_resource.get_npc_dialogue(npc_id)
	if current_branch_index < npc_dialogues.size():
		for dialogue in npc_dialogues[current_branch_index]["dialogues"]:
			if dialogue["state"] == current_state:
				return dialogue
	return null

func set_dialogue_tree(branch_index):
	current_branch_index = branch_index
	current_state = "start"

func set_dialogue_state(state):
	current_state = state
