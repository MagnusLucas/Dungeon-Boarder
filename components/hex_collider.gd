class_name HexCollider
extends Area2D


func _init(size: Vector2) -> void:
	var collision_shape := CollisionMultiHex2D.new()
	collision_shape.set_size(size)
	add_child(collision_shape)
