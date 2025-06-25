extends Control

@onready var sub_viewport_container: SubViewportContainer = $SubViewportContainer

func _ready() -> void:
	Global.set_viewport(sub_viewport_container)
