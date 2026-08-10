# combat_component.gd
class_name CombatComponent
extends Component

@export var look_relative: GUIDEAction
@export var look_absolute: GUIDEAction
@export var fire: GUIDEAction
@export var bolt: PackedScene
@export var max_turn_degrees: float = 90.0

@export var turn_speed: float = 5.0

var _facing_angle: float = 0.0
var _initialized: bool = false

@onready var body: Node2D = get_parent() as Node2D
@onready var center_hand: Node2D = %CenterHand


func _ready() -> void:
	if body != null:
		_facing_angle = body.global_rotation
	_initialized = true
	fire.triggered.connect(_fire)


func _physics_process(delta: float) -> void:
	var target: Vector2 = Vector2.INF

	if look_absolute.is_triggered():
		var canvas_pos: Vector2 = look_absolute.value_axis_2d
		target = get_viewport().get_canvas_transform().affine_inverse() * canvas_pos
	elif look_relative.is_triggered():
		target = body.global_position + look_relative.value_axis_2d

	if not target.is_finite():
		return

	var to_target: Vector2 = target - body.global_position
	if to_target.length_squared() <= 0.000001:
		return

	var desired_angle: float = to_target.angle()

	if not _initialized:
		_facing_angle = body.global_rotation
		_initialized = true

	var signed_delta: float = wrapf(desired_angle - _facing_angle, -PI, PI)
	var max_delta: float = deg_to_rad(max_turn_degrees)
	signed_delta = clamp(signed_delta, -max_delta, max_delta)

	var clamped_angle: float = _facing_angle + signed_delta
	_facing_angle = lerp_angle(_facing_angle, clamped_angle, turn_speed * delta)

	body.global_rotation = _facing_angle


func _fire() -> void:
	for hand: Node2D in [center_hand]:
		var a_bolt: Node2D = bolt.instantiate()
		body.get_parent().add_child(a_bolt)
		a_bolt.global_transform = hand.global_transform
