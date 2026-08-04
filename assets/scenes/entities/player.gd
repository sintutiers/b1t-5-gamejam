# player.gd
class_name Player
extends RapierCharacterBody2D

@export var light_radius: float = 200.0
@export var speed: float = 300.0


func _ready() -> void:
	LightManager.register_light(self, light_radius)
	add_to_group("player", false)


func _exit_tree() -> void:
	LightManager.unregister_light(self)
