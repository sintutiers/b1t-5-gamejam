### actual dogshit code i need to rewire to my current system
### okey, i rewrote it
class_name AudioComponent
extends Component

@export var footstep_sounds: Array[AudioStream] = []
@export var fire_sound: AudioStream
@export var footstep_interval: float = 0.35

var _is_walking: bool = false
var _footstep_timer: float = 0.0

@onready var player: AudioStreamPlayer2D = %AudioStreamPlayer2D
@onready var animation: AnimationComponent = get_sibling(AnimationComponent)


func _ready() -> void:
	if animation:
		animation.step.connect(_on_step)


func _process(delta: float) -> void:
	if not _is_walking:
		return
	_footstep_timer -= delta
	if _footstep_timer <= 0.0:
		_footstep_timer = footstep_interval
		play_footstep()


func play_footstep() -> void:
	if footstep_sounds.is_empty():
		return
	player.stream = footstep_sounds.pick_random()
	player.play()


func play_fire() -> void:
	_play_one_shot(fire_sound)


func _on_step(is_active: bool) -> void:
	_is_walking = is_active
	_footstep_timer = 0.0


func _play_one_shot(stream: AudioStream) -> void:
	if not stream:
		return
	player.stream = stream
	player.play()
