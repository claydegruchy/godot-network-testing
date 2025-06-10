extends Node

var peer: SteamMultiplayerPeer = SteamMultiplayerPeer.new()

var steam_username: String
var steam_id: int

var lobby_members_max := 4
var lobby_members: Array = []

var lobby_id: int


signal connection_state(state)
signal lobby_list_update(lobbies)
signal lobby_joined(player_id: int)


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
	Steam.lobby_match_list.connect(_lobby_match_list)


	multiplayer.connected_to_server.connect(on_multiplayer_connect)


func on_multiplayer_connect(args):
	print("on_multiplayer_connect")
	print(args)

func _process(_delta):
	Steam.run_callbacks()


func _create_lobby():
	print("_create_lobby")
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, lobby_members_max)

func _join_lobby(lobby_id: int, ):
	print("_join_lobby")
	Steam.joinLobby(int(lobby_id))
	
func _on_lobby_created(_connect: int, this_lobby_id: int):
	print("_on_lobby_created")
	if _connect:
		lobby_id = this_lobby_id
		Steam.setLobbyData(lobby_id, "name", steam_username + "'s lobby")
		Steam.setLobbyJoinable(lobby_id, true)
		create_multiplayer_socket()
		print("Create lobby id:", str(lobby_id))


func _on_lobby_joined(lobby: int, _permissions: int, _locked: bool, response: int):
	print("_on_lobby_joined", response)
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		var id = Steam.getLobbyOwner(lobby)
		# if id != Steam.getSteamID():
		connect_multiplayer_socket(id)
		lobby_id = id
		lobby_joined.emit(steam_id)
	else:
		# Get the failure reason
		var fail_reason: String

		match response:
				Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST: fail_reason = "This lobby no longer exists."
				Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED: fail_reason = "You don't have permission to join this lobby."
				Steam.CHAT_ROOM_ENTER_RESPONSE_FULL: fail_reason = "The lobby is now full."
				Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR: fail_reason = "Uh... something unexpected happened!"
				Steam.CHAT_ROOM_ENTER_RESPONSE_BANNED: fail_reason = "You are banned from this lobby."
				Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED: fail_reason = "You cannot join due to having a limited account."
				Steam.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED: fail_reason = "This lobby is locked or disabled."
				Steam.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN: fail_reason = "This lobby is community locked."
				Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU: fail_reason = "A user in the lobby has blocked you from joining."
				Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER: fail_reason = "A user you have blocked is in the lobby."

		print("Failed to join this chat room: %s" % fail_reason)


func create_multiplayer_socket():
	print("create_multiplayer_socket")
	# Example of peer config
	#peer.set_config(SteamPeerConfig.NETWORKING_CONFIG_SEND_BUFFER_SIZE, 524288)
	var error = peer.create_host(0)
	if error != OK:
		print("ERROR")
		print(error)
	multiplayer.multiplayer_peer = peer


func connect_multiplayer_socket(steam_id: int):
	print("connect_multiplayer_socket")
	# Example of peer config
	# peer.set_config(SteamPeerConfig.NETWORKING_CONFIG_SEND_BUFFER_SIZE, 524288)
	peer.create_client(steam_id, 0)
	multiplayer.multiplayer_peer = peer


func get_lobby_list():
	print("get_lobby_list")
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_CLOSE)
	Steam.requestLobbyList()

func _lobby_match_list(lobbies):
	print("_lobby_match_list")
	var t = []
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby, "name")
		if lobby_name.length() < 1:
			continue
		var member_count = Steam.getNumLobbyMembers(lobby)
		t.append([lobby_name, member_count])
	lobby_list_update.emit(t)
