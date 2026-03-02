class_name BoarderDrawer
extends Node2D

@export var shape: HexShape
@export var hex_size: Vector2
@export var color: Color


func _draw() -> void:
	if shape:
		var points := shape.get_points(hex_size)
		points.append(points[0])
		draw_polyline(points, color, 3)


func set_shape(new_shape: HexShape) -> void:
	shape = new_shape
	queue_redraw()


func erase_shape() -> void:
	shape = null
	queue_redraw()


func set_hex_size(new_size: Vector2) -> void:
	hex_size = new_size
