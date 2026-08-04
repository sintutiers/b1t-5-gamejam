# audio_component.gd
class_name AudioComponent
extends Node

@export var footstep_sounds: Array[AudioStream] = []
@export var fire_sound: AudioStream
@export var footstep_frames: Array[int] = [2]

var animation: AnimationComponent

@onready var player: AudioStreamPlayer2D = %AudioStreamPlayer2D


func _ready() -> void:
	call_deferred("_connect_animation")


func play_footstep() -> void:
	if footstep_sounds.is_empty():
		return
	player.stream = footstep_sounds.pick_random()
	player.play()


func play_fire() -> void:
	_play_one_shot(fire_sound)


func _connect_animation() -> void:
	animation = _find_sibling_of_type(AnimationComponent)
	if not animation:
		push_error("no animation")
		return
	animation.sprite.frame_changed.connect(_on_frame_changed)


func _on_frame_changed() -> void:
	if (
		animation.sprite.animation in MovementComponent.DIRECTION_NAMES.values()
		and animation.sprite.frame in footstep_frames
	):
		play_footstep()


func _play_one_shot(stream: AudioStream) -> void:
	if not stream:
		return
	player.stream = stream
	player.play()


func _find_sibling_of_type(type: Script) -> Node:
	var parent: Node = get_parent()
	if not parent:
		push_error("no parent")
		return null
	for child: Node in parent.get_children():
		if is_instance_of(child, type):
			return child
	push_warning("no sibling: %s" % type.resource_path)
	return null
