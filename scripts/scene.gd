extends Node3D

var peer: SteamMultiplayerPeer = SteamMultiplayerPeer.new()

var steam_username: String
var steam_id: int

var lobby_members_max := 4
var lobby_members: Array = []

var lobby_id: int


@onready var menu = $Menu


@onready var sessions_browser: VBoxContainer = %SessionsContainer
@onready var spawner: MultiplayerSpawner = %MultiplayerSpawner
@export var player_scene: PackedScene

func _init():
	print("RUN _init")
	OS.set_environment("SteamAppId", str(480))
	OS.set_environment("SteamGameId", str(480))
	
func _ready():
	print("RUN _ready")
	var initialize_response: Dictionary = Steam.steamInitEx()
	print("Did Steam initialize?: %s " % initialize_response)
	steam_id = Steam.getSteamID()
	steam_username = Steam.getPersonaName()
	print("steam_id:", steam_id)
	print("steam_username:", steam_username)

	print("setting up callbacks...")

func _process(_delta):
	Steam.run_callbacks()

func _on_host_pressed():
	print("_on_host_pressed")
	peer.create_host(

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
