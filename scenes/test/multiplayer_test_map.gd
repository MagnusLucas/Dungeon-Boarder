extends Node2D

@onready var host_button = $VBoxContainer/HBoxContainer/Host
@onready var join_button = $VBoxContainer/HBoxContainer/Join
@onready var test_message_button = $VBoxContainer/HBoxContainer/TestMessage
@onready var start_game_button = $VBoxContainer/StartGame
@onready var player_list = $ItemList
@onready var line_edit = $VBoxContainer/LineEdit2

func _ready():
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	test_message_button.pressed.connect(_on_test_message_pressed)
	start_game_button.pressed.connect(_on_start_game_pressed)
	
	NetworkManager.PlayerConnected.connect(_on_player_connected)
	NetworkManager.PlayerDisconnected.connect(_on_player_disconnected)

func _on_host_pressed():
	NetworkManager.CreateGame()

func _on_join_pressed():
	var ip_address = line_edit.text
	if ip_address == "":
		ip_address = "127.0.0.1"
	NetworkManager.JoinGame(ip_address)

func _on_test_message_pressed():
	NetworkManager.BroadcastTestMessage("Everything goes wrong")
	
func _on_start_game_pressed():
	NetworkManager.StartGame("res://scenes/map/map.tscn")

func _on_player_connected(_peer_id, _player_info):
	_refresh_player_list()

func _on_player_disconnected(_peer_id):
	_refresh_player_list()

func _refresh_player_list():
	player_list.clear()
	var players = NetworkManager.PlayerList.GetAll()
	var ids = players.keys()
	ids.sort()
	for id in ids:
		player_list.add_item(players[id]["Name"] + " (" + str(id) + ")")
