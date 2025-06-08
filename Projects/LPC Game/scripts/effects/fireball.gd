extends Area2D

@export var damage: int = 10
@export var speed: int = 300
@export var projectile_range: int = 300

@onready var player = get_tree().get_first_node_in_group("player")

var direction
var distance = 0
var tween

func _ready():
	direction = player.fireball_direction
	rotation = player.projectile_origin.rotation
	if direction == Vector2.ZERO:
		player.magic += player.magic_drain
		queue_free()

func _physics_process(delta):
	position += direction * speed * delta
	distance += speed * delta
	if distance > projectile_range:
		tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.25)
		tween.tween_callback(queue_free)

func _on_body_entered(body):
	if body.has_method("damage_health"):
		body.damage_health(damage)
	direction = Vector2.ZERO
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.25)
	tween.tween_callback(queue_free)
