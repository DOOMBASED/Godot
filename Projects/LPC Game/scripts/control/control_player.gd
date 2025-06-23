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
@onready var quest_manager: Control = $UserInterface/HUD/QuestManager
@onready var quest_tracker: Control = $UserInterface/HUD/QuestTracker
@onready var quest_title: Label = $UserInterface/HUD/QuestTracker/ColorRect/Details/Title
@onready var quest_objectives: VBoxContainer = $UserInterface/HUD/QuestTracker/ColorRect/Details/Objectives
@onready var health_bar: TextureProgressBar = $UserInterface/HUD/HealthBars/HealthBars/Health
#@onready var health_label: Label = health_bar.get_child(0)
@onready var stamina_bar: TextureProgressBar = $UserInterface/HUD/HealthBars/HealthBars/Stamina
#@onready var stamina_label: Label = stamina_bar.get_child(0)
@onready var magic_bar: TextureProgressBar = $UserInterface/HUD/HealthBars/HealthBars/Magic
#@onready var magic_label: Label = magic_bar.get_child(0)
@onready var stats_ui: Control = $UserInterface/HUD/StatsUI
@onready var interact_ui: Control = $UserInterface/HUD/Interact
@onready var interact_label: Label = $UserInterface/HUD/Interact/ColorRect/InteractLabel
@onready var fps_label: Control = $UserInterface/HUD/FPSLabel/Label

const FIREBALL: Resource = preload("res://scenes/effects/effect_fireball.tscn")
var gold: Resource = preload("res://tres/items/currency/gold.tres")

var direction: Vector2 = Vector2(0.0, 1.0)
var last_direction: Vector2
var fireball_direction: Vector2
var last_position: Vector2
var speed: float = walk_speed
var health: float = max_health
var stamina: float = max_stamina
var magic: float = max_magic
var stamina_cooldown: bool = false
var magic_cooldown: bool = false

var can_move: bool = true
var looting: bool = false
var should_use: bool = false
var recent_pickup: bool = false
var in_interact_area: bool = false
var time_since_pickup: int = 0
var current_quest: Quest = null

func _ready() -> void:
	Global.set_player(self)
	Global.player_name = player_name
	stamina_bar.modulate = Color(0, 127, 0)
	quest_manager.quest_updated.connect(_on_quest_updated)
	quest_manager.objectives_updated.connect(_on_objective_updated)

func _process(_delta: float) -> void:
	interface_check()
	health_check()
	stamina_check()
	magic_check()

func _physics_process(_delta: float) -> void:
	animation_check()
	interface_check_bars()
	if can_move:
		input_check()
		interact_check()
		camera_check()

func input_check() -> void:
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
						magic_cast()
	if Input.is_action_just_pressed("inventory"):
		inventory_check()
		quest_manager.quest_log_toggle()
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("show_fps"):
		if fps_label.get_parent().visible == false:
			fps_label.get_parent().visible = true
		else:
			fps_label.get_parent().visible = false
	if fps_label.get_parent().visible == true:
		fps_label.text = str(Engine.get_frames_per_second())

func interact_check() -> void:
	if recent_pickup == true:
		time_since_pickup += 1
		if time_since_pickup == 50:
			Global.inventory_updated.emit()
		if time_since_pickup > 100:
			time_since_pickup = 0
			recent_pickup = false
	if can_move:
		if Input.is_action_just_pressed("interact"):
			var target: Node = ray_cast.get_collider()
			if target != null:
				if target.is_in_group("NPC"):
					can_move = false
					target.dialogue_start()
					quest_objectives_check(target.npc_id, "talk_to")
				elif target.is_in_group("QuestItem"):
					if quest_items_check(target.item_id):
						quest_objectives_check(target.item_id, "collection", target.item_quantity)
						target.get_parent().queue_free()
					else:
						print("Item not needed for any active quest.")
	if ray_cast.is_colliding():
		var target: Node = ray_cast.get_collider()
		interact_ui.visible = true
		if target != null:
			if target.is_in_group("NPC"):
				interact_label.text = target.npc_name
			elif target.is_in_group("QuestItem"):
				interact_label.text = target.get_parent().item_name
	elif !ray_cast.is_colliding() && !in_interact_area:
		interact_ui.visible = false

func interface_check():
	if interface.visible == false:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	elif inventory.visible == true:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		get_tree().paused = true
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_tree().paused = false

func interface_check_bars() -> void:
	var stamina_tween: float = stamina
	var s_tween: Tween = create_tween()
	var magic_tween: float = magic
	var m_tween: Tween = create_tween()
	s_tween.tween_property(stamina_bar, "value", stamina_tween, 0.1)
	m_tween.tween_property(magic_bar, "value", magic_tween, 0.1)

func inventory_check() -> void:
	if looting == false:
		if inventory.visible == false:
			Global.inventory_updated.emit()
			animation_tree.active = false
			inventory.visible = true
			stats_ui.visible = true
			get_tree().paused = true
		elif inventory.visible == true:
			animation_tree.active = true
			inventory.visible = false
			stats_ui.visible = false
			get_tree().paused = false

func health_check() -> void:
	health_bar.value = health
	#health_label.text = str(health as int).pad_zeros(3)
	if health == 0:
		print("DEAD")
		process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func health_heal(amount: float) -> void:
	if health < max_health:
		health += amount
		if health > max_health:
			health = max_health

func health_damage(amount: float) -> void:
	if health > 0:
		health -= amount

func stamina_check() -> void:
	#stamina_label.text = str(stamina as int).pad_zeros(3)
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
				stamina_bar.modulate = Color.RED
				if stamina == 0:
					await get_tree().create_timer(2.0).timeout
				stamina += stamina_gain
				if stamina > max_stamina / PI:
					stamina_cooldown = false
					stamina_bar.modulate = Color(0, 127, 0)
			elif stamina_cooldown == false:
				stamina += stamina_gain

func stamina_heal(amount: float) -> void:
	if stamina < max_stamina:
		stamina += amount
		if stamina > max_stamina:
			stamina = max_stamina

func stamina_damage(amount: float) -> void:
	if stamina > 0:
		stamina -= amount

func magic_check() -> void:
	#magic_label.text = str(magic as int).pad_zeros(3)
	if magic < 0:
		magic = 0
	if get_tree().paused == false && magic < max_magic:
		if magic < 0.48:
			#magic_label.self_modulate = Color.RED
			await get_tree().create_timer(1.5).timeout
			magic = 0.49
		if magic >= 0.49 && magic_cooldown == false:
			magic += magic_gain
	#if magic < magic_drain:
		#magic_label.self_modulate = Color.RED
	#else:
		#magic_label.self_modulate = Color.WHITE
	if magic > max_magic:
		magic = max_magic

func magic_cast() -> void:
	if magic_cooldown == false:
		var new_fireball: Node = FIREBALL.instantiate()
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

func magic_heal(amount: float) -> void:
	if magic < max_magic:
		magic += amount
		if magic > max_magic:
			magic = max_magic

func magic_damage(amount: float) -> void:
	if magic > 0:
		magic -= amount

func item_effect(item: Dictionary) -> void:
	should_use = false
	if interface.visible == true:
		match item["effect"]:
			"Health":
				if health >= max_health:
					print("Already at max Health.")
				else:
					should_use = true
					health_heal(item["magnitude"])
					print("Healed " + str(item["magnitude"]) + " HP")
			"Stamina":
				if stamina >= max_stamina:
					print("Already at max Stamina.")
				else:
					should_use = true
					stamina_heal(item["magnitude"])
					print("Healed " + str(item["magnitude"]) + " Stamina")
			"Magic":
				if magic >= max_magic:
					print("Already at max Magic.")
				else:
					should_use = true
					magic_heal(item["magnitude"])
					print("Healed " + str(item["magnitude"]) + " MP")
			"Inventory":
				if Global.inventory.size() >= Global.inventory_max:
					print("Already at max Inventory capacity.")
				else:
					should_use = true
					Global.inventory_increase_size(item["magnitude"])
					Global.inventory_full = false
					print("Inventory Slots +" + str(item["magnitude"]))
			"Damage":
				should_use = true
				health_damage(item["magnitude"])
				print("Damaged " + str(item["magnitude"]) + " HP")
			_:
				print("This item has no effect")

func animation_check() -> void:
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
				if hand.equipped_item.type != "Spell" || magic > magic_drain && magic_cooldown == false:
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

func camera_check() -> void:
	last_direction = direction
	if last_direction != direction:
		last_direction = direction
	if direction != Vector2.ZERO:
		position.x = round(position.x)
		position.y = round(position.y)
	follow_camera.position = position

func quest_tracker_check(quest: Quest) -> void:
	if quest:
		quest_tracker.visible = true
		quest_objectives.visible = true
		if inventory.visible == true:
			quest_tracker.modulate = Color(1, 1, 1, 1)
		else:
			quest_tracker.modulate = Color(1, 1, 1, 0.8)
		quest_title.text = quest.quest_name
		for child in quest_objectives.get_children():
			quest_objectives.remove_child(child)
		for objective in quest.objectives:
			var label: Label = Label.new()
			label.text = objective.description
			if objective.is_completed:
				label.add_theme_font_size_override("font_size", 12)
				label.add_theme_color_override("font_color", Color(0, 1, 0))
			else:
				label.add_theme_font_size_override("font_size", 12)
				label.add_theme_color_override("font_color", Color(1, 0, 0))
			quest_objectives.add_child(label)
	elif !quest && inventory.visible == true:
		quest_title.text = "No Active Quests"
		quest_tracker.modulate = Color(1, 1, 1, 1)
		quest_tracker.visible = true
		quest_objectives.visible = false
	else:
		quest_tracker.visible = false

func quest_items_check(item_id: String) -> bool:
	if current_quest != null:
		for objective in current_quest.objectives:
			if objective.target_id == item_id && objective.target_type == "collection" && not objective.is_completed:
				return true
	return false

func quest_objectives_check(target_id: String, target_type: String, quantity: int = 1) -> void:
	if current_quest == null:
		return
	var objective_updated: bool = false
	for objective in current_quest.objectives:
		if objective.target_id == target_id && objective.target_type == target_type && not objective.is_completed:
			current_quest.complete_objective(objective.id, quantity)
			objective_updated = true
			break
	if objective_updated:
		if current_quest.complete():
			quest_completion_check(current_quest)
		quest_tracker_check(current_quest)

func quest_completion_check(quest: Quest) -> void:
	for reward in quest.rewards:
		if reward.reward_type == "Gold":
			var item_instance: Dictionary = {
			"quantity" : reward.reward_amount,
			"id" : gold.id,
			"type" : gold.type,
			"equippable" : gold.equippable,
			"name" : gold.name,
			"texture" : gold.texture,
			"effect" : gold.effect,
			"magnitude" : gold.magnitude,
			"scene_path" : gold.scene,
			}
			Global.item_add(item_instance)
	quest_tracker_check(quest)
	quest_manager.quest_update(quest.quest_id, "completed")

func _on_quest_updated(quest_id: String) -> void:
	var quest: Quest = quest_manager.quest_get(quest_id)
	if quest == current_quest:
		quest_tracker_check(quest)
	current_quest = null

func _on_objective_updated(quest_id: String, _objective_id: String) -> void:
	if current_quest && current_quest.quest_id == quest_id:
		quest_tracker_check(current_quest)
	current_quest = null
