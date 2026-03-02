@tool
class_name CharacterArea2D
extends Area2D

@export var character: Character: set = set_character
@export var size := Vector2(100, 100 * sqrt(3))

var collider: HexCollider
var textures: Array[TextureRect]

@onready var texture_rect: TextureRect = $TextureRect


func _ready() -> void:
	texture_rect.texture = AtlasCoordsTexture.new()


func set_character(new_character: Character) -> void:
	character = new_character
	
	var old_collider := collider
	collider = null
	old_collider.free()
	
	collider = HexCollider.new(character.shape, size)
	add_child(collider)
