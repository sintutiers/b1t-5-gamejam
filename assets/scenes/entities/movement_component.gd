# movement_component.gd
class_name MovementComponent
extends Node

enum Direction {NONE, UP, DOWN, LEFT, RIGHT}
const DIRECTION_NAMES: Dictionary[Direction, String] = {
	Direction.UP: "up",
	Direction.DOWN: "down",
	Direction.LEFT: "left",
	Direction.RIGHT: "right",
}

@export var move_speed: int = 200

var facing: Direction = Direction.DOWN
var is_interacting: bool = false

@onready var animation: AnimationComponent = get_node_or_null("%AnimationComponent")
@onready var body: RapierCharacterBody2D = get_parent() as RapierCharacterBody2D


func _ready() -> void:
	assert(body != null, "Movement_Component expects parent to be RapierCharacterBody2D.")
	if not animation:
		push_warning("Movement_Component: Animation_Component would be nice to have no?")


func _physics_process(delta: float) -> void:
	if is_interacting:
		body.velocity = Vector2.ZERO
		body.move_and_slide()
		return

	var input_dir: Vector2 = Input.get_vector(&"left", &"right", &"up", &"down")
	if input_dir != Vector2.ZERO:
		body.velocity = input_dir * move_speed
		_update_facing(input_dir)
		if animation:
			animation.play_walk(facing)
	else:
		body.velocity = Vector2.ZERO
		if animation:
			animation.update_walk_buffer(delta)

	body.move_and_slide()
	body.position = body.position.round() # temp, should be improved


func set_interacting(value: bool) -> void:
	is_interacting = value
	if value:
		body.velocity = Vector2.ZERO


func _update_facing(direction: Vector2) -> void:
	var threshold: float = 0.5
	var new_facing: Direction = facing

	if abs(direction.x) >= abs(direction.y):
		if direction.x > threshold:
			new_facing = Direction.RIGHT
		elif direction.x < -threshold:
			new_facing = Direction.LEFT
	else:
		if direction.y > threshold:
			new_facing = Direction.DOWN
		elif direction.y < -threshold:
			new_facing = Direction.UP

	facing = new_facing
