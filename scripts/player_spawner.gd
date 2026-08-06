# player_spawner.gd
### non working player spwaing code blocked bc of phantomcamara asigning limitations.
class_name PlayerSpawner
extends Marker2D

@export var player_scene: PackedScene
@export var reuse_existing_player: bool = true
@export var camera: PhantomCamera2D


func _ready() -> void:
	call_deferred("_spawn")


func _spawn() -> void:
	if not player_scene:
		push_error("no player_scene")
		return
	var player: Node2D = _find_existing_player() if reuse_existing_player else null
	if player:
		player.reparent(get_tree().current_scene)
		player.global_position = global_position
	else:
		player = player_scene.instantiate() as Node2D
		get_tree().current_scene.add_child(player)
		player.global_position = global_position
	if camera:
		camera.global_position = player.global_position
		camera.follow_target = player
	else:
		push_warning("no camera assigned.")


func _find_existing_player() -> Node2D:
	var existing: Node = get_tree().get_first_node_in_group(&"player")
	return existing as Node2D
