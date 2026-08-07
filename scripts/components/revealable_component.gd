#revealable_component.gd
class_name RevealableComponent
extends Node

@export var start_hidden: bool = true
@export var disable_collision_when_hidden: bool = true
@export var dark_layer_number: int = -1

var _revealed: bool
var _parent: Node2D
var _original_parent: Node
var _dark_layer: CanvasLayer


func _ready() -> void:
	_parent = get_parent() as Node2D
	assert(_parent, "RevealableComponent need.")

	_original_parent = _parent.get_parent()
	_dark_layer = _find_canvas_layer_by_number(dark_layer_number)

	LightManager.register_revealable(self)
	_set_revealed_internal(not start_hidden)


func _exit_tree() -> void:
	LightManager.unregister_revealable(self)


func set_revealed(revealed: bool) -> void:
	if revealed == _revealed:
		return
	_set_revealed_internal(revealed)


func get_world_position() -> Vector2:
	return _parent.global_position if _parent else Vector2.ZERO


func _set_revealed_internal(revealed: bool) -> void:
	_revealed = revealed

	if _dark_layer and is_instance_valid(_original_parent):
		var target_parent: Node = _original_parent if revealed else _dark_layer
		if _parent.get_parent() != target_parent:
			var saved_global_position: Vector2 = _parent.global_position
			_parent.reparent(target_parent)
			_parent.global_position = saved_global_position

	for child: Node in _parent.find_children("*", "", true, false):
		if disable_collision_when_hidden and child is CollisionShape2D:
			var shape: CollisionShape2D = child as CollisionShape2D
			shape.disabled = not revealed
		elif disable_collision_when_hidden and child is Area2D:
			var area: Area2D = child as Area2D
			area.monitoring = revealed
			area.monitorable = revealed
		elif child is MovementComponent:
			var movement: MovementComponent = child as MovementComponent
			movement.set_process(revealed)
			movement.set_physics_process(revealed)
		if child is CanvasItem:
			var item: CanvasItem = child as CanvasItem
			item.visible = revealed


func _find_canvas_layer_by_number(layer_number: int) -> CanvasLayer:
	var scene_tree: SceneTree = Engine.get_main_loop() as SceneTree
	if not scene_tree:
		return null
	for layer_node: CanvasLayer in scene_tree.root.find_children("*", "CanvasLayer", true, false):
		if layer_node.layer == layer_number:
			return layer_node
	return null
