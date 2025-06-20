class_name Quest
extends Resource

@export var quest_id: String
@export var unlock_id: String
@export var quest_name: String
@export var state: String = "not_started"
@export var objectives: Array[Objectives] = []
@export var rewards: Array[Rewards] = []

func complete_objectives(objective_id: String, quantity: int = 1):
	for objective in objectives:
		if objective.id == objective_id:
			if objective.target_type == "collection":
				objective.collected_quantity += quantity
				if objective.collected_quantity >= objective.required_quantity:
					objective.is_completed = true
			elif objective.target_type == "talk_to":
				objective.is_completed = true
			break

func is_completed() -> bool:
	for objective in objectives:
		if not objective.is_completed:
			return false
	return true
