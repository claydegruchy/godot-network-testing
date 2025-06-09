extends Node3D


@onready var menu = $Menu


@onready var sessions_browser: VBoxContainer = %SessionsContainer


func _ready():
	Global.lobby_list_update.connect(update_session_browser)
	Global.peer.peer_connected.connect(func(id): add_player_character(id))
	pass


func _on_host_pressed():
	print("_on_host_pressed")
	Global._create_lobby()
	

func get_sessions():
	print("get_sessions")
	Global.get_lobby_list()


func add_player_character(id = 1):
	print("add_player_character")
	var character = preload("res://player/player.tscn").instantiate()
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
		b.pressed.connect(Global._join_lobby.bind(lobby[1]))
		sessions_browser.add_child(b)
	return
