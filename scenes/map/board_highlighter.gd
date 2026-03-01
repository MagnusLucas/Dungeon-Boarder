class_name BoardHighlighter
extends Node2D


var boundries: Array[Boundry]


func _get_tile_boundries(board: Board, tile: Vector2i, map: TileMapLayer) -> Array[Boundry]:
	var tile_boundries: Array[Boundry] = []
	
	var potential_neighbours := Hex.get_neighbours(tile)
	for direction in potential_neighbours:
		if !board.tiles.has(potential_neighbours[direction]):
			var boundry := Boundry.from_direction(direction, map.tile_set.tile_size)
			boundry.add_offset(map.map_to_local(tile))
			tile_boundries.append(boundry)
	
	return tile_boundries


func _calculate_boundries(board: Board, map: TileMapLayer) -> void:
	boundries = []
	for tile in board.tiles:
		boundries.append_array(_get_tile_boundries(board, tile, map))


func start_drawing_boundries(board: Board, map: TileMapLayer) -> void:
	_calculate_boundries(board, map)
	queue_redraw()


func end_drawing_boundries() -> void:
	boundries = []
	queue_redraw()


func _draw() -> void:
	for boundry in boundries:
		draw_line(boundry.start, boundry.end, Color.AQUA)


class Boundry:
	var start: Vector2
	var end: Vector2
	
	
	static func from_direction(direction: Hex.Direction, size: Vector2) -> Boundry:
		var boundry := Boundry.new()
		var points := Hex.get_points(size)
		match direction:
			Hex.Direction.RIGHT:
				boundry.start = points[Hex.Point.TOP_RIGHT]
				boundry.end = points[Hex.Point.BOTTOM_RIGHT]
			Hex.Direction.BOTTOM_RIGHT:
				boundry.start = points[Hex.Point.BOTTOM_RIGHT]
				boundry.end = points[Hex.Point.BOTTOM]
			Hex.Direction.BOTTOM_LEFT:
				boundry.start = points[Hex.Point.BOTTOM]
				boundry.end = points[Hex.Point.BOTTOM_LEFT]
			Hex.Direction.LEFT:
				boundry.start = points[Hex.Point.BOTTOM_LEFT]
				boundry.end = points[Hex.Point.TOP_LEFT]
			Hex.Direction.TOP_LEFT:
				boundry.start = points[Hex.Point.TOP_LEFT]
				boundry.end = points[Hex.Point.TOP]
			Hex.Direction.TOP_RIGHT:
				boundry.start = points[Hex.Point.TOP]
				boundry.end = points[Hex.Point.TOP_RIGHT]
		return boundry
	
	
	func add_offset(offset: Vector2) -> void:
		start += offset
		end += offset
