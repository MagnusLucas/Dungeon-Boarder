class_name CharacterData
extends Resource

@export var name: String
@export var texture_coordinates: Vector2i
@export var shape: HexShape


func _to_string() -> String:
	return "%s" % name


func get_hex_coordinates() -> Array[Vector2i]:
	return shape.hex_coordinates
