extends CharacterBody2D

@export var player_name: String

@export var speed: float
@export var health_max: float = 100.0
@export var stamina_max: float = 100.0
@export var magic_max: float = 100.0
@export var stamina_drain: float = 0.15
@export var stamina_gain: float = 0.05
@export var magic_drain: float = 10
@export var magic_gain: float = 0.025

@onready var animation_tree: AnimationTree = $AnimationTree

var hsm: LimboHSM

var direction: Vector2
var position_last: Vector2
var direction_last: Vector2

var speed_walk: float = 100.0
var speed_run: float = 200.0
var health: float = health_max
var stamina: float = stamina_max
var magic: float = magic_max

var idle: bool = true
var walk: bool = false
var run: bool = false

var stamina_cooldown: bool = false
var stamina_full: bool = true
var magic_cooldown: bool = false

func _ready() -> void:
	player_init()

func _process(_delta: float) -> void:
	check_stamina()
	check_test_labels()

func _physics_process(_delta: float) -> void:
	if direction:
		direction = direction.round()
		direction_last = direction.round()
		velocity = direction * speed
		position = position.round()
		position_last = position.round()
		
	else:
		velocity = Vector2.ZERO
		hsm.dispatch(&"reset")
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if Input.is_action_just_pressed("interact"):
			print(Global.player_name, ": interact")

func player_init() -> void:
	Global.set_player(self)
	Global.player_name = player_name
	player_state_init()

func player_state_init() -> void:
	hsm = LimboHSM.new()
	add_child(hsm)
	var state_idle: LimboState = LimboState.new().named("Idle").call_on_enter(state_idle_ready).call_on_update(state_idle_process)
	var state_walk: LimboState = LimboState.new().named("Walk").call_on_enter(state_walk_ready).call_on_update(state_walk_process)
	var state_run: LimboState = LimboState.new().named("Run").call_on_enter(state_run_ready).call_on_update(state_run_process)
	hsm.add_child(state_idle)
	hsm.add_child(state_walk)
	hsm.add_child(state_run)
	hsm.add_transition(state_idle, state_walk, &"walk_start")
	hsm.add_transition(state_walk, state_idle, &"walk_stop")
	hsm.add_transition(state_walk, state_run, &"run_start")
	hsm.add_transition(state_run, state_walk, &"run_stop")
	hsm.add_transition(hsm.ANYSTATE, state_idle, &"reset")
	hsm.initial_state = state_idle
	hsm.initialize(self)
	hsm.set_active(true)

func state_idle_ready() -> void:
	speed = speed_walk
	run = false
	walk = false
	idle = true
	animation_tree.set("parameters/Idle/blend_position", direction_last)

func state_idle_process(_delta: float) -> void:
	if velocity != Vector2.ZERO && position_last != position.round():
		hsm.dispatch(&"walk_start")

func state_walk_ready() -> void:
	speed = speed_walk
	idle = false
	run = false
	walk = true
	animation_tree.set("parameters/Walk/blend_position", velocity.normalized())

func state_walk_process(_delta: float) -> void:
	if velocity == Vector2.ZERO || position_last == position.round():
		hsm.dispatch(&"walk_stop")
	if Input.is_action_pressed("run"):
		if position_last != position.round() && stamina_cooldown == false:
			hsm.dispatch(&"run_start")

func state_run_ready() -> void:
	speed = speed_run
	idle = false
	walk = false
	run = true
	animation_tree.set("parameters/Run/blend_position", velocity.normalized())

func state_run_process(_delta: float) -> void:
	if stamina_cooldown == false:
		stamina -= stamina_drain
	if stamina < 0:
		stamina_cooldown = true
		stamina = 0
	if Input.is_action_just_released("run") || stamina_cooldown == true || position_last == position.round():
			hsm.dispatch(&"run_stop")

func check_stamina() -> void:
	if get_tree().paused == false:
		if stamina < stamina_max:
			stamina_full = false
		if stamina_full == false:
			if stamina_cooldown == true:
				if stamina == 0:
					await get_tree().create_timer(2.0).timeout
				stamina += stamina_gain
				if stamina > stamina_max / PI:
					stamina_cooldown = false
			elif stamina_cooldown == false:
				stamina += stamina_gain
			if stamina > stamina_max:
				stamina_full = true
				stamina = stamina_max

func check_test_labels() -> void:
	Global.player_interface.test_label_1.text = str(" 	 Stats: HP: " + str(health).pad_decimals(1) + " | SP: ") + str(stamina).pad_decimals(1) + " | MP: " + str(magic).pad_decimals(1)
	Global.player_interface.test_label_2.text = str(" 	 Last Pos: " + str(position_last.x).pad_decimals(1).pad_zeros(4) + " , " + str(position_last.y).pad_decimals(1).pad_zeros(4) + " | Last Dir: " + str(direction_last.x).pad_decimals(1).pad_zeros(4) + " , " + str(direction_last.y).pad_decimals(1).pad_zeros(4))
	Global.player_interface.test_label_3.text = str(" 	 Speed: " + str(speed) + " | State: " + str(hsm.get_active_state().name) + " | Stamina Cooldown: " + str(stamina_cooldown).capitalize())
