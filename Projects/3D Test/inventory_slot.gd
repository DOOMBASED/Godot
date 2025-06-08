extends Control

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

func _on_item_button_pressed() -> void:
	if item != null:
		usage_panel.visible = !usage_panel.visible

func _on_item_button_mouse_entered() -> void:
	if item != null:
		usage_panel.visible = false
		details_panel.visible = true

func _on_item_button_mouse_exited() -> void:
	if item != null:
		details_panel.visible = false

func set_empty():
	icon.texture = null
	quantity_label.text = ""

func set_item(new_item):
	item = new_item
	icon.texture = new_item["item_texture"]
	mesh = item["item_mesh"]
	quantity_label.text = str(item["quantity"])
	item_name.text = str(item["item_name"])
	item_type.text = str(item["item_type"])
	if item["item_effect"] != "":
		item_effect.text = str(item["item_effect"])
	else:
		item_effect.text = ""

func _on_drop_button_pressed() -> void:
	if item != null:
		var drop_position = player.global_position
		var drop_offset = Vector3(0.0, 0.0, 5.0)
		drop_offset = drop_offset.rotated(player.rotation.normalized(), 0.0)
		Global.drop_item(item, drop_position + drop_offset)
		Global.remove_item(item["item_type"], item["item_effect"])
		usage_panel.visible = false
