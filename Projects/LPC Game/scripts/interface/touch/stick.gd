extends Sprite2D

#source: https://johnnysdabblings.code.blog/2020/01/22/how-to-make-a-touch-joystick-in-godot/

var radiusJoyStick 
var radiusJoyBase 
var maxLength
var touchInsideJoystick = false

signal joystick_moved
signal joystick_released

func _ready():
	radiusJoyStick = global_scale.x * texture.get_size().x/2;
	radiusJoyBase = get_node("../Base").global_scale.x * $"../Base".texture.get_size().x/2
	maxLength = radiusJoyBase - radiusJoyStick

func _input(event):
	if event is InputEventScreenDrag:
		if touchInsideJoystick == true:
			position.x = position.x + event.relative.x
			position.y = position.y + event.relative.y
			if position.length() > maxLength:
				var angle = position.angle()
				position.x = cos(angle) * maxLength
				position.y = sin(angle) * maxLength
			emit_signal("joystick_moved", position)
	if event is InputEventScreenTouch:
		if !event.pressed:
			position.x = 0
			position.y = 0
			emit_signal("joystick_released")
		if event.pressed:
			touchInsideJoystick = (event.position - global_position).length() <= radiusJoyStick
