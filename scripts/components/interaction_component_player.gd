# interaction_component_player.gd
class_name InteractionComponent
extends Component

@export var interact_action: GUIDEAction

@onready var interact_area: RapierArea2D = get_sibling(RapierArea2D)
@onready var movement: MovementComponent = get_sibling(MovementComponent)


func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	interact_action.triggered.connect(_on_interact_triggered)


func _exit_tree() -> void:
	DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)
	interact_action.triggered.disconnect(_on_interact_triggered)


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
		var dist_sq: float = movement.get_global_position().distance_squared_to(
			interactable.global_position
		)
		if dist_sq < closest_dist_sq:
			closest_dist_sq = dist_sq
			closest = interactable
	if closest:
		movement.is_interacting = true
		closest.trigger(interact_area)
		print("Interacted: ", closest.get_parent().name)


func _on_interact_triggered() -> void:
	interact()


func _find_interactable(node: Node2D) -> Interactable:
	if node is Interactable:
		return node
	for child: Node in node.get_children():
		if child is Interactable:
			return child
	return null


func _on_dialogue_ended(_resource: DialogueResource) -> void:
	movement.is_interacting = false
