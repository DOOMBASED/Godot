class_name Player
extends CharacterBody2D

@export var player_name: String

@export var speed: float
@export var health_max: float = 100.0
@export var stamina_max: float = 100.0
@export var magic_max: float = 100.0
@export var stamina_drain: float = 0.30
@export var stamina_gain: float = 0.15

@export var idle: bool = true
@export var walk: bool = false
@export var swing: bool = false
@export var run: bool = false

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var effects: Node = $Effects

var hsm: LimboHSM = null
var inventory: Inventory = null

var state_idle: LimboState
var state_walk: LimboState
var state_swing: LimboState
var state_run: LimboState

var direction: Vector2
var position_last: Vector2
var direction_last: Vector2

var speed_walk: float = 100.0
var speed_run: float = 200.0
var health: float = health_max
var stamina: float = stamina_max
var magic: float = magic_max

var dead: bool = false
var can_move:bool = true
var stamina_cooldown: bool = false
var stamina_full: bool = true
var recent_pickup: bool = false
var recent_pickup_time: int = 0

func _ready() -> void:
	player_init()

func _process(_delta: float) -> void:
	health_check()
	stamina_check()
	magic_check()
	pickup_check()

func _physics_process(_delta: float) -> void:
	if can_move:
		if direction:
			direction = direction.round()
			direction_last = direction.round()
			position = position.round()
			position_last = position.round()
			velocity = direction * speed
			move_and_slide()
		else:
			if velocity != Vector2.ZERO:
				velocity = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if !inventory.inventory_ui.visible && Input.is_action_pressed("swing"):
			if hsm.get_active_state() != state_swing && swing != true:
				hsm.dispatch(&"swing_start")

func player_init() -> void:
	Global.set_player(self)
	Global.player_name = player_name
	inventory = Inventory
	direction_last = Vector2(0.0, 1.0)
	state_init()

func state_init() -> void:
	hsm = LimboHSM.new()
	add_child(hsm)
	state_idle = LimboState.new().named("Idle").call_on_enter(state_idle_ready).call_on_update(state_idle_process)
	state_walk = LimboState.new().named("Walk").call_on_enter(state_walk_ready).call_on_update(state_walk_process)
	state_swing = LimboState.new().named("Swing").call_on_enter(state_swing_ready).call_on_update(state_swing_process)
	state_run = LimboState.new().named("Run").call_on_enter(state_run_ready).call_on_update(state_run_process)
	hsm.add_child(state_idle)
	hsm.add_child(state_walk)
	hsm.add_child(state_swing)
	hsm.add_child(state_run)
	hsm.add_transition(state_idle, state_walk, &"walk_start")
	hsm.add_transition(state_walk, state_idle, &"walk_stop")
	hsm.add_transition(hsm.ANYSTATE, state_swing, &"swing_start")
	hsm.add_transition(state_swing, state_idle, &"swing_stop")
	hsm.add_transition(state_walk, state_run, &"run_start")
	hsm.add_transition(state_run, state_walk, &"run_stop")
	hsm.add_transition(hsm.ANYSTATE, state_idle, &"reset")
	hsm.initial_state = state_idle
	hsm.initialize(self)
	hsm.set_active(true)

func state_idle_ready() -> void:
	walk = false
	run = false
	swing = false
	idle = true
	can_move = true
	speed = speed_walk
	animation_tree.set("parameters/Idle/blend_position", direction_last)

func state_idle_process(_delta: float) -> void:  
	if velocity != Vector2.ZERO && position_last != position.round():
		idle = false
		hsm.dispatch(&"walk_start")

func state_walk_ready() -> void:
	animation_tree.set("parameters/Walk/blend_position", direction_last)
	speed = speed_walk

func state_walk_process(_delta: float) -> void:
	animation_tree["parameters/Walk/blend_position"] = direction_last
	walk = true
	if velocity == Vector2.ZERO || position_last == position.round():
		walk = false
		hsm.dispatch(&"walk_stop")
	if Input.is_action_pressed("run"):
		if position_last != position.round() && !stamina_cooldown:
			walk = false
			hsm.dispatch(&"run_start")

func state_run_ready() -> void:
	animation_tree.set("parameters/Run/blend_position", direction_last)
	speed = speed_run

func state_run_process(_delta: float) -> void:
	animation_tree["parameters/Run/blend_position"] = direction_last 
	speed = speed_run
	run = true
	if !stamina_cooldown:
		stamina -= stamina_drain
	if stamina < 0:
		stamina_cooldown = true
		stamina = 0
	if Input.is_action_just_released("run") || stamina_cooldown:
			run = false
			hsm.dispatch(&"run_stop")
	if direction == Vector2.ZERO || position_last.round() == position.round():
			run = false
			hsm.dispatch(&"reset")

func state_swing_ready() -> void:
	animation_tree.set("parameters/Swing Axe/blend_position", direction_last)
	swing = true
	can_move = false

func state_swing_process(_delta: float) -> void:
	if !swing:
		hsm.dispatch(&"swing_stop")

func state_swing_done() -> void:
	swing = false

func health_check() -> void:
	if !get_tree().paused:
		if health < health_max && !dead:
			if health <= 0:
				health = 0
				dead = true
				print("DEAD")

func stamina_check() -> void:
	if !get_tree().paused:
		if stamina < stamina_max:
			stamina_full = false
		if !stamina_full:
			if stamina_cooldown:
				if stamina == 0:
					await get_tree().create_timer(2.0).timeout
				stamina += stamina_gain
				if stamina > stamina_max / 4:
					stamina_cooldown = false
			elif !stamina_cooldown && !run:
				stamina += stamina_gain
			if stamina > stamina_max:
				stamina_full = true
				stamina = stamina_max

func magic_check() -> void:
	if !get_tree().paused:
		if magic < magic_max:
			print(magic)

func pickup_check() -> void:
	if recent_pickup:
		recent_pickup_time += 1
		if recent_pickup_time == 10:
			Inventory.inventory_updated.emit()
		if recent_pickup_time >= 20:
			recent_pickup_time = 0
			recent_pickup = false
