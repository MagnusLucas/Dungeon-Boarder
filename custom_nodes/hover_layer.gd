class_name HoverLayer
extends TileMapLayer

var boards: Array[Board]
var boarder_to_draw: Array[TileBoarder] = []


func _draw() -> void:
	for tile_boarder in boarder_to_draw:
		var offset := map_to_local(tile_boarder.owner)
		draw_line(
			tile_boarder.get_begin(tile_set.tile_size) + offset,
			tile_boarder.get_end(tile_set.tile_size) + offset,
			Color.AQUA, 4
		)


func _on_tile_collider_mouse_entered(coordinates: Vector2i, board_owner: Board) -> void:
	set_cell(coordinates, 0, board_owner.tile_coordinates)


func _on_tile_collider_mouse_exited(coordinates: Vector2i) -> void:
	erase_cell(coordinates)


func _on_board_collider_mouse_entered(board: Board) -> void:
	boarder_to_draw = board.get_boarder()
	queue_redraw()


func _on_board_collider_mouse_exited() -> void:
	boarder_to_draw = []
	queue_redraw()


func set_boards(new_boards: Array[Board]) -> void:
	boards = new_boards
	
	for board in boards:
		var board_collider := BoardCollider.new(board, self)
		add_child(board_collider)
		board_collider.mouse_entered.connect(_on_board_collider_mouse_entered.bind(board))
		board_collider.mouse_exited.connect(_on_board_collider_mouse_exited)
		
		for tile in board.tiles:
			var collider := HexCollider.new(tile_set.tile_size)
			add_child(collider)
			collider.position = map_to_local(tile)
			collider.mouse_entered.connect(_on_tile_collider_mouse_entered.bind(tile, board))
			collider.mouse_exited.connect(_on_tile_collider_mouse_exited.bind(tile))
