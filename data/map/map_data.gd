class_name MapData
extends Resource

@export var boards: Dictionary[Vector2i, Board]


func get_joined_shape() -> HexShape:
	var hex_coords: Array[Vector2i]
	for board_coords in boards:
		var board := boards[board_coords]
		var local_coords := board.get_tiles()
		for tile_coords in local_coords:
			hex_coords.append(tile_coords + board_coords)
	return HexShape.new(hex_coords)
