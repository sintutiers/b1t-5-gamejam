class_name FallZone
extends Node2D

@export var area: RapierArea2D

var _bodies_falling: Array[Node] = []


func _ready() -> void:
	if not area:
		area = find_child("*", true, false) as RapierArea2D
	if not area:
		push_error("%s: no RapierArea2D found/assigned." % name)
		return
	area.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body in _bodies_falling:
		return

	var movement: MovementComponent = Component.find_child_of_type(body, MovementComponent)
	var checkpoint: CheckpointComponent = Component.find_child_of_type(body, CheckpointComponent)
	var animation: AnimationComponent = Component.find_child_of_type(body, AnimationComponent)
	if not movement or not checkpoint:
		push_warning("%s: component missing %s." % [name, body.name])
		return

	_bodies_falling.append(body)

	if animation:
		animation.play_fall()
		await animation.fall_finished

	movement.fall_and_respawn(checkpoint.position)
	_bodies_falling.erase(body)
