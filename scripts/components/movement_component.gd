# movement_component.gd
class_name MovementComponent
extends Component

signal moved(direction: Vector2)
signal stopped
signal jumped(direction: Vector2)
signal landed
signal flipped(new_facing_x: float)

@export var move_speed: int = 150
@export var move: GUIDEAction

var facing: Vector2 = Vector2.DOWN
var is_interacting: bool = false:
	set(value):
		is_interacting = value
		if value:
			state_chart.send_event(&"interact")
		else:
			state_chart.send_event(&"interact_end")
var _was_moving: bool = false
var _was_airborne: bool = false

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


func _physics_process(delta: float) -> void:
	if move_state.get("active"):
		_on_move_physics_update(delta)
	elif interact_state.get("active"):
		_on_interact_physics_update(delta)
	elif launch_state.get("active"):
		_on_launch_physics_update(delta)
	_check_landing()


func launch(velocity: Vector2) -> void:
	body.velocity = velocity
	state_chart.send_event(&"launch")


func jump() -> void:
	jumped.emit(facing)


func get_global_position() -> Vector2:
	return body.global_position


func _on_move_physics_update(_delta: float) -> void:
	var input_dir: Vector2 = move.value_axis_2d
	if input_dir.length() < 0.15:
		input_dir = Vector2.ZERO
	if input_dir != Vector2.ZERO:
		body.velocity = input_dir * move_speed
		var direction_changed: bool = _update_facing(input_dir)
		if not _was_moving or direction_changed:
			moved.emit(facing)
		_was_moving = true
	else:
		body.velocity = Vector2.ZERO
		if _was_moving:
			stopped.emit()
		_was_moving = false
	body.move_and_slide()


func _on_interact_physics_update(_delta: float) -> void:
	body.velocity = Vector2.ZERO
	body.move_and_slide()


func _on_launch_physics_update(_delta: float) -> void:
	body.move_and_slide()


func _check_landing() -> void:
	var airborne: bool = launch_state.get("active")
	if _was_airborne and not airborne and body.is_on_floor():
		landed.emit()
	_was_airborne = airborne


func _update_facing(direction: Vector2) -> bool:
	if direction == Vector2.ZERO:
		return false
	var new_facing: Vector2 = Vector2(
		1.0 if direction.x >= 0.0 else -1.0,
		1.0 if direction.y >= 0.0 else -1.0,
	).normalized()
	var changed: bool = new_facing != facing
	if sign(new_facing.x) != sign(facing.x) and sign(new_facing.x) != 0.0 and sign(facing.x) != 0.0:
		flipped.emit(new_facing.x)
	facing = new_facing
	return changed
