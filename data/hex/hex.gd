class_name Hex
extends RefCounted


enum Direction{
	RIGHT,
	BOTTOM_RIGHT,
	BOTTOM_LEFT,
	LEFT,
	TOP_LEFT,
	TOP_RIGHT
}

enum Point{
	TOP_RIGHT,
	BOTTOM_RIGHT,
	BOTTOM,
	BOTTOM_LEFT,
	TOP_LEFT,
	TOP
}


static func get_neighbours(position: Vector2i) -> Dictionary[Direction, Vector2i]:
	const EVEN_ROW: Dictionary[Direction, Vector2i] = {
		Direction.RIGHT : Vector2i(1, 0),
		Direction.BOTTOM_RIGHT : Vector2i(0, 1),
		Direction.BOTTOM_LEFT : Vector2i(-1, 1),
		Direction.LEFT : Vector2i(-1, 0),
		Direction.TOP_LEFT : Vector2i(-1, -1),
		Direction.TOP_RIGHT : Vector2i(0, -1),
	}
	const ODD_ROW: Dictionary[Direction, Vector2i] = {
		Direction.RIGHT : Vector2i(1, 0),
		Direction.BOTTOM_RIGHT : Vector2i(1, 1),
		Direction.BOTTOM_LEFT : Vector2i(0, 1),
		Direction.LEFT : Vector2i(-1, 0),
		Direction.TOP_LEFT : Vector2i(0, -1),
		Direction.TOP_RIGHT : Vector2i(1, -1),
	}
	
	var result := EVEN_ROW.duplicate() if position.y % 2 == 0 else ODD_ROW.duplicate()
	for key in result:
		result[key] += position
	return result


static func get_points(size: Vector2) -> Dictionary[Point, Vector2]:
	const POINTS: Dictionary[Point, Vector2] = {
		Point.TOP : Vector2(0.5, 0),
		Point.TOP_RIGHT : Vector2(1, 0.25),
		Point.BOTTOM_RIGHT : Vector2(1, 0.75),
		Point.BOTTOM : Vector2(0.5, 1),
		Point.BOTTOM_LEFT : Vector2(0, 0.75),
		Point.TOP_LEFT : Vector2(0, 0.25),
	}
	var result := POINTS.duplicate()
	for key in result:
		result[key] = result[key] * size - size / 2
	return result


static func get_hex_position(coordinates: Vector2i, hex_size: Vector2) -> Vector2:
	var base_position := Vector2(coordinates) * hex_size * Vector2(1, 0.75)
	if coordinates.y % 2 == 0:
		return base_position
	var odd_row_offset := hex_size / 2 * Vector2(1, 0)
	return base_position + odd_row_offset


static func get_px_span(hexes: Array[Vector2i], hex_size: Vector2) -> Rect2:
	var min_x := INF
	var max_x := -INF
	var min_y := INF
	var max_y := -INF
	
	for hex in hexes:
		var pos := get_hex_position(hex, hex_size)
		if pos.x < min_x: min_x = pos.x
		if pos.x + hex_size.x > max_x: max_x = pos.x + hex_size.x
		if pos.y < min_y: min_y = pos.y
		if pos.y  + hex_size.y > max_y: max_y = pos.y + hex_size.y
	
	var size := Vector2(max_x - min_x, max_y - min_y)
	var position := Vector2(min_x, min_y)
	return Rect2(position, size)
