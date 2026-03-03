@tool
class_name AtlasCoordsTexture
extends AtlasTexture

const HEXAGON_ALL_SHEET = preload("uid://e4yvbntghhu4")

@export var region_size := Vector2(120, 140)
@export var region_offset := Vector2(2, 2)

@export var coordinates: Vector2i: set = set_coordinates


func _init() -> void:
	atlas = HEXAGON_ALL_SHEET
	_update_region()


func _update_region() -> void:
	var position := (region_size + region_offset) * Vector2(coordinates)
	region = Rect2(position, region_size)


func set_coordinates(new_coordinates: Vector2i) -> void:
	coordinates = new_coordinates
	_update_region()
