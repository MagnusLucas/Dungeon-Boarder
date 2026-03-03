class_name HoverLayer
extends TileMapLayer

var boards: Dictionary[Vector2i, Board]


func _on_tile_collider_mouse_entered(coordinates: Vector2i, board_owner: Board) -> void:
	set_cell(coordinates, 0, board_owner.tile_coordinates)


func _on_tile_collider_mouse_exited(coordinates: Vector2i) -> void:
	erase_cell(coordinates)


func _on_board_collider_mouse_entered(collider: HexCollider, board: Board) -> void:
	var boarder_drawer := BoarderDrawer.new(board.shape, tile_set.tile_size)
	add_child(boarder_drawer)
	var offset := - Vector2(tile_set.tile_size) / 2
	boarder_drawer.position = map_to_local(boards.find_key(board)) + offset
	collider.mouse_exited.connect(boarder_drawer.queue_free)


func _set_tile(tile_coordinates: Vector2i, owner_board: Board) -> void:
	var collider := HexCollider.new(
		HexShape.new(), tile_set.tile_size, map_to_local(tile_coordinates))
	add_child(collider)
	collider.mouse_entered.connect(_on_tile_collider_mouse_entered.bind(tile_coordinates, owner_board))
	collider.mouse_exited.connect(_on_tile_collider_mouse_exited.bind(tile_coordinates))


func _set_board(board_coordinates: Vector2i) -> void:
	var board := boards[board_coordinates]
	var board_collider := HexCollider.new(
			board.shape, tile_set.tile_size, map_to_local(board_coordinates))
	add_child(board_collider)
	board_collider.mouse_entered.connect(
		_on_board_collider_mouse_entered.bind(board_collider, board))
	
	for board_tile_coords in board.get_tiles():
		var tile_coords := board_coordinates + board_tile_coords
		_set_tile(tile_coords, board)


func set_boards(new_boards: Dictionary[Vector2i, Board]) -> void:
	boards = new_boards
	
	for board_coords in boards:
		_set_board(board_coords)
