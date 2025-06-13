extends CharacterBody3D

@export_group("Custom Values")
@export var jump_speed: float = 5.0
@export var jump_drain: float = 4.0
@export var walk_speed: float = 8.0
@export var run_speed: float = 16.0
@export var push_force: float = 100.0
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
@export var jumping: bool

@onready var model = %Skeleton
@onready var hud = $HUD
@onready var inventory = $HUD/Inventory
@onready var camera_pivot1p = $CameraPivot1P
@onready var camera_pivot3p = $CameraPivot3P
@onready var camera1p = $CameraPivot1P/Camera
@onready var camera3p = $CameraPivot3P/Camera
@onready var raycast1p = $CameraPivot1P/Camera/RayCast3D
@onready var raycast3p = $CameraPivot3P/Camera/RayCast3D

var direction
var input_dir
var last_position
var camera
var raycast
var speed = walk_speed
var health = max_health
var stamina = max_stamina
var magic = max_magic
var stamina_cooldown = false
var magic_cooldown = false
var mouse_sens = 0.3

var looting = false
var object = null
var should_use = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.set_player(self)
	camera = camera1p
	raycast = raycast1p

func _process(_delta: float) -> void:
	if inventory.visible == true:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		get_tree().paused = true
		position.y = last_position.y
		velocity.y = 0.0
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_tree().paused = false
		position.y = position.y

func _physics_process(delta: float) -> void:
	check_positions(delta)
	check_input()
	push_pushables(delta)
	check_raycast()
	check_health()
	check_stamina()

func _input(event):
	if event is InputEventMouseMotion && Input.mouse_mode != Input.MOUSE_MODE_CONFINED:
		if camera == camera1p:
			rotate_y(deg_to_rad(-event.relative.x*mouse_sens))
			camera_pivot1p.rotate_x(deg_to_rad(-event.relative.y*mouse_sens))
			camera_pivot1p.rotation.x = clamp(camera_pivot1p.rotation.x, deg_to_rad(-90.0), deg_to_rad(90.0))
		elif camera == camera3p:
			rotate_y(deg_to_rad(-event.relative.x*mouse_sens))
			camera_pivot3p.rotate_x(deg_to_rad(-event.relative.y*mouse_sens))
			camera_pivot3p.rotation.x = clamp(camera_pivot3p.rotation.x, deg_to_rad(-60.0), deg_to_rad(60.0))
	if Input.is_action_just_pressed("inventory"):
		if looting == false:
			if inventory.visible == false:
				inventory.visible = true
			elif inventory.visible == true:
				inventory.visible = false
	if Input.is_action_just_pressed("view"):
		if camera == camera1p:
			camera = camera3p
			raycast = raycast3p
			camera1p.current = false
			camera3p.current = true
			raycast1p.enabled = false
			raycast3p.enabled = true
			model.visible = true
		elif camera == camera3p:
			camera = camera1p
			raycast = raycast1p
			camera3p.current = false
			camera1p.current = true
			raycast3p.enabled = false
			raycast1p.enabled = true
			model.visible = false
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func check_positions(delta):
	last_position = position
	if is_on_floor() == false:
		idle = false
		walking = false
		running = false
		jumping = true
		velocity += get_gravity() * delta
	if is_on_floor() == true:
		jumping = false
	if camera == camera1p:
		camera_pivot3p.rotation.x = clamp(camera_pivot1p.rotation.x, deg_to_rad(-60.0), deg_to_rad(60.0))
	elif camera == camera3p:
		camera_pivot1p.rotation.x = clamp(camera_pivot3p.rotation.x, deg_to_rad(-90.0), deg_to_rad(90.0))

func check_input():
	input_dir = Input.get_vector("left", "right", "up", "down")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction && inventory.visible == false:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if is_on_floor():
			walking = true
		idle = false
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		walking = false
		if !jumping:
			idle = true
	if Input.is_action_pressed("run"):
		if direction != Vector3.ZERO && last_position != position.round() && is_on_floor():
			if stamina != 0 && stamina_cooldown == false:
				if is_on_floor():
					running = true
					jumping = false
				walking = false
				idle = false
				speed = run_speed
				last_position = position.round()
			elif last_position == position.round() || stamina == 0 && is_on_floor():
				Input.action_release("run")
				running = false
				if is_on_floor():
					walking = true
					jumping = false
				idle = false
				speed = walk_speed
				last_position = position.round()
	if Input.is_action_just_released("run") && is_on_floor():
		speed = walk_speed
		running = false
		walking = true
	if Input.is_action_just_pressed("autorun"):
		Input.action_press("up")
	if Input.is_action_just_pressed("jump") && inventory.visible == false && is_on_floor() :
		idle = false
		walking = false
		if stamina_cooldown == false && stamina > 1:
			if velocity.x == 0 and velocity.z == 0:
				jumping = true
				velocity.y = jump_speed
				stamina -= jump_drain
			elif velocity.x != 0 || velocity.z != 0:
				jumping = true
				running = false
				velocity.y = jump_speed
				stamina -= jump_drain
	if velocity.y > jump_speed:
			velocity.y = jump_speed
	if velocity.x > run_speed:
			velocity.x = run_speed
	if velocity.z > run_speed:
			velocity.z = run_speed
	move_and_slide()

func push_pushables(delta: float) -> void:
	var col := get_last_slide_collision()
	if col:
		var col_collider := col.get_collider()
		var col_position := col.get_position()
		if not col_collider is RigidBody3D:
			return
		var push_direction := -col.get_normal()
		var push_position = col_position - col_collider.global_position
		col_collider.apply_impulse(push_direction * push_force * delta, push_position)

func check_raycast():
	if raycast.is_colliding():
		object = raycast.get_collider().get_parent()
		if Input.is_action_just_pressed("interact"):
			if object.has_method("pickup_item"):
				raycast.enabled = false
				object.pickup_item()
				await get_tree().create_timer(250).timeout
	raycast.enabled = true

func check_health():
	if health > max_health:
		health = max_health
	if health <= 0:
		health = 0
		print("GAME OVER")
		get_tree().quit()

func check_stamina():
	if running == true && idle == false && stamina_cooldown == false:
		if last_position != position.round():
			stamina -= stamina_drain
	if stamina <= 0:
		stamina_cooldown = true
		stamina = 0
	if stamina >= max_stamina:
		stamina = max_stamina
	if stamina <= max_stamina:
		if get_tree().paused == false && running == false:
			if stamina_cooldown == true:
				hud.stamina_label.self_modulate = Color.RED
				if stamina == 0:
					await get_tree().create_timer(2.0, false).timeout
					stamina = 0.1
				if stamina > 0:
					stamina += stamina_gain
				if stamina > max_stamina / PI:
					stamina_cooldown = false
					hud.stamina_label.self_modulate = Color.WHITE
			elif stamina_cooldown == false:
				stamina += stamina_gain

func heal_health(amount):
	if health < max_health:
		health += amount

func damage_health(amount):
	if health > 0:
		health -= amount

func heal_stamina(amount):
	if stamina < max_stamina:
		stamina += amount

func apply_item_effect(item):
	should_use = false
	match item["effect"]:
		"Stamina":
			if stamina >= max_stamina:
				print("")
				print("Already at max Stamina.")
			else:
				should_use = true
				heal_stamina(item["magnitude"])
				print("Healed " + str(item["magnitude"]) + " Stamina")
		"Health":
			if health >= max_health:
				print("")
				print("Already at max Health.")
			else:
				should_use = true
				heal_health(item["magnitude"])
				print("Healed " + str(item["magnitude"]) + " HP")
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
			print("Damaged 10HP")
		_:
			print("")
			print("This item has no effect")
