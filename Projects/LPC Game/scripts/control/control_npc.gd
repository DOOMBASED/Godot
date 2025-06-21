extends CharacterBody2D

@export var npc_id: String
@export var npc_name: String
@export var dialogue_resource: Dialogue
@export var quests: Array[Quest] = []

@onready var dialogue_manager: Node2D = $DialogueManager

var quest_manager: Node = null
var current_state = "start"
var current_branch_index = 0

func _ready():
	dialogue_manager.npc = self
	quest_manager = Global.player_node.quest_manager
	dialogue_resource.load_dialogue("res://json/dialogue/dialogue_data.json")
	print("Quests loaded for " + npc_name + " : " + str(quests.size()))
	print("")


func dialogue_start():
	var npc_dialogues = dialogue_resource.npc_get_dialogue(npc_id)
	if npc_dialogues.is_empty():
		return
	dialogue_manager.dialogue_show(self)

func dialogue_get_current():
	var npc_dialogues = dialogue_resource.npc_get_dialogue(npc_id)
	if current_branch_index < npc_dialogues.size():
		for dialogue in npc_dialogues[current_branch_index]["dialogues"]:
			if dialogue["state"] == current_state:
				return dialogue
	return null

func dialogue_set_branch(branch_index):
	current_branch_index = branch_index
	current_state = "start"

func dialogue_set_state(state):
	current_state = state

func quest_offer(quest_id: String):
	for quest in quests:
		if quest.quest_id == quest_id && quest.state == "not_started":
			quest.state = "in_progress"
			quest_manager.quest_add(quest)
			print("Offering quest: " + quest.quest_name)
			print("")
			return
	print("No quest found, or quest is already started")
	print("")

func quest_get_dialogue() -> Dictionary:
	var active_quests = quest_manager.quest_get_active()
	for quest in active_quests:
		for objective in quest.objectives:
			if objective in quest.objectives:
				if objective.target_id == npc_id && objective.target_type == "talk_to" && not objective.is_completed:
					if current_state == "start":
						return {"text": objective.objective_dialogue, "options": {}}
	return {"text": "", "options": {}}
