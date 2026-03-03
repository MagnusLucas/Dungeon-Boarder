class_name HexShapeContainer
extends Container

@export var min_hex_tile_size: Vector2 = Vector2(10, 10):
	set(value):
		min_hex_tile_size = value
		for child in get_children():
			_set_child_position(child, child.get_shape())
@export var fill_size: bool


func _init() -> void:
	child_entered_tree.connect(_on_child_entered_tree)


func _on_child_entered_tree(child: Node) -> void:
	if child is Map or child is Character:
		# Omg
		# You'd think ready.connect would be enough
		# But it actually makes perfect sense that it isn't
		# Since we don't know the size of this container, it depends on parent
		# so also root of scene.
		# This should happen before it first draws to screen, I think
		draw.connect(_set_child_position.bind(child, child.get_shape()),
				CONNECT_ONE_SHOT)


func _set_child_position(child: Node2D, shape: HexShape) -> void:
	var min_board := Hex.get_px_span(shape.hex_coordinates, min_hex_tile_size)
	custom_minimum_size = min_board.size
	
	if !fill_size:
		var min_middle := min_board.position + min_board.size / 2
		child.position = size/2 - min_middle
		child.set_hex_size(min_hex_tile_size)
		return
	
	var max_board_scale := size / min_board.size
	# Keeping aspect ratio
	var lower_max := minf(max_board_scale.x, max_board_scale.y)
	max_board_scale = Vector2(lower_max, lower_max)
	
	var max_hex_tile_size := max_board_scale * min_hex_tile_size
	var max_board := Hex.get_px_span(shape.hex_coordinates, max_hex_tile_size)
	var max_middle := max_board.position + max_board.size / 2
	child.position = size/2 - max_middle
	child.set_hex_size(max_hex_tile_size)
	
