extends Node2D

@onready var dialogue_ui: Control = $DialogueUI

var npc: Node = null

@warning_ignore("shadowed_variable")
func dialogue_show(npc: Node) -> void:
	branch_check_and_advance()
	var quest_dialogue: Dictionary = npc.quest_get_dialogue()
	if quest_dialogue["text"] != "":
		dialogue_ui.dialogue_show(npc.npc_name, quest_dialogue["text"], quest_dialogue["options"])
	else:
		var dialogue: Dictionary = npc.dialogue_get_current()
		if dialogue:
			dialogue_ui.dialogue_show(npc.npc_name, dialogue["text"], dialogue["options"])

func dialogue_hide() -> void:
	dialogue_ui.dialogue_hide()

func dialogue_handle_choice(option: String) -> void:
	var current_dialogue: Dictionary = npc.dialogue_get_current()
	if not current_dialogue:
		return

	var next_state: String = current_dialogue["options"].get(option, "start")
	npc.dialogue_set_state(next_state)

	if next_state == "end":
		if branch_quests_completed(npc.current_branch_index):
			branch_advance_to_next()
		else:
			dialogue_ui.dialogue_show(npc.npc_name, "Goodbye for now.", {"Close": "exit"})
	elif next_state == "exit":
		dialogue_hide()
	elif next_state == "give_quests":
		quests_offer(npc.dialogue_resource.npc_get_dialogue(npc.npc_id)[npc.current_branch_index]["branch_id"])
		dialogue_show(npc)
	else:
		dialogue_show(npc)


func branch_check_and_advance() -> void:
	if branch_quests_completed(npc.current_branch_index) and npc.current_branch_index < npc.dialogue_resource.npc_get_dialogue(npc.npc_id).size() - 1:
		branch_advance_to_next()

func branch_advance_to_next() -> void:
	npc.dialogue_set_branch(npc.current_branch_index + 1)
	npc.dialogue_set_state("start")
	dialogue_show(npc)

func branch_quests_completed(branch_index: int) -> bool:
	var branch_id: String = npc.dialogue_resource.npc_get_dialogue(npc.npc_id)[branch_index]["branch_id"]
	for quest in npc.quests:
		if quest.unlock_id == branch_id and quest.state != "completed":
			return false
	return true

func quests_offer(branch_id: String) -> void:
	for quest in npc.quests:
		if quest.unlock_id == branch_id and quest.state == "not_started":
			npc.quest_offer(quest.quest_id)

func quests_offer_remaining() -> void:
	for quest in npc.quests:
		if quest.state == "not_started":
			npc.quest_offer(quest.quest_id)
