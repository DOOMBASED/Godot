extends Control

@onready var quest_ui: Control = $QuestUI

signal quest_updated(quest_id)
signal objectives_updated(quest_id, objective_id)
signal quest_list_updated()

var quests: Dictionary = {}

func quest_get(quest_id: String):
	return quests.get(quest_id, null)

func quest_get_active() -> Array:
	var active_quests = []
	for quest in quests.values():
		if quest.state == "in_progress":
			active_quests.append(quest)
	return active_quests

func quest_add(quest: Quest) -> void:
	quests[quest.quest_id] = quest
	quest_updated.emit(quest.quest_id)
	quest_ui._on_quest_selected(quest)
	Global.player_node.quest_tracker_check(quest)

func quest_update(quest_id: String, state: String) -> void:
	var quest = quest_get(quest_id)
	if quest:
		quest.state = state
		quest_updated.emit(quest_id)
		if state == "completed":
			quest_remove(quest_id)
			Global.player_node.current_quest = null

func quest_remove(quest_id: String) -> void:
	quests.erase(quest_id)
	quest_list_updated.emit()

func quest_objective_complete(quest_id: String, objective_id: String) -> void:
	var quest = quest_get(quest_id)
	if quest:
		quest.complete_objective(objective_id)
		objectives_updated.emit(quest_id, objective_id)

func quest_log_toggle() -> void:
	quest_ui.quest_log_toggle()
