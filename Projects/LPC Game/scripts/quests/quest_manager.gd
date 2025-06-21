extends Node

@onready var quest_ui: Control = $QuestUI

signal quest_updated(quest_id: String)
signal objectives_updated(quest_id: String, objective_id: String)
signal quest_list_updated()

var quests = {}

func quest_get(quest_id: String):
	return quests.get(quest_id, null)

func quest_get_active() -> Array:
	var active_quests = []
	for quest in quests.values():
		if quest.state == "in_progress":
			active_quests.append(quest)
	return active_quests

func quest_add(quest: Quest):
	quests[quest.quest_id] = quest
	quest_updated.emit(quest.quest_id)

func quest_update(quest_id: String, state: String):
	var quest = quest_get(quest_id)
	if quest:
		quest.state = state
		quest_updated.emit(quest_id)
		if state == "completed":
			quest_remove(quest_id)
			Global.player_node.selected_quest = null

func quest_remove(quest_id: String):
	quests.erase(quest_id)
	quest_list_updated.emit()

func quest_objective_complete(quest_id: String, objective_id: String):
	var quest = quest_get(quest_id)
	if quest:
		quest.complete_objective(objective_id)
		objectives_updated.emit(quest_id, objective_id)

func quest_log_toggle():
	quest_ui.quest_log_toggle()
