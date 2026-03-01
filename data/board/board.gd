class_name Board
extends Resource


@export var tiles: Dictionary[Vector2i, bool]
@export var tile_coordinates: Vector2i


func _find_boarder() -> TileBoarder:
	for tile in tiles:
		var neighbours := Hex.get_neighbours(tile)
		for direction in neighbours:
			if !neighbours[direction] in tiles:
				return TileBoarder.new(tile, direction)
	return null


func _get_next_boarder(tile: Vector2i, direction: Hex.Direction) -> TileBoarder:
	var neighbours := Hex.get_neighbours(tile)
	var next_direction: Hex.Direction = (direction + 1) % Hex.Direction.size() as Hex.Direction
	if !tiles.has(neighbours[next_direction]):
		return TileBoarder.new(tile, next_direction)
	var next_tile := neighbours[next_direction]
	var next_dir: Hex.Direction = Hex.get_neighbours(next_tile).find_key(tile)
	next_dir = (next_dir + 1) % Hex.Direction.size() as Hex.Direction
	return TileBoarder.new(next_tile, next_dir)
	


func get_boarder() -> Array[TileBoarder]: # [Vector2i, Hex.Direction]
	var first := _find_boarder()
	var result: Array[TileBoarder] = [first]
	var next := _get_next_boarder(first.owner, first.direction)
	while !next.equals(first):
		result.append(next)
		next = _get_next_boarder(next.owner, next.direction)
	return result
