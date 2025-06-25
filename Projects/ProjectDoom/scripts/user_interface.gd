extends CanvasLayer

@onready var test_label_1: Label = $MarginContainer/VBoxContainer/Panel1/TestLabel1
@onready var test_label_2: Label = $MarginContainer/VBoxContainer/Panel2/TestLabel2
@onready var test_label_3: Label = $MarginContainer/VBoxContainer/Panel3/TestLabel3

func _ready() -> void:
	Global.set_player_interface(self)
