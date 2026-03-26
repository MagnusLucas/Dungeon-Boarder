class_name HexCollider
extends Area2D

signal left_clicked
signal right_clicked


@export var shape: HexShape
@export var size: Vector2

var collision_shape: CollisionMultiHex2D


func _init(
		tilemap_shape: HexShape, 
		hex_size: Vector2, 
		map_local_position: Vector2) -> void:
	shape = tilemap_shape
	size = hex_size
	collision_shape = CollisionMultiHex2D.new(shape, size)
	_update_collision_shape()
	shape.changed.connect(_update_collision_shape)
	add_child(collision_shape)
	_set_local_tilemap_position(map_local_position)


func _unhandled_input(event: InputEvent) -> void:
	if !(event is InputEventMouseButton):
		return
	if !event.pressed:
		return
	if event.button_index == MOUSE_BUTTON_LEFT:
		left_clicked.emit()
		return
	if event.button_index == MOUSE_BUTTON_RIGHT:
		right_clicked.emit()


func _update_collision_shape() -> void:
	collision_shape.set_shape(shape)
	collision_shape.set_size(size)


func _set_local_tilemap_position(local_position: Vector2) -> void:
	var offset := - size / 2
	position = local_position + offset
