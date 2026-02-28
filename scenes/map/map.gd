class_name Map
extends Node

@export var player_boards: Array[Board]
@export var enemy_board: Board

@onready var tile_layer: TileMapLayer = $TileLayer


func _ready() -> void:
	var boards := player_boards
	boards.append(enemy_board)
	for board in boards:
		for tile in board.tiles:
			tile_layer.set_cell(tile, 0, board.tile_coordinates)
