# interaction_component_player.gd
class_name InteractionComponent
extends Component

@export var interact_action: GUIDEAction
@export var interact_radius: float = 32.0

@onready var interact_area: RapierArea2D = get_component(RapierArea2D)
@onready var movement: MovementComponent = get_component(MovementComponent)


func _ready() -> void:
	interact_action.triggered.connect(_on_interact_triggered)


func _exit_tree() -> void:
	interact_action.triggered.disconnect(_on_interact_triggered)


func interact() -> void:
	if movement.is_interacting:
		return
	var closest: Interactable = null
	var closest_dist_sq: float = INF
	var player_pos: Vector2 = movement.get_global_position()
	for interactable: Interactable in get_tree().get_nodes_in_group(&"interactable"):
		var dist_sq: float = player_pos.distance_squared_to(interactable.global_position)
		if dist_sq > interact_radius * interact_radius:
			continue
		if dist_sq < closest_dist_sq:
			closest_dist_sq = dist_sq
			closest = interactable
	if closest:
		closest.trigger(interact_area)
		print("Interacted: ", closest.name)


func _on_interact_triggered() -> void:
	interact()
