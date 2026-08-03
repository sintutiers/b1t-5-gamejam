extends RapierCharacterBody2D

@export var speed:float = 300
@export var move_action:GUIDEAction

func _process(delta:float) -> void:
	position += move_action.value_axis_2d.normalized() * speed * delta
