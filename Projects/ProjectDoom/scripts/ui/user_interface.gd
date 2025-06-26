extends CanvasLayer

@onready var test_labels: MarginContainer = $TestLabels
@onready var test_label_1: Label = $TestLabels/VBoxContainer/Panel1/TestLabel1
@onready var test_label_2: Label = $TestLabels/VBoxContainer/Panel2/TestLabel2
@onready var test_label_3: Label = $TestLabels/VBoxContainer/Panel3/TestLabel3
@onready var test_label_4: Label = $TestLabels/VBoxContainer/Panel4/TestLabel4

@onready var health_bar: TextureProgressBar = $StatsBars/VBoxContainer/Panel1/HealthBar
@onready var stamina_bar: TextureProgressBar = $StatsBars/VBoxContainer/Panel2/StaminaBar
@onready var magic_bar: TextureProgressBar = $StatsBars/VBoxContainer/Panel3/MagicBar

@onready var inventory_ui: MarginContainer = $InventoryUI

var player: Player = null

var stamina_tween: float
var s_tween: Tween
#var magic_tween: float
#var m_tween: Tween

func _ready() -> void:
	Global.set_player_interface(self)
	player = Global.player

func _process(_delta: float) -> void:
	check_stats_bars()
	if test_labels.visible == true:
		#print("checking debug")
		check_test_labels()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("show_inventory"):
			inventory_ui.visible = !inventory_ui.visible
			inventory_ui.usage_grid.visible = false
			if inventory_ui.visible == true:
				Inventory.inventory_updated.emit()
		if Input.is_action_just_pressed("show_debug"):
			test_labels.visible = !test_labels.visible

func check_test_labels() -> void:
	test_label_1.text = str(" 	 Stats: HP: " + str(player.health).pad_decimals(0) + " | SP: ") + str(player.stamina).pad_decimals(0) + " | MP: " + str(player.magic).pad_decimals(0)
	test_label_2.text = str(" 	 Last Pos:  " + str(player.position_last.x).pad_decimals(1).pad_zeros(4) + " , " + str(player.position_last.y).pad_decimals(1).pad_zeros(4) + " | Last Dir:  " + str(player.direction_last.x).pad_decimals(1) + " , " + str(player.direction_last.y).pad_decimals(1))
	test_label_3.text = str(" 	 Speed: " + str(player.speed) + " | State: " + str(player.hsm.get_active_state().name) + " | Stamina Cooldown: " + str(player.stamina_cooldown).capitalize())
	test_label_4.text = 	" 	 Nothing to display"

func check_stats_bars() -> void:
	#health_bar.value = player.health
	if player.stamina < player.stamina_max:
		#print("checking stamina bars")
		stamina_tween = player.stamina
		s_tween = create_tween()
		s_tween.tween_property(stamina_bar, "value", stamina_tween, 0.1)
	#magic_tween = player.magic
	#m_tween = create_tween()
	#m_tween.tween_property(magic_bar, "value", magic_tween, 0.1)
