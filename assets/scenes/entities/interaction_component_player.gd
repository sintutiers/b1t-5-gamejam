# interaction_component_player.gd
class_name InteractionComponent
extends Node

@onready var interact_area: RapierArea2D = %InteractAreaPlayer
@onready var movement: MovementComponent = %movement


func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func _exit_tree() -> void:
	if DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"interact"):
		interact()


func interact() -> void:
	if movement.is_interacting:
		return

	var overlapping: Array[Node2D] = []
	overlapping.append_array(interact_area.get_overlapping_areas())
	overlapping.append_array(interact_area.get_overlapping_bodies())

	var closest: Interactable = null
	var closest_dist_sq: float = INF
	for node: Node2D in overlapping:
		var interactable: Interactable = _find_interactable(node)
		if not interactable:
			continue
		var d2: float = movement.get_global_position().distance_squared_to(interactable.global_position)
		if d2 < closest_dist_sq:
			closest_dist_sq = d2
			closest = interactable

	if closest:
		movement.is_interacting = true
		closest.trigger(interact_area)


func _find_interactable(node: Node2D) -> Interactable:
	if node is Interactable:
		return node as Interactable
	for child: Node in node.get_children():
		if child is Interactable:
			return child as Interactable
	return null


func _on_dialogue_ended(_resource: DialogueResource) -> void:
	movement.is_interacting = false
