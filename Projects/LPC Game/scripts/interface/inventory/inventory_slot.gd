extends Control

@onready var item_button = $ItemButton
@onready var hotbar_button = $UsagePanel/HotbarButton
@onready var item_name = $DetailsPanel/ItemName
@onready var item_type = $DetailsPanel/ItemType
@onready var item_effect = $DetailsPanel/ItemEffect
@onready var icon = $InnerBorder/ItemIcon
@onready var quantity_label = $InnerBorder/ItemQuantity
@onready var quantity_small = $InnerBorder/ItemQuantitySmall
@onready var key_label = $InnerBorder/KeyLabel
@onready var details_panel = $DetailsPanel
@onready var usage_panel = $UsagePanel
@onready var outer_border = $OuterBorder
@onready var scene

var item = null
var slot_index = -1
var assigned = false

signal drag_start(slot)
signal drag_stop()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory"):
		usage_panel.visible = false

func set_empty():
	outer_border.modulate = Color.BLACK
	item_button.mouse_filter = MOUSE_FILTER_PASS
	icon.texture = null
	quantity_label.text = ""
	quantity_small.text = ""

func set_item(new_item):
	outer_border.modulate = Color.BLACK
	item_button.mouse_filter = MOUSE_FILTER_STOP
	item = new_item
	scene = item["scene"]
	icon.texture = new_item["texture"]
	quantity_label.text = str(item["quantity"])
	quantity_small.text = str(item["quantity"])
	item_name.text = str(item["name"])
	item_type.text = str(item["type"])
	if item["effect"] != "":
		if item["effect"] != "Quest Item":
			item_effect.text = str(item["effect"]) + " " + "+" + str(item["magnitude"])
		else:
			item_effect.text = "Quest Item"
	else:
		item_effect.text = ""
	update_assignment()

func set_slot_index(new_index):
	slot_index = new_index

func update_assignment():
	assigned = Global.check_hotbar_assignment(item)
	if assigned:
		hotbar_button.text = "UNASSIGN"
	else:
		hotbar_button.text = "ASSIGN"

func _on_item_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed():
			if item != null:
				item_button.visible = false
				usage_panel.visible = true
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				outer_border.modulate = Color.GREEN
				drag_start.emit(self)
			else:
				outer_border.modulate = Color.BLACK
				drag_stop.emit()

func _on_item_button_mouse_entered() -> void:
	if item != null:
		usage_panel.visible = false
		details_panel.visible = true

func _on_item_button_mouse_exited() -> void:
	if item != null:
		item_button.visible = true
		details_panel.visible = false

func _on_usage_panel_mouse_exited() -> void:
	usage_panel.visible = false

func _on_use_button_pressed() -> void:
		if item != null && item["effect"] != "":
			if item["effect"] != "Quest Item" && item["type"] != "Resource":
				item_button.visible = true
				usage_panel.visible = false
				if Global.player_node:
					Global.player_node.apply_item_effect(item)
					var use = Global.player_node.should_use
					if use:
						Global.remove_item(item["type"], item["effect"])
						Global.remove_hotbar_item(item["type"], item["effect"])
					elif !use:
						print("Item not used.")
			else:
				print("Cannot use this item!")
				print("")

func _on_hotbar_button_pressed() -> void:
	if item != null:
		if item["effect"] != "Quest Item" && item["type"] != "Resource":
			if assigned:
				Global.unassign_hotbar_item(item["type"], item["effect"])
				assigned = false
			else:
				Global.add_item(item, true)
				assigned = true
			update_assignment()
		else:
			print("Cannot assign this item!")
			print("")

func _on_drop_button_pressed() -> void:
	if item != null && item["effect"] != "Quest Item":
		var drop_position = Global.player_node.position + Vector2(0.0, 64.0)
		var drop_offset = Global.player_node.last_direction
		Global.drop_item(item, drop_position + drop_offset)
		Global.remove_item(item["type"], item["effect"])
		Global.remove_hotbar_item(item["type"], item["effect"])
		item_button.visible = true
		details_panel.visible = false
		usage_panel.visible = false
	else:
		print("Cannot drop Quest Items!")
		print("")
