# 1.gd
extends Node2D


func _ready() -> void:
	_set_mouse_filter_recursive(self, Control.MOUSE_FILTER_IGNORE)


func _set_mouse_filter_recursive(node: Node, filter: Control.MouseFilter) -> void:
	if node is Control:
		(node as Control).mouse_filter = filter
	for child in node.get_children():
		_set_mouse_filter_recursive(child, filter)
