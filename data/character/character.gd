class_name Character
extends Resource

@export var name: String
@export var texture_coordinates: Vector2i
@export var shape: HexShape
@export var base_tile: Vector2i


func _to_string() -> String:
	return "%s" % name
