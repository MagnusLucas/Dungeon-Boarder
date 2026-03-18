class_name BoarderDrawer
extends Node2D

@export var shape: HexShape
@export var hex_size: Vector2
@export var color: Color


func _init(hex_shape: HexShape, single_hex_size: Vector2, 
		boarder_color := Color.BLACK) -> void:
	shape = hex_shape
	hex_size = single_hex_size
	color = boarder_color


func _draw() -> void:
	var points := shape.get_points(hex_size)
	points.append(points[0])
	draw_polyline(points, color, 3)
