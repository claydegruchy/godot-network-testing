extends Node

var peer: SteamMultiplayerPeer = SteamMultiplayerPeer.new()

var steam_username: String
var steam_id: int

var lobby_members_max := 4
var lobby_members: Array = []

var lobby_id: int

var player_name: String


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
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)


	multiplayer.connected_to_server.connect(on_multiplayer_connect)


func on_multiplayer_connect(args):
	print("on_multiplayer_connect")
	print(args)

func _process(_delta):
	Steam.run_callbacks()


func _create_lobby():
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, lobby_members_max)

func _join_lobby(lobby_id: int, new_player_name: String):
	player_name = new_player_name
	Steam.joinLobby(int(lobby_id))
	
func _on_lobby_created(_connect: int, this_lobby_id: int):
	if _connect:
		lobby_id = this_lobby_id
		Steam.setLobbyData(lobby_id, "name", steam_username + "'s lobby")
		Steam.setLobbyJoinable(lobby_id, true)
		create_socket()
		print("Create lobby id:", str(lobby_id))

func _on_lobby_joined(lobby: int, permissions: int, locked: bool, response: int):
	if response == 1:
		var id = Steam.getLobbyOwner(lobby)
		if id != Steam.getSteamID():
			connect_socket(id)


func create_socket():
	# Example of peer config
	#peer.set_config(SteamPeerConfig.NETWORKING_CONFIG_SEND_BUFFER_SIZE, 524288)
	var error = peer.create_host(0)
	if error != OK:
		print("ERROR")
		print(error)
	print(peer)
	multiplayer.multiplayer_peer = peer


func connect_socket(steam_id: int):
	# Example of peer config
	# peer.set_config(SteamPeerConfig.NETWORKING_CONFIG_SEND_BUFFER_SIZE, 524288)
	peer.create_client(steam_id, 0)
	multiplayer.multiplayer_peer = peer
