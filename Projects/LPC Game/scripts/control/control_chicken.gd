extends CharacterBody2D

@export var health = 10
@export var speed: float = 111.0
@export var spawn_chance: float = 0.5
@export var evil = false
@export var explosion_scene: PackedScene

@onready var animation_tree = $AnimationTree
@onready var player = get_tree().get_first_node_in_group("player")
@onready var spawn_point = get_parent()

var direction = Vector2(0.0, 1.0)
var damage_collision
var direction_timer
var idle_timer
var tween
var explosion_instance

func _ready():
	if evil == true:
		damage_collision = $DamageCollision
	elif evil == false:
		direction_timer = $DirectionTimer
		idle_timer = $IdleTimer

func _physics_process(_delta):
	animation_parameters()
	if evil == true:
		speed = player.speed
		if direction:
			velocity = direction * speed
		else:
			velocity = Vector2.ZERO
		if player.velocity != Vector2.ZERO:
			move_and_slide()
			direction = (-player.position - position).normalized()
	if evil == false:
		movement()

func animation_parameters():
	if velocity == Vector2.ZERO:
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	else:
		animation_tree["parameters/conditions/is_moving"] = true
		animation_tree["parameters/conditions/idle"] = false
	if direction != Vector2.ZERO:
		animation_tree["parameters/Idle/blend_position"] = direction
		animation_tree["parameters/Walk/blend_position"] = direction

func movement():
	if direction:
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	if get_last_slide_collision():
		direction = (-direction + Vector2(randf_range(-0.95,0.95),randf_range(-0.95,0.95))).normalized()

func choose_random_direction():
		direction = Vector2(randf_range(-1.0,1.0),randf_range(-1.0,1.0)).normalized()

func _on_direction_timer_timeout():
	if animation_tree["parameters/conditions/idle"] == true:
		choose_random_direction()
		direction_timer.start(randf_range(1.0,5.0))

func _on_idle_timer_timeout():
	direction = Vector2.ZERO
	idle_timer.start(randf_range(3.0,7.0))

func _on_damage_collision_body_entered(body):
	if evil == true && body == player:
		body.damage_health(10)
		
func damage_health(damage):
	health -= damage
	if health >= 0:
		direction = Vector2.ZERO
		explosion_instance = explosion_scene.instantiate()
		explosion_instance.position = position
		explosion_instance.z_index = 4096
		explosion_instance.one_shot = true
		spawn_point.add_child(explosion_instance)
		tween = get_tree().create_tween()
		tween.tween_property(self, "scale", Vector2(), 0.25)
		tween.tween_callback(queue_free)
