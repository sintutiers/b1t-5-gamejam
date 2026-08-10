class_name RevealMask
extends ColorRect

@export var light_area: RapierArea2D
@export var parallax: Parallax2D
@export var base_dither_size := 40.0


func _ready() -> void:
	if not light_area:
		for child in get_children():
			if child.name == "LightRadius" and child is RapierArea2D:
				light_area = child
				break

	if light_area:
		light_area.monitoring = false
		light_area.monitorable = false


func _process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as RapierCharacterBody2D
	if not player:
		return

	if parallax:
		parallax.screen_offset = player.global_position

	var mat := material as ShaderMaterial
	if not mat:
		return

	var canvas_transform := get_viewport().get_canvas_transform()
	var scale := canvas_transform.get_scale()

	mat.set_shader_parameter("light_pos", canvas_transform * player.global_position)
	mat.set_shader_parameter("dither_size", base_dither_size * max(scale.x, scale.y))
	_push_shape_to_shader(mat, scale)


func _push_shape_to_shader(mat: ShaderMaterial, scale: Vector2) -> void:
	if not light_area:
		_use_default_circle(mat)
		return

	for child in light_area.get_children():
		if not child is CollisionShape2D:
			continue

		var shape := (child as CollisionShape2D).shape
		if not shape:
			continue

		if shape is CircleShape2D:
			mat.set_shader_parameter("shape_type", 0)
			mat.set_shader_parameter("circle_radius", shape.radius * max(scale.x, scale.y))
			return

		if shape is RectangleShape2D:
			mat.set_shader_parameter("shape_type", 1)
			mat.set_shader_parameter("rect_half_extents", shape.size * 0.5 * scale)
			mat.set_shader_parameter("rect_rotation", child.global_rotation)
			return

		break

	_use_default_circle(mat)


func _use_default_circle(mat: ShaderMaterial) -> void:
	mat.set_shader_parameter("shape_type", 0)
	mat.set_shader_parameter("circle_radius", 150.0)
