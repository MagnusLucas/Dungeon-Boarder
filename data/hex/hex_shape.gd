class_name HexShape
extends Resource

@export var hex_coordinates: Array[Vector2i]:
	set(value):
		hex_coordinates = value
		changed.emit()


func _init(tilemap_coordinates: Array[Vector2i] = [Vector2i.ZERO]) -> void:
	hex_coordinates = tilemap_coordinates


func _find_boarder() -> TileBoarder:
	for coordinates in hex_coordinates:
		var neighbours := Hex.get_neighbours(coordinates)
		for direction in neighbours:
			if !neighbours[direction] in hex_coordinates:
				return TileBoarder.new(coordinates, direction)
	return null


func _get_next_boarder(coordinates: Vector2i, direction: Hex.Direction) -> TileBoarder:
	var neighbours := Hex.get_neighbours(coordinates)
	var next_direction: Hex.Direction = (direction + 1) % Hex.Direction.size() as Hex.Direction
	if !hex_coordinates.has(neighbours[next_direction]):
		return TileBoarder.new(coordinates, next_direction)
	var next_tile := neighbours[next_direction]
	var next_dir: Hex.Direction = Hex.get_neighbours(next_tile).find_key(coordinates)
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


func _get_hex_position(coordinates: Vector2i, hex_size: Vector2) -> Vector2:
	var half_tile_offset := hex_size / 2
	var base_position := Vector2(coordinates) * hex_size * Vector2(1, 0.75)
	if coordinates.y % 2 == 0:
		return base_position + half_tile_offset
	var odd_row_offset := hex_size / 2 * Vector2(1, 0)
	return base_position + odd_row_offset + half_tile_offset


func get_points(hex_size: Vector2) -> Array[Vector2]:
	var points: Array[Vector2] = []
	var boarder := _get_boarder()
	for tile_boarder in boarder:
		points.append(
			tile_boarder.get_begin(hex_size) +
			_get_hex_position(tile_boarder.owner, hex_size))
	return points
