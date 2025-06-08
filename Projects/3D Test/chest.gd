extends Node3D

@onready var activate_area = $StaticBody3D/ActivateArea
@onready var inventory = $StaticBody3D/HUD/Inventory
@onready var player = Global.player_node

var opened = false
var collision = false

func _on_activate_area_body_entered(body: Node3D) -> void:
	if body == player:
		collision = true

func _on_activate_area_body_exited(body: Node3D) -> void:
	if body == player:
		collision = false
		if inventory.visible == true:
			inventory.visible = false
			player.inventory.visible = false
	if opened == true:
		opened = false

func open():
		if collision == true && player.object == self:
			if opened == false:
				opened = true
				inventory.visible = true
				if player.inventory.visible == false:
					player.inventory.visible = true
				player.looting = true
			elif opened == true:
				opened = false
				inventory.visible = false
				if player.inventory.visible == true:
					player.inventory.visible = false
				player.looting = false
