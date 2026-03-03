class_name CharacterHexTexture
extends TextureRect

var character: Character


func _init(character_data: Character, bounding_rect_size: Vector2) -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	size = bounding_rect_size
	texture = AtlasCoordsTexture.new()
	character = character_data
	texture.set_coordinates(character.texture_coordinates)
