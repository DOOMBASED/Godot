class_name Quest
extends Resource

@export var quest_id: String
@export var unlock_id: String
@export var quest_name: String
@export var state: String = "not_started"
@export var objectives: Array[Objectives] = []
@export var rewards: Array[Rewards] = []
