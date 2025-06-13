extends Node

# the purposes of this script is to handle the setup of networking for the rest of the game
# this doesnt deal with socket conenctions, it simply sets the stage for the 'multiplayer' builtin
# this lets us use normal multiplayer spawners and syncers instead of dealing with packet sending

# it does this using the steam lobby system, where a lobby is created, then that lobby is joined and used as
# the socket connection with steam sitting as the match maker


# Max number of players.
const MAX_PEERS: int = 12

var peer: SteamMultiplayerPeer = null

# Name for my player.
signal name_update(new_name)
var player_name: String = "Nameless":
	set(n):
		player_name = n
		name_update.emit(n)


# Names for remote players in id:name format.
var players = {}

var lobby_id := -1
var host_id := -1
var steam_id := -1


# Signals to let lobby GUI know what's going on.
signal player_list_changed(added: int, removed: int)
signal player_joined(id)
signal player_left(id)
signal connection_failed()
signal connection_succeeded()
signal socket_update_succeeded()
signal socket_update_failed(what)
signal game_error(what)


var network_active := false

func _process(_delta):
	Steam.run_callbacks()


# Callback from SceneTree.
func _player_connected(id):
	print("_player_connected")
	# Registration of a client beings here, tell the connected player that we are here.
	register_player.rpc_id(id, player_name)


# Callback from SceneTree.
func _player_disconnected(id):
	print("_player_disconnected")
	if network_active: # Game is in progress.
		if multiplayer.is_server(): # If we are the host
			game_error.emit("Player " + players[id] + " disconnected")
			
			end_game()
	else: # Game is not in progress.
		# Unregister this player.
		unregister_player(id)


# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	print("_connected_ok")
	# We just connected to a server
	connection_succeeded.emit()


# Callback from SceneTree, only for clients (not server).
func _server_disconnected():
	print("_server_disconnected")
	game_error.emit("Server disconnected")
	end_game()


# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	print("_connected_fail")
	multiplayer.set_network_peer(null) # Remove peer
	connection_failed.emit()


# Lobby management functions.
@rpc("any_peer")
func register_player(new_player_name):
	print("register_player")
	var id = multiplayer.get_remote_sender_id()
	players[id] = new_player_name
	player_joined.emit(id)

	
func unregister_player(id):
	print("unregister_player")
	players.erase(id)
	player_left.emit(id)


func create_lobby():
	print("create_lobby")
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, MAX_PEERS)


func join_lobby(lobby_id):
	print("join_lobby", lobby_id)
	Steam.joinLobby(int(lobby_id))


func get_player_list():
	print("get_player_list")
	return players.values()


func begin_game():
	print("begin_game")
	# assert(multiplayer.is_server())
	# load_world.rpc()

	# var world = get_tree().get_root().get_node("World")
	var player_scene = load("res://player/player.tscn")

	# # Create a dictionary with peer id and respective spawn points, could be improved by randomizing.
	# var spawn_points = {}
	# spawn_points[1] = 0 # Server in spawn point 0.
	# var spawn_point_idx = 1
	# for p in players:
	# 	spawn_points[p] = spawn_point_idx
	# 	spawn_point_idx += 1

	# for p_id in spawn_points:
	# 	var spawn_pos = world.get_node("SpawnPoints/" + str(spawn_points[p_id])).position
	# 	var player = player_scene.instantiate()
	# 	player.synced_position = spawn_pos
	# 	player.name = str(p_id)
	# 	player.set_player_name(player_name if p_id == multiplayer.get_unique_id() else players[p_id])
	# 	world.get_node("Players").add_child(player)


# @rpc("call_local")
# func load_world():
# 	print("load_world")
# 	# Change scene.
# 	var world = load("res://world.tscn").instantiate()
# 	get_tree().get_root().add_child(world)
# 	get_tree().get_root().get_node("Lobby").hide()

# 	# Set up score.
# 	world.get_node("Score").add_player(multiplayer.get_unique_id(), player_name)
# 	for pn in players:
# 		world.get_node("Score").add_player(pn, players[pn])
# 	get_tree().set_pause(false) # Unpause and unleash the game!

func end_game():
	print("end_game")
	players.clear()
	network_active = false


func _init():
	print("_init")
	OS.set_environment("SteamAppId", str(480))
	OS.set_environment("SteamGameId", str(480))

func _ready():
	print("_ready")
	var initialize_response: Dictionary = Steam.steamInitEx()
	print("Did Steam initialize?: %s " % initialize_response)
	
	print("Connecting siganls")
	multiplayer.peer_connected.connect(self._player_connected)
	multiplayer.peer_disconnected.connect(self._player_disconnected)
	multiplayer.connected_to_server.connect(self._connected_ok)
	multiplayer.connection_failed.connect(self._connected_fail)
	multiplayer.server_disconnected.connect(self._server_disconnected)
	
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_match_list.connect(_lobby_match_list)

	print("Waiting for name...")
	await get_tree().process_frame # delay this call to the next frame as its async
	var steam_username = Steam.getPersonaName()
	if steam_username:
		player_name = steam_username
		print("Set name to " + player_name)
	steam_id = Steam.getSteamID()
	

func _on_lobby_created(_connect: int, _lobby_id: int):
	print_debug("_on_lobby_created", _connect)
	if _connect == 1:
		print("Create lobby id:", str(lobby_id))
		lobby_id = _lobby_id
		Steam.setLobbyData(_lobby_id, "name", "test_server")
		create_socket()
	
	else:
		print("Error on create lobby!")


func _on_lobby_joined(lobby: int, _permissions: int, _locked: bool, response: int):
	print("_on_lobby_joined")

	if response == 1:
		var id = Steam.getLobbyOwner(lobby)
		if id != steam_id:
			connect_socket(id)
	else:
		# Get the failure reason
		var FAIL_REASON: String
		match response:
			2: FAIL_REASON = "This lobby no longer exists."
			3: FAIL_REASON = "You don't have permission to join this lobby."
			4: FAIL_REASON = "The lobby is now full."
			5: FAIL_REASON = "Uh... something unexpected happened!"
			6: FAIL_REASON = "You are banned from this lobby."
			7: FAIL_REASON = "You cannot join due to having a limited account."
			8: FAIL_REASON = "This lobby is locked or disabled."
			9: FAIL_REASON = "This lobby is community locked."
			10: FAIL_REASON = "A user in the lobby has blocked you from joining."
			11: FAIL_REASON = "A user you have blocked is in the lobby."
		print(FAIL_REASON)


signal lobby_list_update(list: Array)
func get_lobby_list():
	print("get_lobby_list")
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()

func _lobby_match_list(lobbies):
	print("_lobby_match_list")
	Logger.log(lobbies)
	var t = []
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby, "name")
		if lobby_name.length() < 1:
			continue
		var member_count = Steam.getNumLobbyMembers(lobby)
		t.append([lobby_name, lobby, member_count])
	lobby_list_update.emit(t)


func create_socket():
	print("create_socket")
	peer = SteamMultiplayerPeer.new()
	# Example of peer config
	#peer.set_config(SteamPeerConfig.NETWORKING_CONFIG_SEND_BUFFER_SIZE, 524288)
	var error = peer.create_host(0)
	if error == OK:
		multiplayer.set_multiplayer_peer(peer)
		socket_update_succeeded.emit()
		# register ourselves
		var uid = multiplayer.get_unique_id()
		network_active = true
		
		players[uid] = player_name
		player_joined.emit(uid)

	else:
		socket_update_failed.emit(error)


func connect_socket(steam_id: int):
	print("connect_socket")
	peer = SteamMultiplayerPeer.new()
	# Example of peer config
	# peer.set_config(SteamPeerConfig.NETWORKING_CONFIG_SEND_BUFFER_SIZE, 524288)
	var error = peer.create_client(steam_id, 0)
	if error == OK:
		multiplayer.set_multiplayer_peer(peer)
		network_active = true
		socket_update_succeeded.emit()
	else:
		socket_update_failed.emit(error)
