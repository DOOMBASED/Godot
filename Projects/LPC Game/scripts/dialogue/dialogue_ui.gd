extends Control

@onready var panel: Panel = $CanvasLayer/Panel
@onready var dialogue_speaker: Label = $CanvasLayer/Panel/DialogueBox/DialogueSpeaker
@onready var dialogue_text: Label = $CanvasLayer/Panel/DialogueBox/DialogueText
@onready var dialogue_options: HBoxContainer = $CanvasLayer/Panel/DialogueBox/DialogueOptions

func _ready() -> void:
	dialogue_hide()

func _unhandled_input(event: InputEvent) -> void:
	if panel.visible == true:
		if event is InputEventKey && event.pressed:
			for i in range(Global.hotbar_size):
				if dialogue_options.get_children().size() >= i + 1 && Input.is_action_just_pressed(str(i + 1)):
					dialogue_options.get_child(i).pressed.emit()
					break
		if Input.is_action_just_pressed("close_dialogue"):
			dialogue_hide()
		

func dialogue_show(npc_name: String, text: String, options: Dictionary) -> void:
	Global.player_node.interface.visible = false
	Global.player_node.velocity = Vector2.ZERO
	panel.visible = true
	text = text.replace("#PLAYER#", Global.player_name)
	text = text.replace("#NPC#", npc_name)
	dialogue_speaker.text = npc_name
	dialogue_text.text = text
	for child in dialogue_options.get_children():
		dialogue_options.remove_child(child)
	for option in options.keys():
		var button: Button = Button.new()
		button.pressed.connect(_on_option_selected.bind(option))
		dialogue_options.add_child(button)
		button.text = "(" + str(button.get_index() + 1) + ") " + option
		button.add_theme_font_size_override("font_size", 14)

func dialogue_hide() -> void:
	panel.visible = false
	Global.player_node.can_move = true
	Global.player_node.interface.visible = true

func _on_option_selected(option: String) -> void:
	get_parent().dialogue_handle_choice(option)

func _on_close_button_pressed() -> void:
	dialogue_hide()
