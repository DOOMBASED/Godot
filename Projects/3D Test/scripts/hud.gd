extends Control

@onready var player = $".."
@onready var health_bar = $HealthBar
@onready var health_label = $HealthBar/HealthLabel
@onready var stamina_bar = $StaminaBar
@onready var stamina_label = $StaminaBar/StaminaLabel
@onready var magic_bar = $MagicBar
@onready var magic_label = $MagicBar/MagicLabel
@onready var fps_label = $FPSLabel
@onready var object_label = $ObjectLabel
@onready var test_label = $TestLabel

var health
var stamina
var magic

func _ready() -> void:
	health = player.health
	stamina = player.stamina
	magic = player.magic

func _process(_delta: float) -> void:
	if player.object != null:
		if player.object.is_in_group("Items"):
			object_label.text = "Object: " + str(player.object.item_name)
		else:
			object_label.text = "Object: " + str(player.object.name)
	elif player.object == null:
		object_label.text = "Object: " + "NULL"
	player.object = null
	test_label.text = "TEST"
	if Input.is_action_just_pressed("show_fps"):
		fps_label.visible = !fps_label.visible
	if fps_label.visible == true:
		fps_label.text = "FPS: " + str(Engine.get_frames_per_second() as int)
	animate_bars()

func animate_bars():
	var health_tween = player.health
	var h_tween = create_tween()
	h_tween.tween_property(health_bar, "value", health_tween, 0.1)
	var stamina_tween = player.stamina
	var s_tween = create_tween()
	s_tween.tween_property(stamina_bar, "value", stamina_tween, 0.1)
	var magic_tween = player.magic
	var m_tween = create_tween()
	m_tween.tween_property(magic_bar, "value", magic_tween, 0.1)
	health_bar.value = player.health
	health_label.text = "Health:   " + str(player.health as int).pad_zeros(3)
	stamina_bar.value = player.stamina
	stamina_label.text = "Stamina:  " + str(player.stamina as int).pad_zeros(3)
	magic_bar.value = player.magic
	magic_label.text = "Magic:    " + str(player.magic as int).pad_zeros(3)
