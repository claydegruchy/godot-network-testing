extends Node3D


@onready var menu = $Menu


@export var player_scene: PackedScene
@export var map_scene: PackedScene
@onready var sessions_browser: VBoxContainer = %SessionsContainer

func _ready():
	pass

func _on_host_pressed():
	return
func _on_join_pressed(lobby_id, player_id):
	return
func get_sessions():
	print("get_sessions")
	Global.get_lobby_list()


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
	print(lobbies)

	var children = sessions_browser.get_children()
	for child in children:
		child.free()

	for lobby in lobbies:
		var b = Button.new()
		b.text = lobby[0]
		sessions_browser.add_child(b)
	return
