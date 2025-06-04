extends Node3D

var multiplayer_peer = ENetMultiplayerPeer.new()

@onready var menu = $Menu
var port = 1234


func _on_join_pressed():
	print("_on_join_pressed")
	multiplayer_peer.create_client("localhost", port)
	multiplayer.multiplayer_peer = multiplayer_peer
	menu.visible = false


func _on_host_pressed():
	print("_on_host_pressed")
	multiplayer_peer.create_server(port)
	multiplayer.multiplayer_peer = multiplayer_peer
	multiplayer_peer.peer_connected.connect(func(id): add_player_character(id))
	menu.visible = false
	add_player_character()


func add_player_character(id = 1):
	print("add_player_character")
	var character = preload("res://player/player.tscn").instantiate()
	character.name = str(id)
	add_child(character)


func _on_host_button_down() -> void:
	pass # Replace with function body.

func _on_join_button_down() -> void:
	pass # Replace with function body.
