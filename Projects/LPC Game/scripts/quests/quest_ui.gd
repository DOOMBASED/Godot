extends Control

@onready var panel: Panel = $CanvasLayer/Panel
@onready var quest_list: VBoxContainer = $CanvasLayer/Panel/Contents/Details/QuestList
@onready var quest_title: Label = $CanvasLayer/Panel/Contents/Details/QuestDetails/QuestTitle
@onready var quest_objectives: VBoxContainer = $CanvasLayer/Panel/Contents/Details/QuestDetails/QuestObjectives
@onready var quest_rewards: VBoxContainer = $CanvasLayer/Panel/Contents/Details/QuestDetails/QuestRewards
