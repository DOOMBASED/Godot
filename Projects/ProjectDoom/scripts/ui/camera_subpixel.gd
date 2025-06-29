extends Camera2D

@onready var player: CharacterBody2D = Global.player

var camera_position: Vector2
var camera_speed: float

func _ready() -> void:
	camera_position = player.global_position
	camera_speed = 4

func _physics_process(delta: float) -> void:
	if camera_position.round() != player.global_position.round():
		camera_position = camera_position.lerp(player.global_position, delta * camera_speed)
		var camera_subpixel_offset = camera_position.round() - camera_position
		Global.viewport.material.set_shader_parameter("camera_offset", camera_subpixel_offset)
		global_position = camera_position.round()
