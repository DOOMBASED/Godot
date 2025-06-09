extends Control

@onready var item_button = $ItemButton
@onready var item_name = $DetailsPanel/ItemName
@onready var item_type = $DetailsPanel/ItemType
@onready var item_effect = $DetailsPanel/ItemEffect
@onready var icon = $InnerBorder/ItemIcon
@onready var quantity_label = $InnerBorder/ItemQuantity
@onready var details_panel = $DetailsPanel
@onready var usage_panel = $UsagePanel
@onready var mesh

@onready var player = Global.player_node

var item = null

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory"):
		usage_panel.visible = false

func set_empty():
	item_button.visible = false
	item_button.mouse_filter = MOUSE_FILTER_IGNORE
	icon.texture = null
	quantity_label.text = ""

func set_item(new_item):
	item_button.visible = true
	item_button.mouse_filter = MOUSE_FILTER_STOP
	item = new_item
	mesh = item["mesh"]
	icon.texture = new_item["texture"]
	quantity_label.text = str(item["quantity"])
	item_name.text = str(item["name"])
	item_type.text = str(item["type"])
	if item["effect"] != "":
		item_effect.text = str(item["effect"])
	else:
		item_effect.text = ""

func _on_item_button_pressed() -> void:
	if item != null:
		item_button.visible = false
		usage_panel.visible = true

func _on_item_button_mouse_entered() -> void:
	if item != null:
		usage_panel.visible = false
		details_panel.visible = true

func _on_item_button_mouse_exited() -> void:
	if item != null:
		item_button.visible = true
		details_panel.visible = false

func _on_drop_button_pressed() -> void:
	if item != null:
		var drop_position = player.global_position
		var drop_offset = Vector3(0.0, 0.0, 5.0)
		drop_offset = drop_offset.rotated(player.rotation.normalized(), 0.0)
		Global.drop_item(item, drop_position + drop_offset)
		Global.remove_item(item["type"], item["effect"])
		item_button.visible = true
		details_panel.visible = false
		usage_panel.visible = false

func _on_use_button_pressed() -> void:
		item_button.visible = true
		usage_panel.visible = false
		if item != null && item["effect"] != "":
			if player:
				player.apply_item_effect(item)
				Global.remove_item(item["type"], item["effect"])

func _on_usage_panel_mouse_exited() -> void:
	usage_panel.visible = false
