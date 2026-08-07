# animation_component.gd
class_name AnimationComponent
extends Component

signal step(is_active: bool)

@export var buffer_duration: float = 0.3
@export var idle_delay: float = 3.0

var walk_buffer: float = 0.0
var idle_time: float = 0.0
var is_actively_moving: bool = false

@onready var tree: AnimationTree = %AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = tree["parameters/playback"]
@onready var movement: MovementComponent = get_sibling(MovementComponent, false)


func _ready() -> void:
	assert(tree, "no AnimationTree.")
	tree.active = true
	playback.travel("start")
	if movement:
		movement.moved.connect(_on_moved)
		movement.stopped.connect(_on_stopped)
		movement.jumped.connect(_on_jumped)
		movement.landed.connect(_on_landed)


func _process(delta: float) -> void:
	if is_actively_moving:
		return
	if walk_buffer > 0.0:
		walk_buffer -= delta
		return
	walk_buffer = 0.0
	idle_time += delta
	if idle_time >= idle_delay:
		tree.active = true
		playback.travel("idle")


func _on_moved(direction: Vector2) -> void:
	tree.active = true
	walk_buffer = buffer_duration
	idle_time = 0.0
	is_actively_moving = true
	tree["parameters/walk/blend_position"] = direction
	playback.travel("walk")
	step.emit(true)


func _on_stopped() -> void:
	is_actively_moving = false
	var anim_player: AnimationPlayer = tree.get_node(tree.anim_player) as AnimationPlayer
	if anim_player:
		anim_player.seek(0.0, true)
	tree.active = false
	step.emit(false)


func _on_jumped(direction: Vector2) -> void:
	tree["parameters/jump/blend_position"] = direction
	playback.travel("jump")


func _on_landed() -> void:
	var anim_player: AnimationPlayer = tree.get_node(tree.anim_player) as AnimationPlayer
	if anim_player:
		anim_player.seek(0.0, true)
	tree.active = false
