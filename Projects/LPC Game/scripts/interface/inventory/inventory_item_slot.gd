extends Control

@onready var item_button: Button = $ItemButton
@onready var hotbar_button: Button = $UsagePanel/HotbarButton
@onready var item_name: Label = $DetailsPanel/ItemName
@onready var item_type: Label = $DetailsPanel/ItemType
@onready var item_effect: Label = $DetailsPanel/ItemEffect
@onready var icon: Sprite2D = $InnerBorder/ItemIcon
@onready var quantity_label: Label = $InnerBorder/ItemQuantity
@onready var key_label_box: Panel = $InnerBorder/KeyLabelBox
@onready var key_label: Label = $InnerBorder/KeyLabelBox/KeyLabel
@onready var details_panel: ColorRect = $DetailsPanel
@onready var usage_panel: ColorRect = $UsagePanel
@onready var outer_border: ColorRect = $OuterBorder

var item = null
var slot_index: int = -1
var assigned: bool = false

signal drag_start(slot)
signal drag_stop()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory"):
		usage_panel.visible = false

func slot_set_index(new_index) -> void:
	slot_index = new_index

func slot_set_item(new_item) -> void:
	outer_border.modulate = Color.BLACK
	item_button.mouse_filter = MOUSE_FILTER_STOP
	item = new_item
	icon.texture = new_item["texture"]
	quantity_label.text = str(item["quantity"])
	item_name.text = str(item["name"])
	item_type.text = str(item["type"])
	if item["magnitude"] == 0:
		item["effect"] = ""
	if item["effect"] != "":
		if item["effect"] != "Quest Item":
			item_effect.text = str(item["effect"]) + " " + "+" + str(item["magnitude"])
		else:
			item_effect.text = ""
	else:
		item_effect.text = ""
	slot_set_assignment()

func slot_set_empty() -> void:
	outer_border.modulate = Color.BLACK
	item_button.mouse_filter = MOUSE_FILTER_PASS
	icon.texture = null
	quantity_label.text = ""

func slot_set_assignment() -> void:
	assigned = Global.hotbar_assignment_check(item)
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
					Global.player_node.item_effect(item)
					var use: bool = Global.player_node.should_use
					if use:
						Global.item_remove(item["id"])
						Global.item_remove_from_hotbar(item["id"])
					elif !use:
						print("Item not used.")
						print("")
			else:
				print("Cannot use this item!")
				print("")
		else:
			print("This item has no effect")
			print("")

func _on_hotbar_button_pressed() -> void:
	if item != null:
		if item["effect"] != "Quest Item" && item["type"] != "Resource":
			if assigned:
				Global.item_unassign_hotbar(item["id"])
				assigned = false
			else:
				Global.item_add(item, true)
				assigned = true
			slot_set_assignment()
		else:
			print("Cannot assign this item!")
			print("")

func _on_drop_button_pressed() -> void:
	if item != null && item["effect"] != "Quest Item":
		var drop_position: Vector2 = Global.player_node.position + Vector2(0.0, 64.0)
		var drop_offset: Vector2 = Global.player_node.last_direction
		Global.item_drop(item, drop_position + drop_offset)
		Global.item_remove(item["id"])
		Global.item_remove_from_hotbar(item["id"])
		item_button.visible = true
		details_panel.visible = false
		usage_panel.visible = false
	else:
		print("Cannot drop Quest Items!")
		print("")
