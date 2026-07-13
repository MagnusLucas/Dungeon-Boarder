class_name Character
extends Node2D

signal pick_up_requested

@export var character_data: CharacterData: set = set_character
@export var size := Vector2(100, 200 / sqrt(3))

var collider: HexCollider
var textures: Array[TextureRect]


func _on_collider_mouse_entered() -> void:
	var boarder_drawer := BoarderDrawer.new(character_data.shape, size)
	add_child(boarder_drawer)
	collider.mouse_exited.connect(boarder_drawer.queue_free)


func _clear_children() -> void:
	var old_children = []
	collider = null
	textures = []
	for child in get_children():
		old_children.append(child)
		remove_child(child)
	old_children.all(func(child): child.queue_free())


func _set_textures() -> void:
	for hex_coords in character_data.get_hex_coordinates():
		var texture := CharacterHexTexture.new(character_data, size)
		add_child(texture)
		texture.position = Hex.get_hex_position(hex_coords, size)


func _set_collider() -> void:
	collider = HexCollider.new(character_data.shape, size, size/2)
	collider.collision_layer = 2 # is character
	collider.collision_mask = 1 # sees boards
	collider.mouse_entered.connect(_on_collider_mouse_entered)
	collider.left_clicked.connect(pick_up_requested.emit)
	add_child(collider)


func set_character(new_character: CharacterData) -> void:
	character_data = new_character
	_clear_children()
	_set_collider()
	_set_textures()


func set_hex_size(new_size: Vector2) -> void:
	size = new_size
	set_character(character_data)


func get_shape() -> HexShape:
	return character_data.shape
