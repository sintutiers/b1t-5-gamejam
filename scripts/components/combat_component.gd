# combat_component.gd
class_name CombatComponent
extends Component

@export var look_relative: GUIDEAction
@export var look_absolute: GUIDEAction
@export var fire: GUIDEAction
@export var bolt: PackedScene
@export var turn_speed: float = 5.0
@export var max_turn_degrees: float = 80.0
@export var side_switch_margin: float = 6.0

var aim_angle: float = 0.0
var aim_side: float = 1.0
var started: bool = false

@onready var body: Node2D = get_parent() as Node2D
@onready var center_hand: Node2D = %CenterHand
@onready var sprite: Node2D = %AnimatedSprite2D


func _ready() -> void:
	if body:
		aim_angle = body.global_rotation
	started = true
	fire.triggered.connect(_fire)


func _physics_process(delta: float) -> void:
	var target: Vector2 = Vector2.INF
	if look_absolute.is_triggered():
		var mouse_pos: Vector2 = look_absolute.value_axis_2d
		target = get_viewport().get_canvas_transform().affine_inverse() * mouse_pos
	elif look_relative.is_triggered():
		target = body.global_position + look_relative.value_axis_2d
	if not target.is_finite():
		return
	var dir: Vector2 = target - center_hand.global_position
	if dir.length_squared() <= 0.000001:
		return
	if aim_side >= 0.0:
		if dir.x < -side_switch_margin:
			aim_side = -1.0
	else:
		if dir.x > side_switch_margin:
			aim_side = 1.0
	if not started:
		aim_angle = body.global_rotation
		started = true
	var flat_dir: Vector2 = Vector2(absf(dir.x), dir.y)
	var base_angle: float = clamp(
		flat_dir.angle(),
		-deg_to_rad(max_turn_degrees),
		deg_to_rad(max_turn_degrees),
	)
	var target_angle: float = base_angle * aim_side
	aim_angle = lerp_angle(aim_angle, target_angle, turn_speed * delta)
	body.global_rotation = aim_angle
	sprite.scale.x = aim_side * absf(sprite.scale.x)


func _fire() -> void:
	for hand: Node2D in [center_hand]:
		var a_bolt: Node2D = bolt.instantiate()
		body.get_parent().add_child(a_bolt)
		a_bolt.global_transform = hand.global_transform
