class_name Player
extends CharacterBody2D

@export var player_name: String = "null"

@export_group("Custom Values")
@export var walk_speed: float = 100.0
@export var run_speed: float = 250.0
@export var max_health: float = 100.0
@export var max_stamina: float = 100.0
@export var max_magic: float = 100.0
@export var stamina_drain: float = 0.15
@export var stamina_gain: float = 0.05
@export var magic_drain: float = 10
@export var magic_gain: float = 0.025

@export_group("Animation Bools")
@export var idle: bool
@export var walking: bool
@export var running: bool
@export var swinging: bool

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var ray_cast: RayCast2D = $RayCast2D
@onready var hand: Hand = $Hand
@onready var projectile_origin: Marker2D = $ProjectileOrigin
@onready var follow_camera: RemoteTransform2D = $"../Camera"
@onready var interface: CanvasLayer = $UserInterface
@onready var inventory: Control = $UserInterface/HUD/InventoryUI
@onready var quest_manager: Node2D = $QuestManager
@onready var quest_tracker: Control = $UserInterface/HUD/QuestTracker
@onready var quest_title: Label = $UserInterface/HUD/QuestTracker/ColorRect/Details/Title
@onready var quest_objectives: VBoxContainer = $UserInterface/HUD/QuestTracker/ColorRect/Details/Objectives
@onready var health_bar: TextureProgressBar = $UserInterface/HUD/StatsUI/HealthBars/Health
@onready var health_label: Label = health_bar.get_child(0)
@onready var stamina_bar: TextureProgressBar = $UserInterface/HUD/StatsUI/HealthBars/Stamina
@onready var stamina_label: Label = stamina_bar.get_child(0)
@onready var magic_bar: TextureProgressBar = $UserInterface/HUD/StatsUI/HealthBars/Magic
@onready var magic_label: Label = magic_bar.get_child(0)
@onready var interact_label: Control = $UserInterface/HUD/Interact
@onready var fps_label: Control = $UserInterface/HUD/FPSLabel/Label

const FIREBALL = preload("res://scenes/effects/effect_fireball.tscn")

var direction = Vector2(0.0, 1.0)
var last_direction
var fireball_direction
var last_position
var speed = walk_speed
var health = max_health
var stamina = max_stamina
var magic = max_magic
var stamina_cooldown = false
var magic_cooldown = false

var can_move = true
var looting = false
var should_use = false
var recent_pickup = false
var in_interact_area = false
var selected_quest: Quest = null
var time_since_pickup: int = 0
var quest_coins_reward: int = 0

func _ready():
	Global.set_player(self)
	Global.player_name = player_name
	quest_manager.quest_updated.connect(_on_quest_updated)
	quest_manager.objectives_updated.connect(_on_objective_updated)

func _process(_delta):
	check_ui()
	check_health()
	check_stamina()
	check_magic()

func _physics_process(_delta):
	animation_parameters()
	animate_bars()
	if can_move:
		check_input()
		check_interact()
		camera_follow()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quests"):
		quest_manager.toggle_quest_log()

func check_input():
	if get_tree().paused == false:
		direction = Input.get_vector("left", "right", "up", "down").normalized()
		ray_cast.target_position = animation_tree["parameters/Idle/blend_position"] * 48
	if Input.is_action_pressed("run"):
		if direction != Vector2.ZERO && last_position != position.round():
			if stamina != 0 && stamina_cooldown == false:
				speed = run_speed
				last_position = position.round()
			elif last_position == position.round() || stamina == 0:
				Input.action_release("run")
				speed = walk_speed
				last_position = position.round()
	if Input.is_action_just_released("run"):
		speed = walk_speed
	if direction && !swinging:
		velocity = direction.round() * speed
	else:
		velocity = Vector2.ZERO
	if get_tree().paused == false:
		move_and_slide()
	if Input.is_action_just_pressed("use"):
		if interface.visible == true:
			if hand.equipped_item != null && get_tree().paused == false:
				if hand.equipped_item["type"] == "Spell" && magic >= magic_drain:
					if magic_cooldown == false:
						shoot_fireball()
	if Input.is_action_just_pressed("inventory"):
		open_inventory()
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("show_fps"):
		if fps_label.get_parent().visible == false:
			fps_label.get_parent().visible = true
		else:
			fps_label.get_parent().visible = false
	if fps_label.get_parent().visible == true:
		fps_label.text = str(Engine.get_frames_per_second())

func open_inventory():
	if looting == false:
		if inventory.visible == false:
			Global.inventory_updated.emit()
			animation_tree.active = false
			inventory.visible = true
			get_tree().paused = true
		elif inventory.visible == true:
			animation_tree.active = true
			inventory.visible = false
			get_tree().paused = false

func check_ui():
	if interface.visible == false:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	elif inventory.visible == true:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		get_tree().paused = true
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_tree().paused = false

func check_interact():
	if recent_pickup == true:
		time_since_pickup += 1
		if time_since_pickup == 50:
			Global.inventory_updated.emit()
		if time_since_pickup > 100:
			time_since_pickup = 0
			recent_pickup = false
	if can_move:
		if Input.is_action_just_pressed("interact"):
			var target = ray_cast.get_collider()
			if target != null:
				if target.is_in_group("NPC"):
					can_move = false
					target.start_dialogue()
					check_quest_objectives(target.npc_id, "talk_to")
				elif target.is_in_group("QuestItem"):
					if check_quest_items(target.get_parent().item_id):
						check_quest_objectives(target.item_id, "collection", target.item_quantity)
						target.queue_free()
					else:
						print("Item not needed for any active quest.")
						print("")
	if ray_cast.is_colliding() || in_interact_area == true:
		interact_label.visible = true
	else:
		interact_label.visible = false

func check_quest_items(item_id: String) -> bool:
	if selected_quest != null:
		for objective in selected_quest.objectives:
			if objective.terget_id == item_id && objective.target_type == "collection" && !objective.is__completed:
				return true
	return false

func check_quest_objectives(target_id: String, target_type: String, quantity: int = 1):
	if selected_quest == null:
		return
	var objective_updated = false
	for objective in selected_quest.objectives:
		if objective.terget_id == target_id && objective.target_type == target_type && !objective.is__completed:
			print("Finished objective for quest: ", selected_quest.quest_name)
			print("")
			selected_quest.complete_objectives(objective.id, quantity)
			objective_updated = true
			break
	if objective_updated:
		if selected_quest.is_completed():
			check_quest_completion(selected_quest)
		check_quest_tracker(selected_quest)

func check_quest_completion(quest: Quest):
	for reward in quest.rewards:
		if reward.reward_type == "coins":
			quest_coins_reward += reward.reward_amount
			print(quest_coins_reward)
			print("")
			print("Need to implement giving coins as an item.")
			print("")
	check_quest_tracker(quest)
	quest_manager.update_quest(quest.quest_id, "completed")

func _on_quest_updated(quest_id: String):
	var quest = quest_manager.get_quest(quest_id)
	if quest == selected_quest:
		check_quest_tracker(quest)

func _on_objective_updated(quest_id: String, _objective_id: String):
	if selected_quest && selected_quest.quest_id == quest_id:
		check_quest_tracker(selected_quest)

func check_health():
	health_bar.value = health
	health_label.text = str(health as int).pad_zeros(3)
	if health == 0:
		print("DEAD")
		print("")
		process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func check_quest_tracker(quest: Quest):
	if quest:
		quest_tracker.visible = true
		quest_title.text = quest.quest_name
		for child in quest_objectives.get_children():
			quest_objectives.remove_child(child)
		for objective in quest.objectives:
			var label = Label.new()
			label.text = objective.description
			if objective.is_completed:
				label.add_theme_color_override("font_color", Color(0, 1, 0))
			else:
				label.add_theme_color_override("font_color", Color(1, 0, 0))
			quest_objectives.add_child(label)
	else:
		quest_tracker.visible = false

func animate_bars():
	var stamina_tween = stamina
	var s_tween = create_tween()
	s_tween.tween_property(stamina_bar, "value", stamina_tween, 0.1)
	var magic_tween = magic
	var m_tween = create_tween()
	m_tween.tween_property(magic_bar, "value", magic_tween, 0.1)
	
func check_stamina():
	stamina_label.text = str(stamina as int).pad_zeros(3)
	if running == true && swinging == false && stamina_cooldown == false:
		if last_position != position.round():
			stamina -= stamina_drain
	if stamina < 0:
		stamina_cooldown = true
		stamina = 0
	if stamina > max_stamina:
		stamina = max_stamina
	if stamina < max_stamina:
		if get_tree().paused == false && running == false:
			if stamina_cooldown == true:
				stamina_label.self_modulate = Color.RED
				if stamina == 0:
					await get_tree().create_timer(2.0).timeout
				stamina += stamina_gain
				if stamina > max_stamina / PI:
					stamina_cooldown = false
					stamina_label.self_modulate = Color.WHITE
			elif stamina_cooldown == false:
				stamina += stamina_gain
	
func check_magic():
	magic_label.text = str(magic as int).pad_zeros(3)
	if magic < 0:
		magic = 0
	if get_tree().paused == false && magic < max_magic:
		if magic < 0.48:
			magic_label.self_modulate = Color.RED
			await get_tree().create_timer(1.5).timeout
			magic = 0.49
		if magic >= 0.49 && magic_cooldown == false:
			magic += magic_gain
	if magic < magic_drain:
		magic_label.self_modulate = Color.RED
	else:
		magic_label.self_modulate = Color.WHITE
	if magic > max_magic:
		magic = max_magic

func shoot_fireball():
	if magic_cooldown == false:
		var new_fireball = FIREBALL.instantiate()
		magic_cooldown = true
		magic -= magic_drain
		if idle:
			fireball_direction = animation_tree["parameters/Idle/blend_position"]
		else:
			fireball_direction = direction
		new_fireball.global_position = projectile_origin.global_position
		get_parent().add_child(new_fireball)
		await get_tree().create_timer(1.0).timeout
		magic_cooldown = false

func camera_follow():
	last_direction = direction
	if last_direction != direction:
		last_direction = direction
	if direction != Vector2.ZERO:
		position.x = round(position.x)
		position.y = round(position.y)
	follow_camera.position = position

func heal_health(amount):
	if health < max_health:
		health += amount
		if health > max_health:
			health = max_health

func damage_health(amount):
	if health > 0:
		health -= amount

func heal_stamina(amount):
	if stamina < max_stamina:
		stamina += amount
		if stamina > max_stamina:
			stamina = max_stamina

func damage_stamina(amount):
	if stamina > 0:
		stamina -= amount

func heal_magic(amount):
	if magic < max_magic:
		magic += amount
		if magic > max_magic:
			magic = max_magic

func damage_magic(amount):
	if magic > 0:
		magic -= amount

func apply_item_effect(item):
	should_use = false
	match item["effect"]:
		"Health":
			if health >= max_health:
				print("Already at max Health.")
				print("")
			else:
				should_use = true
				heal_health(item["magnitude"])
				print("Healed " + str(item["magnitude"]) + " HP")
				print("")
		"Stamina":
			if stamina >= max_stamina:
				print("Already at max Stamina.")
				print("")
			else:
				should_use = true
				heal_stamina(item["magnitude"])
				print("Healed " + str(item["magnitude"]) + " Stamina")
				print("")
		"Magic":
			if magic >= max_magic:
				print("Already at max Magic.")
				print("")
			else:
				should_use = true
				heal_magic(item["magnitude"])
				print("Healed " + str(item["magnitude"]) + " MP")
				print("")
		"Inventory":
			if Global.inventory.size() >= Global.inventory_max:
				print("Already at max Inventory capacity.")
				print("")
			else:
				should_use = true
				Global.increase_inventory_size(item["magnitude"])
				Global.inventory_full = false
				print("Inventory Slots +" + str(item["magnitude"]))
				print("")
		"Damage":
			should_use = true
			damage_health(item["magnitude"])
			print("Damaged " + str(item["magnitude"]) + " HP")
			print("")
		_:
			print("This item has no effect")
			print("")

func animation_parameters():
	if velocity == Vector2.ZERO || last_position == position.round():
		Input.action_release("run")
		idle = true
		walking = false
		running = false
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
		animation_tree["parameters/conditions/is_running"] = false
		animation_tree["parameters/conditions/swing"] = false
	else:
		if speed == walk_speed && last_position != position.round():
			idle = false
			walking = true
			running = false
			animation_tree["parameters/conditions/is_moving"] = true
			animation_tree["parameters/conditions/is_running"] = false
		elif speed == run_speed && last_position != position.round():
			idle = false
			walking = false
			running = true
			animation_tree["parameters/conditions/is_moving"] = false
			animation_tree["parameters/conditions/is_running"] = true
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/swing"] = false
	if Input.is_action_just_pressed("use"):
		if hand.equipped_item != null:
			if interface.visible == true:
				if hand.equipped_item.name != "Fireball" || magic > magic_drain && magic_cooldown == false:
					animation_tree["parameters/conditions/swing"] = true
				animation_tree["parameters/conditions/idle"] = false
				animation_tree["parameters/conditions/is_moving"] = false
				animation_tree["parameters/conditions/is_running"] = false
	else:
		animation_tree["parameters/conditions/swing"] = false
	if direction != Vector2.ZERO:
		animation_tree["parameters/Idle/blend_position"] = direction
		animation_tree["parameters/Walk/blend_position"] = direction
		animation_tree["parameters/Run/blend_position"] = direction
		animation_tree["parameters/Swing/blend_position"] = direction
