# animation_component.gd
class_name AnimationComponent
extends Node

@export var buffer_duration: float = 0.3
@export var idle_delay: float = 3.0

var walk_buffer: float = 0.0
var idle_time: float = 0.0
var current_horizontal: MovementComponent.Horizontal = MovementComponent.DEFAULT_HORIZONTAL
var current_vertical: MovementComponent.Vertical = MovementComponent.DEFAULT_VERTICAL

@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D


func _ready() -> void:
	assert(sprite, "no Sprite.")
	sprite.play("start")


func play_walk(
	horizontal: MovementComponent.Horizontal,
	vertical: MovementComponent.Vertical,
) -> void:
	walk_buffer = buffer_duration
	idle_time = 0.0
	current_horizontal = horizontal
	current_vertical = vertical
	_play_if_needed(_walk_anim_name())


func update_walk_buffer(delta: float) -> void:
	walk_buffer -= delta
	if walk_buffer > 0.0:
		_play_if_needed(_walk_anim_name())
	else:
		walk_buffer = 0.0
		idle_time += delta
		if idle_time >= idle_delay:
			play_idle()


func play_idle() -> void:
	_play_if_needed("idle")


func _walk_anim_name() -> String:
	var h: String = MovementComponent.HORIZONTAL_NAMES.get(current_horizontal, "right")
	var v: String = MovementComponent.VERTICAL_NAMES.get(current_vertical, "down")
	return "%s_%s" % [h, v]


func _play_if_needed(anim_name: String) -> void:
	if sprite.animation != anim_name or not sprite.is_playing():
		sprite.play(anim_name)
