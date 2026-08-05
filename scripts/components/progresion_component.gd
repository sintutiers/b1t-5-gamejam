# progression_component.gd
class_name ProgressionComponent
extends Node

@onready var collectable: CollectableComponent = _find_sibling_of_type(CollectableComponent)


func _ready() -> void:
	if not collectable:
		push_warning("no CollectableComponent sibling.")
		return
	collectable.collected.connect(_on_collected)


func _on_collected(definition: ItemDefinition, amount: int) -> void:
	ProgressionState.register_collected(definition, amount)


func _find_sibling_of_type(type: Script) -> Node:
	var parent: Node = get_parent()
	for child: Node in parent.get_children():
		if is_instance_of(child, type):
			return child
	return null
