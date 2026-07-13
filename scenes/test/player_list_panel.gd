extends Node
@onready var player_count = $VBoxContainer/HBoxContainer/PlayerCount

func update_count(current: int):
	player_count.text = str(current) + " / 3"
