class_name TileBoarder
extends RefCounted

var owner: Vector2i
var direction: Hex.Direction


func _init(tile_coords: Vector2i, hex_direction: Hex.Direction) -> void:
	owner = tile_coords
	direction = hex_direction


func _to_string() -> String:
	return "%s : %s" % [owner, direction]


func equals(other: TileBoarder) -> bool:
	return owner == other.owner and direction == other.direction


func get_begin(size: Vector2) -> Vector2:
	return Hex.get_points(size)[direction]


func get_end(size: Vector2) -> Vector2:
	return Hex.get_points(size)[(direction + 1) % Hex.Point.size()]
