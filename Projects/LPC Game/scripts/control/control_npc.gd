extends CharacterBody2D

@export var npc_id: String
@export var npc_name: String
@export var dialogue_resource: Dialogue
@export var quests: Array[Quest] = []

@onready var dialogue_manager: Node2D = $DialogueManager

var quest_manager: Node = null
var current_state: String = "start"
var current_branch_index: int = 0

func _ready() -> void:
	dialogue_manager.npc = self
	quest_manager = Global.player_node.quest_manager
	dialogue_resource.load_dialogue("res://json/dialogue/dialogue_data.json")

func dialogue_start() -> void:
	var npc_dialogues: Array = dialogue_resource.npc_get_dialogue(npc_id)
	if npc_dialogues.is_empty():
		return
	current_state = "start"
	dialogue_manager.dialogue_show(self)

func dialogue_get_current():
	var npc_dialogues: Array = dialogue_resource.npc_get_dialogue(npc_id)
	if current_branch_index < npc_dialogues.size():
		for dialogue in npc_dialogues[current_branch_index]["dialogues"]:
			if dialogue["state"] == current_state:
				return dialogue
	return null

func dialogue_set_branch(branch_index: int) -> void:
	current_branch_index = branch_index
	current_state = "start"

func dialogue_set_state(state: String) -> void:
	current_state = state

func quest_offer(quest_id: String) -> void:
	for quest in quests:
		if quest.quest_id == quest_id && quest.state == "not_started":
			quest.state = "in_progress"
			quest_manager.quest_add(quest)
			return

func quest_get_dialogue() -> Dictionary:
	var active_quests: Array = quest_manager.quest_get_active()
	for quest in active_quests:
		for objective in quest.objectives:
			if objective in quest.objectives:
				if objective.target_id == npc_id && objective.target_type == "talk_to" && not objective.is_completed:
					if current_state == "start":
						return {"text": objective.objective_dialogue, "options": {}}
	return {"text": "", "options": {}}
