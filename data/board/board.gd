class_name Board
extends Resource

@export var shape: HexShape
@export var tile_coordinates: Vector2i


func get_tiles() -> Array[Vector2i]:
	return shape.hex_coordinates
