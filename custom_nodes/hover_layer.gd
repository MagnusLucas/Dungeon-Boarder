class_name HoverLayer
extends TileMapLayer

var boards: Array[Board]


func set_boards(new_boards: Array[Board]) -> void:
	boards = new_boards
	
	for board in boards:
		for tile in board.tiles:
			var collider := HexCollider.new(tile_set.tile_size)
			add_child(collider)
			collider.position = map_to_local(tile)
