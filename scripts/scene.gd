extends Node3D


@onready var menu = $Menu


@export var player_scene: PackedScene
@export var map_scene: PackedScene
@onready var sessions_browser: VBoxContainer = %SessionsContainer
@onready var lobby_status_display: Label = %LobbyStatus


func _ready():
	Global.lobby_list_update.connect(update_session_browser)
	Logging.initate_logger(log_container)
	Logging.log("lmao")
	pass

func _on_host_pressed():
	Global.host_game()

func get_sessions():
	print("get_sessions")
	Global.get_lobby_list()
	lobby_status_display.text = "Searching for sessions..."

func start_game():
	return
	
func end_game():
	return


# func add_player_character(id = 1):
# 	print("add_player_character")
# 	# spawner.spawn("res://player/player.tscn")
# 	# character.name = str(id)
# 	# add_child(character)
# 	var character = player_scene.instantiate()
# 	character.name = str(id)
# 	add_child(character)


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
		sessions_browser.add_child(b)
	return
