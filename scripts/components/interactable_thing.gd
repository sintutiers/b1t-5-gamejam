# interactable_thing.gd
class_name Interactable
extends Node2D

signal interacted(by: RapierArea2D)

## TRUE?: pause sprite resume when triggered.
@export var animate_on_interact: bool = false
@export var sprite: AnimatedSprite2D


func _ready() -> void:
	add_to_group(&"interactable")
	if animate_on_interact and not sprite:
		push_warning("No sprite.")
	if animate_on_interact and sprite:
		sprite.pause()


func trigger(by: RapierArea2D) -> void:
	if animate_on_interact and sprite:
		sprite.play()
	interacted.emit(by)
