# collectable_component.gd
class_name CollectableComponent
extends Component

signal collected(definition: ItemDefinition, amount: int)

@export var definition: ItemDefinition
@export var amount: int = 1
@export var disappear_on_collect: bool = true

@onready var interactable: Interactable = get_sibling(Interactable)


func _ready() -> void:
	interactable.interacted.connect(_on_interacted)
	add_to_group("collectable")


func collect() -> void:
	print("Collectable: emitting collected signal for ", definition.display_name)
	collected.emit(definition, amount)
	if not disappear_on_collect:
		return
	if interactable.animate_on_interact and interactable.sprite:
		await interactable.sprite.animation_finished
	get_parent().queue_free()


func _on_interacted(_by: RapierArea2D) -> void:
	collect()
