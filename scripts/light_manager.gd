extends Node

var _lights: Array[LightData] = []
var _revealables: Array[WeakRef] = []


func _process(_delta: float) -> void:
	for i: int in range(_revealables.size() - 1, -1, -1):
		var ref: Object = _revealables[i].get_ref()
		if not ref:
			_revealables.remove_at(i)
			continue
		var revealable: RevealableComponent = ref as RevealableComponent
		revealable.set_revealed(is_point_lit(revealable.get_world_position()))


func register_light(light_node: Node2D, radius: float) -> void:
	_lights.append(LightData.new(light_node, radius))


func unregister_light(light_node: Node2D) -> void:
	for i: int in _lights.size():
		if _lights[i].source == light_node:
			_lights.remove_at(i)
			return


func register_revealable(revealable: RevealableComponent) -> void:
	_revealables.append(weakref(revealable))


func unregister_revealable(revealable: RevealableComponent) -> void:
	for i: int in _revealables.size():
		if _revealables[i].get_ref() == revealable:
			_revealables.remove_at(i)
			return


func is_point_lit(world_position: Vector2) -> bool:
	for light: LightData in _lights:
		if world_position.distance_squared_to(light.source.global_position) <= light.radius_squared:
			return true
	return false


class LightData:
	var source: Node2D
	var radius: float
	var radius_squared: float


	func _init(p_source: Node2D, p_radius: float) -> void:
		source = p_source
		radius = p_radius
		radius_squared = p_radius * p_radius
