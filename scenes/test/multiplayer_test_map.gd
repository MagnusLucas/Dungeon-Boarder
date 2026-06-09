extends Node2D

@onready var host_button = $VBoxContainer/HBoxContainer/Host
@onready var join_button = $VBoxContainer/HBoxContainer/Join
@onready var invite_button = $VBoxContainer/HBoxContainer/Invite
@onready var test_message_button = $VBoxContainer3/TestMessage
@onready var start_game_button = $VBoxContainer3/StartGame
@onready var line_edit = $VBoxContainer/LineEdit2
@onready var player_list = $PlayerListPanel/VBoxContainer/PlayerEntryContainer
@onready var switch_backend_button = $SwitchBackend

const PlayerEntry = preload("res://scenes/test/player_entry.tscn")

func _ready():
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	invite_button.pressed.connect(func(): NetworkManager.OpenInviteOverlay())
		
	test_message_button.pressed.connect(_on_test_message_pressed)
	start_game_button.pressed.connect(_on_start_game_pressed)
	
	NetworkManager.PlayerConnected.connect(_on_player_connected)
	NetworkManager.PlayerDisconnected.connect(_on_player_disconnected)
	
	switch_backend_button.pressed.connect(_on_switch_network_type)
	NetworkManager.SwitchBackend(0)
	_update_ui()
	NetworkManager.ServerDisconnected.connect(_on_server_disconnected)
	NetworkManager.AvatarLoaded.connect(_on_avatar_loaded)

func _on_host_pressed():
	NetworkManager.CreateGame()

func _on_join_pressed():
	if NetworkManager.CurrentBackend == 1:
		NetworkManager.JoinGame(line_edit.text)
	else:
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
	
	for child in player_list.get_children():
		child.queue_free()
	
	if not multiplayer.has_multiplayer_peer():
		get_node("PlayerListPanel").update_count(0)
		return
	
	var players = NetworkManager.PlayerList.GetAll()
	var ids = players.keys()
	ids.sort()
	
	get_node("PlayerListPanel").update_count(players.size())
	
	for id in ids:
		var entry = PlayerEntry.instantiate()
		
		if NetworkManager.CurrentBackend == 1:
			var steam_id = int(players[id]["SteamId"])
			var texture = NetworkManager.PlayerList.GetSteamAvatar(steam_id)
			if texture:
				entry.get_node("PlayerIcon").texture = texture
		
		entry.get_node("PlayerName").text = players[id]["Name"]
		
		var kick_button = entry.get_node("MarginContainer/KickButton")
		if multiplayer.is_server() and id != multiplayer.get_unique_id():
			kick_button.pressed.connect(_on_kick_pressed.bind(id))
		else:
			kick_button.hide()
		
		player_list.add_child(entry)
		
func _on_kick_pressed(peer_id):
	NetworkManager.KickPlayer(peer_id)
	
func _on_switch_network_type():
	if NetworkManager.CurrentBackend == 0:
		NetworkManager.SwitchBackend(1)
	else:
		NetworkManager.SwitchBackend(0)
	_update_ui()

func _update_ui():
	var is_steam = NetworkManager.CurrentBackend == 1
	line_edit.visible = !is_steam
	invite_button.visible = is_steam
	join_button.visible = !is_steam
	switch_backend_button.text = "Switch to Steam" if !is_steam else "Switch to ENet"
	_refresh_player_list()
	
func _on_server_disconnected():
	print("server disconnected fired, peer: ", multiplayer.has_multiplayer_peer())
	_refresh_player_list()
	
func _on_avatar_loaded(_steam_id):
	_refresh_player_list()
