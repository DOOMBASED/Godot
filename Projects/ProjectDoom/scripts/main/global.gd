extends Node

var viewport: SubViewportContainer = null
var player: Player = null
var player_interface: CanvasLayer = null
var player_inventory: InventoryNode

var player_name: String = "null"

func set_viewport(current_viewport: SubViewportContainer):
	viewport = current_viewport

func set_player(player_node: Player):
	player = player_node

func set_player_interface(current_ui: Node):
	player_interface = current_ui

func set_player_inventory(current_inventory: InventoryNode):
	player_inventory = current_inventory
