class_name HoverLayer
extends TileMapLayer

var boards: Array[Board]


func _on_tile_collider_mouse_entered(coordinates: Vector2i, board_owner: Board) -> void:
	set_cell(coordinates, 0, board_owner.tile_coordinates)


func _on_tile_collider_mouse_exited(coordinates: Vector2i) -> void:
	erase_cell(coordinates)


func _on_board_collider_mouse_entered(collider: HexCollider, board: Board) -> void:
	var boarder_drawer := BoarderDrawer.new(board.shape, tile_set.tile_size)
	add_child(boarder_drawer)
	collider.mouse_exited.connect(boarder_drawer.queue_free)


func _on_board_collider_mouse_exited() -> void:
	pass


func set_boards(new_boards: Array[Board]) -> void:
	boards = new_boards
	
	for board in boards:
		var board_collider := HexCollider.new(board.shape, tile_set.tile_size)
		add_child(board_collider)
		board_collider.mouse_entered.connect(
			_on_board_collider_mouse_entered.bind(board_collider, board))
		board_collider.mouse_exited.connect(_on_board_collider_mouse_exited)
		
		for tile in board.get_tiles():
			var collider := HexCollider.new(HexShape.new(), tile_set.tile_size)
			add_child(collider)
			collider.position = map_to_local(tile) - Vector2(tile_set.tile_size)/2
			collider.mouse_entered.connect(_on_tile_collider_mouse_entered.bind(tile, board))
			collider.mouse_exited.connect(_on_tile_collider_mouse_exited.bind(tile))
