# component.gd
class_name Component
extends Node


# find a sibling by type, not just Components
static func find_sibling_of_type(from: Node, type: Variant, warn_if_missing: bool = true) -> Node:
	var parent: Node = from.get_parent()
	if not parent:
		push_error("%s: no parent." % from.name)
		return null
	for child: Node in parent.get_children():
		if is_instance_of(child, type):
			return child
	if warn_if_missing:
		push_warning("%s: no sibling of type %s." % [from.name, type])
	return null


# same but for children, jumppad need it, probb should update that
static func find_child_of_type(from: Node, type: Variant, warn_if_missing: bool = false) -> Node:
	for child: Node in from.get_children():
		if is_instance_of(child, type):
			return child
	if warn_if_missing:
		push_warning("%s: no child of type %s." % [from.name, type])
	return null


# components can get_sibling(AnimationComponent)
func get_sibling(type: Variant, warn_if_missing: bool = true) -> Node:
	return Component.find_sibling_of_type(self, type, warn_if_missing)
