extends AnimationPlayer

@onready var player = get_parent()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		if player.inventory.visible == false:
				pause()
		elif player.inventory.visible == true:
				play()
	if player.idle:
		play("idle")
	if player.walking:
		play("walking")
	if player.running:
		play("running")
	if player.jumping:
		if player.velocity.x == 0 and player.velocity.z == 0:
			play("jumping")
			seek(0.7)
		elif player.velocity.x != 0 || player.velocity.z != 0:
			play("running_jump")
