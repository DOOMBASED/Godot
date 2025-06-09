extends CharacterBody3D

@export_group("Custom Values")
@export var jump_speed: float = 5.0
@export var walk_speed: float = 8.0
@export var run_speed: float = 16.0
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

@onready var model = $Mesh
@onready var camera_pivot1p = $CameraPivot1P
@onready var camera_pivot3p = $CameraPivot3P
@onready var camera1p = $CameraPivot1P/Camera
@onready var camera3p = $CameraPivot3P/Camera
@onready var raycast1p = $CameraPivot1P/Camera/RayCast3D
@onready var raycast3p = $CameraPivot3P/Camera/RayCast3D
@onready var fps_label = $HUD/FPSLabel
@onready var health_bar = $HUD/HealthBar
@onready var health_label = $HUD/HealthLabel
@onready var stamina_bar = $HUD/StaminaBar
@onready var stamina_label = $HUD/StaminaLabel
@onready var object_label = $HUD/ObjectLabel
@onready var test_label = $HUD/TestLabel
@onready var inventory = $HUD/Inventory
@onready var inventory_grid = $HUD/Inventory/TextureRect/GridContainer

var direction = Vector3.ZERO
var input_dir
var last_direction
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

var test_boxes = 0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.set_player(self)
	Global.inventory_updated.connect(_on_inventory_updated)
	camera = camera1p
	raycast = raycast1p
	_on_inventory_updated()

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
	last_position = position
	if is_on_floor() == false:
		velocity += get_gravity() * delta
	
	if camera == camera1p:
		camera_pivot3p.rotation.x = clamp(camera_pivot1p.rotation.x, deg_to_rad(-60.0), deg_to_rad(60.0))
	elif camera == camera3p:
		camera_pivot1p.rotation.x = clamp(camera_pivot3p.rotation.x, deg_to_rad(-90.0), deg_to_rad(90.0))

	if object != null:
		if object.is_in_group("Items"):
			object_label.text = "Object: " + str(object.item_name)
		else:
			object_label.text = "Object: " + str(object.name)
	elif object == null:
		object_label.text = "Object: " + "NULL"
	object = null

	check_input()
	check_health()
	check_stamina()
	animate_bars()

	test_label.text = "TEST"

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

func check_input():
	input_dir = Input.get_vector("left", "right", "up", "down")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction && inventory.visible == false:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		last_direction = direction
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	if Input.is_action_pressed("run"):
		if direction != Vector3.ZERO && last_position != position.round() && is_on_floor():
			if stamina != 0 && stamina_cooldown == false:
				running = true
				walking = false
				speed = run_speed
				last_position = position.round()
			elif last_position == position.round() || stamina == 0:
				Input.action_release("run")
				running = false
				walking = true
				speed = walk_speed
				last_position = position.round()
	if Input.is_action_just_released("run"):
		speed = walk_speed
		running = false
		walking = true
	if Input.is_action_just_pressed("autorun"):
		Input.action_press("up")
	if Input.is_action_just_pressed("jump") && inventory.visible == false && is_on_floor() :
		if stamina_cooldown == false && stamina > 1:
			velocity.y = jump_speed
			stamina -= 5
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
	if Input.is_action_just_pressed("show_fps"):
		if fps_label.visible == false:
			fps_label.visible = !fps_label.visible
	if fps_label.visible == true:
		fps_label.text = "FPS: " + str(Engine.get_frames_per_second() as int)
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	move_and_slide()

	if raycast.is_colliding():
		object = raycast.get_collider().get_parent()
		if object.has_method("pickup_item") && Input.is_action_just_pressed("interact"):
			raycast.enabled = false
			if object.is_in_group("Box"):
				object.pickup_item()
				test_boxes += 1
			await get_tree().create_timer(250).timeout
		if object.has_method("open") && Input.is_action_just_pressed("interact"):
				raycast.enabled = false
				object.open()
				await get_tree().create_timer(250).timeout
	raycast.enabled = true

func check_health():
	health_bar.value = health
	health_label.text = "Health:  " + str(health as int).pad_zeros(3)
	if health == 0:
		print("GAME OVER")
		get_tree().quit()

func check_stamina():
	stamina_label.text = "Stamina: " + str(stamina as int).pad_zeros(3)
	if running == true && stamina_cooldown == false:
		if last_position != position.round():
			stamina -= stamina_drain
	if stamina < 0:
		stamina_cooldown = true
		stamina = 0
	if stamina > max_stamina:
		stamina = max_stamina
	if stamina < max_stamina:
		if running == false:
			if stamina_cooldown == true:
				stamina_label.self_modulate = Color.RED
				if stamina == 0:
					await get_tree().create_timer(2.0).timeout
				stamina += stamina_gain
				if stamina > max_stamina / PI:
					stamina_cooldown = false
					stamina_label.self_modulate = Color.WHITE
			elif stamina_cooldown == false && get_tree().paused == false:
				stamina += stamina_gain

func animate_bars():
	var health_tween = health
	var m_tween = create_tween()
	m_tween.tween_property(health_bar, "value", health_tween, 0.1)
	var stamina_tween = stamina
	var s_tween = create_tween()
	s_tween.tween_property(stamina_bar, "value", stamina_tween, 0.1)

func _on_inventory_updated():
	clear_grid_container()
	for item in Global.inventory:
		var slot = Global.inventory_slot_scene.instantiate()
		inventory_grid.add_child(slot)
		if item != null:
			slot.set_item(item)
		else:
			slot.set_empty()

func clear_grid_container():
	while inventory_grid.get_child_count() > 0:
		var child = inventory_grid.get_child(0)
		inventory_grid.remove_child(child)
		child.queue_free()

func damage_health(damage):
	health -= damage
	if health < 0:
		health = 0

func heal_health(hitpoints):
	if health <= max_health:
		health += hitpoints
	if health > max_health:
		health = max_health

func apply_item_effect(item):
	match item["effect"]:
		"Stamina":
			run_speed += run_speed
			print("Run Speed increased to " + str(run_speed))
		"Health":
			heal_health(item["magnitude"])
			print("Healed " + str(item["magnitude"]) + " HP")
		"Damage":
			damage_health(item["magnitude"])
			print("Damaged 10HP")
		"Inventory+":
			Global.increase_inventory_size(item["magnitude"])
			print("Inventory Slots +" + str(item["magnitude"]))
		_:
			print("This item has no effect")
