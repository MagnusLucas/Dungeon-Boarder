class_name HexCollider
extends Area2D

@export var shape: HexShape
@export var size: Vector2

var collision_shape: CollisionMultiHex2D


func _init(tilemap_shape: HexShape, hex_size: Vector2) -> void:
	shape = tilemap_shape
	size = hex_size
	collision_shape = CollisionMultiHex2D.new(shape, size)
	_update_collision_shape()
	shape.changed.connect(_update_collision_shape)
	add_child(collision_shape)


func _update_collision_shape() -> void:
	collision_shape.set_shape(shape)
	collision_shape.set_size(size)
