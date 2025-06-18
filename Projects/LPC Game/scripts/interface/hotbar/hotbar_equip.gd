extends Control

var hand: Hand

func _ready():
	visible = true
	if Global.player_node:
		hand = Global.player_node.find_child("Hand")
		for button in self.get_children():
			button.hand = hand
