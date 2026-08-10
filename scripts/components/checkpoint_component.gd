# checkpoint_component
class_name CheckpointComponent
extends Component

var position: Vector2

@onready var body: Node2D = get_parent()


func _ready() -> void:
	position = body.global_position


func set_checkpoint(new_position: Vector2) -> void:
	position = new_position
