# dialogue_component.gd
class_name DialogueComponent
extends Node

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

@onready var interactable: Interactable = get_parent() as Interactable


func _ready() -> void:
	assert(interactable, "Interactable needed.")
	if not dialogue_resource:
		push_warning("No DialogueResource.")
	interactable.interacted.connect(_on_interacted)


func _exit_tree() -> void:
	if interactable and interactable.interacted.is_connected(_on_interacted):
		interactable.interacted.disconnect(_on_interacted)


func _on_interacted(_by: RapierArea2D) -> void:
	if not dialogue_resource:
		return
	DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_start)
