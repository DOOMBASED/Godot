class_name Dialogue
extends Resource

@export var dialogues: Dictionary = {}

func load_dialogue(file_path: String) -> void:
	var data: String = FileAccess.get_file_as_string(file_path)
	var parsed_data: Dictionary = JSON.parse_string(data)
	if parsed_data:
		dialogues = parsed_data
	else:
		print("Failed to parse: " + str(parsed_data))

func npc_get_dialogue(npc_id: String) -> Array:
	if npc_id in dialogues:
		return dialogues[npc_id]["trees"]
	else:
		return []
