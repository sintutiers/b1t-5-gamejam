class_name ItemSlot
extends Control

@onready var icon_rect: TextureRect = $Icon
@onready var count_label: Label = $Count


func _ready() -> void:
	custom_minimum_size = Vector2(64, 64)
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE


func set_item(definition: ItemDefinition, count: int):
	icon_rect.texture = definition.icon
	update_count(count)


func update_count(new_count: int):
	count_label.text = str(new_count)
	count_label.visible = new_count > 0
