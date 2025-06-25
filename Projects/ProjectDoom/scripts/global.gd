extends Node

var player: Node = null
var player_name: String = "null"
var player_interface: CanvasLayer = null
var viewport: SubViewportContainer = null

func set_player(player_node: Node):
	player = player_node

func set_player_interface(current_ui: Node):
	player_interface = current_ui

func set_viewport(current_viewport: SubViewportContainer):
	viewport = current_viewport
