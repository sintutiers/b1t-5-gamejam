class_name RevealMask
extends ColorRect

@export var light_area: RapierArea2D
@export var base_dither_size: float = 40.0


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	if not light_area:
		for child: Node in get_children():
			if child.name == "LightRadius" and child is RapierArea2D:
				light_area = child as RapierArea2D
				break
	if light_area:
		light_area.monitoring = false
		light_area.monitorable = false


func _process(_delta: float) -> void:
	var player_node: Node = get_tree().get_first_node_in_group("player")
	if not (player_node is RapierCharacterBody2D):
		return
	var player: RapierCharacterBody2D = player_node as RapierCharacterBody2D
	var active_material: ShaderMaterial = material as ShaderMaterial
	if not active_material:
		return

	var canvas_transform: Transform2D = get_viewport().get_canvas_transform()
	var canvas_scale: Vector2 = canvas_transform.get_scale()
	var screen_position: Vector2 = canvas_transform * player.global_position

	active_material.set_shader_parameter("light_pos", screen_position)
	active_material.set_shader_parameter(
		"dither_size",
		base_dither_size * max(canvas_scale.x, canvas_scale.y),
	)
	_push_shape_to_shader(active_material, canvas_scale)


func _push_shape_to_shader(shader_material: ShaderMaterial, canvas_scale: Vector2) -> void:
	if not light_area:
		_use_default_circle(shader_material)
		return

	for child: Node in light_area.get_children():
		if not child is CollisionShape2D:
			continue
		var collision_shape: CollisionShape2D = child as CollisionShape2D
		var shape: Shape2D = collision_shape.shape
		if not shape:
			continue

		if shape is CircleShape2D:
			var circle: CircleShape2D = shape as CircleShape2D
			var radius: float = circle.radius * max(canvas_scale.x, canvas_scale.y)
			shader_material.set_shader_parameter("shape_type", 0)
			shader_material.set_shader_parameter("circle_radius", radius)
			return

		if shape is RectangleShape2D:
			var rect: RectangleShape2D = shape as RectangleShape2D
			var pixel_half: Vector2 = rect.size * 0.5 * canvas_scale
			shader_material.set_shader_parameter("shape_type", 1)
			shader_material.set_shader_parameter("rect_half_extents", pixel_half)
			shader_material.set_shader_parameter("rect_rotation", collision_shape.global_rotation)
			return

		break

	_use_default_circle(shader_material)


func _use_default_circle(shader_material: ShaderMaterial) -> void:
	shader_material.set_shader_parameter("shape_type", 0)
	shader_material.set_shader_parameter("circle_radius", 150.0)
