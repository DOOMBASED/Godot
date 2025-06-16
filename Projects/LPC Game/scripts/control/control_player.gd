class_name Player
extends CharacterBody2D

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

@onready var animation_tree = $AnimationTree
@onready var follow_camera = $"../Camera"
@onready var interface = $Interface
@onready var inventory = $Interface/HUD/InventoryUI
@onready var fps_label = $Interface/HUD/FPSLabel/Label
@onready var hand = $Hand
@onready var projectile_origin = $ProjectileOrigin
@onready var health_bar = $Interface/HUD/HealthBars/Health
@onready var health_label = health_bar.get_child(0)
@onready var stamina_bar = $Interface/HUD/HealthBars/Stamina
@onready var stamina_label: = stamina_bar.get_child(0)
@onready var magic_bar = $Interface/HUD/HealthBars/Magic
@onready var magic_label = magic_bar.get_child(0)

const FIREBALL = preload("res://scenes/effects/fireball.tscn")

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

var looting = false

var should_use = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.set_player(self)
	interface.visible = true

func _process(_delta):
	if inventory.visible == true:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		get_tree().paused = true
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_tree().paused = false
	check_health()
	check_stamina()
	check_magic()

func _physics_process(_delta):
	animation_parameters()
	check_input()
	animate_bars()
	camera_follow()
	if get_tree().paused == false:
		move_and_slide()

func check_input():
	if get_tree().paused == false:
		direction = Input.get_vector("left", "right", "up", "down").normalized()
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
	if Input.is_action_just_pressed("use"):
		if hand.equipped_item != null:
			if hand.equipped_item.display_name == "Fireball" && magic >= magic_drain:
				if magic_cooldown == false:
					shoot_fireball()
	if Input.is_action_just_pressed("inventory"):
		open_inventory()
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("show_fps"):
		if fps_label.visible == false:
			fps_label.visible = true
		else:
			fps_label.visible = false
	if fps_label.visible == true:
		fps_label.text = str(Engine.get_frames_per_second())

func open_inventory():
	if looting == false:
		if inventory.visible == false:
			Global.inventory_updated.emit()
			inventory.visible = true
			get_tree().paused = true
			animation_tree.active = false
		elif inventory.visible == true:
			inventory.visible = false
			get_tree().paused = false
			animation_tree.active = true

func check_health():
	health_bar.value = health
	health_label.text = str(health as int).pad_zeros(3)
	if health == 0:
		print("DEAD")
		process_mode = Node.PROCESS_MODE_WHEN_PAUSED

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
	if magic < max_magic:
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
				print("")
				print("Already at max Health.")
			else:
				should_use = true
				heal_health(item["magnitude"])
				print("Healed " + str(item["magnitude"]) + " HP")
		"Stamina":
			if stamina >= max_stamina:
				print("")
				print("Already at max Stamina.")
			else:
				should_use = true
				heal_stamina(item["magnitude"])
				print("Healed " + str(item["magnitude"]) + " Stamina")
		"Magic":
			if magic >= max_magic:
				print("")
				print("Already at max Magic.")
			else:
				should_use = true
				heal_magic(item["magnitude"])
				print("Healed " + str(item["magnitude"]) + " MP")
		"Inventory":
			if Global.inventory.size() >= Global.inventory_max:
				print("")
				print("Already at max Inventory capacity.")
			else:
				should_use = true
				Global.increase_inventory_size(item["magnitude"])
				print("")
				print("Inventory Slots +" + str(item["magnitude"]))
		"Damage":
			should_use = true
			damage_health(item["magnitude"])
			print("")
			print("Damaged " + str(item["magnitude"]) + " HP")
		_:
			print("")
			print("This item has no effect")

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
			if hand.equipped_item.display_name != "Fireball" || magic > magic_drain && magic_cooldown == false:
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
