class_name TavernStock
extends HBoxContainer

signal character_picked_up(character: Character)

@export var available_characters := 4
@export var character_pool: CharacterPool
@export var min_hex_tile_size := Vector2(100, 115)


func _ready() -> void:
	_clear_children()
	_setup_random_stock()


func _clear_children() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()


func _setup_random_stock() -> void:
	for i in available_characters:
		var hsc := HexShapeContainer.new()
		hsc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hsc.min_hex_tile_size = min_hex_tile_size
		var chr := Character.new()
		# Line below might require duplication, depending on CharacterData content
		chr.character_data = character_pool.get_random_character_data()
		hsc.add_child(chr)
		add_child(hsc)
		chr.pick_up_requested.connect(character_picked_up.emit.bind(chr))
