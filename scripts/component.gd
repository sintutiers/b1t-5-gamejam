# component.gd
class_name Component
extends Node


static func find_child_of_type(from: Node, type: Variant, warn: bool = false) -> Node:
	for child: Node in from.get_children():
		if is_instance_of(child, type):
			return child
	if warn:
		push_warning("%s: no %s child." % [from.name, type])
	return null


func get_component(type: Variant, warn: bool = true) -> Node:
	var root: Node = _find_entity_root()
	for child: Node in root.find_children("*", "", true, false):
		if is_instance_of(child, type):
			return child
	if warn:
		push_warning("%s: no %s found." % [name, type])
	return null


func _find_entity_root() -> Node:
	var node: Node = get_parent()
	while node:
		if node is Entity:
			return node
		node = node.get_parent()
	return get_parent()
