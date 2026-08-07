# movement_component.gd
class_name MovementComponent
extends Component

signal moved(direction: Vector2)
signal stopped
signal jumped(direction: Vector2)

const FACING_THRESHOLD: float = 0.5

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


func launch(velocity: Vector2) -> void:
	body.velocity = velocity
	state_chart.send_event(&"launch")


func jump() -> void:
	jumped.emit(facing)


func get_global_position() -> Vector2:
	return body.global_position


func _on_move_physics_update(delta: float) -> void:
	var input_dir: Vector2 = move.value_axis_2d
	if input_dir != Vector2.ZERO:
		body.velocity = input_dir * move_speed
		_update_facing(input_dir)
		moved.emit(facing)
	else:
		body.velocity = Vector2.ZERO
		stopped.emit()
	body.move_and_slide()


func _on_interact_physics_update(_delta: float) -> void:
	body.velocity = Vector2.ZERO
	body.move_and_slide()


func _on_launch_physics_update(_delta: float) -> void:
	body.move_and_slide()


func _update_facing(direction: Vector2) -> void:
	if abs(direction.x) > FACING_THRESHOLD:
		facing.x = 1.0 if direction.x > 0.0 else -1.0
	else:
		facing.x = 0.0
	if abs(direction.y) > FACING_THRESHOLD:
		facing.y = 1.0 if direction.y > 0.0 else -1.0
	else:
		facing.y = 0.0
	if facing == Vector2.ZERO:
		facing = Vector2.DOWN
