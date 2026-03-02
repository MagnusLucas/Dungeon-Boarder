@tool
class_name CollisionMultiHex2D
extends CollisionPolygon2D


@export var hex_coordinates: Array[Vector2i]:
	set(value):
		hex_coordinates = value
		polygon = get_points()
@export var size: Vector2:
	set(value):
		size = value
		polygon = get_points()


func _find_boarder() -> TileBoarder:
	for tile in hex_coordinates:
		var neighbours := Hex.get_neighbours(tile)
		for direction in neighbours:
			if !neighbours[direction] in hex_coordinates:
				return TileBoarder.new(tile, direction)
	return null


func _get_next_boarder(tile: Vector2i, direction: Hex.Direction) -> TileBoarder:
	var neighbours := Hex.get_neighbours(tile)
	var next_direction: Hex.Direction = (direction + 1) % Hex.Direction.size() as Hex.Direction
	if !hex_coordinates.has(neighbours[next_direction]):
		return TileBoarder.new(tile, next_direction)
	var next_tile := neighbours[next_direction]
	var next_dir: Hex.Direction = Hex.get_neighbours(next_tile).find_key(tile)
	next_dir = (next_dir + 1) % Hex.Direction.size() as Hex.Direction
	return TileBoarder.new(next_tile, next_dir)


func _get_boarder() -> Array[TileBoarder]:
	var first := _find_boarder()
	var result: Array[TileBoarder] = [first]
	var next := _get_next_boarder(first.owner, first.direction)
	while !next.equals(first):
		result.append(next)
		next = _get_next_boarder(next.owner, next.direction)
	return result


func _get_hex_position(coordinates: Vector2i) -> Vector2:
	var half_tile_offset := size/2
	var base_position := Vector2(coordinates) * size * Vector2(1, 0.75)
	if coordinates.y % 2 == 0:
		return base_position + half_tile_offset
	var odd_row_offset := size / 2 * Vector2(1, 0)
	return base_position + odd_row_offset + half_tile_offset


func get_points() -> Array[Vector2]:
	var points: Array[Vector2] = []
	var boarder := _get_boarder()
	for tile_boarder in boarder:
		points.append(tile_boarder.get_begin(size) + _get_hex_position(tile_boarder.owner))
	return points
