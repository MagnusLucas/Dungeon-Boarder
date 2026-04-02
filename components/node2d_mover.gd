class_name Node2DMover
extends Node2D

var held_node: Node2D


func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var old_node := held_node
		held_node = null
		if old_node:
			old_node.queue_free()


func pick_up_node(node: Node2D) -> void:
	if held_node:
		return
	held_node = node
	
	held_node.reparent(self)
	held_node.position = Vector2.ZERO
