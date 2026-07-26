class_name HoverLayer
extends TileMapLayer

var boards: Dictionary[Vector2i, Board]
var tile_owners: Dictionary[HexCollider, Board]
var board_tile_coordinates: Dictionary[HexCollider, Vector2i]


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


func _on_tile_collider_hex_collider_entered(hex_collider: HexCollider,
		tile_collider: HexCollider, board: Board) -> void:
	var parent = hex_collider.get_parent()
	
	if not parent is Character:
		return
	
	# start drawing where the character would get placed on the map
	
	var overlapping_areas: Array[Area2D] = hex_collider.get_overlapping_areas()
	var overlapping_tiles: Array[HexCollider] = []
	for area: Area2D in overlapping_areas:
		if area is HexCollider:
			var hex_area := area as HexCollider
			if tile_owners.has(hex_area):
				if tile_owners[hex_area] == board:
					overlapping_tiles.append(hex_area)
	
	for hex_area: HexCollider in overlapping_tiles:
		if hex_collider.shape.fits_in(board.shape, board_tile_coordinates[hex_area]):
			var boarder_drawer := BoarderDrawer.new(hex_collider.shape, tile_set.tile_size)
			add_child(boarder_drawer)
			boarder_drawer.position = hex_area.position
	
			tile_collider.area_exited.connect(
				func(area: Area2D) -> void:
					if area == hex_collider:
						boarder_drawer.queue_free(),
				CONNECT_ONE_SHOT
			)


func _set_tile(board_coords: Vector2i, tile_coordinates: Vector2i, owner_board: Board) -> void:
	var global_coordinates := board_coords + tile_coordinates
	var collider := HexCollider.new(
		HexShape.new(), tile_set.tile_size, map_to_local(global_coordinates))
	add_child(collider)
	
	collider.collision_layer = 1 # is board
	collider.collision_mask = 2 # sees characters
	
	tile_owners[collider] = owner_board
	board_tile_coordinates[collider] = tile_coordinates
	
	collider.mouse_entered.connect(_on_tile_collider_mouse_entered.bind(global_coordinates, owner_board))
	collider.mouse_exited.connect(_on_tile_collider_mouse_exited.bind(global_coordinates))
	collider.area_entered.connect(
		_on_tile_collider_hex_collider_entered.bind(collider, owner_board)
	)


func _set_board(board_coordinates: Vector2i) -> void:
	var board := boards[board_coordinates]
	var board_collider := HexCollider.new(
			board.shape, tile_set.tile_size, map_to_local(board_coordinates))
	add_child(board_collider)
	board_collider.collision_layer = 1 # is board
	board_collider.collision_mask = 2 # sees characters
	#board_collider.mouse_entered.connect(
		#_on_board_collider_mouse_entered.bind(board_collider, board))
	
	for board_tile_coords in board.get_tiles():
		_set_tile(board_coordinates, board_tile_coords, board)


func set_boards(new_boards: Dictionary[Vector2i, Board]) -> void:
	boards = new_boards
	
	for board_coords in boards:
		_set_board(board_coords)
