# movement_component.gd
class_name MovementComponent
extends Node

enum Direction {NONE, UP, DOWN, LEFT, RIGHT}

const DEFAULT_DIRECTION: Direction = Direction.DOWN

const DIRECTION_NAMES: Dictionary[Direction, String] = {
	Direction.UP: "up",
	Direction.DOWN: "down",
	Direction.LEFT: "left",
	Direction.RIGHT: "right",
}

@export var move_speed: int = 200

var facing: Direction = DEFAULT_DIRECTION

var is_interacting: bool = false:
	set(value):
		is_interacting = value
		if value and body:
			body.velocity = Vector2.ZERO

const FACING_THRESHOLD: float = 0.5

@onready var animation: AnimationComponent = get_node_or_null("%AnimationComponent")
@onready var body: RapierCharacterBody2D = get_parent() as RapierCharacterBody2D


func _ready() -> void:
	if not body:
		push_error("MovementComponent: expects parent to be RapierCharacterBody2D. Disabling.")
		set_physics_process(false)
		return
	if not animation:
		push_warning("MovementComponent: AnimationComponent not found.")


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


func get_global_position() -> Vector2:
	return body.global_position


func _update_facing(direction: Vector2) -> void:
	var new_facing: Direction = facing
	if abs(direction.x) >= abs(direction.y):
		if direction.x > FACING_THRESHOLD:
			new_facing = Direction.RIGHT
		elif direction.x < -FACING_THRESHOLD:
			new_facing = Direction.LEFT
	else:
		if direction.y > FACING_THRESHOLD:
			new_facing = Direction.DOWN
		elif direction.y < -FACING_THRESHOLD:
			new_facing = Direction.UP
	facing = new_facing
