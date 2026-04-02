class_name Tavern
extends PanelContainer

@onready var tavern_stock: TavernStock = $StockAndMap/TavernStock
@onready var node_2d_mover: Node2DMover = $StockAndMap/Node2DMover


func _ready() -> void:
	tavern_stock.character_picked_up.connect(node_2d_mover.pick_up_node)
	node_2d_mover.place_down_requested.connect(node_2d_mover.put_it_back.unbind(1))
