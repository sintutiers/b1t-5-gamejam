# dialogue_component.gd
class_name DialogueComponent
extends Node

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

var _movement: MovementComponent

@onready var interactable: Interactable = get_parent() as Interactable

func _ready() -> void:
	if not interactable:
		interactable = Component.find_sibling_of_type(self, Interactable, false) as Interactable
		if interactable:
			push_warning(
				"%s: Interactable is sibling. Prefer child of Interactable."
				% name,
			)
	assert(interactable, "Interactable needed.")
	if not dialogue_resource:
		push_warning("No DialogueResource.")
	interactable.interacted.connect(_on_interacted)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _exit_tree() -> void:
	if interactable and interactable.interacted.is_connected(_on_interacted):
		interactable.interacted.disconnect(_on_interacted)
	if DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)

func _on_interacted(by: RapierArea2D) -> void:
	if not dialogue_resource:
		return
	_movement = Component.find_sibling_of_type(by, MovementComponent) as MovementComponent
	if _movement:
		_movement.is_interacting = true
	DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_start)

func _on_dialogue_ended(_resource: DialogueResource) -> void:
	if _movement:
		_movement.is_interacting = false
