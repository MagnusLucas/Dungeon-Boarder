@tool
class_name Character
extends Node2D

@export var character: CharacterData: set = set_character
@export var size := Vector2(100, 200 / sqrt(3))

var collider: HexCollider
var textures: Array[TextureRect]


func set_character(new_character: CharacterData) -> void:
	character = new_character
	
	set_collider()
	
	for hex_coords in new_character.get_hex_coordinates():
		var texture := CharacterHexTexture.new(new_character, size)
		add_child(texture)
		texture.position = Hex.get_hex_position(hex_coords, size)


func set_collider() -> void:
	if collider:
		collider.free()
	
	collider = HexCollider.new(character.shape, size)
	collider.mouse_entered.connect(_on_collider_mouse_entered)
	add_child(collider)


func _on_collider_mouse_entered() -> void:
	var boarder_drawer := BoarderDrawer.new(character.shape, size)
	add_child(boarder_drawer)
	collider.mouse_exited.connect(boarder_drawer.queue_free)
