class_name HexShape
extends Resource

@export var points: Array[Vector2i]:
	set(value):
		points = value
		changed.emit()


func _init(tilemap_coordinates: Array[Vector2i]) -> void:
	points = tilemap_coordinates
