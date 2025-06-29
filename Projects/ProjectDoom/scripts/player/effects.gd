extends Node

@onready var player: Player = get_parent()

var inventory: Inventory = null

var should_use: bool = false
var use_cooldown: float = 2.5

var panel_base_color: Color = Color(1.0, 1.0, 1.0, 0.784)

func _ready() -> void:
	inventory = Inventory

func item_effect(item: Item) -> void:
	match item.item_effect:
		"Health":
			if player.health >= player.health_max:
				item_used_at_max(item.item_effect)
			else:
				item_used()
				health_heal(item.item_magnitude)
		"Stamina":
			if player.stamina >= player.stamina_max:
				item_used_at_max(item.item_effect)
			else:
				item_used()
				stamina_heal(item.item_magnitude)
		"Magic":
			if player.magic >= player.magic_max:
				item_used_at_max(item.item_effect)
			else:
				item_used()
				magic_heal(item.item_magnitude)
		"Slot":
			if Inventory.inventory.size() >= Inventory.inventory_max:
				item_used_at_max(item.item_effect)
			else:
				item_used()
				inventory.inventory_increase_size(item.item_magnitude)
		"Damage":
			if player.health >= 1: 
				item_used()
				health_damage(item.item_magnitude)
			else:
				item_used_at_max(item.item_effect)
		_:
			print("This item has no effect")

func item_used() -> void:
	should_use = true
	inventory.item_remove(inventory.inventory_ui.selected_item)
	await get_tree().create_timer(use_cooldown).timeout
	inventory.inventory_ui.use_cooldown = false
	should_use = false
	inventory.inventory_ui.use_panel.self_modulate = panel_base_color

func item_used_at_max(item_used_effect: String) -> void:
	inventory.inventory_ui._on_details_button_pressed()
	inventory.inventory_ui.use_message_label.visible = true
	inventory.inventory_ui.use_message_label.text = "Already at max " + item_used_effect + "."
	await get_tree().create_timer(use_cooldown).timeout
	inventory.inventory_ui.use_cooldown = false
	inventory.inventory_ui.use_message_label.visible = false
	inventory.inventory_ui.use_message_label.text = ""
	inventory.inventory_ui.use_panel.self_modulate = panel_base_color

func health_heal(amount: float) -> void:
	if player.health < player.health_max:
		player.health += amount
		if player.health > player.health_max:
			player.health = player.health_max
 
func health_damage(amount: float) -> void:
	if player.health > 0:
		player.health -= amount

func stamina_heal(amount: float) -> void:
	if player.stamina < player.stamina_max:
		player.stamina += amount
		if player.stamina > player.stamina_max:
			player.stamina = player.stamina_max

func stamina_damage(amount: float) -> void:
	if player.stamina > 0:
		player.stamina -= amount

func magic_heal(amount: float) -> void:
	if player.magic < player.magic_max:
		player.magic += amount
		if player.magic > player.magic_max:
			player.magic = player.magic_max

func magic_damage(amount: float) -> void:
	if player.magic > 0:
		player.magic -= amount
