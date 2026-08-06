# audio_component.gd
### actual dogshit code i need to rewire to my current system
### okey, i rewrote it
class_name AudioComponent
extends Component

@export var footstep_sounds: Array[AudioStream] = []
@export var fire_sound: AudioStream
@export var footstep_cooldown: float = 0.2
@export var footstep_buffer_duration: float = 0.1

var _footstep_timer: float = 0.0
var _footstep_buffer: float = 0.0

@onready var player: AudioStreamPlayer2D = %AudioStreamPlayer2D
@onready var animation: AnimationComponent = get_sibling(AnimationComponent)


func _ready() -> void:
	if animation:
		animation.step.connect(_on_step)


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


func _on_step(is_active: bool) -> void:
	if is_active:
		_footstep_buffer = footstep_buffer_duration
		play_footstep()
	elif _footstep_buffer > 0.0:
		play_footstep()


func _play_one_shot(stream: AudioStream) -> void:
	if not stream:
		return
	player.stream = stream
	player.play()
