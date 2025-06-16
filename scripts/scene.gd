extends Node3D


@export var player_scene: PackedScene
@export var map_scene: PackedScene
@onready var sessions_browser: VBoxContainer = %SessionsContainer
@onready var log_container: VBoxContainer = %LogContainer
@onready var lobby_status_display: Label = %LobbyStatus

@onready var player_container: Node3D = %PlayerContainer


func _ready():
	Network.lobby_list_update.connect(update_session_browser)
	Network.player_joined.connect(on_player_join)
	Network.player_left.connect(on_player_leave)
	Logger.initate_logger(log_container)
	pass

func _on_host_pressed():
	Network.create_lobby()


func on_player_join(id):
	print("player added:", id)
	if (multiplayer.is_server()): # other players will get the update via the multiplayerspawner
		add_player_character(id)

func on_player_leave(id):
	print("player leave:", id)

func add_player_character(id: int = 1):
	print("add_player_character", id)
	var character = player_scene.instantiate()
	character.name = str(id)
	player_container.add_child(character)

func remove_player_character(id: int = 1):
	print("remove_player_character", id)


func get_sessions():
	print("get_sessions")
	Network.get_lobby_list()
	lobby_status_display.text = "Searching for sessions..."


func update_session_browser(lobbies: Array):
	print("update_session_browser")
	lobby_status_display.text = "Found sessions"
	print(lobbies)

	var children = sessions_browser.get_children()
	for child in children:
		child.free()

	for lobby in lobbies:
		var b = Button.new()
		b.text = lobby[0] + " - (" + str(lobby[2]) + ")"
		b.pressed.connect(Network.join_lobby.bind(lobby[1]))
		b.pressed.connect(func(): print(lobby))
		sessions_browser.add_child(b)
	return
