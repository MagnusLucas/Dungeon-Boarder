@tool
class_name CollisionMultiHex2D
extends CollisionPolygon2D

@export var shape: HexShape: set = set_shape
@export var size: Vector2: set = set_size


func _init(hex_shape: HexShape, hex_size: Vector2) -> void:
	shape = hex_shape
	size = hex_size
	_update_polygon()


func set_shape(new_shape: HexShape) -> void:
	if shape:
		shape.changed.disconnect(_update_polygon)
	shape = new_shape
	if shape:
		shape.changed.connect(_update_polygon)
	_update_polygon()


func set_size(new_size: Vector2) -> void:
	size = new_size
	_update_polygon()


func _update_polygon() -> void:
	if !shape:
		polygon = []
		return
	polygon = shape.get_points(size)
