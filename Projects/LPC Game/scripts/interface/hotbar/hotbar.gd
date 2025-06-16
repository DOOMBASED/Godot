extends Control

@onready var player = get_tree().get_first_node_in_group("player")

var hand: Hand

func _ready():
	visible = true
	if player:
		hand = player.find_child("Hand")
		for button in self.get_children():
			button.hand = hand

func _input(_event: InputEvent) -> void:
	if Input.get_vector("1","2","3","unequip"):
		for button in self.get_children():
			button.find_child("OuterBorder").modulate = Color.BLACK
