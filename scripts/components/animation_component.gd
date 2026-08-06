# animation_component.gd
class_name AnimationComponent
extends Node

signal step(is_active: bool)

@export var buffer_duration: float = 0.3
@export var idle_delay: float = 3.0

var walk_buffer: float = 0.0
var idle_time: float = 0.0
var is_actively_moving: bool = false
var current_horizontal: MovementComponent.Horizontal = MovementComponent.DEFAULT_HORIZONTAL
var current_vertical: MovementComponent.Vertical = MovementComponent.DEFAULT_VERTICAL

@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D


func _ready() -> void:
	assert(sprite, "no Sprite.")
	sprite.play("start")
	sprite.frame_changed.connect(_on_frame_changed)


func play_walk(
	horizontal: MovementComponent.Horizontal,
	vertical: MovementComponent.Vertical,
) -> void:
	walk_buffer = buffer_duration
	idle_time = 0.0
	is_actively_moving = true
	current_horizontal = horizontal
	current_vertical = vertical
	_play_if_needed(_walk_anim_name())


func update_walk_buffer(delta: float) -> void:
	is_actively_moving = false
	walk_buffer -= delta
	if walk_buffer > 0.0:
		_play_if_needed(_walk_anim_name())
	else:
		walk_buffer = 0.0
		idle_time += delta
		if idle_time >= idle_delay:
			play_idle()


func play_idle() -> void:
	is_actively_moving = false
	_play_if_needed("idle")


func _walk_anim_name() -> String:
	var h: String = MovementComponent.HORIZONTAL_NAMES.get(current_horizontal, "right")
	var v: String = MovementComponent.VERTICAL_NAMES.get(current_vertical, "down")
	return "%s_%s" % [h, v]


func _play_if_needed(anim_name: String) -> void:
	if sprite.animation != anim_name or not sprite.is_playing():
		sprite.play(anim_name)


func _on_frame_changed() -> void:
	if _is_walk_animation():
		step.emit(is_actively_moving)


func _is_walk_animation() -> bool:
	return sprite.animation != "idle" and sprite.animation != "start"
