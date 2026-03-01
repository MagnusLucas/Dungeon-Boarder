class_name HoverLayer
extends TileMapLayer

var boards: Array[Board]
@onready var board_highlighter: BoardHighlighter = $BoardHighlighter


func set_boards(new_boards: Array[Board]) -> void:
	boards = new_boards
	
	for board in boards:
		for tile in board.tiles:
			var collider := HexCollider.new(tile_set.tile_size)
			add_child(collider)
			collider.position = map_to_local(tile)
			collider.mouse_entered.connect(_on_collider_mouse_entered.bind(tile, board))
			collider.mouse_exited.connect(_on_collider_mouse_exited.bind(tile))


func _on_collider_mouse_entered(coordinates: Vector2i, board_owner: Board) -> void:
	set_cell(coordinates, 0, board_owner.tile_coordinates)
	board_highlighter.start_drawing_boundries(board_owner, self)


func _on_collider_mouse_exited(coordinates: Vector2i) -> void:
	erase_cell(coordinates)
	board_highlighter.end_drawing_boundries()
