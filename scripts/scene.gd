extends Node3D

# var multiplayer_peer = ENetMultiplayerPeer.new()
# var peer = SteamMultiplayerPeer.new()


@onready var menu = $Menu


func _ready():
	pass

func _on_host_pressed():
	print("_on_host_pressed")
	Global._create_lobby()

	# multiplayerr
	# multiplayer_peer.create_server(port)
	# multiplayer.multiplayer_peer = multiplayer_peer
	# multiplayer_peer.peer_connected.connect(func(id): add_player_character(id))
	# menu.visible = false
	# add_player_character()
	

func _on_join_pressed():
	print("_on_join_pressed")
	# Global._join_lobby()
	# peer.create_client(
	# multiplayer_peer.create_client("localhost", port)
	# multiplayer.multiplayer_peer = multiplayer_peer
	# menu.visible = false


func add_player_character(id = 1):
	print("add_player_character")
	# var character = preload("res://player/player.tscn").instantiate()
	# character.name = str(id)
	# add_child(character)
