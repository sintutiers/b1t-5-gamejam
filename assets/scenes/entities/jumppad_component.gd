# jumppad_component.gd
class_name JumppadComponent
extends RapierArea2D

enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	CUSTOM,
}

const DIRECTION_VECTORS: Dictionary[Direction, Vector2] = {
	Direction.UP: Vector2.UP,
	Direction.DOWN: Vector2.DOWN,
	Direction.LEFT: Vector2.LEFT,
	Direction.RIGHT: Vector2.RIGHT,
}

@export var direction: Direction = Direction.UP
@export var custom_direction: Vector2 = Vector2.UP
@export var launch_speed: float = 800.0
@export var additive: bool = false
@export var cooldown: float = 0.5

var _cooldowns: Dictionary = {}

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if _cooldowns.is_empty():
		return
	var to_remove: Array[Node] = []
	for body: Node in _cooldowns:
		_cooldowns[body] -= delta
		if _cooldowns[body] <= 0.0:
			to_remove.append(body)
	for body: Node in to_remove:
		_cooldowns.erase(body)

func _on_body_entered(body: Node2D) -> void:
	print("entered: ", body.name)
	if not _has_velocity(body):
		return
	if _cooldowns.has(body):
		return
	_launch(body)
	if cooldown > 0.0:
		_cooldowns[body] = cooldown

func get_launch_direction() -> Vector2:
	if direction == Direction.CUSTOM:
		return custom_direction
	return DIRECTION_VECTORS.get(direction, Vector2.ZERO)

func _launch(body: Node2D) -> void:
	var dir: Vector2 = get_launch_direction()
	if dir == Vector2.ZERO:
		return
	dir = dir.normalized()
	var new_velocity: Vector2 = dir * launch_speed
	if additive:
		var current: Variant = body.get("velocity")
		if current is Vector2:
			new_velocity += current
	body.set("velocity", new_velocity)

func _has_velocity(body: Node2D) -> bool:
	return body.get("velocity") is Vector2
