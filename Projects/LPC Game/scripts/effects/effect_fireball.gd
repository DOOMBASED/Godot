extends Area2D

@export var damage: int = 10
@export var speed: int = 300
@export var projectile_range: int = 300

var direction: Vector2
var distance: int = 0
var tween: Tween

func _ready():
	direction = Global.player_node.fireball_direction
	rotation = Global.player_node.fireball_direction.angle()
	if direction == Vector2.ZERO:
		Global.player_node.magic += Global.player_node.magic_drain
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
