# audio_component.gd
### actual dogshit code i need to rewire to my current system
class_name AudioComponent
extends Component

@export var footstep_sounds: Array[AudioStream] = []
@export var fire_sound: AudioStream
@export var footstep_cooldown: float = 0.2
@export var footstep_buffer_duration: float = 0.1

var animation: AnimationComponent
var movement: MovementComponent
var _footstep_timer: float = 0.0
var _footstep_buffer: float = 0.0

@onready var player: AudioStreamPlayer2D = %AudioStreamPlayer2D


func _ready() -> void:
	call_deferred("_connect_siblings")


func _process(delta: float) -> void:
	if _footstep_timer > 0.0:
		_footstep_timer -= delta
	if _footstep_buffer > 0.0:
		_footstep_buffer -= delta


func play_footstep() -> void:
	if footstep_sounds.is_empty():
		return
	if _footstep_timer > 0.0:
		return
	if player.playing:
		return
	_footstep_timer = footstep_cooldown
	player.stream = footstep_sounds.pick_random()
	player.play()


func play_fire() -> void:
	_play_one_shot(fire_sound)


func _connect_siblings() -> void:
	animation = get_sibling(AnimationComponent)
	movement = get_sibling(MovementComponent)
	if not animation or not movement:
		push_error("missing sibling")
		return
	animation.sprite.frame_changed.connect(_on_frame_changed)


func _on_frame_changed() -> void:
	if not movement.move_state.get("active"):
		return
	var state = movement.move._last_state
	if (
		state == GUIDEAction.GUIDEActionState.TRIGGERED
		or state == GUIDEAction.GUIDEActionState.ONGOING
	):
		_footstep_buffer = footstep_buffer_duration
		play_footstep()
	elif _footstep_buffer > 0.0:
		play_footstep()


func _play_one_shot(stream: AudioStream) -> void:
	if not stream:
		return
	player.stream = stream
	player.play()
