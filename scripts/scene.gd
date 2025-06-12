extends Node3D


@export var player_scene: PackedScene
@export var map_scene: PackedScene
@onready var sessions_browser: VBoxContainer = %SessionsContainer
@onready var log_container: VBoxContainer = %LogContainer
@onready var lobby_status_display: Label = %LobbyStatus


func _ready():
	Global.lobby_list_update.connect(update_session_browser)
	Global.socket_update_succeeded.connect(_on_join_game)
	Logging.initate_logger(log_container)
	Logging.log("lmao")
	pass

func _on_host_pressed():
	Global.host_game()


func _on_join_game():
	add_player_character(multiplayer.get_unique_id())
	print(Global.steam_id)
	print(multiplayer.get_unique_id())
	print(multiplayer.get_remote_sender_id())
	if multiplayer.is_server():
		print("server")
	else:
		print("client")
	return

func get_sessions():
	print("get_sessions")
	Global.get_lobby_list()
	lobby_status_display.text = "Searching for sessions..."


func spawn():
	add_player_character(Global.steam_id)
	return

func add_player_character(id: int = 1):
	print("add_player_character", id)
	print(Global.players)
	var character = player_scene.instantiate()
	character.name = str(id)
	add_child(character)


func update_session_browser(lobbies: Array):
	print("update_session_browser")
	lobby_status_display.text = "Found sessions"
	print(lobbies)

	var children = sessions_browser.get_children()
	for child in children:
		child.free()

	for lobby in lobbies:
		var b = Button.new()
		b.text = lobby[0]
		b.pressed.connect(Global.join_lobby.bind(lobby[1]))
		sessions_browser.add_child(b)
	return
