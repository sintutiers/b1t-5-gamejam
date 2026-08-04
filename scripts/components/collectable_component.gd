# collectable_component.gd
class_name CollectableComponent
extends Node

signal collected(definition: ItemDefinition, amount: int)

@export var definition: ItemDefinition
@export var amount: int = 1

@onready var interactable: Interactable = _find_sibling_of_type(Interactable)


func _ready() -> void:
	interactable.interacted.connect(_on_interacted)


func collect() -> void:
	collected.emit(definition, amount)
	get_parent().queue_free()


func _on_interacted(_by: RapierArea2D) -> void:
	collect()


func _find_sibling_of_type(type: Script) -> Node:
	var parent: Node = get_parent()
	for child: Node in parent.get_children():
		if is_instance_of(child, type):
			return child
	return null
