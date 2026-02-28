class_name HexCollider
extends Area2D


func _init(size: Vector2) -> void:
	var collision_shape := CollisionShape2D.new()
	add_child(collision_shape)
	collision_shape.shape = ConvexPolygonShape2D.new()
	
	var hex_points := Hex.get_points(size)
	collision_shape.shape.points = hex_points.values()
