@tool
class_name CharacterArea2D
extends Area2D

@export var character: Character: set = set_character
@export var size := Vector2(100, 200 / sqrt(3))

var collider: HexCollider
var textures: Array[TextureRect]


func set_character(new_character: Character) -> void:
	character = new_character
	
	if collider: collider.free()
	
	collider = HexCollider.new(character.shape, size)
	add_child(collider)
	
	for hex_coords in new_character.get_hex_coordinates():
		var texture := CharacterHexTexture.new(new_character, size)
		add_child(texture)
		texture.position = Hex.get_hex_position(hex_coords, size)
