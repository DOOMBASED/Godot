extends Camera2D

@onready var player: CharacterBody2D = Global.player

var camera_position: Vector2

func _ready() -> void:
	camera_position = player.global_position

func _process(delta: float) -> void:
	camera_position = camera_position.lerp(player.global_position, delta * PI)
	var camera_subpixel_offset = camera_position.round() - camera_position
	Global.viewport.material.set_shader_parameter("camera_offset", camera_subpixel_offset)
	global_position = camera_position.round()
