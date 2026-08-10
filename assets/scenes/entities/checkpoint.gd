class_name Checkpoint
extends RapierArea2D


func _on_body_entered(body: Node) -> void:
	var checkpoint: CheckpointComponent = Component.find_child_of_type(body, CheckpointComponent)
	if checkpoint:
		checkpoint.set_checkpoint(global_position)
