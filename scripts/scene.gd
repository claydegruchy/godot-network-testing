extends Node3D


@onready var menu = $Menu


@onready var sessions_browser: VBoxContainer = %SessionsContainer
@onready var spawner: MultiplayerSpawner = %MultiplayerSpawner
@export var player_scene: PackedScene


func _ready():
	Global.lobby_list_update.connect(update_session_browser)
	Global.peer.peer_connected.connect(func(id): add_player_character(id))
	Global.lobby_joined.connect(add_player_character)


	pass


func _on_host_pressed():
	print("_on_host_pressed")
	Global._create_lobby()
	add_player_character()

func _on_join_pressed(lobby_id, player_id):
	print(lobby_id, "-", player_id)
	Global._join_lobby(lobby_id)


func get_sessions():
	print("get_sessions")
	Global.get_lobby_list()


func add_player_character(id = 1):
	print("add_player_character")
	# spawner.spawn("res://player/player.tscn")
	# character.name = str(id)
	# add_child(character)
	var character = player_scene.instantiate()
	character.name = str(id)
	add_child(character)


func update_session_browser(lobbies: Array):
	print("update_session_browser")
	print(lobbies)

	var children = sessions_browser.get_children()
	for child in children:
		child.free()

	for lobby in lobbies:
		var b = Button.new()
		b.text = lobby[0]
		b.pressed.connect(_on_join_pressed.bind(lobby[1], Global.steam_id))
		sessions_browser.add_child(b)
	return
