extends Control

@onready var panel: Panel = $CanvasLayer/Panel
@onready var dialogue_speaker: Label = $CanvasLayer/Panel/DialogueBox/DialogueSpeaker
@onready var dialogue_text: Label = $CanvasLayer/Panel/DialogueBox/DialogueText
@onready var dialogue_options: HBoxContainer = $CanvasLayer/Panel/DialogueBox/DialogueOptions

func _ready() -> void:
	hide_dialogue()

func show_dialogue(speaker, text, options):
	Global.player_node.interface.visible = false
	Global.player_node.velocity = Vector2.ZERO
	panel.visible = true
	text = text.replace("#PN#", Global.player_name)
	dialogue_speaker.text = speaker
	dialogue_text.text = text
	for option in dialogue_options.get_children():
		dialogue_options.remove_child(option)
	for option in options.keys():
		var button = Button.new()
		button.text = option
		button.add_theme_font_size_override("font_size", 12)
		button.pressed.connect(_on_option_selected.bind(option))
		dialogue_options.add_child(button)

func hide_dialogue():
	panel.visible = false
	Global.player_node.can_move = true
	Global.player_node.interface.visible = true

func _on_option_selected(option):
	get_parent().handle_dialogue(option)

func _on_close_button_pressed() -> void:
	hide_dialogue()
