# combat_component.gd
class_name CombatComponent
extends Node

@export var look_relative: GUIDEAction
@export var look_absolute: GUIDEAction
@export var fire: GUIDEAction
@export var bolt: PackedScene

@onready var body: Node2D = get_parent() as Node2D
#@onready var left_hand: Node2D = %LeftHand
#@onready var right_hand: Node2D = %RightHand
@onready var center_hand: Node2D = %CenterHand


func _ready() -> void:
	fire.triggered.connect(_fire)


func _physics_process(delta: float) -> void:
	var target: Vector2 = Vector2.INF

	if look_absolute.is_triggered():
		var canvas_pos: Vector2 = look_absolute.value_axis_2d
		target = get_viewport().get_canvas_transform().affine_inverse() * canvas_pos
	elif look_relative.is_triggered():
		target = body.global_position + look_relative.value_axis_2d

	if target.is_finite():
		var target_orientation: Transform2D = Transform2D() \
				.translated(body.global_position) \
				.looking_at(target)
		body.global_transform = body.global_transform.interpolate_with(
			target_orientation,
			5 * delta,
		)


func _fire() -> void:
	for hand: Node2D in [center_hand]:
		var a_bolt: Node2D = bolt.instantiate()
		body.get_parent().add_child(a_bolt)
		a_bolt.global_transform = hand.global_transform
