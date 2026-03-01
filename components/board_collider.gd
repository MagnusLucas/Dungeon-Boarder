class_name BoardCollider
extends Area2D

var board: Board


func _init(target_board: Board, map: TileMapLayer) -> void:
	board = target_board
	var collision_polygon := CollisionPolygon2D.new()
	add_child(collision_polygon)
	var boarder := board.get_boarder()
	var vertices = []
	for tile_boarder in boarder:
		var tile_size := map.tile_set.tile_size
		var offset := map.map_to_local(tile_boarder.owner)
		vertices.append(tile_boarder.get_begin(tile_size) + offset)
	collision_polygon.polygon = vertices
