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
const FACING_THRESHOLD: float = 0.5

@export var move_speed: int = 150
@export var move: GUIDEAction

var facing: Direction = DEFAULT_DIRECTION
var is_interacting: bool = false:
	set(value):
		is_interacting = value
		if value:
			state_chart.send_event(&"interact")
		else:
			state_chart.send_event(&"interact_end")

@onready var animation: AnimationComponent = _find_sibling_of_type(AnimationComponent)
@onready var body: RapierCharacterBody2D = get_parent() as RapierCharacterBody2D
@onready var state_chart: StateChart = %StateChart
@onready var move_state: Node = %Move
@onready var interact_state: Node = %Interact
@onready var launch_state: Node = %Launch

func _ready() -> void:
	if not body:
		push_error("no body")
		set_physics_process(false)
		return

func launch(velocity: Vector2) -> void:
	body.velocity = velocity
	state_chart.send_event(&"launch")

func get_global_position() -> Vector2:
	return body.global_position

func _on_move_physics_update(delta: float) -> void:
	var input_dir: Vector2 = move.value_axis_2d
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

func _on_interact_physics_update(_delta: float) -> void:
	body.velocity = Vector2.ZERO
	body.move_and_slide()

func _on_launch_physics_update(_delta: float) -> void:
	body.move_and_slide()

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

# yeah im not asgning this manually, fuck that. do it yourself
func _find_sibling_of_type(type: Script) -> Node:
	var parent: Node = get_parent()
	if not parent:
		push_error("no parent")
		return null
	for child: Node in parent.get_children():
		if is_instance_of(child, type):
			return child
	push_warning("no sibling: %s" % type.resource_path)
	return null

func _physics_process(delta: float) -> void:
	if move_state.get("active"):
		_on_move_physics_update(delta)
	elif interact_state.get("active"):
		_on_interact_physics_update(delta)
	elif launch_state.get("active"):
		_on_launch_physics_update(delta)
