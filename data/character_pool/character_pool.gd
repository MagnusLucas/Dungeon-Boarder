# This should be converted to C#
class_name CharacterPool
extends Resource

@export var characters: Dictionary[CharacterData, int]:
	set(value):
		characters = value
		available_characters = value.duplicate()

var available_characters: Dictionary[CharacterData, int]


func print_characters() -> void:
	print("Original pool: ", characters)
	print("Currently available: ", available_characters)


func get_random_character_data() -> CharacterData:
	var rng := RandomNumberGenerator.new()
	var random_idx := rng.rand_weighted(available_characters.values())
	var character: CharacterData = available_characters.keys()[random_idx]
	
	available_characters[character] -= 1
	return character
