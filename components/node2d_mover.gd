class_name Node2DMover
extends Node2D

signal place_down_requested(node: Node)

var held_node: Node2D
var old_node_parent: Node


func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and held_node:
		var mbe: InputEventMouseButton = event
		if mbe.button_index == MOUSE_BUTTON_LEFT and mbe.is_released():
			place_down_requested.emit(held_node)


func pick_up_node(node: Node2D) -> void:
	if held_node:
		return
	held_node = node
	var grab_offset := held_node.global_position - global_position
	
	old_node_parent = node.get_parent()
	held_node.reparent(self)
	held_node.position = grab_offset


func put_it_back() -> void:
	if !held_node:
		push_error("Trying to put back nonexistent node!")
	held_node.reparent(old_node_parent)
	held_node = null
	old_node_parent = null
