class_name Dialogue
extends Resource

@export var dialogues = {}

func load_dialogue(file_path):
	var data = FileAccess.get_file_as_string(file_path)
	var parsed_data = JSON.parse_string(data)
	if parsed_data:
		dialogues = parsed_data
	else:
		print("Failed to parse: " + parsed_data)

func npc_get_dialogue(npc_id):
	if npc_id in dialogues:
		return dialogues[npc_id]["trees"]
	else:
		return []
