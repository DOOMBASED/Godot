extends Control

@onready var panel: Panel = $CanvasLayer/Panel
@onready var quest_list: VBoxContainer = $CanvasLayer/Panel/Contents/Details/QuestList
@onready var quest_title: Label = $CanvasLayer/Panel/Contents/Details/QuestDetails/QuestTitle
@onready var quest_description: Label = $CanvasLayer/Panel/Contents/Details/QuestDetails/QuestDescription
@onready var quest_objectives: VBoxContainer = $CanvasLayer/Panel/Contents/Details/QuestDetails/QuestObjectives
@onready var quest_rewards: VBoxContainer = $CanvasLayer/Panel/Contents/Details/QuestDetails/QuestRewards

var quest_manager: Node = null
var selected_quest: Quest = null

func _ready() -> void:
	quest_details_clear()
	quest_manager = get_parent()
	quest_manager.quest_updated.connect(_on_quest_updated)
	quest_manager.objectives_updated.connect(_on_objectives_updated)

func toggle_log():
	panel.visible = !panel.visible
	quest_list_update()
	if selected_quest:
		_on_quest_selected(selected_quest)

func quest_list_update():
	for child in quest_list.get_children():
		quest_list.remove_child(child)
	var active_quests = get_parent().quest_get_active()
	if active_quests.size() == 0:
		quest_details_clear()
		Global.player_node.selected_quest = null
		Global.player_node.check_quest_tracker(null)
	else:
		for quest in active_quests:
			var button = Button.new()
			button.add_theme_font_size_override("font_size", 12)
			button.text = quest.quest_name
			button.pressed.connect(_on_quest_selected.bind(quest))
			quest_list.add_child(button)
	Global.player_node.check_quest_tracker(selected_quest)

func quest_details_clear():
	quest_title.text = ""
	quest_description.text = ""
	for child in quest_objectives.get_children():
		quest_objectives.remove_child(child)
	for child in quest_rewards.get_children():
		quest_rewards.remove_child(child)

func _on_quest_selected(quest: Quest):
	selected_quest = quest
	Global.player_node.selected_quest = quest
	quest_title.text = quest.quest_name
	quest_description.text = quest.quest_description
	for child in quest_objectives.get_children():
		quest_objectives.remove_child(child)
	for objective in quest.objectives:
		var label = Label.new()
		label.add_theme_font_size_override("font_size", 12)
		if objective.target_type == "collection":
			label.text = objective.description + "(" + str(objective.collected_quantity) + "/" + str(objective.required_quantity) + ")"
		else:
			label.text = objective.description
		if objective.is_completed:
			label.add_theme_color_override("font_color", Color(0, 1, 0))
		else:
			label.add_theme_color_override("font_color", Color(1, 0, 0))
		quest_objectives.add_child(label)
	for child in quest_rewards.get_children():
		quest_rewards.remove_child(child)
	for reward in quest.rewards:
		var label = Label.new()
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", Color(0, 0.85, 0))
		label.text = "Rewards: " + reward.reward_type.capitalize() + ": " + str(reward.reward_amount)
		quest_rewards.add_child(label)

func _on_quest_updated(quest_id: String):
	if selected_quest && selected_quest.quest_id == quest_id:
		_on_quest_selected(selected_quest)
	else:
		quest_list_update()
	selected_quest = null
	Global.player_node.selected_quest = null

func _on_objectives_updated(quest_id: String, _objectives_id: String):
	if selected_quest && selected_quest.quest_id == quest_id:
		_on_quest_selected(selected_quest)
	else:
		quest_details_clear()
	selected_quest = null
	Global.player_node.selected_quest = null
