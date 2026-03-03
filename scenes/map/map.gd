class_name Map
extends Node

@export var map_data: MapData

@onready var tile_layer: TileMapLayer = $TileLayer
@onready var hover_layer: HoverLayer = $HoverLayer


func _ready() -> void:
	var boards := map_data.boards
	hover_layer.set_boards(boards)
	for board_coords in boards:
		var board := boards[board_coords]
		for tile in board.get_tiles():
			tile_layer.set_cell(tile + board_coords, 0, board.tile_coordinates)


func get_shape() -> HexShape:
	return map_data.get_joined_shape()
