@tool
class_name HexShapeContainer
extends Container

@export var min_hex_tile_size: Vector2
@export var fill_size: bool


func _init() -> void:
	child_entered_tree.connect(_on_child_entered_tree)


func _on_child_entered_tree(child: Node) -> void:
	if child is Map:
		_set_child_position(child, (child as Map).get_shape())
	elif child is Character:
		_set_child_position(child, (child as Character).get_shape())


func _set_child_position(child: Node2D, shape: HexShape) -> void:
	var min_board := Hex.get_px_span(shape.hex_coordinates, min_hex_tile_size)
	custom_minimum_size = min_board.size
	
	if !fill_size:
		child.position = size/2 + min_board.position
		return
	
	var max_board_scale := size / min_board.size
	# Keeping aspect ratio
	var lower_max := minf(max_board_scale.x, max_board_scale.y)
	max_board_scale = Vector2(lower_max, lower_max)
	
	var max_hex_tile_size := max_board_scale * min_hex_tile_size
	var max_board := Hex.get_px_span(shape.hex_coordinates, max_hex_tile_size)
	child.position = size/2 + max_board.position
