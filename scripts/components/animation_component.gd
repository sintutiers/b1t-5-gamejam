# animation_component.gd
class_name AnimationComponent
extends Component

signal step(is_active: bool)

@export var buffer_duration: float = 0.3
@export var idle_delay: float = 3.0
@export var flip_enabled: bool = true
@export var flip_duration: float = 0.08

var is_actively_moving: bool = false
var _base_scale_x: float = 1.0
var _flip_tween: Tween
var _idle_timer: SceneTreeTimer

@onready var tree: AnimationTree = %AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = tree["parameters/playback"]
@onready var movement: MovementComponent = get_sibling(MovementComponent, false)
@onready var sprite: Node2D = %AnimatedSprite2D


func _ready() -> void:
	assert(tree, "no AnimationTree.")
	_base_scale_x = sprite.scale.x
	tree.active = true
	playback.travel("start")
	if movement:
		movement.moved.connect(_on_moved)
		movement.stopped.connect(_on_stopped)
		movement.jumped.connect(_on_jumped)
		movement.landed.connect(_on_landed)
		movement.flipped.connect(_on_flipped)


func _on_moved(direction: Vector2) -> void:
	tree.active = true
	is_actively_moving = true
	tree["parameters/walk/blend_position"] = direction
	playback.travel("walk")
	step.emit(true)
	_start_idle_countdown()


func _on_stopped() -> void:
	is_actively_moving = false
	var anim_player: AnimationPlayer = tree.get_node(tree.anim_player) as AnimationPlayer
	if anim_player:
		anim_player.seek(0.0, true)
	tree.active = false
	step.emit(false)
	_start_idle_countdown()


func _on_jumped(direction: Vector2) -> void:
	tree["parameters/jump/blend_position"] = direction
	playback.travel("jump")


func _on_landed() -> void:
	var anim_player: AnimationPlayer = tree.get_node(tree.anim_player) as AnimationPlayer
	if anim_player:
		anim_player.seek(0.0, true)
	tree.active = false


func _on_flipped(_new_facing_x: float) -> void:
	if not flip_enabled:
		return
	if _flip_tween and _flip_tween.is_valid():
		_flip_tween.kill()
	sprite.scale.x = _base_scale_x
	_flip_tween = create_tween()
	_flip_tween.set_trans(Tween.TRANS_BACK)
	_flip_tween.set_ease(Tween.EASE_OUT)
	_flip_tween.tween_property(sprite, "scale:x", 0.0, flip_duration)
	_flip_tween.tween_property(sprite, "scale:x", _base_scale_x, flip_duration)


func _start_idle_countdown() -> void:
	_idle_timer = get_tree().create_timer(buffer_duration + idle_delay)
	_idle_timer.timeout.connect(_on_idle_countdown_finished)


func _on_idle_countdown_finished() -> void:
	if is_actively_moving:
		return
	tree.active = true
	playback.travel("idle")
